-- Monitor configuration
hl.monitor({
	output = "eDP-1",
	mode = "1920x1080@60",
	position = "0x0",
	scale = 1,
})
hl.monitor({
	output = "DP-1",
	mode = "1920x1080@60",
	position = "1920x0",
	scale = 1,
})
hl.monitor({
	output = "HDMI-A-2",
	mode = "1920x1080@60",
	position = "3840x0",
	scale = 1,
})

-- Bind workspaces to monitors
hl.workspace_rule({ workspace = "7", persistent = true, monitor = "eDP-1", default = true })
hl.workspace_rule({ workspace = "8", persistent = true, monitor = "eDP-1" })
hl.workspace_rule({ workspace = "9", persistent = true, monitor = "eDP-1" })

hl.workspace_rule({ workspace = "1", persistent = true, monitor = "DP-1", default = true })
hl.workspace_rule({ workspace = "2", persistent = true, monitor = "DP-1" })
hl.workspace_rule({ workspace = "3", persistent = true, monitor = "DP-1" })

hl.workspace_rule({ workspace = "4", persistent = true, monitor = "HDMI-A-2", default = true })
hl.workspace_rule({ workspace = "5", persistent = true, monitor = "HDMI-A-2" })
hl.workspace_rule({ workspace = "6", persistent = true, monitor = "HDMI-A-2" })
