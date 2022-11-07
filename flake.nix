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
    impermanence = { url = "github:nix-community/impermanence"; };
  };

  outputs = { self, nixpkgs, nixos-hardware, nixpkgs-custom, agenix
    , impermanence, ... }@attrs:
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
            ({ ... }: {
              nixpkgs.overlays = [ (overlay-custom-nixpkgs system_x86) ];
              environment.systemPackages = [ agenix.defaultPackage.${system} ];
            })
            nixos-hardware.nixosModules.lenovo-thinkpad-t495
            ./machines/t495.nix
            ./nixconfig/hosts-blacklist
            ./nixconfig/laptop.nix
            ./nixconfig/common.nix
          ];
        };
        falcon = nixpkgs.lib.nixosSystem rec {
          system = system_x86;
          specialArgs = attrs;
          modules = [
            agenix.nixosModule
            ({ ... }: {
              nixpkgs.overlays = [ (overlay-custom-nixpkgs system_x86) ];
              environment.systemPackages = [ agenix.defaultPackage.${system} ];
            })
            impermanence.nixosModule
            nixos-hardware.nixosModules.dell-xps-13-9360
            ./machines/xps13.nix
            ./nixconfig/hosts-blacklist
            ./nixconfig/laptop.nix
            ./nixconfig/dotfiles.nix
            ./nixconfig/common.nix
          ];
        };
      };
    };
}
