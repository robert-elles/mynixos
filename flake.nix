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
    pypi-deps-db = {
      url = "github:DavHau/pypi-deps-db";
      inputs.mach-nix.follows = "mach-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mach-nix = {
      url = "mach-nix/3.5.0";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pypi-deps-db.follows = "pypi-deps-db";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = { url = "github:nix-community/impermanence"; };
  };

  outputs = { self, nixpkgs, nixos-hardware, agenix, impermanence, ... }@inputs:
    let
      #      mach-nix = import inputs.mach-nix {
      #                inherit pkgs;
      #        python = "python3";
      #
      # Latest dependency resolution chain as of May 08, 2021
      #                pypiDataRev = "e674adca06b80ff3831e28cdcff041c44b960bb4";
      #                pypiDataSha256 = "0p90r8daaklp9dqy6ik1wf1c0y32hr2w7rz6ba3g7xb7vfgz17pf";
      #      };
      system_repo_root = "/home/robert/code/mynixos";
      system_x86 = "x86_64-linux";
      patchedPkgs = nixpkgs.legacyPackages.x86_64-linux.applyPatches {
        name = "nixpkgs-patched";
        src = nixpkgs;
        patches = [
          ./patches/0001-add-vulkan-loader-to-LD_LIBRARY_PATH-to-enable-vulka.patch
        ];
      };
      nixosSystem = import (patchedPkgs + "/nixos/lib/eval-config.nix");
      common_modules = [
        agenix.nixosModule
        ({ ... }: {
          environment.systemPackages = [ agenix.defaultPackage.${system_x86} ];
        })
        ./nixconfig/hosts-blacklist
        (import ./nixconfig/laptop.nix system_repo_root)
        (import ./dotfiles/dotfiles.nix system_repo_root)
        ./nixconfig/common.nix
      ];
    in {
      nixosConfigurations = {
        panther = nixosSystem rec {
          system = system_x86;
          specialArgs = inputs;
          modules = common_modules ++ [
            inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t495
            ./machines/t495.nix
          ];
        };
        falcon = nixosSystem rec {
          system = system_x86;
          specialArgs = inputs;
          modules = common_modules ++ [
            nixos-hardware.nixosModules.dell-xps-13-9360
            ./machines/xps13.nix
          ];
        };
      };
    };
}
