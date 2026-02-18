{
  description = "Example nix-darwin system flake";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/4f65914b04bd7fb27011fde595cc446a7b6f498c"; # nixpkgs-unstable
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable"; # nixpkgs-unstable
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
      hostname = "MBCXDL4Y4V0WMT";
      user_home = "/Users/rell";
      system_repo_root = "${user_home}/Nextcloud/code/mynixos";
      settings = { inherit system_repo_root hostname user_home; };

      configuration = { pkgs, ... }:
        let
          my-kubernetes-helm = with pkgs;
            wrapHelm kubernetes-helm {
              plugins = with pkgs.kubernetes-helmPlugins; [
                helm-secrets
                helm-diff
                helm-s3
                helm-git
              ];
            };

          my-helmfile = pkgs.helmfile-wrapped.override {
            inherit (my-kubernetes-helm) pluginsDir;
          };
        in {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = with pkgs; [
            ncdu
            git
            lazygit
            nom
            htop
            btop
            nixfmt-classic
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
            k9s
            audacity
            postgresql
            ffmpeg-full
            # agenix-cli
            inputs.agenix.packages."aarch64-darwin".default
            ngrok
            eternal-terminal
            yt-dlp
            inetutils
            pear-desktop # youtube music
            my-kubernetes-helm
            my-helmfile
            ranger
            # spotdl
            nom
            beets
            nmap
          ];
          nixpkgs.overlays = [
            (self: super:
              {
                # kdenlive = super.libsForQt5.kdenlive.override {
                #   mlt = super.mlt.override {
                #     frei0r = super.frei0r.override {
                #       opencv = null;
                #     };
                #   };
                #   frei0r = super.frei0r.override {
                #     opencv = null;
                #   };
                # };
                # ruff = super.ruff.overrideAttrs (old: rec {
                #   version = "0.12.9";

                #   src = super.fetchFromGitHub {
                #     owner = "astral-sh";
                #     repo = "ruff";
                #     tag = "v0.4.10";
                #     hash = "sha256-XuHVKxzXYlm3iEhdAVCyd62uNyb3jeJRl3B0hnvUzX0=";
                #   };
                # });
              })
          ];

          nix = {
            enable = false; # becaus of use of determinate nix
            # following settings have no effect as long as enable is false
            # edit instead /etc/nix/nix.custom.conf and restart determinate nix daemon
            settings = {
              experimental-features = "nix-command flakes";
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

          services.openssh.enable = true;

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
            FLAKE =
              "${settings.system_repo_root}/machines/${settings.hostname}";
          };
          # Configure skhd for global keyboard shortcuts
          # services.skhd = {
          #   enable = false;
          #   # run skhd --reload
          #   skhdConfig = ''
          #     # Cmd + B: Open new Firefox window
          #     # cmd - b : open -n -a Firefox

          #     # Cmd + E: Open new Finder window
          #     cmd - e : open -n -a Finder

          #     # Cmd + Enter: Open new Terminal window
          #     cmd - return : open -n -a Terminal
          #   '';
          # };

          # system.defaults = {
          #   CustomUserPreferences = {
          #     "org.hammerspoon.Hammerspoon" = {
          #       MJConfigFile =
          #         "${settings.system_repo_root}/dotfiles/hammerspoon/init.lua";
          #     };
          #   };
          # };
        };
    in {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#MBCXDL4Y4V0WMT
      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
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
            homebrew.casks =
              [ "hammerspoon" "wine@staging" "macfuse" "calibre" ];
          }
          inputs.agenix.nixosModules.default
          ({ ... }: {
            age.identityPaths = [ "/Users/rell/.ssh/id_ed25519_home" ];
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
