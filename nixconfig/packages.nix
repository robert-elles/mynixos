{ pkgs, ... }:
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
        version = "6.5.1";
        src = super.fetchurl {
          url = "https://github.com/ferdium/ferdium-app/releases/download/v${version}/Ferdium-linux-${version}-amd64.deb";
          sha256 = "sha256-0srzSzNevvbzdihSNPkvCUMkFHPBwLko79SH5HLqGFc=";
          # sha256 = lib.fakeSha256;
        };
      });
      # sddm = super.sddm.overrideAttrs (old: {
      #   src = super.fetchFromGitHub {
      #     owner = "sddm";
      #     repo = "sddm";
      #     rev = "3ee57e99836fe051c97e0f301962120466d220f7";
      #     sha256 = lib.fakeSha256;
      #     # sha256 = "1s6icb5r1n6grfs137gdzfrcvwsb3hvlhib2zh6931x8pkl1qvxa";
      #   };
      # });
      # linphone = super.linphone.overrideAttrs (old: {
      #   src = super.fetchFromGitLab {
      #     domain = "gitlab.linphone.org";
      #     owner = "public";
      #     group = "BC";
      #     repo = pname;
      #     rev = version;
      #     sha256 = "sha256-V3vycO0kV6RTFZWi6uiCFSNfLq/09dBfyLk/5zw3kRA=";
      #   };
      # });
    })
  ];

  programs.java.enable = true;
  programs.java.package = pkgs.jdk19;

  programs.noisetorch.enable = true;

  environment.defaultPackages = with pkgs; [ keepassxc ];

  environment.systemPackages = with pkgs; [
    nil # nix language server
    # poetry
    nixfmt
    nixpkgs-fmt
    nix-tree
    manix
    nix-du
    vlang
    sshfs
    samba
    networkmanager
    inetutils
    wireguard-tools
    protonvpn-gui
    protonvpn-cli
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
    libcamera
    gnome.yelp # see the documentation in easyeffects
    gnome.seahorse # view the keyring store
    virt-manager
    gramps # family tree stammbau

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
    qpwgraph
    pavucontrol
    playerctl
    audio-recorder
    audacity
    songrec
    alsa-utils

    nmap
    mpv
    gnome.gnome-clocks
    kitty
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
    # steam-run # run non-nixos compatible binaries
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
    gh # github cli
    git
    zeal # offline api documentation browser
    poetry

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
    # (jetbrains.idea-ultimate.override { jdk = pkgs.jetbrains.jdk; })
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
    dfeet # dbus viewer d-feet
    convmv # fix file name encoding
    android-tools

    # node nix package development
    node2nix
    prefetch-npm-deps
    nodejs

    # android
    scrcpy # android dev remote control
    android-studio

    linuxKernel.packages.linux_latest_libre.cpupower
    kodi
    protonup-qt
    lutris
    heroic
  ];
}
