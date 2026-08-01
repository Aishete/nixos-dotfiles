{ pkgs, lib, ... }:
{
  # Default rice — the baseline Layer-2 shell (Waybar + SwayNC + hyprpaper wallpaper).
  # This is what the host got before the rice matrix existed; it is now a first-class
  # rice module so the 2D matrix (color x rice) is symmetric with `antiquity`.
  #
  # The bar/notification programs (waybar/swaync/hyprpanel/noctalia) are selected by
  # `bar`/`waybarTheme` in the host vars and imported by the parent module gated on
  # `rice == "default"`. Both rices now use hyprpaper for wallpaper (unified), so the
  # `wallpaper` daemon is hyprpaper here too — same ExecStartPost IPC-apply pattern as
  # antiquity. The antiquity rice instead uses hyprpaper service in its own module.
  home-manager.sharedModules = [
    (
      { pkgs, lib, ... }:
      let
        # Shared wallpaper pool (modules/themes/wallpapers). Absolute store path —
        # hyprpaper does NOT expand ~, but we expose these under ~/.local/share/wallpapers
        # and reference them via $HOME in scripts/QML.
        wallpaperFile = ../../../../themes/wallpapers/galaxy.webp;
        # Apply wallpaper via IPC after the Wayland session is up. hyprpaper's
        # at-startup conf parse races with monitor enumeration ("no target"), so we
        # deterministically set the wallpaper here once hyprctl is reachable.
        # NOTE: `hyprctl hyprpaper preload` is NOT a valid request in 0.8.4 (returns
        # "invalid hyprpaper request"); the `wallpaper` command both preloads and
        # applies, so we only call that. ExecStartPost failure fails the whole
        # service, so the loop must not abort on a single monitor miss.
        applyWallpaper = pkgs.writeShellScript "default-apply-wallpaper" ''
          # Wait for the Hyprland IPC socket (up to 30s).
          for i in $(seq 1 30); do
            hyprctl -q ping >/dev/null 2>&1 && break
            sleep 1
          done
          # Give hyprpaper's IPC a moment to come up after the socket.
          sleep 2
          WP=${wallpaperFile}
          # If a user-selected override exists, prefer it.
          if [ -s "$HOME/.local/state/quickshell/selectedWallpaper" ]; then
            WP="$(cat "$HOME/.local/state/quickshell/selectedWallpaper")"
          fi
          for m in eDP-1 DP-1 HDMI-A-2; do
            hyprctl hyprpaper wallpaper "$m,$WP" || true
          done
        '';
      in
      {
        home.packages = with pkgs; [
          hyprpaper
        ];

        xdg.configFile."hypr/hyprpaper.conf".text = ''
          wallpaper = eDP-1, ${wallpaperFile}, cover
          wallpaper = DP-1, ${wallpaperFile}, cover
          wallpaper = HDMI-A-2, ${wallpaperFile}, cover
          splash = false
        '';

        systemd.user.services.hyprpaper = {
          Unit.Description = "Hyprpaper wallpaper daemon (Default rice)";
          Service = {
            Type = "simple";
            ExecStart = "${pkgs.hyprpaper}/bin/hyprpaper";
            ExecStartPost = "${applyWallpaper}";
            Restart = "on-failure";
            RestartSec = 2;
          };
          Install.WantedBy = [ "default.target" ];
        };
      }
    )
  ];
}
