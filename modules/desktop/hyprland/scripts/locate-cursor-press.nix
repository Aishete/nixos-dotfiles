{ pkgs, ... }:
pkgs.writeShellScriptBin "locate-cursor-press" ''
  # Hold-to-activate: smoothly enlarges cursor icon, stays big until release
  THEME="macOS"
  STEP=8
  TARGET=96

  CURRENT=$(hyprctl getoption cursor:hotspot_padding -j > /dev/null 2>&1; echo "''${XCURSOR_SIZE:-24}")

  while [ "$CURRENT" -lt "$TARGET" ]; do
    CURRENT=$((CURRENT + STEP))
    if [ "$CURRENT" -gt "$TARGET" ]; then
      CURRENT=$TARGET
    fi
    hyprctl setcursor "$THEME" "$CURRENT" > /dev/null 2>&1
    sleep 0.02
  done
''
