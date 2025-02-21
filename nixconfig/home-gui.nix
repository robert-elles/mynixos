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
        extensions = with pkgs.vscode-extensions;
          [
            dracula-theme.theme-dracula
            yzhang.markdown-all-in-one
            # vscode plugins are better installed from vscode itself
            # github.copilot # seems to be outdated
            # ms-python.python
            # ms-toolsai.jupyter  
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
