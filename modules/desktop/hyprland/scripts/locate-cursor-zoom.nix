{ pkgs, ... }:
pkgs.writeShellScriptBin "locate-cursor-zoom" ''
  # "Find my cursor" — zooms 3× around cursor for a moment, then restores
  # This is the GNOME/KDE-style "locate pointer" effect
  #
  # Usage: locate-cursor-zoom [multiplier] [duration_seconds]
  # Defaults: 3× zoom, 1.5 seconds

  MULTIPLIER="''${1:-3.0}"
  DURATION="''${2:-1.5}"

  # Read current zoom factor
  CURRENT_ZOOM=$(hyprctl getoption cursor:zoom_factor -j | ${pkgs.jq}/bin/jq -r '.float')
  if [ -z "$CURRENT_ZOOM" ] || [ "$CURRENT_ZOOM" = "null" ]; then
    CURRENT_ZOOM="1.0"
  fi

  # Bail if already zoomed (avoid stacking)
  if [ "$(echo "$CURRENT_ZOOM > 1.0" | ${pkgs.bc}/bin/bc -l)" -eq 1 ]; then
    exit 0
  fi

  # Zoom in
  hyprctl keyword cursor:zoom_factor "$MULTIPLIER" > /dev/null 2>&1

  # Wait, then restore
  sleep "$DURATION"
  hyprctl keyword cursor:zoom_factor "$CURRENT_ZOOM" > /dev/null 2>&1
''
