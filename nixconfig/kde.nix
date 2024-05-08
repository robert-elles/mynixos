{ pkgs, ... }:
# let
#   sddm-chili-theme = pkgs.stdenv.mkDerivation rec {
#     pname = "kde-plasma-chili";
#     version = "0.5.5";
#     dontBuild = true;
#     installPhase = ''
#       mkdir -p $out/share/sddm/themes
#       cp -aR $src $out/share/sddm/themes/chili
#     '';
#     src = pkgs.fetchFromGitHub {
#       owner = "MarianArlt";
#       repo = "${pname}";
#       rev = "${version}";
#       sha256 = "fWRf96CPRQ2FRkSDtD+N/baZv+HZPO48CfU5Subt854=";
#     };
#   };
# in
let
  # get current session: echo $XDG_SESSION_TYPE
  # session = "x11";
  session = "wayland";
in
{
  services.xserver = {
    enable = true;
  };
  # desktopManager.plasma5.enable = true;
  # desktopManager.lxqt.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager = {
    sddm = {
      enable = true;
      # theme = "chili";
      wayland.enable = if session == "x11" then false else true;
    };
    # defaultSession = "plasma";
    defaultSession = if session == "x11" then "plasmax11" else "plasma";
  };

  boot.plymouth.theme = "breeze";

  programs.kdeconnect.enable = true;

  security.pam.services.robert.enableKwallet = true;

  xdg.portal.enable = true;
  # xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-kde pkgs.xdg-desktop-portal-gtk ];

  services.unclutter.enable = true;

  # environment.systemPackages = with pkgs.libsForQt5; [
  environment.systemPackages = with pkgs.kdePackages; [
    #    krohnkite
    #    bismuth
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
