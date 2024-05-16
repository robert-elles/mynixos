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
      system = "x86_64-linux";
      system_repo_root = "/home/robert/code/mynixos";

      settings = {
        inherit system system_repo_root hostname;
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
          ({ pkgs, ... }: {
            networking.hostName = hostname; # Define your hostname.
            networking.firewall.enable = false;
            networking.extraHosts = ''
              192.168.178.69 falcon
            '';

            services.displayManager.autoLogin = {
              enable = true;
              user = "robert";
            };

            services.mysql = {
              enable = true;
              package = pkgs.mariadb;
            };

            nix.settings.trusted-substituters = [ "https://ai.cachix.org" ];
            nix.settings.trusted-public-keys = [ "ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc=" ];
          })
          (../../nixconfig/home.nix)
          (../../nixconfig/common.nix)
          (../../nixconfig/laptop.nix)
          (../../nixconfig/system.nix)
          (../../nixconfig/dotfiles.nix)
          (../../nixconfig/hosts-blacklist)
          (../../nixconfig/pyenv.nix)
          (./hardware.nix)
        ];
    in
    {
      nixosConfigurations = {
        ${hostname} = nixosSystem {
          inherit system modules;
          specialArgs = {
            inherit nixpkgs nixos-hardware agenix impermanence home-manager;
            inherit settings;
          };
        };
      };
    };
}
