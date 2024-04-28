{ systemSettings, impermanence, ... }: {

  # not needed when mynixos folder not in system dir ?
  programs.fuse.userAllowOther = true;
  home-manager = {
    users.robert = {
      imports = [ "${impermanence}/home-manager.nix" ];
      home.persistence."${systemSettings.system_repo_root}/dotfiles" = {
        removePrefixDirectory = false;
        allowOther = true;
        directories = [
          "sd"
          ".config/kitty"
          ".config/gtk-3.0"
          ".config/gtk-4.0"
          ".config/xsettingsd"
          ".config/easyeffects"
          ".config/autostart"
          ".kde"
        ];
        files = [
          ".config/akregatorrc"
          ".config/baloofileinformationrc"
          ".config/baloofilerc"
          ".config/device_automounter_kcmrc"
          ".config/dolphinrc"
          ".config/filetypesrc"
          ".config/gtkrc"
          ".config/gtkrc-2.0"
          ".config/kactivitymanagerd-pluginsrc"
          ".config/kactivitymanagerd-statsrc"
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
          ".config/user-dirs.locale"
          ".config/Code/User/settings.json"
          ".config/Code/User/keybindings.json"
          ".local/share/user-places.xbel"
          ".local/share/user-places.xbel.tbcache"
          ".local/share/applications/playerctl.desktop"
          ".local/share/applications/playerctl-2.desktop"
          ".local/share/applications/playerctl-4.desktop"
        ];
      };
    };
  };
}
