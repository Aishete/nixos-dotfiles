{ pkgs, ... }:
pkgs.writeShellScriptBin "locate-cursor-press" ''
  # Hold-to-activate: smoothly enlarges cursor icon, stays big until release
  STEP=8
  TARGET=96

  CURRENT=$(hyprctl getoption cursor:hyprcursor_size -j 2>/dev/null | ${pkgs.jq}/bin/jq -r '.int // empty' 2>/dev/null)
  if [ -z "$CURRENT" ] || [ "$CURRENT" = "null" ]; then
    CURRENT="''${XCURSOR_SIZE:-24}"
  fi

  if [ "$CURRENT" -ge "$TARGET" ] 2>/dev/null; then
    exit 0
  fi

  while [ "$CURRENT" -lt "$TARGET" ]; do
    CURRENT=$((CURRENT + STEP))
    if [ "$CURRENT" -gt "$TARGET" ]; then
      CURRENT=$TARGET
    fi
    hyprctl keyword cursor:hyprcursor_size "$CURRENT" > /dev/null 2>&1
    sleep 0.02
  done
''
