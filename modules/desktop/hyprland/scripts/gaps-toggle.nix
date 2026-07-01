{ pkgs, ... }:
pkgs.writeShellScriptBin "gaps-toggle" ''
  CURRENT=$(hyprctl getoption general:gaps_in | ${pkgs.gawk}/bin/awk 'NR==1 {print $2}')

  case $CURRENT in
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
    8|*)
      hyprctl keyword general:gaps_in 1
      hyprctl keyword general:gaps_out 4
      notify-send "Gaps" "compact (1/4)"
      ;;
  esac
''
