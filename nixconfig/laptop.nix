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
  boot.loader.timeout = 1;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.plymouth = {
    enable = true;
    #    theme = "spinner";
    #    logo = ./milkyway.png;
  };

  hardware.enableAllFirmware = true;

  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true;

  services.fstrim.enable = true;
  services.irqbalance.enable = true;

  services.gnome.gnome-keyring.enable = true;

  systemd.services.NetworkManager-wait-online.enable = false;

  services.nscd.enableNsncd = true;

  networking.extraHosts = ''
    192.168.11.232  registry.devsrv.kuelap.io
  '';

  virtualisation.docker.enable = true;
  #  virtualisation.docker.extraOptions = "--insecure-registry 10.180.3.2:5111 ";
  #  virtualisation.docker.extraOptions =
  #    "--insecure-registry registry.devsrv.kuelap.io:80 ";
  virtualisation.docker.daemon.settings = {
    insecure-registries = [ "registry.devsrv.kuelap.io:80" "10.180.3.2:5111" ];
  };

  programs.light.enable = true; # screen and keyboard background lights

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.networkmanager.enable = true;

  services.fwupd.enable = true;

  fonts.fonts = with pkgs; [ hermit source-code-pro ];

  systemd.services.post-resume-hook = {
    enable = true;
    description = "Commands to execute after resume";
    wantedBy = [ "post-resume.target" ];
    after = [ "post-resume.target" ];
    script =
      "/run/current-system/sw/bin/light -s sysfs/leds/tpacpi::power -S 0";
    serviceConfig.Type = "oneshot";
  };

  services.logind.extraConfig = ''
    HandleLidSwitchDocked=ignore
  '';

  services.geoclue2.enable = true;
  location.provider = "geoclue2";

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplipWithPlugin ];
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

  #  shellInit = ''
  #    export GTK_PATH=$GTK_PATH:${pkgs.oxygen_gtk}/lib/gtk-2.0
  #    export GTK2_RC_FILES=$GTK2_RC_FILES:${pkgs.oxygen_gtk}/share/themes/oxygen-gtk/gtk-2.0/gtkrc
  #  '';

  #  environment.sessionVariables = { };

  nixpkgs.config.packageOverrides = pkgs: {
    ctlptl = pkgs.callPackage ./packages/ctlptl {
      buildGoModule = pkgs.buildGo117Module;
    };
    chromium = pkgs.chromium.override {
      commandLineArgs = [
        "--enable-features=VaapiVideoDecoder"
        "--use-gl=desktop"
        "--ignore-gpu-blocklist"
        "--enable-gpu-rasterization"
        "--enable-zero-copy"
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

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ 8080 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  networking.firewall.enable = true;

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
