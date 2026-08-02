-- Default rice binds (Waybar + SwayNC). Loaded by binds.lua when rice == "default".
-- `mainMod` is a global (variables.lua). This rice uses rofi-style `launcher drun`
-- for the app launcher.
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("launcher drun"))
