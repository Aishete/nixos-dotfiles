{ pkgs, ... }:
pkgs.writeShellScriptBin "locate-cursor-release" ''
  # Release handler: smoothly shrinks cursor icon back to normal
  STEP=8
  TARGET="''${XCURSOR_SIZE:-24}"

  CURRENT=$(hyprctl getoption cursor:hyprcursor_size -j 2>/dev/null | ${pkgs.jq}/bin/jq -r '.int // empty' 2>/dev/null)
  if [ -z "$CURRENT" ] || [ "$CURRENT" = "null" ]; then
    CURRENT=96
  fi

  if [ "$CURRENT" -le "$TARGET" ] 2>/dev/null; then
    exit 0
  fi

  while [ "$CURRENT" -gt "$TARGET" ]; do
    CURRENT=$((CURRENT - STEP))
    if [ "$CURRENT" -lt "$TARGET" ]; then
      CURRENT=$TARGET
    fi
    hyprctl keyword cursor:hyprcursor_size "$CURRENT" > /dev/null 2>&1
    sleep 0.02
  done
''
