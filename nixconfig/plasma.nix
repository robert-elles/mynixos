{ inputs, settings, ... }:
let
  old_config = import ./plasma_rc2nix.nix;
in
{

  environment.systemPackages = [
    inputs.plasma-manager.packages.${settings.system}.rc2nix
  ];

  home-manager = {
    users.robert = {
      programs.plasma = {
        # See options in https://github.com/nix-community/plasma-manager/tree/trunk/modules
        enable = true;
        workspace = {
          wallpaper = "/home/robert/Documents/wallpaper/ilnur-kalimullin-9r4kV5VrdSQ-unsplash.jpg";
          lookAndFeel = "org.kde.breezedark.desktop";
        };
        panels = [
          # Windows-like panel at the bottom
          {
            location = "top";
            height = 43;
          }
        ];
        shortcuts = old_config.programs.plasma.shortcuts;
        configFile = old_config.programs.plasma.configFile;
      };
    };
  };
}
