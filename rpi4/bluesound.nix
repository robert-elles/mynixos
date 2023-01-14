{ config, pkgs, lib, ... }: {

  environment.systemPackages = with pkgs;
    [
      bluez-tools
      #    python39Packages.dbus-python
    ];

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


  # First you have to configurate sspmode 0, for pin request: hciconfig hci0 sspmode 0
  # systemd.user.services.noinputbtagent = {
  #   #    wantedBy = [ "multi-user.target" ];
  #   wantedBy = [ "default.target" ];
  #   after = [ "bluetooth.service" ];
  #   description = "noinput bt agent";
  #   serviceConfig = {
  #     ExecStart =
  #       "${pkgs.bluez-tools}/bin/bt-agent --capability=NoInputNoOutput";
  #     Restart = "always";
  #     RestartSec = 12;
  #     #      DynamicUser = true;
  #     #      User = "robert";
  #     #      SupplementaryGroups = [ "audio" ];
  #   };
  # };

  # Audio & bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    disabledPlugins = [ "sap" ]; # SIM Access profile
    settings = {
      #      Policy = { AutoEnable = true; };
      General = {
        #        ControllerMode = "le"; # dual (default), bredr, le
        #        Enable = "Source,Sink,Media,Socket";
        #        Class = "0x00041C";
        Class = "0x41C";
        Name = "rpi4";
        DiscoverableTimeout = 0;
        PairableTimeout = 0;
        #        JustWorksRepairing = "always";
        #        FastConnectable = "true";
        #        MultiProfile = "multiple";
      };
    };
  };
  # Remove sound.enable or turn it off if you had it set previously, it seems to cause conflicts with pipewire
  #sound.enable = false;
  #  hardware.pulseaudio.enable = true;
  # rtkit is optional but recommended
  security.rtkit.enable = true;
  # xdg.portal.enable = true; # seems to be needed for pipewire

  services.pipewire = {
    enable = true;
    systemWide = false;
    wireplumber.enable = true;
    alsa.enable = false;
    alsa.support32Bit = true;
    pulse.enable = false;
    jack.enable = true;
  };

  # environment.etc = {
  #   "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
  #     	bluez_monitor.rules = {
  #         matches = {
  #           {
  #             { "device.name", "matches", "bluez_card.*" },
  #           },
  #         },
  #         apply_properties = {
  #            ["bluez5.auto-connect"]  = "[ a2dp_sink ]",
  #            ["device.profile"] = "a2dp-sink",
  #         }
  #       }
  #   '';
  # };
}
