{ config, pkgs, ... }: {

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    disabledPlugins = [ "sap" ]; # SIM Access profile
    settings = {
      #      Experimental = true;
      # Enables kernel experimental features, alternatively a list of UUIDs
      # can be given.
      # Possible values: true,false,<UUID List>
      # Possible UUIDS:
      # Defaults to false.
      #      KernelExperimental = true;
      #      Policy = { AutoEnable = true; };
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
}
