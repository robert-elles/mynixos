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

  # Symlink agenix-decrypted user-mapping.xml to the hardcoded location the
  # file-auth provider reads from.
  systemd.tmpfiles.rules = [
    "L+ /etc/guacamole/user-mapping.xml - - - - ${config.age.secrets.guacamole_user_mapping.path}"
  ];

  # === XRDP with XFCE ===
  # Plasma can't run twice for the same user (live Wayland session on the
  # monitor + parallel xrdp X11 Plasma → dbus collision → black screen).
  # XFCE is a separate desktop with its own dbus services, so it coexists
  # fine with the live Plasma session.
  services.xrdp = {
    enable = true;
    # Use startxfce4 (not xfce4-session directly) — it launches the WM, panel,
    # and desktop together. Also set XDG_CURRENT_DESKTOP so xfsettingsd and
    # other XDG autostart units don't skip themselves.
    # Launch XFCE components directly instead of going through xfce4-session.
    # The session manager gets confused by Plasma's XDG_CONFIG_DIRS contamination
    # and ends up sleeping forever without spawning the WM/panel/desktop.
    defaultWindowManager = "${pkgs.writeShellScript "xrdp-xfce" ''
      export XDG_CURRENT_DESKTOP=XFCE
      export XDG_SESSION_DESKTOP=xfce
      export XDG_CONFIG_DIRS=/etc/xdg

      echo "xrdp-xfce starting on DISPLAY=$DISPLAY" >> /tmp/xrdp-xfce.log

      # Reap stale xfce components from prior xrdp sessions so D-Bus name
      # registration doesn't make new ones bail out as "already running".
      # We match the wrapped binary names too.
      ${pkgs.procps}/bin/pkill -9 -u "$USER" -f xfce4-panel || true
      ${pkgs.procps}/bin/pkill -9 -u "$USER" -f xfdesktop || true
      sleep 1

      # dbus-run-session gives this xrdp session its OWN session bus, isolated
      # from the user-wide /run/user/1000/bus that the live Plasma Wayland
      # session keeps occupied. Without this, xfce4-panel and xfdesktop see
      # Plasma's already-registered D-Bus names and exit immediately.
      exec ${pkgs.dbus}/bin/dbus-run-session -- ${pkgs.writeShellScript "xrdp-xfce-inner" ''
        echo "  inner bus=$DBUS_SESSION_BUS_ADDRESS" >> /tmp/xrdp-xfce.log
        ${pkgs.xfce.xfwm4}/bin/xfwm4 --compositor=off --display="$DISPLAY" >> /tmp/xrdp-xfce.log 2>&1 &
        sleep 1
        ${pkgs.xfce.xfce4-panel}/bin/xfce4-panel --disable-wm-check --display="$DISPLAY" >> /tmp/xrdp-xfce.log 2>&1 &
        ${pkgs.xfce.xfdesktop}/bin/xfdesktop --display="$DISPLAY" >> /tmp/xrdp-xfce.log 2>&1 &
        exec ${pkgs.xterm}/bin/xterm -geometry 80x24+10+10 -title "xrdp fallback shell"
      ''}
    ''}";
    openFirewall = false;
  };

  # Minimal XFCE so the xrdp session has a usable desktop
  environment.systemPackages = with pkgs; [
    xfce.xfce4-session
    xfce.xfwm4
    xfce.xfce4-panel
    xfce.xfce4-settings
    xfce.xfdesktop
    xfce.thunar
    xfce.xfce4-terminal
    # Keep KRdp installed for the live-session use case via native RDP clients
    kdePackages.krdp
  ];
}
