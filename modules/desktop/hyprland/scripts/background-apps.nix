{ pkgs, ... }:
pkgs.writeShellScriptBin "background-apps" ''
  # Background app indicator for waybar
  # Shows icons for running apps: Telegram, Teams, Spotify, Discord, Slack
  apps=""
  tooltip=""
  sep=""

  check_app() {
    local name="$1"
    local icon="$2"
    local process="$3"
    if pgrep -f "$process" > /dev/null 2>&1; then
      apps+="''${sep}''${icon}"
      tooltip+="''${sep}''${name}"
      sep=" "
    fi
  }

  check_app "Telegram" "󰙯" "telegram-desktop"
  check_app "Teams" "󰓩" "teams-for-linux"
  check_app "Spotify" "󰓇" "spotify"
  check_app "Discord" "󰙯" "Discord"
  check_app "Slack" "󰒱" "slack"
  check_app "Signal" "󰭽" "signal-desktop"

  if [ -n "$apps" ]; then
    printf '{"text":"%s","tooltip":"Running: %s","class":"active"}' "$apps" "$tooltip"
  else
    printf '{"text":" ","tooltip":"No background apps"}'
  fi
''
