{ config, pkgs, lib, ... }: {
  imports = [
    (import ./sound.nix)
    (import ./mediakeys.nix)
    (import ./packages.nix { inherit config pkgs lib; })
    (import ./kde.nix)
    (import ./powersave.nix)
    (import ./home-gui.nix)
    (import ./hooks.nix)
  ];

  networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];
  networking.extraHosts = ''
    192.168.178.69 falcon
  '';

  # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  # add: "mitigations=off" to kernel params to disable spectre and meltdown for more performance
  boot.kernel.sysctl = {
    # "fs.inotify.max_user_instances" = 40960;
    "fs.inotify.max_user_watches" = 10485760;
  };

  boot.kernelPackages = pkgs.linuxPackages_zen;
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.plymouth = {
    enable = true;
    #    theme = "spinner";
    #    logo = ./milkyway.png;
  };
  boot.initrd.systemd.enable = true; # enables gui password prompt for encrypted disks
  boot.kernelParams = [ "quiet" ];

  # systemd.services.plymouth-quit = {
  #   description = "Retain Plymouth splash screen";
  #   wantedBy = [ "multi-user.target" ];
  #   before = [ "display-manager.service" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = "${pkgs.plymouth}/bin/plymouth --quit --retain-splash";
  #   };
  # };

  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # dbus service for generating thumbnails

  services.fstrim.enable = true;
  services.irqbalance.enable = true;

  programs.adb.enable = true;
  users.users.robert.extraGroups = [ "adbusers" ];
  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon android-udev-rules ];


  # services.gnome.gnome-keyring.enable = true;

  # systemd.services.NetworkManager-wait-online.enable = false;

  # services.nscd.enableNsncd = true;
  # systemd.services.nscd.serviceConfig = {
  #   Restart = "always";
  #   RestartSec = 2;
  #   StartLimitIntervalSec = 5; # means that if the service is restarted more than 10 times in 5 seconds, it is considered to be in a failure state
  #   StartLimitBurst = 15;
  # };

  virtualisation.docker.enable = true;
  #  virtualisation.docker.extraOptions = "--insecure-registry 10.180.3.2:5111 ";
  #  virtualisation.docker.extraOptions =
  #    "--insecure-registry registry.devsrv.kuelap.io:80 ";

  virtualisation.libvirtd.enable = false; # virtual machines
  # virtual box:
  # virtualisation.virtualbox.host.enable = true;
  # virtualisation.virtualbox.host.enableExtensionPack = true;
  # users.extraGroups.vboxusers.members = [ "robert" ];


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
  services.gnome.gnome-settings-daemon.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall =
      true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall =
      true; # Open ports in the firewall for Source Dedicated Server
  };

  nixpkgs.config.packageOverrides = pkgs: {
    # chromium = pkgs.chromium.override {
    #   commandLineArgs = [
    #     # "--enable-features=WebUIDarkMode,VaapiVideoEncoder,VaapiVideoDecoder,CanvasOopRasterization,RawDraw,WebRTCPipeWireCapturer,Vulkan,VulkanFromANGLE,DefaultANGLEVulkan"
    #     # "--enable-features=WebUIDarkMode,VaapiVideoEncoder,VaapiVideoDecoder,CanvasOopRasterization,RawDraw,WebRTCPipeWireCapturer,Vulkan"
    #     "--enable-features=WebUIDarkMode,VaapiVideoEncoder,VaapiVideoDecoder,WebRTCPipeWireCapturer,RawDraw"
    #     "--force-dark-mode"
    #     "--enable-gpu-rasterization"
    #     "--enable-raw-draw" # web page divides the page into grids of 256 x 256 pixels and updates only necessary parts
    #     "--enable-drdc" # Display compositor uses new dr-dc gpu thread and all other clients (raster, webgl, video) continues using the gpu main thread.
    #     "--enable-zero-copy" # Raster threads write directly to GPU memory associated with tiles
    #     # "--skia-graphite-backend"
    #     # "--skia-graphite"
    #     # "--use-gl=egl"
    #     # "--use-gl=desktop"
    #     # "--ignore-gpu-blocklist"
    #     # user the gpu to composite the content of a web page
    #     # "--use-vulkan"
    #     # "--enable-vulkan"
    #     # "--disable-sync-preferences"
    #     # "--disable-features=UseChromeOSDirectVideoDecoder"
    #     # "--enable-unsafe-webgpu"
    #   ];
    # };
  };

  programs.chromium.enable = true;
  # see id in url of extensions on chrome web store page
  programs.chromium.extensions = [
    "niloccemoadcdkdjlinkgdfekeahmflj" # pocket
    "edibdbjcniadpccecjdfdjjppcpchdlm" # I still don't care about cookies
    "dhdgffkkebhmkfjojejmpbldmpobfkfo" # Tampermonkey
    "lcbjdhceifofjlpecfpeimnnphbcjgnc" # XBrowserSync
  ];

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

  # see home manager settings
  xdg.mime.enable = true;
  xdg.mime.defaultApplications =
    let
      # browser = "chromium-browser.desktop";
      browser = "firefox.desktop";
    in
    {
      "text/html" = browser;
      "image/jpeg" = "feh -F";
      "x-scheme-handler/http" = browser;
      "x-scheme-handler/https" = browser;
      "x-scheme-handler/about" = browser;
      "x-scheme-handler/unknown" = browser;
    };
}
