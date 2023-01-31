{ config, pkgs, lib, mach-nix, ... }:
{
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
      ferdium = super.ferdium.overrideAttrs (old: rec {
        version = "6.2.3";
        src = super.fetchurl {
          url = "https://github.com/ferdium/ferdium-app/releases/download/v${version}/Ferdium-linux-${version}-amd64.deb";
          sha256 = "sha256-Pzx0H82jRa1cyfK7m+DQXw45XnsOFFL9bHki3zY1fAY=";
        };
      });
    })
  ];

  programs.java.enable = true;
  programs.java.package = pkgs.jdk19;

  programs.noisetorch.enable = true;

  environment.defaultPackages = with pkgs; [ keepassxc ];

  environment.systemPackages = with pkgs; [
    nil # nix language server
    poetry
    nixfmt
    nixpkgs-fmt
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
    gnome.seahorse # view the keyring store

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
    # handbrake # video transcoder

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
    # helvum # patchbay for pipewire
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
    # apostrophe # markdown editor
    #    wine
    winetricks
    wineWowPackages.stable
    bottles
    gnome.gnome-screenshot
    libsecret
    gnome.gnome-keyring
    gnome.libgnome-keyring
    xorg.xbacklight
    # Development
    # tilt
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
    # (callPackage ./my-spicedb-zed { buildGoModule = buildGo119Module; })

    dbeaver
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
    foliate
    kstars
    tor-browser-bundle-bin
    signal-desktop
    gnome-frog # ocr (text extraction) tool
    mixxx
    remmina # rdp client
    ferdium # multi messenger
  ];
}
