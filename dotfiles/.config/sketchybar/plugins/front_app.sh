#!/bin/sh

# Focused application name, truncated so a long name cannot push the
# right-hand items off the bar.

name="$INFO"
[ -z "$name" ] && exit 0

max=28
if [ "${#name}" -gt "$max" ]; then
    name="$(printf '%.*s' $((max - 1)) "$name")…"
fi

sketchybar --set "$NAME" label="$name"
