{ pkgs, ... }:
pkgs.writeShellScriptBin "locate-cursor-release" ''
  # Release handler: smoothly shrinks cursor icon back to normal
  THEME="macOS"
  STEP=8
  TARGET="''${XCURSOR_SIZE:-24}"
  START=96

  CURRENT=$START

  while [ "$CURRENT" -gt "$TARGET" ]; do
    CURRENT=$((CURRENT - STEP))
    if [ "$CURRENT" -lt "$TARGET" ]; then
      CURRENT=$TARGET
    fi
    hyprctl setcursor "$THEME" "$CURRENT" > /dev/null 2>&1
    sleep 0.02
  done
''
