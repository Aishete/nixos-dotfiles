{
  host,
  pkgs,
  ...
}:
let
  inherit (import ../../../../../hosts/${host}/variables.nix) clock24h monospaceFont;
  gpuinfo = pkgs.callPackage ../../scripts/gpuinfo.nix { };
in
{
  home-manager.sharedModules = [
    (_: {
      programs.waybar = {
        enable = true;

        settings = {
          mainBar = {
            # General Settings
            layer = "top";
            position = "top";
            mode = "dock";
            height = 32;
            exclusive = true;
            passthrough = false;
            gtk-layer-shell = true;
            ipc = true;
            fixed-center = true;
            margin-top = 0;
            margin-left = 0;
            margin-right = 0;
            margin-bottom = 0;
            spacing = 8;

            # Layout Modules
            "modules-left" = [
              "hyprland/workspaces"
              "custom/media"
              "cpu"
              "memory"
            ];
            "modules-center" = [
              "clock"
            ];
            "modules-right" = [
              "custom/gpuinfo"
              "backlight"
              "network"
              "pulseaudio"
              "battery"
              "custom/notification"
            ];

            # Module Configurations
            "hyprland/workspaces" = {
              on-click = "activate";
              all-outputs = false;
              show-special = false;
              sort-by-number = true;
              # Optional: Add icons to make it look cleaner
              format = "{name}:{icon}";
              format-icons = {
                "1" = "∀";
                "2" = "∃";
                "3" = "∂";
                "4" = "∇";
                "5" = "∆";
                "6" = "∫";
                "7" = "∑";
                "8" = "∏";
                "9" = "√";
                "empty" = " ";
                "urgent" = "";
              };
            };
            "tray" = {
              "icon-size" = 16;
              "spacing" = 10;
            };
            "custom/gpuinfo" = {
              "exec" = "${gpuinfo}/bin/gpuinfo";
              "return-type" = "json";
              "format" = "{0}";
              "interval" = 5;
              "tooltip" = true;
            };
            "cpu" = {
              "interval" = 10;
              "format" = "󰍛 {usage}%";
              "tooltip" = false;
            };
            "memory" = {
              "interval" = 30;
              "format" = "󰾆 {percentage}%";
              "tooltip-format" = "󰘚 {used:.1f}GB / {total:.1f}GB";
            };
            "backlight" = {
              "device" = "amdgpu_bl1";
              "format" = "{icon} {percent}%";
              "format-icons" = [
                "󰃞"
                "󰃟"
                "󰃠"
              ];
            };
            "network" = {
              format-wifi = "󰤨";
              format-ethernet = "󰈀";
              format-disconnected = "󰤯";
              format-disabled = "󰤮";
              format-icons = [
                "󰤟"
                "󰤢"
                "󰤥"
                "󰤨"
              ];
              on-click = "nm-connection-editor";
              tooltip-format = "Gateway: {gwaddr}";
              tooltip-format-wifi = "Network: {essid}\nIP: {ipaddr}/{cidr}\nStrength: {signalStrength}%";
              tooltip-format-ethernet = "Interface: {ifname}";
              tooltip-format-disconnected = "Wi-Fi Disconnected";
              tooltip-format-disabled = "Wi-Fi Disabled";
            };
            "pulseaudio" = {
              "format" = "{icon} {volume}%";
              "format-muted" = "󰝟 muted";
              "format-icons" = {
                "headphone" = "";
                "default" = [
                  ""
                  ""
                  ""
                ];
              };
              "on-click" = "pavucontrol";
            };
            "battery" = {
              "states" = {
                "warning" = 30;
                "critical" = 15;
              };
              "format" = "{capacity}% {icon}";
              "format-full" = "{capacity}% {icon}";
              "format-charging" = "{capacity}% 󱐋";
              "format-plugged" = "{capacity}% ";
              "format-alt" = "{time} {icon}";
              "format-icons" = [
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
            "clock" = {
              "format" = if clock24h == true then "{:%R}" else "{:%I:%M %p}";
              "format-alt" = "{:%Y-%m-%d %H:%M}";
              "tooltip-format" = "<tt><small>{calendar}</small></tt>";
            };
            "custom/notification" = {
              "tooltip" = false;
              "format" = "{icon}";
              "format-icons" = {
                "notification" = "<span foreground='red'><sup></sup></span>";
                "none" = "";
                "dnd-notification" = "<span foreground='red'><sup></sup></span>";
                "dnd-none" = "";
              };
              "return-type" = "json";
              "exec" = "swaync-client -swb";
              "on-click" = "swaync-client -t -sw";
              "on-click-right" = "swaync-client -d -sw";
              "escape" = true;
            };
            "custom/media" = {
              "format" = "{icon} {}";
              "return-type" = "json";
              "max-length" = 40;
              "format-icons" = {
                "spotify" = "";
                "default" = "🎜";
              };
              "escape" = true;
              "exec" = "$HOME/.config/waybar/mediaplayer.py 2> /dev/null";
            };
            "custom/backlight" = {
              "format" = "󰃠 {}%";
              "exec" = "brightnessctl get | awk '{print int($1*100/255)}'"; # Adjust if max brightness differs
              "interval" = 2;
              "on-scroll-up" = "brightnessctl set +5%";
              "on-scroll-down" = "brightnessctl set 5%-";
              "tooltip" = false;
            };
          };
        };

        style = ''
          @define-color black #0f0f0f;
          @define-color gray-0 #131414;
          @define-color gray-1 #1D1F1E;
          @define-color gray-2 #272A28;
          @define-color gray-3 #3A3F3C;
          @define-color gray-4 #585F5A;
          @define-color gray-5 #6B746E;
          @define-color gray-6 #878E7A;
          @define-color gray-7 #999C8B;
          @define-color gray-8 #B6B69A;
          @define-color gray-9 #D8CCB4;
          @define-color gray-10 #E3DAC9;
          @define-color white #F9EEE5;
          @define-color red #cb3d96;
          @define-color green #9dc34f;
          @define-color blue #89B4FA;

          * {
            border-radius: 0px;
            font-family: ${monospaceFont};
            font-weight: 600;
            font-size: 14px;
            margin: 0px;
          }

          window#waybar {
            background-color: @black;
            border: 2px solid @black;
            border-radius: 0px;
          }

          #workspaces, #tags {
            border: none;
            background: @black;
            box-shadow: none;
            text-shadow: none;
            padding: 0px;
            margin-bottom: 2px;
          }

          #workspaces button, #tags button {
            border: none;
            border-radius: 0px;
            background: @gray-1;
            box-shadow: none;
            text-shadow: none;
            padding: 2px 8px;
            margin: 0px;
            color: @red;
          }

          #workspaces button:hover, #tags button:hover {
            border: none;
            background: @gray-2;
            font-weight: 600;
            color: @red;
          }

          #workspaces button.active, button.focused, #tags button.active, button.focused {
            border: none;
            background: @green;
            color: @black;
            padding: 2px 16px;
          }

          #workspaces button.active:hover, button.focused:hover, #tags button.active:hover, button.focused:hover {
            border: none;
            background: @red;
            color: @black;
            padding: 2px 16px;
          }

          #clock, #cpu, #pulseaudio, #memory, #backlight, #battery, #tray, #network, #custom-gpuinfo, #custom-notification {
            border: none;
            background: @black;
            box-shadow: none;
            text-shadow: none;
            padding: 0 16px;
            margin: 4px;
            color: @white;
          }

          #cpu {
            color: @blue;
          }

          #memory {
            color: @green;
          }

          #custom-gpuinfo {
            color: @red;
          }

          #clock:hover, #cpu:hover, #pulseaudio:hover, #memory:hover, #backlight:hover, #battery:hover, #tray:hover, #network:hover, #custom-gpuinfo:hover, #custom-notification:hover {
            border: none;
            background: @gray-2;
            font-weight: 600;
            color: @white;
          }
        '';
      };
    })
  ];
}
