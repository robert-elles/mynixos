{
  description = "Robert's NixOs flake configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs_pin_virtualbox.url = "github:nixos/nixpkgs/c3aa7b8938b17aebd2deecf7be0636000d62a2b9";
    nixpkgs_pin.url = "github:nixos/nixpkgs/23e89b7da85c3640bbc2173fe04f4bd114342367";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
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
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.sharedModules = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];
          }
          ({ pkgs, ... }:
            # let
            #   post_login_script = pkgs.writeShellScriptBin "post_login_script" ''
            #     #!/bin/sh
            #     xdg-screensaver lock
            #     EOF
            #   '';
            # in
            {
              systemd.network.wait-online.enable = false;

              networking.firewall.enable = false;

              # services.displayManager.autoLogin = {
              #   enable = true;
              #   user = "robert";
              # };
              # systemd.user.services.auto-login-script = {
              #   description = "Run script after auto login";
              #   serviceConfig.ExecStart = "${post_login_script}/bin/post_login_script";
              #   wantedBy = [ "default.target" ];
              #   type = "oneshot";
              #   remainAfterExit = true;
              # };

              # services.ollama = {
              #   enable = true;
              #   acceleration = "rocm";
              #   # environmentVariables = {
              #   #   HCC_AMDGPU_TARGET = "gfx1031"; # used to be necessary, but doesn't seem to anymore
              #   # };
              #   # rocmOverrideGfx = "10.3.1";
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
            inherit inputs nixpkgs settings pkgs-pin-virtualbox pkgs-pin;
          };
        };
      };
    };
}
