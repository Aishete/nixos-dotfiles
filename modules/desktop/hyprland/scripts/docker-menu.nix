{ pkgs, ... }:
pkgs.writeShellScriptBin "docker-menu" ''
  # Docker container management menu for waybar
  # Shows running/stopped containers with actions

  rofi_theme="''${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/type-4/style-4.rasi"

  if ! command -v docker &>/dev/null; then
    notify-send "Docker" "Docker is not installed"
    exit 1
  fi

  # Main menu
  choice=$(printf "󰓒 Running Containers\n󰅖 Stopped Containers\n---\n󰃤 Stop All Running\n  Start All Stopped" \
    | rofi -dmenu -i -p "Docker" -config "$rofi_theme" -theme-str 'window {width: 400px;}')

  case "$choice" in
    *"Running Containers"*)
      # List running containers
      running=$(docker ps --format '{{.Names}}\t{{.Status}}\t{{.Ports}}' 2>/dev/null)
      if [ -z "$running" ]; then
        notify-send "Docker" "No running containers"
        exit 0
      fi

      # Build menu entries
      menu=""
      while IFS=$'\t' read -r name status ports; do
        # Format ports nicely
        if [ -n "$ports" ]; then
          ports_display="$ports"
        else
          ports_display="no ports"
        fi
        menu+="  $name\n   $status\n   󰓗 $ports_display\n---\n"
      done <<< "$running"
      menu+="󰋋 Back"

      chosen=$(echo -e "$menu" | rofi -dmenu -i -p "Running" -config "$rofi_theme" -theme-str 'window {width: 500px;}')

      if [ -z "$chosen" ] || echo "$chosen" | grep -q "Back"; then
        exit 0
      fi

      # Extract container name (first non-space, non-icon line)
      container_name=$(echo "$chosen" | grep -v "^   " | grep -v "^---" | grep -v "Back" | sed 's/^[ ]*//' | head -n1)

      if [ -z "$container_name" ]; then
        exit 0
      fi

      # Action submenu for this container
      action=$(printf "󰅖 Stop\n  Restart\n 󰋋 Logs (last 20)" \
        | rofi -dmenu -i -p "$container_name" -config "$rofi_theme" -theme-str 'window {width: 350px;}')

      case "$action" in
        *"Stop"*)
          docker stop "$container_name" 2>/dev/null
          notify-send "Docker" "Stopped $container_name"
          ;;
        *"Restart"*)
          docker restart "$container_name" 2>/dev/null
          notify-send "Docker" "Restarted $container_name"
          ;;
        *"Logs"*)
          terminal="$(command -v kitty || command -v alacritty || command -v foot || echo "kitty")"
          $terminal -e sh -c "docker logs --tail 20 -f $container_name; echo 'Press any key to close'; read" &
          ;;
      esac
      ;;

    *"Stopped Containers"*)
      # List stopped containers
      stopped=$(docker ps -a --filter "status=exited" --filter "status=created" --filter "status=dead" --format '{{.Names}}\t{{.Status}}\t{{.Ports}}' 2>/dev/null)
      if [ -z "$stopped" ]; then
        notify-send "Docker" "No stopped containers"
        exit 0
      fi

      menu=""
      while IFS=$'\t' read -r name status ports; do
        if [ -n "$ports" ]; then
          ports_display="$ports"
        else
          ports_display="no ports"
        fi
        menu+="  $name\n   $status\n   󰓗 $ports_display\n---\n"
      done <<< "$stopped"
      menu+="󰋋 Back"

      chosen=$(echo -e "$menu" | rofi -dmenu -i -p "Stopped" -config "$rofi_theme" -theme-str 'window {width: 500px;}')

      if [ -z "$chosen" ] || echo "$chosen" | grep -q "Back"; then
        exit 0
      fi

      container_name=$(echo "$chosen" | grep -v "^   " | grep -v "^---" | grep -v "Back" | sed 's/^[ ]*//' | head -n1)

      if [ -z "$container_name" ]; then
        exit 0
      fi

      action=$(printf "  Start\n  Remove" \
        | rofi -dmenu -i -p "$container_name" -config "$rofi_theme" -theme-str 'window {width: 350px;}')

      case "$action" in
        *"Start"*)
          docker start "$container_name" 2>/dev/null
          notify-send "Docker" "Started $container_name"
          ;;
        *"Remove"*)
          confirm=$(printf "  Yes, remove\n  Cancel" \
            | rofi -dmenu -i -p "Remove $container_name?" -config "$rofi_theme" -theme-str 'window {width: 350px;}')
          if echo "$confirm" | grep -q "Yes"; then
            docker rm "$container_name" 2>/dev/null
            notify-send "Docker" "Removed $container_name"
          fi
          ;;
      esac
      ;;

    *"Stop All"*)
      confirm=$(printf "  Yes, stop all\n  Cancel" \
        | rofi -dmenu -i -p "Stop all running containers?" -config "$rofi_theme" -theme-str 'window {width: 350px;}')
      if echo "$confirm" | grep -q "Yes"; then
        count=$(docker ps -q 2>/dev/null | wc -l)
        docker stop $(docker ps -q) 2>/dev/null
        notify-send "Docker" "Stopped $count containers"
      fi
      ;;

    *"Start All"*)
      count=$(docker ps -a --filter "status=exited" --filter "status=created" --filter "status=dead" -q 2>/dev/null | wc -l)
      if [ "$count" -eq 0 ]; then
        notify-send "Docker" "No stopped containers to start"
        exit 0
      fi
      docker start $(docker ps -a --filter "status=exited" --filter "status=created" --filter "status=dead" -q) 2>/dev/null
      notify-send "Docker" "Started $count containers"
      ;;
  esac
''
