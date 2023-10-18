{
  description = "Robert's NixOs flake configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = { url = "github:nix-community/impermanence"; };
    jules = { url = "/home/robert/code/jules"; };
    # mynixos-private = {
    #   url = "git+ssh://git@github.com/robert-elles/mynixos-private";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = { self, nixpkgs, nixos-hardware, agenix, impermanence, home-manager, jules, ... }@inputs:
    let
      system_repo_root = "/home/robert/code/mynixos";
      secrets_dir = system_repo_root + "/secrets/agenix";
      system_x86 = "x86_64-linux";
      patchedPkgs = nixpkgs.legacyPackages.x86_64-linux.applyPatches {
        name = "nixpkgs-patched";
        src = nixpkgs;
        patches = [
          ./patches/paperless.patch # https://nixpk.gs/pr-tracker.html?pr=259056
        ];
      };
      nixosSystem = import (patchedPkgs + "/nixos/lib/eval-config.nix");
      common_modules = [
        agenix.nixosModules.default
        ({ lib, ... }: {
          options = {
            system_repo_root = {
              type = lib.types.path;
              default = /home/robert/code/mynixos;
            };
          };
        })
        ({ ... }: {
          environment.systemPackages = [ agenix.packages.${system_x86}.default ];
          environment.sessionVariables.FLAKE = "${system_repo_root}";
          # After that you can refer to the system version of nixpkgs as <nixpkgs> even without any channels configured.
          # Also, legacy package stuff like the ability to do nix-shell -p netcat just works.
          nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
          environment =
            {
              etc = {
                "nix/channels/nixpkgs".source = nixpkgs;
                "nix/channels/home-manager".source = home-manager;
              };
            };
        })
        ./nixconfig/hosts-blacklist
        (import ./nixconfig/laptop.nix system_repo_root)
        (import ./dotfiles/dotfiles.nix system_repo_root)
        ./nixconfig/common.nix
        ./nixconfig/pyenv.nix
      ];
    in
    {
      nixosConfigurations = {
        panther = nixosSystem rec {
          system = system_x86;
          specialArgs = inputs;
          modules = common_modules ++ [
            inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t495
            ./machines/t495.nix
            jules.nixosModules.${system}.default
            jules.nixosModules.${system}.crawlers
            ({ ... }: {
              # Open ports in the firewall.
              # networking.firewall.allowedTCPPorts = [ 8080 ];
              # networking.firewall.allowedUDPPorts = [ ... ];
              networking.firewall.enable = false;
            })
          ];
        };
        falcon = nixosSystem rec {
          system = system_x86;
          specialArgs = inputs;
          modules = common_modules ++ [
            nixos-hardware.nixosModules.dell-xps-13-9360
            ./machines/xps13.nix
            jules.nixosModules.${system}.default
            jules.nixosModules.${system}.crawlers
            ({ ... }: {
              jules.services.jupyter = {
                enable = true;
                password = "argon2:$argon2id$v=19$m=10240,t=10,p=8$uZibffn4smeNyJJJCaycEA$ccK5+/+/LfpHfwydNYAGTkYDd8Zd2tGobE0j0xXgAJk";
                user = "robert";
                group = "users";
                notebookDir = "/home/robert/code/jules";
              };
              jules.timers.crawlers.enable = true;
              jules.timers.crawlers.onCalendar = "*-*-* 4:00:00 Europe/Berlin";
            })
            ./nixconfig/server/disks.nix
            ./nixconfig/server/agenix.nix
            ({ ... }: {
              security.sudo.wheelNeedsPassword = false;
              networking.firewall.enable = false;
            })
            ./nixconfig/server/nextcloud.nix
            ./nixconfig/server/nfs.nix
            ./nixconfig/server/samba.nix
            ./nixconfig/server/services.nix
            ./nixconfig/server/paperless.nix
            ./nixconfig/server/torrent.nix
            ./nixconfig/server/audiobookshelf.nix
            ./nixconfig/server/calibre-web.nix
            ./nixconfig/server/bluetooth_speaker
            ./nixconfig/server/spotifyd.nix
          ];
        };
      };
    };
}
