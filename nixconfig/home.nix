{ pkgs, home-manager, ... }: {

  imports = [ home-manager.nixosModule ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.robert = {

      xdg.mimeApps = {
        enable = true;
        defaultApplications =
          let
            # browser = "chromium-browser.desktop";
            browser = "firefox.desktop";
          in
          {
            "image/jpeg" = [ "feh -F" ];
            "text/html" = [ browser ];
            "x-scheme-handler/http" = [ browser ];
            "x-scheme-handler/https" = [ browser ];
            "x-scheme-handler/about" = [ browser ];
            "x-scheme-handler/unknown" = [ browser ];
            "video/x-matroska" = [ "vlc" ];
            "video/mp4" = [ "vlc" ];
            "video/avi" = [ "vlc" ];
            "audio/wav" = [ "vlc" ];
            "audio/ogg" = [ "vlc" ];
            "audio/mp3" = [ "vlc" ];
          };
      };

      programs.direnv.enable = true;
      programs.direnv.nix-direnv.enable = true;
      programs.direnv.enableZshIntegration = true;

      services.gnome-keyring.enable = true;

      home.stateVersion = "22.05";
      programs.tmux.enable = true;
      programs.starship = {
        enable = true;
        enableZshIntegration = true;
        settings = { };
      };
      programs.zsh = {
        enable = true;
        plugins = [
          {
            name = "sd";
            src = pkgs.fetchFromGitHub {
              owner = "ianthehenry";
              repo = "sd";
              rev = "v1.1.0";
              sha256 = "sha256-X5RWCJQUqDnG2umcCk5KS6HQinTJVapBHp6szEmbc4U=";
            };
          }
        ];
        zplug = {
          enable = true;
          plugins = [
            { name = "zsh-users/zsh-autosuggestions"; }
            { name = "agkozak/zsh-z"; }
          ];
        };
        shellAliases =
          let
            rebuild = cmd: "nixos-rebuild ${cmd} --impure --flake $FLAKE |& nom";
            rebuild_cmd = cmd: "sudo sh -c '${rebuild cmd}'";
          in
          {
            ll = "ls -l";
            rpi4 = "et rpi4";
            getsha256 =
              "nix-prefetch-url --type sha256 --unpack $1"; # $1 link to tar.gz release archive in github
            termcopy =
              "kitty +kitten ssh $1"; # copy terminal info to remote server $1 = remote server
            rebuild = rebuild_cmd "$1";
            rebuildswitch = rebuild_cmd "switch";
            rebuildboot = rebuild_cmd "boot";
            rebuildtest = rebuild_cmd "test"; # also needs sudo to activate systemd services
            captiveportal =
              "xdg-open http://$(ip --oneline route get 1.1.1.1 | awk '{print $3}')";
            pwrestart = "systemctl --user restart pipewire-pulse.service";
            suspend = "systemctl suspend";
            journal_errors = "journalctl -p 3 -xb";
            reboot = "systemctl stop easyeffects --user && reboot";
            shutdown = "systemctl stop easyeffects --user && shutdown -h now";
          };
        oh-my-zsh = {
          enable = true;
          plugins = [
            # "git" # slow tab completion # https://github.com/bobthecow/git-flow-completion/wiki/Update-Zsh-git-completion-module
            "kubectl"
            "sudo"
            "systemd"
            "history"
          ];
          theme = "af-magic";
        };
        initExtra = ''
          alias dngconvert="WINEPREFIX='$HOME/wine-dng' wine /home/robert/wine-dng/drive_c/Program\ Files/Adobe/Adobe\ DNG\ Converter/Adobe\ DNG\ Converter.exe ./"
          export LANGUAGE=en_US.UTF-8
          export LC_ALL=en_US.UTF-8
          export LANG=en_US.UTF-8
          export LC_CTYPE=en_US.UTF-8
        '';
      };

      home.file.".config/plasma-workspace/env/local.sh".text = ''
        export LANGUAGE=en_US.UTF-8
        export LC_ALL=en_US.UTF-8
        export LANG=en_US.UTF-8
        export LC_CTYPE=en_US.UTF-
      '';

      home.file.".local/share/applications/p2nix.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=p2nix
        Exec=code ~/code/poetry2nix
        Icon=vscode
      '';

      home.file.".local/share/applications/mynixos.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=MyNixOS
        Exec=code ~/code/mynixos
        Icon=vscode
      '';

      home.file.".local/share/applications/nipkgs.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=NixPkgs
        Exec=code ~/code/nixpkgs
        Icon=vscode
      '';

      home.file.".local/share/applications/lebenslauf.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Lebenslauf
        Exec=code ~/Documents/Bewerbung/Lebenslauf_latex
        Icon=vscode
      '';

      home.file.".local/share/applications/JDownloader.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=JDownloader
        Exec=java -jar /home/robert/Downloads/jdownloader/JDownloader.jar
        Icon=/home/robert/Downloads/jdownloader/themes/standard/org/jdownloader/images/logo/logo-128x128.png
      '';

      home.file.".local/share/applications/Kuelap.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Kuelap
        Exec=code ~/gitlab/kuelap-connect
        Icon=vscode
      '';

      home.sessionVariables = {
        #LS_COLORS="$LS_COLORS:'di=1;33:'"; # export LS_COLORS
      };

      programs.git = {
        enable = true;
        aliases = {
          add-commit = "!git add -A && git commit";
        };
        # delta.enable = true;
        diff-so-fancy.enable = true;
        userEmail = "elles.robert@gmail.com";
        userName = "Robert Elles";
      };
      programs.lazygit.enable = true;

      # home.file.".config/pipewire/filter-chain.conf.d/sink-virtual-surround-7.1-hesuvi.conf" = builtins.readFile ../dotfiles/pipewire/filter-chain.conf.d/sink-virtual-surround-7.1-hesuvi.conf;
      home.file.".config/pipewire/filter-chain.conf.d/sink-virtual-surround-7.1-hesuvi.conf".text = ''
              # Convolver sink
        #
        # Copy this file into a conf.d/ directory such as
        # ~/.config/pipewire/filter-chain.conf.d/
        #
        context.modules = [
            { name = libpipewire-module-filter-chain
                args = {
                    node.description = "Virtual Surround Sink"
                    media.name       = "Virtual Surround Sink"
                    filter.graph = {
                        nodes = [
                            # duplicate inputs
                            { type = builtin label = copy name = copyFL  }
                            { type = builtin label = copy name = copyFR  }
                            { type = builtin label = copy name = copyFC  }
                            { type = builtin label = copy name = copyRL  }
                            { type = builtin label = copy name = copyRR  }
                            { type = builtin label = copy name = copySL  }
                            { type = builtin label = copy name = copySR  }
                            { type = builtin label = copy name = copyLFE }

                            # apply hrir - HeSuVi 14-channel WAV (not the *-.wav variants) (note: */44/* in HeSuVi are the same, but resampled to 44100)
                            { type = builtin label = convolver name = convFL_L config = { filename = "hrir_hesuvi/hrir.wav" channel =  0 } }
                            { type = builtin label = convolver name = convFL_R config = { filename = "hrir_hesuvi/hrir.wav" channel =  1 } }
                            { type = builtin label = convolver name = convSL_L config = { filename = "hrir_hesuvi/hrir.wav" channel =  2 } }
                            { type = builtin label = convolver name = convSL_R config = { filename = "hrir_hesuvi/hrir.wav" channel =  3 } }
                            { type = builtin label = convolver name = convRL_L config = { filename = "hrir_hesuvi/hrir.wav" channel =  4 } }
                            { type = builtin label = convolver name = convRL_R config = { filename = "hrir_hesuvi/hrir.wav" channel =  5 } }
                            { type = builtin label = convolver name = convFC_L config = { filename = "hrir_hesuvi/hrir.wav" channel =  6 } }
                            { type = builtin label = convolver name = convFR_R config = { filename = "hrir_hesuvi/hrir.wav" channel =  7 } }
                            { type = builtin label = convolver name = convFR_L config = { filename = "hrir_hesuvi/hrir.wav" channel =  8 } }
                            { type = builtin label = convolver name = convSR_R config = { filename = "hrir_hesuvi/hrir.wav" channel =  9 } }
                            { type = builtin label = convolver name = convSR_L config = { filename = "hrir_hesuvi/hrir.wav" channel = 10 } }
                            { type = builtin label = convolver name = convRR_R config = { filename = "hrir_hesuvi/hrir.wav" channel = 11 } }
                            { type = builtin label = convolver name = convRR_L config = { filename = "hrir_hesuvi/hrir.wav" channel = 12 } }
                            { type = builtin label = convolver name = convFC_R config = { filename = "hrir_hesuvi/hrir.wav" channel = 13 } }

                            # treat LFE as FC
                            { type = builtin label = convolver name = convLFE_L config = { filename = "hrir_hesuvi/hrir.wav" channel =  6 } }
                            { type = builtin label = convolver name = convLFE_R config = { filename = "hrir_hesuvi/hrir.wav" channel = 13 } }

                            # stereo output
                            { type = builtin label = mixer name = mixL }
                            { type = builtin label = mixer name = mixR }
                        ]
                        links = [
                            # input
                            { output = "copyFL:Out"  input="convFL_L:In"  }
                            { output = "copyFL:Out"  input="convFL_R:In"  }
                            { output = "copySL:Out"  input="convSL_L:In"  }
                            { output = "copySL:Out"  input="convSL_R:In"  }
                            { output = "copyRL:Out"  input="convRL_L:In"  }
                            { output = "copyRL:Out"  input="convRL_R:In"  }
                            { output = "copyFC:Out"  input="convFC_L:In"  }
                            { output = "copyFR:Out"  input="convFR_R:In"  }
                            { output = "copyFR:Out"  input="convFR_L:In"  }
                            { output = "copySR:Out"  input="convSR_R:In"  }
                            { output = "copySR:Out"  input="convSR_L:In"  }
                            { output = "copyRR:Out"  input="convRR_R:In"  }
                            { output = "copyRR:Out"  input="convRR_L:In"  }
                            { output = "copyFC:Out"  input="convFC_R:In"  }
                            { output = "copyLFE:Out" input="convLFE_L:In" }
                            { output = "copyLFE:Out" input="convLFE_R:In" }

                            # output
                            { output = "convFL_L:Out"  input="mixL:In 1" }
                            { output = "convFL_R:Out"  input="mixR:In 1" }
                            { output = "convSL_L:Out"  input="mixL:In 2" }
                            { output = "convSL_R:Out"  input="mixR:In 2" }
                            { output = "convRL_L:Out"  input="mixL:In 3" }
                            { output = "convRL_R:Out"  input="mixR:In 3" }
                            { output = "convFC_L:Out"  input="mixL:In 4" }
                            { output = "convFC_R:Out"  input="mixR:In 4" }
                            { output = "convFR_R:Out"  input="mixR:In 5" }
                            { output = "convFR_L:Out"  input="mixL:In 5" }
                            { output = "convSR_R:Out"  input="mixR:In 6" }
                            { output = "convSR_L:Out"  input="mixL:In 6" }
                            { output = "convRR_R:Out"  input="mixR:In 7" }
                            { output = "convRR_L:Out"  input="mixL:In 7" }
                            { output = "convLFE_R:Out" input="mixR:In 8" }
                            { output = "convLFE_L:Out" input="mixL:In 8" }
                        ]
                        inputs  = [ "copyFL:In" "copyFR:In" "copyFC:In" "copyLFE:In" "copyRL:In" "copyRR:In", "copySL:In", "copySR:In" ]
                        outputs = [ "mixL:Out" "mixR:Out" ]
                    }
                    capture.props = {
                        node.name      = "effect_input.virtual-surround-7.1-hesuvi"
                        media.class    = Audio/Sink
                        audio.channels = 8
                        audio.position = [ FL FR FC LFE RL RR SL SR ]
                    }
                    playback.props = {
                        node.name      = "effect_output.virtual-surround-7.1-hesuvi"
                        node.passive   = true
                        audio.channels = 2
                        audio.position = [ FL FR ]
                    }
                }
            }
        ]

      '';
    };
  };
}
