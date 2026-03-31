{
  settings,
  pkgs,
  pkgs-pin,
  config,
  ...
}:

let
  audiomuseai-plugin = pkgs.fetchurl {
    url = "https://github.com/NeptuneHub/AudioMuse-AI-NV-plugin/releases/download/v6/audiomuseai.ndp";
    hash = "sha256-jEA7z1zhcgISYd1jlmyl267jSa15Q+Pi8Jpbw5Xqbvo=";
  };

  mood-playlists-plugin = pkgs.fetchurl {
    url = "https://github.com/craiglush/navidrome-mood-plugin/releases/download/v0.2.0/mood-playlists.ndp";
    hash = "sha256-WI2u2SAA339FCoyIkGHWXfOaE7Zsy3t9LswVNqyZ3bo=";
  };

  mood-analyzer-src = pkgs.fetchFromGitHub {
    owner = "craiglush";
    repo = "navidrome-mood-plugin";
    rev = "v0.2.0";
    hash = "sha256-lhmp/gk8F6BYJEM+o3LW4KPSfWnsAyWGH2V3j2PJcl0=";
  };

  essentia-extractor-gaia = pkgs.stdenv.mkDerivation {
    pname = "essentia-extractor-gaia";
    version = "2.1_beta2";
    src = pkgs.fetchurl {
      url = "https://essentia.upf.edu/extractors/essentia-extractors-v2.1_beta2-linux-x86_64.tar.gz";
      hash = "sha256-tqqu+rN5y2zAoS2VhlMngT7P+iqKPSrTdhlFbpz7qqY=";
    };
    unpackPhase = "unpackFile $src; export sourceRoot=essentia-extractors-v2.1_beta2";
    installPhase = ''
      mkdir -p $out/bin
      cp streaming_extractor_music $out/bin
      chmod +x $out/bin/streaming_extractor_music
    '';
    meta.platforms = [ "x86_64-linux" ];
  };

  essentia-svm-models = pkgs.fetchurl {
    url = "https://essentia.upf.edu/svm_models/essentia-extractor-svm_models-v2.1_beta5.tar.gz";
    hash = "sha256-3ILxMbLNXkJWWaKd3Zj9ePNniEZ19xuGVBOTSKHIzAE=";
  };

  svm-models = pkgs.runCommand "essentia-svm-models" { } ''
    mkdir -p $out
    tar xzf ${essentia-svm-models} -C $out --strip-components=1
  '';

  beets-xtractor = pkgs.python3Packages.buildPythonPackage {
    pname = "beets-xtractor";
    version = "0.4.2";
    src = pkgs.fetchPypi {
      pname = "beets_xtractor";
      version = "0.4.2";
      hash = "sha256-wn25Kewkj0oT+BVnLFuJaLAbZGLkA2eu6bgF1rWTGIk=";
    };
    pyproject = true;
    build-system = [ pkgs.python3Packages.setuptools ];
    dependencies = with pkgs.python3Packages; [
      pyyaml
    ];
    postPatch = ''
      substituteInPlace beetsplug/xtractor/command.py \
        --replace-warn "os.makedirs(output_path)" "os.makedirs(output_path, exist_ok=True)"
    '';
    doCheck = false;
    pythonRemoveDeps = [ "beets" ];
  };

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
    serviceConfig.ExecStartPre = [
      "${pkgs.coreutils}/bin/mkdir -p /var/lib/navidrome/plugins"
      "${pkgs.coreutils}/bin/cp -f ${audiomuseai-plugin} /var/lib/navidrome/plugins/audiomuseai.ndp"
      "${pkgs.coreutils}/bin/cp -f ${mood-playlists-plugin} /var/lib/navidrome/plugins/mood-playlists.ndp"
    ];
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
      PluginsEnabled = true;
      Agents = "audiomuseai,lastfm,spotify";
    };
    environmentFile = config.age.secrets.navidrome.path;
  };

  systemd.services.mood-analyzer = {
    description = "Navidrome Mood Analyzer Service";
    after = [
      "docker.service"
      "data.mount"
    ];
    requires = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStartPre = [
        "-${pkgs.docker}/bin/docker stop mood-analyzer"
        "-${pkgs.docker}/bin/docker rm mood-analyzer"
        "${pkgs.docker}/bin/docker build -t mood-analyzer ${mood-analyzer-src}/analyzer-service"
      ];
      ExecStart = "${pkgs.docker}/bin/docker run --rm --name mood-analyzer --network host -v /data/music:/music:ro mood-analyzer";
      ExecStop = "${pkgs.docker}/bin/docker stop mood-analyzer";
      Restart = "on-failure";
      RestartSec = "30s";
    };
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
              xtractor = {
                enable = true;
                propagatedBuildInputs = [ beets-xtractor ];
              };
            };
          }
        );
        settings = {
          directory = "/data/music";
          library = "/data/music/beets.db";
          plugins = [
            "lastgenre"
            "musicbrainz"
            "mbsync"
            "chroma"
            # "wlg"
            "xtractor"
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
          lastgenre = {
            auto = true;
            force = false;
            count = 3;
            source = "track";
            canonical = true;
            cleanup_existing = true;
            prefer_specific = true;
            whitelist = true;
          };
          wlg = {
            auto = true;
            force = false;
            count = 3;
            whitelist = "wlg";
          };
          xtractor = {
            auto = false;
            threads = 0;
            force = false;
            quiet = false;
            essentia_extractor = "${essentia-extractor-gaia}/bin/streaming_extractor_music";
            extractor_profile = {
              outputFormat = "json";
              outputFrames = 0;
              highlevel = {
                compute = 1;
                svm_models = [
                  "${svm-models}/danceability.history"
                  "${svm-models}/gender.history"
                  "${svm-models}/genre_dortmund.history"
                  "${svm-models}/genre_electronic.history"
                  "${svm-models}/genre_rosamerica.history"
                  "${svm-models}/genre_tzanetakis.history"
                  "${svm-models}/mood_acoustic.history"
                  "${svm-models}/mood_aggressive.history"
                  "${svm-models}/mood_electronic.history"
                  "${svm-models}/mood_happy.history"
                  "${svm-models}/mood_party.history"
                  "${svm-models}/mood_relaxed.history"
                  "${svm-models}/mood_sad.history"
                  "${svm-models}/moods_mirex.history"
                  "${svm-models}/timbre.history"
                  "${svm-models}/tonal_atonal.history"
                  "${svm-models}/voice_instrumental.history"
                ];
              };
            };
          };
        };
      };
    };
  };
}
