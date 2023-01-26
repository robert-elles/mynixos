# example: https://codeberg.org/papojari/nixos-config/src/branch/main/flake.nix
{

  description = "Robert's NixOs flake configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-hardware, agenix, home-manager, ... }@attrs:
    let
      system_arm = "aarch64-linux";
      modules = [
        agenix.nixosModule
        {
          age.secrets = {
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
          environment =
            {
              etc = {
                "nix/channels/nixpkgs".source = nixpkgs;
                "nix/channels/home-manager".source = home-manager;
              };
            };
        })
        nixos-hardware.nixosModules.raspberry-pi-4
        ../nixconfig/common.nix
        ./system.nix
        home-manager.nixosModule
        ./home.nix
        ./bluesound.nix
        ./spotifyd.nix
        ./mopidy.nix
        ./torrent.nix
        ./nextcloud.nix
        ./services.nix
        ./mediacenter.nix
      ];
    in
    {
      colmena = {
        # colmena build <- only builds localy
        # colmena apply --on rpi <- builds and applies to rpi
        meta = { nixpkgs = import nixpkgs { system = system_arm; }; };
        rpi4 = { pkgs, ... }: {
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
