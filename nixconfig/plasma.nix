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
                    displayedText = {
                      desktopNumber = "Number";
                    };
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
