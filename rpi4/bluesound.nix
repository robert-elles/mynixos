{ config, pkgs, lib, ... }:
{

  environment.systemPackages = with pkgs;
    [
      bluez-tools
    ];

  nixpkgs.overlays = [
    (self: super: { a2dp-agent = pkgs.writeScript "a2dp-agent.py" (builtins.readFile ./a2dp-agent.py); })
  ];

  systemd.services.a2dp-agent = {
    description = "Bluetooth a2dp speaker agent";
    serviceConfig = {
      ExecStart =
        let
          python = pkgs.python310.withPackages (ps:
            with ps; [
              dbus-python
              pygobject3
              systemd
            ]);
        in
        "${python.interpreter} ${pkgs.a2dp-agent}";
    };
    wantedBy = [ "default.target" ];
    after = [ "bluetooth.service" ];
  };

  # seems to be needed for pipewire video/camera support
  # xdg.portal.enable = true;
  # xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # services.gnome.gnome-settings-daemon.enable = true;
  # programs.dconf.enable = true;

  # Audio & bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    disabledPlugins = [ "sap" ]; # SIM Access profile
    settings = {
      General = {
        Class = "0x41C";
        Name = "rpi4";
        DiscoverableTimeout = 0;
        PairableTimeout = 0;
      };
    };
  };
  # Remove sound.enable or turn it off if you had it set previously, it seems to cause conflicts with pipewire
  # sound.enable = true;
  # rtkit is optional but recommended
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    systemWide = false;
    wireplumber.enable = true;
    alsa.enable = false;
    # alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  security.pam.loginLimits = [
    {
      domain = "@audio";
      item = "rtprio";
      type = "-";
      value = "95";
    }
    {
      domain = "@audio";
      item = "memlock";
      type = "-";
      value = "unlimited";
    }
    {
      domain = "@audio";
      item = "nice";
      type = "-";
      value = "-19";
    }
  ];

  # services.pipewire = {
  #   config.pipewire-pulse = {
  #     "context.properties" = {
  #       "log.level" = 2;
  #     };
  #     "context.modules" = [{ name = "module-bluetooth-discover"; } { name = "module-bluetooth-policy"; }];
  #   };
  # };

  environment.etc = {
    "wireplumber/bluetooth.lua.d/50-bluez-config.lua".text = ''
      	table.insert (bluez_monitor.rules, {
          matches = {
              {
                { "device.name", "matches", "bluez_card.*" },
              },
            },
            apply_properties = {
              ["bluez5.auto-connect"]  = "[ a2dp_sink ]",
              ["device.profile"] = "a2dp-sink",
            }
        })
    '';
  };
}
