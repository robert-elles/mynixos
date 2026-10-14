#!/bin/sh

# Renders the single focused-workspace indicator.
# FOCUSED_WORKSPACE is supplied by the hyprspace_workspace_change event
# (see exec-on-workspace-change in hyprspace/config.toml).

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

sketchybar --set "$NAME" icon="$focused"
