system_repo_root:
{ config, pkgs, lib, home-manager, mach-nix, ... }: {
  imports = [
    (import ./home.nix {
      inherit config pkgs lib home-manager;
    })
    (import ./sound.nix)
    (import ./mediakeys.nix system_repo_root)
    (import ./packages.nix { inherit config pkgs lib mach-nix; })
    (import ./kde.nix)
    (import ./powersave.nix)
  ];

  networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  # add: "mitigations=off" to kernel params to disable spectre and meltdown for more performance
  boot.kernelParams = [ "nowatchdog" ];
  boot.kernel.sysctl = {
    # "fs.inotify.max_user_instances" = 40960;
    "fs.inotify.max_user_watches" = 1048576;
  };
  boot.loader.timeout = 1;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.plymouth = {
    enable = true;
    #    theme = "spinner";
    #    logo = ./milkyway.png;
  };

  nix = {
    settings = {
      # keep-outputs = true;
    };
  };

  hardware.enableAllFirmware = true;

  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true;

  services.fstrim.enable = true;
  services.irqbalance.enable = true;

  # services.gnome.gnome-keyring.enable = true;

  systemd.services.NetworkManager-wait-online.enable = false;

  services.nscd.enableNsncd = true;
  systemd.services.nscd.serviceConfig = {
    Restart = "always";
    RestartSec = 2;
    StartLimitIntervalSec = 5; # means that if the service is restarted more than 10 times in 5 seconds, it is considered to be in a failure state
    StartLimitBurst = 15;
  };

  virtualisation.docker.enable = true;
  #  virtualisation.docker.extraOptions = "--insecure-registry 10.180.3.2:5111 ";
  #  virtualisation.docker.extraOptions =
  #    "--insecure-registry registry.devsrv.kuelap.io:80 ";

  virtualisation.libvirtd.enable = true;
  # virtual box:
  # virtualisation.virtualbox.host.enable = true;
  # virtualisation.virtualbox.host.enableExtensionPack = true;
  # users.extraGroups.vboxusers.members = [ "robert" ];

  programs.light.enable = true; # screen and keyboard background lights

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.networkmanager.enable = true;

  services.fwupd.enable = true;

  fonts.packages = with pkgs; [ hermit source-code-pro ];

  fileSystems."/mnt/movies" = {
    device = "falcon:/export/movies";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" ];
  };
  fileSystems."/mnt/tvshows" = {
    device = "falcon:/export/tvshows";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" ];
  };
  fileSystems."/mnt/downloads" = {
    device = "falcon:/export/downloads";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" ];
  };

  systemd.services.post-resume-hook = {
    enable = true;
    description = "Commands to execute after resume";
    wantedBy = [ "post-resume.target" ];
    after = [ "post-resume.target" ];
    script =
      "/run/current-system/sw/bin/light -s sysfs/leds/tpacpi::power -S 0";
    serviceConfig.Type = "oneshot";
  };

  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';

  services.logind.extraConfig = ''
    HandleLidSwitchDocked=ignore
  '';

  services.geoclue2.enable = true;
  location.provider = "geoclue2";

  services.printing.enable = true;
  services.printing.drivers = [
    pkgs.hplip
    # pkgs.hplipWithPlugin
  ];
  services.avahi.enable = true;

  # needed for some gnome apps
  programs.dconf.enable = true;
  environment.systemPackages = [ pkgs.gnome.adwaita-icon-theme ];
  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
  services.gnome.gnome-settings-daemon.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall =
      true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall =
      true; # Open ports in the firewall for Source Dedicated Server
  };

  nixpkgs.config.packageOverrides = pkgs: {
    chromium = pkgs.chromium.override {
      commandLineArgs = [
        # "--enable-features=WebUIDarkMode,VaapiVideoEncoder,VaapiVideoDecoder,CanvasOopRasterization,RawDraw,WebRTCPipeWireCapturer,Vulkan,VulkanFromANGLE,DefaultANGLEVulkan"
        # "--enable-features=WebUIDarkMode,VaapiVideoEncoder,VaapiVideoDecoder,CanvasOopRasterization,RawDraw,WebRTCPipeWireCapturer,Vulkan"
        "--enable-features=WebUIDarkMode,VaapiVideoEncoder,VaapiVideoDecoder,WebRTCPipeWireCapturer,RawDraw"
        "--force-dark-mode"
        "--enable-gpu-rasterization"
        "--enable-raw-draw" # web page divides the page into grids of 256 x 256 pixels and updates only necessary parts
        "--enable-drdc" # Display compositor uses new dr-dc gpu thread and all other clients (raster, webgl, video) continues using the gpu main thread.
        "--enable-zero-copy" # Raster threads write directly to GPU memory associated with tiles
        # "--skia-graphite-backend"
        # "--skia-graphite"
        # "--use-gl=egl"
        # "--use-gl=desktop"
        # "--ignore-gpu-blocklist"
        # user the gpu to composite the content of a web page
        # "--use-vulkan"
        # "--enable-vulkan"
        # "--disable-sync-preferences"
        # "--disable-features=UseChromeOSDirectVideoDecoder"
        # "--enable-unsafe-webgpu"
      ];
    };
  };

  programs.chromium.enable = true;
  # see id in url of extensions on chrome web store page
  programs.chromium.extensions = [
    "niloccemoadcdkdjlinkgdfekeahmflj" # pocket
    "edibdbjcniadpccecjdfdjjppcpchdlm" # I still don't care about cookies
    "dhdgffkkebhmkfjojejmpbldmpobfkfo" # Tampermonkey
    "lcbjdhceifofjlpecfpeimnnphbcjgnc" # XBrowserSync
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.allowSFTP = true;


  # system.activationScripts.report-changes = ''
  #   PATH=$PATH:${lib.makeBinPath [ pkgs.nvd pkgs.nix ]}
  #   nvd diff $(ls -dv /nix/var/nix/profiles/system-*-link | tail -2)
  # '';

  # run binaries compiled for other linux distributions
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    fuse3
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    curl
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libGL
    libappindicator-gtk3
    libdrm
    libnotify
    libpulseaudio
    libuuid
    xorg.libxcb
    libxkbcommon
    mesa
    nspr
    nss
    pango
    pipewire
    systemd
    icu
    openssl
    xorg.libX11
    xorg.libXScrnSaver
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXtst
    xorg.libxkbfile
    xorg.libxshmfence
    zlib
  ];

  xdg.mime.enable = true;
  xdg.mime.defaultApplications = {
    "text/html" = "chromium-browser.desktop";
    "image/jpeg" = "feh -F";
    "x-scheme-handler/http" = "chromium-browser.desktop";
    "x-scheme-handler/https" = "chromium-browser.desktop";
    "x-scheme-handler/about" = "chromium-browser.desktop";
    "x-scheme-handler/unknown" = "chromium-browser.desktop";
  };
}
