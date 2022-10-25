{ config, pkgs, lib, ... }: {

  #  environment.systemPackages = with pkgs; [ python39Packages.dbus-python ];

  #  systemd.services.speaker-agent = {
  #    description = "Bluetooth speaker agent";
  #    serviceConfig = {
  #      ExecStart = let
  #        python = pkgs.python39.withPackages (ps:
  #          with ps; [
  #            pkgs.python39Packages.dbus-python
  #            pkgs.python39Packages.pygobject3
  #          ]);
  #      in "${python.interpreter} ${./speaker-agent.py}";
  #      #    ExecStart = "python ${./speaker-agent.py}";
  #    };
  #    wantedBy = [ "default.target" ];
  #  };

  # The bluetooth controller is by default connected to the UART device at /dev/ttyAMA0
  # and needs to be enabled through btattach
  #  systemd.services.btattach = {
  #    before = [ "bluetooth.service" ];
  #    after = [ "dev-ttyAMA0.device" ];
  #    wantedBy = [ "multi-user.target" ];
  #    description = "Enable bluetooth";
  #    serviceConfig = {
  #      ExecStart =
  #        "${pkgs.bluez}/bin/btattach -B /dev/ttyAMA0 -P bcm -S 3000000";
  #    };
  #  };

  # Audio & bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    disabledPlugins = [ "sap" ];
    settings = {
      Policy = { AutoEnable = true; };
      General = {
        Class = "0x41C";
        Name = "rpi4";
        DiscoverableTimeout = 0;
        PairableTimeout = 0;
        JustWorksRepairing = "always";
      };
    };
  };
  sound.enable = true;
  #  hardware.pulseaudio.enable = true;
  # rtkit is optional but recommended
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    systemWide = false;
    wireplumber.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  #  environment.etc = {
  #    "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
  #
  #      	bluez_monitor.properties = {
  #          ["bluez5.enable-sbc-xq"] = true,
  #      		["bluez5.enable-msbc"] = true,
  #      		["bluez5.enable-hw-volume"] = true,
  #      	}
  #
  #      	bluez_monitor.rules = {
  #          matches = {
  #            {
  #              { "device.name", "matches", "bluez_card.*" },
  #            },
  #          },
  #          apply_properties = {
  #             ["bluez5.auto-connect"]  = "[ a2dp_sink ]",
  #             ["device.profile"] = "a2dp-sink",
  #          }
  #        }
  #    '';
  #  };
}
