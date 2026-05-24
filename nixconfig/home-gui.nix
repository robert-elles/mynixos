{ pkgs, inputs, ... }:
{

  home-manager = {

    sharedModules = [ inputs.plasma-manager.homeModules.plasma-manager ];

    users.robert = {
      imports = [
        # inputs.betterfox.homeModules.betterfox
        ./firefox.nix
      ];

      # imports = [
      #   ./firefox.nix
      # ];

      services.easyeffects.enable = true;
    };
  };
}
