require("monitors")
require("variables")
require("settings")
require("animations")
-- Rice identity is read inside binds.lua / settings.lua via require("rice")
-- (one file, emitted by the active rice module or the parent for "default").
require("binds")
require("rules")
require("plugins")

-- Bring up the rice's user services (bar/shell daemons) on Hyprland startup.
-- Each rice declares its service list in its rice.lua (`services` field):
-- antiquity -> "quickshell.service hyprpaper.service", end4pC ->
-- "quickshell-end4pc.service" (no hyprpaper — the shell renders its own
-- wallpaper), default -> none (started via settings.lua exec instead).
-- The services are WantedBy graphical-session.target, but on a MANUAL Hyprland
-- launch (e.g. from a TTY) that target is never activated and even refuses
-- manual start, so nothing pulls the daemons up and the bar/shell silently
-- vanish. Starting the services directly here is idempotent (no-op if already
-- running via the target under a display manager) and works for both launch
-- styles.
hl.on("hyprland.start", function()
  local rice_conf = {}
  pcall(function() rice_conf = require("rice") or {} end)
  local svcs = rice_conf.services or ""
  if svcs ~= "" then
    hl.exec_cmd("systemctl --user start " .. svcs)
  end
end)

-- External monitor hotplug: when a monitor is added, re-apply the current
-- wallpaper so the new output isn't left blank/black. hyprpaper preloads every
-- theme wallpaper (see antiquity/default.nix), so the swap is flash-free.
-- The actual apply path is injected by the rice module (it owns the script's
-- store path); we just register the handler here.
pcall(require, "monitor_hotplug")

