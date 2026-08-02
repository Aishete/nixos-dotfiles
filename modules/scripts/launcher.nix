{
  lib,
  pkgs,
  terminal,
  ...
}:
let
  # Filter out .rrdata sidecar files (download artifacts) so Nix's git-path check
  # doesn't reject the whole themes/wallpapers directory.
  wallpapersDir = builtins.filterSource
    (path: _: let b = baseNameOf path; in !(lib.hasSuffix ".rrdata" b))
    ../themes/wallpapers;
  wallpaperDir = "${wallpapersDir}";
  wallpaperThumbs =
    pkgs.runCommand "wallpaper-thumbnails"
      {
        buildInputs = [ pkgs.imagemagick ];
      }
      ''
        mkdir -p $out
        for wallpaper in "${wallpaperDir}"/*.{webp,jxl,jpg,jpeg,png,gif}; do
          if [ -f "$wallpaper" ]; then
            wallpaper_name=$(basename "$wallpaper")
            wallpaper_name="''${wallpaper_name%.*}"
            thumbnail_size="320x180"
            if [ ! -f "$out/''${wallpaper_name}.jpg" ]; then
              magick "$wallpaper[0]" -strip -gravity center -thumbnail "''${thumbnail_size}^" -extent "$thumbnail_size" "$out/''${wallpaper_name}.jpg"
            fi
          fi
        done
      '';
in
pkgs.writeShellScriptBin "launcher" ''
  # check if rofi is already running
  if pidof rofi >/dev/null; then
    pkill rofi
    exit 0
  fi

  case $1 in
  drun)
    # rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/type-4/style-7.rasi"
    # rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/type-4/style-3.rasi"
    rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/type-2/style-2.rasi"
    r_override="entry{placeholder:'Search Applications...';}listview{lines:9;}"

    rofi -show drun -theme-str "$r_override" -theme "$rofi_theme"
    ;;
  window)
    # rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/type-2/style-2.rasi"
    rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/type-4/style-4.rasi"
    r_override="entry{placeholder:'Search Windows...';}listview{lines:12;}"

    rofi -show window -theme-str "$r_override" -theme "$rofi_theme"
    ;;
  file)
    rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/type-2/style-2.rasi"
    r_override="entry{placeholder:'Search Files...';}listview{lines:8;}"

    rofi -show filebrowser -theme-str "$r_override" -theme "$rofi_theme"
    ;;
  tmux)
    rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/type-4/style-4.rasi"
    r_override="entry{placeholder:'Search Tmux Sessions...';}listview{lines:15;}"

    sessions=$(tmux ls -F '#{session_name}: #{session_path} (#{session_windows} windows)' |
      rofi -dmenu -i -theme-str "$r_override" -theme "$rofi_theme" | cut -d: -f1)
    if [[ $sessions ]]; then
      ${terminal} --hold -e tmux attach -t $sessions
    fi
    ;;
  wallpaper)
    rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/wallpaper-select.rasi"
    r_override="entry{placeholder:'Search Wallpapers...';}"
    # rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/type-4/style-4.rasi"
    # r_override="entry{placeholder:'Search Wallpapers...';}listview{lines:15;}"

    CACHE_DIR=${wallpaperThumbs}
    WALLPAPER_DIR="${wallpaperDir}"

    rofi_cmd() {
      rofi -dmenu \
        -i \
        -theme-str "$r_override" \
        -theme "$rofi_theme"
    }

    CHOICE=$(${lib.getExe pkgs.fd} --type f . "''${WALLPAPER_DIR}" \
      | sed 's/.*\///' \
      | while read -r A ; do echo -en "$A\x00icon\x1f""''${CACHE_DIR}"/"''${A%.*}.jpg\n" ; done \
      | rofi_cmd)
    [ -z "$CHOICE" ] && exit 0

    if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
      # Unified on hyprpaper. NO black gap: every apply must route through the
      # canonical preloaded symlink ~/.local/share/wallpapers/selected.webp
      # (hyprpaper.conf preloads it; 0.8.4 has no preload IPC verb). Applying
      # the raw store path directly would force a fresh decode -> black flash.
      # Mirrors Config.qml's applyWallpaper: re-point the symlink, then apply
      # the canonical path to every CONNECTED monitor (dynamic, not hardcoded).
      WP_ABS="$WALLPAPER_DIR/$CHOICE"
      CANON="$HOME/.local/share/wallpapers/selected.webp"
      mkdir -p "$HOME/.local/share/wallpapers"
      ln -sf "$WP_ABS" "$CANON"
      for output in $(hyprctl monitors -j 2>/dev/null | jq -r '.[].name'); do
        hyprctl hyprpaper wallpaper "$output,$CANON" || true
      done
      mkdir -p "$HOME/.local/state/quickshell"
      echo "$WP_ABS" > "$HOME/.local/state/quickshell/selectedWallpaper"
    else
      TEMP_DIR="/tmp/wallpaper-cache"
      WALLPAPER="$WALLPAPER_DIR/$CHOICE"
      case "$WALLPAPER" in
        *.webp|*.WEBP)
          mkdir -p "$TEMP_DIR"
          ${pkgs.imagemagick}/bin/magick "$WALLPAPER" "$TEMP_DIR/$(basename "$WALLPAPER" .webp).png"
          WALLPAPER="$TEMP_DIR/$(basename "$WALLPAPER" .webp).png"
          ;;
      esac
      for output in $(xrandr --listmonitors 2>/dev/null | awk 'NR>1 {print $4}'); do
        ${pkgs.feh}/bin/feh --bg-fill "$WALLPAPER" --no-fehbg --output "$output"
      done
    fi
    ;;
  emoji)
    rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/type-4/style-4.rasi"
    r_override="entry{placeholder:'Search Emojis...';}listview{lines:15;}"

    rofi -modi emoji -show emoji -theme "''${rofi_theme}" -theme-str "$r_override"
    ;;
  games)
    r_override="entry{placeholder:'Search Games...';}listview{lines:15;}"
    rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/type-1/style-5.rasi"

    rofi -show games -modi games -theme "''${rofi_theme}" -theme-str "$r_override"
    ;;
  help | --help | -h)
    echo "Usage: launcher [ACTION]"
    echo "Launch various rofi modes with custom themes and settings."
    echo ""
    echo "Actions:"
    echo "  drun         Launch application search mode"
    echo "  window       Switch between open windows"
    echo "  file         Browse and search files"
    echo "  tmux         Search active tmux sessions"
    echo "  wallpaper    Search and set wallpapers"
    echo "  emoji        Search and insert emojis"
    echo "  games        Launch games menu"
    echo "  help         Display this help message"
    echo "  --help       Same as 'help'"
    echo ""
    echo "If no action is specified, defaults to 'drun' mode."
    exit 0
    ;;
  *) exec "$0" drun ;;
  esac
''
