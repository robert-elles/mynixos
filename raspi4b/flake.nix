# sudo nixos-rebuild dry-build --flake /etc/nixos/mynixos
# example: https://codeberg.org/papojari/nixos-config/src/branch/main/flake.nix
{

  description = "Robert's NixOs flake configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs-custom.url = "path:/home/robert/code/nixpkgs";
    home_manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-hardware, nixpkgs-custom, home_manager
    , agenix, ... }@attrs:
    let
      system_arm = "aarch64-linux";
      overlay-custom-nixpkgs = system: final: prev: {
        pkgs-custom = import nixpkgs-custom {
          inherit system;
          config.allowUnfree = true;
        };
      };
      modules = [
        agenix.nixosModule
        {
          age.secrets = {
            #            rpi4.file = ./secrets/rpi4.nix.age;
            wireless.file = ./secrets/wireless.env.age;
            mopidy_extra.file = ./secrets/mopidy_extra.conf.age;
            dbpass = {
              file = ./secrets/dbpass.age;
              mode = "770";
              owner = "nextcloud";
              group = "nextcloud";
            };
            nextcloud_adminpass = {
              file = ./secrets/nextcloud_adminpass.age;
              mode = "770";
              owner = "nextcloud";
              group = "nextcloud";
            };
          };
        }
        ({ ... }: {
          environment.systemPackages = [ agenix.defaultPackage.${system_arm} ];
        })
        nixos-hardware.nixosModules.raspberry-pi-4
        (import ../nixconfig/common.nix (overlay-custom-nixpkgs system_arm))
        ./hardware.nix
        ./bluesound.nix
        #        ./latest_rpi_kernel.nix
        ./system.nix
        ./mopidy.nix
        ./torrent.nix
        home_manager.nixosModule
        ./home.nix
        ./nextcloud.nix
      ];
    in {
      colmena = {
        # colmena build <- only builds localy
        # colmena apply --on rpi <- builds and applies to rpi
        meta = { nixpkgs = import nixpkgs { system = system_arm; }; };
        rpi = { pkgs, ... }: {
          nixpkgs.system = system_arm;
          deployment = {
            targetHost = "rpi4";
            targetUser = "robert";
            buildOnTarget = true;
          };
          imports = modules;
        };
      };
      nixosConfigurations = {
        rpi4 = nixpkgs.lib.nixosSystem {
          system = system_arm;
          specialArgs = attrs;
          modules = modules;
        };
      };
    };
}
