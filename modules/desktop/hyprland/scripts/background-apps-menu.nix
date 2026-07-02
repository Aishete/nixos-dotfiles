{ pkgs, ... }:
pkgs.writeShellScriptBin "background-apps-menu" ''
  # Right-click menu for background apps
  # Shows running apps with options: Focus, Close

  apps=()
  pids=()
  icons=()

  check_app() {
    local name="$1"
    local icon="$2"
    local process="$3"
    local pid
    pid=$(pgrep -f "$process" 2>/dev/null | head -n1)
    if [ -n "$pid" ]; then
      apps+=("$name")
      pids+=("$pid")
      icons+=("$icon")
    fi
  }

  check_app "Telegram" "󰙯" "telegram-desktop"
  check_app "Teams" "󰓩" "teams-for-linux"
  check_app "Spotify" "󰓇" "spotify"
  check_app "Discord" "󰙯" "Discord"
  check_app "Slack" "󰒱" "slack"
  check_app "Signal" "󰭽" "signal-desktop"

  if [ ''${#apps[@]} -eq 0 ]; then
    notify-send "Background Apps" "No apps running"
    exit 0
  fi

  # Build rofi menu entries
  menu=""
  for i in "''${!apps[@]}"; do
    menu+="''${icons[$i]} ''${apps[$i]} [PID: ''${pids[$i]}]\n"
  done
  menu+="---\n󰆋 Close All"

  # Show rofi menu
  chosen=$(echo -e "$menu" | rofi -dmenu -p "Background Apps" -theme str 'window {width: 350px;}')

  if [ -z "$chosen" ]; then
    exit 0
  fi

  # Handle "Close All"
  if echo "$chosen" | grep -q "Close All"; then
    for pid in "''${pids[@]}"; do
      kill "$pid" 2>/dev/null
    done
    notify-send "Background Apps" "All apps closed"
    exit 0
  fi

  # Extract app name from chosen entry
  app_name=$(echo "$chosen" | awk '{print $2}')

  # Find the PID for this app
  for i in "''${!apps[@]}"; do
    if [ "''${apps[$i]}" = "$app_name" ]; then
      pid="''${pids[$i]}"
      break
    fi
  done

  # Show action menu for selected app
  action=$(echo -e "󰋋 Focus\n󰅖 Close\n󰏗 Kill" | rofi -dmenu -p "$app_name")

  case "$action"
    *"Focus"*)
      # Try to focus the window
      hyprctl dispatch focuswindow "pid:$pid" 2>/dev/null
      ;;
    *"Close"*)
      kill "$pid" 2>/dev/null
      notify-send "Background Apps" "$app_name closed"
      ;;
    *"Kill"*)
      kill -9 "$pid" 2>/dev/null
      notify-send "Background Apps" "$app_name killed"
      ;;
  esac
''
