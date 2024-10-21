{
  description = "Robert's NixOs flake configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs_pin.url = "github:nixos/nixpkgs/c3aa7b8938b17aebd2deecf7be0636000d62a2b9";
    nixpkgs_pin_calibre.url = "github:nixos/nixpkgs/c31898adf5a8ed202ce5bea9f347b1c6871f32d1";
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
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      hostname = "bear";
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

      pkgs-pin = import inputs.nixpkgs_pin {
        inherit system;
        config.allowUnfree = true;
      };

      pkgs-pin-calibre = import inputs.nixpkgs_pin_calibre {
        inherit system;
        config.allowUnfree = true;
      };

      nixosSystem = import (pkgs + "/nixos/lib/eval-config.nix");

      post_login_script = pkgs.writeShellScriptBin "post_login_script" ''
        #!/bin/sh
        xdg-screensaver lock
        EOF
      '';

      modules =
        [
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.sharedModules = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];
          }
          ({ pkgs, ... }: {
            networking.firewall.enable = false;

            services.displayManager.autoLogin = {
              enable = true;
              user = "robert";
            };
            systemd.user.services.auto-login-script = {
              description = "Run script after auto login";
              serviceConfig.ExecStart = "${post_login_script}/bin/post_login_script";
              wantedBy = [ "default.target" ];
            };

            # services.displayManager.autoLogin = {
            #   enable = true;
            #   user = "robert";
            # };

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
            inherit inputs nixpkgs settings pkgs-pin pkgs-pin-calibre;
          };
        };
      };
    };
}
