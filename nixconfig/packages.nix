{ pkgs, pkgs-pin, ... }:
{
  nixpkgs.overlays = [
    (self: super: {
      # kdenlive = super.libsForQt5.kdenlive.override {
      #   mlt = super.mlt.override {
      #     frei0r = super.frei0r.override {
      #       opencv = null;
      #     };
      #   };
      #   frei0r = super.frei0r.override {
      #     opencv = null;  
      #   };
      # };
      # super-productivity = super.super-productivity.overrideAttrs (old: rec {
      #   version = "11.1.2";
      #   src = super.fetchurl {
      #     url = "https://github.com/johannesjo/super-productivity/releases/download/v${version}/superProductivity-x86_64.AppImage";
      #     sha256 = "sha256-AtN7x0Vt0wWxNoXwRc78drFE8UfMpssFBYZ83w1QgbU=";
      #     name = "${pname}-${version}.AppImage";
      #   };
      # });
    })
  ];

  programs.java.enable = true;
  # programs.java.package = pkgs.jdk19;

  programs.noisetorch.enable = true;

  environment.defaultPackages = with pkgs; [ keepassxc ];

  environment.systemPackages = with pkgs; [
    nil # nix language server
    # poetry
    nixfmt-rfc-style
    nixpkgs-fmt
    nix-tree
    manix
    zoom-us
    # nix-du  
    vlang
    sshfs
    samba
    ntfs3g
    networkmanager
    inetutils
    wireguard-tools
    # protonvpn-gui
    # protonvpn-cli
    inotify-tools
    arc-theme # gtk theme
    lxappearance # set gtk themes
    xarchiver
    file-roller
    # cbatticon
    gitAndTools.gitFull
    # mariadb
    miniserve
    # youtube-dl # out of date
    yt-dlp
    libcamera
    yelp # see the documentation in easyeffects
    seahorse # view the keyring store
    virt-manager
    # gramps # family tree stammbau
    bfg-repo-cleaner
    git-filter-repo
    # Foto
    imagemagick
    exiftool
    libraw
    digikam
    darktable
    gthumb
    pinta
    geeqie
    # rapid-photo-downloader
    exiv2
    feh
    # rawtherapee
    # pinta
    # shotwell
    # nomacs
    # hugin
    kdePackages.kdenlive # video editor
    # handbrake # video transcoder
    openshot-qt # video editor
    openshot-qt
    glaxnimate
    mediainfo
    ffmpeg-full
    comma

    # gpu
    glxinfo
    vdpauinfo
    radeontop

    portfolio
    zed-editor
    code-cursor # AI code editor

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
    gnome-clocks
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
    # bottles
    # protonup-qt # wine proton installer
    lutris # game launcher
    # heroic # epic game store
    # ludusavi # backup game saves
    gnome-screenshot
    libsecret
    gnome-keyring
    libgnome-keyring
    xorg.xbacklight
    # steam-run # run non-nixos compatible binaries

    protonup-qt

    maven
    gradle
    docker
    docker-compose
    dive # explore docker image layers's contents
    pipenv
    direnv
    devenv # also see devshell
    gh # github cli
    git
    # zeal # offline api documentation browser
    poetry
    bintools # for the strings command
    android-studio

    dbeaver-bin
    vulkan-tools
    vulkan-loader
    vulkan-headers
    vulkan-validation-layers
    libva-utils
    arandr
    # firefox
    # joplin # cli client
    joplin-desktop
    planify
    chromium
    # zoom-us
    vlc
    # spotify
    spotifywm # set correct class name for spotify
    # shortwave # radio
    pirate-get
    transmission_4-gtk
    btfs # bittorrent filesystem
    # blueberry 
    # (jetbrains.idea-ultimate.override { jdk = pkgs.jetbrains.jdk; })
    # jetbrains.idea-community
    # jetbrains.pycharm-community
    nextcloud-client
    captive-browser
    libreoffice-fresh
    evince
    gedit
    notepadqq
    multipath-tools # kpartx -av some_image.img creates device files that can be mounted
    # chiaki # playstation remote play
    # tdrop # drop down terminal
    colmena # nixos deployment tool
    anki
    hwinfo
    corectrl

    calibre
    foliate # ebook reader
    # kstars
    tor-browser-bundle-bin
    signal-desktop
    gnome-frog # ocr (text extraction) tool
    mixxx # dj software
    jamesdsp
    # spotdl # spotify downloader
    remmina # rdp client
    ferdium # multi messenger
    convmv # fix file name encoding
    android-tools
    zotero # literatur verwaltung
    # node nix package development
    node2nix
    prefetch-npm-deps
    nodejs
    nodePackages.prettier

    # android
    # scrcpy # android dev remote control
    # android-studio

    # boot.kernelPackages = pkgs.linuxPackages_latest;
    # linuxKernel.packages.linux_latest_libre.cpupower
    # config.boot.kernelPackages.cpupower

    pdfsam-basic
    pdfarranger

    # minecraft
    prismlauncher

    # spell checking:
    hunspell
    hunspellDicts.de_DE
    hunspellDicts.en_US
    # aspellDicts.de
    # aspellDicts.en

    super-productivity
    otpclient
  ];
}
