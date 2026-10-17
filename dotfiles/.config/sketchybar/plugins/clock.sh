#!/bin/sh

# Weekday + date + time, e.g. "Mi 15.10  14:32".
sketchybar --set "$NAME" label="$(LC_TIME=de_DE.UTF-8 date '+%d.%m %H:%M')"
