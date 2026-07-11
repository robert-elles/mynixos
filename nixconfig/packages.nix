{ pkgs, pkgs-pin, ... }:
{
  nixpkgs.overlays = [
    (self: super: {
      compact_pager = self.callPackage ./packages/compact_pager { };
      sonar = self.callPackage ./packages/sonar { };
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

    })
  ];

  programs.java.enable = true;
  # programs.java.package = pkgs.jdk19;

  programs.noisetorch.enable = true;

  environment.defaultPackages = with pkgs; [ keepassxc ];

  environment.systemPackages = with pkgs; [
    uv
    nixpkgs-fmt
    nix-tree
    nix-sweep
    comma # run nix programms without installing
    nix-du
    vlang
    sshfs
    ntfs3g
    inetutils
    wireguard-tools
    # protonvpn-gui
    # protonvpn-cli
    inotify-tools
    xarchiver
    p7zip
    file-roller
    # cbatticon
    gitFull
    # mariadb
    miniserve
    # youtube-dl # out of date
    yt-dlp
    libcamera
    yelp # see the documentation in easyeffects
    seahorse # view the keyring store
    # gramps # family tree stammbau
    # Foto
    imagemagick
    exiftool
    libraw
    pinta
    geeqie
    # rapid-photo-downloader
    exiv2
    feh

    # rawtherapee
    # gthumb
    # pinta
    # shotwell
    # nomacs
    # hugin
    # handbrake # video transcoder
    # openshot-qt # video editor
    mediainfo
    ffmpeg-full

    # gpu
    vdpauinfo # display video decode capabilities of the system

    portfolio # investment performance

    ranger
    yazi # fast terminal file manager
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
    gnome-sound-recorder
    audacity
    songrec
    alsa-utils

    nmap
    mpv
    gnome-clocks
    openvpn

    hydra-check
    #    typora # markdown editor
    xev
    brightnessctl
    # apostrophe # markdown editor
    #    wine
    winetricks
    # wineWowPackages.stable
    # bottles
    # protonup-qt # wine proton installer
    # lutris # game launcher
    # heroic # epic game store
    # ludusavi # backup game saves
    gnome-screenshot
    libsecret
    gnome-keyring
    libgnome-keyring
    xbacklight
    # steam-run # run non-nixos compatible binaries

    protonup-qt
    maven
    gradle
    docker
    docker-compose
    dive # explore docker image layers's contents
    direnv
    devenv # also see devshell
    gh # github cli
    git
    # zeal # offline api documentation browser
    bintools # for the strings command
    pkgs-pin.android-studio
    zed-editor
    repomix # pack multiple file into one for AI consumption
    sonar # display services listening on ports

    dbeaver-bin
    libva-utils
    # joplin # cli client
    joplin-desktop
    # planify # todo list
    chromium
    vlc
    # spotify
    # spotifywm # set correct class name for spotify
    # shortwave # radio
    transmission_4-gtk
    btfs # bittorrent filesystem
    # blueberry
    # (jetbrains.idea-ultimate.override { jdk = pkgs.jetbrains.jdk; })
    # jetbrains.idea-community
    # jetbrains.pycharm-community
    nextcloud-client
    # captive-browser
    # libreoffice-fresh
    libreoffice-fresh
    evince
    gedit
    # notepadqq
    multipath-tools # kpartx -av some_image.img creates device files that can be mounted
    # chiaki # playstation remote play
    # tdrop # drop down terminal
    anki
    hwinfo

    filezilla
    ghostscript
    libtiff
    calibre
    foliate # ebook reader
    # kstars
    tor-browser
    signal-desktop
    gnome-frog # ocr (text extraction) tool
    mixxx # dj software
    darktable
    # kdePackages.kdenlive
    # digikam
    immich-cli
    immich-go
    # jamesdsp
    # spotdl # spotify downloader
    remmina # rdp client
    convmv # fix file name encoding
    android-tools # adb
    # node nix package development
    nodejs
    prefetch-npm-deps # compute npm package hashes
    prettier

    # android
    # scrcpy # android dev remote control

    # boot.kernelPackages = pkgs.linuxPackages_latest;
    # linuxKernel.packages.linux_latest_libre.cpupower
    # config.boot.kernelPackages.cpupower

    # pdfsam-basic
    # pdfarranger
    # scribus

    # minecraft
    # prismlauncher # minecraft

    # spell checking:
    hunspell
    hunspellDicts.de_DE
    hunspellDicts.en_US
    # aspellDicts.de
    # aspellDicts.en

    otpclient # one time passwort client

    # Android
    gnirehtet # reverse tethering over adb
    scrcpy
    qtscrcpy
    deskreen # Turn any device into a secondary screen for your computer

    # docker
    nixpacks # App source + Nix packages + Docker = Image Resources

    remmina # remote desktop client
    # yaak # api client
    bruno # api client
    # hurl # api client:
    evince # gnome document viewer
    xdg-ninja

    # webcam
    webcamoid
    camset # GUI for Video4Linux adjustments of webcams
    nfs-utils

    # debootstrap
    # toolbox
    distrobox
    ddrescue
    qmapshack # mapping software
    claude-code
    opencode
  ];
}
