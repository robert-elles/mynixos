#!/usr/bin/env bash
# Toggle GTA IV between the current (FusionFix + gilian modpack) setup and
# GTA4-RTX (RTX Remix compat mod 1.5.2) + dlssg_for_sm86 frame generation.
#
#   gta4-rtx-dlssg.sh install    # snapshot current mod files, install RTX + FG
#   gta4-rtx-dlssg.sh uninstall  # remove RTX + FG, restore snapshot
#   gta4-rtx-dlssg.sh status
#
# Runs on leopard. Nothing outside the game dir is touched (savegames live in
# GTAIV/Savefiles and are never moved). Steam launch options (edit localconfig.vdf only
# while Steam is stopped):
#   WINEDLLOVERRIDES="version=n,b" PROTON_NVIDIA_NVCUDA=1 ~/Downloads/gta4mods/vkfix/launch-env.sh %command%
# FG is left OFF (rtx.dlfg.enable = False): dlssg 0.4.0 has no vulkan FG path, see memory.md.
set -euo pipefail

G="$HOME/.local/share/Steam/steamapps/common/Grand Theft Auto IV/GTAIV"
RTX_SRC="$G/_backup-rtx-remix-content"                      # previous RTX 1.5.2 install (kept read-only)
FG_SRC="$HOME/Downloads/gta4mods/dlssg_for_sm86-0.4.0/extracted"
SNAP="$G/_backup-pre-rtx-dlssg"                             # snapshot of the non-RTX state
MARK="$G/.rtx-dlssg-installed"                              # list of items installed by us

# Items of the current setup that conflict with RTX and are moved away.
CURRENT_ITEMS=(d3d9.dll dinput8.dll vulkan.dll d3d9.cfg commandline.txt plugins update TLAD/update TBoGT/update)

cd "$G"

running() { pgrep -fi 'GTAIV\.exe|NvRemixBridge\.exe' >/dev/null; }

status() {
  if [ -f "$MARK" ]; then echo "RTX + dlssg installed"; else echo "not installed (normal setup)"; fi
  [ -d "$SNAP" ] && echo "snapshot present: $SNAP"
  return 0
}

install() {
  [ -f "$MARK" ] && { echo "already installed"; exit 1; }
  [ -e "$SNAP" ] && { echo "snapshot $SNAP already exists - refusing to overwrite"; exit 1; }
  [ -d "$RTX_SRC" ] && [ -f "$FG_SRC/version.dll" ] || { echo "sources missing"; exit 1; }
  running && { echo "quit the game first"; exit 1; }

  # 1. move current state away (same fs -> instant, lossless)
  mkdir -p "$SNAP/TLAD" "$SNAP/TBoGT"
  for i in "${CURRENT_ITEMS[@]}"; do [ -e "$i" ] && mv "$i" "$SNAP/$i"; done
  mkdir -p TLAD/update TBoGT/update

  # 2. copy RTX install (everything in the backup; update-base -> update)
  : > "$MARK"
  for p in "$RTX_SRC"/* "$RTX_SRC"/.trex; do
    n=$(basename "$p"); dst=$n; [ "$n" = update-base ] && dst=update
    cp -a "$p" "$G/$dst"; echo "$dst" >> "$MARK"
  done
  echo TLAD/update >> "$MARK"; echo TBoGT/update >> "$MARK"

  # 3. frame generation: proxy goes next to NvRemixBridge.exe (64-bit renderer)
  cp -a "$FG_SRC/version.dll" "$FG_SRC/dlssg_sm86.ini" "$FG_SRC/dlssg_sm86" "$G/.trex/"
  # keep original line endings (the ini is LF)
  sed -i 's/^Level=1\(\r\?\)$/Level=2\1/' "$G/.trex/dlssg_sm86.ini"
  echo "installed (FG off). Set Steam launch options, see header."
}

uninstall() {
  [ -f "$MARK" ] || { echo "not installed"; exit 1; }
  [ -d "$SNAP" ] || { echo "snapshot missing!"; exit 1; }
  running && { echo "quit the game first"; exit 1; }
  while read -r i; do [ -n "$i" ] && rm -rf -- "${G:?}/$i"; done < "$MARK"
  for i in "${CURRENT_ITEMS[@]}"; do [ -e "$SNAP/$i" ] && mv "$SNAP/$i" "$i"; done
  rmdir "$SNAP/TLAD" "$SNAP/TBoGT" "$SNAP"
  rm "$MARK"
  echo "restored. Remove the Steam launch options again."
}

case "${1:-status}" in
  install) install ;; uninstall) uninstall ;; status) status ;;
  *) echo "usage: $0 install|uninstall|status"; exit 1 ;;
esac
