{ pkgs, inputs, ... }: {

  home-manager = {

    sharedModules = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];

    users.robert = {
      imports = [
        inputs.betterfox.homeManagerModules.betterfox
        ./firefox.nix
      ];


      # imports = [
      #   ./firefox.nix
      # ];

      services.easyeffects.enable = true;

      programs.vscode = {
        enable = true;
        # package = pkgs.vscode.fhs;
        package = pkgs.vscode.fhs;
        # extensions = with pkgs.vscode-extensions;
        profiles.default.extensions = with pkgs.vscode-extensions;
          [
            dracula-theme.theme-dracula
            yzhang.markdown-all-in-one
            # vscode plugins are better installed from vscode itself
            # github.copilot # seems to be outdated
            ms-python.python
            ms-python.debugpy
            ms-python.vscode-pylance
            ms-python.pylint
            ms-python.black-formatter
            ms-toolsai.jupyter
            esbenp.prettier-vscode
            jnoortheen.nix-ide
            james-yu.latex-workshop
          ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            # run: sd utils update_installed_extensions.sh
            {
              name = "filewatcher";
              publisher = "appulate";
              version = "2.0.0";
              hash = "sha256-4tSXWGztpTIqIkKxN1Gqg0wYYoDe4JdlHwwd14rc9hY=";
            }
            {
              name = "pdf";
              publisher = "tomoki1207";
              version = "1.2.2";
              hash = "sha256-i3Rlizbw4RtPkiEsodRJEB3AUzoqI95ohyqZ0ksROps=";
            }
          ];
      };

      programs.kodi = {
        enable = true;
        package = pkgs.kodi.withPackages (p: [ p.a4ksubtitles ]);
      };
    };
  };

  # fileSystems."/home/robert/.config/autostart" = {
  #   device = "/home/robert/Nextcloud/Config/autostart";
  #   options = [ "bind" ];
  #   # options = [ "bind" "uid=1000" "gid=1000" "dmask=007" "fmask=117" ];
  #   neededForBoot = false;
  #   noCheck = true;
  # };
}
