{ config, pkgs, nixpkgs, agenix, home-manager, ... }: {

  environment.sessionVariables.FLAKE = "${config.mynix.system_flake}";

  # After that you can refer to the system version of nixpkgs as <nixpkgs> even without any channels configured.
  # Also, legacy package stuff like the ability to do nix-shell -p netcat just works.
  nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
  environment =
    {
      etc = {
        "nix/channels/nixpkgs".source = nixpkgs;
        "nix/channels/home-manager".source = home-manager;
      };
    };

  boot.blacklistedKernelModules = [ "pcspkr" ];

  nix = {
    #    packages = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
    settings = {
      substituters =
        [ "https://nix-community.cachix.org" "https://cache.nixos.org/" ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      auto-optimise-store = true;
      # secret-key-files = /home/robert/cache-priv-key.pem;
    };
    # binaryCaches = [ "http://<server url>" ];
    # binaryCachePublicKeys = [ "<the cache's public key>" ];
  };

  networking.dhcpcd.wait = "background";
  # systemd.services.systemd-udev-settle.enable = false;

  services.openssh.enable = true;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  services.tzupdate.enable = true;
  services.localtimed.enable = true;
  services.automatic-timezoned.enable = true;
  # time.timeZone = "Europe/Berlin";
  # time.timeZone = "Atlantic/Madeira";
  #  time.timeZone = "Africa/Nairobi";
  #  time.timeZone = "Asia/Jakarta";
  #  time.timeZone = "Asia/Makassar";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" "de_DE.UTF-8/UTF-8" ];

  i18n.extraLocaleSettings = {
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

  users.defaultUserShell = pkgs.zsh;
  programs.zsh = { enable = true; };

  # Don't forget to set a password with ‘passwd’.
  users.users = {
    robert = {
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
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;
  environment.variables = {
    NIXPKGS_ALLOW_UNFREE = "1";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    agenix.packages.${config.mynix.system}.default
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
  ];
}
