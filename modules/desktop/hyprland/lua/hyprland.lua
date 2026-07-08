require("monitors")
require("variables")
require("settings")
require("animations")
require("binds")
require("rules")

os.execute("systemctl --user start awww-daemon.service")
