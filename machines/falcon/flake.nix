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
    jules.url = "git+ssh://git@github.com/robert-elles/jules?ref=main";
  };

  outputs = { self, nixpkgs, nixos-hardware, agenix, impermanence, home-manager, jules, ... }@inputs:
    let
      hostname = "falcon";
      system = "x86_64-linux";
      system_repo_root = "/home/robert/code/mynixos";
      modules =
        [
          ({ ... }: with nixpkgs.lib; {
            options.mynix = {
              system = mkOption {
                type = types.str;
                default = system;
                description = "The system to build for";
              };

              system_repo_root = mkOption {
                type = types.str;
                default = system_repo_root;
                description = "The root of the system repository";
              };

              system_flake = mkOption {
                type = types.str;
                default = "${system_repo_root}/machines/${hostname}";
                description = "The flake to build for";
              };
            };
          })
          ({ ... }: {
            networking.hostName = hostname; # Define your hostname.
            networking.firewall.enable = false;
            networking.extraHosts = ''
              192.168.178.69 falcon
            '';

            systemd.additionalUpstreamSystemUnits = [ "debug-shell.service" ];

            jules.services.jupyter = {
              enable = true;
              password = "argon2:$argon2id$v=19$m=10240,t=10,p=8$uZibffn4smeNyJJJCaycEA$ccK5+/+/LfpHfwydNYAGTkYDd8Zd2tGobE0j0xXgAJk";
              user = "robert";
              group = "users";
              notebookDir = "/home/robert/code/jules";
            };
            jules.timers.crawlers.enable = true;
            jules.services.mercury.enable = true;

            services.xserver.displayManager.autoLogin = {
              enable = true;
              user = "robert";
            };
          })
          (../../nixconfig/hosts-blacklist)
          (../../nixconfig/dotfiles.nix)
          (../../nixconfig/common.nix)
          (../../nixconfig/pyenv.nix)
          (./hardware.nix)

          (jules.nixosModules.${system}.default)

          ../../nixconfig/server/disks.nix
          ../../nixconfig/server/agenix.nix
          ../../nixconfig/server/postgres.nix
          ../../nixconfig/server/acmeproxy.nix
          ../../nixconfig/server/nextcloud.nix
          ../../nixconfig/server/nfs.nix
          ../../nixconfig/server/samba.nix
          ../../nixconfig/server/services.nix
          ../../nixconfig/server/paperless.nix
          ../../nixconfig/server/torrent.nix
          ../../nixconfig/server/audiobookshelf.nix
          ../../nixconfig/server/calibre-web.nix
          ../../nixconfig/server/bluetooth_speaker
          ../../nixconfig/server/spotifyd.nix
        ];
    in
    {
      nixosConfigurations =
        let
          patchedPkgs = nixpkgs.legacyPackages.${system}.applyPatches {
            name = "nixpkgs-patched";
            src = nixpkgs;
            patches = [
              # ./patches/immich_244803.patch # https://github.com/NixOS/nixpkgs/pull/244803/files
            ];
          };
          nixosSystem = import (patchedPkgs + "/nixos/lib/eval-config.nix");
        in
        {
          ${hostname} = nixosSystem {
            inherit system;
            specialArgs = inputs;
            modules = modules;
          };
        };
    };
}
