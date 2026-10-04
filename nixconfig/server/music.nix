{
  settings,
  pkgs,
  pkgs-pin,
  config,
  ...
}:

let
  # services.navidrome.plugins only accepts packages flagged isNavidromePlugin;
  # the navidrome package links $out/share/<pname>.ndp into its (read-only)
  # Plugins.Folder. Wrap prebuilt release .ndp files accordingly.
  ndpPlugin =
    pname: src:
    pkgs.runCommand "navidrome-plugin-${pname}"
      {
        inherit pname;
        passthru.isNavidromePlugin = true;
      }
      ''
        install -Dm444 ${src} $out/share/${pname}.ndp
      '';

  audiomuseai-plugin = ndpPlugin "audiomuseai" (
    pkgs.fetchurl {
      url = "https://github.com/NeptuneHub/AudioMuse-AI-NV-plugin/releases/download/v10/audiomuseai.ndp";
      hash = "sha256-wTjprxbwl9jNB6yVf7iknZGn2gZuW0oUV8rb1HmqEKc=";
    }
  );

  mood-playlists-plugin = ndpPlugin "mood-playlists" (
    pkgs.fetchurl {
      url = "https://github.com/craiglush/navidrome-mood-plugin/releases/download/v0.2.0/mood-playlists.ndp";
      hash = "sha256-WI2u2SAA339FCoyIkGHWXfOaE7Zsy3t9LswVNqyZ3bo=";
    }
  );

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

  beets = pkgs.python3Packages.beets.override {
    # lastgenre returns whitelisted kept genres as-is when Last.fm has
    # nothing; canonicalize them too so they still get their parent genres.
    extraPatches = [ ./beets/lastgenre-canonicalize-original-fallback.patch ];
    pluginOverrides = {
      xtractor = {
        enable = true;
        propagatedBuildInputs = [ beets-xtractor ];
      };
    };
  };

  # Genres that neither beets' built-in lists nor MusicBrainz know, mapped to
  # a parent genre, or null to derive the parent from a known trailing word
  # group ("french indie pop" -> "indie pop"). See beets/extend-genres.py.
  genreExtras = {
    "afrobeats" = "african";
    "afrohouse" = "afro house";
    "afro tech" = "afro house";
    "afropop" = "african";
    "alt country" = "alternative country";
    "azonto" = "african";
    "cold wave" = "coldwave";
    "coupé décalé" = "coupé-décalé";
    "dance" = "electronic";
    "drill" = "hip hop";
    "edm" = "electronic dance music";
    "electrocumbia" = "cumbia";
    "indie dance" = "electronic";
    "jazz funk" = "jazz-funk";
    "melodic house & techno" = "techno";
    "ndombolo" = "soukous";
    "neo-psychedelic" = "neo-psychedelia";
    "rap" = "hip hop";
    "variété française" = "chanson";
    "brazilian pop" = null;
    "brooklyn drill" = null;
    "classic soul" = null;
    "dansk rap" = null;
    "egyptian pop" = null;
    "ethiopian jazz" = null;
    "experimental jazz" = null;
    "finnish pop" = null;
    "french indie pop" = null;
    "french jazz" = null;
    "french rap" = null;
    "german indie" = null;
    "german pop" = null;
    "indie jazz" = null;
    "indie r&b" = null;
    "indie soul" = null;
    "k-rap" = null;
    "nz reggae" = null;
    "retro soul" = null;
    "soft pop" = null;
    "traditional folk" = null;
    "uk r&b" = null;
    "vocal downtempo" = null;
  };

  # lastgenre whitelist (genres.txt) and canonicalization tree
  # (genres-tree.yaml): beets' defaults extended with MusicBrainz' genre list
  # and genreExtras, so every whitelisted genre can pull in its parents.
  lastgenreData =
    pkgs.runCommand "beets-lastgenre-data"
      {
        nativeBuildInputs = [ (pkgs.python3.withPackages (p: [ p.pyyaml ])) ];
        extras = builtins.toJSON genreExtras;
        passAsFile = [ "extras" ];
      }
      ''
        python3 ${./beets/extend-genres.py} \
          ${beets.src}/beetsplug/lastgenre/genres.txt \
          ${beets.src}/beetsplug/lastgenre/genres-tree.yaml \
          ${./beets/musicbrainz-genres.txt} \
          "$extrasPath" $out
      '';
in
{

  systemd.services.navidrome = {
    after = [ "data.mount" ];
    requires = [ "data.mount" ];
  };

  services.navidrome = {
    enable = true;
    plugins = [
      audiomuseai-plugin
      mood-playlists-plugin
    ];
    settings = {
      Address = "0.0.0.0";
      Port = 9002;
      EnableInsightsCollector = true;
      MusicFolder = "/data/music";
      BaseUrl = "http://${settings.hostname}:9002";
      Scanner.Enabled = true;
      LogLevel = "error";
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
      # Host networking: move uvicorn off 8000, which audiomuse-flask's
      # hardcoded gunicorn needs. mood-playlists plugin analyzer_url:
      # http://127.0.0.1:8001
      ExecStart = "${pkgs.docker}/bin/docker run --rm --name mood-analyzer --network host -v /data/music:/music:ro mood-analyzer uvicorn app:app --host 0.0.0.0 --port 8001";
      ExecStop = "${pkgs.docker}/bin/docker stop mood-analyzer";
      Restart = "on-failure";
      RestartSec = "30s";
    };
  };

  # AudioMuse-AI core, the backend the audiomuseai plugin above queries.
  # The worker fetches audio through Navidrome's Subsonic API (no music mount)
  # and analyses it; flask serves the web UI and the similarity API. Plugin
  # apiUrl (Navidrome plugin UI): http://127.0.0.1:8000
  #
  # Host networking: the image hardcodes gunicorn on 0.0.0.0:8000, the worker
  # has no listener, and postgres moves to 127.0.0.1:5433 because the shared
  # native postgres (postgres.nix) owns 5432.
  #
  # audiomuse secret (env file): POSTGRES_PASSWORD, NAVIDROME_USER,
  # NAVIDROME_PASSWORD. The navidrome/tuning values are only seeds: on first
  # boot AudioMuse copies them into its app_config table, and from then on the
  # setup wizard / DB value wins over the environment.
  virtualisation.oci-containers.containers =
    let
      image = "ghcr.io/neptunehub/audiomuse-ai:3.6.2";
      dbEnv = {
        TZ = "Europe/Berlin";
        POSTGRES_USER = "audiomuse";
        POSTGRES_DB = "audiomusedb";
      };
      appEnv = dbEnv // {
        POSTGRES_HOST = "127.0.0.1";
        POSTGRES_PORT = "5433";
        MEDIASERVER_TYPE = "navidrome";
        NAVIDROME_URL = "http://127.0.0.1:9002";
        TEMP_DIR = "/app/temp_audio";
      };
      common = {
        environmentFiles = [ config.age.secrets.audiomuse.path ];
        networks = [ "host" ];
      };
    in
    {
      audiomuse-postgres = common // {
        image = "docker.io/library/postgres:15-alpine";
        # PGPORT is honoured by both the entrypoint's init server and postgres
        environment = dbEnv // {
          PGPORT = "5433";
        };
        cmd = [
          "postgres"
          "-c"
          "listen_addresses=127.0.0.1"
        ];
        volumes = [ "/fastdata/audiomuse/postgres:/var/lib/postgresql/data" ];
      };
      audiomuse-flask = common // {
        inherit image;
        environment = appEnv // {
          SERVICE_TYPE = "flask";
        };
        dependsOn = [ "audiomuse-postgres" ];
        volumes = [
          "audiomuse-temp-flask:/app/temp_audio"
          "audiomuse-plugins-flask:/app/plugin/installed"
        ];
      };
      audiomuse-worker = common // {
        inherit image;
        environment = appEnv // {
          SERVICE_TYPE = "worker";
        };
        dependsOn = [ "audiomuse-postgres" ];
        volumes = [
          "audiomuse-temp-worker:/app/temp_audio"
          "audiomuse-plugins-worker:/app/plugin/installed"
        ];
      };
    };

  # uid/gid 70 = postgres in the alpine image; matches what its entrypoint
  # chowns the data dir to, so tmpfiles and the entrypoint don't fight.
  systemd.tmpfiles.rules = [
    "d /fastdata/audiomuse 0755 root root -"
    "d /fastdata/audiomuse/postgres 0700 70 70 -"
  ];

  home-manager = {
    users.robert = {
      programs.beets = {
        enable = true;
        package = pkgs.python3Packages.toPythonApplication beets;
        settings = {
          directory = "/data/music";
          library = "/data/music/beets.db";
          plugins = [
            "musicbrainz"
            "lastgenre"
            "mbsync"
            "chroma"
            "xtractor"
          ];
          import = {
            copy = false;
            quiet = true;
            write = true;
          };
          # Genres come from two sources and land in the multi-valued `genres`
          # field, written as one genre tag per value (Navidrome reads these
          # as separate genres):
          # 1. musicbrainz: release + release-group genres, set when a
          #    release is matched on import or refreshed by `beet mbsync`.
          # 2. lastgenre (runs after matching on import): merges those with
          #    Last.fm tags (track, then album, then artist), whitelists and
          #    adds each genre's parents ("Melodic Techno" -> "Techno",
          #    "Electronic").
          # mbsync replaces genres with MusicBrainz-only ones, so run
          # `beet lastgenre` afterwards. Whole library:
          # `beet lastgenre` (albums, also tracks via source=track) and
          # `beet lastgenre -A singleton:true` for singletons.
          musicbrainz = {
            genres = true;
            genres_tag = "genre";
            extra_tags = [
              "label"
              "country"
              "year"
            ];
          };
          lastgenre = {
            auto = true;
            source = "track";
            # Re-fetch every time but keep existing (e.g. MusicBrainz) genres,
            # which take precedence over new Last.fm ones.
            force = true;
            keep_existing = true;
            whitelist = "${lastgenreData}/genres.txt";
            canonical = "${lastgenreData}/genres-tree.yaml";
            # prefer_specific would sort by tree depth and cut the broad
            # parents off at `count`; popularity order keeps each genre's
            # parent chain. `count` also counts chain duplicates before
            # dedup, so 5 yields ~2-4 distinct genres.
            prefer_specific = false;
            count = 5;
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
