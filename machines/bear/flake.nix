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
  };

  outputs = { self, nixpkgs, nixos-hardware, agenix, impermanence, home-manager, ... }@inputs:
    let
      hostname = "bear";
      system_repo_root = "/home/robert/code/mynixos";
      nixconfig = /. + system_repo_root + /nixconfig;
      system = "x86_64-linux";
      patchedPkgs = nixpkgs.legacyPackages.x86_64-linux.applyPatches {
        name = "nixpkgs-patched";
        src = nixpkgs;
        patches = [
          # ./patches/immich_244803.patch # https://github.com/NixOS/nixpkgs/pull/244803/files
        ];
      };
      nixosSystem = import (patchedPkgs + "/nixos/lib/eval-config.nix");
      modules = [
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

            networking.firewall.enable = false;
            networking.extraHosts = ''
              192.168.178.69 falcon
            '';
          };
        })
        agenix.nixosModules.default
        (nixconfig + /hosts-blacklist)
        (nixconfig + /laptop.nix)
        (nixconfig + /dotfiles.nix)
        (nixconfig + /common.nix)
        (nixconfig + /pyenv.nix)
        (./hardware.nix)
      ];
    in
    {
      nixosConfigurations = {
        bear = nixosSystem {
          inherit system;
          specialArgs = inputs;
          modules = modules;
        };
      };
    };
}
