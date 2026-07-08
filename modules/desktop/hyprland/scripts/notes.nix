{ pkgs, ... }:
pkgs.writeShellScriptBin "notes" ''
  folder="$HOME/notes/"
  mkdir -p "$folder"

  newnote () {
    dir=$(find "$folder" -mindepth 1 -maxdepth 1 -type d | \
      ${pkgs.rofi}/bin/rofi -dmenu \
        -theme "$HOME/.config/rofi/launchers/type-1/style-6.rasi" \
        -i -p "Choose directory: ") || exit 0
    [ -z "$dir" ] && dir="$folder"

    name=$(echo "" | \
      ${pkgs.rofi}/bin/rofi -dmenu \
        -theme "$HOME/.config/rofi/launchers/type-1/style-6.rasi" \
        -i -p "Enter note name: ") || exit 0
    [ -z "$name" ] && name=$(date +%F_%H-%M-%S)

    ${pkgs.kitty}/bin/kitty --class "notes" -e nvim "$dir/$name.md" &
  }

  selected () {
    choice=$(echo -e "New\n$(find "$folder" -type f -name '*.md' -printf '%T@ %P\n' | sort -nr | cut -d' ' -f2-)" | \
      ${pkgs.rofi}/bin/rofi -dmenu \
        -theme "$HOME/.config/rofi/launchers/type-1/style-6.rasi" \
        -i -p "Notes:") || exit 0

    case "$choice" in
      New) newnote ;;
      *.md) ${pkgs.kitty}/bin/kitty --class "notes" -e nvim "$folder$choice" & ;;
      *) exit ;;
    esac
  }

  selected
''
