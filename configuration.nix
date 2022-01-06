# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  parameters = import ./parameters.nix;
  home-manager = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/release-21.11.tar.gz";
  unstable = import (builtins.fetchTarball
    "https://github.com/nixos/nixpkgs/tarball/nixpkgs-unstable") {
      #    "https://github.com/nixos/nixpkgs/tarball/nixos-unstable") {
      #    "https://github.com/nixos/nixpkgs/tarball/master") {
      config = config.nixpkgs.config;
    };
  #  unstable = import <nixos-unstable> { };
in {
  imports = [ # Include the results of the hardware scan.
    (./hardware-configurations + "/${parameters.machine}.nix")
    (import (./machines + "/${parameters.machine}.nix"))
    (import "${home-manager}/nixos")
    (import ./config/btswitch/btswitch.nix)
    (import ./nixconfig/sound.nix)
    (import ./nixconfig/mediakeys.nix)
    (import ./nixconfig/xwindows.nix)
  ];

  boot.blacklistedKernelModules = [ "pcspkr" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;

  services.auto-cpufreq.enable = true;
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true;

  networking.dhcpcd.wait = "background";
  systemd.services.systemd-udev-settle.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;

  networking.extraHosts = let
    hostsPath =
      "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
    hostsFile = builtins.fetchurl hostsPath;
  in builtins.readFile "${hostsFile}";

  programs.light.enable = true;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  time.timeZone = "Europe/Berlin";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  #networking.interfaces.enp0s3.useDHCP = true;
  networking.networkmanager.enable = true;
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    # enableAutosuggestions = true;
    #enableSyntaxHighlighting = true;
    #ohMyZsh = {
    # enable = true;
    # plugins = [ "git" "python" "man" ];
    # theme = "robbyrussell";
    #};
  };

  services.fwupd.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  #  hardware.bluetooth.settings = {
  #    General = {
  #      Enable = "Source,Sink,Media,Socket";
  #    };
  #  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    robert = {
      isNormalUser = true;
      extraGroups = [ "wheel" "docker" "networkmanager" "video" "input" ];
    };
  };

  fonts.fonts = with pkgs; [ hermit source-code-pro ];

  virtualisation.docker.enable = true;

  services.geoclue2.enable = true;
  location.provider = "geoclue2";

  #  shellInit = ''
  #    export GTK_PATH=$GTK_PATH:${pkgs.oxygen_gtk}/lib/gtk-2.0
  #    export GTK2_RC_FILES=$GTK2_RC_FILES:${pkgs.oxygen_gtk}/share/themes/oxygen-gtk/gtk-2.0/gtkrc
  #  '';

  #  environment.shells = with pkgs; [ bashInteractive zsh ];

  environment.defaultPackages = with pkgs; [ keepassxc ];

  nixpkgs.config.allowUnfree = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    nano
    bash
    neofetch
    killall
    cryptsetup
    pstree
    perl
    curl
    htop
    zsh
    oh-my-zsh
    rsync
    ncdu
    bc
    zip
    unzip
    unrar
    mosh
    usbutils

    nixfmt
    networkmanager
    wireguard-tools
    rofi # Window switcher, run dialog and dmenu replacement
    #    rofi-calc
    #    rofi-vpn
    #    rofi-systemd
    arc-theme
    lxappearance
    kde-gtk-config
    xarchiver
    gnome.file-roller
    gitAndTools.gitFull
    # Foto
    exiftool
    mariadb
    libraw
    unstable.digikam
    darktable
    geeqie
    ranger
    handlr # set default applications
    fdupes
    jdupes

    gparted
    polkit_gnome # polkit authentication agent
    feh
    pamixer
    pulseaudio # needed for pactl
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
    #    (winetricks.override { wine = wineWowPackages.staging; })
    unstable.bottles
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
    easyeffects
    # Development
    tilt
    jdk11
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
    #    chromium
    unstable.chromium
    zoom-us
    vlc
    spotify
    transmission-gtk
    pavucontrol
    blueberry
    #    jetbrains.jdk
    #    jetbrains.idea-ultimate
    (jetbrains.idea-ultimate.override { jdk = pkgs.jetbrains.jdk; })
    nextcloud-client
    networkmanagerapplet
    libreoffice-fresh
    evince
    gnome.gedit
    chiaki
    #     networkmanager_dmenu
  ];

  # tilt overlay for latest version
  nixpkgs.overlays = [
    (self: super: {
      tilt = super.tilt.overrideAttrs (old: rec {
        version = "0.23.3";
        src = super.fetchFromGitHub {
          owner = "tilt-dev";
          repo = "tilt";
          rev = "v${version}";
          #          sha256 = lib.fakeSha256;
          sha256 =
            "sha256:1612yrlsajl1j95zh057k82nzz492a9p1cgamph4m84zpm0v67jc";
        };
        ldflags = [ "-X main.version=${version}" ];
      });
    })
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

  home-manager.users.robert = {
    # Here goes your home-manager config, eg home.packages = [ pkgs.foo ];
    programs.zsh = {
      enable = true;
      zplug = {
        enable = true;
        plugins = [
          { name = "zsh-users/zsh-autosuggestions"; }
          {
            name = "agkozak/zsh-z";
          }
          #           { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; } # Installations with additional options. For the list of options, please refer to Zplug README.
        ];
      };
      shellAliases = {
        ll = "ls -l";
        update = "sudo nixos-rebuild switch";
      };
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "kubectl" "sudo" ];
        theme = "af-magic";
        #	    theme = "pygmalion";
        #	    theme = "duellj";
        #	    theme = "bira";
      };
      initExtra = ''
                source ~/gitlab/kuelap-connect/dev/kuelap.sh
        alias dngconvert="WINEPREFIX='$HOME/wine-dng' wine /home/robert/wine-dng/drive_c/Program\ Files/Adobe/Adobe\ DNG\ Converter/Adobe\ DNG\ Converter.exe ./"
              '';
    };

    home.file.".config/i3/config".source = ./config/i3/config;
    home.file.".config/i3status/config".source = ./config/i3status/config;
    home.file.".config/kitty/kitty.conf".source = ./config/kitty.conf;
    home.file.".config/gtk-3.0/settings.ini".source =
      ./config/gtk-3.0/settings.ini;
    home.file.".config/rofi".source = ./config/rofi;
    home.file.".config/dunst".source = ./config/dunst;
    #    home.file = [{
    #      source = ./config/rofi;
    #      target = ".config/rofi";
    #      recursive = true;
    #    }];
    home.file.".config/systemd/user/default.target.wants/redshift.service".source =
      ./config/redshift.service;
    home.file.".xprofile".text = if (builtins.pathExists ./kuelap.conf) then
      "${(builtins.readFile ./kuelap.conf)}"
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
}

