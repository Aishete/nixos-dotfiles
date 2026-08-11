-- end4pC rice binds (Quickshell M3 shell). Loaded by binds.lua when rice == "end4pC".
-- Globals available here: `mainMod` (variables.lua). The end4pc-* script paths
-- come from rice.lua (the rice identity table, required by the dispatcher
-- before this file). The shell owns its launcher/notifications/settings, so
-- this rice has no waybar/swaync/rofi binds.
local rice_conf = { rice = "default" }
pcall(function() rice_conf = require("rice") or rice_conf end)

-- SUPER+SPACE toggles the launcher (sidebarRight) on the focused monitor.
-- Script resolves the monitor at keypress time (config parse is too early).
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(rice_conf.end4pcLauncherBin))
-- SUPER+escape toggles the settings overlay (fork README: settings is an
-- overlay panel, not a window — SUPER+Q won't close it, this toggle does).
hl.bind(mainMod .. " + escape", hl.dsp.exec_cmd(rice_conf.end4pcSettingsBin))
-- SUPER+SHIFT+W opens the wallpaper selector (Hyprland global).
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.global("quickshell:wallpaperSelectorToggle"))
