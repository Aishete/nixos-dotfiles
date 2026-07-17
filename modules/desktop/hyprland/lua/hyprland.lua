require("monitors")
require("variables")
require("settings")
require("animations")
require("binds")
require("rules")
require("plugins")

os.execute("systemctl --user start awww-daemon.service")
