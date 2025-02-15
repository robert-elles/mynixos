{ pkgs, ... }:
let
  # get current session: echo $XDG_SESSION_TYPE
  # session = "x11";
  session = "wayland";

  # background-package = pkgs.stdenvNoCC.mkDerivation {
  #   name = "background-image";
  #   src = ./.;
  #   dontUnpack = true;
  #   installPhase = ''
  #     cp $src/wallpaper.png $out  
  #   '';
  # };
in
{

  imports = [
    (import ./plasma.nix)
  ];

  services.xserver = {
    enable = true;
  };
  # desktopManager.plasma5.enable = true;
  # desktopManager.lxqt.enable = true;
  services.desktopManager.plasma6.enable = true;
  # services.displayManager = {
  #   sddm = {
  #     enable = true;
  #     # theme = "chili";
  #     theme = "breeze";
  #     wayland.enable = if session == "x11" then false else true;
  #   };
  #   # defaultSession = "plasma";
  #   defaultSession = if session == "x11" then "plasmax11" else "plasma";
  # };

  services.xserver.displayManager.lightdm = {
    enable = true;
  };

  boot.plymouth = {
    enable = true;
    theme = "breeze";
    #    logo = ./milkyway.png;
  };

  programs.kdeconnect.enable = true;

  security.pam.services.robert.enableKwallet = true;

  xdg.portal.enable = true;
  # xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-kde pkgs.xdg-desktop-portal-gtk ];

  # services.unclutter.enable = true; # hide mouse cursor when inactive

  # environment.systemPackages = with pkgs.libsForQt5; [
  environment.systemPackages = with pkgs.kdePackages; [
    # (
    #   pkgs.writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
    #     [General]
    #     background=${background-package}/wallpaper.png
    #   ''
    # )
    #    krohnkite
    pkgs.wl-clipboard
    kidletime
    plasma-browser-integration
    ksshaskpass
    kde-gtk-config # should set kde themes
    # kdeconnect-kde
    #    yakuake
    kde-cli-tools
    ksystemlog
    breeze-plymouth
    dolphin-plugins
    # kmix # plasma-pa instead
    plasma-pa
    # kpipewire
    kdeplasma-addons
    breeze-plymouth
    elisa
    plasma-vault
    powerdevil
    kmail
    # sddm-kcm # sddm settings module
    # sddm-chili-theme
    pkgs.sshfs-fuse
    pkgs.sshfs
    pkgs.sftpman
  ];

  networking.firewall.allowedUDPPortRanges = [{
    from = 1714;
    to = 1764;
  }];
  networking.firewall.allowedTCPPortRanges = [{
    from = 1714;
    to = 1764;
  }];
}
