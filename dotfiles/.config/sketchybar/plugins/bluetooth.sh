#!/bin/sh

# Bluetooth state and connected device names (via system_profiler, ~0.1s).

info="$(system_profiler SPBluetoothDataType -json 2>/dev/null |
    jq -r '.SPBluetoothDataType[0]
        | (.controller_properties.controller_state // ""),
          ([.device_connected[]? | keys[]] | join(", "))')"

state="$(printf '%s\n' "$info" | sed -n 1p)"
devices="$(printf '%s\n' "$info" | sed -n 2p)"

if [ "$state" != "attrib_on" ]; then
    sketchybar --set "$NAME" icon="󰂲" icon.color="${COLOR_DIM:-0xff8087a2}" \
        label.drawing=off
elif [ -n "$devices" ]; then
    sketchybar --set "$NAME" icon="󰂱" icon.color="${COLOR_ACCENT:-0xff8aadf4}" \
        label="$devices" label.drawing=on
else
    sketchybar --set "$NAME" icon="󰂯" icon.color="${COLOR_FG:-0xffcad3f5}" \
        label.drawing=off
fi
