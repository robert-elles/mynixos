{ config, lib, pkgs, home-manager, ... }:

{
  # Simply install just the packages
  environment.packages = with pkgs; [
    procps
    killall
    diffutils
    findutils
    utillinux
    tzdata
    hostname
    man
    gnugrep
    gnupg
    gnused
    gnutar
    bzip2
    gzip
    xz
    zip
    unzip

    unixtools.ping
    openssh
    micro
    nano
    code-server
    devenv
    direnv
    rsync
    gnused
    git

    gnumake
    texlive.combined.scheme-full
    texmaker

  ];

  # users.defaultUserShell = pkgs.fish;
  # programs.fish.enable = true;
  user.shell = "${pkgs.fish}/bin/fish";

  time.timeZone = "Europe/Berlin";

  # or if you have a separate home.nix already present:
  home-manager = {
    config = ./home.nix;
    useGlobalPkgs = true;
    backupFileExtension = "hm-bak";
  };

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "24.05";

  # Set up nix for flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Set your time zone
  #time.timeZone = "Europe/Berlin";
}
