{ config, pkgs, lib, ... }:
with pkgs;
let

  numpy = python310Packages.numpy;
  numba = python310.pkgs.numba;
  pyqtgraph = python310Packages.pyqtgraph;
  pyqt6 = python310Packages.pyqt6;
  sounddevice = python310Packages.sounddevice;

  ebooklib = callPackage ./python/ebooklib {
    buildPythonPackage = python310.pkgs.buildPythonPackage;
    fetchPypi = python310.pkgs.fetchPypi;
    setuptools = python310.pkgs.setuptools;
    setuptools-scm = python310.pkgs.setuptools-scm;
    six = python310Packages.six;
    lxml = python310Packages.lxml;
  };

  pyexiftool = callPackage ./python/pyexiftool {
    buildPythonPackage = python310.pkgs.buildPythonPackage;
    fetchPypi = python310.pkgs.fetchPypi;
    setuptools = python310.pkgs.setuptools;
    setuptools-scm = python310.pkgs.setuptools-scm;
  };

  eventkit = callPackage ./python/eventkit {
    buildPythonPackage = python310.pkgs.buildPythonPackage;
    fetchPypi = python310.pkgs.fetchPypi;
    setuptools = python310.pkgs.setuptools;
    setuptools-scm = python310.pkgs.setuptools-scm;
    inherit numpy;
  };

  hifiscan = callPackage ./python/hifiscan {
    buildPythonPackage = python310.pkgs.buildPythonPackage;
    fetchPypi = python310.pkgs.fetchPypi;
    setuptools = python310.pkgs.setuptools;
    setuptools-scm = python310.pkgs.setuptools-scm;
    inherit numba pyqtgraph pyqt6 sounddevice eventkit;
  };

  largestinteriorrectangle = callPackage ./python/largestinteriorrectangle {
    buildPythonPackage = python310.pkgs.buildPythonPackage;
    fetchPypi = python310.pkgs.fetchPypi;
    setuptools = python310.pkgs.setuptools;
    setuptools-scm = python310.pkgs.setuptools-scm;
    numba = python310.pkgs.numba;
  };

  stitching = callPackage ./python/stitching {
    buildPythonPackage = python310.pkgs.buildPythonPackage;
    fetchPypi = python310.pkgs.fetchPypi;
    setuptools = python310.pkgs.setuptools;
    setuptools-scm = python310.pkgs.setuptools-scm;
    inherit largestinteriorrectangle;
    opencv4 = python310.pkgs.opencv4;
    numba = python310.pkgs.numba;
  };

  my-python-packages = python-packages:
    with python-packages; [
      #      pandas
      requests
      piexif
      stitching
      hifiscan
      subliminal
      pyexiftool
      ebooklib
      beautifulsoup4
      #      rich
    ];
  python-with-my-packages = python3.withPackages my-python-packages;
in {
  nixpkgs.overlays = [
    (self: super: {
      tilt = (super.tilt.override {
        buildGoModule = pkgs.buildGo118Module;
      }).overrideAttrs (old: rec {
        version = "0.30.9";
        src = super.fetchFromGitHub {
          owner = "tilt-dev";
          repo = "tilt";
          rev = "v${version}";
          #          sha256 = lib.fakeSha256;
          sha256 = "sha256-vZthFaIsgpZ2aap9kRSH//AHHnOpekPIkwpz9Tt0lI4=";
        };
        ldflags = [ "-X main.version=${version}" ];
      });
    })
  ];

  programs.java.enable = true;
  programs.java.package = pkgs.jdk11;

  programs.noisetorch.enable = true;

  environment.defaultPackages = with pkgs; [ keepassxc ];

  environment.systemPackages = with pkgs; [
    nixfmt
    vlang
    sshfs
    networkmanager
    inetutils
    wireguard-tools
    protonvpn-gui
    protonvpn-cli
    rofi # Window switcher, run dialog and dmenu replacement
    arc-theme # gtk theme
    lxappearance # set gtk themes
    kde-gtk-config # should set kde themes
    xarchiver
    gnome.file-roller
    cbatticon
    gitAndTools.gitFull
    mariadb
    miniserve
    youtube-dl
    powertop

    # Foto
    imagemagick
    exiftool
    libraw
    digikam
    darktable
    geeqie
    rapid-photo-downloader
    exiv2
    feh
    rawtherapee
    pinta
    shotwell
    nomacs
    hugin

    # gpu
    glxinfo
    nvtop-amd
    vdpauinfo
    radeontop

    ranger
    handlr # set default applications
    gparted
    polkit_gnome # polkit authentication agent

    # Audio
    pamixer
    pulseaudio # needed for pactl
    helvum # patchbay for pipewire
    pavucontrol
    playerctl
    audio-recorder
    audacity
    songrec
    alsa-utils

    nmap
    mpv
    gnome.gnome-clocks
    rxvt-unicode
    kitty
    dunst
    openvpn
    p7zip
    hydra-check
    #    typora # markdown editor
    auto-cpufreq
    xorg.xev
    light
    apostrophe # markdown editor
    #    wine
    winetricks
    wineWowPackages.stable
    bottles
    gnome.gnome-screenshot
    libsecret
    gnome.gnome-keyring
    gnome.libgnome-keyring
    xorg.xbacklight
    xfce.xfce4-pulseaudio-plugin
    xfce.thunar
    xfce.xfconf # Needed to save the preferences
    xfce.exo
    xfce.thunar-archive-plugin
    xfce.xfce4-i3-workspaces-plugin
    xfce.xfce4-panel
    xfce.xfce4-notifyd
    xfce.xfce4-battery-plugin
    xfce.xfce4-power-manager
    # Development
    tilt
    #    ctlptl
    glab # gitlab cli
    steam-run # run non-nixos compatible binaries
    nodejs-14_x
    maven
    gradle
    docker
    docker-compose
    dive
    pipenv
    python-with-my-packages
    #    vscode
    kube3d
    pinta
    postman
    google-cloud-sdk
    kubectl
    k9s
    kustomize
    smartgithg
    ytt
    direnv
    (callPackage ./my-spicedb-zed { buildGoModule = buildGo119Module; })

    dbeaver
    #    anki-bin
    vulkan-tools
    vulkan-loader
    vulkan-headers
    vulkan-validation-layers
    mr
    libva-utils
    arandr
    autorandr
    plasma-pa
    firefox
    joplin # cli client
    joplin-desktop
    #    pkgs-custom.chromium
    chromium
    zoom-us
    vlc
    spotify
    shortwave # radio
    transmission-gtk
    pirate-get
    blueberry
    (jetbrains.idea-ultimate.override { jdk = pkgs.jetbrains.jdk; })
    nextcloud-client
    networkmanagerapplet
    captive-browser
    libreoffice-fresh
    evince
    gnome.gedit
    notepadqq
    multipath-tools # kpartx -av some_image.img creates device files that can be mounted
    chiaki
    tdrop
    colmena
    anki-bin
    ffmpeg

    # printing
    hplip

    hwinfo
    corectrl

    calibre
    kstars
    tor-browser-bundle-bin
    signal-desktop
    gnome-frog # ocr (text extraction) tool
  ];
}
