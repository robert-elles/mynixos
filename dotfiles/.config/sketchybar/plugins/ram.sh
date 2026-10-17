#!/bin/sh

# Memory pressure plugin.
#
# "Used %" is meaningless on macOS (caches fill RAM on purpose). Instead show
# memory pressure, the same signal as Activity Monitor's pressure graph:
#   - percent = 100 - kern.memorystatus_level (kernel's "free" percentage)
#   - color   = kern.memorystatus_vm_pressure_level (1 normal, 2 warn, 4 critical)
# Swap in use is appended when significant (>= 1 GB), since heavy swapping is
# the practical symptom of running out of RAM.

free_pct="$(sysctl -n kern.memorystatus_level 2>/dev/null)"
level="$(sysctl -n kern.memorystatus_vm_pressure_level 2>/dev/null)"

case "$free_pct" in '' | *[!0-9]*) free_pct=100 ;; esac
pressure=$((100 - free_pct))

case "$level" in
4) color="${COLOR_RED:-0xffed8796}" ;;
2) color="${COLOR_PEACH:-0xfff5a97f}" ;;
*) color="${COLOR_FG:-0xffcad3f5}" ;;
esac

# "total = 12288,00M  used = 11011,19M  free = ..." (decimal sep is locale-dependent)
swap_gb="$(sysctl -n vm.swapusage 2>/dev/null |
    awk '{ for (i = 1; i <= NF; i++) if ($i == "used") { v = $(i + 2); sub(/[.,].*/, "", v); printf "%d", v / 1024; exit } }')"

label="${pressure}%"
case "$swap_gb" in
'' | *[!0-9]*) ;;
*) [ "$swap_gb" -ge 1 ] && label="${label} 󰾴${swap_gb}G" ;;
esac

sketchybar --set ram_usage label="$label" label.color="$color"
