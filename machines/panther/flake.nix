{
  description = "Robert's NixOs flake configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs_pin_virtualbox.url = "github:nixos/nixpkgs/c3aa7b8938b17aebd2deecf7be0636000d62a2b9";
    # nixpkgs_pin.url = "github:nixos/nixpkgs/23e89b7da85c3640bbc2173fe04f4bd114342367";
    nixpkgs_pin.url = "github:nixos/nixpkgs/3592d2c1c29e6c3d437ce37b577c21f85fd0d2fc";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    isd.url = "github:isd-project/isd";
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
    betterfox = {
      url = "github:HeitorAugustoLN/betterfox-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
          ../../patches/super-productivity.patch
        ];
      };

      pkgs-pin-virtualbox = import inputs.nixpkgs_pin_virtualbox {
        inherit system;
        config.allowUnfree = true;
      };

      pkgs-pin = import inputs.nixpkgs_pin {
        inherit system;
        config.allowUnfree = true;
      };

      nixosSystem = import (pkgs + "/nixos/lib/eval-config.nix");

      modules =
        [
          inputs.chaotic.nixosModules.default
          inputs.nixos-facter-modules.nixosModules.facter
          { config.facter.reportPath = ./facter.json; }
          # inputs.home-manager.nixosModules.home-manager
          # {
          # home-manager.useGlobalPkgs = true;
          # home-manager.useUserPackages = true;
          # home-manager.sharedModules = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];
          # home-manager.users.robert = import ./home.nix;
          # }
          ({ pkgs, ... }: {

            nixpkgs = {
              overlays = [ inputs.nur.overlays.default ];
            };

            systemd.network.wait-online.enable = false;

            environment.systemPackages = [ inputs.isd.packages.${system}.isd ];

            networking.firewall = {
              enable = false;
              # allowedTCPPorts = [ 80 443  ];
              # allowedUDPPortRanges = [
              #   { from = 4000; to = 4007; }
              #   { from = 8000; to = 8010; }
              # ];
            };

            services.displayManager.autoLogin = {
              enable = true;
              user = "robert";
            };

            # services.icecast = {
            #   enable = true;
            # };

            nix.distributedBuilds = true;
            nix.buildMachines = [
              {
                hostName = "bear";
                maxJobs = 16;
                speedFactor = 3;
                sshUser = "robert";
                system = "x86_64-linux";
              }
            ];

            # systemd.additionalUpstreamSystemUnits = [ "debug-shell.service" ];
            # jules.services.renaissance.enable = false;
          })
          # (../../nixconfig/home.nix)
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
            inherit inputs nixpkgs settings pkgs-pin-virtualbox pkgs-pin;
          };
        };
      };
    };
}
