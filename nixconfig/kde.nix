{ config, pkgs, lib, ... }:
let
  sddm-chili = pkgs.stdenv.mkDerivation rec {
    pname = "kde-plasma-chili";
    version = "0.5.5";
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/share/sddm/themes
      cp -aR $src $out/share/sddm/themes/chili
    '';
    src = pkgs.fetchFromGitHub {
      owner = "MarianArlt";
      repo = "${pname}";
      rev = "${version}";
      sha256 = "fWRf96CPRQ2FRkSDtD+N/baZv+HZPO48CfU5Subt854=";
    };
  };
  #  sddm_theme = pkgs.callPackage sddm-sugar-dark { };
in {
  services.xserver = {
    enable = true;
    desktopManager.plasma5.enable = true;
    displayManager = {
      sddm = {
        enable = true;
        theme = "chili";
      };
      #      defaultSession = "plasmawayland";
      defaultSession = "plasma";
    };
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu # application launcher most people use
        i3status # gives you the default i3 status bar
        i3lock # default i3 screen locker
        i3blocks # if you are planning on using i3blocks over i3status
      ];
    };
  };

  boot.plymouth.theme = "breeze";

  programs.kdeconnect.enable = true;
  services.printing.enable = true;

  security.pam.services.robert.enableKwallet = true;

  services.xserver.libinput = {
    enable = true;
    touchpad = {
      accelProfile = "flat";
      accelSpeed = "1";
    };
    mouse = { accelSpeed = "1.2"; };
  };
  #services.xserver.libinput.mouse.accelProfile = adaptive;
  services.unclutter.enable = true;

  environment.systemPackages = with pkgs; [
    sddm-chili
    #    libsForQt5.krohnkite
    #    libsForQt5.bismuth
    libsForQt5.ksshaskpass
    libsForQt5.kdeconnect-kde
    #    libsForQt5.yakuake
    libsForQt5.kde-cli-tools
    libsForQt5.ksystemlog
    libsForQt5.breeze-plymouth
    libsForQt5.dolphin-plugins
    libsForQt5.kmix
    sshfs-fuse
    sshfs
    sftpman
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
