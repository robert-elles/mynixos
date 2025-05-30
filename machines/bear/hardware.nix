# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  services.thermald.enable = true;

  boot.initrd.availableKernelModules = [ "nvme" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-intel" "amdgpu" ];
  boot.consoleLogLevel = 3;
  # boot.extraModulePackages = with config.boot.kernelPackages; [
  #   rtl88x2bu # wifi driver
  # ];

  services.xserver.videoDrivers = [ "amdgpu" ]; # amdgpu{-pro}, modesetting, radeon ];
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiVdpau
      amdvlk
      libvdpau-va-gl
      mesa
      vulkan-loader
      rocmPackages.clr.icd
      rocmPackages.rocm-runtime
    ];
  };

  environment.systemPackages = with pkgs; [
    amdgpu_top
    nvtopPackages.amd
    rocmPackages.rocminfo
  ];

  hardware.graphics.enable32Bit = true;
  hardware.graphics.extraPackages32 = with pkgs; [
    driversi686Linux.amdvlk
  ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/8205c211-5e6f-4fed-816d-be31d2cfca6f";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/BC02-94C3";
      fsType = "vfat";
    };

  # services.udev.extraRules = ''
  #   ACTION=="add", SUBSYSTEM=="block", KERNEL=="sd[a-z][0-9]", ENV{ID_FS_LABEL}=="usb1", RUN+="/run/wrappers/bin/mount /dev/disk/by-label/usb1 /mnt/usb"
  # '';

  swapDevices =
    [{ device = "/dev/disk/by-uuid/fe1bf30d-ceac-4af3-a8c1-a0c20d59a30e"; }];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp3s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp0s29u1u2.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?


}
