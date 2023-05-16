-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
-- config.color_scheme = "OneDark (Gogh)"
config.color_scheme = "Oceanic-Next"
-- config.color_scheme = "matrix"
config.font = wezterm.font_with_fallback({
	"Cascadia Code",
	{ family = "Symbols Nerd Font", weight = "Bold", stretch = "Normal", style = "Normal" },
	{ family = "IBM Plex Mono", weight = "Medium", stretch = "Normal", style = "Normal" },
	-- { family = "JetBrains Mono", weight = "Medium", stretch = "Normal", style = "Normal" },
	{ family = "Noto Sans Canadian Aboriginal", weight = "Bold", stretch = "Normal", style = "Normal" },
	{ family = "Noto Sans Symbols", weight = "Bold", stretch = "Normal", style = "Normal" },
	{ family = "Noto Sans Math", weight = "Medium", stretch = "Normal", style = "Normal" },
})
config.font_size = 12
config.term = "wezterm"
-- config.window_background_opacity = 0.7
-- config.line_height = 1.1
-- config.cell_width = 1.1

config.hide_tab_bar_if_only_one_tab = true

-- and finally, return the configuration to wezterm
return config
