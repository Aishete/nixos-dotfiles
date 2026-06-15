{ pkgs, ... }:
pkgs.writeShellScriptBin "locate-cursor-release" ''
  # Release handler: smoothly shrinks cursor icon back to default
  THEME="macOS"
  STEP=2
  TARGET="''${XCURSOR_SIZE:-24}"

  # Current size is whatever the cursor is now (likely 96 from press)
  CURRENT=96

  while [ "$CURRENT" -gt "$TARGET" ]; do
    CURRENT=$((CURRENT - STEP))
    if [ "$CURRENT" -lt "$TARGET" ]; then
      CURRENT=$TARGET
    fi
    hyprctl setcursor "$THEME" "$CURRENT" > /dev/null 2>&1
    sleep 0.015
  done

  # Make sure we land exactly on target
  hyprctl setcursor "$THEME" "$TARGET" > /dev/null 2>&1
''
