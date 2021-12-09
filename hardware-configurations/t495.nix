# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    "${
      builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; }
    }/lenovo/thinkpad/t495"
    "${
      builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; }
    }/common/gpu/amd"
  ];

  boot.initrd.availableKernelModules =
    [ "nvme" "ehci_pci" "xhci_pci" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  #  boot.kernelModules = [ "kvm-amd" "amdgpu" ];
  boot.extraModulePackages = [ ];
  #  boot.kernelParams = ["acpi_backlight=vendor"];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/73ccb115-5243-445c-8d3e-5b194fb48428";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/B291-CDF1";
    fsType = "vfat";
  };

  swapDevices = [ ];

  #  services.xserver.videoDrivers = [ "amdgpu" ];
  #
  #  hardware.opengl.driSupport = true;
  #  # For 32 bit applications
  #  hardware.opengl.driSupport32Bit = true;
  #
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      #        intel-media-driver # LIBVA_DRIVER_NAME=iHD
      #        vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      amdvlk
      libvdpau-va-gl
      rocm-opencl-icd
      rocm-opencl-runtime
      mesa
    ];
  };
  #
  #    hardware.opengl.extraPackages32 = with pkgs; [
  #      driversi686Linux.amdvlk
  #    ];

  networking.interfaces.enp3s0f0.useDHCP = true;
  networking.interfaces.enp4s0.useDHCP = true;
  networking.interfaces.wlp1s0.useDHCP = true;
  #networking.wireless.interfaces = ["wlp1s0"];

}
