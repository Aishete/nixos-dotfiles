-- Rofi
hl.layer_rule({
	match = { namespace = "rofi" },
	blur = true,
	ignore_alpha = 0.7,
})

-- Hyprpanel Menus
hl.layer_rule({
	match = {
		namespace = "^(bar-.*|notifications-window|mediamenu|notificationsmenu|calendarmenu|audiomenu|networkmenu|energymenu|dashboardmenu)$",
	},
	blur = true,
	ignore_alpha = 0.7,
})

-- Swaync
hl.layer_rule({
	match = { namespace = "^(swaync-control-center)$" },
	blur = true,
	ignore_alpha = 0.7,
})
hl.layer_rule({
	match = { namespace = "^(swaync-notification-window)$" },
	blur = true,
	ignore_alpha = 0.8,
})

-- Waybar (tokyo theme)
hl.layer_rule({
	match = { namespace = "waybar" },
	blur = true,
	ignore_alpha = 0.75,
})

-- Window rules - opacity
hl.window_rule({ opacity = "1.0 1.0", match = { class = "^(firefox|Brave-browser|floorp|zen|zen-beta)$" } })
hl.window_rule({ opacity = "0.9 0.8", match = { class = "^(Emacs)$" } })
hl.window_rule({ opacity = "0.9 0.8", match = { class = "^(gcr-prompter)$" } })
hl.window_rule({ opacity = "0.9 0.8", match = { title = "^(Hyprland Polkit Agent)$" } })
hl.window_rule({ opacity = "1.0 1.0", match = { class = "^(obsidian)$" } })
hl.window_rule({ opacity = "0.9 0.8", match = { class = "^(proton.vpn.app.gtk)$" } })
hl.window_rule({ opacity = "0.9 0.8", match = { class = "^(heroic)$" } })
hl.window_rule({ opacity = "0.9 0.8", match = { class = "^(Lutris|lutris|net.lutris.Lutris)$" } })

hl.window_rule({ opacity = "0.8 0.7", match = { class = "^(kitty|alacritty|Alacritty|org.wezfurlong.wezterm|com.mitchellh.ghostty)$" } })
hl.window_rule({ opacity = "0.8 0.7", match = { class = "^(nvim-wrapper)$" } })
hl.window_rule({ opacity = "0.8 0.7", match = { class = "^(gnome-disks)$" } })
hl.window_rule({ opacity = "0.8 0.7", match = { class = "^(org.gnome.Nautilus|Thunar|thunar|pcmanfm)$" } })
hl.window_rule({ opacity = "0.8 0.7", match = { class = "^(thunar-volman-settings)$" } })
hl.window_rule({ opacity = "0.8 0.7", match = { class = "^(org.gnome.FileRoller)$" } })
hl.window_rule({ opacity = "0.8 0.7", match = { class = "^(io.github.ilya_zlobintsev.LACT)$" } })
hl.window_rule({ opacity = "0.8 0.7", match = { class = "^(Steam|steam|steamwebhelper)$" } })
hl.window_rule({ opacity = "0.8 0.7", match = { class = "^(Spotify|spotify|com.github.th_ch.youtube_music)$" } })
hl.window_rule({ opacity = "0.8 0.7", match = { title = "^(Kvantum Manager)$" } })
hl.window_rule({ opacity = "0.8 0.7", match = { class = "^(VSCodium|codium-url-handler)$" } })
hl.window_rule({ opacity = "0.8 0.7", match = { class = "^(code|code-url-handler)$" } })
hl.window_rule({ opacity = "0.8 0.7", match = { class = "^(tuiFileManager)$" } })
hl.window_rule({ opacity = "0.8 0.7", match = { class = "^(org.kde.dolphin)$" } })
hl.window_rule({ opacity = "0.8 0.7", match = { class = "^(org.kde.ark)$" } })
hl.window_rule({ opacity = "0.8 0.7", match = { class = "^(nwg-look)$" } })
hl.window_rule({ opacity = "0.8 0.7", match = { class = "^(qt5ct|qt6ct)$" } })
hl.window_rule({ opacity = "0.8 0.7", match = { class = "^(yad)$" } })
hl.window_rule({ opacity = "0.8 0.7", match = { class = "^(gjs)$" } })

hl.window_rule({ opacity = "0.9 0.8", match = { class = "^(discord)$" } })
hl.window_rule({ opacity = "0.9 0.8", match = { class = "^(WebCord)$" } })
hl.window_rule({ opacity = "0.9 0.8", match = { class = "^(com.github.rafostar.Clapper)$" } })
hl.window_rule({ opacity = "0.8 0.7", match = { class = "^(com.github.tchx84.Flatseal)$" } })
hl.window_rule({ opacity = "0.8 0.7", match = { class = "^(hu.kramo.Cartridges)$" } })
hl.window_rule({ opacity = "0.8 0.7", match = { class = "^(com.obsproject.Studio)$" } })
hl.window_rule({ opacity = "0.8 0.7", match = { class = "^(gnome-boxes)$" } })
hl.window_rule({ opacity = "0.8 0.7", match = { class = "^(app.drey.Warp)$" } })
hl.window_rule({ opacity = "0.8 0.7", match = { class = "^(net.davidotek.pupgui2)$" } })
hl.window_rule({ opacity = "0.8 0.7", match = { class = "^(Signal)$" } })
hl.window_rule({ opacity = "0.8 0.7", match = { class = "^(io.gitlab.theevilskeleton.Upscaler)$" } })

hl.window_rule({ opacity = "0.8 0.7", match = { class = "^(pavucontrol)$" } })
hl.window_rule({ opacity = "0.8 0.7", match = { class = "^(org.pulseaudio.pavucontrol)$" } })
hl.window_rule({ opacity = "0.8 0.7", match = { class = "^(blueman-manager)$" } })
hl.window_rule({ opacity = "0.8 0.7", match = { class = "^(.blueman-manager-wrapped)$" } })
hl.window_rule({ opacity = "0.8 0.7", match = { class = "^(nm-applet)$" } })
hl.window_rule({ opacity = "0.8 0.7", match = { class = "^(nm-connection-editor)$" } })
hl.window_rule({ opacity = "0.8 0.7", match = { class = "^(org.kde.polkit-kde-authentication-agent-1)$" } })

-- Picture-in-Picture
hl.window_rule({ floating = true, match = { title = "^(Picture-in-Picture)$", class = "^(zen|zen-beta|floorp|firefox)$" } })
hl.window_rule({ pin = true, match = { title = "^(Picture-in-Picture)$", class = "^(zen|zen-beta|floorp|firefox)$" } })

-- Games
hl.window_rule({ content = "game", match = { tag = "games" } })
hl.window_rule({ tag = "+games", match = { content = "3" } })
hl.window_rule({ tag = "+games", match = { class = "^(steam_app.*|steam_app_\\d+)$" } })
hl.window_rule({ tag = "+games", match = { class = "^(gamescope)$" } })
hl.window_rule({ tag = "+games", match = { class = "(Waydroid)" } })
hl.window_rule({ tag = "+games", match = { class = "(osu!)" } })

hl.window_rule({ sync_fullscreen = true, match = { tag = "games" } })
hl.window_rule({ fullscreen = true, match = { tag = "games" } })
hl.window_rule({ border_size = 0, match = { tag = "games" } })
hl.window_rule({ no_shadow = true, match = { tag = "games" } })
hl.window_rule({ no_blur = true, match = { tag = "games" } })
hl.window_rule({ no_anim = true, match = { tag = "games" } })

-- Godot
hl.window_rule({ tile = true, match = { title = "(.*)(Godot)(.*)$" } })

-- Microfetch
hl.window_rule({ opacity = "0.8 0.7", match = { class = "^(microfetch)$" } })
hl.window_rule({ floating = true, match = { class = "^(microfetch)$" } })
hl.window_rule({ center = true, match = { class = "^(microfetch)$" } })
hl.window_rule({ size = { w = 802, h = 261 }, match = { class = "^(microfetch)$" } })

-- Floating windows
hl.window_rule({ floating = true, match = { class = "^(qt5ct)$" } })
hl.window_rule({ floating = true, match = { class = "^(nwg-look)$" } })
hl.window_rule({ floating = true, match = { class = "^(org.kde.ark)$" } })
hl.window_rule({ floating = true, match = { class = "^(Signal)$" } })
hl.window_rule({ floating = true, match = { class = "^(com.github.rafostar.Clapper)$" } })
hl.window_rule({ floating = true, match = { class = "^(app.drey.Warp)$" } })
hl.window_rule({ floating = true, match = { class = "^(net.davidotek.pupgui2)$" } })
hl.window_rule({ floating = true, match = { class = "^(eog)$" } })
hl.window_rule({ floating = true, match = { class = "^(io.gitlab.theevilskeleton.Upscaler)$" } })
hl.window_rule({ floating = true, match = { class = "^(yad)$" } })
hl.window_rule({ floating = true, match = { class = "^(pavucontrol)$" } })
hl.window_rule({ floating = true, match = { class = "^(blueman-manager)$" } })
hl.window_rule({ floating = true, match = { class = "^(.blueman-manager-wrapped)$" } })
hl.window_rule({ floating = true, match = { class = "^(nm-applet)$" } })
hl.window_rule({ floating = true, match = { class = "^(nm-connection-editor)$" } })
hl.window_rule({ floating = true, match = { class = "^(org.kde.polkit-kde-authentication-agent-1)$" } })

-- No blur on games
hl.window_rule({ no_blur = true, match = { tag = "games" } })