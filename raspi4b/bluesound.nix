{ config, pkgs, lib, ... }: {

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