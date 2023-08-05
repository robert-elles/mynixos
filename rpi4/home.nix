{ config, pkgs, lib, home-manager, ... }: {

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.robert = {

    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;
    programs.direnv.enableZshIntegration = true;

    home.stateVersion = "22.05";
    # Here goes your home-manager config, eg home.packages = [ pkgs.foo ];
    programs.tmux.enable = true;
    programs.zsh = {
      enable = true;
      plugins = [
        {
          name = "sd";
          src = pkgs.fetchFromGitHub {
            owner = "ianthehenry";
            repo = "sd";
            rev = "v1.1.0";
            sha256 = "sha256-X5RWCJQUqDnG2umcCk5KS6HQinTJVapBHp6szEmbc4U=";
          };
        }
      ];
      zplug = {
        enable = true;
        plugins = [
          { name = "zsh-users/zsh-autosuggestions"; }
          { name = "agkozak/zsh-z"; }
          { name = "agkozak/agkozak-zsh-prompt"; }
        ];
      };
      shellAliases = {
        ll = "ls -l";
      };
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "sudo" "systemd" "tmux" ];
      };
      # initExtra = "";
      localVariables = {
        "ZSH_TMUX_AUTOSTART" = "true";
        "ZSH_TMUX_AUTOQUIT" = "true";
        "ZSH_TMUX_AUTOCONNECT" = "true";
      };
    };
  };
}
