{ }: {

  # Networking
  networking.hostName = "rpi4";

  # Audio
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  boot.loader.raspberryPi.firmwareConfig = ''
    dtparam=audio=on
  '';

  powerManagement.cpuFreqGovernor = "ondemand";

  environment.systemPackages = with pkgs; [ raspberrypi-eeprom libraspberrypi ];

  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;
  nix = {
    autoOptimiseStore = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    # Free up to 1GiB whenever there is less than 100MiB left.
    extraOptions = ''
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}
    '';
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = 21.11; # Did you read the comment?
}
