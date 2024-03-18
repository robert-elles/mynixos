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

  services.pipewire = {
    enable = true;
    systemWide = false;
    wireplumber.enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.pipewire.socketActivation = false;
  systemd.user.services.pipewire.wantedBy = [ "default.target" ];
  systemd.user.services.pipewire-pulse.wantedBy = [ "default.target" ];

  security.rtkit.enable = true;
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

  services.pipewire.wireplumber.configPackages = [
    (pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/50-bluez-config.lua" ''
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
    '')
  ];
}
