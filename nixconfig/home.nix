{ config, pkgs, lib, home-manager, ... }: {

  imports = [ home-manager.nixosModule ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.robert = {

      services.easyeffects.enable = true;
      #      services.easyeffects.preset = "";

      home.stateVersion = "22.05";
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
          rebuildswitch =
            "sudo nixos-rebuild switch --flake /etc/nixos/mynixos |& nom";
          rebuildboot =
            "sudo nixos-rebuild boot --flake /etc/nixos/mynixos |& nom";
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

      home.file.".config/plasma-workspace/env/local.sh".text = ''
        export LANGUAGE=en_US.UTF-8
        export LC_ALL=en_US.UTF-8
        export LANG=en_US.UTF-8
        export LC_CTYPE=en_US.UTF-
      '';

      home.sessionVariables = {
        #LS_COLORS="$LS_COLORS:'di=1;33:'"; # export LS_COLORS
      };

      programs = {
        git = { enable = true; };
        vscode.enable = true;
        vscode.userSettings = {
          #          "[nix]": {
          #                "editor.defaultFormatter": "brettm12345.nixfmt-vscode"
          #            },
          workbench.colorTheme = "Default Light+";
          #            "explorer.confirmDragAndDrop": false,
          #            "explorer.confirmDelete": false,
          #            "git.confirmSync": false,
          window.openFoldersInNewWindow = "on";
          window.restoreWindows = "none";
          files.autoSave = "afterDelay";
        };
      };
    };
  };
}
