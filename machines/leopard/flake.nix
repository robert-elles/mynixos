{
  description = "Robert's NixOs flake configuration";
  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/2cef7a0b9c6231d75dd3f4258c3af29eb5393ae6";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs_mastger.url = "github:NixOS/nixpkgs/master";
    nixpkgs_pin_virtualbox.url =
      "github:nixos/nixpkgs/0182a361324364ae3f436a63005877674cf45efb";
    nixpkgs_pin.url =
      "github:nixos/nixpkgs/e4bae1bd10c9c57b2cf517953ab70060a828ee6f";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    flake-utils.url = "github:numtide/flake-utils";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # impermanence = {
    #   url = "github:nix-community/impermanence";
    # };
    betterfox = {
      url = "github:HeitorAugustoLN/betterfox-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tuxedo-nixos.url = "github:sund3RRR/tuxedo-nixos";
    mynixosp.url =
      "git+ssh://git@github.com/robert-elles/mynixos-private?ref=main";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      hostname = "leopard";
      system = "x86_64-linux";
      system_repo_root = "/home/robert/Nextcloud/code/mynixos";

      parameters = builtins.fromJSON (builtins.readFile
        (system_repo_root + "/secrets/gitcrypt/params.json"));

      settings = {
        inherit system system_repo_root hostname;
        synced_config = "/home/robert/Nextcloud/Config";
        public_hostname = parameters.public_hostname;
        public_hostname2 = parameters.public_hostname2;
        email = parameters.email;
        email2 = parameters.email2;
        server_ip = "192.168.178.38";
      };

      pkgs = nixpkgs.legacyPackages.${system}.applyPatches {
        name = "nixpkgs-patched";
        src = nixpkgs;
        patches = [
          # ../../patches/441841.patch
        ];
      };

      pkgs-pin-virtualbox = import inputs.nixpkgs_pin_virtualbox {
        inherit system;
        config.allowUnfree = true;
      };

      pkgs-pin = import inputs.nixpkgs_pin {
        inherit system;
        config.allowUnfree = true;
      };

      nixosSystem = import (pkgs + "/nixos/lib/eval-config.nix");

      modules = [
        (inputs.mynixosp.nixosModules.${system}.default)
        # inputs.impermanence.nixosModules.impermanence
        inputs.chaotic.nixosModules.default
        inputs.tuxedo-nixos.nixosModules.default
        inputs.nixos-facter-modules.nixosModules.facter
        { config.facter.reportPath = ./facter.json; }
        inputs.home-manager.nixosModules.home-manager
        ({ pkgs, lib, config, ... }: {

          nixpkgs = let cuda = true;
          in {
            config = {
              allowUnfree = true;
              cudaSupport = cuda;
              cudnnSupport = cuda;
            };
            overlays = [
              inputs.chaotic.overlays.default
              inputs.nur.overlays.default
              (self: super: {
                ctranslate2 = super.ctranslate2.override {
                  withCUDA = cuda;
                  withCuDNN = cuda;
                };
              })
            ];
          };

          systemd.network.wait-online.enable = false;

          environment.systemPackages = [
            pkgs.coolercontrol.coolercontrol-gui
            pkgs.liquidctl
            pkgs.docker-compose
            pkgs.firefox
            pkgs.yt-dlp
            pkgs.yazi
            pkgs.ddrescue
            pkgs.immich-cli
            pkgs.distrobox
            pkgs.devenv
            pkgs.pulseaudioFull
            pkgs.adwaita-icon-theme
            pkgs.hermit
            pkgs.source-code-pro
          ];

          hardware.tuxedo-control-center.enable = true;

          nix.settings = {
            substituters = [ "https://cuda-maintainers.cachix.org" ];
            trusted-public-keys = [
              "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
            ];
          };

          hardware.new-lg4ff.enable = true;

          services.mongodb = {
            enable = false;
            enableAuth = false;
            # bind_ip = "0.0.0.0";
          };

          networking.firewall = { enable = false; };

          networking.extraHosts = ''
            ${settings.server_ip} ${settings.hostname}
          '';

          services.xrdp = {
            enable = true;
            defaultWindowManager = "startplasma-x11";
          };

          services.sunshine = {
            enable = true;
            autoStart = true;
            capSysAdmin = true;
            openFirewall = true;
          };

          services.displayManager.autoLogin = {
            enable = true;
            user = "robert";
          };

          programs.steam.enable = true;

          # === Server config (ported from falcon) ===

          # Disable suspend (override hardware.nix)
          services.autosuspend.enable = false;
          systemd.sleep.extraConfig = lib.mkForce ''
            AllowSuspend=no
            AllowHibernation=no
            AllowHybridSleep=no
            AllowSuspendThenHibernate=no
          '';
          services.logind.settings.Login.HandleLidSwitch = "lock";
          services.logind.settings.Login.HandleLidSwitchExternalPower = "lock";
          services.logind.settings.Login.HandleLidSwitchDocked = "lock";

          # Docker TCP listener + logging
          virtualisation.docker = {
            enable = true;
            listenOptions =
              [ "/run/docker.sock" "tcp://${settings.hostname}:2375" ];
          };
          virtualisation.docker.daemon.settings = { log-opt = "max-size=50m"; };

          # Maintenance mode target
          systemd.targets.maintenance-network = {
            description = "Maintenance Mode with Networking and SSH";
            requires = [
              "maintenance.target"
              "systemd-networkd.service"
              "sshd.service"
            ];
            after = [
              "maintenance.target"
              "systemd-networkd.service"
              "sshd.service"
            ];
            unitConfig.AllowIsolate = true;
          };

          # Nextcloud user/group (needed by nextcloud + other services)
          users.groups.nextcloud = { };
          users.users.nextcloud = {
            home = "/var/lib/nextcloud";
            group = "nextcloud";
            isSystemUser = true;
          };

          users.users."robert".linger = true;

          # services.xserver.serverFlagSection = {
          #   "BlankTime" = "2";
          #   "StandbyTime" = "2";
          #   "SuspendTime" = "3";
          #   "OffTime" = "3";
          # };

          # === Config from laptop.nix (not covered by sub-imports) ===

          boot.kernel.sysctl."fs.inotify.max_user_watches" = 10485760;
          boot.kernelPackages = pkgs.linuxPackages_cachyos;

          services.ananicy.enable = false;
          services.ananicy.package = pkgs.ananicy-cpp;
          services.ananicy.rulesProvider = pkgs.ananicy-rules-cachyos_git;
          services.ananicy.extraRules = [{
            name = "baloo_file_extractor";
            nice = 19;
            latency_nice = 19;
            sched = "idle";
          }];

          boot.initrd.systemd.enable = true;
          boot.kernelParams = [ "quiet" ];

          services.gvfs.enable = true;
          services.tumbler.enable = true;
          services.fstrim.enable = true;
          services.irqbalance.enable = true;

          users.users.robert.extraGroups = [ "adbusers" ];

          systemd.services.NetworkManager-wait-online.enable = false;

          # VirtualBox (disabled)
          virtualisation.virtualbox.host.enable = false;
          virtualisation.virtualbox.host.enableExtensionPack = true;
          virtualisation.virtualbox.host.package =
            pkgs-pin-virtualbox.virtualbox;
          users.extraGroups.vboxusers.members = [ "robert" ];

          fonts.packages = with pkgs; [ hermit source-code-pro ];

          programs.npm = let cfg = config.environment.sessionVariables;
          in {
            enable = true;
            npmrc = ''
              prefix=${pkgs.nodejs}/lib/node_modules
              cache=${cfg.XDG_CACHE_HOME}/npm
              init-module=${cfg.XDG_CONFIG_HOME}/npm/config/npm-init.js
              tmp=${cfg.XDG_CACHE_HOME}/npm/tmp
            '';
          };

          services.geoclue2.enable = true;
          location.provider = "geoclue2";

          services.printing.enable = true;
          services.printing.drivers = [ pkgs.hplip ];
          services.avahi.enable = true;

          programs.dconf.enable = true;
          services.gnome.gnome-settings-daemon.enable = true;

          programs.chromium.enable = true;
          programs.chromium.extensions = [
            "niloccemoadcdkdjlinkgdfekeahmflj" # pocket
            "edibdbjcniadpccecjdfdjjppcpchdlm" # I still don't care about cookies
            "dhdgffkkebhmkfjojejmpbldmpobfkfo" # Tampermonkey
            "lcbjdhceifofjlpecfpeimnnphbcjgnc" # XBrowserSync
          ];

          programs.nix-ld.enable = true;
          programs.nix-ld.libraries = with pkgs; [
            stdenv.cc.cc
            zlib
            fuse3
            alsa-lib
            at-spi2-atk
            at-spi2-core
            atk
            cairo
            cups
            curl
            dbus
            expat
            fontconfig
            freetype
            gdk-pixbuf
            glib
            gtk3
            libGL
            libappindicator-gtk3
            libdrm
            libnotify
            libpulseaudio
            libuuid
            libxcb
            libxkbcommon
            mesa
            nspr
            nss
            pango
            pipewire
            systemd
            icu
            openssl
            libXScrnSaver
            libXcomposite
            libXcursor
            libXdamage
            libXext
            libXfixes
            libXi
            libXrandr
            libXrender
            libXtst
            libxkbfile
            libxshmfence
            zlib
          ];

          xdg.mime.enable = true;
          xdg.mime.defaultApplications = let browser = "firefox.desktop";
          in {
            "text/html" = browser;
            "image/jpeg" = "feh -F";
            "x-scheme-handler/http" = browser;
            "x-scheme-handler/https" = browser;
            "x-scheme-handler/about" = browser;
            "x-scheme-handler/unknown" = browser;
          };
        })
        # Sub-modules from laptop.nix
        (../../nixconfig/sound.nix)
        (../../nixconfig/packages.nix)
        (../../nixconfig/kde.nix)
        (../../nixconfig/powersave.nix)
        (../../nixconfig/home-gui.nix)
        (../../nixconfig/hooks.nix)
        # Common modules
        (../../nixconfig/home.nix)
        (../../nixconfig/common.nix)
        (../../nixconfig/system.nix)
        # (../../nixconfig/dotfiles.nix)
        (../../nixconfig/hosts-blacklist)
        (../../nixconfig/pyenv.nix)
        (./hardware.nix)

        # Server modules
        ../../nixconfig/server/immich.nix
        ../../nixconfig/server/dns.nix
        ../../nixconfig/server/disks.nix
        ../../nixconfig/server/agenix.nix
        ../../nixconfig/server/dyndns.nix
        ../../nixconfig/server/postgres.nix
        ../../nixconfig/server/acmeproxy.nix
        ../../nixconfig/server/nextcloud.nix
        ../../nixconfig/server/nfs.nix
        ../../nixconfig/server/samba.nix
        ../../nixconfig/server/services.nix
        ../../nixconfig/server/paperless.nix
        ../../nixconfig/server/audiobookshelf.nix
        ../../nixconfig/server/calibre-web.nix
        ../../nixconfig/server/vikunja.nix
        # ../../nixconfig/server/elastic.nix
        ../../nixconfig/server/soundserver.nix
        ../../nixconfig/server/music.nix
        ../../nixconfig/server/wallabag.nix
        ../../nixconfig/server/mealie.nix
        ../../nixconfig/server/freshrss.nix
        ../../nixconfig/server/vogesen.nix
      ];
    in {
      nixosConfigurations = {
        ${hostname} = nixosSystem {
          inherit system modules;
          specialArgs = {
            inherit inputs nixpkgs settings pkgs-pin-virtualbox pkgs-pin;
          };
        };
      };
    };
}
