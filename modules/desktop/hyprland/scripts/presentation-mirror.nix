{ pkgs, ... }:
pkgs.writeShellScriptBin "presentation-mirror" ''
  set -euo pipefail

  STATE_FILE=/tmp/hypr-presentation-mirror
  SOURCE="''${1:-eDP-1}"

  # --- Toggle off ---
  if [ -f "$STATE_FILE" ]; then
      read -r PID TARGET < "$STATE_FILE"
      kill "$PID" 2>/dev/null || true
      rm -f "$STATE_FILE"
      ${pkgs.libnotify}/bin/notify-send -a "Presentation Mirror" "Mirror stopped ($SOURCE → $TARGET)"
      exit 0
  fi

  # --- Find external monitors ---
  MONITORS=$(${pkgs.hyprland}/bin/hyprctl monitors all \
      | ${pkgs.gnugrep}/bin/grep "^Monitor" \
      | ${pkgs.gawk}/bin/awk '{print $2}' \
      | ${pkgs.gnugrep}/bin/grep -v "^''${SOURCE}$" \
      | ${pkgs.gnugrep}/bin/grep -v "^$" \
  ) || true

  COUNT=$(echo "$MONITORS" | ${pkgs.gawk}/bin/awk 'END {print NR}')
  if [ "$COUNT" -eq 0 ]; then
      ${pkgs.libnotify}/bin/notify-send -a "Presentation Mirror" "No external monitors found"
      exit 1
  fi

  # --- Pick target via rofi ---
  if [ "$COUNT" -eq 1 ]; then
      TARGET="$MONITORS"
  else
      TARGET=$(echo "$MONITORS" | ${pkgs.rofi}/bin/rofi -dmenu -p "Mirror $SOURCE →" \
          -theme-str 'window {width: 400px;} listview {lines: 5;}')
      [ -z "$TARGET" ] && exit 1
  fi

  # --- Start wl-mirror with --fullscreen-output (places + fullscreens on target) ---
  ${pkgs.wl-mirror}/bin/wl-mirror \
      --fullscreen \
      --fullscreen-output "$TARGET" \
      "$SOURCE" &
  PID=$!
  echo "$PID $TARGET" > "$STATE_FILE"

  ${pkgs.libnotify}/bin/notify-send -a "Presentation Mirror" "Mirroring $SOURCE → $TARGET"
''
