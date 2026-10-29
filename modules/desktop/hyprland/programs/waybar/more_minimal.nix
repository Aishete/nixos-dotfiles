{
  host,
  pkgs,
  ...
}: let
  inherit (import ../../../../../hosts/${host}/variables.nix) clock24h monospaceFont;
in {
  home-manager.sharedModules = [
    (_: {
      programs.waybar = {
        enable = true;

        settings = {
          mainBar = {
            # General Settings
            "margin-top" = 0;
            "margin-left" = 0;
            "margin-right" = 0;
            "spacing" = 8;

            # Layout Modules
            "modules-left" = [
              "hyprland/workspaces"
              "custom/media"
            ];
            "modules-center" = [];
            "modules-right" = [
              "tray"
              "battery"
            ];

            # Module Configurations
            "hyprland/workspaces" = {
              "format" = "{name}";
            };
            "tray" = {
              "icon-size" = 16;
              "spacing" = 10;
            };
            "battery" = {
              "states" = {
                "warning" = 30;
                "critical" = 15;
              };
              "format" = "{capacity}% {icon}";
              "format-full" = "{capacity}% {icon}";
              "format-charging" = "{capacity}% ";
              "format-plugged" = "{capacity}% ";
              "format-alt" = "{time} {icon}";
              "format-icons" = [ "" "" "" "" "" ];
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
          @define-color light-yellow #efbe71;
          @define-color yellow #ef944d;

          * {
            border-radius: 0px;
            font-family: ${monospaceFont};
            font-weight: 600;
            font-size: 16px;
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
            color: @light-yellow;
          }

          #workspaces button:hover, #tags button:hover {
            border: none;
            background: @gray-2;
            font-weight: 600;
            color: @light-yellow;
          }

          #workspaces button.active, button.focused, #tags button.active, button.focused {
            border: none;
            background: @yellow;
            color: @black;
            padding: 2px 16px;
          }

          #workspaces button.active:hover, button.focused:hover, #tags button.active:hover, button.focused:hover {
            border: none;
            background: @light-yellow;
            color: @black;
            padding: 2px 16px;
          }

          #clock, #cpu, #pulseaudio, #memory, #temperature, #battery, #tray {
            border: none;
            background: @black;
            box-shadow: none;
            text-shadow: none;
            padding: 0 16px;
            margin: 4px;
            color: @white;
          }

          #clock:hover, #cpu:hover, #pulseaudio:hover, #memory:hover, #temperature:hover, #battery:hover, #tray:hover {
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
