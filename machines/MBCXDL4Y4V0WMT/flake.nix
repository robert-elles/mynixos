{
  description = "Example nix-darwin system flake";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/a955b38b80c3e476d6f447770c457aec5a023a5f"; # nixpkgs-unstable
    # nixpkgs.url = "github:NixOS/nixpkgs/master"; # nixpkgs-unstable
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable"; # nixpkgs-unstable
    # audacity 4.0.0 fails to build on newer nixpkgs (QML "reference to 'Type' is ambiguous")
    nixpkgs_pin.url = "github:NixOS/nixpkgs/ca1659429c950a11a565b5764e37a1b704e17ec8";
    # opencode 1.18.35
    # check revisions on https://www.nixhub.io/packages/opencode
    nixpkgs_opencode.url = "github:NixOS/nixpkgs/8edc0c72e3a38faf5434e40d1f19431125fe4b30";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/master";
    # "github:nix-community/home-manager/be0c641a6a5564caa33982faa1fe2c60d92131c7";
    # home-manager.inputs.nixpkgs.follows = "nixpkgs";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # https://github.com/zhaofengli/nix-homebrew
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    # newer brew than nix-homebrew's pin; must keep up with homebrew-core formula DSL
    nix-homebrew.inputs.brew-src.follows = "brew-src";
    brew-src = {
      url = "github:Homebrew/brew/7.0.9";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-peachlife = {
      url = "github:PeachlifeAB/homebrew-tap";
      flake = false;
    };
    homebrew-felixkratz = {
      url = "github:FelixKratz/homebrew-formulae";
      flake = false;
    };
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      ...
    }:
    let
      hostname = "MBCXDL4Y4V0WMT";
      user_home = "/Users/rell";
      system_repo_root = "${user_home}/Nextcloud/code/mynixos";
      settings = { inherit system_repo_root hostname user_home; };

      configuration =
        { pkgs, ... }:
        let
          my-kubernetes-helm =
            with pkgs;
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
        in
        {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = with pkgs;
          let
          lapkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
          pinpkgs = inputs.nixpkgs_pin.legacyPackages.${pkgs.stdenv.hostPlatform.system};
          opencodepkgs = inputs.nixpkgs_opencode.legacyPackages.${pkgs.stdenv.hostPlatform.system};
          in
          [
            lapkgs.omp
            herdr
            ncdu
            nvd
            nix-weather
            nix-forecast
            git
            pstree
            lazygit
            nix-output-monitor
            htop
            btop
            nixfmt
            git-crypt
            # repomix
            # claude-code
            # aider-chat
            # aider-chat-with-playwright
            # aider-chat-with-browser
            devenv
            # skhd # Simple Hotkey Daemon for global keyboard shortcuts
            # alt-tab-macos
            nodejs
            glab
            docker
            docker-compose
            docker-credential-helpers
            # script-directory
            bindfs
            openvpn
            # mr # myrepos
            # gita # alternative to myrepos
            mu-repo # alternative to myrepos
            uv
            # ruff
            tilt
            kubectl
            k9s
            pinpkgs.audacity
            # postgresql
            # ffmpeg-full
            # agenix-cli
            inputs.agenix.packages."aarch64-darwin".default
            # ngrok
            eternal-terminal
            yt-dlp
            inetutils
            # pear-desktop # youtube music
            # my-kubernetes-helm
            # my-helmfile
            # ranger
            # spotdl
            # beets
            nmap
            # aerospace

            # Ai harness and its toolsk
            opencodepkgs.opencode
            claude-code
            # Ai Tools
            (python3.withPackages (ps: [ ps.pdftotext ]))
            # pandoc # umwandeln von dokumenten

            # vscode
            killport
            sonar # find processes listening on ports
            nil # language server for nix in zed
            nixd # language server for nix in zed
            nix-sweep
            mosh
            azure-cli
            kubeseal
            hurl
            aria2 # downloader
            nvd # diff package versions between two store paths / generations
            # ice-bar # mac menu bar manager
            yazi # ranger alternative
          ];
          nixpkgs.overlays = [
            (self: super: {
              # Go 1.26 made -linkmode=external a hard error when CGO_ENABLED=0
              direnv = super.direnv.overrideAttrs (old: {
                env = (old.env or { }) // {
                  CGO_ENABLED = "1";
                };
              });
              # fabric pins invoke<3, nixpkgs has invoke 3; needed by azure-cli
              pythonPackagesExtensions = super.pythonPackagesExtensions ++ [
                (pyself: pysuper: {
                  fabric = pysuper.fabric.overridePythonAttrs (old: {
                    pythonRelaxDeps = (old.pythonRelaxDeps or [ ]) ++ [ "invoke" ];
                    doCheck = false;
                    meta = old.meta // { broken = false; };
                  });
                })
              ];
              # sonar = super.callPackage ../../nixconfig/packages/sonar { };
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
            enable = false; # because of use of determinate nix: config lives in /etc/nix/nix.custom.conf
            # following settings have no effect as long as enable is false
            # edit instead /etc/nix/nix.custom.conf and restart determinate nix daemon
            # settings = {
            #   experimental-features = "nix-command flakes";
            #   trusted-users = [
            #     "root"
            #     "rell"
            #   ];
            #   substituters = [
            #     "https://nix-community.cachix.org"
            #     "https://cache.numtide.com"
            #   ];
            #   trusted-public-keys = [
            #     "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
            #     "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
            #   ];
            # };
          };

          # Disable nix-darwin's global compinit — oh-my-zsh (via home-manager)
          # runs its own compinit with ZSH_DISABLE_COMPFIX=true (compinit -C),
          # so the system-level one is redundant and adds ~2s of startup.
          programs.zsh.enableGlobalCompInit = false;

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
            FLAKE = "${settings.system_repo_root}/machines/${settings.hostname}";
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

          # Prevent macOS from switching Spaces when a new window of an
          # already-open app is created elsewhere. Without this, AeroSpace
          # can't place new windows on the currently focused workspace,
          # since macOS jumps to the app's other Space before the window
          # even appears.
          system.defaults.NSGlobalDomain.AppleSpacesSwitchOnActivate = false;

          # Never auto-merge new Terminal windows into tab groups; the tabs
          # share one frame, so the tiling WM can only show one of them.
          # system.defaults.CustomUserPreferences."com.apple.Terminal".AppleWindowTabbingMode = "manual";
        };
    in
    {
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
                "PeachlifeAB/homebrew-tap" = inputs.homebrew-peachlife;
                "FelixKratz/homebrew-formulae" = inputs.homebrew-felixkratz;
              };

              # Optional: Enable fully-declarative tap management
              #
              # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
              mutableTaps = false;
            };
            homebrew = {
              enable = true;
              onActivation = {
                autoUpdate = true;
                cleanup = "zap";
                upgrade = true;
                extraFlags = [ "--verbose" ];
              };
            };
            homebrew.casks = [
              "hammerspoon"
              "wine@staging"
              "macfuse"
              "calibre"
              "PeachlifeAB/tap/hyprspace"
              "font-hack-nerd-font" # hyprspace init dependency
              "android-platform-tools"
              "gstreamer-runtime"
              # "karabiner-elements"
              # "microsoft-remote-desktop"
              "raycast"
              # "whichspace"
            ];
            homebrew.brews = [
              "ffmpeg"
              "freerdp"
              "git-filter-repo"
              "helmfile"
              "kubeseal"
              "node"
              "nvm"
              "pyenv"
              "python@3.13"
              "sdl2-compat" # dep of ffmpeg/freerdp; bundle cleanup wrongly flags it
              "swiftly"
              "tilt"
              "uv"
              "wireguard-tools"
              # hyprspace init dependencies (run init with HYPRSPACE_SKIP_DEPENDENCY_SETUP=1)
              "FelixKratz/formulae/sketchybar"
              "FelixKratz/formulae/borders"
            ];
          }
          (
            { config, ... }:
            {
              # declare all nix-homebrew taps so cleanup="zap" doesn't try to untap them
              homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
            }
          )
          inputs.agenix.nixosModules.default
          (
            { ... }:
            {
              age.identityPaths = [ "/Users/rell/.ssh/id_ed25519_home" ];
              age.secrets = {
                atuin_key = {
                  file = ../../secrets/agenix/atuin_key.age;
                  owner = "rell";
                };
              };
            }
          )
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
