{ inputs, settings, ... }:
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
        overrideConfig = true;
        workspace = {
          wallpaper = "/home/robert/Documents/wallpaper/ilnur-kalimullin-9r4kV5VrdSQ-unsplash.jpg";
          lookAndFeel = "org.kde.breezedark.desktop";
        };
        hotkeys.commands = {
          "kitty" = {
            name = "Launch Kitty";
            key = "Meta+Enter";
            command = "kitty.desktop";
          };
        };
        shortcuts = {
          "services/firefox.desktop"."_launch" = "Meta+B";
          "services/chromium-browser.desktop"."_launch" = "Meta+Shift+B";
          "services/kitty.desktop"."_launch" = "Meta+Return";
          "services/systemsettings.desktop"."_launch" = "Meta+Shift+S";
          "services/playerctl-2.desktop"."_launch" = "Ctrl+Shift+Left";
          "services/playerctl-4.desktop"."_launch" = "Ctrl+Shift+Space";
          "services/playerctl.desktop"."_launch" = "Ctrl+Shift+Right";
          "services/org.kde.spectacle.desktop"."RectangularRegionScreenShot" = [ "Meta+Shift+P" "Meta+Shift+Print" ];
          "kwin"."Window Close" = [ "Meta+Shift+Q" "Alt+F4,Alt+F4,Close Window" ];
          "kwin"."Switch to Desktop 1" = [ "Meta+1" "Ctrl+F1,Ctrl+F1,Switch to Desktop 1" ];
          "kwin"."Switch to Desktop 2" = [ "Meta+2" "Ctrl+F2,Ctrl+F2,Switch to Desktop 2" ];
          "kwin"."Switch to Desktop 3" = [ "Meta+3" "Ctrl+F3,Ctrl+F3,Switch to Desktop 3" ];
          "kwin"."Switch to Desktop 4" = [ "Meta+4" "Ctrl+F4,Ctrl+F4,Switch to Desktop 4" ];
          "kwin"."Switch to Desktop 5" = [ "Meta+5" "Ctrl+F5,Ctrl+F5,Switch to Desktop 5" ];
          "kwin"."Switch to Desktop 6" = [ "Meta+6" "Ctrl+F6,Ctrl+F6,Switch to Desktop 6" ];
          "kwin"."Switch to Desktop 7" = [ "Meta+7" "Ctrl+F7,Ctrl+F7,Switch to Desktop 7" ];
          "kwin"."Switch to Desktop 8" = [ "Meta+8" "Ctrl+F8,Ctrl+F8,Switch to Desktop 8" ];
          "kwin"."Switch to Desktop 9" = [ "Meta+9" "Ctrl+F9,Ctrl+F9,Switch to Desktop 9" ];
          "kwin"."Switch to Desktop 10" = [ "Meta+0" "Ctrl+F10,Ctrl+F10,Switch to Desktop 10" ];
          "plasmashell"."activate task manager entry 1" = "Ctrl+1,Meta+1,Activate Task Manager Entry 1";
          "plasmashell"."activate task manager entry 2" = "Ctrl+2,Meta+2,Activate Task Manager Entry 2";
          "plasmashell"."activate task manager entry 3" = "Ctrl+3,Meta+3,Activate Task Manager Entry 3";
          "plasmashell"."activate task manager entry 4" = "Ctrl+4,Meta+4,Activate Task Manager Entry 4";
          "plasmashell"."activate task manager entry 5" = "Ctrl+5,Meta+5,Activate Task Manager Entry 5";
          "plasmashell"."activate task manager entry 6" = "Ctrl+6,Meta+6,Activate Task Manager Entry 6";
          "plasmashell"."activate task manager entry 7" = "Ctrl+7,Meta+7,Activate Task Manager Entry 7";
          "plasmashell"."activate task manager entry 8" = "Ctrl+8,Meta+8,Activate Task Manager Entry 8";
          "plasmashell"."activate task manager entry 9" = "Ctrl+9,Meta+9,Activate Task Manager Entry 9";
        };
        configFile = {
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
        };

        panels = [
          # Windows-like panel at the bottom
          {
            location = "top";
            height = 43;
            floating = false;
            widgets = [
              "org.kde.plasma.kickoff"
              # "org.kde.plasma.pager"
              {
                pager = {
                  size = {
                    width = 500;
                    height = 42;
                  };
                  general = {
                    showWindowOutlines = true;
                    displayedText = "desktopNumber";
                  };
                };
              }
              "org.kde.plasma.taskmanager"
              "org.kde.plasma.marginsseparator"
              # "org.kde.plasma.panelspacer"
              "org.kde.plasma.systemtray"
              "org.kde.plasma.digitalclock"

              #   {
              #     systemTray.items = {
              #       # We explicitly show bluetooth and battery
              #       shown = [
              #         "org.kde.plasma.battery"
              #         "org.kde.plasma.bluetooth"
              #       ];
              #       # And explicitly hide networkmanagement and volume
              #       hidden = [
              #         "org.kde.plasma.networkmanagement"
              #         "org.kde.plasma.volume"
              #       ];
              #     };
              #   }
            ];
          }
        ];
      };
    };
  };
}
