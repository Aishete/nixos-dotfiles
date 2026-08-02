-- Antiquity rice binds (Quickshell bar). Loaded by binds.lua when rice == "antiquity".
-- Globals available here: `mainMod` (variables.lua), `antiquityRaiseBin` (rices.lua,
-- required before binds by hyprland.lua). The `launcher *` commands are quickshell
-- launchers, so they belong to this rice only.
--
-- SUPER+Grave raises BOTH the main menu (Control Panel) and the bottom bar
-- (workspaces strip) in one keypress via the antiquity-raise script, which resolves
-- the focused monitor at keypress time and calls both quickshell IPC handlers.
hl.bind(mainMod .. " + Grave", hl.dsp.exec_cmd(antiquityRaiseBin))
-- SUPER+D opens the quickshell app launcher (upstream parity: quickshell ipc
-- call appLauncher_<mon> toggleAppLauncher). Script resolves the focused
-- monitor at keypress time.
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(antiquityLauncherBin))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("launcher wallpaper"))
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("launcher emoji"))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("launcher tmux"))
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("launcher games"))
