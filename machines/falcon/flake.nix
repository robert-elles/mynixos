{
  description = "Robert's NixOs flake configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    flake-utils.url = "github:numtide/flake-utils";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = { url = "github:nix-community/impermanence"; };
    # jules.url = "git+ssh://git@github.com/robert-elles/jules?ref=main";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      hostname = "falcon";
      system = "x86_64-linux";
      system_repo_root = "/home/robert/Nextcloud/code/mynixos";

      parameters =
        builtins.fromJSON (builtins.readFile (system_repo_root + "/secrets/gitcrypt/params.json"));

      settings = {
        inherit system system_repo_root hostname;
        public_hostname = parameters.public_hostname;
        public_hostname2 = parameters.public_hostname2;
        email = parameters.email;
      };

      pkgs = nixpkgs.legacyPackages.${system}.applyPatches {
        name = "nixpkgs-patched";
        src = nixpkgs;
        patches = [
        ];
      };

      nixosSystem = import (pkgs + "/nixos/lib/eval-config.nix");

      modules =
        [
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.sharedModules = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];
          }
          ({ pkgs, ... }: {

            networking.firewall.enable = false;
            networking.extraHosts = ''
              192.168.178.69 falcon
            '';

            services.logind.lidSwitchExternalPower = "lock";
            services.logind.lidSwitchDocked = "lock";
            services.logind.lidSwitch = "lock";
            # powerManagement.enable = false;
            services.autosuspend.enable = false;
            systemd.sleep.extraConfig = ''
              AllowSuspend=no
              AllowHibernation=no
              AllowHybridSleep=no
              AllowSuspendThenHibernate=no
            '';

            users.users."robert".linger = true;
            # services.displayManager.autoLogin = {
            #   enable = true;
            #   user = "robert";
            # };

            # jules.services.jupyter = {
            #   enable = true;
            #   password = "argon2:$argon2id$v=19$m=10240,t=10,p=8$uZibffn4smeNyJJJCaycEA$ccK5+/+/LfpHfwydNYAGTkYDd8Zd2tGobE0j0xXgAJk";
            #   user = "robert";
            #   group = "users";
            #   notebookDir = "/home/robert/code/jules";
            # };
            # jules.timers.crawlers.enable = true;
            # jules.services.mercury.enable = true;

            environment.systemPackages = with pkgs; [
              pavucontrol
              docker-compose
              firefox
              chromium
              jamesdsp
              spotify
              devenv
            ];

            home-manager = {
              users.robert = {
                services.easyeffects.enable = true;
              };
            };

            virtualisation.docker.enable = true;

          })
          (../../nixconfig/home.nix)
          (../../nixconfig/common.nix)
          (../../nixconfig/powersave.nix)
          (../../nixconfig/system.nix)
          (../../nixconfig/kde.nix)
          (../../nixconfig/dotfiles.nix)
          (../../nixconfig/hosts-blacklist)
          (../../nixconfig/pyenv.nix)
          (./hardware.nix)

          # (jules.nixosModules.${system}.default)

          ../../nixconfig/server/disks.nix
          ../../nixconfig/server/agenix.nix
          ../../nixconfig/server/dyndns.nix
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
          ../../nixconfig/server/vikunja.nix
          ../../nixconfig/server/stirlingpdf.nix
          # ../../nixconfig/server/openproject.nix
        ];
    in
    {
      nixosConfigurations = {
        ${hostname} = nixosSystem {
          inherit system modules;
          specialArgs = {
            inherit nixpkgs inputs settings;
          };
        };
      };
    };
}
