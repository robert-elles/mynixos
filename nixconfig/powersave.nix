{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    powerstat
    powertop
  ];
  powerManagement.powertop.enable = false;
  services.power-profiles-daemon.enable = false;
  services.auto-cpufreq.enable = true; # auto-cpufreq --stats
  services.thermald.enable = config.services.auto-cpufreq.enable; # recommended by auto-cpufreq
  # swtich between battery and ac : sudo tlp ac | bat
  # https://linrunner.de/tlp/support/troubleshooting.html
  services.tlp.enable = !config.services.auto-cpufreq.enable; # tlp-stat -s
  services.tlp.settings = {
    # USB_AUTOSUSPEND = 0;
    RUNTIME_PM_BLACKLIST = "06:00.3 06:00.4"; # check with lspci
  };
}
