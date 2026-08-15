-- Default rice binds (Waybar + SwayNC). Loaded by binds.lua when rice == "default".
-- `mainMod` is a global (variables.lua). This rice uses rofi-style `launcher drun`
-- for the app launcher. SwayNC notification-center toggles live here too (moved
-- from binds-common: they are default-rice-only actions).
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("launcher drun"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("swaync-client -t -sw"))
-- Wallpaper selector (rofi): writes the override file + applies via the
-- canonical preloaded path.
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("launcher wallpaper"))
-- Window list (rofi): every open window with icon + title, click to switch.
hl.bind(mainMod .. " + SHIFT + TAB", hl.dsp.exec_cmd("launcher window"))
