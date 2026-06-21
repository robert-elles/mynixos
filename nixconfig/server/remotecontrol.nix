{ config, pkgs, ... }:
{
  # === Guacamole (browser-based remote desktop gateway) ===

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true; # only needed for Wayland -- omit this when using with Xorg
    openFirewall = true;
    # settings = {
    #   port = 9012;
    # };
  };

  # permit sunshine to emulate input devices
  users.users.robert = {
    extraGroups = [ "uinput" ];
  };

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

  # === XRDP with i3 ===
  # i3 is a single-binary X11 window manager with no D-Bus singletons, so it
  # coexists trivially with the live Plasma Wayland session on seat0.
  # No dbus-run-session, no xfce4-session, no zombie panels.
  services.xrdp = {
    enable = true;
    defaultWindowManager = "${pkgs.writeShellScript "xrdp-i3" ''
      export XDG_CURRENT_DESKTOP=i3
      export XDG_SESSION_DESKTOP=i3
      echo "xrdp-i3 starting on DISPLAY=$DISPLAY" >> /tmp/xrdp-i3.log
      # Lower DPI so UI elements are smaller on high-res displays via Guacamole
      echo "Xft.dpi: 60" | ${pkgs.xrdb}/bin/xrdb -merge
      # i3bar wants a working PATH for status-command etc.
      export PATH=${pkgs.i3status}/bin:${pkgs.rofi}/bin:${pkgs.kitty}/bin:$PATH
      exec ${pkgs.i3}/bin/i3 -c /etc/i3/config-xrdp >> /tmp/xrdp-i3.log 2>&1
    ''}";
    openFirewall = false;
  };

  # Minimal i3 config tuned for remote use.
  # Mod4 = Super on PC keyboards = Cmd on Mac (when the RDP client passes it
  # through; in Microsoft Remote Desktop set Keyboard Mode = Scancode).
  environment.etc."i3/config-xrdp".text = ''
    set $mod Control

    font pango:DejaVu Sans 11 # same like kitty in dotfiles/.config/kitty/kitty.conf

    floating_modifier $mod

    # terminal & launcher
    bindsym $mod+Return exec ${pkgs.kitty}/bin/kitty
    bindsym $mod+d      exec ${pkgs.rofi}/bin/rofi -show drun -show-icons
    bindsym $mod+Shift+q kill
    bindsym $mod+w kill
    bindsym $mod+Shift+e exit
    bindsym $mod+Shift+r restart

    # focus (matches aerospace hjkl)
    bindsym $mod+h focus left
    bindsym $mod+j focus down
    bindsym $mod+k focus up
    bindsym $mod+l focus right

    # move (matches aerospace shift+hjkl)
    bindsym $mod+Shift+h move left
    bindsym $mod+Shift+j move down
    bindsym $mod+Shift+k move up
    bindsym $mod+Shift+l move right

    bindsym $mod+Left move left
    bindsym $mod+Down move down
    bindsym $mod+Up move up
    bindsym $mod+Right move right

    # layouts (matches aerospace slash/comma)
    bindsym $mod+slash layout toggle split
    bindsym $mod+comma layout tabbed
    bindsym $mod+f fullscreen toggle

    # resize (matches aerospace minus/equal)
    bindsym $mod+minus resize shrink width 50 px
    bindsym $mod+equal resize grow width 50 px

    # tab cycling (matches aerospace alt-tab)
    bindsym $mod+Tab focus right
    bindsym $mod+Shift+Tab focus left

    # back-and-forth (matches aerospace alt-a)
    bindsym $mod+a workspace back_and_forth

    # workspaces 0-9
    bindsym $mod+1 workspace number 1
    bindsym $mod+2 workspace number 2
    bindsym $mod+3 workspace number 3
    bindsym $mod+4 workspace number 4
    bindsym $mod+5 workspace number 5
    bindsym $mod+6 workspace number 6
    bindsym $mod+7 workspace number 7
    bindsym $mod+8 workspace number 8
    bindsym $mod+9 workspace number 9
    bindsym $mod+0 workspace number 10
    bindsym $mod+Shift+1 move container to workspace number 1
    bindsym $mod+Shift+2 move container to workspace number 2
    bindsym $mod+Shift+3 move container to workspace number 3
    bindsym $mod+Shift+4 move container to workspace number 4
    bindsym $mod+Shift+5 move container to workspace number 5
    bindsym $mod+Shift+6 move container to workspace number 6
    bindsym $mod+Shift+7 move container to workspace number 7
    bindsym $mod+Shift+8 move container to workspace number 8
    bindsym $mod+Shift+9 move container to workspace number 9
    bindsym $mod+Shift+0 move container to workspace number 10

    # appearance
    default_border pixel 2
    gaps inner 4
    gaps outer 2

    bar {
      status_command ${pkgs.i3status}/bin/i3status -c /etc/i3status/config-xrdp
      position top
    }
  '';

  # Minimal i3status config without network/IP info
  environment.etc."i3status/config-xrdp".text = ''
    general {
      colors = true
      interval = 5
      color_good = "#50fa7b"
      color_degraded = "#f1fa8c"
      color_bad = "#ff5555"
    }

    order += "cpu_usage"
    order += "load"
    order += "memory"
    order += "disk /"
    order += "tztime local"

    cpu_usage {
      format = " CPU: %usage "
    }

    load {
      format = " Load: %1min "
    }

    memory {
      format = " RAM: %used / %total "
      threshold_degraded = "10%"
      threshold_critical = "5%"
    }

    disk "/" {
      format = " Disk: %avail "
    }

    tztime local {
      format = " %Y-%m-%d %H:%M "
    }
  '';

  # Packages available inside the xrdp i3 session
  environment.systemPackages = with pkgs; [
    i3
    i3status
    rofi
    kitty
    # Keep KRdp installed for native RDP client access to the live Plasma session
    kdePackages.krdp
  ];
}
