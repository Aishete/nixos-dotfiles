{ pkgs, lib, ... }:
{
  # Default rice — the baseline Layer-2 shell (Waybar + SwayNC + awww wallpaper).
  # This is what the host got before the rice matrix existed; it is now a first-class
  # rice module so the 2D matrix (color x rice) is symmetric with `antiquity`.
  #
  # The bar/notification programs (waybar/swaync/hyprpanel/noctalia) are selected by
  # `bar`/`waybarTheme` in the host vars and imported by the parent module gated on
  # `rice == "default"`. This module owns the wallpaper daemon (awww) that the default
  # shell uses; the antiquity rice instead uses hyprpaper.
  home-manager.sharedModules = [
    (
      { pkgs, lib, ... }: {
        services.awww.enable = true;
      }
    )
  ];
}
