{ config, pkgs, lib, ... }: {

  # Audio & bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    disabledPlugins = [ "sap" ];
    settings = {
      General = {
        Class = "0x41C";
        Name = "rpi4";
        Enable = "Source,Sink,Media,Socket";
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
    systemWide = true;
    wireplumber.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    media-session.config.bluez-monitor.rules = [{
      # Matches all cards
      matches = [{ "device.name" = "~bluez_card.*"; }];
      actions = {
        "update-props" = {
          "bluez5.reconnect-profiles" =
            [ "hfp_hf" "hsp_hs" "a2dp_sink" "a2dp_source" ];
          # mSBC is not expected to work on all headset + adapter combinations.
          "bluez5.msbc-support" = true;
          # SBC-XQ is not expected to work on all headset + adapter combinations.
          "bluez5.sbc-xq-support" = true;
        };
      };
    }];
  };
}
