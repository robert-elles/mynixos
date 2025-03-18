{
  description = "Basic example of Nix-on-Droid system config.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-on-droid, home-manager }: {

    nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
      # pkgs = import nixpkgs { system = "aarch64-linux"; };
      modules = [ ./nix-on-droid.nix ];

      extraSpecialArgs = {
        rootPath = /sdcard/Documents/nix-on-droid;
      };

      pkgs = import nixpkgs {
        system = "aarch64-linux";

        overlays = [
          nix-on-droid.overlays.default
          # add other overlays
        ];
      };
    };

  };
}
