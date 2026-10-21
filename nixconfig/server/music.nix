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

  # ReplayGain for every track that has none yet. Same tool, flags and tags
  # as yubal uses on its own downloads (services/replaygain.py:
  # `rsgain custom -q -s i [-a] [-o r]`), so both agree: R128_TRACK_GAIN for
  # opus (RFC 7845) and REPLAYGAIN_TRACK_GAIN/PEAK for m4a, which is What
  # navidrome reads (mappings.yaml).
  #
  # Track gain only, no -a: album gain is computed per *directory*, and
  # outside the yubal subtree a directory is not an album
  # (/data/music/singlefolder alone holds ~1650 unrelated tracks), so it
  # would be meaningless there. yubal already writes album gain for the
  # albums it downloads, and -S leaves those files alone.
  #
  # -S skips anything already tagged, so only genuinely new tracks are
  # decoded; xargs keeps the argument list bounded, which custom mode needs
  # where it takes explicit file names rather than a directory.
  replaygain = pkgs.writeShellScript "music-replaygain" ''
    set -euo pipefail
    find /data/music -type f \
      \( -name '*.opus' -o -name '*.ogg' -o -name '*.flac' -o -name '*.m4a' -o -name '*.mp4' \) \
      -print0 | xargs -0 -r ${pkgs.rsgain}/bin/rsgain custom -q -s i -S -o r
  '';

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

  # Tag whatever ytmusic-sync pulled in during the day (dotfiles/sd/music/tag).
  # Runs as robert: the script is a uv script and reuses that user's uv and
  # ~/.cache/music-tag model cache, and the tracks it writes belong to robert
  # anyway. Lookups that found nothing are remembered in /data/music/tag.db,
  # so a nightly run over the whole library only queries what is genuinely
  # new or previously failed.
  systemd.services.music-tag = {
    description = "Fill in missing music tags (genre, lyrics, country, bpm, mood, year, replaygain)";
    after = [
      "data.mount"
      "network-online.target"
    ];
    requires = [ "data.mount" ];
    wants = [ "network-online.target" ];
    path = with pkgs; [
      uv
      ffmpeg-full
    ];
    serviceConfig = {
      Type = "oneshot";
      User = "robert";
      Group = "users";
      # Read by the tagger to translate non-English lyrics. The unit still
      # works without it; the translation step just no-ops.
      Environment = "DEEPL_KEY_FILE=${config.age.secrets.deepl_api_key.path}";
      # Essentia analysis of new tracks is slow, and MusicBrainz allows only
      # one request per second, so a backlog legitimately takes hours.
      TimeoutStartSec = "6h";
      # Never let tagging compete with navidrome or the transcoders.
      Nice = 15;
      IOSchedulingClass = "idle";
      # Sequential (Type=oneshot): replaygain runs after tagging, so the two
      # never rewrite the same file at once - mutagen saves whole tag blocks
      # and would drop whatever rsgain had just added.
      ExecStart = [
        "${settings.system_repo_root}/dotfiles/sd/music/tag"
        replaygain
      ];
    };
  };

  systemd.timers.music-tag = {
    description = "Tag new music nightly";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "04:30";
      RandomizedDelaySec = "20m";
      Persistent = true;
    };
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
      # Artist images: deezer first. lastfm scrapes last.fm artist pages
      # for them, and last.fm answers that with a bot challenge, which
      # trips navidrome's circuit breaker and leaves most artists without
      # an image. (spotify was removed from navidrome in 0.5x.)
      Agents = "audiomuseai,deezer,lastfm";
      # Artist country, written by `sd music tag` (dotfiles/sd/music/tag).
      # Needs a full scan after changes.
      Tags.country.Aliases = [
        "country"
        "----:com.apple.itunes:country"
      ];
      # DATE_ADDED, written by ytmusic-sync (ytmusic/sync.py). Can't be
      # called "dateadded": that is navidrome's own scan-time field, which
      # would shadow the tag in smart playlists.
      Tags.added.Aliases = [
        "date_added"
        "----:com.apple.itunes:date_added"
      ];
    };
    environmentFile = config.age.secrets.navidrome.path;
  };

  # Feishin: alternative web UI for navidrome (above). Not a server - it is
  # a static JS bundle (pkgs.feishin-web) served straight off the store by
  # the nginx that is already running, so there is no daemon, no state and
  # no container. `settings` is rendered into settings.js at build time and
  # only seeds the login form; the real config lives in the browser.
  #
  # Feishin talks to navidrome from the *browser*, not from the server, so
  # the two schemes must match: this vhost is HTTPS, hence SERVER_URL has to
  # be HTTPS too (browsers block https -> http as mixed content). It points
  # at navidrome's alias vhost on 443 (see acmeproxy.nix), which proxies to
  # 127.0.0.1:9002. Cross-origin is fine: navidrome sends
  # Access-Control-Allow-Origin: *.
  #
  # Both hostnames are covered by the local-CA cert, so a client needs to
  # trust secrets/local-ca/ca.crt (as for mealie/vikunja/gramps).
  services.feishin = {
    enable = true;
    # Plain https on 443, separated from the other services by Host/SNI
    # rather than by port. feishin has no entry in local-aliases.nix: that
    # list builds *proxy* vhosts (and the public vhosts derived from it),
    # while this one is served straight from the store by the module - so
    # its public name has to be wired up here instead.
    #
    # The public name is the primary vhost because it carries the Let's
    # Encrypt wildcard, which needs no CA on the client; the private names
    # get their own vhost below, with the local CA.
    domain = "feishin.${settings.public_hostname2}";
    nginx = {
      enable = true;
      virtualHost = {
        onlySSL = true;
        useACMEHost = settings.public_hostname2;
      };
    };
    settings = {
      ANALYTICS_DISABLED = "true";
      SERVER_NAME = "navidrome";
      SERVER_TYPE = "navidrome";
      # Same scheme and name family as the page itself, so the browser's
      # cross-origin call is not blocked as mixed content.
      SERVER_URL = "https://navidrome.${settings.public_hostname2}";
      # Seed only - the server stays editable from the UI.
      SERVER_LOCK = "false";
    };
  };

  # Private names for feishin, served with the local CA. Mirrors the
  # module's own vhost (same static root, same settings.js) for clients
  # that use the .internal / .local names.
  services.nginx.virtualHosts."feishin-private" = {
    serverName = "feishin.${settings.internal_domain}";
    serverAliases = [ "feishin.local" ];
    onlySSL = true;
    sslCertificate = ../../secrets/local-ca/mealie-fullchain.crt;
    sslCertificateKey = config.age.secrets.mealie_tls_key.path;
    inherit (config.services.nginx.virtualHosts."feishin.${settings.public_hostname2}")
      root
      locations
      extraConfig
      ;
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

  # AudioMuse only analyses what its cron tells it to, and that schedule
  # lives in its postgres `cron` table, which starts empty - so without this
  # newly added music is never picked up. Declaring it here keeps the
  # schedule in the repo and restores it if the database volume is ever
  # recreated. POSTing the same task_type again updates the existing row
  # (there is a unique index on it), so this is safe to repeat on every
  # boot, and the API validates the cron expression, which a direct INSERT
  # would not.
  systemd.services.audiomuse-cron = {
    description = "Declare AudioMuse analysis/clustering schedule";
    after = [ "podman-audiomuse-flask.service" ];
    requires = [ "podman-audiomuse-flask.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.curl ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script =
      let
        entries = [
          # Scan for and analyse new tracks, nightly after music-tag.
          {
            name = "nightly analysis";
            task_type = "analysis";
            cron_expr = "0 6 * * *";
          }
          # Re-cluster weekly: clustering is only worth redoing once a
          # meaningful number of new tracks has been analysed.
          {
            name = "weekly clustering";
            task_type = "clustering";
            cron_expr = "0 7 * * 0";
          }
        ];
        post = entry: ''
          curl -fsS -X POST http://127.0.0.1:8000/api/cron \
            -H 'Content-Type: application/json' \
            -d ${pkgs.lib.escapeShellArg (builtins.toJSON (entry // { enabled = true; }))}
        '';
      in
      ''
        # The container answers only once gunicorn is actually up.
        for i in $(seq 60); do
          curl -fsS -o /dev/null http://127.0.0.1:8000/api/cron && break
          sleep 2
        done
        ${pkgs.lib.concatMapStrings post entries}
      '';
  };

  # uid/gid 70 = postgres in the alpine image; matches what its entrypoint
  # chowns the data dir to, so tmpfiles and the entrypoint don't fight.
  #
  # Smart playlists (.nsp) are imported by navidrome's scanner from the
  # music folder, which it only sees read-only, so they are copied in here.
  # f+ rewrites the content on every activation (C+ skips existing files).
  systemd.tmpfiles.rules =
    let
      recentlyAdded = builtins.toJSON {
        name = "Recently Added";
        comment = "Last 300 tracks by date added, newest first";
        # Navidrome can't COALESCE sort fields, so sort by two keys: tracks
        # with a DATE_ADDED tag (ISO 8601 UTC, sorts as text) first, then the
        # untagged ones by navidrome's scan time. Since ytmusic-sync tags
        # every download, tagged tracks are the newest anyway.
        all = [ { after.dateAdded = "1970-01-01"; } ];
        sort = "-added,-dateAdded";
        limit = 300;
      };
    in
    [
      "d /fastdata/audiomuse 0755 root root -"
      "d /fastdata/audiomuse/postgres 0700 70 70 -"
      "d /data/music/playlists 2770 robert navidrome -"
      "f+ /data/music/playlists/recently-added.nsp 0664 robert navidrome - ${recentlyAdded}"
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
