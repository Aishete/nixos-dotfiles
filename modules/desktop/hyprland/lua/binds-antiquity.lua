-- Antiquity rice binds (Quickshell bar). Loaded by binds.lua when rice == "antiquity".
-- Globals available here: `mainMod` (variables.lua). The antiquity-* script
-- paths come from rice.lua (the rice identity table, required by the dispatcher
-- before this file). The `launcher *` commands are quickshell launchers, so
-- they belong to this rice only.
--
-- SUPER+Grave raises BOTH the main menu (Control Panel) and the bottom bar
-- (workspaces strip) in one keypress via the antiquity-raise script, which resolves
-- the focused monitor at keypress time and calls both quickshell IPC handlers.
local rice_conf = { rice = "default" }
pcall(function() rice_conf = require("rice") or rice_conf end)

hl.bind(mainMod .. " + Grave", hl.dsp.exec_cmd(rice_conf.antiquityRaiseBin))
-- SUPER+SPACE raises/lowers ONLY the curved bottom bar (no main menu).
-- The menu+curve combo stays on SUPER+Grave.
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(rice_conf.antiquityCurveBin))
-- SUPER+D opens the quickshell app launcher (upstream parity: quickshell ipc
-- call appLauncher_<mon> toggleAppLauncher). Script resolves the focused
-- monitor at keypress time.
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(rice_conf.antiquityLauncherBin))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("launcher wallpaper"))
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("launcher emoji"))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("launcher tmux"))
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("launcher games"))
