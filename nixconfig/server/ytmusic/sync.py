"""Mirror a YouTube (Music) playlist into a flat local folder as Opus.

Run hourly by the ytmusic-sync service (nixconfig/server/ytmusic-sync.nix).

Only new tracks are fetched. "New" is decided twice, because the download
archive alone would re-download the ~1500 tracks that were imported into
/data/music/singlefolder by other means:

1. download archive  - video ids seen by an earlier run, the cheap check.
2. existing filename - the name yt-dlp would write, compared against the
   folder ignoring the extension, so the .m4a files already in the library
   are recognised as the same track. Those ids are then written to the
   archive, so step 1 catches them from the next run on (the whole playlist
   is extracted once, afterwards only genuinely new likes are).

Audio is the native Opus stream, remuxed into .opus rather than re-encoded
(verified: the audio stream md5 is unchanged), with metadata and a square
cover embedded.
"""

import os
import shutil
import subprocess
import sys
import unicodedata
from pathlib import Path

MUSIC_DIR = Path(os.environ.get("MUSIC_DIR", "/data/music/singlefolder"))
STATE_DIR = Path(os.environ.get("STATE_DIRECTORY", "/var/lib/ytmusic-sync"))
REPO_COOKIES = Path(os.environ["REPO_COOKIES"])
PLAYLIST_URL = os.environ["PLAYLIST_URL"]
YTDLP = os.environ.get("YTDLP", "yt-dlp")

ARCHIVE = STATE_DIR / "archive.txt"
COOKIES = STATE_DIR / "cookies.txt"

# Extensions that count as "this track is already here". The library is m4a
# today and opus from now on; the rest are cheap insurance.
AUDIO_EXT = {".opus", ".m4a", ".mp3", ".flac", ".ogg", ".oga", ".wav", ".webm"}

# "Artist - Title", matching how the existing files are named. Topic uploads
# carry artist/track; for plain uploads yt-dlp falls back to uploader/title.
OUTTMPL = "%(artist,uploader)s - %(track,title)s.%(ext)s"

# yt-dlp embeds Opus thumbnails with mutagen, so EmbedThumbnail never shells
# out to ffmpeg and cropping has to happen while converting the thumbnail.
SQUARE_CROP = (
    "ThumbnailsConvertor+ffmpeg_o:-c:v mjpeg "
    "-vf crop=\"'if(gt(ih,iw),iw,ih)':'if(gt(iw,ih),ih,iw)'\""
)


def log(msg: str) -> None:
    print(msg, flush=True)


def run(args: list[str], **kwargs) -> subprocess.CompletedProcess:
    return subprocess.run([YTDLP, *args], text=True, **kwargs)


def sync_cookies() -> None:
    """Keep a working copy, so yt-dlp's cookie rotation never touches the repo.

    Refreshed whenever the git-crypt'ed file is newer, which is how a manual
    re-export gets picked up.
    """
    if not REPO_COOKIES.exists():
        sys.exit(f"cookie file missing: {REPO_COOKIES}")
    if not COOKIES.exists() or REPO_COOKIES.stat().st_mtime > COOKIES.stat().st_mtime:
        shutil.copyfile(REPO_COOKIES, COOKIES)
        COOKIES.chmod(0o600)
        log(f"refreshed cookies from {REPO_COOKIES}")


def normalise(stem: str) -> str:
    """Compare names without tripping over unicode form or spacing."""
    return " ".join(unicodedata.normalize("NFC", stem).split()).casefold()


def existing_tracks() -> set[str]:
    if not MUSIC_DIR.is_dir():
        sys.exit(f"music folder missing: {MUSIC_DIR}")
    return {
        normalise(p.stem)
        for p in MUSIC_DIR.iterdir()
        if p.is_file() and p.suffix.lower() in AUDIO_EXT
    }


def archived_ids() -> set[str]:
    if not ARCHIVE.exists():
        return set()
    ids = set()
    for line in ARCHIVE.read_text(encoding="utf-8").splitlines():
        parts = line.split()
        if len(parts) == 2:
            ids.add(parts[1])
    return ids


def playlist_ids() -> list[str]:
    proc = run(
        [
            "--cookies", str(COOKIES),
            "--flat-playlist",
            "--print", "%(id)s",
            PLAYLIST_URL,
        ],
        capture_output=True,
    )
    if proc.returncode != 0:
        sys.stderr.write(proc.stderr)
        sys.exit(
            "could not read the playlist. Liked Music needs logged-in cookies "
            f"in {REPO_COOKIES} (a logged-out export only has PREF/SOCS/VISITOR_*)."
        )
    return [line.strip() for line in proc.stdout.splitlines() if line.strip()]


def planned_names(ids: list[str]) -> dict[str, str]:
    """id -> filename stem yt-dlp would write, without downloading anything."""
    proc = run(
        [
            "--cookies", str(COOKIES),
            "--ignore-errors",
            "--skip-download",
            "--paths", str(MUSIC_DIR),
            "--output", OUTTMPL,
            # id is 11 chars and space-free, so the stem can be split off even
            # when it contains anything at all.
            "--print", "%(id)s %(filename)s",
            *[f"https://www.youtube.com/watch?v={i}" for i in ids],
        ],
        capture_output=True,
    )
    if proc.stderr:
        sys.stderr.write(proc.stderr)
    names = {}
    for line in proc.stdout.splitlines():
        video_id, _, filename = line.partition(" ")
        if filename:
            names[video_id] = Path(filename).stem
    return names


# Errors that will still be errors next hour, so the track is written off
# instead of retried. Anything else (network, throttling, a missing PO token
# on an otherwise fine video) is left alone and tried again.
PERMANENT = (
    "video unavailable",
    "private video",
    "video has been removed",
    "account associated with this video has been terminated",
    "who has blocked it in your country",
    "not available in your country",
    "members-only content",
    "this live event will begin",
)


def permanently_gone(video_id: str, stderr: str) -> bool:
    for line in stderr.splitlines():
        if line.startswith("ERROR:") and video_id in line:
            return any(p in line.casefold() for p in PERMANENT)
    return False


def mark_archived(ids: list[str]) -> None:
    with ARCHIVE.open("a", encoding="utf-8") as fh:
        for video_id in ids:
            fh.write(f"youtube {video_id}\n")


def download(ids: list[str]) -> str:
    proc = run(
        [
            "--cookies", str(COOKIES),
            "--ignore-errors",
            "--no-overwrites",
            # Prefer the native Opus stream so extraction is a remux rather
            # than a second lossy encode. A few videos offer no audio-only
            # stream at all, hence the fallback to a combined one, which
            # ffmpeg then has to transcode.
            "--format", "bestaudio[acodec=opus]/bestaudio/best",
            "--extract-audio",
            "--audio-format", "opus",
            "--embed-metadata",
            "--embed-thumbnail",
            "--convert-thumbnails", "jpg",
            "--postprocessor-args", SQUARE_CROP,
            "--download-archive", str(ARCHIVE),
            "--paths", str(MUSIC_DIR),
            "--output", OUTTMPL,
            "--sleep-interval", "5",
            "--max-sleep-interval", "15",
            *[f"https://www.youtube.com/watch?v={i}" for i in ids],
        ],
        stderr=subprocess.PIPE,
    )
    sys.stderr.write(proc.stderr)
    return proc.stderr


def main() -> None:
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    sync_cookies()

    have = existing_tracks()
    log(f"{len(have)} tracks in {MUSIC_DIR}")

    ids = playlist_ids()
    log(f"{len(ids)} tracks in the playlist")

    candidates = [i for i in ids if i not in archived_ids()]
    if not candidates:
        log("nothing new")
        return
    log(f"{len(candidates)} not in the archive, resolving names")

    names = planned_names(candidates)
    already = [i for i in candidates if normalise(names.get(i, "")) in have]
    missing = [i for i in candidates if i not in already and i in names]

    if already:
        mark_archived(already)
        log(f"{len(already)} already in the folder, recorded in the archive")
    if not missing:
        log("nothing to download")
        return

    log(f"downloading {len(missing)} tracks")
    stderr = download(missing)

    # yt-dlp only archives what it downloaded, and exits non-zero when any
    # single item failed even under --ignore-errors. A few likes are
    # permanently gone (deleted, private, region locked), so retrying them
    # every hour would both waste requests and keep the unit red forever.
    # Archive those by hand; everything else stays out of the archive and is
    # retried on the next run.
    got = [i for i in missing if i in archived_ids()]
    dead = [i for i in missing if i not in got and permanently_gone(i, stderr)]
    if dead:
        mark_archived(dead)
    retry = len(missing) - len(got) - len(dead)
    log(f"downloaded {len(got)}/{len(missing)}, {len(dead)} unavailable, {retry} to retry")


if __name__ == "__main__":
    main()
