{ pkgs, ... }:
{
  home-manager.sharedModules = [
    (_: {
      programs.wleave = {
        enable = true;
        settings = {
          no-version-info = true;
          buttons-per-row = "3";
          css = "${./.}/style.css";

          buttons = [
            {
              label = "lock";
              action = "hyprlock";
              text = "Lock";
              keybind = "l";
            }
            {
              label = "logout";
              action = "hyprctl dispatch exit 0";
              text = "Logout";
              keybind = "e";
            }
            {
              label = "suspend";
              action = "systemctl suspend";
              text = "Suspend";
              keybind = "u";
            }
            {
              label = "reboot";
              action = "systemctl reboot";
              text = "Reboot";
              keybind = "r";
            }
            {
              label = "shutdown";
              action = "systemctl poweroff";
              text = "Shutdown";
              keybind = "s";
            }
          ];
        };
        style = ''
          * {
            font-family: "Iosevka Nerd Font", monospace;
            font-size: 14pt;
          }

          window {
            background-color: rgba(30, 30, 46, 0.9);
          }

          button {
            color: #cdd6f4;
            background-color: rgba(49, 50, 68, 0.8);
            border: none;
            border-radius: 0px;
            margin: 5px;
            padding: 10px 30px;
            transition: all 0.2s ease-in-out;
          }

          button:hover {
            background-color: #cba6f7;
            color: #1e1e2e;
          }

          button:focus {
            background-color: #cba6f7;
            color: #1e1e2e;
          }

          #lock:hover, #lock:focus {
            background-color: #89b4fa;
          }

          #logout:hover, #logout:focus {
            background-color: #f38ba8;
          }

          #suspend:hover, #suspend:focus {
            background-color: #f9e2af;
          }

          #reboot:hover, #reboot:focus {
            background-color: #a6e3a1;
          }

          #shutdown:hover, #shutdown:focus {
            background-color: #eba0ac;
          }
        '';
      };
    })
  ];
}
