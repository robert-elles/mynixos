{ config, pkgs, ... }: {

  services.xserver = {
    enable = true;
    desktopManager.plasma5.enable = true;
    displayManager = {
      #      gdm.enable = true;
      sddm.enable = true;
      defaultSession = "plasmawayland";
    };
    #    windowManager.
  };

  programs.kdeconnect.enable = true;

  services.printing.enable = true;

  environment.systemPackages = with pkgs; [
    libsForQt5.bismuth
    libsForQt5.kde-cli-tools
    sshfs-fuse
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
