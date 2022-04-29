# sudo nixos-rebuild dry-build --flake /etc/nixos/mynixos
# example: https://codeberg.org/papojari/nixos-config/src/branch/main/flake.nix
{

  description = "Robert's NixOs flake configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-anki.url = "github:dnaq/nixpkgs/anki-2.1.50";
    nixpkgs-custom.url = "path:/home/robert/code/nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hosts.url = "github:StevenBlack/hosts";
    #    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixos-hardware, hosts, nixpkgs-anki, nixpkgs-custom
    , ... }@attrs:
    let
      system = "x86_64-linux";
      overlay-anki = final: prev: {
        pkgs-anki = nixpkgs-anki.legacyPackages.${prev.system};
        # use this variant if unfree packages are needed:
        # pkgs-anki = import nixpkgs-anki {
        #   inherit system;
        #   config.allowUnfree = true;
        # };
      };
      overlay-custom-nixpkgs = final: prev: {
        pkgs-custom = nixpkgs-custom.legacyPackages.${prev.system};
      };
    in {
      nixosConfigurations.panther = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = attrs;
        modules = [
          nixos-hardware.nixosModules.lenovo-thinkpad-t495
          ./hardware-configurations/t495.nix
          ./machines/t495.nix
          ./nixconfig/laptop.nix
          hosts.nixosModule
          { networking.stevenBlackHosts.enable = true; }
          ({ config, pkgs, lib, ... }: {

            nixpkgs.overlays = [ overlay-anki overlay-custom-nixpkgs ];

            #            pin nixpkgs
            nix.registry.nixpkgs.flake = nixpkgs;

            boot.blacklistedKernelModules = [ "pcspkr" ];

            nix = {
              #    packages = pkgs.nixUnstable;
              extraOptions = ''
                experimental-features = nix-command flakes
              '';
            };

            networking.dhcpcd.wait = "background";
            systemd.services.systemd-udev-settle.enable = false;

            services.openssh.enable = true;

            zramSwap = {
              enable = true;
              algorithm = "zstd";
            };

            time.timeZone = "Europe/Berlin";
            #  time.timeZone = "Asia/Jakarta";
            #  time.timeZone = "Asia/Makassar";

            users.defaultUserShell = pkgs.zsh;
            programs.zsh = { enable = true; };

            # Don't forget to set a password with ‘passwd’.
            users.users = {
              robert = {
                isNormalUser = true;
                extraGroups = [
                  "wheel"
                  "docker"
                  "networkmanager"
                  "video"
                  "input"
                  "btaudio"
                  "audio"
                ];
              };
            };

            nixpkgs.config.allowUnfree = true;
            # List packages installed in system profile. To search, run:
            # $ nix search wget
            environment.systemPackages = with pkgs; [
              vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
              wget
              bind
              nano
              bash
              neofetch
              killall
              cryptsetup
              pstree
              perl
              curl
              htop
              zsh
              git
              oh-my-zsh
              rsync
              ncdu
              bc
              zip
              unzip
              unrar
              mosh
              usbutils
              lsof
              fdupes
              jdupes
              #              pkgs-anki.anki-bin
              pkgs-custom.anki-bin
            ];
          })
        ];
      };

    };
}
