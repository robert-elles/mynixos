{ config, lib, pkgs, ... }: {

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  #networking = { interfaces.eth0.useDHCP = true; };

  # Enable GPU acceleration
  hardware.raspberry-pi."4".fkms-3d.enable = true;
  hardware.raspberry-pi."4".audio.enable = true;
  #  hardware.raspberry-pi."4".dwc2.enable = true;
}
