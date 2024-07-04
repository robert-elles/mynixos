# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
{ lib, pkgs, modulesPath, inputs, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t495)
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

  # fingerprint reader
  # fprintd-enroll
  services.fprintd.enable = true;

  boot.initrd.availableKernelModules =
    [ "nvme" "ehci_pci" "xhci_pci" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ "kvm-amd" "amdgpu" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/cbe9cefa-09b4-4997-9e0a-8e626f319553";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."luks-f6b0827a-9e93-4fe8-85aa-672d588d55f4".device = "/dev/disk/by-uuid/f6b0827a-9e93-4fe8-85aa-672d588d55f4";

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/7903-79ED";
      fsType = "vfat";
    };

  swapDevices = [ ];

  services.xserver.videoDrivers = [ "amdgpu" ]; # amdgpu{-pro}, modesetting, radeon ];
  hardware.cpu.amd.updateMicrocode = true;

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiVdpau
      amdvlk
      libvdpau-va-gl
      rocm-opencl-icd
      rocm-opencl-runtime
      mesa
      vulkan-loader
    ];
  };

  environment.systemPackages = with pkgs; [
    amdgpu_top
    nvtopPackages.amd
  ];

  # radv is mesa's amd driver and replaces amdvlk/radeon
  # environment.variables.AMD_VULKAN_ICD = "RADV";
  # environment.variables.AMD_VULKAN_ICD = "AMDVLK";

  # networking.interfaces.enp3s0f0.useDHCP = true;
  # networking.interfaces.enp4s0.useDHCP = true;
  # networking.interfaces.wlp1s0.useDHCP = true;
  #networking.wireless.interfaces = ["wlp1s0"];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  systemd.services.post-resume-hook = {
    enable = true;
    description = "Commands to execute after resume";
    wantedBy = [ "post-resume.target" ];
    after = [ "post-resume.target" ];
    script =
      "/run/current-system/sw/bin/light -s sysfs/leds/tpacpi::power -S 0";
    serviceConfig.Type = "oneshot";
  };

}
