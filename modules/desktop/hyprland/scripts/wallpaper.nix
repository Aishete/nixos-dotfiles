{ pkgs, defaultWallpaper, lib, ... }:
let
  # Unified on hyprpaper (replaces awww). Applies the default wallpaper at startup
  # via IPC, preferring a user-selected override file if present.
  # Filter out .rrdata sidecar files so Nix's git-path check accepts the dir.
  wallpaperDir = builtins.filterSource
    (path: _: !(builtins.match ".*\\.rrdata" (baseNameOf path) == null))
    ../../../themes/wallpapers;
in
pkgs.writeShellScriptBin "wallpaper" ''
  # Wait briefly for hyprpaper's IPC to be reachable.
  for i in $(seq 1 10); do
    hyprctl -q ping >/dev/null 2>&1 && break
    sleep 1
  done

  WP=${wallpaperDir}/${defaultWallpaper}
  # If a user-selected override exists, prefer it.
  if [ -s "$HOME/.local/state/quickshell/selectedWallpaper" ]; then
    WP="$(cat "$HOME/.local/state/quickshell/selectedWallpaper")"
  fi

  for m in eDP-1 DP-1 HDMI-A-2; do
    hyprctl hyprpaper wallpaper "$m,$WP" || true
  done
''
