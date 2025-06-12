{ pkgs, config, ... }: {

  home.stateVersion = "25.05";

  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    zplug = {
      enable = true;
      plugins = [
        { name = "zsh-users/zsh-autosuggestions"; }
        { name = "zsh-users/zsh-syntax-highlighting"; }
        { name = "agkozak/zsh-z"; }
      ];
    };
    oh-my-zsh = {
      enable = true;
      theme = "af-magic";
    };
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    # enableFishIntegration = true;
    settings = {
      # atuin register/login -u <USERNAME> -e <EMAIL> (-p <PASSWORD>)
      # atuin import auto
      auto_sync = true;
      sync_frequency = "5m";
      sync_address = "https://api.atuin.sh";
      search_mode = "prefix";
      # key_path = config.age.secrets.atuin_key.path;
      key_path = "/Users/rell/.config/atuin/atuin_key";
    };
  };
}
