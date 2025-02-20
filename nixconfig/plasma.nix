{ inputs, settings, lib, ... }:
{
  environment.systemPackages = [
    inputs.plasma-manager.packages.${settings.system}.rc2nix
  ];

  home-manager = {
    users.robert = {

      # imports = [
      #   ./plasma_rc2nix.nix
      # ];

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
        # hotkeys.commands = {
        #   "kitty" = {
        #     name = "Launch Kitty";
        #     key = "Meta+Enter";
        #     command = "kitty.desktop";
        #   };
        # };
        kwin = {
          #   virtualDesktops =
          #     let
          #       number = 10;
          #     in
          #     {
          #       names = map (n: "Desktop ${toString n}") (lib.range 1 number);
          #       inherit number;
          #       rows = 1;
          #     };
          nightLight = {
            enable = true;
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
          "plasmashell"."activate application launcher" = "none";
          "services/org.kde.krunner.desktop"."_launch" = [ "Alt+Space" "Meta" ];
          "plasmashell"."next activity" = "Meta+z";
          "plasmashell"."previous activity" = [ "Meta+Shift+z" "Meta+Shift+Z" "Meta+Z" ];
          "plasmashell"."switch to next activity" = "Meta+a";
          "plasmashell"."switch to previous activity" = [ "Meta+Shift+a" "Meta+Shift+A" "Meta+A" ];
          "kwin"."Overview" = [ "Meta+w" "Meta+W" ];
          "kwin"."Grid View" = "Meta+h";
          "services/org.pulseaudio.pavucontrol.desktop"."_launch" = "Meta+G";
          "kwin"."Window Operations Menu" = "Alt+Q";

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
        };
        configFile = {
          "kactivitymanagerdrc"."activities"."4a162aea-a0f9-4acb-a72d-2c48d7816b0b" = "Main";
          "kwinrc"."Desktops"."Id_10" = "cae9dbca-9e38-4abe-9ed5-7cdea84c8e1f";
          "kwinrc"."Desktops"."Id_2" = "53d93476-07e9-4303-afe6-70938407f287";
          "kwinrc"."Desktops"."Id_3" = "f8152b2a-8fb8-462b-9788-65f187c3873b";
          "kwinrc"."Desktops"."Id_4" = "eef5c7ee-9b91-49e8-be4a-4459a9619599";
          "kwinrc"."Desktops"."Id_5" = "9ff4b9b8-5935-40e8-83fa-cc3142e70e60";
          "kwinrc"."Desktops"."Id_6" = "74d5af11-2fd0-4e5c-a4ed-9cf8c985b6d6";
          "kwinrc"."Desktops"."Id_7" = "2d17e3c3-4a76-48aa-b3a4-89cf0fa7bf49";
          "kwinrc"."Desktops"."Id_8" = "b76cf321-a983-4890-9bc6-965f2bc129b5";
          "kwinrc"."Desktops"."Id_9" = "064396a0-87a3-4e94-b1bd-2f827919b9a0";
          "kwinrc"."Desktops"."Number" = 10;
          "kwinrc"."Desktops"."Rows" = 1;
          "kcminputrc"."Libinput/2/10/TPPS\\/2 Elan TrackPoint"."PointerAcceleration" = 0.000;
          "kcminputrc"."Libinput/2/7/SynPS\\/2 Synaptics TouchPad"."PointerAcceleration" = 0.800;
          "kcminputrc"."Libinput/2/7/SynPS\\/2 Synaptics TouchPad"."ScrollFactor" = 2;
          "kwinrc"."Plugins"."fadedesktopEnabled" = true;
          "kwinrc"."Plugins"."slideEnabled" = false;
          "kwinrc"."Effect-translucency"."IndividualMenuConfig" = true;
          "kwinrc"."MouseBindings"."CommandAllWheel" = "Change Opacity";
          "kwinrc"."Plugins"."translucencyEnabled" = true;
          "plasma-localerc"."Formats"."LC_TIME" = "en_DE.UTF-8";
          # "kxkbrc"."Layout"."LayoutList" = "us";
          # "kxkbrc"."Layout"."Use" = true;
          # "kxkbrc"."Layout"."VariantList" = "altgr-intl";
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
              "org.kde.plasma.taskmanager"
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
