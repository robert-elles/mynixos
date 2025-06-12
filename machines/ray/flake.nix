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
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, ... }:
    let
      hostname = "ray";
      system_repo_root = "/Users/rell/Nextcloud/code/mynixos";
      settings = { inherit system_repo_root hostname; };

      configuration = { pkgs, ... }: {
        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget
        environment.systemPackages = with pkgs; [
          ncdu
          nixfmt
          git-crypt
          repomix
          claude-code
          aider-chat
          aider-chat-with-playwright
          aider-chat-with-browser
          devenv
          direnv
          skhd # Simple Hotkey Daemon for global keyboard shortcuts
        ];
        nix.enable = false;
        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes";

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
          home = "/Users/rell";
        };

        environment.variables = rec {
          FLAKE = "${settings.system_repo_root}/machines/${settings.hostname}";
        };
        # Configure skhd for global keyboard shortcuts
        services.skhd = {
          enable = true;
          skhdConfig = ''
            # Cmd + B: Open new Firefox window
            cmd - b : open -n -a Firefox
          '';
        };
      };
    in {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#MBCXDL4Y4V0WMT
      darwinConfigurations."ray" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
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
            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
        ];
      };
    };
}
