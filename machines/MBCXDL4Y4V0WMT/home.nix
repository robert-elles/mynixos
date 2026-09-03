{
  pkgs,
  config,
  settings,
  ...
}:
let
  configFilesDir = "${settings.system_repo_root}/machines/MBCXDL4Y4V0WMT/config";
in
{

  home.stateVersion = "25.05";
  home.enableNixpkgsReleaseCheck = false;

  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      # sudo resets the soft fd limit to the macOS default (256), which is too
      # low for nix's git fetcher; raise it inside the privileged shell.
      rebuildswitch = "sudo darwin-rebuild switch --flake \"$FLAKE\" --impure'";
      mycursor = "cursor --user-data-dir=$HOME/.cursor-profile-private --extensions-dir=$HOME/.cursor-profile-private/extensions ./";
      h = "herdr --session $(basename $PWD)";
    };
    initContent = ''
      # macOS default soft fd limit (256) is too low for nix flake update's git
      # fetcher; raise it so `nix flake update` works without manual intervention.
      ulimit -n 1048576 2>/dev/null || true

      # zsh-z (directory jumping) — single-file plugin, sourced directly instead
      # of via zplug which added ~1s of startup overhead (git checks, flock, cache).
      source ${pkgs.zsh-z}/share/zsh-z/zsh-z.plugin.zsh
    '';
    oh-my-zsh = {
      enable = true;
      theme = "af-magic";
      # Skip compfix security audit (scans all fpath dirs for insecure perms).
      # oh-my-zsh runs compinit -C when this is set, dropping ~2s of startup.
      extraConfig = "ZSH_DISABLE_COMPFIX=true";
    };
  };

  programs.script-directory = {
    enable = true;
    settings = {
      SD_ROOT = "${settings.system_repo_root}/dotfiles/sd";
      # SD_EDITOR = "vim";
      # SD_CAT = "bat";
    };
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    # enableFishIntegration = true;
    settings = {
      # atuin register/login -u <USERNAME> -e <EMAIL> (-p <PASSWORD>)
      # atuin import auto
      auto_sync = true;
      sync_frequency = "5m";
      sync_address = "https://api.atuin.sh";
      search_mode = "prefix";
      # key_path = config.age.secrets.atuin_key.path;
      key_path = "/Users/rell/.config/atuin/atuin_key";
    };
  };

  # Add ~/.rd/bin to PATH
  home.sessionVariables = {
    PATH = "$HOME/.rd/bin:$PATH";
  };

  home.file.".aerospace.toml" = {
    source = "${configFilesDir}/aerospace.toml";
  };

  # Editable, bi-directional link into the git repo (not copied to /nix/store)
  home.file.".config/zed/keymap.json".source =
    config.lib.file.mkOutOfStoreSymlink "${configFilesDir}/zed/keymap.json";

  home.file."Library/Application Support/Code/User/keybindings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${configFilesDir}/vscode/keybindings.json";

  programs.git = {
    enable = true;
    ignores = [ ".direnv" ".devenv" ".DS_Store" ".claude" ];
  };

  home.file.".config/opencode/config.json".text = builtins.toJSON {
    autoupdate = false;
    permission = {
      edit = {
        "*" = "allow";
        "src/*.js" = "allow";
      };
    };
  };
}
