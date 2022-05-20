# sudo nixos-rebuild dry-build --flake /etc/nixos/mynixos
# example: https://codeberg.org/papojari/nixos-config/src/branch/main/flake.nix
{

  description = "Robert's NixOs flake configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-custom.url = "path:/home/robert/code/nixpkgs";
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

  outputs =
    { self, nixpkgs, nixos-hardware, nixpkgs-custom, agenix, ... }@attrs:
    let
      system_arm = "aarch64-linux";
      overlay-custom-nixpkgs = system: final: prev: {
        pkgs-custom = import nixpkgs-custom {
          inherit system;
          config.allowUnfree = true;
        };
      };
    in {
      nixosConfigurations = {

        rpi4 = nixpkgs.lib.nixosSystem {
          system = system_arm;
          specialArgs = attrs;
          modules = [
            agenix.nixosModule
            {
              age.secrets = {
                wireless.file = ../secrets/wireless.env.age;
                mopidy_extra.file = ../secrets/mopidy_extra.conf.age;
              };
            }
            ({ ... }: {
              environment.systemPackages =
                [ agenix.defaultPackage.${system_arm} ];
            })
            nixos-hardware.nixosModules.raspberry-pi-4
            ./hardware.nix
            ./system.nix
            ./home.nix
            (import ../nixconfig/common.nix (overlay-custom-nixpkgs system_arm))
            ./mopidy.nix
            ./torrent.nix
          ];
        };
      };
    };
}
