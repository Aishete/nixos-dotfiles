{ pkgs, ... }:
pkgs.writeShellScriptBin "appearance" ''
  # Get current values
  get_val() {
    hyprctl getoption "$1" | ${pkgs.gnused}/bin/sed -n '1p' | ${pkgs.gawk}/bin/awk '{print $2}'
  }
#TODO
  BLUR=$(get_val "decoration:blur:enabled")
  BLUR_SIZE=$(get_val "decoration:blur:size")
  BLUR_PASSES=$(get_val "decoration:blur:passes")
  OPACITY=$(get_val "decoration:active_opacity")

  # Build menu
  if [ "$BLUR" = true ]; then
    BLUR_LABEL="Blur: ON (size=$BLUR_SIZE passes=$BLUR_PASSES)"
    BLUR_TOGGLE="blur_off"
  else
    BLUR_LABEL="Blur: OFF"
    BLUR_TOGGLE="blur_on"
  fi

  OPACITY_INT=$(echo "$OPACITY" | ${pkgs.coreutils}/bin/cut -d. -f1)
  OPACITY_LABEL="Opacity: $OPACITY_INT%"

  CHOICE=$(echo -e "$BLUR_LABEL\nBlur Size: $BLUR_SIZE\nBlur Passes: $BLUR_PASSES\n$OPACITY_LABEL\nReset All" | \
    ${pkgs.rofi}/bin/rofi -dmenu \
      -theme "$HOME/.config/rofi/launchers/type-1/style-6.rasi" \
      -i -p "Gamemode:")

  case "$CHOICE" in
    *"Blur: ON"*)
      hyprctl -q eval "hl.config({ decoration = { blur = { enabled = false } } })"
      ;;
    *"Blur: OFF"*)
      hyprctl -q eval "hl.config({ decoration = { blur = { enabled = true } } })"
      ;;
    "Blur Size:"*)
      NEW_VAL=$(echo "" | ${pkgs.rofi}/bin/rofi -dmenu \
        -theme "$HOME/.config/rofi/launchers/type-1/style-6.rasi" \
        -p "Blur Size (current: $BLUR_SIZE)")
      [ -n "$NEW_VAL" ] && hyprctl -q eval "hl.config({ decoration = { blur = { size = $NEW_VAL } } })"
      ;;
    "Blur Passes:"*)
      NEW_VAL=$(echo "" | ${pkgs.rofi}/bin/rofi -dmenu \
        -theme "$HOME/.config/rofi/launchers/type-1/style-6.rasi" \
        -p "Blur Passes (current: $BLUR_PASSES)")
      [ -n "$NEW_VAL" ] && hyprctl -q eval "hl.config({ decoration = { blur = { passes = $NEW_VAL } } })"
      ;;
    "Opacity:"*)
      NEW_VAL=$(echo "" | ${pkgs.rofi}/bin/rofi -dmenu \
        -theme "$HOME/.config/rofi/launchers/type-1/style-6.rasi" \
        -p "Opacity 0-100 (current: $OPACITY_INT)")
      if [ -n "$NEW_VAL" ]; then
        DECIMAL=$(echo "scale=2; $NEW_VAL / 100" | ${pkgs.gawk}/bin/awk '{printf "%.2f", $1 / 100}')
        hyprctl -q eval "hl.config({ decoration = { active_opacity = $DECIMAL, inactive_opacity = $DECIMAL, fullscreen_opacity = 1.0 } })"
      fi
      ;;
    "Reset All")
      hyprctl -q eval "
        hl.config({
          decoration = {
            blur = { enabled = true, size = 3, passes = 1 },
            active_opacity = 1.0,
            inactive_opacity = 1.0,
            fullscreen_opacity = 1.0,
          },
        })
      "
      ;;
  esac
''
