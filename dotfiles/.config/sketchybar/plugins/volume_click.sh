#!/bin/sh

# Toggle mute on click.

muted="$(osascript -e 'output muted of (get volume settings)' 2>/dev/null)"

if [ "$muted" = "true" ]; then
    osascript -e 'set volume without output muted' 2>/dev/null
else
    osascript -e 'set volume with output muted' 2>/dev/null
fi

exec "$(dirname "$0")/volume.sh"
