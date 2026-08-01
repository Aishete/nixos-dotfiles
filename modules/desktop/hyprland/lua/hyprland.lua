require("monitors")
require("variables")
require("settings")
require("animations")
require("binds")
require("rules")
require("plugins")

-- Bring up the rice's user services (quickshell bar + hyprpaper) on Hyprland
-- startup. They are WantedBy graphical-session.target, but on a MANUAL Hyprland
-- launch (e.g. from a TTY) that target is never activated and even refuses manual
-- start, so nothing pulls the daemons up and the bar/wallpaper silently vanish.
-- Starting the services directly here is idempotent (no-op if already running via
-- the target under a display manager) and works for both launch styles.
hl.on("hyprland.start", function()
  hl.exec_cmd("systemctl --user start quickshell.service hyprpaper.service")
end)

-- External monitor hotplug: when a monitor is added, re-apply the current
-- wallpaper so the new output isn't left blank/black. hyprpaper preloads every
-- theme wallpaper (see antiquity/default.nix), so the swap is flash-free.
-- The actual apply path is injected by the rice module (it owns the script's
-- store path); we just register the handler here.
pcall(require, "monitor_hotplug")

