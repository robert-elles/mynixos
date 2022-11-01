{ config, pkgs, lib, home-manager, impermanence, ... }: {
  imports = [ home-manager.nixosModule ];

  programs.fuse.userAllowOther = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.robert = {

      imports = [ "${impermanence}/home-manager.nix" ];

      home.stateVersion = "22.05";
      programs.zsh = {
        enable = true;
        zplug = {
          enable = true;
          plugins = [
            { name = "zsh-users/zsh-autosuggestions"; }
            { name = "agkozak/zsh-z"; }
          ];
        };
        shellAliases = {
          ll = "ls -l";
          getsha256 =
            "nix-prefetch-url --type sha256 --unpack $1"; # $1 link to tar.gz release archive in github
          termcopy =
            "kitty +kitten ssh $1"; # copy terminal info to remote server $1 = remote server
          switch =
            "sudo nixos-rebuild -v switch --flake /etc/nixos/mynixos |& nom";
          buildboot =
            "sudo nixos-rebuild -v boot --flake /etc/nixos/mynixos |& nom";
          update = "sudo /etc/nixos/mynixos/scripts/update";
          captiveportal =
            "xdg-open http://$(ip --oneline route get 1.1.1.1 | awk '{print $3}')";
          pwrestart = "systemctl --user restart pipewire-pulse.service";
        };
        oh-my-zsh = {
          enable = true;
          plugins = [ "git" "kubectl" "sudo" "systemd" "history" ];
          theme = "af-magic";
        };
        initExtra = ''
          source ~/gitlab/kuelap-connect/dev/kuelap.sh
          alias dngconvert="WINEPREFIX='$HOME/wine-dng' wine /home/robert/wine-dng/drive_c/Program\ Files/Adobe/Adobe\ DNG\ Converter/Adobe\ DNG\ Converter.exe ./"
          export LANGUAGE=en_US.UTF-8
          export LC_ALL=en_US.UTF-8
          export LANG=en_US.UTF-8
          export LC_CTYPE=en_US.UTF-8
        '';
      };

      #  home.file.".config/i3/config".source = ../config/i3/config;
      #  home.file.".config/i3status/config".source = ../config/i3status/config;
      home.file.".config/kitty/kitty.conf".source = ../config/kitty.conf;
      home.file.".config/gtk-3.0/settings.ini".source =
        ../config/gtk-3.0/settings.ini;
      #  home.file.".config/rofi".source = ../config/rofi;
      #  home.file.".config/dunst".source = ../config/dunst;
      #  home.file.".config/systemd/user/default.target.wants/redshift.service".source =
      #    ../config/redshift.service;
      #    home.file.".xprofile".text = if (builtins.pathExists kuelapconf) then
      #      "${(builtins.readFile kuelapconf)}"
      #    else
      #      "";
      home.file.".config/plasma-workspace/env/local.sh".text = ''
        export LANGUAGE=en_US.UTF-8
        export LC_ALL=en_US.UTF-8
        export LANG=en_US.UTF-8
        export LC_CTYPE=en_US.UTF-
      '';

      home.sessionVariables = {
        #LS_COLORS="$LS_COLORS:'di=1;33:'"; # export LS_COLORS
      };

      programs = {
        git = { enable = true; };
        vscode.enable = true;
        vscode.userSettings = {
          #          "[nix]": {
          #                "editor.defaultFormatter": "brettm12345.nixfmt-vscode"
          #            },
          workbench.colorTheme = "Default Light+";
          #            "explorer.confirmDragAndDrop": false,
          #            "explorer.confirmDelete": false,
          #            "git.confirmSync": false,
          window.openFoldersInNewWindow = "on";
          window.restoreWindows = "none";
          files.autoSave = "afterDelay";
        };
      };

      home.persistence."/etc/nixos/mynixos/dotfiles/plasma5" = {
        removePrefixDirectory = false;
        allowOther = true;
        directories = [
          ".config/gtk-3.0"
          ".config/gtk-4.0"
          ".config/plasma-workspace"
          ".config/xsettingsd"
          ".kde"
        ];
        files = [
          #          ".config/akregatorrc"
          #          ".config/baloofileinformationrc"
          #          ".config/baloofilerc"
          #          ".config/bluedevilglobalrc"
          #          ".config/device_automounter_kcmrc"
          #          ".config/dolphinrc"
          #          ".config/filetypesrc"
          ".config/gtkrc"
          ".config/gtkrc-2.0"
          #          ".config/gwenviewrc"
          #          ".config/kactivitymanagerd-pluginsrc"
          #          ".config/kactivitymanagerd-statsrc"
          #          ".config/kactivitymanagerd-switcher"
          #          ".config/kactivitymanagerdrc"
          #          ".config/katemetainfos"
          #          ".config/katerc"
          #          ".config/kateschemarc"
          #          ".config/katevirc"
          #          ".config/kcmfonts"
          #          ".config/kcminputrc"
          #          ".config/kconf_updaterc"
          #          ".config/kded5rc"
          ".config/kdeglobals"
          #          ".config/kgammarc"
          ".config/kglobalshortcutsrc"
          ".config/khotkeysrc"
          #          ".config/kmixrc"
          #          ".config/konsolerc"
          #          ".config/kscreenlockerrc"
          #          ".config/ksmserverrc"
          #          ".config/ksplashrc"
          #          ".config/ktimezonedrc"
          ".config/kwinrc"
          ".config/kwinrulesrc"
          #          ".config/kxkbrc"
          ".config/mimeapps.list"
          #          ".config/partitionmanagerrc"
          #          ".config/plasma-localerc"
          #          ".config/plasma-nm"
          ".config/plasma-org.kde.plasma.desktop-appletsrc"
          #          ".config/plasmanotifyrc"
          #          ".config/plasmarc"
          ".config/plasma-localerc"
          ".config/plasmashellrc"
          #          ".config/PlasmaUserFeedback"
          #          ".config/plasmawindowed-appletsrc"
          #          ".config/plasmawindowedrc"
          #          ".config/powermanagementprofilesrc"
          #          ".config/spectaclerc"
          #          ".config/startkderc"
          ".config/systemsettingsrc"
          ".config/Trolltech.conf"
          #          ".config/user-dirs.dirs"
          #          ".config/user-dirs.locale"
          #
          #          ".local/share/krunnerstaterc"
          #          ".local/share/user-places.xbel"
          #          ".local/share/user-places.xbel.bak"
          #          ".local/share/user-places.xbel.tbcache"
        ];
      };
    };
  };
}
