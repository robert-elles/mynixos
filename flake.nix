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
    hosts.url = "github:StevenBlack/hosts";
    #    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixos-hardware, hosts, nixpkgs-custom, ... }@attrs:
    let
      system = "x86_64-linux";
      overlay-custom-nixpkgs = final: prev: {
        pkgs-custom = import nixpkgs-custom {
          inherit system;
          config.allowUnfree = true;
        };
      };
    in {
      nixosConfigurations.panther = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = attrs;
        modules = [
          nixos-hardware.nixosModules.lenovo-thinkpad-t495
          ./hardware-configurations/t495.nix
          ./machines/t495.nix
          hosts.nixosModule
          { networking.stevenBlackHosts.enable = true; }
          ./nixconfig/laptop.nix
          (import ./nixconfig/common.nix overlay-custom-nixpkgs)
        ];
      };

    };
}
