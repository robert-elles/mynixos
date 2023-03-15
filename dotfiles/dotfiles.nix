system_repo_root:
{ config, pkgs, lib, home-manager, impermanence, ... }: {

  # system.activationScripts.deleteintheway = ''
  #   rm /home/robert/.config/mimeapps.list
  # '';

  # not needed when mynixos folder not in system dir ?
  programs.fuse.userAllowOther = true;
  home-manager = {
    users.robert = {
      imports = [ "${impermanence}/home-manager.nix" ];
      home.activation.delete_in_the_way = ''
        #!/usr/bin/env bash
        if [ -f /home/robert/.config/mimeapps.list ]; then
          rm /home/robert/.config/mimeapps.list
        fi
      '';
      home.persistence."${system_repo_root}/dotfiles" = {
        removePrefixDirectory = false;
        allowOther = true;
        directories = [
          "sd"
          ".config/kitty"
          ".config/gtk-3.0"
          ".config/gtk-4.0"
          ".config/xsettingsd"
          ".kde"
        ];
        files = [
          ".config/akregatorrc"
          ".config/baloofileinformationrc"
          ".config/baloofilerc"
          ".config/bluedevilglobalrc"
          ".config/device_automounter_kcmrc"
          ".config/dolphinrc"
          ".config/filetypesrc"
          ".config/gtkrc"
          ".config/gtkrc-2.0"
          # ".config/gwenviewrc"
          ".config/kactivitymanagerd-pluginsrc"
          ".config/kactivitymanagerd-statsrc"
          ".config/kactivitymanagerd-switcher"
          ".config/kactivitymanagerdrc"
          ".config/katemetainfos"
          ".config/katerc"
          ".config/kateschemarc"
          ".config/katevirc"
          ".config/kcmfonts"
          ".config/kcminputrc"
          ".config/kconf_updaterc"
          ".config/kded5rc"
          ".config/kdeglobals"
          ".config/kgammarc"
          ".config/kglobalshortcutsrc"
          ".config/khotkeysrc"
          ".config/kmixrc"
          ".config/konsolerc"
          ".config/kscreenlockerrc"
          ".config/ksmserverrc"
          ".config/ksplashrc"
          ".config/ktimezonedrc"
          ".config/kwinrc"
          ".config/kwinrulesrc"
          ".config/kxkbrc"
          # ".config/mimeapps.list" conflicts always with home-manager
          ".config/partitionmanagerrc"
          ".config/plasma-localerc"
          ".config/plasma-nm"
          ".config/plasma-org.kde.plasma.desktop-appletsrc"
          ".config/plasmanotifyrc"
          ".config/plasmarc"
          ".config/plasma-localerc"
          ".config/plasmashellrc"
          ".config/PlasmaUserFeedback"
          ".config/plasmawindowed-appletsrc"
          ".config/plasmawindowedrc"
          ".config/powermanagementprofilesrc"
          ".config/spectaclerc"
          ".config/startkderc"
          ".config/systemsettingsrc"
          #          ".config/Trolltech.conf"
          ".config/user-dirs.dirs"
          ".config/user-dirs.locale"
          ".local/share/krunnerstaterc"
          ".local/share/user-places.xbel"
          #          ".local/share/user-places.xbel.bak"
          ".local/share/user-places.xbel.tbcache"
          # vscode:
          ".config/Code/User/settings.json"
          ".config/Code/User/keybindings.json"
        ];
      };
    };
  };
}
