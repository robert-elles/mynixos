{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    powerstat
    powertop
  ];
  services.auto-cpufreq.enable = false; # auto-cpufreq --stats
  powerManagement.powertop.enable = false;
  services.power-profiles-daemon.enable = false;
  services.thermald.enable = false;
  # swtich between battery and ac : sudo tlp ac | bat
  # https://linrunner.de/tlp/support/troubleshooting.html
  services.tlp.enable = true; # tlp-stat -s
  services.tlp.settings = {
    # USB_AUTOSUSPEND = 0;
    # AHCI_RUNTIME_PM_ON_BAT = "on";
    # RUNTIME_PM_DRIVER_DENYLIST = "ahci xhci_hcd";
    RUNTIME_PM_BLACKLIST = "06:00.3 06:00.4"; # check with lspci

    # RADEON_DPM_PERF_LEVEL_ON_AC = "high";
    # RADEON_DPM_PERF_LEVEL_ON_BAT = "low";

    # RADEON_DPM_STATE_ON_AC = "performance";
    # RADEON_DPM_STATE_ON_BAT = "battery";

    # RADEON_POWER_PROFILE_ON_AC = "high";
    # RADEON_POWER_PROFILE_ON_BAT = "low";

    # PCIE_ASPM_ON_AC = "performance";
    # PCIE_ASPM_ON_BAT = "powersupersave";

    # DEVICES_TO_ENABLE_ON_STARTUP = "wifi";
    # DEVICES_TO_DISABLE_ON_STARTUP = "bluetooth nfc wwan";
    # DEVICES_TO_DISABLE_ON_SHUTDOWN = "bluetooth nfc wifi wwan";
    # DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE = "bluetooth nfc wifi wwan";

    # START_CHARGE_THRESH_BAT0 = 94;
    # STOP_CHARGE_THRESH_BAT0 = 98;

    # DEVICES_TO_DISABLE_ON_WIFI_CONNECT = "wwan";
    # DEVICES_TO_DISABLE_ON_WWAN_CONNECT = "wifi";
  };
}
