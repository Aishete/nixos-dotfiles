{ pkgs, ... }:
pkgs.writeShellScriptBin "gamemode" ''
  HYPRGAMEMODE=$(hyprctl getoption animations:enabled | ${pkgs.gnused}/bin/sed -n '1p' | ${pkgs.gawk}/bin/awk '{print $2}')

  if [ "$HYPRGAMEMODE" = true ]; then
    hyprctl -q eval "
      hl.config({
        animations = { enabled = false },
        general = {
          border_size = 1,
          gaps_in = 0,
          gaps_out = 0,
        },
        decoration = {
          rounding = 0,
          active_opacity = 1.0,
          inactive_opacity = 1.0,
          fullscreen_opacity = 1.0,
          shadow = { enabled = false },
          blur = { enabled = false, xray = true },
        },
      })
    "
    exit
  else
    hyprctl reload config-only -q
  fi
''
