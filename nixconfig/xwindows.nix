{ config, pkgs, ... }: {

  environment.pathsToLink = [ "/libexec" ];
  # security.pam.services.robert.enableGnomeKeyring = true;
  programs.seahorse.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  #  hardware.video.hidpi.enable = true;
  services.xserver = {
    enable = true;

    desktopManager = {
      xterm.enable = false;
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };

    displayManager = {
      gdm.enable = true;
      #      sddm.enable = true;
      #      lightdm.enable = true;
      defaultSession = "xfce+i3";
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        # rofi, dunst
        dmenu # application launcher most people use
        i3status # gives you the default i3 status bar
        i3lock # default i3 screen locker
        i3blocks # if you are planning on using i3blocks over i3status
      ];

    };
  };

  services.xserver.desktopManager.xfce.thunarPlugins =
    [ pkgs.xfce.thunar-archive-plugin pkgs.xfce.thunar-volman ];

  programs.slock.enable = true;

  services.picom.enable = true;

  # Mouseconfig
  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.synaptics = {
    enable = false;
    buttonsMap = [ 1 3 2 ];
    fingersMap = [ 1 3 2 ];
    palmDetect = true;
    twoFingerScroll = true;
    horizontalScroll = false;
    horizTwoFingerScroll = false;
    accelFactor = "0.03";
    minSpeed = "0.8";
    maxSpeed = "10";
  };
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

  services.redshift = {
    enable = false;
    brightness = {
      # Note the string values below.
      day = "1";
      night = "1";
    };
    temperature = {
      day = 5500;
      night = 3700;
    };
  };

  environment.systemPackages = with pkgs; [
    xfce.xfce4-pulseaudio-plugin
    xfce.thunar
    xfce.xfconf # Needed to save the preferences
    xfce.exo
    xfce.thunar-archive-plugin
    xfce.xfce4-i3-workspaces-plugin
    xfce.xfce4-panel
    xfce.xfce4-notifyd
    xfce.xfce4-battery-plugin
    xfce.xfce4-power-manager
  ];
}
