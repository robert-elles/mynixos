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
        panels = [
          # Windows-like panel at the bottom
          {
            location = "top";
            height = 43;
            floating = false;
            widgets = [
              "org.kde.plasma.kickoff"
              "org.kde.plasma.pager"
              "org.kde.plasma.icontasks"
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
