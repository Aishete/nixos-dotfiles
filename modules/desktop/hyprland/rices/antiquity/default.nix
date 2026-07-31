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
        ];

        # Link Antiquity's Quickshell bar + assets (from the flake input)
        xdg.configFile."quickshell".source =
          "${inputs.antiquity}/configs/quickshell";
        xdg.configFile."mako/config".source =
          "${inputs.antiquity}/configs/mako/config";
        xdg.configFile."hypr/hyprpaper.conf".source =
          "${inputs.antiquity}/configs/hypr/hyprpaper.conf";
        # Antiquity bundles its wallpapers here; link so hyprpaper can find them
        xdg.configFile."hypr/wallpapers_bundled".source =
          "${inputs.antiquity}/configs/hypr/wallpapers_bundled";

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
