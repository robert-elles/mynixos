{
  settings,
  pkgs,
  pkgs-pin,
  config,
  ...
}:

let
  whatlastgenre = pkgs.python3Packages.buildPythonPackage {
    pname = "whatlastgenre";
    version = "0.2.1";
    src = pkgs.fetchFromGitHub {
      owner = "YetAnotherNerd";
      repo = "whatlastgenre";
      rev = "8af22282f925442945acd83de52760de9c78f3c7";
      hash = "sha256-QjAJ5hNbX1+P33PN5d4AY4qldaTj6/WjjVH7vs9mEWE=";
    };
    pyproject = true;
    build-system = [ pkgs.python3Packages.setuptools ];
    dependencies = with pkgs.python3Packages; [
      mutagen
      requests
    ];
    # beets 2.x uses "genre" (singular), whatlastgenre expects "genres" (plural)
    postPatch = ''
      substituteInPlace plugin/beets/beetsplug/wlg.py \
        --replace-warn "album.genres" "album.genre" \
        --replace-warn "item.genres" "item.genre"
    ''; # todo: remove with beets 2.7
    doCheck = false;
  };
in
{

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
    users.robert = {
      home.file.".whatlastgenre/config".source = ../../secrets/gitcrypt/whatlastgenre_config;
      programs.beets = {
        enable = true;
        package = pkgs.python3Packages.toPythonApplication (
          pkgs.python3Packages.beets.override {
            pluginOverrides = {
              wlg = {
                enable = true;
                propagatedBuildInputs = [ whatlastgenre ];
              };
            };
          }
        );
        settings = {
          directory = "/data/music";
          library = "/data/music/beets.db";
          plugins = [
            "musicbrainz"
            "wlg"
          ];
          import = {
            copy = false;
            quiet = true;
            write = true;
          };
          musicbrainz = {
            genres = false;
            genres_tag = "genre";
            musicbrainz = {
              extra_tags = [
                "label"
                "country"
                "year"
              ];
            };
          };
          wlg = {
            auto = true;
            force = false;
            count = 3;
            whitelist = "wlg";
          };
        };
      };
    };
  };
}
