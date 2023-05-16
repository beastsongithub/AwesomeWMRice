local awful = require("awful")
local gfs = require("gears.filesystem")

local sh_path = gfs.get_configuration_dir() .. "assets/autostart.sh"

local function load_autostart()
	awful.spawn.with_shell(sh_path)
end

load_autostart()
