{ config, pkgs, lib, unstable, ... }:
let parameters = import ../parameters.nix;
in {

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.loader.raspberryPi = {
    #    enable = true;
    #    uboot.enable = true;
    version = 4;
    #    firmwareConfig = ''
    #      dtparam=audio=on
    #    '';
  };
  boot = {
    #    kernelPackages = pkgs.linuxPackages_latest;
    kernelPackages = pkgs.linuxPackages_rpi4;
    tmpOnTmpfs = true;
    initrd.availableKernelModules = [ "usbhid" "usb_storage" ];
    # ttyAMA0 is the serial console broken out to the GPIO
    #    extraModprobeConfig = ''
    #      options snd_bcm2835 enable_headphones=1
    #    '';
    kernelParams = [
      "8250.nr_uarts=1"
      "console=ttyAMA0,115200"
      "console=tty1"
      # Some gui programs need this
      "cma=128M"
    ];
  };

  # store journal in memory only
  services.journald.extraConfig = ''
    Storage = volatile
    RuntimeMaxFileSize = 10M;
  '';

  hardware.enableRedistributableFirmware = true;
  # Networking
  networking.hostName = "rpi4";
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
  # Wireless
  networking = {
    wireless = {
      enable = true;
      networks."${parameters.SSID}".psk = parameters.SSIDpassword;
      interfaces = [ "wlan0" ];
    };
  };

  # Audio & bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    disabledPlugins = [ "sap" ];
    settings = {
      General = {
        Class = "0x41C";
        Name = "rpi4";
        #        Enable = "Source,Sink,Media,Socket";
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
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    media-session.config.bluez-monitor.rules = [{
      # Matches all cards
      matches = [{ "device.name" = "~bluez_card.*"; }];
      actions = {
        "update-props" = {
          "bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
          # mSBC is not expected to work on all headset + adapter combinations.
          "bluez5.msbc-support" = true;
          # SBC-XQ is not expected to work on all headset + adapter combinations.
          "bluez5.sbc-xq-support" = true;
        };
      };
    }];
  };

  # mopidy
  services.mopidy = {
    enable = true;
    extensionPackages = with pkgs; [
      #      mopidy-spotify
      mopidy-iris
      mopidy-youtube
      mopidy-soundcloud
    ];
    configuration = ''
            #      [local]
            #      enabled = true
            #      media_dir = /data/nextcloud/nextcloud/data/robert/files/Music

            [http]
            enabled = true
            hostname = 0.0.0.0
            port = 6680

            [spotify]
            username = 1125705310
            password = ${parameters.mopidy.spotify.pwd}
            client_id = ${parameters.mopidy.spotify.client_id}
            client_secret = ${parameters.mopidy.spotify.client_secret}
            bitrate = 320

            [audio]
            #output = pulsesink server=127.0.0.1
            #output = pulsesink device=1
            #output = alsasink
            #output = autoaudiosink
            output = pulsesink
            mixer = software

            [youtube]
            enabled = true
            #autoplay_enabled = true
            youtube_api_key = ${parameters.mopidy.youtube_api_key}
            api_enabled = true

            [mpd]
            enabled = true
            hostname = 0.0.0.0
            zeroconf = mpd
            port = 6610
            connection_timeout = 240

      #      [file]
      #      enabled = true
      #      media_dirs = /data/nextcloud/nextcloud/data/robert/files/Music
      #      show_dotfiles = false
      #      excluded_file_extensions =
      #        .directory
      #        .html
      #        .jpeg
      #        .jpg
      #        .log
      #        .nfo
      #        .pdf
      #        .png
      #        .txt
      #        .zip
      #      follow_symlinks = false
      #      metadata_timeout = 1000

            [mowecl]
            enabled = true

            # generic config
            seek_update_interval = 500
            search_history_length = 10

            # theme config
            ## light or dark
            theme_type = dark
            #background_color = #fdf6e3
            #text_color = #002b36
            #primary_color = #268bd2


            [soundcloud]
            auth_token = ${parameters.mopidy.soundcloud_auth_token}
            explore_songs = 25

            [iris]
            country = DE
            locale = de_DE
    '';
  };
  powerManagement.cpuFreqGovernor = "ondemand";

  home-manager.users.robert = {
    # Here goes your home-manager config, eg home.packages = [ pkgs.foo ];
    programs.zsh = {
      enable = true;
      zplug = {
        enable = true;
        plugins = [
          #          { name = "zsh-users/zsh-autosuggestions"; }
          { name = "agkozak/zsh-z"; }
          { name = "agkozak/agkozak-zsh-prompt"; }
        ];
      };
      shellAliases = {
        ll = "ls -l";
        switch = "sudo nixos-rebuild switch";
      };
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "kubectl" "sudo" ];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    raspberrypi-eeprom
    libraspberrypi
    pamixer
    pulseaudio
  ];

  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;
  nix = {
    autoOptimiseStore = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    # Free up to 1GiB whenever there is less than 100MiB left.
    extraOptions = ''
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}
    '';
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
