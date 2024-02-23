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
      system_repo_root = /home/robert/code/mynixos;
      flake = "${system_repo_root}/machines/${hostname}";
      nixconfig = system_repo_root + /nixconfig;
      system_x86 = "x86_64-linux";
      patchedPkgs = nixpkgs.legacyPackages.x86_64-linux.applyPatches {
        name = "nixpkgs-patched";
        src = nixpkgs;
        patches = [
          # ./patches/immich_244803.patch # https://github.com/NixOS/nixpkgs/pull/244803/files
        ];
      };
      nixosSystem = import (patchedPkgs + "/nixos/lib/eval-config.nix");
      common_modules = [
        agenix.nixosModules.default
        ({ ... }: {
          nixpkgs.config.permittedInsecurePackages = [
            "electron-24.8.6"
          ];
          environment.systemPackages = [ agenix.packages.${system_x86}.default ];
          environment.sessionVariables.FLAKE = "${flake}";
          # After that you can refer to the system version of nixpkgs as <nixpkgs> even without any channels configured.
          # Also, legacy package stuff like the ability to do nix-shell -p netcat just works.
          nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
          environment =
            {
              etc = {
                "nix/channels/nixpkgs".source = nixpkgs;
                "nix/channels/home-manager".source = home-manager;
              };
            };
        })
        (nixconfig + /hosts-blacklist)
        (import (nixconfig + /laptop.nix) system_repo_root)
        (import (nixconfig + /dotfiles/dotfiles.nix) system_repo_root)
        (nixconfig + /common.nix)
        (nixconfig + /pyenv.nix)
      ];
    in
    {
      nixosConfigurations = {
        bear = nixosSystem {
          system = system_x86;
          specialArgs = inputs;
          modules = common_modules ++ [
            inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t495
            ./hardware.nix
            ({ ... }: {
              networking.firewall.enable = false;
              networking.extraHosts = ''
                192.168.178.69 falcon
              '';
            })
          ];
        };
      };
    };
}
