{ config, pkgs, lib, home-manager, ... }: {
  imports = [ home-manager.nixosModule ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.robert = {
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
          switch =
            "sudo nixos-rebuild -v switch --flake /etc/nixos/mynixos |& nom";
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

      #  home.file.".config/i3/config".source = ../config/i3/config;
      #  home.file.".config/i3status/config".source = ../config/i3status/config;
      home.file.".config/kitty/kitty.conf".source = ../config/kitty.conf;
      home.file.".config/gtk-3.0/settings.ini".source =
        ../config/gtk-3.0/settings.ini;
      #  home.file.".config/rofi".source = ../config/rofi;
      #  home.file.".config/dunst".source = ../config/dunst;
      #  home.file.".config/systemd/user/default.target.wants/redshift.service".source =
      #    ../config/redshift.service;
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

      home.sessionVariables = {
        #LS_COLORS="$LS_COLORS:'di=1;33:'"; # export LS_COLORS
      };

      programs.git = { enable = true; };
    };
  };
}
