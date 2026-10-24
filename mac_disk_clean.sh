#!/usr/bin/env bash
#
# Interactive macOS disk cleanup.
# Every step asks for confirmation before running. Nothing happens on [N]/Enter.
#
#   ./mac_disk_clean.sh            # run all groups
#   ./mac_disk_clean.sh --dry-run  # print commands only, never execute
#
# Groups:
#   1  Safe caches      - regenerate automatically, zero risk
#   2  Logs             - zero risk
#   3  ML models        - re-downloadable, slow
#   4  node_modules     - dormant projects only (last commit shown)
#   5  .devenv gcroots  - unpins /nix store paths; devenv shell regenerates
#   6  Nix GC           - removes old generations, you lose rollback
#   7  Containers       - docker prune + rancher VM trim
#   8  Trash            - empty ~/.Trash

set -uo pipefail

DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

BOLD=$'\033[1m'; DIM=$'\033[2m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'
CYAN=$'\033[36m'; RED=$'\033[31m'; RESET=$'\033[0m'

FREED_BEFORE=""

avail_kb() { df -k / | awk 'NR==2 {print $4}'; }

human() { # bytes -> human
  awk -v b="$1" 'BEGIN{
    split("B KB MB GB TB",u," "); i=1
    while (b>=1024 && i<5) {b/=1024; i++}
    printf "%.1f%s", b, u[i]
  }'
}

header() {
  echo
  echo "${BOLD}${CYAN}=== $* ===${RESET}"
}

note() { echo "${DIM}    $*${RESET}"; }

# ask "<description>" "<size estimate>" "<command...>"
ask() {
  local desc="$1" size="$2"; shift 2
  local cmd="$*"

  echo
  echo "${BOLD}${desc}${RESET} ${DIM}(~${size})${RESET}"
  echo "${DIM}  \$ ${cmd}${RESET}"

  if (( DRY_RUN )); then
    echo "  ${YELLOW}[dry-run] skipped${RESET}"
    return 0
  fi

  local reply
  read -r -p "  Run this? [y/N] " reply
  case "$reply" in
    [yY]|[yY][eE][sS]) ;;
    *) echo "  ${DIM}skipped${RESET}"; return 0 ;;
  esac

  local before after
  before=$(avail_kb)
  if eval "$cmd"; then
    after=$(avail_kb)
    local delta=$(( (after - before) * 1024 ))
    if (( delta > 0 )); then
      echo "  ${GREEN}done, freed $(human "$delta")${RESET}"
    else
      echo "  ${GREEN}done${RESET}"
    fi
  else
    echo "  ${RED}command exited non-zero${RESET}"
  fi
}

# ask_group "<title>" -> returns 1 if user wants to skip the whole group
ask_group() {
  header "$1"
  (( DRY_RUN )) && return 0
  local reply
  read -r -p "  Enter this group? [Y/n] " reply
  case "$reply" in
    [nN]|[nN][oO]) echo "  ${DIM}group skipped${RESET}"; return 1 ;;
    *) return 0 ;;
  esac
}

START_AVAIL=$(avail_kb)
echo "${BOLD}macOS disk cleanup${RESET}"
(( DRY_RUN )) && echo "${YELLOW}DRY RUN - nothing will be executed${RESET}"
echo
df -h / /System/Volumes/Data


# ---------------------------------------------------------------- 1. caches
if ask_group "1. Safe caches"; then

  note "uv archive-v0 is ~21G by du, but entries are HARDLINKED into existing"
  note "venvs, so actual reclaim is much less. 'prune' removes only unused."
  ask "uv cache prune (unused entries only)" "a few GB" \
      "uv cache prune"
  ask "uv cache clean (ALL 21G, every venv re-downloads)" "21G" \
      "uv cache clean"

  ask "npm cache" "4.8G" \
      "npm cache clean --force"

  ask "gradle build caches" "4.5G" \
      "rm -rf ~/.gradle/caches"
  ask "gradle wrapper distributions + bundled JDKs" "2.1G" \
      "rm -rf ~/.gradle/wrapper ~/.gradle/jdks"

  ask "go build + module + test cache" "1.0G" \
      "go clean -cache -modcache -testcache"

  ask "playwright browsers (restore: npx playwright install)" "1.5G" \
      "rm -rf ~/Library/Caches/ms-playwright"

  ask "homebrew downloads and old versions" "760M" \
      "brew cleanup --prune=all"

  ask "node-gyp headers" "415M" \
      "rm -rf ~/Library/Caches/node-gyp"

  note "close browsers first, otherwise they rewrite the cache immediately"
  ask "browser caches (Chrome, Firefox, Edge)" "2.5G" \
      "rm -rf ~/Library/Caches/Google ~/Library/Caches/Firefox ~/Library/Caches/'Microsoft Edge'"

  ask "misc dev caches (pip, electron, swiftpm, typescript, gopls)" "300M" \
      "rm -rf ~/Library/Caches/pip ~/Library/Caches/electron ~/Library/Caches/org.swift.swiftpm ~/Library/Caches/typescript ~/Library/Caches/gopls"

  ask "clean devenv leftover symlinks" "unknown" "rm -r ~/.local/share/devenv/gc"
fi


# ------------------------------------------------------------------ 2. logs
if ask_group "2. Logs"; then
  ask "Google logs" "516M" "rm -rf ~/Library/Logs/Google"
  ask "JetBrains logs" "392M" "rm -rf ~/Library/Logs/JetBrains"
  ask "OneDrive logs" "145M" "rm -rf ~/Library/Logs/OneDrive"
  ask "camunda-modeler logs" "132M" "rm -rf ~/Library/Logs/camunda-modeler"
fi


# -------------------------------------------------------------- 3. ML models
if ask_group "3. ML models"; then
  ask "Whispering whisper models" "1.9G" \
      "rm -rf ~/Library/Application\\ Support/com.bradenwong.whisperingwhisper-models"
  ask "huggingface cache" "636M" \
      "rm -rf ~/.cache/huggingface"
fi


# ----------------------------------------------------------- 4. node_modules
if ask_group "4. node_modules of dormant projects"; then
  note "date = last git commit in that repo. today is $(date +%Y-%m-%d)"

  ask "[2025-02] cncode/drsf/bestandssystem-angular" "631M" \
      "rm -rf ~/code/cncode/drsf/bestandssystem-angular/node_modules"
  ask "[2025-03] mcp/db-timetable-mcp" "124M" \
      "rm -rf ~/code/mcp/db-timetable-mcp/node_modules"
  ask "[2025-07] cncode/aon/whitelist-manager-ui" "295M" \
      "rm -rf ~/code/cncode/aon/whitelist-manager-ui/node_modules"
  ask "[2026-01] cncode/aon/insurance-hub-ui" "295M" \
      "rm -rf ~/code/cncode/aon/insurance-hub-ui/node_modules"
  ask "[2026-03] cncode/offline-app/neudorff-sales-app" "992M" \
      "rm -rf ~/code/cncode/offline-app/neudorff-sales-app/node_modules"
  ask "[2026-03] cncode/offline-app/api-backend" "5.4M" \
      "rm -rf ~/code/cncode/offline-app/api-backend/node_modules"

  note "below are recent (>= 2026-07). recommended to KEEP."
  ask "[2026-07] cncode/sms/labeling-helper" "390M" \
      "rm -rf ~/code/cncode/sms/labeling-helper/node_modules"
  ask "[2026-08] cncode/sms/camunda-poc" "38M" \
      "rm -rf ~/code/cncode/sms/camunda-poc/node_modules"
  ask "[2026-09] Nextcloud/code/ttsnewscast/frontend" "292M" \
      "rm -rf ~/Nextcloud/code/ttsnewscast/frontend/node_modules"
  ask "[2026-09] Nextcloud/code/veantur/event-client/renaissance" "978M" \
      "rm -rf ~/Nextcloud/code/veantur/event-client/renaissance/node_modules"
fi


# -------------------------------------------------------- 5. .devenv gcroots
if ask_group "5. Stale .devenv gcroots"; then
  note "non-destructive: 'devenv shell' regenerates these. cost is rebuild time."
  note "they pin /nix store paths, so removing them is what makes nix GC effective."

  for entry in \
    "2024-05|8K|$HOME/Nextcloud/code/learnkotlin" \
    "2025-04|768K|$HOME/Nextcloud/Documents/Bewerbung/Latex" \
    "2025-07|552K|$HOME/code/dshdi" \
    "2025-09|572K|$HOME/Nextcloud/code/bookformat" \
    "2025-09|772K|$HOME/code/cncode/common" \
    "2025-10|343M|$HOME/code/mcp" \
    "2025-11|76M|$HOME/code/cncode/buergschaftsportal" \
    "2026-03|207M|$HOME/code/cncode/offline-app" \
    "2026-03|12M|$HOME/code/cncode/cysmo" \
    "2026-04|49M|$HOME/code/cncode/hyos" \
    "2026-04|270M|$HOME/code/cncode/mcp-bridge" \
    "2026-06|10M|$HOME/Nextcloud/code/fazcast" \
    "2026-06|824K|$HOME/code/cncode/schuler" \
    "2026-08|172K|$HOME/Nextcloud/code/ttsbackend" \
    "2026-08|2.2G|$HOME/Nextcloud/code/jules" \
    "2026-08|9.8M|$HOME/code/cncode/sms/camunda-poc" \
    "2026-08|838M|$HOME/code/cncode/sms" \
    "2026-08|2.4M|$HOME/Nextcloud/code/deployment_vps1" \
    "no-git|40M|$HOME/Nextcloud/code/newsnarrator" \
    "no-git|213M|$HOME/code/cncode/neudorff" \
    "no-git|240M|$HOME/code/ttsnewscast" \
    "no-git|904K|$HOME/code/cncode/concordia" \
    "no-git|256K|$HOME/Nextcloud/code" \
  ; do
    IFS='|' read -r d sz p <<< "$entry"
    [[ -d "$p/.devenv" ]] || continue
    ask "[$d] ${p/#$HOME/\~}/.devenv" "$sz" "rm -rf '$p/.devenv'"
  done

  note "keeping: ttsnewscast, veantur*, polyglot, bsh, vogesen, aon, sms/data-engine-v2"
fi


# ---------------------------------------------------------------- 6. nix gc
if ask_group "6. Nix garbage collection"; then
  note "only ~123M is dead until step 5 ran. generations are the real holders."
  note "you lose the ability to roll back to older generations."

  ask "show what nix would delete (read-only)" "-" \
      "nix-store --gc --print-dead | xargs du -sch 2>/dev/null | tail -1"

  ask "collect unreferenced store paths only (keeps generations)" "varies" \
      "nix store gc"

  note "'sd nixos gc' ends with 'nixos-rebuild boot' which does NOT exist on"
  note "macOS - expect that last line to fail. The GC part before it still works."
  ask "sd nixos gc (full script: nix-env -u, collect-garbage -d, rebuild)" "GBs" \
      "sd nixos gc"

  ask "user generations older than 14 days" "varies" \
      "nix-collect-garbage --delete-older-than 14d"
  ask "root/system old generations (needs sudo)" "varies" \
      "sudo nix-collect-garbage --delete-old"

  ask "optimise store (dedupe via hardlinks, slow but non-destructive)" "varies" \
      "nix store optimise"
fi


# ------------------------------------------------------------- 7. containers
if ask_group "7. Containers"; then
  note "prune removes all stopped containers, unused images, networks, volumes."
  note "the fstrim afterwards is what actually shrinks the Rancher VM disk file."
  ask "docker system prune + trim Rancher VM disk" "3.5G VM" \
      "docker system prune -af --volumes && rdctl shell -- sudo fstrim -v /mnt/data"
fi


# ----------------------------------------------------------------- 8. trash
if ask_group "8. Trash"; then
  CUR=$(du -sh ~/.Trash 2>/dev/null | cut -f1)
  ask "empty ~/.Trash" "${CUR:-0}" \
      "rm -rf ~/.Trash/* ~/.Trash/.[!.]* 2>/dev/null; true"
fi


# ----------------------------------------------------------------- summary
header "Summary"
END_AVAIL=$(avail_kb)
TOTAL=$(( (END_AVAIL - START_AVAIL) * 1024 ))
if (( TOTAL > 0 )); then
  echo "  ${GREEN}${BOLD}Total freed: $(human "$TOTAL")${RESET}"
else
  echo "  ${DIM}No net change.${RESET}"
fi
echo
df -h / /System/Volumes/Data
echo
note "Not covered here, inspect manually if you need more:"
note "  ~/code/cncode                              14G   work repos"
note "  ~/Library/Application Support/Claude-3p    8.3G  live Claude Code VM"
note "  ~/Nextcloud                                22G   synced data"
note "  ~/Library/Application Support/Code|Zed     3.2G  editor state"
