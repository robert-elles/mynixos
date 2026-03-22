{ settings, pkgs, pkgs-pin, config, ... }: {

  systemd.services.navidrome = {
    after = [ "data.mount" ];
    requires = [ "data.mount" ];
  };

  services.navidrome = {
    enable = true;
    settings = {
      address = "::";
      port = 4533;
      EnableInsightsCollector = true;
      MusicFolder = "/data/music";
      BaseUrl = "https://navidrome.${settings.public_hostname2}";
      Scanner.Enabled = true;
      LogLevel = "error";
    };
    environmentFile = config.age.secrets.navidrome.path;
  };

  home-manager = {
    users.robert = rec {
      programs.beets = {
        enable = true;
        # package = pkgs-pin.beets;
        settings = {
          directory = "/data/music";
          library = "/data/music/beets.db";
          plugins = [
            "lastgenre"
            #"lyrics"
          ];
          # To import music run:
          # beet import -A -q -C --group-albums # import music without autotagging and quietly and group albums by artist
          import = {
            copy = false;
            quiet = true;
            write = true; # defaults to true
          };
          lastgenre = {
            force = false;
            keep_existing = true;
            count = 1;
          };
        };
      };
    };
  };
}
