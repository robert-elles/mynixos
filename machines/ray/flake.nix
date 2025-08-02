{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # https://github.com/zhaofengli/nix-homebrew
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, ... }:
    let
      hostname = "ray";
      user_home = "/Users/rell";
      system_repo_root = "${user_home}/Nextcloud/code/mynixos";
      settings = { inherit system_repo_root hostname user_home; };

      configuration = { pkgs, ... }: {
        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget
        environment.systemPackages = with pkgs; [
          ncdu
          git
          nom
          et
          htop
          btop
          nixfmt
          git-crypt
          repomix
          claude-code
          # aider-chat
          # aider-chat-with-playwright
          # aider-chat-with-browser
          devenv
          skhd # Simple Hotkey Daemon for global keyboard shortcuts
          alt-tab-macos
          nodejs
          glab
          temurin-bin
          docker
          docker-compose
          docker-credential-helpers
          # script-directory
          bindfs
          mongodb-compass
          openvpn
          mr # myrepos
          gita # alternative to myrepos
          mu-repo # alternative to myrepos
          uv
          ruff
          tilt
          kubectl
          kubernetes-helm
          k9s
          audacity
          postgresql
        ];
        nix.enable = false;
        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes";

        nix = {
          settings = {
            trusted-users = [ "root" "rell" ];
            substituters = [
              "https://devenv.cachix.org"
              "https://nix-community.cachix.org"
            ];
            trusted-public-keys = [
              "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
            ];
          };
        };

        # Enable alternative shell support in nix-darwin.
        # programs.fish.enable = true;

        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 6;

        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "aarch64-darwin";
        nixpkgs.config.allowUnfree = true;

        # Set the primary user for services that require a user context
        system.primaryUser = "rell";

        users.users.rell = {
          name = "rell";
          home = user_home;
        };

        environment.variables = rec {
          FLAKE = "${settings.system_repo_root}/machines/${settings.hostname}";
        };
        # Configure skhd for global keyboard shortcuts
        services.skhd = {
          enable = false;
          # run skhd --reload
          skhdConfig = ''
            # Cmd + B: Open new Firefox window
            # cmd - b : open -n -a Firefox

            # Cmd + E: Open new Finder window
            cmd - e : open -n -a Finder

            # Cmd + Enter: Open new Terminal window
            cmd - return : open -n -a Terminal
          '';
        };

        system.defaults = {
          CustomUserPreferences = {
            "org.hammerspoon.Hammerspoon" = {
              MJConfigFile =
                "${settings.system_repo_root}/dotfiles/hammerspoon/init.lua";
            };
          };
        };
      };
    in {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#MBCXDL4Y4V0WMT
      darwinConfigurations."ray" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs nixpkgs settings; };
        modules = [
          configuration
          inputs.nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              # Install Homebrew under the default prefix
              enable = true;
              autoMigrate = true; # existing brew installation
              # User owning the Homebrew prefix
              user = "rell";
              # Optional: Declarative tap management
              taps = {
                "homebrew/homebrew-core" = inputs.homebrew-core;
                "homebrew/homebrew-cask" = inputs.homebrew-cask;
              };

              # Optional: Enable fully-declarative tap management
              #
              # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
              mutableTaps = false;
            };
            homebrew = {
              onActivation = {
                autoUpdate = true;
                cleanup = "zap";
                upgrade = true;
                extraFlags = [ "--verbose" ];
              };
            };
            homebrew.casks = [ "hammerspoon" "wine@staging" ];
          }
          inputs.agenix.nixosModules.default
          ({ ... }: {
            age.identityPaths = [ "/home/robert/.ssh/id_ed25519_home" ];
            age.secrets = {
              atuin_key = {
                file = ../../secrets/agenix/atuin_key.age;
                owner = "rell";
              };
            };
          })
          inputs.home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = false;
            home-manager.users.rell = ./home.nix;
            home-manager.backupFileExtension = "hm.bak";
            home-manager.extraSpecialArgs = { inherit settings; };
            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
        ];
      };
    };
}
