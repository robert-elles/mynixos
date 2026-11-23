{ ... }:
{

  services.guacamole-server = {
    enable = true;
    host = "127.0.0.1";
    port = 4822;
    userMappingXml = ./user-mapping.xml;
  };

  services.guacamole-client = {
    enable = true;
    enableWebserver = true;
    settings = {
      guacd-port = 4822;
      guacd-hostname = "localhost";
    };
  };

  services.tomcat.port = 9011;

  # XRDP remote desktop
  services.xrdp = {
    enable = true;
    defaultWindowManager = "startplasma-x11";
  };

  # Sunshine game streaming
  # TODO: capture method needs investigation
  # leopard runs KDE Plasma 6 on Wayland; valid capture options: nvfbc, wlr, kms, x11
  # - wlr: KDE/KWin does not implement wlr-export-dmabuf
  # - kms: KWin holds DRM resources exclusively, KMS monitor list empty
  # - x11: needs an X11 session (currently Wayland)
  # - nvfbc: NVIDIA consumer GPUs require driver patch to unlock
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };
}
