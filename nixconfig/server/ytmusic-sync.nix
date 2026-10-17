{
  settings,
  pkgs,
  ...
}:

# Hourly mirror of a YouTube Music playlist into /data/music/singlefolder as
# Opus (lossless remux of YouTube's own Opus stream) with metadata and a
# square cover. The dedup logic lives in ytmusic/sync.py.
#
# Cookies: secrets/gitcrypt/yt-music-cookies.txt. "Liked music" is only
# visible to a logged-in session, so that file has to be an export of a
# logged-in browser profile (it needs SID / __Secure-*PSID / LOGIN_INFO; an
# export with only PREF/SOCS/VISITOR_* makes the playlist look non-existent).
# yt-dlp rotates cookies as it uses them, so the service works on a copy in
# its StateDirectory and leaves the git-crypt'ed original alone, re-copying
# it whenever it is newer.

let
  playlistUrl = "https://www.youtube.com/playlist?list=LM";
  musicDir = "/data/music/singlefolder";

  sync = pkgs.writers.writePython3Bin "ytmusic-sync" { flakeIgnore = [ "E501" ]; } (
    builtins.readFile ./ytmusic/sync.py
  );
in
{
  systemd.services.ytmusic-sync = {
    description = "Download new liked YouTube Music tracks";
    after = [
      "network-online.target"
      "data.mount"
    ];
    wants = [ "network-online.target" ];
    requires = [ "data.mount" ];

    path = [
      pkgs.yt-dlp
      pkgs.ffmpeg-full
      pkgs.python3Packages.mutagen # yt-dlp embeds Opus cover art through mutagen
    ];

    environment = {
      PLAYLIST_URL = playlistUrl;
      MUSIC_DIR = musicDir;
      REPO_COOKIES = "${settings.system_repo_root}/secrets/gitcrypt/yt-music-cookies.txt";
      YTDLP = "${pkgs.yt-dlp}/bin/yt-dlp";
    };

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${sync}/bin/ytmusic-sync";
      # The folder is robert:navidrome 2770 and the repo (cookies) is
      # robert's, so run as robert; 0002 keeps the group-writable setgid
      # layout the rest of the library has.
      User = "robert";
      Group = "navidrome";
      UMask = "0002";
      StateDirectory = "ytmusic-sync";
      # Hourly, so a hung run must not sit on top of the next one.
      TimeoutStartSec = "50m";
    };
  };

  systemd.timers.ytmusic-sync = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "10m";
      OnUnitActiveSec = "1h";
      # Spread the hourly run, YouTube dislikes clockwork.
      RandomizedDelaySec = "5m";
      Persistent = true;
      Unit = "ytmusic-sync.service";
    };
  };
}
