{ config, pkgs, lib, home-manager, ... }: {

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.robert = {
    home.stateVersion = "22.05";
    # Here goes your home-manager config, eg home.packages = [ pkgs.foo ];
    programs.tmux.enable = true;
    programs.zsh = {
      enable = true;
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
