---------------------------
-- Default awesome theme --
---------------------------
local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()
local conf_path = gfs.get_configuration_dir()
local gears = require("gears")

local theme = {}

theme.font = "JetBrains Mono 10"
-- theme.font = "Cascadia Code 10"
theme.nerd_font = "Cascadia Code"
theme.nerd_font_mono = "Cascadia Code"

--Color Scheme
--Well_intentions
--Liberated_nomads
theme.White = "#ECEEE9"
theme.Off_white = "#D5CEB4"
theme.Teal_blue = "#0091A2"
theme.Dusk_blue = "#1D538F"
-- theme.Dark_grey_blue = "#36576A"
theme.Dark_grey_blue = "#162635"
theme.Medium_pink = "#B7386F"
theme.Peachy_pink = "#CD7069"
theme.Dusty_red = "#AC343D"
theme.Custard = "#D0D34E"
theme.Blue_green = "#006B59"
theme.Slate = "#3E5E6B"
theme.Blue_grey = "#969FBE"
theme.Dark_grey = "#333333"

theme.fg_normal = theme.White
theme.fg_focus = theme.Off_white
theme.fg_minimize = theme.Custard
theme.fg_urgent = theme.Peachy_pink
theme.bg_systray = theme.bg_normal
theme.systray_icon_spacing = 3
theme.bg_focus_hover = theme.Dark_grey_blue
theme.bg_focus_hover_1 = theme.Teal_blue
theme.bg_notification_urgent = theme.Peachy_pink

theme.bg_normal = theme.Dark_grey_blue
theme.bg_focus = theme.Teal_blue
theme.bg_urgent = theme.Peachy_pink
theme.bg_minimize = theme.Custard
theme.fg_critical = theme.Medium_pink
theme.fg_calm = theme.Blue_green
theme.fg_calm_2 = theme.Teal_blue
theme.fg_notification_normal = theme.Off_white

theme.calendar_bg_normal = theme.Slate
theme.calendar_bg_focus = theme.Dusk_blue

theme.weather_day = theme.fg_focus
theme.weather_night = theme.fg_calm_2
-- theme.weather_max = theme.Peachy_pink
-- theme.weather_min = theme.Blue_green

theme.useless_gap = dpi(3)
theme.border_width = dpi(1)
theme.border_color_normal = theme.gray
-- theme.border_color_active = theme.red
theme.border_color_marked = theme.alt_white

local function rounded_shape(size, partial)
	if partial then
		return function(cr, width, height)
			gears.shape.partially_rounded_rect(cr, width, height, false, true, false, true, 5)
		end
	else
		return function(cr, width, height)
			gears.shape.rounded_rect(cr, width, height, size)
		end
	end
end

-- theme.calendar_month_border_width = 1
-- theme.calendar_month_padding = 5
-- theme.calendar_month_shape = rounded_shape(5)
-- theme.calendar_normal_shape = rounded_shape(5)
-- -- theme.calendar_normal_bg_color = (weekday == 4) and "#ff9800" or "#de5e1e"
-- theme.calendar_focus_fg_color = theme.black
-- theme.calendar_focus_bg_color = theme.lightred .. "aa"
-- theme.calendar_focus_shape = rounded_shape(5, true)
-- theme.calendar_focus_markup = function(t) return '<b>' .. t .. '</b>' end
-- theme.calendar_header_fg_color = theme.orange
-- theme.calendar_header_shape = rounded_shape(10)
-- theme.calendar_header_markup = function(t) return '<b>' .. t .. '</b>' end
-- theme.calendar_weekday_shape = rounded_shape(5)
-- theme.calendar_weekday_markup = function(t) return '<b>' .. t .. '</b>' end
-- theme.calendar_weekday_fg_color = theme.white

-- theme.notification_bg= theme.yellow

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- prompt_[fg|bg|fg_cursor|bg_cursor|font]
-- hotkeys_[bg|fg|border_width|border_color|shape|opacity|modifiers_fg|label_bg|label_fg|group_margin|font|description_font]
-- Example:
theme.taglist_bg_focus = theme.bg_focus .. "bb"
-- theme.taglist_bg_focus = theme.bg_normal
-- theme.taglist_bg_occupied = theme.bg_focus
theme.taglist_bg_urgent = theme.bg_urgent .. "66"
theme.taglist_bg_empty = theme.bg_normal
theme.taglist_fg_empty = theme.fg_focus .. "70"
theme.taglist_fg_focus = theme.fg_normal
theme.taglist_fg_occupied = theme.Off_white .. "cc"

theme.tasklist_bg_normal = theme.bg_focus .. "39"
theme.tasklist_bg_focus = theme.bg_focus .. "bb"
theme.tasklist_bg_urgent = theme.bg_urgent .. "aa"
theme.tasklist_bg_minimize = theme.bg_minimize .. "44"
theme.tasklist_fg_focus = theme.fg_normal
theme.tasklist_fg_minimize = theme.fg_normal

-- Generate taglist squares:
local taglist_square_size = dpi(0)
-- theme.taglist_squares_sel = theme_assets.taglist_squares_sel(
--     taglist_square_size, theme.fg_normal
-- )
-- theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(
--     taglist_square_size, theme.fg_normal
-- )

-- Variables set for theming notifications:
-- notification_font
-- notification_[bg|fg]
-- notification_[width|height|margin]
-- notification_[border_color|border_width|shape|opacity]

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = themes_path .. "default/submenu.png"
theme.menu_height = dpi(25)
theme.menu_width = dpi(200)

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

theme.wallpaper = conf_path .. "Wallpaper/wp.jpg"
-- theme.wallpaper = conf_path .. "Wallpaper/wp.png"

-- You can use your own layout icons like this:
theme.layout_fairh = gears.color.recolor_image(themes_path .. "default/layouts/fairhw.png", theme.fg_normal)
theme.layout_fairv = gears.color.recolor_image(themes_path .. "default/layouts/fairvw.png", theme.fg_normal)
theme.layout_floating = gears.color.recolor_image(themes_path .. "default/layouts/floatingw.png", theme.fg_normal)
theme.layout_magnifier = gears.color.recolor_image(themes_path .. "default/layouts/magnifierw.png", theme.fg_normal)
theme.layout_max = gears.color.recolor_image(themes_path .. "default/layouts/maxw.png", theme.fg_normal)
theme.layout_fullscreen = gears.color.recolor_image(themes_path .. "default/layouts/fullscreenw.png", theme.fg_normal)
theme.layout_tilebottom = gears.color.recolor_image(themes_path .. "default/layouts/tilebottomw.png", theme.fg_normal)
theme.layout_tileleft = gears.color.recolor_image(themes_path .. "default/layouts/tileleftw.png", theme.fg_normal)
theme.layout_tile = gears.color.recolor_image(themes_path .. "default/layouts/tilew.png", theme.fg_normal)
theme.layout_tiletop = gears.color.recolor_image(themes_path .. "default/layouts/tiletopw.png", theme.fg_normal)
theme.layout_spiral = gears.color.recolor_image(themes_path .. "default/layouts/spiralw.png", theme.fg_normal)
theme.layout_dwindle = gears.color.recolor_image(themes_path .. "default/layouts/dwindlew.png", theme.fg_normal)
theme.layout_cornernw = gears.color.recolor_image(themes_path .. "default/layouts/cornernww.png", theme.fg_normal)
theme.layout_cornerne = gears.color.recolor_image(themes_path .. "default/layouts/cornernew.png", theme.fg_normal)
theme.layout_cornersw = gears.color.recolor_image(themes_path .. "default/layouts/cornersww.png", theme.fg_normal)
theme.layout_cornerse = gears.color.recolor_image(themes_path .. "default/layouts/cornersew.png", theme.fg_normal)

-- Generate Awesome icon:
theme.awesome_icon = theme_assets.awesome_icon(theme.menu_height, theme.bg_focus, theme.fg_focus)
theme.notification_icon = conf_path .. "assets/icons/Light/alarm.svg"
-- theme.notification_icon = gears.color.recolor_image(conf_path .. "assets/icons/alarm1.svg", theme.fg_normal)
theme.notification_icon_empty = conf_path .. "assets/icons/Light/bell1.svg"
-- theme.dashboard_icon = conf_path .. "assets/icons/preference.png"
theme.dashboard_icon = gears.color.recolor_image(conf_path .. "assets/icons/preference.png", theme.fg_normal)
theme.notifications_delete_icon = conf_path .. "assets/icons/Light/broom1.svg"
theme.shutdown_icon = conf_path .. "assets/icons/shutdown.svg"
theme.reboot_icon = conf_path .. "assets/icons/reboot1.svg"
theme.logout_icon = conf_path .. "assets/icons/logout.svg"
theme.lockscreen_icon = conf_path .. "assets/icons/lockscreen.svg"

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = "Zafiro-Icons-Dark-Blue-f"

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
