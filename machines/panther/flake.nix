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
    jules_local = { url = "/home/robert/code/jules"; };
  };

  outputs = { self, nixpkgs, nixos-hardware, agenix, impermanence, home-manager, jules_local, ... }@inputs:
    let
      hostname = "panther";
      system = "x86_64-linux";
      system_repo_root = "/home/robert/code/mynixos";
      modules =
        [
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
            };
          })
          ({ ... }: {
            networking.hostName = hostname; # Define your hostname.
            networking.firewall.enable = false;
            networking.extraHosts = ''
              192.168.178.69 falcon
            '';

            systemd.additionalUpstreamSystemUnits = [ "debug-shell.service" ];

            jules.services.renaissance.enable = false;

          })
          (../../nixconfig/home.nix)
          (../../nixconfig/common.nix)
          (../../nixconfig/system.nix)
          (../../nixconfig/laptop.nix)
          (../../nixconfig/dotfiles.nix)
          (../../nixconfig/hosts-blacklist)
          (../../nixconfig/pyenv.nix)
          (./hardware.nix)

          (jules_local.nixosModules.${system}.default)
          (../../nixconfig/kuelap/kuelap.nix)
        ];
    in
    {
      nixosConfigurations =
        let
          patchedPkgs = nixpkgs.legacyPackages.${system}.applyPatches {
            name = "nixpkgs-patched";
            src = nixpkgs;
            patches = [
              # ./patches/immich_244803.patch # https://github.com/NixOS/nixpkgs/pull/244803/files
            ];
          };
          nixosSystem = import (patchedPkgs + "/nixos/lib/eval-config.nix");
        in
        {
          ${hostname} = nixosSystem {
            inherit system;
            specialArgs = inputs;
            modules = modules;
          };
        };
    };
}
