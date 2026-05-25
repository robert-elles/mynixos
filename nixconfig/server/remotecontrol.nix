{ config, pkgs, ... }:
{
  # === Guacamole (browser-based remote desktop gateway) ===

  services.guacamole-server = {
    enable = true;
    host = "127.0.0.1";
    port = 4822;
  };

  services.guacamole-client = {
    enable = true;
    enableWebserver = true;
    settings = {
      guacd-hostname = "127.0.0.1";
      guacd-port = 4822;
    };
  };

  services.tomcat.port = 9011;

  # Guacamole's file-auth provider only reads from GUACAMOLE_HOME/user-mapping.xml
  # (hardcoded filename). Symlink it to the agenix-decrypted secret at runtime.
  systemd.tmpfiles.rules = [
    "L+ /etc/guacamole/user-mapping.xml - - - - ${config.age.secrets.guacamole_user_mapping.path}"
  ];

  # === XRDP (the desktop session guacamole connects to) ===
  services.xrdp = {
    enable = true;
    defaultWindowManager = "${pkgs.kdePackages.plasma-workspace}/bin/startplasma-x11";
    openFirewall = false;
  };
}
