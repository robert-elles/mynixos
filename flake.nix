{

  description = "Robert's NixOs flake configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    #    nixpkgs-custom.url = "path:/home/robert/code/nixpkgs";
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

  outputs = { self, nixpkgs, nixos-hardware, agenix, impermanence, ... }@attrs:
    let
      system_repo_root = "/etc/nixos/mynixos";
      system_x86 = "x86_64-linux";
      system_arm = "aarch64-linux";
      #      overlay-custom-nixpkgs = system: final: prev: {
      #        pkgs-custom = import nixpkgs-custom {
      #          inherit system;
      #          config.allowUnfree = true;
      #        };
      #      };
      patchedPkgs = nixpkgs.legacyPackages.x86_64-linux.applyPatches {
        name = "nixpkgs-patched";
        src = nixpkgs;
        patches = [
          ./patches/0001-add-vulkan-loader-to-LD_LIBRARY_PATH-to-enable-vulka.patch
        ];
      };
      nixosSystem = import (patchedPkgs + "/nixos/lib/eval-config.nix");
    in {
      nixosConfigurations = {
        panther = nixosSystem rec {
          system = system_x86;
          specialArgs = attrs;
          modules = [
            agenix.nixosModule
            ({ ... }: {
              #              nixpkgs.overlays = [ (overlay-custom-nixpkgs system_x86) ];
              environment.systemPackages = [ agenix.defaultPackage.${system} ];
            })
            nixos-hardware.nixosModules.lenovo-thinkpad-t495
            ./machines/t495.nix
            ./nixconfig/hosts-blacklist
            ./nixconfig/laptop.nix
            (import ./dotfiles/dotfiles.nix system_repo_root)
            ./nixconfig/common.nix
          ];
        };
        falcon = nixosSystem rec {
          system = system_x86;
          specialArgs = attrs;
          modules = [
            agenix.nixosModule
            ({ ... }: {
              #              nixpkgs.overlays = [ (overlay-custom-nixpkgs system_x86) ];
              environment.systemPackages = [ agenix.defaultPackage.${system} ];
            })
            impermanence.nixosModule
            nixos-hardware.nixosModules.dell-xps-13-9360
            ./machines/xps13.nix
            ./nixconfig/hosts-blacklist
            ./nixconfig/laptop.nix
            (import ./dotfiles/dotfiles.nix system_repo_root)
            ./nixconfig/common.nix
          ];
        };
      };
    };
}
