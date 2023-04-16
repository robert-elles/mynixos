{ config, pkgs, lib, home-manager, ... }: {

  imports = [ home-manager.nixosModule ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.robert = {

      programs.direnv.enable = true;
      programs.direnv.nix-direnv.enable = true;
      programs.direnv.enableZshIntegration = true;

      services.easyeffects.enable = true;
      #      services.easyeffects.preset = "";

      home.stateVersion = "22.05";
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
        shellAliases = {
          ll = "ls -l";
          rpi4 = "et rpi4";
          getsha256 =
            "nix-prefetch-url --type sha256 --unpack $1"; # $1 link to tar.gz release archive in github
          termcopy =
            "kitty +kitten ssh $1"; # copy terminal info to remote server $1 = remote server
          rebuildswitch =
            "sudo sh -c 'nixos-rebuild switch --flake $FLAKE |& nom'";
          rebuildboot =
            "sudo sh -c 'nixos-rebuild boot --flake $FLAKE |& nom'";
          captiveportal =
            "xdg-open http://$(ip --oneline route get 1.1.1.1 | awk '{print $3}')";
          pwrestart = "systemctl --user restart pipewire-pulse.service";
        };
        oh-my-zsh = {
          enable = true;
          plugins = [
            "git"
            "kubectl"
            "sudo"
            "systemd"
            "history"
          ];
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

      home.file.".local/share/applications/jules.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Jules
        Exec=code ~/code/jules
        Icon=code
      '';

      home.file.".local/share/applications/mynixos.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=MyNixOS
        Exec=code ~/code/mynixos
        Icon=code
      '';

      home.file.".local/share/applications/nipkgs.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=NixPkgs
        Exec=code ~/code/nixpkgs
        Icon=code
      '';


      home.file.".local/share/applications/JDownloader.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=JDownloader
        Exec=java -jar /home/robert/Downloads/jdownloader/JDownloader.jar
        Icon=/home/robert/Downloads/jdownloader/themes/standard/org/jdownloader/images/logo/logo-128x128.png
      '';

      home.sessionVariables = {
        #LS_COLORS="$LS_COLORS:'di=1;33:'"; # export LS_COLORS
      };

      # programs.git = {
      #   enable = true;
      #   delta.enable = true;
      #   diff-so-fancy.enable = true;
      #   userEmail = "";
      #   userName = "";
      # };

      programs.vscode = {
        enable = true;
        package = pkgs.vscode.fhs;
        extensions = with pkgs.vscode-extensions;
          [
            dracula-theme.theme-dracula
            yzhang.markdown-all-in-one
            mkhl.direnv
            # vscode plugins are better installed from vscode itself
            # github.copilot # seems to be outdated
            # ms-python.python
            # ms-toolsai.jupyter
          ];
      };
    };
  };
}
