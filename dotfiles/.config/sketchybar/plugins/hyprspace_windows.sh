#!/bin/sh

# Shows how many windows live on the focused workspace, and which other
# workspaces are occupied. Keeps the bar informative without drawing an
# item per persistent workspace.

if [ -n "${HYPRSPACE_BIN:-}" ]; then
    HYPRSPACE_BIN="$HYPRSPACE_BIN"
elif command -v brew >/dev/null 2>&1; then
    HYPRSPACE_BIN="$(brew --prefix)/bin/hyprspace"
elif [ "$(uname -m)" = "arm64" ]; then
    HYPRSPACE_BIN="/opt/homebrew/bin/hyprspace"
else
    HYPRSPACE_BIN="/usr/local/bin/hyprspace"
fi

if [ ! -x "$HYPRSPACE_BIN" ]; then
    HYPRSPACE_BIN="$(command -v hyprspace 2>/dev/null || true)"
fi

focused="$FOCUSED_WORKSPACE"
if [ -z "$focused" ]; then
    focused="$("$HYPRSPACE_BIN" list-workspaces --focused 2>/dev/null)"
fi

[ -z "$focused" ] && exit 0

count="$("$HYPRSPACE_BIN" list-windows --workspace "$focused" 2>/dev/null | grep -c .)"
case "$count" in
'' | *[!0-9]*) count=0 ;;
esac

# Other workspaces that currently hold windows.
others="$("$HYPRSPACE_BIN" list-workspaces --monitor all --empty no 2>/dev/null |
    grep -v "^${focused}$" | tr -d ' ' | paste -sd' ' -)"

if [ -n "$others" ]; then
    sketchybar --set "$NAME" label="$count  ·  $others"
else
    sketchybar --set "$NAME" label="$count"
fi
