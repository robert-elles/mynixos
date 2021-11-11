# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  parameters = import ./parameters.nix;
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-21.05.tar.gz";
in
{
  imports =
    [ # Include the results of the hardware scan.
      (./hardware-configurations + "/${parameters.machine}.nix")
      (import (./machines + "/${parameters.machine}.nix"))
      (import "${home-manager}/nixos")
    ];

  boot.blacklistedKernelModules = [ "pcspkr" ];
  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  services.auto-cpufreq.enable = true;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s3.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system.
  #services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  #services.xserver.displayManager.gdm.enable = true;
  #services.xserver.desktopManager.gnome.enable = true;
  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";


  #programs.zsh.enable = true;
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

  environment.pathsToLink = [ "/libexec" ];

  services.xserver = {
    enable = true;

    desktopManager = {
#      default = "xfce";
      xterm.enable = false;
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };
   
    displayManager = {
        defaultSession = "xfce+i3";
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu #application launcher most people use
        i3status # gives you the default i3 status bar
        i3lock #default i3 screen locker
        i3blocks #if you are planning on using i3blocks over i3status
     ];

    };
  };


  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
   sound.enable = true;
   hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
   users.users.robert = {
     isNormalUser = true;
     extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
   };

  nixpkgs.config.allowUnfree = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
     wget
     curl
     git
     htop
     zsh
     oh-my-zsh
     ncdu
     bc
     zip
     unzip
     unrar
     feh
     mosh
     rxvt-unicode
     kitty
     auto-cpufreq
     xorg.xev
     xfce.xfce4-pulseaudio-plugin

     jdk11
     maven
     gradle
     nodePackages.npm
#     tilt
      docker
      docker-compose
      k3d
      postman
      google-cloud-sdk


#     home-manager

    arandr
    autorandr

     firefox
     chromium
     zoom-us
     vlc
     spotify
     transmission-gtk
     pavucontrol
     xfce.thunar
     xfce.thunar-archive-plugin
     blueberry
     jetbrains.idea-ultimate
     nextcloud-client
     networkmanagerapplet
     libreoffice-fresh
     evince
     gnome.gedit
     chiaki
#     networkmanager_dmenu
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
    /* Here goes your home-manager config, eg home.packages = [ pkgs.foo ]; */
   programs.zsh = {
     enable = true;
	  shellAliases = {
	    ll = "ls -l";
	    update = "sudo nixos-rebuild switch";
	  };
	  oh-my-zsh = {
	    enable = true;
	    plugins = [ "git" ];
	    theme = "af-magic";
#	    theme = "pygmalion";
#	    theme = "duellj";
#	    theme = "bira";
	  };
   };

    home.file.".config/i3/config".source = ./i3/config;
    home.file.".config/i3status/config".source = ./i3status/config;

    home.sessionVariables = {
        LS_COLORS="$LS_COLORS:'di=1;33:'"; # export LS_COLORS
      };


#   xsession.windowManager.i3 = {
#     config = rec {
#
##       keybindings = lib.mkOptionDefault {
##              "XF86AudioMute" = "exec amixer set Master toggle";
##              "XF86AudioLowerVolume" = "exec amixer set Master 4%-";
##              "XF86AudioRaiseVolume" = "exec amixer set Master 4%+";
##              "XF86MonBrightnessDown" = "exec brightnessctl set 4%-";
##              "XF86MonBrightnessUp" = "exec brightnessctl set 4%+";
##              "${modifier}+Return" = "exec ${pkgs.kitty}/bin/kitty";
##              "${modifier}+d" = "exec ${pkgs.rofi}/bin/rofi -modi drun -show drun";
##              "${modifier}+Shift+d" = "exec ${pkgs.rofi}/bin/rofi -show window";
##              "${modifier}+b" = "exec ${pkgs.brave}/bin/brave";
##              "${modifier}+Shift+x" = "exec systemctl suspend";
##            };
#
#      bars = [
#              {
#                position = "top";
##                statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${./i3status-rust.toml}";
#              }
#            ];
#     };
#   };
 };
}

