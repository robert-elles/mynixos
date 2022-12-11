{ config, pkgs, lib, mach-nix, ... }:
with pkgs;
with python310.pkgs;
let

  poetry_py_env = pkgs.poetry2nix.mkPoetryEnv { projectDir = ./poetry; };

  mach_nix_py_env = mach-nix.lib."x86_64-linux".mkPython {
    python = "python310";
    ignoreDataOutdated = true;
    requirements = ''
      requests
      beautifulsoup4
      jupyter
      pandas
      numpy
      matplotlib
    '';
    #    requirements = lib.concatStringsSep "\n" [ "ebooklib" "jupyter" ];
    #    _.tomli.propagatedBuildInputs.mod = pySelf: self: oldVal:
    #      oldVal ++ [ pySelf.flit-core ];
  };

  pypi_drv = { pname, version, sha256 ? lib.fakeSha256, nbi ? [ ], pbi ? [ ] }:
    callPackage buildPythonPackage rec {
      inherit pname version;
      doCheck = false;
      format = "pyproject";
      src = fetchPypi { inherit pname version sha256; };
      nativeBuildInputs = [ setuptools-scm ] ++ nbi;
      propagatedBuildInputs = [ setuptools ] ++ pbi;
    };

  ebooklib = pypi_drv {
    pname = "EbookLib";
    version = "0.18";
    sha256 = "sha256-OFYmQ6e8lNm/VumTC0kn5Ok7XR0JF/aXpkVNtaHBpTM=";
    pbi = [ six lxml ];
  };

  pykson = pypi_drv {
    pname = "pykson";
    version = "0.9.9.8.14";
    sha256 = "sha256-6jL7js+Px4WMPbOObRwKpSe7jG7Lxa1v+DCk6OE0SyM=";
    pbi = [ jdatetime six pytz python-dateutil ];
  };

  pypi = name:
    { ... }@pypkgs:
    callPackage (./python + "/${name}") ({
      inherit buildPythonPackage fetchPypi setuptools setuptools-scm;
    } // pypkgs);

  #  ebooklib = pypi "ebooklib" { inherit six lxml; };
  pyexiftool = pypi "pyexiftool" { };
  eventkit = pypi "eventkit" { inherit numpy; };
  hifiscan =
    pypi "hifiscan" { inherit numba pyqtgraph pyqt6 sounddevice eventkit; };
  largestinteriorrectangle = pypi "largestinteriorrectangle" { inherit numba; };
  stitching = pypi "stitching" { inherit numba largestinteriorrectangle; };

  #  my-mach-nix-packages = ps:
  #    with ps;
  #    [
  #      (mach-nix.lib."x86_64-linux".mkPythonShell {
  #        requirements = ''
  #          requests
  #          ebooklib
  #        '';
  #      })
  #    ];

  my-python-packages = python-packages:
    with python-packages; [
      requests
      piexif
      stitching
      hifiscan
      subliminal
      pyexiftool
      ebooklib
      beautifulsoup4
      jupyter
      pandas
      numpy
      matplotlib
      #      pykson
    ];
  python-with-my-packages = python3.withPackages my-python-packages;
  #  python-with-my-packages = python3.withPackages my-mach-nix-packages;
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
    python-with-my-packages
    #    poetry_py_env
    #    mach_nix_py_env
    poetry
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
    libcamera
    gnome.yelp # see the documentation in easyeffects

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
    #    vscode.fhs
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
    mixxx
  ];
}
