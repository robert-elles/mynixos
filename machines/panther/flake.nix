{
  description = "Robert's NixOs flake configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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

  outputs = { self, nixpkgs, ... }@inputs:
    let
      hostname = "panther";
      system = "x86_64-linux";
      system_repo_root = "/home/robert/Nextcloud/code/mynixos";

      settings = {
        inherit system system_repo_root hostname;
        synced_config = "/home/robert/Nextcloud/Config";
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
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.sharedModules = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];
          }
          ({ pkgs, ... }: {
            networking.firewall.enable = true;

            services.displayManager.autoLogin = {
              enable = true;
              user = "robert";
            };

            nix.distributedBuilds = true;
            nix.buildMachines = [
              {
                hostName = "bear";
                maxJobs = 8;
                speedFactor = 2;
                sshUser = "robert";
                system = "x86_64-linux";
              }
            ];

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
          # (../../nixconfig/kuelap/kuelap.nix)
        ];
    in
    {
      nixosConfigurations = {
        ${hostname} = nixosSystem {
          inherit system modules;
          specialArgs = {
            inherit inputs nixpkgs settings;
          };
        };
      };
    };
}
