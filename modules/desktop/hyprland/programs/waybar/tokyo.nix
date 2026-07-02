{
  host,
  pkgs,
  ...
}: let
  inherit (import ../../../../../hosts/${host}/variables.nix) clock24h monospaceFont;
  # Zeibytes-inspired palette
  palette = {
    bg0 = "#141221";
    bg1 = "#1B1D2E";
    accent = "#C4A7E7";
    fg0 = "#CDD6F4";
    fg1 = "#E0DEF4";
    muted = "#5B4950";
    hoverBg = "#1E1E1E";
    surface2 = "#585B70";
    red = "#F38BA8";
    green = "#A6E3A1";
    blue = "#89B4FA";
  };
  gpuinfo = pkgs.callPackage ../../scripts/gpuinfo.nix {};
  keyboardswitch = pkgs.callPackage ../../scripts/keyboardswitch.nix {};
  backgroundApps = pkgs.callPackage ../../scripts/background-apps.nix {};
in {
  home-manager.sharedModules = [
    (_: {
      programs.waybar = {
        enable = true;
        systemd = {
          enable = false;
          target = "graphical-session.target";
        };
        settings = {
          mainBar = {
            layer = "top";
            position = "top";
            mode = "dock";
            height = 1;
            exclusive = true;
            passthrough = false;
            gtk-layer-shell = true;
            ipc = true;
            fixed-center = true;
            margin-top = 0;
            margin-left = 0;
            margin-right = 0;
            margin-bottom = 0;
            spacing = 3;

            modules-left = [
              "hyprland/workspaces"
              "custom/sep"
              "hyprland/window"
              "custom/background-apps"
              "cpu"
              "memory"
              "custom/gpuinfo"
            ];
            modules-center = [
              "custom/cpucat"
              "clock"
            ];
            modules-right = [
              "wireplumber"
              "backlight"
              "bluetooth"
              "network"
              "battery"
              "mpris"
              "clock#date"
              "hyprland/language"
              "custom/notification"
            ];

            "hyprland/workspaces" = {
              format = "{name}";
              on-click = "activate";
              sort-by-number = true;
            };

            "custom/sep" = {
              format = "";
              tooltip = false;
              interval = "once";
            };

            "hyprland/window" = {
              format = "{}";
              rewrite = {
                "" = "Desktop";
                "kitty" = "Terminal";
                "zsh" = "Terminal";
                "~" = "Terminal";
              };
              icon = true;
              separate-outputs = true;
              max-length = 60;
            };

            "custom/background-apps" = {
              exec = "${backgroundApps}/bin/background-apps";
              exec-if = "test -x ${backgroundApps}/bin/background-apps";
              return-type = "json";
              format = "{}";
              interval = 5;
              tooltip = true;
            };

            "cpu" = {
              interval = 10;
              format = "󰍛 {usage}%";
              tooltip = false;
            };

            "memory" = {
              interval = 30;
              format = "󰾆 {percentage}%";
              tooltip-format = "󰘚 {used:.1f}GB / {total:.1f}GB";
            };

            "custom/gpuinfo" = {
              exec = "${gpuinfo}/bin/gpuinfo";
              return-type = "json";
              format = "{0}";
              on-click = "${gpuinfo}/bin/gpuinfo --toggle";
              interval = 5;
              tooltip = true;
            };

            "custom/cpucat" = {
              exec = "${pkgs.writeShellScriptBin "cpucat" ''
                CPU_USAGE=0.0
                SLEEP_AFTER=4
                AWAKE_FRAMES=($(eval echo {A..E}))
                SLEEP_FRAMES=($(eval echo {G..N}))
                COUNT=0
                read_cpu() {
                  awk '/^cpu /{user=$2; nice=$3; sys=$4; idle=$5; active=user+nice+sys; total=active+idle; printf "%d %d\n", active, total; exit}' /proc/stat
                }
                read prev_active prev_total < <(read_cpu)
                while true; do
                  read active total < <(read_cpu)
                  delta_active=$((active - prev_active))
                  delta_total=$((total - prev_total))
                  if [ "$delta_total" -le 0 ] || [ "$delta_active" -lt 0 ]; then
                    utilization="0.0000"
                  else
                    utilization=$(awk -v a="$delta_active" -v t="$delta_total" 'BEGIN { printf "%.4f", (a / t) }')
                  fi
                  CPU_USAGE=$utilization
                  SPEED=$(awk -v u="$CPU_USAGE" 'BEGIN { printf "%.2f", 0.22 - (u * 0.10) }')
                  if (($(echo "$SPEED < 0.05" | bc -l))); then SPEED=0.05; fi
                  if (($(echo "$CPU_USAGE < 0.02" | bc -l))); then
                    COUNT=$((COUNT + 1))
                  else
                    COUNT=0
                  fi
                  if [ $COUNT -ge $SLEEP_AFTER ]; then
                    for s in "''${SLEEP_FRAMES[@]}"; do echo "$s"; sleep "$SPEED"; done
                  else
                    for i in "''${AWAKE_FRAMES[@]}"; do echo "$i"; sleep "$SPEED"; done
                  fi
                  prev_active=$active; prev_total=$total
                done
              ''}/bin/cpucat";
              interval = "once";
            };

            "wireplumber" = {
              scroll-step = 5;
              format = " {icon} {volume}%";
              format-muted = "󰝟 muted";
              on-click = "pavucontrol";
              format-icons = {
                default = ["󰕿" "󰖀" "󰕾"];
                headphones = "󰋋";
                headset = "󰋎";
              };
            };

            "bluetooth" = {
              format = "";
              format-connected = " {num_connections}";
              tooltip-format = " {device_alias}";
              tooltip-format-connected = "{device_enumerate}";
              tooltip-format-enumerate-connected = " {device_alias}";
              on-click = "blueman-manager";
            };

            "network" = {
              format-wifi = "󰤨";
              format-ethernet = "󰈀";
              format-disconnected = "󰤯";
              format-disabled = "󰤮";
              format-icons = ["󰤟" "󰤢" "󰤥" "󰤨"];
              on-click = "nm-connection-editor";
              tooltip-format = "Gateway: {gwaddr}";
              tooltip-format-wifi = "Network: {essid}\nIP: {ipaddr}/{cidr}\nStrength: {signalStrength}%";
              tooltip-format-ethernet = "Interface: {ifname}";
              tooltip-format-disconnected = "Wi-Fi Disconnected";
              tooltip-format-disabled = "Wi-Fi Disabled";
            };

            "backlight" = {
              device = "intel_backlight";
              format = " {icon} {percent}% ";
              format-icons = ["󰃞" "󰃟" "󰃠"];
            };

            "battery" = {
              states = {
                warning = 30;
                critical = 15;
              };
              format = "{icon} {capacity}% ";
              format-charging = "󰂄 {capacity}% ";
              format-plugged = "󱟦 {capacity}% ";
              format-full = "󰁹 {capacity}% ";
              format-icons = [
                "󰂎"
                "󰁺"
                "󰁻"
                "󰁼"
                "󰁽"
                "󰁾"
                "󰁿"
                "󰂀"
                "󰂁"
                "󰂂"
                "󰁹"
              ];
            };

            "mpris" = {
              format = "  {artist} - {title} ";
              format-paused = " 󰐊 {artist} - {title} ";
              max-length = 37;
              tooltip = true;
              player = "spotify";
            };

            "clock#date" = {
              format = "{:%m-%d-%Y %H:%M} ";
            };

            "clock" = {
              format =
                if clock24h == true
                then "{:%R}"
                else "{:%I:%M %p}";
              format-alt =
                if clock24h == true
                then "{:%I:%M %p}"
                else "{:%R}";
              tooltip-format = "<tt>{calendar}</tt>";
              calendar = {
                mode = "month";
                mode-mon-col = 3;
                format = {
                  months = "<span color='${palette.accent}'><b>{}</b></span>";
                  weekdays = "<span color='${palette.blue}'><b>{}</b></span>";
                  today = "<span color='${palette.red}'><b><u>{}</u></b></span>";
                };
              };
              actions = {
                on-click-right = "mode";
                on-click-forward = "tz_up";
                on-click-backward = "tz_down";
              };
            };

            "hyprland/language" = {
              format = "{short}";
              on-click = "${keyboardswitch}/bin/keyboardswitch";
            };

            "custom/notification" = {
              tooltip = false;
              format = "{icon}";
              format-icons = {
                notification = "<span foreground='red'><sup></sup></span>";
                none = "";
                dnd-notification = "<span foreground='red'><sup></sup></span>";
                dnd-none = "";
                inhibited-notification = "<span foreground='red'><sup></sup></span>";
                inhibited-none = "";
                dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
                dnd-inhibited-none = "";
              };
              return-type = "json";
              exec-if = "which swaync-client";
              exec = "swaync-client -swb";
              on-click = "swaync-client -t -sw";
              on-click-right = "swaync-client -d -sw";
              escape = true;
            };
          };
        };
        style = ''
          * {
            font-family: "Iosevka Nerd Font", monospace;
            font-weight: 800;
            font-size: 13px;
            color: ${palette.accent};
            min-height: 0;
          }

          window#waybar {
            background: rgba(20, 18, 33, 0.75);
            border-radius: 0;
            margin: 0;
            padding: 0;
            margin-right: 8px;
          }

          /* WORKSPACES */
          #workspaces button {
            padding: 0px 1px;
            margin: 3px 2px;
            border-radius: 0;
            background: transparent;
            color: ${palette.muted};
          }

          #workspaces button.active {
            border-bottom: 2px solid ${palette.accent};
          }

          #workspaces button:hover {
            background: #1e1e1e;
          }

          #workspaces button.urgent {
            background: ${palette.muted};
          }

          #window {
            font-weight: 700;
            padding: 0 4px;
            color: ${palette.fg0};
          }

          #custom-sep {
            color: ${palette.surface2};
            font-size: 10px;
            padding: 0 2px;
          }

          #bluetooth {
            padding: 0 4px;
          }

          #bluetooth.disabled,
          #bluetooth.off {
            opacity: 0.4;
          }

          #network {
            padding: 0 4px;
          }

          #network.disconnected,
          #network.disabled {
            opacity: 0.4;
          }

          #mpris {
            font-weight: 700;
            padding: 0 4px;
          }

          #cpu {
            padding: 0 4px;
            color: ${palette.blue};
          }

          #memory {
            padding: 0 4px;
            color: ${palette.green};
          }

          #custom-gpuinfo {
            padding: 0 4px;
            color: ${palette.accent};
          }

          #custom-background-apps {
            padding: 0 4px;
            color: ${palette.fg0};
          }

          #custom-background-apps.active {
            color: ${palette.green};
          }

          /* RIGHT SIDE STATES */
          #battery.warning {
            background: rgba(246, 193, 119, 0.15);
            padding: 1px 4px;
          }

          #battery.critical {
            background: rgba(235, 111, 146, 0.18);
            padding: 1px 4px;
          }

          #wireplumber.muted {
            opacity: 0.6;
          }

          #custom-cpucat {
            font-family: "Iosevka Nerd Font", monospace;
            font-size: 20px;
            font-weight: bold;
            color: white;
            padding-left: 5px;
            padding-right: 8px;
          }
          #notification {
            padding: 0px 2px;
          }

          /* TOOLTIP */
          tooltip {
            background: #111111;
            border: 1px solid #333333;
          }

          tooltip label {
            color: ${palette.fg1};
            font-size: 11px;
          }
        '';
      };
    })
  ];
}
