{ pkgs, ... }:
pkgs.writeShellScriptBin "locate-cursor" ''
  # "Find my cursor" — briefly makes cursor huge, then restores
  # Works by temporarily swapping cursor size via hyprctl keyword
  #
  # Usage: locate-cursor [duration_seconds]
  # Default duration: 1.5 seconds

  DURATION="''${1:-1.5}"
  BIG_SIZE=96

  # Read current cursor size (default to 24 if unavailable)
  CURRENT_SIZE=$(hyprctl getoption cursor:hyprcursor_size -j 2>/dev/null | ${pkgs.jq}/bin/jq -r '.int // empty' 2>/dev/null)
  if [ -z "$CURRENT_SIZE" ] || [ "$CURRENT_SIZE" = "null" ]; then
    CURRENT_SIZE="''${XCURSOR_SIZE:-24}"
  fi

  # Bail if already at big size (avoid double-trigger issues)
  if [ "$CURRENT_SIZE" -ge "$BIG_SIZE" ] 2>/dev/null; then
    exit 0
  fi

  # Make cursor big
  hyprctl keyword cursor:hyprcursor_size "$BIG_SIZE" > /dev/null 2>&1

  # Wait, then restore
  sleep "$DURATION"
  hyprctl keyword cursor:hyprcursor_size "$CURRENT_SIZE" > /dev/null 2>&1
''
