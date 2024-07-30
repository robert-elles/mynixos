{ inputs, settings, ... }: {

  # not needed when mynixos folder not in system dir ?
  programs.fuse.userAllowOther = true;
  home-manager = {
    users.robert = {
      imports = [ "${inputs.impermanence}/home-manager.nix" ];
      home.persistence."${settings.synced_config}" = {
        removePrefixDirectory = true;
        allowOther = true;
        directories = [
          "autostart"
        ];
      };
      home.persistence."${settings.system_repo_root}/dotfiles" = {
        removePrefixDirectory = false;
        allowOther = true;
        directories = [
          "sd"
          ".config/kitty"
          ".config/easyeffects"
          # ".config/autostart"
          # ".config/gtk-3.0"
          # ".config/gtk-4.0"
          # ".config/xsettingsd"
          # ".kde"
        ];
        files = [
          ".config/Code/User/settings.json"
          ".config/Code/User/keybindings.json"
          ".local/share/applications/playerctl.desktop"
          ".local/share/applications/playerctl-2.desktop"
          ".local/share/applications/playerctl-4.desktop"
          ".config/akregatorrc"
          # ".config/baloofileinformationrc"
          ".config/device_automounter_kcmrc"
          ".config/filetypesrc"
          ".config/kactivitymanagerd-pluginsrc"
          ".config/kactivitymanagerd-statsrc"
          ".config/katemetainfos"
          ".config/kateschemarc"
          ".config/katevirc"
          ".config/kcmfonts"
          ".config/konsolerc"
          ".config/ktimezonedrc"
          ".config/ksplashrc"
          ".config/partitionmanagerrc"
          ".config/plasma-localerc"
          ".config/plasma-nm"
          ".config/plasmanotifyrc"
          ".config/PlasmaUserFeedback"
          ".config/plasmawindowed-appletsrc"
          ".config/plasmawindowedrc"
          ".config/powermanagementprofilesrc"
          ".config/startkderc"
          ".config/user-dirs.locale"

          # commented files because they constantly change with each boot
          # and are therefore not suitable for version control
          # ".config/gtkrc"
          # ".config/gtkrc-2.0"
          # ".config/katerc"
          # ".config/kconf_updaterc"
          # ".config/plasma-org.kde.plasma.desktop-appletsrc"
          # ".config/spectaclerc"
          # ".config/plasmashellrc"
          # ".local/share/user-places.xbel"
          # ".local/share/user-places.xbel.tbcache"

          # commented files are managed by plasma-manager
          # ".config/kactivitymanagerdrc" # new
          # ".config/kwalletrc" # new
          # ".config/kiorc" # new
          # ".config/baloofilerc"
          # ".config/dolphinrc"
          # ".config/kcminputrc"
          # ".config/kded5rc"
          # ".config/kdeglobals"
          # ".config/kgammarc"
          # ".config/kglobalshortcutsrc"
          # ".config/khotkeysrc"
          # ".config/kmixrc"
          # ".config/kscreenlockerrc"
          # ".config/ksmserverrc"
          # ".config/kwinrc"
          # ".config/kwinrulesrc"
          # ".config/kxkbrc"
          # ".config/plasmarc"
          # ".config/plasma-localerc"
          # ".config/systemsettingsrc"
        ];
      };
    };
  };
}
