{ pkgs, ... }:
pkgs.writeShellScriptBin "gaps-toggle" ''
  CURRENT_GAPS_IN=$(
    hyprctl -j getoption general:gaps_in | ${pkgs.gawk}/bin/awk -F'"' '/"custom"/ {split($4, a, " "); print a[1]}'
  )

  case $CURRENT_GAPS_IN in
    0)
      hyprctl keyword general:gaps_in 4
      hyprctl keyword general:gaps_out 5
      notify-send "Gaps" "normal (4/5)"
      ;;
    1)
      hyprctl keyword general:gaps_in 4
      hyprctl keyword general:gaps_out 5
      notify-send "Gaps" "normal (4/5)"
      ;;
    4)
      hyprctl keyword general:gaps_in 8
      hyprctl keyword general:gaps_out 12
      notify-send "Gaps" "spacious (8/12)"
      ;;
    8)
      hyprctl keyword general:gaps_in 1
      hyprctl keyword general:gaps_out 4
      notify-send "Gaps" "compact (1/4)"
      ;;
    *)
      hyprctl keyword general:gaps_in 1
      hyprctl keyword general:gaps_out 4
      notify-send "Gaps" "compact (1/4)"
      ;;
  esac
''
