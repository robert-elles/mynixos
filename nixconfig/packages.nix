{ config, pkgs, lib, ... }:
with pkgs;
let
  largestinteriorrectangle = python310.pkgs.buildPythonPackage rec {
    pname = "largestinteriorrectangle";
    version = "0.1.1";
    doCheck = false;
    format = "pyproject";
    src = python310.pkgs.fetchPypi {
      inherit pname version;
      sha256 = "sha256-giIa9M1Ov56U9IlSAVgnWzlzAawI+ymN8tBoxuXwPb8=";
    };
    nativeBuildInputs = [ python310.pkgs.setuptools-scm python310.pkgs.numba ];
    propagatedBuildInputs = [ python310.pkgs.setuptools ];
    meta = with lib; {
      description =
        "Largest Interior/Inscribed Rectangle implementation in Python";
      homepage = "https://github.com/lukasalexanderweber/lir";
    };
  };

  stitching = python310.pkgs.buildPythonPackage rec {
    pname = "stitching";
    version = "0.3.0";
    doCheck = false;
    format = "pyproject";
    src = python310.pkgs.fetchPypi {
      inherit pname version;
      sha256 = "sha256-dSrXWfbHYdGs6WTPeJ3xv4kl3fKGguAvPBFzfumw0Ko=";
    };
    postPatch = ''
      sed -ie '/opencv-python/d' setup.cfg
    '';
    nativeBuildInputs = [
      python310.pkgs.setuptools-scm
      largestinteriorrectangle
      python310.pkgs.opencv4
      python310.pkgs.numba
    ];
    propagatedBuildInputs =
      [ python310.pkgs.setuptools largestinteriorrectangle ];
    meta = with lib; {
      description = "A Python package for fast and robust Image Stitching";
      homepage = "https://github.com/lukasalexanderweber/stitching";
    };
  };
  my-python-packages = python-packages:
    with python-packages; [
      #      pandas
      requests
      piexif
      stitching
      python310.pkgs.opencv4
      python310.pkgs.numba
      largestinteriorrectangle
      # other python packages you want
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

  environment.defaultPackages = with pkgs; [ keepassxc ];

  environment.systemPackages = with pkgs; [
    nixfmt
    vlang
    sshfs
    networkmanager
    inetutils
    wireguard-tools
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
    easyeffects
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
    #    unstable.chromium
    pkgs-custom.chromium
    #    chromium
    #    unstable.zoom-us
    zoom-us
    vlc
    spotify
    shortwave # radio
    transmission-gtk
    pirate-get
    blueberry
    #    jetbrains.jdk
    #    jetbrains.idea-ultimate
    (jetbrains.idea-ultimate.override { jdk = pkgs.jetbrains.jdk; })
    nextcloud-client
    networkmanagerapplet
    captive-browser
    libreoffice-fresh
    evince
    gnome.gedit
    #    notepad-next
    notepadqq
    multipath-tools # kpartx -av some_image.img creates device files that can be mounted
    chiaki
    tdrop
    colmena
    anki-bin
    ffmpeg
    #     networkmanager_dmenu

    # printing
    hplip

    hwinfo
    corectrl

    calibre
    kstars
    tor-browser-bundle-bin
    signal-desktop
  ];
}
