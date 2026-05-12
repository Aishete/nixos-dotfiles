{ pkgs, ... }:
pkgs.writeShellScriptBin "wallpaper" ''
  WALLPAPER="$1"
  TEMP_DIR="/tmp/wallpaper-cache"

  # feh doesn't support webp — convert to png first
  case "$WALLPAPER" in
    *.webp|*.WEBP)
      mkdir -p "$TEMP_DIR"
      TEMP_FILE="$TEMP_DIR/$(basename "$WALLPAPER" .webp).png"
      ${pkgs.imagemagick}/bin/magick "$WALLPAPER" "$TEMP_FILE"
      WALLPAPER="$TEMP_FILE"
      ;;
  esac

  for output in $(xrandr --listmonitors | awk 'NR>1 {print $4}'); do
    ${pkgs.feh}/bin/feh --bg-fill "$WALLPAPER" --no-fehbg --output "$output"
  done
''
