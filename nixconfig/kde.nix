{ config, pkgs, unstable, ... }: {

  services.xserver = {
    enable = true;
    desktopManager.plasma5.enable = true;
    displayManager = {
      #      gdm.enable = true;
      sddm = {
        enable = true;
        settings = {
          General = {
            type = "color";
            color = "#242424";
            background = null;
          };
        };
      };
      defaultSession = "plasmawayland";
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

  programs.kdeconnect.enable = true;
  programs.kdeconnect.package = unstable.libsForQt5.kdeconnect-kde;
  services.printing.enable = true;

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
    libsForQt5.bismuth
    libsForQt5.kde-cli-tools
    libsForQt5.ksystemlog
    unstable.libsForQt5.kdeconnect-kde
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
