{ config, pkgs, lib, home-manager, ... }:
let kuelapconf = ./kuelap.sh;
in {
  imports = [ # Include the results of the hardware scan.
    home-manager.nixosModule
    (import ../config/btswitch/btswitch.nix)
    (import ./sound.nix)
    (import ./mediakeys.nix)
    (import ./packages.nix)
    (import ./kde.nix)
    (import ./fprint-laptop-service)
    #    (import ./kde.nix {
    #      config = config;
    #      pkgs = pkgs;
    #    })
    #    (import ./xwindows.nix)
    #    (import ./modules/autorandr-rs.nix)
  ];

  networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  boot.kernelParams = [ "nowatchdog" ];
  boot.loader.timeout = 1;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.plymouth = {
    enable = true;
    #    theme = "spinner";
    #    logo = ./milkyway.png;
  };

  services.auto-cpufreq.enable = true;
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true;

  services.fstrim.enable = true;
  services.irqbalance.enable = true;
  #  nix.settings.auto-optimise-store = true;

  # fingerprint reader
  services.fprintd.enable = true;
  services.fprint-laptop-lid.enable = false;

  services.gnome.gnome-keyring.enable = true;

  systemd.services.NetworkManager-wait-online.enable = false;

  networking.extraHosts = ''
    192.168.11.232  registry.devsrv.kuelap.io
    192.168.178.192 robert.my.to
  '';

  virtualisation.docker.enable = true;
  #  virtualisation.docker.extraOptions = "--insecure-registry 10.180.3.2:5111 ";
  #  virtualisation.docker.extraOptions =
  #    "--insecure-registry registry.devsrv.kuelap.io:80 ";
  virtualisation.docker.daemon.settings = {
    insecure-registries = [ "registry.devsrv.kuelap.io:80" "10.180.3.2:5111" ];
  };

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

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplipWithPlugin ];
  services.avahi.enable = true;

  #  shellInit = ''
  #    export GTK_PATH=$GTK_PATH:${pkgs.oxygen_gtk}/lib/gtk-2.0
  #    export GTK2_RC_FILES=$GTK2_RC_FILES:${pkgs.oxygen_gtk}/share/themes/oxygen-gtk/gtk-2.0/gtkrc
  #  '';

  #  environment.sessionVariables = { };

  nixpkgs.config.packageOverrides = pkgs: rec {
    ctlptl = pkgs.callPackage ./packages/ctlptl {
      buildGoModule = pkgs.buildGo117Module;
    };
    chromium = pkgs.chromium.override {
      commandLineArgs = [
        "--enable-features=VaapiVideoDecoder"
        "--use-gl=desktop"
        "--ignore-gpu-blocklist"
        "--enable-gpu-rasterization"
        "--enable-zero-copy"
      ];
    };
  };

  services.openssh.allowSFTP = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 8080 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.robert = {
    home.stateVersion = "22.05";
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
        getsha256 =
          "nix-prefetch-url --type sha256 --unpack $1"; # $1 link to tar.gz release archive in github
        termcopy =
          "kitty +kitten ssh $1"; # copy terminal info to remote server $1 = remote server
        switch = "sudo nixos-rebuild -v switch --flake /etc/nixos/mynixos";
        buildboot =
          "sudo nixos-rebuild -v boot --flake /etc/nixos/mynixos |& nom";
        update = "sudo /etc/nixos/mynixos/scripts/update";
        captiveportal =
          "xdg-open http://$(ip --oneline route get 1.1.1.1 | awk '{print $3}')";
        pwrestart = "systemctl --user restart pipewire-pulse.service";
      };
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "kubectl" "sudo" "systemd" "history" ];
        theme = "af-magic";
      };
      initExtra = ''
        source ~/gitlab/kuelap-connect/dev/kuelap.sh
        alias dngconvert="WINEPREFIX='$HOME/wine-dng' wine /home/robert/wine-dng/drive_c/Program\ Files/Adobe/Adobe\ DNG\ Converter/Adobe\ DNG\ Converter.exe ./"
        export LANGUAGE=en_US.UTF-8
        export LC_ALL=en_US.UTF-8
        export LANG=en_US.UTF-8
        export LC_CTYPE=en_US.UTF-8
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
    #    home.file.".xprofile".text = if (builtins.pathExists kuelapconf) then
    #      "${(builtins.readFile kuelapconf)}"
    #    else
    #      "";
    home.file.".config/plasma-workspace/env/local.sh".text = ''
      export LANGUAGE=en_US.UTF-8
      export LC_ALL=en_US.UTF-8
      export LANG=en_US.UTF-8
      export LC_CTYPE=en_US.UTF-
    '';
    #    home.file.".config/plasma-workspace/env/kuelapenv.sh".text =
    #      if (builtins.pathExists kuelapconf) then ''
    #        ${(builtins.readFile kuelapconf)}
    #      '' else
    #        "";

    home.sessionVariables = {
      #LS_COLORS="$LS_COLORS:'di=1;33:'"; # export LS_COLORS
    };

    programs.git = {
      enable = true;
      #      extraConfig = {
      #        credential.helper = "${
      #            pkgs.git.override { withLibsecret = true; }
      #          }/bin/git-credential-libsecret";
      #      };
    };
  };
}
