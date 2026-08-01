{ inputs, pkgs, lib, ... }:
{
  # Antiquity rice — Layer-2 shell template (Quickshell + hyprpaper + mako).
  # Designed to pair with any Layer-1 color theme (modules/themes/*). This
  # module only owns the shell; it does NOT touch GTK/Qt/cursor and does NOT
  # replace your shared lua binds (binds.lua / settings.lua stay managed by the
  # parent hyprland module, so SUPER+Tab and friends survive the switch).
  #
  # The bar/widget/config SOURCE is vendored into ./source (tracked, editable)
  # rather than pulled from the flake input at build time. Only the bulky assets
  # (buuf-nestort icons) remain referenced from inputs.antiquity.
  #
  # Wallpaper: unified on hyprpaper (same daemon as the default rice). Each theme
  # has its own default wallpaper (Config.qml themes[].defaultWallpaperPath),
  # exposed under ~/.local/share/wallpapers so QML and the selector can reference
  # them by $HOME-relative path. Switching theme resets to the theme default; the
  # `launcher wallpaper` selector overrides until the next theme switch.
  home-manager.sharedModules = [
    (
      { pkgs, lib, ... }:
      let
        # Wallpaper pool: the antiquity-bundled collages + the shared galaxy.webp,
        # all exposed under ~/.local/share/wallpapers.
        bundled = "${inputs.antiquity}/configs/hypr/wallpapers_bundled";
        # Absolute store path of galaxy.webp (shared default-rice wallpaper).
        galaxy = ../../../../themes/wallpapers/galaxy.webp;
        # Apply wallpaper via IPC after the Wayland session is up. hyprpaper's
        # at-startup conf parse races with monitor enumeration ("no target"), so we
        # deterministically set the wallpaper here once hyprctl is reachable.
        # NOTE: `hyprctl hyprpaper preload` is NOT a valid request in 0.8.4 (returns
        # "invalid hyprpaper request"); the `wallpaper` command both preloads and
        # applies, so we only call that. ExecStartPost failure fails the whole
        # service, so the loop must not abort on a single monitor miss.
        # Preference: a user-selected override file (if present), else galaxy.webp
        # as a neutral fallback until quickshell applies the active theme default.
        applyWallpaper = pkgs.writeShellScript "antiquity-apply-wallpaper" ''
          # Wait for the Hyprland socket dir to appear (up to 30s). This implies
          # the Wayland display is up. We do NOT rely on HYPRLAND_INSTANCE_SIGNATURE
          # being inherited from the service env (it isn't, for user services,
          # especially when Hyprland was launched manually from a TTY). Instead we
          # derive it from the runtime socket dir Hyprland creates under
          # $XDG_RUNTIME_DIR/hypr/<signature>/.socket.sock.
          for i in $(seq 1 30); do
            HIS=$(ls -1 "''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hypr" 2>/dev/null | head -1)
            [ -n "$HIS" ] && break
            sleep 1
          done
          export HYPRLAND_INSTANCE_SIGNATURE="$HIS"
          # Give hyprpaper's IPC a moment to come up after the socket.
          sleep 2
          WP=${galaxy}
          # If a user-selected override exists, prefer it over the theme default.
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
          quickshell
          hyprpaper
          qt6.qt5compat  # provides Qt5Compat.GraphicalEffects used by RadialTaskbar
        ];

        # Vendored bar + configs (editable in-repo; see ./source).
        xdg.configFile."quickshell".source = ./source/quickshell;
        xdg.configFile."mako/config".source = ./source/mako/config;
        xdg.configFile."kitty/antiquity".source = ./source/kitty;

        # Wallpaper pool exposed under ~/.local/share/wallpapers for QML + selector.
        home.file.".local/share/wallpapers/georges_riom_collage.png".source = "${bundled}/georges_riom_collage.png";
        home.file.".local/share/wallpapers/carnation_collage.png".source = "${bundled}/carnation_collage.png";
        home.file.".local/share/wallpapers/oc_the_blackboard.png".source = "${bundled}/oc_the_blackboard.png";
        home.file.".local/share/wallpapers/galaxy.webp".source = galaxy;
        # Per-theme pool wallpapers (distinct from the bundled collages).
        home.file.".local/share/wallpapers/ALCHEMY-dark.png".source = ../../../../themes/wallpapers/ALCHEMY-dark.png;
        home.file.".local/share/wallpapers/HIRAETH.png".source = ../../../../themes/wallpapers/HIRAETH.png;

        # hyprpaper.conf generated with YOUR monitors (vendored copy targets the
        # wrong DP-2/DP-4 names). Uses galaxy.webp as a neutral fallback; the
        # active theme's default wallpaper is applied by quickshell on load.
        # Path is absolute (hyprpaper does NOT expand ~).
        # NOTE: at boot hyprpaper may start before monitors are enumerated and log
        # "no target"; the ExecStartPost below applies the wallpaper via IPC once
        # the Wayland session is up, so this file is a fallback / reload source.
        xdg.configFile."hypr/hyprpaper.conf".text = ''
          wallpaper = eDP-1, ${galaxy}, cover
          wallpaper = DP-1, ${galaxy}, cover
          wallpaper = HDMI-A-2, ${galaxy}, cover
          splash = false
        '';

        # Icon theme referenced by shell.qml (`//@ pragma IconTheme buuf-nestort`).
        # Kept as input ref (2854 files — not worth vendoring).
        home.file.".local/share/icons/buuf-nestort".source =
          "${inputs.antiquity}/iconTheme/buuf-nestort";

        # Notifications via mako (HM-managed service)
        services.mako.enable = true;

        # Quickshell runtime state (settings.json, favoriteapps.json, widgets.json)
        # lives in a WRITABLE dir, NOT inside the read-only ~/.config/quickshell
        # store symlink. Config.qml points its FileViews here. Create it on activation.
        home.activation.createQuickshellState = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          mkdir -p "$HOME/.local/state/quickshell"
        '';

        systemd.user.services.quickshell = {
          Unit = {
            Description = "Antiquity Quickshell bar";
            # Start within the graphical session so WAYLAND_DISPLAY /
            # HYPRLAND_INSTANCE_SIGNATURE are present, and stop with it.
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };
          Service = {
            Type = "simple";
            ExecStart = "${pkgs.quickshell}/bin/quickshell";
            Restart = "on-failure";
            RestartSec = 2;
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
        systemd.user.services.hyprpaper = {
          Unit = {
            Description = "Hyprpaper wallpaper daemon (Antiquity)";
            # Same as quickshell: only run inside the Wayland session. Starting at
            # login (default.target) races the compositor — hyprpaper aborts with
            # "wl_display_connect failed" before the display exists, and the
            # ExecStartPost script can't reach hyprland (no session env). Binding to
            # graphical-session.target fixes both: the display + signature are ready.
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
