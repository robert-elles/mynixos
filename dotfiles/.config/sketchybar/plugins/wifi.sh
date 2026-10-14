#!/bin/sh

# Network indicator.
#
# NOTE: macOS 15+/26 redacts the Wi-Fi SSID for any process that lacks
# Location Services permission (ipconfig/scutil both return "<redacted>"),
# and a shell script cannot hold that permission. So instead of the SSID we
# show the DNS search domain, which identifies the network just as well and
# is not redacted, falling back to the local IP address.

wifi_device="$(networksetup -listallhardwareports 2>/dev/null |
    awk '/Hardware Port: Wi-Fi/ { getline; print $2; exit }')"
[ -z "$wifi_device" ] && wifi_device="en0"

ip="$(ipconfig getifaddr "$wifi_device" 2>/dev/null)"

# Wired fallback: first non-Wi-Fi interface holding an address.
if [ -z "$ip" ]; then
    for dev in en1 en2 en3 en4 en5 en6 en7; do
        [ "$dev" = "$wifi_device" ] && continue
        candidate="$(ipconfig getifaddr "$dev" 2>/dev/null)"
        if [ -n "$candidate" ]; then
            sketchybar --set "$NAME" \
                icon="󰈀" \
                icon.color="${COLOR_GREEN:-0xffa6da95}" \
                label="$candidate"
            exit 0
        fi
    done

    sketchybar --set "$NAME" \
        icon="󰖪" \
        icon.color="${COLOR_RED:-0xffed8796}" \
        label="offline"
    exit 0
fi

# Prefer the DNS search domain as a human-readable network name.
label="$(scutil --dns 2>/dev/null |
    awk '/search domain\[0\]/ { print $NF; exit }')"

[ -z "$label" ] && label="$ip"

sketchybar --set "$NAME" \
    icon="󰖩" \
    icon.color="${COLOR_GREEN:-0xffa6da95}" \
    label="$label"
