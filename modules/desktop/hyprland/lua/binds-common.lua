-- Common binds shared by EVERY rice (default + antiquity).
-- Rice-specific binds live in binds-default.lua / binds-antiquity.lua and are
-- loaded by binds.lua (the dispatcher) based on rice.lua's `rice` value.
-- `mainMod` is a global (set by variables.lua, required before this file).

-- Mouse bindings
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Resize windows
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x = 30, y = 0 }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.resize({ x = -30, y = 0 }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.resize({ x = 0, y = -30 }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.resize({ x = 0, y = 30 }), { repeating = true })

-- Resize windows with hjkl keys
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.resize({ x = 30, y = 0 }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.resize({ x = -30, y = 0 }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.resize({ x = 0, y = -30 }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.resize({ x = 0, y = 30 }), { repeating = true })

-- Functional keybinds
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 2%-"), { repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +2%"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 2"), { repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 2"), { repeating = true })
hl.bind("xf86Sleep", hl.dsp.exec_cmd("systemctl suspend"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("pamixer --default-source -t"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pamixer -t"))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("xf86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("xf86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))

-- Keybinds help menu
hl.bind(mainMod .. " + question", hl.dsp.exec_cmd(keybinds_yad))
hl.bind(mainMod .. " + slash", hl.dsp.exec_cmd(keybinds_yad))
hl.bind(mainMod .. " + CTRL + K", hl.dsp.exec_cmd(keybinds_yad))

-- Autoclicker
hl.bind(mainMod .. " + F8",
    hl.dsp.exec_cmd("kill $(cat /tmp/auto-clicker.pid) 2>/dev/null || " .. autoclicker .. " --cps 40"))

-- Night Mode
hl.bind(mainMod .. " + F9", hl.dsp.exec_cmd("hyprsunset --temperature 3500"))
hl.bind(mainMod .. " + F10", hl.dsp.exec_cmd("pkill hyprsunset"))

-- Window/Session actions
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + delete", hl.dsp.exit())
hl.bind(mainMod .. " + W", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.group.toggle())
hl.bind("ALT + return", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + ALT + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + backspace", hl.dsp.exec_cmd("pkill -x wleave || wleave --css ~/.config/wleave/style.css"))
hl.bind("CONTROL + ESCAPE", hl.dsp.exec_cmd('pkill "waybar|hyprpanel" || ' .. bar))
hl.bind(mainMod .. " + CTRL + mouse_down", hl.dsp.exec_cmd(zoom .. " in"))
hl.bind(mainMod .. " + CTRL + mouse_up", hl.dsp.exec_cmd(zoom .. " out"))

-- Applications
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(term))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(term))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(editor))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("spotify"))
hl.bind(mainMod .. " + SHIFT + Y", hl.dsp.exec_cmd("youtube-music"))
hl.bind("CONTROL + ALT + DELETE", hl.dsp.exec_cmd(term .. " -e btop"))
hl.bind("CONTROL + ALT + M", hl.dsp.exec_cmd(term .. ' --class "microfetch" --hold -e microfetch'))
hl.bind(mainMod .. " + CTRL + C", hl.dsp.exec_cmd("hyprpicker --autocopy --format=hex"))

-- Misc
hl.bind(mainMod .. " + ALT + K", hl.dsp.exec_cmd(keyboardswitch))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + ALT + G", hl.dsp.exec_cmd(appearance))
-- Instant blur toggle (no menu): read current state, flip it
hl.bind(mainMod .. " + ALT + B", hl.dsp.exec_cmd("b=$(hyprctl getoption decoration:blur:enabled | awk 'NR==1{print $2}'); if [ \"$b\" = true ]; then hyprctl -q keyword decoration:blur:enabled false; else hyprctl -q keyword decoration:blur:enabled true; fi"))
hl.bind(mainMod .. " + CTRL + G", hl.dsp.exec_cmd(gapstoggle))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd(presentation_mirror))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(clipmanager))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(notes))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(rofimusic))

-- Screenshot/Screencapture
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd(screen_record .. " a"))
hl.bind(mainMod .. " + CTRL + R", hl.dsp.exec_cmd(screen_record .. " m"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd(screenshot .. " s"))
hl.bind(mainMod .. " + CTRL + P", hl.dsp.exec_cmd(screenshot .. " sf"))
hl.bind(mainMod .. " + print", hl.dsp.exec_cmd(screenshot .. " m"))
hl.bind(mainMod .. " + ALT + P", hl.dsp.exec_cmd(screenshot .. " p"))

-- Window focus with arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "d" }))
hl.bind("ALT + Tab", hl.dsp.focus({ direction = "d" }))

-- Window focus with hjkl
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "d" }))

-- Workspace switching
hl.bind(mainMod .. " + CTRL + right", hl.dsp.focus({ workspace = "r+1" }))
hl.bind(mainMod .. " + CTRL + left", hl.dsp.focus({ workspace = "r-1" }))
hl.bind(mainMod .. " + CTRL + down", hl.dsp.focus({ workspace = "empty" }))

-- Cycle windows
hl.bind(mainMod .. " + Tab", hl.dsp.window.cycle_next())

-- Rebuild
hl.bind(mainMod .. " + U", hl.dsp.exec_cmd(term .. " -e rebuild"))

-- Move active window
hl.bind(mainMod .. " + CTRL + ALT + right", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind(mainMod .. " + CTRL + ALT + left", hl.dsp.window.move({ workspace = "r-1" }))

-- Move window with SHIFT+CTRL arrows
hl.bind(mainMod .. " + SHIFT + CTRL + left", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + CTRL + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + CTRL + up", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + CTRL + down", hl.dsp.window.move({ direction = "d" }))
hl.bind(mainMod .. " + SHIFT + CTRL + H", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + CTRL + L", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + CTRL + K", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + CTRL + J", hl.dsp.window.move({ direction = "d" }))

-- Special workspaces (scratchpad)
hl.bind(mainMod .. " + CTRL + S", hl.dsp.window.move({ workspace = "special", follow = false }))
hl.bind(mainMod .. " + ALT + S", hl.dsp.window.move({ workspace = "special", follow = false }))
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("special"))

-- Mouse workspace switching
hl.bind(mainMod .. " + mouse:276", hl.dsp.focus({ workspace = "5" }))
hl.bind(mainMod .. " + mouse:275", hl.dsp.focus({ workspace = "6" }))
hl.bind(mainMod .. " + ALT + mouse:275", hl.dsp.focus({ workspace = "7" }))
hl.bind(mainMod .. " + SHIFT + mouse:276", hl.dsp.window.move({ workspace = "5" }))
hl.bind(mainMod .. " + SHIFT + mouse:275", hl.dsp.window.move({ workspace = "6" }))
hl.bind(mainMod .. " + SHIFT + ALT + mouse:275", hl.dsp.window.move({ workspace = "7" }))
hl.bind(mainMod .. " + CTRL + mouse:276", hl.dsp.window.move({ workspace = "5", follow = false }))
hl.bind(mainMod .. " + CTRL + mouse:275", hl.dsp.window.move({ workspace = "6", follow = false }))
hl.bind(mainMod .. " + CTRL + ALT + mouse:275", hl.dsp.window.move({ workspace = "7", follow = false }))

-- Scroll workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Workspace 1-10 with mainMod + number
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = tostring(i) }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = tostring(i) }))
    hl.bind(mainMod .. " + CTRL + " .. key, hl.dsp.window.move({ workspace = tostring(i), follow = false }))
end

-- Workspace 11-20 with ALT + number
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + ALT + " .. key, hl.dsp.focus({ workspace = tostring(i + 10) }))
    hl.bind(mainMod .. " + ALT + SHIFT + " .. key, hl.dsp.window.move({ workspace = tostring(i + 10) }))
end
