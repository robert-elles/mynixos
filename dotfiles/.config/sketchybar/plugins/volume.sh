#!/bin/sh

# Output volume with a level-appropriate icon.
# The volume_change event provides $INFO (0-100); fall back to osascript.

vol="$INFO"
case "$vol" in
'' | *[!0-9]*)
    vol="$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)"
    ;;
esac

case "$vol" in
'' | *[!0-9]*) vol=0 ;;
esac

muted="$(osascript -e 'output muted of (get volume settings)' 2>/dev/null)"

if [ "$muted" = "true" ] || [ "$vol" -eq 0 ]; then
    icon="󰝟"
    color="$COLOR_DIM"
elif [ "$vol" -gt 60 ]; then
    icon="󰕾"
    color="$COLOR_FG"
elif [ "$vol" -gt 20 ]; then
    icon="󰖀"
    color="$COLOR_FG"
else
    icon="󰕿"
    color="$COLOR_FG"
fi

sketchybar --set "$NAME" \
    icon="$icon" \
    icon.color="${color:-0xffcad3f5}" \
    label="${vol}%"
