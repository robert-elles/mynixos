#!/bin/sh

# Network indicator.
#
# NOTE: macOS 15+/26 redacts the Wi-Fi SSID ("<redacted>") for processes
# without Location Services permission. Run once to un-redact it for
# `ipconfig getsummary`:
#     sudo ipconfig setverbose 1
# Without that, fall back to the search domain scoped to the Wi-Fi
# interface (not the global one, which may belong to a VPN), then the IP.

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

label="$(ipconfig getsummary "$wifi_device" 2>/dev/null |
    awk -F' : ' '/^ +SSID : / { print $2; exit }')"
[ "$label" = "<redacted>" ] && label=""

# Search domain of a resolver bound to the Wi-Fi interface.
if [ -z "$label" ]; then
    label="$(scutil --dns 2>/dev/null | awk -v dev="($wifi_device)" '
        /^resolver/ { sd = "" }
        /search domain\[0\]/ { sd = $NF }
        /if_index/ && $NF == dev && sd != "" { print sd; exit }')"
fi

[ -z "$label" ] && label="$ip"

sketchybar --set "$NAME" \
    icon="󰖩" \
    icon.color="${COLOR_GREEN:-0xffa6da95}" \
    label="$label"
