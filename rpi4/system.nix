{ config, pkgs, lib, ... }: {

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
    "/data" = {
      device = "/dev/disk/by-label/DATA";
      fsType = "ext4";
      options = [ "noatime" "async" "nofail" ];
    };
  };

  #networking = { interfaces.eth0.useDHCP = true; };

  boot = {
    # kernelPackages = pkgs.linuxPackages;
    #    kernelPackages = pkgs.linuxPackages_latest;
    kernelPackages = pkgs.linuxPackages_rpi4; # working
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
      raspberryPi = {
        version = 4;
        firmwareConfig = ''
          dtparam=audio=on
           dtparam=krnbt=on
        '';
      };
    };
    tmpOnTmpfs = true;
    tmpOnTmpfsSize = "90%";
    initrd.availableKernelModules = [
      "usbhid"
      "usb_storage"
      "vc4"
      "pcie_brcmstb" # required for the pcie bus to work
      "reset-raspberrypi" # required for vl805 firmware to load
    ];
    # ttyAMA0 is the serial console broken out to the GPIO
    #    extraModprobeConfig = ''
    #      options snd_bcm2835 enable_headphones=1
    #    '';
    kernelParams = [
      "8250.nr_uarts=1"
      "console=ttyAMA0,115200"
      "console=tty1"
      # Some gui programs need this
      "cma=128M"
    ];
  };

  # No GPU:
  # services.xserver.videoDrivers = [ "fbdev" ];
  # Enable GPU acceleration
  hardware.raspberry-pi."4".fkms-3d.enable = true;
  #  hardware.raspberry-pi."4".audio.enable = true;
  #  hardware.raspberry-pi."4".dwc2.enable = true;
  # hardware.deviceTree.filter = "bcm2711-rpi-*.dtb";
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;
  #  hardware.firmware = [ pkgs.broadcom-bt-firmware ];


  # Networking
  networking.hostName = "rpi4";
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
  # Wireless
  networking = {
    wireless = {
      enable = true;
      interfaces = [ "wlan0" ];
      networks.bambule.psk = "@PSK_WIFI_HOME@";
      environmentFile = config.age.secrets.wireless.path;
    };
  };


  services.eternal-terminal.enable = true;

  security.sudo.wheelNeedsPassword = false;

  # store journal in memory only
  services.journald.extraConfig = ''
    Storage = volatile
    RuntimeMaxFileSize = 10M;
  '';
  services.fwupd.enable = true;

  powerManagement.cpuFreqGovernor = "ondemand";

  environment.systemPackages = with pkgs; [
    raspberrypi-eeprom
    libraspberrypi
    pamixer
    pulseaudio
    alsa-utils
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
