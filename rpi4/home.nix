# { config, pkgs, lib, home_manager, ... }: {
{ config, pkgs, lib, ... }: {

  #  imports = [ home_manager.nixosModule ];
  #  home-manager.username = "robert";
  #  home.homeDirectory = "/home/robert";
  #  programs.home-manager.enable = true;
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.robert = {
    home.stateVersion = "22.05";
    # Here goes your home-manager config, eg home.packages = [ pkgs.foo ];
    programs.zsh = {
      enable = true;
      zplug = {
        enable = true;
        plugins = [
          #          { name = "zsh-users/zsh-autosuggestions"; }
          { name = "agkozak/zsh-z"; }
          { name = "agkozak/agkozak-zsh-prompt"; }
        ];
      };
      shellAliases = {
        ll = "ls -l";
        switch = "sudo nixos-rebuild switch";
      };
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "kubectl" "sudo" ];
      };
    };
  };
}