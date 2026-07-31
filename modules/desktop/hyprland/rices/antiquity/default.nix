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
  # (buuf-nestort icons, bundled wallpapers) remain referenced from inputs.antiquity.
  home-manager.sharedModules = [
    (
      { pkgs, lib, ... }: {
        home.packages = with pkgs; [
          quickshell
          hyprpaper
          qt6.qt5compat  # provides Qt5Compat.GraphicalEffects used by RadialTaskbar
        ];

        # Vendored bar + configs (editable in-repo; see ./source).
        xdg.configFile."quickshell".source = ./source/quickshell;
        xdg.configFile."mako/config".source = ./source/mako/config;
        xdg.configFile."kitty/antiquity".source = ./source/kitty;

        # hyprpaper.conf generated with YOUR monitors (vendored copy targets the
        # wrong DP-2/DP-4 names). preload + wallpaper = format (hyprpaper v0.8.x).
        xdg.configFile."hypr/hyprpaper.conf".text = ''
          preload = ~/.config/hypr/wallpapers_bundled/georges_riom_collage.png
          wallpaper = eDP-1, ~/.config/hypr/wallpapers_bundled/georges_riom_collage.png, cover
          wallpaper = DP-1, ~/.config/hypr/wallpapers_bundled/georges_riom_collage.png, cover
          wallpaper = HDMI-A-2, ~/.config/hypr/wallpapers_bundled/georges_riom_collage.png, cover
          splash = false
        '';
        # Antiquity's bundled wallpapers (kept as input ref; large binary assets).
        xdg.configFile."hypr/wallpapers_bundled".source =
          "${inputs.antiquity}/configs/hypr/wallpapers_bundled";

        # Icon theme referenced by shell.qml (`//@ pragma IconTheme buuf-nestort`).
        # Kept as input ref (2854 files — not worth vendoring).
        home.file.".local/share/icons/buuf-nestort".source =
          "${inputs.antiquity}/iconTheme/buuf-nestort";

        # Notifications via mako (HM-managed service)
        services.mako.enable = true;

        # Quickshell + hyprpaper auto-start.
        # graphical-session.target is inactive on this boot, so we bind to
        # default.target (active on login) and let Restart=on-failure retry
        # until the Wayland socket is ready.
        systemd.user.services.quickshell = {
          Unit.Description = "Antiquity Quickshell bar";
          Service = {
            Type = "simple";
            ExecStart = "${pkgs.quickshell}/bin/quickshell";
            Restart = "on-failure";
            RestartSec = 2;
          };
          Install.WantedBy = [ "default.target" ];
        };
        systemd.user.services.hyprpaper = {
          Unit.Description = "Hyprpaper wallpaper daemon (Antiquity)";
          Service = {
            Type = "simple";
            ExecStart = "${pkgs.hyprpaper}/bin/hyprpaper";
            Restart = "on-failure";
            RestartSec = 2;
          };
          Install.WantedBy = [ "default.target" ];
        };
      }
    )
  ];
}
