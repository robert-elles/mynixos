{ config, lib, pkgs, nixpkgs, inputs, settings, ... }: {

  imports = [
    inputs.agenix.nixosModules.default
    (import ./home.nix {
      inherit config pkgs lib inputs;
    })
  ];

  networking.hostName = settings.hostname; # Define your hostname.

  # After that you can refer to the system version of nixpkgs as <nixpkgs> even without any channels configured.
  # Also, legacy package stuff like the ability to do nix-shell -p netcat just works.
  nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
  environment =
    {
      etc = {
        "nix/channels/nixpkgs".source = nixpkgs;
        "nix/channels/home-manager".source = inputs.home-manager;
      };
    };

  security.sudo.wheelNeedsPassword = false;

  services.fwupd.enable = true;
  programs.light.enable = true; # screen and keyboard background lights
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.allowSFTP = true;
  services.eternal-terminal.enable = true;

  boot.blacklistedKernelModules = [ "pcspkr" ];

  boot.loader.systemd-boot.configurationLimit = 3;


  age.identityPaths = [ "/home/robert/.ssh/id_ed25519" ];
  age.secrets = {
    atuin_key = {
      file = ../secrets/agenix/atuin_key.age;
      owner = "robert";
    };
  };

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      # keep-outputs = true # keep the outputs of the derivations
      # keep-derivations = true # keep
    '';
    settings = {
      trusted-users = [ "root" "robert" ];
      substituters =
        [ "https://nix-community.cachix.org" "https://cache.nixos.org/" ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      auto-optimise-store = true;
      use-xdg-base-directories = true;
      # secret-key-files = /home/robert/cache-priv-key.pem;
    };
    # binaryCaches = [ "http://<server url>" ];
    # binaryCachePublicKeys = [ "<the cache's public key>" ];
  };

  networking.dhcpcd.wait = "background";
  # systemd.services.systemd-udev-settle.enable = false;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  # services.tzupdate.enable = true;
  services.localtimed.enable = true;
  services.automatic-timezoned.enable = true;
  # time.timeZone = "Europe/Berlin";
  # time.timeZone = "Atlantic/Madeira";
  #  time.timeZone = "Africa/Nairobi";
  #  time.timeZone = "Asia/Jakarta";
  #  time.timeZone = "Asia/Makassar";

  i18n.defaultLocale = "de_DE.UTF-8";

  # Select internationalisation properties.
  i18n.extraLocales = [ "en_US.UTF-8/UTF-8" "de_DE.UTF-8/UTF-8" ];

  i18n.extraLocaleSettings = {
    # LANGUAGE = "en_US:en";
    LC_ALL = "en_US.UTF-8";
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  users.defaultUserShell = pkgs.fish;
  # programs.zsh.enable = true;
  programs.fish.enable = true;

  # Don't forget to set a password with ‘passwd’.
  users.users = {
    robert = {
      uid = 1000;
      isNormalUser = true;
      description = "Robert Elles";
      extraGroups = [
        "wheel"
        "docker"
        "networkmanager"
        "video"
        "input"
        "btaudio"
        "pipewire"
        "realtime"
        "audio"
        "kvm"
      ];
    };
  };

  environment.sessionVariables = rec
  {
    FLAKE = "${settings.system_repo_root}/machines/${settings.hostname}";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";

    GTK_THEME = "Adwaita"; # fix for libreoffice

    # Not officially in the specification
    XDG_BIN_HOME = "$HOME/.local/bin";
    PATH = [
      "${XDG_BIN_HOME}"
    ];

    XCOMPOSECACHE = "${XDG_CACHE_HOME}/X11/xcompose";
    GTK2_RC_FILES = "${XDG_CONFIG_HOME}/gtk-2.0/gtkrc";
    IPYTHONDIR = "${XDG_CONFIG_HOME}/ipython";
    ANDROID_USER_HOME = "${XDG_DATA_HOME}/android";
    HISTFILE = "${XDG_STATE_HOME}/bash/history";
    CUDA_CACHE_PATH = "${XDG_CACHE_HOME}/nv";
    PYTHONSTARTUP = "${XDG_CONFIG_HOME}/python/pythonrc";
    ERRFILE = "${XDG_CACHE_HOME}/X11/xsession-errors";
    GNUPGHOME = "${XDG_DATA_HOME}/gnupg";
    ZDOTDIR = "${XDG_CONFIG_HOME}/zsh";
    WINEPREFIX = "${XDG_DATA_HOME}/wine";
    DOCKER_CONFIG = "${XDG_CONFIG_HOME}/docker";
  };

  nixpkgs.config.allowUnfree = true;
  environment.variables = {
    NIXPKGS_ALLOW_UNFREE = "1";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    fishPlugins.done
    # fishPlugins.fzf-fish
    # fishPlugins.forgit
    # fishPlugins.hydro
    # fzf
    fishPlugins.grc
    fishPlugins.z
    fishPlugins.colored-man-pages
    fishPlugins.sponge
    grc
    inputs.agenix.packages.${settings.system}.default
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    bind
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
    git
    oh-my-zsh
    rsync
    ncdu
    bc
    jq
    zip
    unzip
    unrar
    mosh
    eternal-terminal # replacement for mosh with scroll support
    eza # modern replacement for ls
    usbutils
    lsof
    fdupes
    jdupes
    iotop
    iotop-c
    kitty
    nix-output-monitor
    nvd # nixos upgrade diff tool
    ripgrep
    gdb
    reptyr
    ethtool
    bmon # network traffic monitoring
    tzupdate
    fd
    pciutils
    lshw
    git-crypt
    gnupg
    lm_sensors # run sudo sensors-detect
    pkgs.home-manager
    gnumake
    nix-tree
    p7zip
    sysdig
    binutils
    ranger
    nixos-facter
  ];
}
