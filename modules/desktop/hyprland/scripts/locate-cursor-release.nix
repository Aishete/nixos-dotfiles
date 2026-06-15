{ pkgs, ... }:
pkgs.writeShellScriptBin "locate-cursor-release" ''
  # Release handler: smoothly shrinks cursor area back to normal
  # Triggered by: SUPER+F7 (release) via bindr

  STEP=0.15
  TARGET=1.0

  CURRENT=$(hyprctl getoption cursor:zoom_factor -j | ${pkgs.jq}/bin/jq -r '.float')
  if [ -z "$CURRENT" ] || [ "$CURRENT" = "null" ]; then
    CURRENT="1.0"
  fi

  # Already at normal? skip
  if [ "$(echo "$CURRENT <= $TARGET" | ${pkgs.bc}/bin/bc -l)" -eq 1 ]; then
    exit 0
  fi

  # Smoothly shrink from current to target
  while true; do
    NEW=$(echo "$CURRENT - $STEP" | ${pkgs.bc}/bin/bc)
    if [ "$(echo "$NEW <= $TARGET" | ${pkgs.bc}/bin/bc -l)" -eq 1 ]; then
      hyprctl keyword cursor:zoom_factor "$TARGET" > /dev/null 2>&1
      break
    fi
    hyprctl keyword cursor:zoom_factor "$NEW" > /dev/null 2>&1
    CURRENT=$NEW
    sleep 0.02
  done
''
