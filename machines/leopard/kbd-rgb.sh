#!/bin/sh
# Utility to control RGB keyboard backlight via hid-ite8291r3 driver

LED_PATH="/sys/class/leds/usb-5-1-3-1::kbd_backlight"

# Find the LED if the path doesn't exist (device might be on different USB port)
if [ ! -d "$LED_PATH" ]; then
  LED_PATH=$(find /sys/class/leds -name "*kbd_backlight" -type d 2>/dev/null | head -1)
  if [ -z "$LED_PATH" ]; then
    echo "Error: Keyboard backlight LED not found"
    exit 1
  fi
fi

COLOR_FILE="$LED_PATH/color"
BRIGHTNESS_FILE="$LED_PATH/brightness"
MAX_BRIGHTNESS=$(cat "$LED_PATH/max_brightness" 2>/dev/null || echo "50")

# Convert hex to RGB (e.g., #FF0000 -> 255 0 0)
hex_to_rgb() {
  hex=$(echo "$1" | tr '[:lower:]' '[:upper:]' | sed 's/^#//')
  r=$(printf "%d" 0x''${hex:0:2} 2>/dev/null || echo "255")
  g=$(printf "%d" 0x''${hex:2:2} 2>/dev/null || echo "255")
  b=$(printf "%d" 0x''${hex:4:2} 2>/dev/null || echo "255")
  echo "$r $g $b"
}

case "$1" in
  set|color)
    if [ -z "$2" ]; then
      echo "Usage: kbd-rgb set <R> <G> <B> | kbd-rgb set #RRGGBB"
      echo "Example: kbd-rgb set 255 0 0    (red)"
      echo "Example: kbd-rgb set #FF0000     (red)"
      exit 1
    fi
    
    # Check if it's a hex color
    if echo "$2" | grep -qE '^#[0-9A-Fa-f]{6}$'; then
      rgb=$(hex_to_rgb "$2")
    elif [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]; then
      rgb="$2 $3 $4"
    else
      echo "Error: Invalid color format. Use 'R G B' or '#RRGGBB'"
      exit 1
    fi
    
    # Some drivers require brightness > 0 before color can be set
    current_brightness=$(cat "$BRIGHTNESS_FILE" 2>/dev/null || echo "0")
    if [ "$current_brightness" -eq 0 ]; then
      echo "Note: Brightness is 0, setting to minimum (1) first..." >&2
      echo "1" > "$BRIGHTNESS_FILE" 2>/dev/null || true
    fi
    
    # Convert RGB to hexadecimal format (RRGGBB) - hid-ite8291r3 expects hex
    # Extract R, G, B values
    r=$(echo "$rgb" | awk '{print $1}')
    g=$(echo "$rgb" | awk '{print $2}')
    b=$(echo "$rgb" | awk '{print $3}')
    
    # Convert to hex (pad with zeros to 2 digits)
    hex_color=$(printf "%02x%02x%02x" "$r" "$g" "$b")
    
    # Try to write the color in hex format - show actual error if it fails
    err=$(echo "$hex_color" > "$COLOR_FILE" 2>&1)
    exit_code=$?
    if [ $exit_code -eq 0 ]; then
      echo "Color set to: RGB($r, $g, $b) = #$hex_color"
    else
      # If hex format fails, try space-separated format as fallback
      err2=$(echo "$rgb" > "$COLOR_FILE" 2>&1)
      exit_code2=$?
      if [ $exit_code2 -eq 0 ]; then
        echo "Color set to: $rgb (space-separated format)"
      else
        echo "Error: Failed to set color" >&2
        echo "File: $COLOR_FILE" >&2
        echo "Tried hex format: $hex_color" >&2
        echo "Tried space format: $rgb" >&2
        if [ -n "$err" ]; then
          echo "Hex format error: $err" >&2
        fi
        if [ -n "$err2" ]; then
          echo "Space format error: $err2" >&2
        fi
        # Check if file is writable
        if [ ! -w "$COLOR_FILE" ]; then
          echo "File is not writable. Current permissions:" >&2
          ls -l "$COLOR_FILE" >&2
          echo "Try running: sudo chmod 666 $COLOR_FILE" >&2
        else
          echo "File appears writable, but write failed. Exit codes: $exit_code (hex), $exit_code2 (space)" >&2
        fi
        exit 1
      fi
    fi
    ;;
  brightness|bright)
    if [ -z "$2" ]; then
      current=$(cat "$BRIGHTNESS_FILE" 2>/dev/null || echo "0")
      echo "Current brightness: $current / $MAX_BRIGHTNESS"
      echo "Usage: kbd-rgb brightness <0-$MAX_BRIGHTNESS>"
      exit 1
    fi
    
    if [ "$2" -ge 0 ] && [ "$2" -le "$MAX_BRIGHTNESS" ] 2>/dev/null; then
      if err=$(echo "$2" > "$BRIGHTNESS_FILE" 2>&1); then
        echo "Brightness set to: $2 / $MAX_BRIGHTNESS"
      else
        echo "Error: Failed to set brightness" >&2
        if [ -n "$err" ]; then
          echo "Error message: $err" >&2
        fi
        exit 1
      fi
    else
      echo "Error: Brightness must be between 0 and $MAX_BRIGHTNESS"
      exit 1
    fi
    ;;
  off)
    if err=$(echo "0" > "$BRIGHTNESS_FILE" 2>&1); then
      echo "Keyboard backlight turned off"
    else
      echo "Error: Failed to turn off backlight" >&2
      if [ -n "$err" ]; then
        echo "Error message: $err" >&2
      fi
      exit 1
    fi
    ;;
  on)
    if err=$(echo "$MAX_BRIGHTNESS" > "$BRIGHTNESS_FILE" 2>&1); then
      echo "Keyboard backlight turned on"
    else
      echo "Error: Failed to turn on backlight" >&2
      if [ -n "$err" ]; then
        echo "Error message: $err" >&2
      fi
      exit 1
    fi
    ;;
  status)
    current_color=$(cat "$COLOR_FILE" 2>/dev/null || echo "N/A")
    current_brightness=$(cat "$BRIGHTNESS_FILE" 2>/dev/null || echo "0")
    echo "LED Path: $LED_PATH"
    echo "Color: $current_color"
    echo "Brightness: $current_brightness / $MAX_BRIGHTNESS"
    ;;
  *)
    echo "RGB Keyboard Backlight Control"
    echo ""
    echo "Usage: kbd-rgb <command> [args]"
    echo ""
    echo "Commands:"
    echo "  set <R> <G> <B>     Set RGB color (0-255 each)"
    echo "  set #RRGGBB          Set color using hex code"
    echo "  brightness <0-$MAX_BRIGHTNESS>  Set brightness level"
    echo "  on                  Turn on backlight (max brightness)"
    echo "  off                 Turn off backlight"
    echo "  status              Show current settings"
    echo ""
    echo "Examples:"
    echo "  kbd-rgb set 255 0 0        # Red"
    echo "  kbd-rgb set #00FF00        # Green"
    echo "  kbd-rgb set 0 0 255        # Blue"
    echo "  kbd-rgb brightness 25      # Set brightness to 25"
    echo "  kbd-rgb off                # Turn off"
    ;;
esac
