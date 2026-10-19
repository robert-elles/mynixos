{ ... }:
# yubal: self-hosted YouTube Music downloader (https://github.com/guillevc/yubal).
#
# Runs alongside ytmusic-sync (ytmusic-sync.nix) as a side-by-side trial, so
# both tools sync Liked Music and every track ends up in the library TWICE,
# in two different layouts. That is deliberate for now; retire one of them
# once the trial is over.
#
# Library layout: yubal only recognises a track as "already downloaded" by
# testing whether its own output path exists
# (download_service.py: `Path(f"{output_path}.{codec}").exists()`), and that
# path is always base/Artist/YEAR - Album/NN - Title. It has no library
# scanner and no flat-folder mode, so it cannot see the existing 2100+ flat
# files in /data/music/singlefolder and would re-download all of them as
# duplicates if pointed at /data/music directly. It therefore gets its own
# subtree, where its dedup is self-consistent.
#
# The rest of the pipeline needs no changes: `sd music tag`
# (dotfiles/sd/music/tag) walks /data/music with rglob, and navidrome's
# scanner is recursive too, so both pick the subtree up on their own.
{
  virtualisation.oci-containers.containers.yubal = {
    image = "ghcr.io/guillevc/yubal:0.10.0";

    # Only reachable via the nginx HTTPS front built from local-aliases.nix.
    # The container's own port stays 8000, but that is taken on the host by
    # audiomuse-flask's hardcoded gunicorn (music.nix), hence 19019 outside.
    ports = [ "127.0.0.1:19019:8000" ];

    volumes = [
      # Music library. Its own subtree, see the dedup note above.
      "/data/music/yubal:/app/data"
      # Config + state: yt-dlp cookies uploaded through the web UI, the
      # subscription database and the extraction cache all live here.
      "/fastdata/yubal/config:/app/config"
    ];

    environment = {
      # The image's entrypoint.sh starts as root on purpose: it creates the
      # config dirs, chowns them to PUID:PGID and only then drops privileges
      # with gosu. Setting `user`/`--user=` would skip that and make it fail
      # on a non-writable /app/data, so ownership is steered with PUID/PGID
      # instead: robert (1000) and the navidrome group (976), matching the
      # rest of /data/music.
      PUID = "1000";
      PGID = "976";

      YUBAL_TZ = "Europe/Berlin";

      # Match the existing library, and keep it a lossless remux where
      # youtube already serves opus.
      YUBAL_AUDIO_FORMAT = "opus";

      # Lyrics are owned end-to-end by `sd music tag`, which writes them
      # into the tags and adds a translated LYRICS:eng layer. yubal would
      # instead drop .lrc sidecars next to the files, which that translation
      # step never looks at - so they would stay untranslated.
      YUBAL_FETCH_LYRICS = "false";
      YUBAL_YTMUSIC_LYRICS_FALLBACK = "false";

      # Nightly, early enough to be finished before music-tag runs at 04:30
      # and audiomuse analyses at 06:00 (music.nix).
      YUBAL_SCHEDULER_CRON = "0 3 * * *";
    };
  };

  # /data is a separate mount; without this the container can start before it
  # is there and yubal's entrypoint would populate an empty mountpoint.
  systemd.services.podman-yubal = {
    after = [ "data.mount" ];
    requires = [ "data.mount" ];
  };

  # 2770 + group navidrome mirrors /data/music itself, so everything yubal
  # writes stays readable by navidrome and writable by robert (the user
  # `sd music tag` runs as). The entrypoint chowns /app/data non-recursively,
  # which this already satisfies.
  systemd.tmpfiles.rules = [
    "d /fastdata/yubal 0755 root root -"
    "d /fastdata/yubal/config 0750 robert navidrome -"
    "d /data/music/yubal 2770 robert navidrome -"
  ];
}
