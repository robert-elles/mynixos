{ config, lib, pkgs, modulesPath, ... }: {
  imports = [
    "${
      builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; }
    }/raspberry-pi/4"
    #    "${
    #      fetchTarball
    #      "https://github.com/NixOS/nixos-hardware/archive/936e4649098d6a5e0762058cb7687be1b2d90550.tar.gz"
    #    }/raspberry-pi/4"
  ];

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
}
