{ pkgs, ... }:
# Toggle the animations that play when SWITCHING windows: the focus-change
# border/fade effects (border / borderangle / fadeSwitch / fadeShadow /
# fadeGlow) AND the workspace switch slide (workspaces / specialWorkspace).
# The slide is included because this rice runs one window per workspace, so
# switching windows usually IS a workspace switch — the slide is the visible
# part. Bind: SUPER SHIFT ALT G.
#
# NOT touched: window open/close (windows/windowsIn/windowsOut), move/resize
# (windowsMove), the general fade, layer animations.
#
# Why hl.animation() instead of hyprctl keyword: keyword is dead on Hyprland
# 0.55+ ("keyword can't work with non-legacy parsers. Use eval."). hl.animation
# writes the same animation-tree nodes the Lua config declares at load
# (animations.lua), so `hyprctl animations` shows overridden=true.
#
# The "on" path is `hyprctl reload config-only`: it re-runs the whole Lua
# config and re-applies the authored animation values exactly. Do NOT re-enable
# with hl.animation({enabled=true}) individually: leaves the config does not
# declare (fadeShadow/fadeGlow/borderangle) have no authored speed to re-declare
# and the C++ AnimationTree defaults (borderangle = off) differ from the
# authored baseline. Reload is verified to NOT respawn exec-once children
# (waybar/swaync process counts survive it).
#
# State detection: `hyprctl -j animations` returns [animationTree, curves];
# tree entries carry "overridden" (has an explicit config — the Lua config AND
# any runtime eval set it, so it does NOT mean "toggled off"). Parse the
# effective .enabled of the border leaf instead.
pkgs.writeShellScriptBin "anim-toggle" ''
  HYPRCTL=${pkgs.hyprland}/bin/hyprctl
  JQ=${pkgs.jq}/bin/jq
  NOTIFY=${pkgs.libnotify}/bin/notify-send

  ENABLED=$(
    $HYPRCTL -j animations 2>/dev/null \
      | $JQ -r '.[0][] | select(.name == "border") | .enabled' 2>/dev/null
  )
  case "$ENABLED" in
    true|false) ;;
    *) exit 1 ;;
  esac

  # workspacesIn/workspacesOut are not overridden, so they inherit the
  # workspaces node; specialWorkspace IS declared in animations.lua and must
  # be disabled on its own.
  if [ "$ENABLED" = "true" ]; then
    $HYPRCTL -q eval '
      hl.animation({ leaf = "border", enabled = false })
      hl.animation({ leaf = "borderangle", enabled = false })
      hl.animation({ leaf = "fadeSwitch", enabled = false })
      hl.animation({ leaf = "fadeShadow", enabled = false })
      hl.animation({ leaf = "fadeGlow", enabled = false })
      hl.animation({ leaf = "workspaces", enabled = false })
      hl.animation({ leaf = "specialWorkspace", enabled = false })
    '
    $NOTIFY -a "Hyprland" -t 1500 "Switch animations" "OFF (focus + workspace switch)"
  else
    $HYPRCTL reload config-only
    $NOTIFY -a "Hyprland" -t 1500 "Switch animations" "ON (config reloaded)"
  fi
''
