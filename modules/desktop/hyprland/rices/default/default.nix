{ pkgs, lib, config, ... }:
{
  # Default rice — the baseline Layer-2 shell (Waybar + SwayNC + hyprpaper wallpaper).
  # This is the only rice currently in use; the rice module structure is kept
  # so the `bar` variant selection (waybar/hyprpanel/noctalia) has a home.
  #
  # The bar/notification programs (waybar/swaync/hyprpanel/noctalia) are selected by
  # `bar`/`waybarTheme` in the host vars and imported by the parent module gated on
  # `rice == "default"`. The `wallpaper` daemon is hyprpaper here, exposed via a
  # graphical-session.target service + ExecStartPost IPC-apply.
  home-manager.sharedModules = [
    (
      { pkgs, lib, config, ... }:
      let
        # Shared wallpaper pool (modules/themes/wallpapers). Absolute store path —
        # hyprpaper does NOT expand ~, but we expose the canonical selection under
        # ~/.local/share/wallpapers/selected.webp and reference that in the conf.
        wallpaperFile = ../../../../themes/wallpapers/galaxy.webp;
        # User home — used for the canonical wallpaper symlink path that hyprpaper
        # PRELOADS. hyprpaper 0.8.4 keys preloads by exact path string, so every
        # runtime apply must route through this symlink path (never the raw store
        # path) or the preload is missed and the wallpaper re-parses from disk
        # (black flash on every select).
        homeDir = config.home.homeDirectory;
        # Apply wallpaper via IPC after the Wayland session is up. hyprpaper's
        # at-startup conf parse races with monitor enumeration ("no target"), so we
        # deterministically set the wallpaper here once the Hyprland socket is up.
        # NOTE: `hyprctl hyprpaper preload` is NOT a valid request in 0.8.4 (returns
        # "invalid hyprpaper request"); the `wallpaper` command both preloads and
        # applies, so we only call that. ExecStartPost failure fails the whole
        # service, so the loop must not abort on a single monitor miss.
        applyWallpaper = pkgs.writeShellScript "default-apply-wallpaper" ''
          # Wait for the Hyprland socket dir to appear (up to 30s) — implies the
          # Wayland display is up. User services do NOT inherit
          # HYPRLAND_INSTANCE_SIGNATURE (especially for manual TTY launches), so
          # derive it from the runtime socket dir Hyprland creates under
          # $XDG_RUNTIME_DIR/hypr/<signature>/.socket.sock.
          HIS=""
          for i in $(seq 1 30); do
            HIS=$(ls -1 "''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hypr" 2>/dev/null | head -1)
            [ -n "$HIS" ] && break
            sleep 1
          done
          export HYPRLAND_INSTANCE_SIGNATURE="$HIS"
          # Give hyprpaper's IPC a moment to come up after the socket.
          sleep 2
          # Wallpaper path may be passed as $1 (used on monitor hotplug); else
          # prefer a user-selected override file, then the theme default.
          if [ -n "''${1:-}" ]; then
            WP="$1"
          elif [ -s "$HOME/.local/state/quickshell/selectedWallpaper" ]; then
            WP="$(cat "$HOME/.local/state/quickshell/selectedWallpaper")"
          else
            WP=${wallpaperFile}
          fi
          # Only target monitors that are ACTUALLY connected right now. Setting
          # wallpaper on a disconnected output returns an error (and in 0.8.4
          # triggers a reparse/flash on every monitor), so skip the dead ones.
          for m in $(hyprctl monitors -j 2>/dev/null | jq -r '.[].name'); do
            [ -n "$m" ] && hyprctl hyprpaper wallpaper "$m,$WP" || true
          done
        '';
      in
      {
        home.packages = with pkgs; [
          hyprpaper
        ];

        xdg.configFile."hypr/hyprpaper.conf".text = ''
          # Canonical path every apply routes through (theme default + custom
          # selection via `launcher wallpaper`). Preload it so runtime swaps
          # reuse the buffered texture — no reparse, no black gap.
          preload = ${homeDir}/.local/share/wallpapers/selected.webp
          wallpaper = eDP-1, ${wallpaperFile}, cover
          wallpaper = DP-1, ${wallpaperFile}, cover
          wallpaper = HDMI-A-2, ${wallpaperFile}, cover
          splash = false
        '';

        # Canonical preloaded path. Every wallpaper
        # apply (theme default OR custom selection) routes through this symlink.
        # force = true because `launcher wallpaper` re-points this symlink at
        # runtime (without force, the next switch aborts on "would be clobbered").
        home.file.".local/share/wallpapers/selected.webp".source = wallpaperFile;
        home.file.".local/share/wallpapers/selected.webp".force = true;

        systemd.user.services.hyprpaper = {
          Unit = {
            Description = "Hyprpaper wallpaper daemon (Default rice)";
            # Only run inside the Wayland session. Starting at login
            # (default.target) races the compositor — hyprpaper aborts with
            # "wl_display_connect failed" before the display exists (status 0,
            # so Restart=on-failure never fires), and the ExecStartPost script
            # can't reach hyprland. Binding to graphical-session.target fixes
            # both: the display + instance signature are ready.
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };
          Service = {
            Type = "simple";
            ExecStart = "${pkgs.hyprpaper}/bin/hyprpaper";
            ExecStartPost = "${applyWallpaper}";
            Restart = "on-failure";
            RestartSec = 2;
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
      }
    )
  ];
}
