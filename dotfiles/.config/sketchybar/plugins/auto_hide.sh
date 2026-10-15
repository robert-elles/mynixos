#!/bin/sh

# When the cursor reaches the top of the screen macOS reveals its own menu
# bar on top of us. Rather than hiding the bar entirely (which would leave
# the menu bar text floating over the wallpaper and hard to read), keep the
# bar on screen but blank it: hide every item and switch to an opaque dark
# background. That gives the native menu bar a solid backdrop.

BAR_COLOR="${COLOR_BG:-0xcc1e2030}"
BACKDROP_COLOR="${COLOR_BACKDROP:-0xf21e2030}"

case "$SENDER" in
"cursor_at_top")
    sketchybar --bar color="$BACKDROP_COLOR" blur_radius=0 \
        --set '/.*/' drawing=off \
        --set auto_hide_trigger drawing=off
    ;;
"cursor_away_from_top")
    sketchybar --bar color="$BAR_COLOR" blur_radius=30 \
        --set '/.*/' drawing=on \
        --set auto_hide_trigger drawing=off
    ;;
esac
