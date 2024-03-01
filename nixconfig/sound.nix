{ pkgs, ... }: {

  hardware.bluetooth.package = pkgs.bluez5-experimental;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    disabledPlugins = [
      "sap" # SIM Access profile
      # currently disabling those as they only report errors in journalctl:
      "mcp" # Media Control Profile
      "bap" # Basic Audio Profile, which is an essential part of LE Audio responsible for stream control and
      "vcp" # Volume Control Profile
    ];
    settings = {
      # Experimental = true;
      # Enables kernel experimental features, alternatively a list of UUIDs
      # can be given.
      # Possible values: true,false,<UUID List>
      # Possible UUIDS:
      # Defaults to false.
      #      KernelExperimental = true;
      Policy = { AutoEnable = true; };
      #      General = { };
    };
  };

  # rtkit is optional but recommended
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
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

  #  environment.etc."wireplumber/wireplumber.conf".text = ''
  #    context.properties = {
  #      log.level = 4
  #    }
  #  '';

  environment.etc = {
    "wireplumber/bluetooth.lua.d/50-bluez-config.lua".text = ''
      	table.insert (bluez_monitor.rules, {
          matches = {
            {
              { "node.name", "matches", "bluez_output.88_C9_E8_3A_1D_49.1" },
            },
          },
          apply_properties = {
             ["priority.session"] = 10000,
             ["priority.driver"] = 10000,
          },
        })
    '';
  };
}
