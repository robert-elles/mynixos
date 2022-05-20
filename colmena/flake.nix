# colmena build
# colmena apply --on rpi
# https://discourse.nixos.org/t/way-to-build-nixos-on-x86-64-machine-and-serve-to-aarch64-over-local-network/18660/2
{

  description = "Robert's NixOs flake configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-custom.url = "path:/home/robert/code/nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, nixos-hardware, nixpkgs-custom, agenix, ... }@attrs:
    let
      system_arm = "aarch64-linux";
      overlay-custom-nixpkgs = system: final: prev: {
        pkgs-custom = import nixpkgs-custom {
          inherit system;
          config.allowUnfree = true;
        };
      };
    in {
      colmena = {
        meta = { nixpkgs = import nixpkgs { system = system_arm; }; };
        rpi = { pkgs, ... }: {
          deployment = {
            targetHost = "rpi4";
            #              targetPort = 1234;
            targetUser = "robert";
            buildOnTarget = true;
            #            privilegeEscalationCommand = [ "sudo" "-S" ];
          };

          nixpkgs.system = "aarch64-linux";

          #          nix.settings.trusted-public-keys = [ "" ];

          imports = [
            agenix.nixosModule
            {
              age.secrets = {
                wireless.file = ../secrets/wireless.env.age;
                mopidy_extra.file = ../secrets/mopidy_extra.conf.age;
              };
            }
            nixos-hardware.nixosModules.raspberry-pi-4
            ((import ../nixconfig/common.nix)
              (overlay-custom-nixpkgs system_arm))
            ../raspi4b/hardware.nix
            ../raspi4b/system.nix
            ../raspi4b/mopidy.nix
            ../raspi4b/torrent.nix
          ];

        };
      };
    };
}
