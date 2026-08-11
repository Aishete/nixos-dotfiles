-- Default rice binds (Waybar + SwayNC). Loaded by binds.lua when rice == "default".
-- `mainMod` is a global (variables.lua). This rice uses rofi-style `launcher drun`
-- for the app launcher. SwayNC notification-center toggles live here too (moved
-- from binds-common: they are default-rice-only actions; antiquity uses mako).
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("launcher drun"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("swaync-client -t -sw"))
