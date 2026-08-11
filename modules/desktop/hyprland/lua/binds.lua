-- Binds dispatcher. Loads the rice-agnostic common binds, then the active
-- rice's own bind file (soft separation: each rice owns its binds, so editing
-- one rice's binds can't silently affect another). The active rice is read from
-- rice.lua (generated per-host), falling back to "default".
require("binds-common")

local rice_state = "default"
pcall(function() rice_state = require("rice").rice or "default" end)

if rice_state == "antiquity" then
  require("binds-antiquity")
elseif rice_state == "end4pC" then
  require("binds-end4pC")
else
  require("binds-default")
end
