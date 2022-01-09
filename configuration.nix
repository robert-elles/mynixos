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
in {
  imports = [
    (./hardware-configurations + "/${parameters.machine}.nix")
    (import (./machines + "/${parameters.machine}.nix") {
      config = config;
      pkgs = pkgs;
      unstable = unstable;
    })
    (import "${home-manager}/nixos")
  ];
  boot.blacklistedKernelModules = [ "pcspkr" ];

  networking.dhcpcd.wait = "background";
  systemd.services.systemd-udev-settle.enable = false;

  services.openssh.enable = true;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  time.timeZone = "Europe/Berlin";

  users.defaultUserShell = pkgs.zsh;
  programs.zsh = { enable = true; };

  # Don't forget to set a password with ‘passwd’.
  users.users = {
    robert = {
      isNormalUser = true;
      extraGroups = [ "wheel" "docker" "networkmanager" "video" "input" ];
    };
  };

  home-manager.users.robert = {
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
      };
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "kubectl" "sudo" ];
        theme = "af-magic";
      };
    };
  };

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
    git
    oh-my-zsh
    rsync
    ncdu
    bc
    zip
    unzip
    unrar
    mosh
    usbutils
    fdupes
    jdupes
  ];
}

