{ config, pkgs, lib, home-manager, ... }: {
  imports = [
    (import ./home-manager.nix { inherit config pkgs lib home-manager; })
    (import ../config/btswitch/btswitch.nix)
    (import ./sound.nix)
    (import ./mediakeys.nix)
    (import ./packages.nix)
    (import ./kde.nix)
    (import ./fprint-laptop-service)
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

  programs.steam = {
    enable = true;
    remotePlay.openFirewall =
      true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall =
      true; # Open ports in the firewall for Source Dedicated Server
  };

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

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.allowSFTP = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 8080 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

}
