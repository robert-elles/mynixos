{ ... }:
{
  # XRDP remote desktop
  services.xrdp = {
    enable = true;
    defaultWindowManager = "startplasma-x11";
  };

  # Sunshine game streaming (headless via NvFBC)
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
    settings = {
      # NvFBC captures directly from the NVIDIA GPU without requiring a physical display
      # Only works with X11 (not Wayland)
      capture = "nvfbc";
    };
  };
}
