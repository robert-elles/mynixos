{ pkgs, config, ... }:
{
  # Read home-manager changelog before changing this value
  home.stateVersion = "24.05";

  nixpkgs.overlays = config.nixpkgs.overlays;

  # insert home-manager config

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';
    # inherit shellAliases;
    plugins = [
    ];
  };
}
