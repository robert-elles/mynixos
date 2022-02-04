{ config, pkgs, lib, unstable, ... }:
let kuelapconf = ../kuelap.conf;
in {
  imports = [ # Include the results of the hardware scan.
    (import ../config/btswitch/btswitch.nix)
    (import ../nixconfig/sound.nix)
    (import ../nixconfig/mediakeys.nix)
    (import ../nixconfig/xwindows.nix)
    #    (import ../nixconfig/modules/autorandr-rs.nix)
  ];

  networking.hostName = "panther";

  boot.loader.timeout = 1;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.plymouth = {
    enable = true;
    theme = "spinner";
    #    logo = ./milkyway.png;
  };

  services.auto-cpufreq.enable = true;
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true;

  systemd.services.NetworkManager-wait-online.enable = false;

  networking.extraHosts = let
    hostsPath =
      "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
    hostsFile = builtins.fetchurl hostsPath;
  in builtins.readFile "${hostsFile}";

  programs.light.enable = true; # screen and keyboard background lights

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.networkmanager.enable = true;

  services.fwupd.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  fonts.fonts = with pkgs; [ hermit source-code-pro ];

  virtualisation.docker.enable = true;

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

  #  shellInit = ''
  #    export GTK_PATH=$GTK_PATH:${pkgs.oxygen_gtk}/lib/gtk-2.0
  #    export GTK2_RC_FILES=$GTK2_RC_FILES:${pkgs.oxygen_gtk}/share/themes/oxygen-gtk/gtk-2.0/gtkrc
  #  '';

  #  environment.sessionVariables = { };

  #  config.home.packages = [
  #    # Mostly for the man files.
  #    pkgs.autorandr-rs
  #  ];
  #
  #  services.autorandr-rs = {
  #    enable = true;
  #    config = ../config/monitors.toml;
  #  };

  environment.defaultPackages = with pkgs; [ keepassxc ];

  environment.systemPackages = with pkgs; [
    nixfmt
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
    # Foto
    exiftool
    mariadb
    libraw
    digikam
    darktable
    geeqie

    ranger
    handlr # set default applications
    gparted
    polkit_gnome # polkit authentication agent
    feh

    # Audio
    pamixer
    pulseaudio # needed for pactl
    easyeffects
    pavucontrol
    playerctl
    audio-recorder

    nmap
    mpv
    gnome.gnome-clocks
    rxvt-unicode
    kitty
    dunst
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
    jdk11
    steam-run # run non-nixos compatible binaries
    nodejs-14_x
    maven
    gradle
    docker
    docker-compose
    pipenv
    python38Packages.pip
    python39Full
    vscode
    k3d
    pinta
    postman
    google-cloud-sdk
    kubectl
    kustomize
    dbeaver
    anki
    vulkan-tools
    vulkan-loader
    vulkan-headers
    vulkan-validation-layers
    mr
    libva-utils
    vdpauinfo
    radeontop
    arandr
    autorandr
    plasma-pa
    firefox
    joplin-desktop
    chromium
    #    unstable.chromium
    zoom-us
    vlc
    spotify
    transmission-gtk
    blueberry
    #    jetbrains.jdk
    #    jetbrains.idea-ultimate
    (jetbrains.idea-ultimate.override { jdk = pkgs.jetbrains.jdk; })
    nextcloud-client
    networkmanagerapplet
    libreoffice-fresh
    evince
    gnome.gedit
    multipath-tools # kpartx -av some_image.img creates device files that can be mounted
    chiaki
    #     networkmanager_dmenu
  ];

  # tilt overlay for latest version
  nixpkgs.overlays = [
    (self: super: {
      tilt = (super.tilt.override {
        buildGoModule = pkgs.buildGo117Module;
      }).overrideAttrs (old: rec {
        version = "0.23.9";
        src = super.fetchFromGitHub {
          owner = "tilt-dev";
          repo = "tilt";
          rev = "v${version}";
          #          sha256 = lib.fakeSha256;
          sha256 =
            "sha256:1j5rflc2gmndp1b7rfcdvd5111ipm3vdpf5qpl6ihn2bjwxr84xk";
        };
        ldflags = [ "-X main.version=${version}" ];
      });
    })
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  home-manager.users.robert = {
    # Here goes your home-manager config, eg home.packages = [ pkgs.foo ];
    # Here goes your home-manager config, eg home.packages = [ pkgs.foo ];
    programs.zsh = {
      enable = true;
      zplug = {
        enable = true;
        plugins = [
          { name = "zsh-users/zsh-autosuggestions"; }
          { name = "agkozak/zsh-z"; }
        ];
      };
      shellAliases = {
        ll = "ls -l";
        switch = "sudo nixos-rebuild switch";
        update = "sudo nixos-rebuild switch --upgrade";
      };
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "kubectl" "sudo" ];
        theme = "af-magic";
      };
      initExtra = ''
                source ~/gitlab/kuelap-connect/dev/kuelap.sh
        alias dngconvert="WINEPREFIX='$HOME/wine-dng' wine /home/robert/wine-dng/drive_c/Program\ Files/Adobe/Adobe\ DNG\ Converter/Adobe\ DNG\ Converter.exe ./"
              '';
    };

    home.file.".config/i3/config".source = ../config/i3/config;
    home.file.".config/i3status/config".source = ../config/i3status/config;
    home.file.".config/kitty/kitty.conf".source = ../config/kitty.conf;
    home.file.".config/gtk-3.0/settings.ini".source =
      ../config/gtk-3.0/settings.ini;
    home.file.".config/rofi".source = ../config/rofi;
    home.file.".config/dunst".source = ../config/dunst;
    home.file.".config/systemd/user/default.target.wants/redshift.service".source =
      ../config/redshift.service;
    home.file.".xprofile".text = if (builtins.pathExists kuelapconf) then
      "${(builtins.readFile kuelapconf)}"
    else
      "";

    home.sessionVariables = {
      #LS_COLORS="$LS_COLORS:'di=1;33:'"; # export LS_COLORS
    };

    programs.git = {
      enable = true;
      extraConfig = {
        credential.helper = "${
            pkgs.git.override { withLibsecret = true; }
          }/bin/git-credential-libsecret";
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
