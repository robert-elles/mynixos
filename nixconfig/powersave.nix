{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    powerstat
    powertop
  ];
  services.auto-cpufreq.enable = false; # auto-cpufreq --stats
  powerManagement.powertop.enable = false;
  services.power-profiles-daemon.enable = false;
  # services.thermald.enable = false;
  # swtich between battery and ac : sudo tlp ac | bat
  # https://linrunner.de/tlp/support/troubleshooting.html
  services.tlp.enable = true; # tlp-stat -s
  services.tlp.settings = {
    # USB_AUTOSUSPEND = 0;
    RUNTIME_PM_BLACKLIST = "06:00.3 06:00.4"; # check with lspci
  };
}
