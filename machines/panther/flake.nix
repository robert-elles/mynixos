{
  description = "Robert's NixOs flake configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs_pin.url =
      "github:nixos/nixpkgs/e4bae1bd10c9c57b2cf517953ab70060a828ee6f";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
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
    # impermanence = { url = "github:nix-community/impermanence"; };
    betterfox = {
      url = "github:HeitorAugustoLN/betterfox-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      hostname = "panther";
      system = "x86_64-linux";
      system_repo_root = "/home/robert/Nextcloud/code/mynixos";

      settings = {
        inherit system system_repo_root hostname;
        synced_config = "/home/robert/Nextcloud/Config";
        server_ip = "192.168.178.38"; # leopard
      };

      pkgs = nixpkgs.legacyPackages.${system}.applyPatches {
        name = "nixpkgs-patched";
        src = nixpkgs;
        # patches = [ ];
      };

      pkgs-pin = import inputs.nixpkgs_pin {
        inherit system;
        config.allowUnfree = true;
      };

      nixosSystem = import (pkgs + "/nixos/lib/eval-config.nix");

      modules = [
        inputs.chaotic.nixosModules.default
        inputs.nixos-facter-modules.nixosModules.facter
        { config.facter.reportPath = ./facter.json; }
        ({ pkgs, ... }: {

          nixpkgs = {
            overlays =
              [ inputs.chaotic.overlays.default inputs.nur.overlays.default ];
          };

          environment.systemPackages = [ ];

          systemd.network.wait-online.enable = false;
          networking.firewall = { enable = false; };

          services.displayManager.autoLogin = {
            enable = true;
            user = "robert";
          };

          nix.distributedBuilds = true;
          nix.buildMachines = [{
            hostName = "leopard";
            maxJobs = 16;
            speedFactor = 3;
            sshUser = "robert";
            system = "x86_64-linux";
          }];
        })
        (../../nixconfig/system.nix)
        (../../nixconfig/common.nix)
        (../../nixconfig/home.nix)
        (../../nixconfig/powersave.nix)
        (../../nixconfig/laptop.nix)
        (../../nixconfig/hosts-blacklist)
        (../../nixconfig/pyenv.nix)
        (./hardware.nix)
      ];
    in {
      nixosConfigurations = {
        ${hostname} = nixosSystem {
          inherit system modules;
          specialArgs = { inherit inputs nixpkgs settings pkgs-pin; };
        };
      };
    };
}
