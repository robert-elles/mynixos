{ inputs, settings, lib, ... }:
{
  environment.systemPackages = [
    inputs.plasma-manager.packages.${settings.system}.rc2nix
  ];

  home-manager = {
    users.robert = {

      programs.plasma = {
        # See options in https://github.com/nix-community/plasma-manager/tree/trunk/modules
        enable = true;
        overrideConfig = false;
        workspace = {
          wallpaper = "/home/robert/Documents/wallpaper/ilnur-kalimullin-9r4kV5VrdSQ-unsplash.jpg";
          lookAndFeel = "org.kde.breezedark.desktop";
        };
        krunner = {
          activateWhenTypingOnDesktop = true;
          historyBehavior = "enableSuggestions";
          position = "center";
        };
        kwin = {
          virtualDesktops =
            let
              number = 10;
            in
            {
              names = map (n: "Desktop ${toString n}") (lib.range 1 number);
              inherit number;
              rows = 3;
            };
          nightLight = {
            enable = false;
            mode = "times";
            temperature = {
              day = 5000;
              night = 3000;
            };
            time = {
              evening = "18:30";
              morning = "06:30";
            };
            transitionTime = 90;
          };
        };
        window-rules = [
          {
            description = "No window borders";
            match.window-types = [ "normal" ];
            apply.noborder = {
              value = true;
              apply = "force"; # initially
            };
          }
          {
            description = "Joplin";
            match.window-class = "joplin Joplin";
            apply.desktops = "Desktop_8";
            apply.maximizehoriz = true;
            apply.activities = "All";
          }
          {
            description = "Spotify";
            match.window-class = "spotify Spotify";
            apply.desktops = "Desktop_5";
            apply.maximizehoriz = true;
            apply.activities = "All";
          }
          {
            description = "Super Productivity";
            match.window-class = "superproductivity superProductivity";
            apply.desktops = "Desktop_8";
            apply.maximizehoriz = true;
            apply.activities = "All";
          }
          {
            description = "Ferdium";
            match.window-class = "ferdium Ferdium";
            apply.desktops = "Desktop_10";
            apply.activities = "All";
          }
          {
            description = "Visual Studio Code";
            match.window-class = "code code-url-handler";
            apply = {
              # desktops = "Desktop_2";
              maximizehoriz = true;
              maximizevert = true;
              # noborder = true;
            };
          }
          # {
          #   description = "Visual Studio Code";
          #   match.window-class = "keepassxc org.keepassxc.KeePassXC";
          # }
        ];
        shortcuts = {
          "services/firefox.desktop"."_launch" = "Meta+B";
          "services/chromium-browser.desktop"."_launch" = "Meta+Shift+B";
          "services/kitty.desktop"."_launch" = "Meta+Return";
          "services/systemsettings.desktop"."_launch" = "Meta+Shift+s";
          "services/playerctl-2.desktop"."_launch" = "Ctrl+Shift+Left";
          "services/playerctl-4.desktop"."_launch" = "Ctrl+Shift+Space";
          "services/playerctl.desktop"."_launch" = "Ctrl+Shift+Right";
          "services/org.kde.spectacle.desktop"."RectangularRegionScreenShot" = [ "Meta+Shift+P" "Meta+Shift+Print" ];
          "kwin"."Window Close" = [ "Meta+Shift+Q" "Alt+F4,Alt+F4,Close Window" ];
          "kwin"."Window Maximize" = "Meta+F";
          "kwin"."Window Fullscreen" = "Meta+Shift+F";
          "ksmserver"."Lock Session" = "Meta+X";
          "ksmserver"."Log Out Without Confirmation" = "Meta+Shift+X";
          "plasma-manager-commands.desktop"."kitty" = "Meta+Enter";
          "plasmashell"."activate application launcher" = "Meta";
          "services/org.kde.krunner.desktop"."_launch" = [ "Alt+Space" ];
          "plasmashell"."next activity" = "Meta+z";
          "plasmashell"."previous activity" = [ "Meta+Shift+z" "Meta+Shift+Z" "Meta+Z" ];
          "plasmashell"."switch to next activity" = "Meta+a";
          "plasmashell"."switch to previous activity" = [ "Meta+Shift+a" "Meta+Shift+A" "Meta+A" ];
          "kwin"."Overview" = [ "Meta+W" ];
          "kwin"."Grid View" = [ "Meta+G" "Meta+Shift+W" ];
          "services/org.pulseaudio.pavucontrol.desktop"."_launch" = "Meta+H";
          "kwin"."Window Operations Menu" = "Alt+`";

          "kwin"."Switch to Desktop 1" = "Meta+1";
          "kwin"."Switch to Desktop 2" = "Meta+2";
          "kwin"."Switch to Desktop 3" = "Meta+3";
          "kwin"."Switch to Desktop 4" = "Meta+4";
          "kwin"."Switch to Desktop 5" = "Meta+5";
          "kwin"."Switch to Desktop 6" = "Meta+6";
          "kwin"."Switch to Desktop 7" = "Meta+7";
          "kwin"."Switch to Desktop 8" = "Meta+8";
          "kwin"."Switch to Desktop 9" = "Meta+9";
          "kwin"."Switch to Desktop 10" = "Meta+0";

          "kwin"."Window to Desktop 1" = "Meta+!";
          "kwin"."Window to Desktop 2" = "Meta+@";
          "kwin"."Window to Desktop 3" = "Meta+#";
          "kwin"."Window to Desktop 4" = "Meta+$";
          "kwin"."Window to Desktop 5" = "Meta+%";
          "kwin"."Window to Desktop 6" = "Meta+^";
          "kwin"."Window to Desktop 7" = "Meta+&";
          "kwin"."Window to Desktop 8" = "Meta+*";
          "kwin"."Window to Desktop 9" = "Meta+(";
          "kwin"."Window to Desktop 10" = "Meta+)";

          "plasmashell"."activate task manager entry 1" = "Alt+1";
          "plasmashell"."activate task manager entry 2" = "Alt+2";
          "plasmashell"."activate task manager entry 3" = "Alt+3";
          "plasmashell"."activate task manager entry 4" = "Alt+4";
          "plasmashell"."activate task manager entry 5" = "Alt+5";
          "plasmashell"."activate task manager entry 6" = "Alt+6";
          "plasmashell"."activate task manager entry 7" = "Alt+7";
          "plasmashell"."activate task manager entry 8" = "Alt+8";
          "plasmashell"."activate task manager entry 9" = "Alt+9";
          "plasmashell"."activate task manager entry 10" = "Alt+0";
        };
        configFile = {
          "kactivitymanagerdrc"."activities"."4a162aea-a0f9-4acb-a72d-2c48d7816b0b" = "Main";
          "kcminputrc"."Libinput/2/10/TPPS\\/2 Elan TrackPoint"."PointerAcceleration" = 0.000;
          "kcminputrc"."Libinput/2/7/SynPS\\/2 Synaptics TouchPad"."PointerAcceleration" = 0.800;
          "kcminputrc"."Libinput/2/7/SynPS\\/2 Synaptics TouchPad"."ScrollFactor" = 2;
          "kwinrc"."Plugins"."fadedesktopEnabled" = true;
          "kwinrc"."Plugins"."slideEnabled" = false;
          "kwinrc"."Effect-translucency"."IndividualMenuConfig" = true;
          "kwinrc"."MouseBindings"."CommandAllWheel" = "Change Opacity";
          "kwinrc"."Plugins"."translucencyEnabled" = true;
          "plasma-localerc"."Formats"."LC_TIME" = "en_DE.UTF-8";
          "kwinrc"."Windows"."ActivationDesktopPolicy" = "BringToCurrentDesktop";
          # "kxkbrc"."Layout"."LayoutList" = "us";
          # "kxkbrc"."Layout"."Use" = true;
          # "kxkbrc"."Layout"."VariantList" = "altgr-intl";
          "plasmanotifyrc"."Applications/org.kde.spectacle"."ShowBadges" = false;
          "plasmanotifyrc"."Applications/org.kde.spectacle"."ShowInHistory" = false;
          "plasmanotifyrc"."Applications/org.kde.spectacle"."ShowPopups" = false;

        };
        input.keyboard.layouts = [
          {
            # displayName = "US AltGr";
            layout = "us";
            variant = "altgr-intl";
          }
        ];

        panels = [
          # Windows-like panel at the bottom
          {
            location = "top";
            height = 36;
            floating = false;
            widgets = [
              "org.kde.plasma.kickoff"
              "com.github.tilorenz.compact_pager"
              "org.kde.plasma.activitybar"
              # "org.kde.plasma.activitypager"
              # "org.kde.plasma.marginsseparator"
              # "org.kde.plasma.pager"
              # {
              #   pager = {
              #     size = {
              #       width = 500;
              #       height = 42;
              #     };
              #     general = {
              #       showWindowOutlines = true;
              #       displayedText = "desktopNumber";
              #     };
              #   };
              # }
              # "org.kde.plasma.taskmanager"
              {
                iconTasks = {
                  iconsOnly = false;
                  appearance = {
                    fill = true;
                    rows = {
                      multirowView = "lowSpace"; # never
                    };
                  };
                  launchers = [ ];
                  behavior = {
                    grouping = {
                      method = "none"; # byProgramName
                      # clickAction = "cycle";
                    };
                    #   sortingMethod = "none";
                  };
                };

              }
              "org.kde.plasma.marginsseparator"
              # "org.kde.plasma.panelspacer"
              # "org.kde.plasma.systemtray"
              {
                systemTray.items = {
                  # We explicitly show bluetooth and battery
                  shown = [
                    # "org.kde.plasma.battery"
                    "org.kde.plasma.bluetooth"
                    "org.kde.plasma.networkmanagement"
                  ];
                  # And explicitly hide networkmanagement and volume
                  hidden = [
                    "org.kde.plasma.volume"
                    "org.kde.plasma.clipboard"
                    "org.kde.plasma.brightness"
                    "chrome_status_icon_1" # super prod and ferdium apparently
                  ];
                };
              }
              "org.kde.plasma.digitalclock"
            ];
          }
        ];
      };
    };
  };
}
