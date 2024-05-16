{ pkgs, ... }: {

  home-manager = {
    users.robert = {

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
}
