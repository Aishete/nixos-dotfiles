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
  # Derive the Hyprland instance signature: Hyprland does NOT propagate
  # HYPRLAND_INSTANCE_SIGNATURE to exec children spawned at hyprland.start,
  # so find it in the runtime socket dir (works for DM and manual launches).
  HIS=$(ls -1 "''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hypr" 2>/dev/null | head -1)
  export HYPRLAND_INSTANCE_SIGNATURE="$HIS"

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

  # Apply to ACTUALLY connected monitors (hardcoded names error on other
  # hardware / hotplug).
  for m in $(hyprctl monitors -j 2>/dev/null | jq -r '.[].name'); do
    [ -n "$m" ] && hyprctl hyprpaper wallpaper "$m,$WP" || true
  done
''
