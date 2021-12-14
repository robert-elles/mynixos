# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  parameters = import ./parameters.nix;
  home-manager = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/release-21.11.tar.gz";
in {
  imports = [ # Include the results of the hardware scan.
    (./hardware-configurations + "/${parameters.machine}.nix")
    (import (./machines + "/${parameters.machine}.nix"))
    (import "${home-manager}/nixos")
  ];

  boot.blacklistedKernelModules = [ "pcspkr" ];
  # Use the GRUB 2 boot loader.
  #boot.loader.grub.enable = true;
  #boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  #boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;

  services.auto-cpufreq.enable = true;

  networking.dhcpcd.wait = "background";

  networking.extraHosts = let
    hostsPath =
      "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
    hostsFile = builtins.fetchurl hostsPath;
  in builtins.readFile "${hostsFile}";

  sound.mediaKeys.enable = true;
  programs.light.enable = true;
  services.actkbd = {
    enable = true;
    bindings = [
      {
        keys = [ 224 ];
        events = [ "key" ];
        command = "/run/current-system/sw/bin/light -U 10";
      }
      {
        keys = [ 225 ];
        events = [ "key" ];
        command = "/run/current-system/sw/bin/light -A 10";
      }
      {
        keys = [ 171 ];
        events = [ "key" ];
        #        command =
        #          "/run/current-system/sw/bin/light -s sysfs/leds/tpacpi::kbd_backlight -S 100";
        command = "/etc/nixos/mynixos/kdblight";
        #        command = ''
        #          backlight=$(light -s sysfs/leds/tpacpi::kbd_backlight -G)
        #          if [ $backlight == "0.00" ]; then
        #              light -s sysfs/leds/tpacpi::kbd_backlight -S 100
        #          else
        #              light -s sysfs/leds/tpacpi::kbd_backlight -S 0
        #          fi
        #                            '';
      }
    ];
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  #networking.interfaces.enp0s3.useDHCP = true;
  networking.networkmanager.enable = true;
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system.
  #services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  #services.xserver.displayManager.gdm.enable = true;
  #services.xserver.desktopManager.gnome.enable = true;
  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  #programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {

    enable = true;
    # enableAutosuggestions = true;
    #enableSyntaxHighlighting = true;
    #ohMyZsh = {
    # enable = true;
    # plugins = [ "git" "python" "man" ];
    # theme = "robbyrussell";
    #};
  };

  environment.pathsToLink = [ "/libexec" ];
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.robert.enableGnomeKeyring = true;
  #  services.gnome3.gnome-keyring.enable = true;
  programs.seahorse.enable = true;

  hardware.video.hidpi.enable = true;
  services.xserver = {
    enable = true;

    desktopManager = {
      xterm.enable = false;
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };

    displayManager = {
      #        gdm.enable = true;
      #        sddm.enable = true;
      lightdm.enable = true;
      defaultSession = "xfce+i3";
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu # application launcher most people use
        i3status # gives you the default i3 status bar
        i3lock # default i3 screen locker
        i3blocks # if you are planning on using i3blocks over i3status
      ];

    };
  };

  services.picom.enable = true;

  services.fwupd.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  #  hardware.bluetooth.settings = {
  #    General = {
  #      Enable = "Source,Sink,Media,Socket";
  #    };
  #  };

  # Pulseaudio setup:
  #  sound.enable = true;
  #   hardware.pulseaudio = {
  #     enable = true;
  #       extraModules = [ pkgs.pulseaudio-modules-bt ];
  #       package = pkgs.pulseaudioFull;
  #       extraConfig = "
  #         load-module module-switch-on-connect
  #       ";
  #     };

  # rtkit is optional but recommended
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    media-session.config.bluez-monitor.rules = [
      {
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
      }
      {
        matches = [
          # Matches all sources
          {
            "node.name" = "~bluez_input.*";
          }
          # Matches all outputs
          { "node.name" = "~bluez_output.*"; }
        ];
        actions = { "node.pause-on-idle" = false; };
      }
    ];
    #    config.pipewire = {
    #      "context.properties" = {
    #        "link.max-buffers" = 16;
    #        "log.level" = 2;
    #        "default.clock.rate" = 48000;
    #        "default.clock.quantum" = 64;
    #        "default.clock.min-quantum" = 32;
    #        "default.clock.max-quantum" = 64;
    #        "core.daemon" = true;
    #        "core.name" = "pipewire-0";
    #      };
    #      "context.modules" = [
    #        {
    #          name = "libpipewire-module-rtkit";
    #          args = {
    #            "nice.level" = -15;
    #            "rt.prio" = 88;
    #            "rt.time.soft" = 200000;
    #            "rt.time.hard" = 200000;
    #          };
    #          flags = [ "ifexists" "nofail" ];
    #        }
    #        { name = "libpipewire-module-protocol-native"; }
    #        { name = "libpipewire-module-profiler"; }
    #        { name = "libpipewire-module-metadata"; }
    #        { name = "libpipewire-module-spa-device-factory"; }
    #        { name = "libpipewire-module-spa-node-factory"; }
    #        { name = "libpipewire-module-client-node"; }
    #        { name = "libpipewire-module-client-device"; }
    #        {
    #          name = "libpipewire-module-portal";
    #          flags = [ "ifexists" "nofail" ];
    #        }
    #        {
    #          name = "libpipewire-module-access";
    #          args = { };
    #        }
    #        { name = "libpipewire-module-adapter"; }
    #        { name = "libpipewire-module-link-factory"; }
    #        { name = "libpipewire-module-session-manager"; }
    #      ];
    #    };
    #    config.pipewire-pulse = {
    #      "context.properties" = { "log.level" = 2; };
    #      "context.modules" = [
    #        {
    #          name = "libpipewire-module-rtkit";
    #          args = {
    #            "nice.level" = -15;
    #            "rt.prio" = 88;
    #            "rt.time.soft" = 200000;
    #            "rt.time.hard" = 200000;
    #          };
    #          flags = [ "ifexists" "nofail" ];
    #        }
    #        { name = "libpipewire-module-protocol-native"; }
    #        { name = "libpipewire-module-client-node"; }
    #        { name = "libpipewire-module-adapter"; }
    #        { name = "libpipewire-module-metadata"; }
    #        {
    #          name = "libpipewire-module-protocol-pulse";
    #          args = {
    #            "pulse.min.req" = "32/48000";
    #            "pulse.default.req" = "32/48000";
    #            "pulse.max.req" = "32/48000";
    #            "pulse.min.quantum" = "32/48000";
    #            "pulse.max.quantum" = "32/48000";
    #            "server.address" = [ "unix:native" ];
    #          };
    #        }
    #      ];
    #      "stream.properties" = {
    #        "node.latency" = "32/48000";
    #        "resample.quality" = 1;
    #      };
    #    };
  };

  # Mouseconfig
  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.synaptics = {
    enable = false;
    buttonsMap = [ 1 3 2 ];
    fingersMap = [ 1 3 2 ];
    palmDetect = true;
    twoFingerScroll = true;
    horizontalScroll = false;
    horizTwoFingerScroll = false;
    accelFactor = "0.03";
    minSpeed = "0.8";
    maxSpeed = "10";
  };
  services.xserver.libinput = {
    enable = true;
    touchpad = {
      accelProfile = "flat";
      accelSpeed = "1";
    };
    mouse = { accelSpeed = "1.2"; };
  };
  #services.xserver.libinput.mouse.accelProfile = adaptive;
  services.unclutter.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    robert = {
      isNormalUser = true;
      extraGroups = [ "wheel" "docker" "networkmanager" "video" "input" ];
    };
  };

  fonts.fonts = with pkgs; [ hermit source-code-pro ];

  virtualisation.docker.enable = true;

  services.geoclue2.enable = true;
  location.provider = "geoclue2";
  services.redshift = {
    enable = false;
    brightness = {
      # Note the string values below.
      day = "1";
      night = "1";
    };
    temperature = {
      day = 5500;
      night = 3700;
    };
  };

  #  environment.shells = with pkgs; [ bashInteractive zsh ];

  environment.defaultPackages = with pkgs; [ tilt keepassxc ];

  programs.slock.enable = true;

  nixpkgs.config.allowUnfree = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    nano
    bash
    neofetch
    nixfmt
    killall
    networkmanager
    curl
    perl
    rsync
    wireguard-tools
    pstree
    gitAndTools.gitFull
    htop
    zsh
    lxappearance
    oh-my-zsh
    ncdu
    bc
    zip
    unzip
    unrar
    feh
    mpv
    mosh
    rxvt-unicode
    kitty
    auto-cpufreq
    xorg.xev
    light
    gnome.gnome-keyring
    gnome.libgnome-keyring
    xorg.xbacklight
    xfce.xfce4-pulseaudio-plugin
    xfce.thunar
    xfce.thunar-archive-plugin
    xfce.xfce4-i3-workspaces-plugin
    xfce.xfce4-panel
    xfce.xfce4-notifyd
    xfce.xfce4-battery-plugin
    xfce.xfce4-power-manager
    libsecret
    jdk11
    nodejs-14_x
    maven
    gradle
    docker
    docker-compose
    k3d
    postman
    google-cloud-sdk
    kubectl
    kustomize
    dbeaver
    vulkan-tools
    vulkan-loader
    vulkan-headers
    vulkan-validation-layers
    mr
    libva-utils
    vdpauinfo
    radeontop
    arandr
    autorandr
    plasma-pa
    firefox
    chromium
    zoom-us
    vlc
    spotify
    transmission-gtk
    pavucontrol
    blueberry
    #    jetbrains.jdk
    #    jetbrains.idea-ultimate
    (jetbrains.idea-ultimate.override { jdk = pkgs.jetbrains.jdk; })
    nextcloud-client
    networkmanagerapplet
    libreoffice-fresh
    evince
    gnome.gedit
    chiaki
    #     networkmanager_dmenu
  ];

  # tilt overlay for latest version
  nixpkgs.overlays = [
    (self: super: {
      tilt = super.tilt.overrideAttrs (old: rec {
        version = "0.23.3";
        src = super.fetchFromGitHub {
          owner = "tilt-dev";
          repo = "tilt";
          rev = "v${version}";
          #          sha256 = lib.fakeSha256;
          sha256 =
            "sha256:1612yrlsajl1j95zh057k82nzz492a9p1cgamph4m84zpm0v67jc";
        };
        ldflags = [ "-X main.version=${version}" ];
      });
    })
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

  home-manager.users.robert = {
    # Here goes your home-manager config, eg home.packages = [ pkgs.foo ];
    programs.zsh = {
      enable = true;
      zplug = {
        enable = true;
        plugins = [{
          name = "zsh-users/zsh-autosuggestions";
        } # Simple plugin installation
        #           { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; } # Installations with additional options. For the list of options, please refer to Zplug README.
          ];
      };
      shellAliases = {
        ll = "ls -l";
        update = "sudo nixos-rebuild switch";
      };
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "kubectl" "sudo" ];
        theme = "af-magic";
        #	    theme = "pygmalion";
        #	    theme = "duellj";
        #	    theme = "bira";
      };
      initExtra = ''
        source ~/gitlab/kuelap-connect/dev/kuelap.sh
      '';
    };

    home.file.".config/i3/config".source = ./i3/config;
    home.file.".config/i3status/config".source = ./i3status/config;
    home.file.".config/kitty/kitty.conf".source = ./kitty.conf;
    home.file.".config/systemd/user/default.target.wants/redshift.service".source =
      ./redshift.service;
    home.file.".xprofile".text = if (builtins.pathExists ./kuelap.conf) then
      "${(builtins.readFile ./kuelap.conf)}"
    else
      "";

    home.sessionVariables = {
      #LS_COLORS="$LS_COLORS:'di=1;33:'"; # export LS_COLORS
    };

    programs.git = {
      enable = true;
      extraConfig = { credential.helper = "libsecret"; };
    };

    #   xsession.windowManager.i3 = {
    #     config = rec {
    #
    ##       keybindings = lib.mkOptionDefault {
    ##              "XF86AudioMute" = "exec amixer set Master toggle";
    ##              "XF86AudioLowerVolume" = "exec amixer set Master 4%-";
    ##              "XF86AudioRaiseVolume" = "exec amixer set Master 4%+";
    ##              "XF86MonBrightnessDown" = "exec brightnessctl set 4%-";
    ##              "XF86MonBrightnessUp" = "exec brightnessctl set 4%+";
    ##              "${modifier}+Return" = "exec ${pkgs.kitty}/bin/kitty";
    ##              "${modifier}+d" = "exec ${pkgs.rofi}/bin/rofi -modi drun -show drun";
    ##              "${modifier}+Shift+d" = "exec ${pkgs.rofi}/bin/rofi -show window";
    ##              "${modifier}+b" = "exec ${pkgs.brave}/bin/brave";
    ##              "${modifier}+Shift+x" = "exec systemctl suspend";
    ##            };
    #
    #      bars = [
    #              {
    #                position = "top";
    ##                statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${./i3status-rust.toml}";
    #              }
    #            ];
    #     };
    #   };
  };
}

