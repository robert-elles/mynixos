#!/usr/bin/env bash

BATT="$(pmset -g batt)"
PERCENTAGE="$(echo "$BATT" | grep -o '[0-9]\+%' | head -1 | cut -d% -f1)"
CHARGING="$(echo "$BATT" | grep -c "AC Power")"

if [[ -z "$PERCENTAGE" ]]; then
    exit 0
fi

if [[ "$CHARGING" -ne 0 ]]; then
    # Plugged in: show a charging bolt regardless of level.
    ICON="󰂄"
    if [[ "$PERCENTAGE" -ge 95 ]]; then
        ICON_COLOR="${COLOR_GREEN:-0xffa6da95}"
    else
        ICON_COLOR="${COLOR_TEAL:-0xff8bd5ca}"
    fi
else
    case ${PERCENTAGE} in
    9[0-9] | 100)
        ICON="󰁹"
        ICON_COLOR="${COLOR_GREEN:-0xffa6da95}"
        ;;
    [6-8][0-9])
        ICON="󰂀"
        ICON_COLOR="${COLOR_GREEN:-0xffa6da95}"
        ;;
    [3-5][0-9])
        ICON="󰁾"
        ICON_COLOR="${COLOR_YELLOW:-0xffeed49f}"
        ;;
    [1-2][0-9])
        ICON="󰁻"
        ICON_COLOR="${COLOR_PEACH:-0xfff5a97f}"
        ;;
    *)
        ICON="󰁺"
        ICON_COLOR="${COLOR_RED:-0xffed8796}"
        ;;
    esac
fi

sketchybar --set "$NAME" \
    icon="$ICON" \
    icon.color="$ICON_COLOR" \
    label="${PERCENTAGE}%"
