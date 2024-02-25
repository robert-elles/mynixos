{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (self: super: {
      ferdium = super.ferdium.overrideAttrs (old: rec {
        version = "6.7.0";
        src = super.fetchurl {
          url = "https://github.com/ferdium/ferdium-app/releases/download/v${version}/Ferdium-linux-${version}-amd64.deb";
          sha256 = "sha256-X1wGrxwENEXKhJkY8cg0iFVJTnJzWDs/4jsluq01sZM=";
        };
      });
      joplin-desktop = super.joplin-desktop.overrideAttrs (old: rec {
        version = "2.13.11";
        # src.sha256.x86_64-linux = "";
        suffix = ".AppImage";
        src = super.fetchurl {
          url = "https://github.com/laurent22/joplin/releases/download/v${version}/Joplin-${version}${suffix}";
          sha256 = "sha256-YkNtvgPAYD7Rw72QoMHqRN24K1RB1GR8W9ka8wCUA8w=";
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
    # protonvpn-gui
    # protonvpn-cli
    arc-theme # gtk theme
    lxappearance # set gtk themes
    kde-gtk-config # should set kde themes
    xarchiver
    gnome.file-roller
    # cbatticon
    gitAndTools.gitFull
    # mariadb
    miniserve
    youtube-dl
    libcamera
    gnome.yelp # see the documentation in easyeffects
    gnome.seahorse # view the keyring store
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
    geeqie
    # rapid-photo-downloader
    exiv2
    feh
    # rawtherapee
    # pinta
    # shotwell
    # nomacs
    # hugin
    handbrake # video transcoder
    openshot-qt # video editor
    libsForQt5.kdenlive # kde video editor

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
    # bottles
    gnome.gnome-screenshot
    libsecret
    gnome.gnome-keyring
    gnome.libgnome-keyring
    xorg.xbacklight
    # steam-run # run non-nixos compatible binaries
    maven
    gradle
    docker
    docker-compose
    dive # explore docker image layers's contents
    pipenv
    #    vscode
    direnv
    gh # github cli
    git
    # zeal # offline api documentation browser
    poetry
    bintools # for the strings command

    dbeaver
    vulkan-tools
    vulkan-loader
    vulkan-headers
    vulkan-validation-layers
    libva-utils
    arandr
    plasma-pa
    firefox
    joplin # cli client
    joplin-desktop
    chromium
    # zoom-us
    vlc
    spotify
    # shortwave # radio
    transmission-gtk
    pirate-get
    # blueberry 
    # (jetbrains.idea-ultimate.override { jdk = pkgs.jetbrains.jdk; })
    #    vscode.fhs
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
    anki-bin
    ffmpeg
    hwinfo
    corectrl

    calibre
    foliate # ebook reader
    # kstars
    tor-browser-bundle-bin
    signal-desktop
    gnome-frog # ocr (text extraction) tool
    mixxx # dj software
    spotdl # spotify downloader
    remmina # rdp client
    ferdium # multi messenger
    dfeet # dbus viewer d-feet
    convmv # fix file name encoding
    android-tools

    # node nix package development
    node2nix
    prefetch-npm-deps
    nodejs
    nodePackages.prettier

    # android
    # scrcpy # android dev remote control
    # android-studio

    linuxKernel.packages.linux_latest_libre.cpupower
    # protonup-qt # wine proton installer
    # lutris # game launcher
    # heroic # epic game store

    pdfsam-basic
    pdfarranger

    # spell checking:
    hunspell
    hunspellDicts.de_DE
    hunspellDicts.en_US
    # aspellDicts.de
    # aspellDicts.en
  ];
}
