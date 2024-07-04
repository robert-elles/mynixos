{
  description = "Robert's NixOs flake configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # vscode-pin-nixpkgs.url = "nixpkgs/cbc4211f0afffe6dfd2478a62615dd5175a13f9a";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    flake-utils.url = "github:numtide/flake-utils";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = { url = "github:nix-community/impermanence"; };
    # jules_local = { url = "/home/robert/code/jules"; };
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      hostname = "panther";
      system = "x86_64-linux";
      system_repo_root = "/home/robert/Nextcloud/code/mynixos";

      settings = {
        inherit system system_repo_root hostname;
      };

      pkgs = nixpkgs.legacyPackages.${system}.applyPatches {
        name = "nixpkgs-patched";
        src = nixpkgs;
        patches = [
        ];
      };

      # pkgs-vscode-pin = import inputs.vscode-pin-nixpkgs {
      #   inherit system;
      #   config.allowUnfree = true;
      # };

      nixosSystem = import (pkgs + "/nixos/lib/eval-config.nix");

      modules =
        [
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.sharedModules = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];
          }
          ({ ... }: {
            networking.firewall.enable = true;

            services.displayManager.autoLogin = {
              enable = true;
              user = "robert";
            };

            # systemd.additionalUpstreamSystemUnits = [ "debug-shell.service" ];
            # jules.services.renaissance.enable = false;
          })
          (../../nixconfig/home.nix)
          (../../nixconfig/common.nix)
          (../../nixconfig/system.nix)
          (../../nixconfig/laptop.nix)
          (../../nixconfig/dotfiles.nix)
          (../../nixconfig/hosts-blacklist)
          (../../nixconfig/pyenv.nix)
          (./hardware.nix)

          # (jules_local.nixosModules.${system}.default)
          (../../nixconfig/kuelap/kuelap.nix)
        ];
    in
    {
      nixosConfigurations = {
        ${hostname} = nixosSystem {
          inherit system modules;
          specialArgs = {
            inherit inputs nixpkgs settings;
            # inherit pkgs-vscode-pin;
          };
        };
      };
    };
}
