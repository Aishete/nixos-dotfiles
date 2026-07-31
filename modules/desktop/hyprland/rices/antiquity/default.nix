{ inputs, pkgs, lib, ... }:
{
  # Antiquity rice — Layer-2 shell template (Quickshell + hyprpaper + mako).
  # Designed to pair with any Layer-1 color theme (modules/themes/*). This
  # module only owns the shell; it does NOT touch GTK/Qt/cursor and does NOT
  # replace your shared lua binds (binds.lua / settings.lua stay managed by the
  # parent hyprland module, so SUPER+Tab and friends survive the switch).
  home-manager.sharedModules = [
    (
      { pkgs, lib, ... }: {
        home.packages = with pkgs; [
          quickshell
          hyprpaper
          qt6.qt5compat  # provides Qt5Compat.GraphicalEffects used by RadialTaskbar
        ];

        # Link Antiquity's Quickshell bar + assets (from the flake input).
        # We build one store path that contains the repo's quickshell dir PLUS our
        # local widgets (RAM/GPU/Power), favoriteapps.json, and a patched Bar.qml
        # that shows those widgets. home-manager cannot merge sub-files into a
        # directory that is itself a `source` symlink, so we bake it into one tree.
        xdg.configFile."quickshell".source = pkgs.runCommand "quickshell-antiquity" { } ''
          cp -r "${inputs.antiquity}/configs/quickshell" "$out"
          chmod -R u+w "$out"

          # --- Our status widgets (RAM / GPU / Power) ---
          cp "${./quickshell-widgets/RamWidget.qml}"   "$out/widgets/RamWidget.qml"
          cp "${./quickshell-widgets/GpuWidget.qml}"   "$out/widgets/GpuWidget.qml"
          cp "${./quickshell-widgets/PowerWidget.qml}" "$out/widgets/PowerWidget.qml"

          # Register the widgets in the Widgets qml module
          cat >> "$out/widgets/qmldir" <<QMLDIR
          RamWidget 1.0 RamWidget.qml
          GpuWidget 1.0 GpuWidget.qml
          PowerWidget 1.0 PowerWidget.qml
          QMLDIR

          # Inject the widgets into the bar (no python in sandbox; use sed).
          # 1) add widgets import right after the existing "import \"..\"" line
          sed -i 's|^import "\.\."$|import ".."\nimport "../widgets" as Widgets|' "$out/taskbar/Bar.qml"
          # 2) insert the status-widget block (with ids) just before the SysTray
          #    instance. The instance is the line containing "id: sysTray".
          sed -i 's|^\( *\)id: sysTray$|\1id: sysTray\n                /*=== Status widgets (RAM / GPU / Power) ===*/\n                Widgets.PowerWidget { id: powerW; anchors.verticalCenter: parent.verticalCenter; anchors.right: sysTray.left; anchors.rightMargin: 8 }\n                Widgets.GpuWidget   { id: gpuW;   anchors.verticalCenter: parent.verticalCenter; anchors.right: powerW.left; anchors.rightMargin: 8 }\n                Widgets.RamWidget   { id: ramW;   anchors.verticalCenter: parent.verticalCenter; anchors.right: gpuW.left;   anchors.rightMargin: 8 }|' "$out/taskbar/Bar.qml"

          cat > "$out/favoriteapps.json" <<EOF
          {
            "Kitty":   { "name": "Kitty",   "execCommand": ["kitty"],                                              "icon": "utilities-terminal" },
            "Firefox": { "name": "Firefox", "execCommand": ["firefox"],                                            "icon": "firefox" },
            "Yazi":    { "name": "Yazi",    "execCommand": ["kitty", "--class", "tuiFileManager", "-e", "yazi"],    "icon": "system-file-manager" },
            "Discord": { "name": "Discord", "execCommand": ["discord"],                                            "icon": "discord" },
            "Spotify": { "name": "Spotify", "execCommand": ["spotify"],                                            "icon": "spotify" }
          }
          EOF
        '';
        xdg.configFile."mako/config".source =
          "${inputs.antiquity}/configs/mako/config";
        # Generate hyprpaper.conf with YOUR monitors (repo targets DP-2/DP-4 which are wrong)
        # Using preload + wallpaper = format (universally supported by hyprpaper v0.8.x)
        xdg.configFile."hypr/hyprpaper.conf".text = ''
          preload = ~/.config/hypr/wallpapers_bundled/georges_riom_collage.png
          wallpaper = eDP-1, ~/.config/hypr/wallpapers_bundled/georges_riom_collage.png, cover
          wallpaper = DP-1, ~/.config/hypr/wallpapers_bundled/georges_riom_collage.png, cover
          wallpaper = HDMI-A-2, ~/.config/hypr/wallpapers_bundled/georges_riom_collage.png, cover
          splash = false
        '';
        # Antiquity bundles its wallpapers here; link so hyprpaper can find them
        xdg.configFile."hypr/wallpapers_bundled".source =
          "${inputs.antiquity}/configs/hypr/wallpapers_bundled";

        # Icon theme referenced by shell.qml (`//@ pragma IconTheme buuf-nestort`).
        # Quickshell resolves it from the XDG icon dir, so install there.
        home.file.".local/share/icons/buuf-nestort".source =
          "${inputs.antiquity}/iconTheme/buuf-nestort";

        # Antiquity kitty themes (match the shell palette). Symlink the dir so
        # `include antiquity/eris.conf` etc. works from kitty.conf.
        xdg.configFile."kitty/antiquity".source =
          "${inputs.antiquity}/configs/kitty";

        # Notifications via mako (HM-managed service)
        services.mako.enable = true;

        # Start the shell components as user services (mirrors awww-daemon)
        systemd.user.services.quickshell = {
          Unit.Description = "Antiquity Quickshell bar";
          Unit.PartOf = [ "graphical-session.target" ];
          Service = {
            Type = "simple";
            ExecStart = "${pkgs.quickshell}/bin/quickshell";
            Restart = "on-failure";
            RestartSec = 2;
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
        systemd.user.services.hyprpaper = {
          Unit.Description = "Hyprpaper wallpaper daemon (Antiquity)";
          Unit.PartOf = [ "graphical-session-pre.target" ];
          Service = {
            Type = "simple";
            ExecStart = "${pkgs.hyprpaper}/bin/hyprpaper";
            Restart = "on-failure";
            RestartSec = 2;
          };
          Install.WantedBy = [ "graphical-session-pre.target" ];
        };
      }
    )
  ];
}
