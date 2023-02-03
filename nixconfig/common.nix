{ config, pkgs, lib, nixpkgs, ... }: {

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
    };
  };

  networking.dhcpcd.wait = "background";
  # systemd.services.systemd-udev-settle.enable = false;

  services.openssh.enable = true;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  services.tzupdate.enable = true;
  # time.timeZone = "Europe/Berlin";
  # time.timeZone = "Atlantic/Madeira";
  #  time.timeZone = "Africa/Nairobi";
  #  time.timeZone = "Asia/Jakarta";
  #  time.timeZone = "Asia/Makassar";

  users.defaultUserShell = pkgs.zsh;
  programs.zsh = { enable = true; };

  # Don't forget to set a password with ‘passwd’.
  users.users = {
    robert = {
      isNormalUser = true;
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
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
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
    zip
    unzip
    unrar
    mosh
    eternal-terminal # replacement for mosh with scroll support
    exa # modern replacement for ls
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
  ];
}
