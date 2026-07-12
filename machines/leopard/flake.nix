{
  description = "Robert's NixOs flake configuration";
  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/2cef7a0b9c6231d75dd3f4258c3af29eb5393ae6";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
      # nixpkgs_mastger.url = "github:NixOS/nixpkgs/master";
      nixpkgs_pin_virtualbox.url = "github:nixos/nixpkgs/0182a361324364ae3f436a63005877674cf45efb";
      nixpkgs_pin.url = "github:nixos/nixpkgs/d407951447dcd00442e97087bf374aad70c04cea";
      nur = {
        url = "github:nix-community/NUR";
        inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable"; # always cached branch
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
    tuxedo-nixos.url = "github:robert-elles/tuxedo-nixos";
    # tuxedo-nixos.url = "github:sund3RRR/tuxedo-nixos/upgrade";
    mynixosp.url = "git+ssh://git@github.com/robert-elles/mynixos-private?ref=main";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      hostname = "leopard";
      system = "x86_64-linux";
      system_repo_root = "/home/robert/Nextcloud/code/mynixos";

      parameters = builtins.fromJSON (
        builtins.readFile (system_repo_root + "/secrets/gitcrypt/params.json")
      );

      settings = {
        inherit system system_repo_root hostname;
        synced_config = "/home/robert/Nextcloud/Config";
        public_hostname = parameters.public_hostname;
        public_hostname2 = parameters.public_hostname2;
        email = parameters.email;
        email2 = parameters.email2;
      };

      pkgs = nixpkgs.legacyPackages.${system}.applyPatches {
        name = "nixpkgs-patched";
        src = nixpkgs;
        patches = [
          # ../../patches/441841.patch
          ../../patches/gnugrep-skip-gnulib-tests-clang.patch
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
        (
          {
            pkgs,
            lib,
            config,
            ...
          }:
          {

            nixpkgs =
              let
                cuda = true;
              in
              {
                config = {
                  allowUnfree = true;
                    cudaSupport = cuda;
                    cudnnSupport = cuda;
                    problems.handlers.cups.broken = "warn";
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
              pkgs.source-code-pro # font
            ];

            # (Optional but recommended) Enable the scx schedulers optimized for CachyOS
            services.scx.enable = true;

            hardware.tuxedo-control-center.enable = true;

            hardware.new-lg4ff.enable = true;

            services.mongodb = {
              enable = false;
              enableAuth = false;
              # bind_ip = "0.0.0.0";
            };

            networking.firewall = {
              enable = false;
            };

            services.displayManager.autoLogin = {
              enable = true;
              user = "robert";
            };

            programs.steam.enable = true;
            programs.gamemode.enable = true;
            programs.steam.extraCompatPackages = with pkgs; [
              proton-ge-bin
            ];
            # programs.steam.package = pkgs.steam.override {
            #   extraPkgs =
            #     pkgs': with pkgs'; [
            #       bumblebee
            #       primus
            #     ];
            # };

            # === Server config (ported from falcon) ===

            # Disable suspend (override hardware.nix)
            services.autosuspend.enable = false;
            systemd.sleep.settings.Sleep = {
              AllowSuspend = "no";
              AllowHibernation = "no";
              AllowHybridSleep = "no";
              AllowSuspendThenHibernate = "no";
            };
            services.logind.settings.Login.HandleLidSwitch = "lock";
            services.logind.settings.Login.HandleLidSwitchExternalPower = "lock";
            services.logind.settings.Login.HandleLidSwitchDocked = "lock";

            # KDE's powerdevil intercepts lid-switch/idle events from logind and
            # acts on its own configured action instead, so the logind settings
            # above are only a fallback for when no Plasma session is running.
            # Powerdevil's default lid action is suspend, which would kill
            # Sunshine streaming. "turnOffScreen" was tried but it powers off
            # *all* KWin outputs, not just the internal panel -- that also
            # kills the HDMI-A-1 virtual output (see hardware.nix) and breaks
            # Sunshine capture ("Couldn't find monitor [0]"). Use "doNothing"
            # instead: the closed lid already physically hides the internal
            # panel, and this leaves HDMI-A-1 (and eDP-1's power state) alone.
            #
            # Separately from the lid action, powerdevil also has a default
            # idle-based "turn off display after N minutes of inactivity"
            # timer -- unrelated to the lid entirely. This one dropped
            # HDMI-A-1 out of Sunshine's active KMS output list after ~1h of
            # no local input, breaking capture ("Couldn't find monitor [0]")
            # even with the lid open. Disable it (and display dimming) so
            # outputs never idle-blank at all.
            # kscreenlocker has its own idle timer (~60min, independent of
            # powerdevil and the lid entirely) that auto-locks the session
            # and blanks outputs -- observed dropping HDMI-A-1 out of
            # Sunshine's active output list after a period of no local
            # input/network activity ("Couldn't find monitor [0]"), matching
            # the ~69min gap between a working stream and this failure.
            home-manager.users.robert.programs.plasma.kscreenlocker.autoLock = false;

            home-manager.users.robert.programs.plasma.powerdevil = {
              AC = {
                whenLaptopLidClosed = "doNothing";
                autoSuspend.action = "nothing";
                turnOffDisplay.idleTimeout = "never";
                dimDisplay.enable = false;
              };
              battery = {
                whenLaptopLidClosed = "doNothing";
                autoSuspend.action = "nothing";
                turnOffDisplay.idleTimeout = "never";
                dimDisplay.enable = false;
              };
            };

            # KWin separately (outside of powerdevil) remembers a per-lid-state
            # output layout in ~/.config/kwinoutputconfig.json and replays it on
            # every lid event -- it had previously saved "eDP-1 disabled" for the
            # lid-closed + HDMI-A-1-present combo, presumably from an earlier
            # docked/external-monitor session. With only HDMI-A-1 active,
            # Sunshine's KMS capture fails to initialize entirely ("Couldn't find
            # monitor [0]" / "Platform failed to initialize"), killing streaming.
            # An acpid hook that re-enabled eDP-1 a few times after each lid
            # event was tried first, but it races KWin's own disable action --
            # a connection attempt landing in that window still fails even
            # though the display self-heals moments later. Run a tight
            # continuous watcher instead so the disabled window is ~1s, not
            # multiple seconds, regardless of what triggers the disable.
            #
            # Also watch HDMI-A-1 (the actual Sunshine capture target, see
            # remotecontrol.nix) for the same reason: it was observed dropping
            # out of Sunshine's active KMS output list after an idle-timeout
            # display-off event (see powerdevil turnOffDisplay above), which
            # shifts monitor indices and breaks capture ("Couldn't find
            # monitor [0]") even though the lid was never closed. Disabling
            # the idle timer should prevent this at the source, but this
            # watcher stays as a cheap defense-in-depth backstop in case some
            # other path (KWin's own persisted config, a future powerdevil
            # regression, etc.) disables either output again.
            systemd.user.services.keep-outputs-enabled = {
              description = "Force-enable eDP-1/HDMI-A-1 whenever KWin disables them (breaks Sunshine capture)";
              wantedBy = [ "graphical-session.target" ];
              partOf = [ "graphical-session.target" ];
              serviceConfig = {
                # Use the stable /run/current-system symlink rather than a
                # ${pkgs...} store path baked in at build time -- a store path
                # for an old generation's kscreen build can get GC'd out from
                # under a long-running Restart=always service, which silently
                # crash-looped here for 13h without ever running the fix.
                ExecStart = "${pkgs.writeShellScript "keep-outputs-enabled" ''
                  while true; do
                    output=$(/run/current-system/sw/bin/kscreen-doctor -o)
                    for name in eDP-1 HDMI-A-1; do
                      if echo "$output" | grep -A1 "Output:.*$name" | grep -q disabled; then
                        /run/current-system/sw/bin/kscreen-doctor output."$name".enable
                      fi
                    done
                    sleep 1
                  done
                ''}";
                Restart = "always";
              };
            };

            # Docker TCP listener + logging
            virtualisation.docker = {
              enable = true;
              listenOptions = [
                "/run/docker.sock"
                "tcp://${settings.hostname}:2375"
              ];
            };
            virtualisation.docker.daemon.settings = {
              log-opt = "max-size=50m";
            };

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
            services.ananicy.extraRules = [
              {
                name = "baloo_file_extractor";
                nice = 19;
                latency_nice = 19;
                sched = "idle";
              }
            ];

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
            virtualisation.virtualbox.host.package = pkgs-pin-virtualbox.virtualbox;
            users.extraGroups.vboxusers.members = [ "robert" ];

            fonts.packages = with pkgs; [
              hermit
              source-code-pro
            ];

            programs.npm =
              let
                cfg = config.environment.sessionVariables;
              in
              {
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
            xdg.mime.defaultApplications =
              let
                browser = "firefox.desktop";
              in
              {
                "text/html" = browser;
                "image/jpeg" = "feh -F";
                "x-scheme-handler/http" = browser;
                "x-scheme-handler/https" = browser;
                "x-scheme-handler/about" = browser;
                "x-scheme-handler/unknown" = browser;
              };
          }
        )
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
        (../../nixconfig/pyenv.nix)
        (../../nixconfig/netbird.nix)
        (./hardware.nix)
        (../../nixconfig/server/mdns.nix)
        (../../nixconfig/server/remotecontrol.nix)

        # Server modules
        ../../nixconfig/server/immich.nix
        ../../nixconfig/server/dns.nix
        ../../nixconfig/server/disks.nix
        ../../nixconfig/server/agenix.nix
        ../../nixconfig/server/dyndns.nix
        ../../nixconfig/server/postgres.nix
        ../../nixconfig/server/acmeproxy.nix
        ../../nixconfig/server/nextcloud.nix
        # ../../nixconfig/server/nfs.nix
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
    in
    {
      nixosConfigurations = {
        ${hostname} = nixosSystem {
          inherit system modules;
          specialArgs = {
            inherit
              inputs
              nixpkgs
              settings
              pkgs-pin-virtualbox
              pkgs-pin
              ;
          };
        };
      };
    };
}
