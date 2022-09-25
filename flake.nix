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
    #    flake-utils.url = "github:numtide/flake-utils";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, nixos-hardware, nixpkgs-custom, agenix, ... }@attrs:
    let
      system_x86 = "x86_64-linux";
      system_arm = "aarch64-linux";
      overlay-custom-nixpkgs = system: final: prev: {
        pkgs-custom = import nixpkgs-custom {
          inherit system;
          config.allowUnfree = true;
        };
      };
    in {
      nixosConfigurations = {
        panther = nixpkgs.lib.nixosSystem rec {
          system = system_x86;
          specialArgs = attrs;
          modules = [
            agenix.nixosModule
            { age.secrets.wireless.file = ./secrets/wireless.env.age; }
            ({ ... }: {
              environment.systemPackages = [ agenix.defaultPackage.${system} ];
            })
            nixos-hardware.nixosModules.lenovo-thinkpad-t495
            ./hardware-configurations/t495.nix
            ./machines/t495.nix
            ./nixconfig/hosts-blacklist
            ./nixconfig/laptop.nix
            (import ./nixconfig/common.nix (overlay-custom-nixpkgs system_x86))
          ];
        };
        #        rpi4 = nixpkgs.lib.nixosSystem { ...  };
      };
    };
}
