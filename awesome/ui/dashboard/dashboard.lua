local beautiful = require("beautiful")
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local helpers = require("helpers")
local conf_path = gears.filesystem.get_configuration_dir()

--{{{ُSliders
local function mkslider(args)
	args.minimum = args.minimum or 0
	args.maximum = args.maximum or 100
	args.bar_height = args.bar_height or 30
	args.forced_width = args.forced_width or 235
	args.forced_height = args.forced_height or args.bar_height
	args.icon = args.icon or ""
	args.buttons = args.buttons
	args.bar_color = args.bar_color or beautiful.bg_focus .. "aa"
	args.bar_active_color = args.bar_active_color or beautiful.fg_normal
	return wibox.widget({
		{
			id = "icon_role",
			markup = helpers.get_colorized_markup(args.icon, args.bar_active_color),
			font = beautiful.nerd_font_mono .. " 25",
			valign = "center",
			halign = "left",
			forced_width = 35,
			buttons = args.buttons,
			widget = wibox.widget.textbox,
		},
		{
			id = "slider_role",
			minimum = args.minimum,
			maximum = args.maximum,
			bar_shape = gears.shape.rounded_bar,
			bar_height = args.bar_height,
			bar_color = args.bar_color,
			bar_active_color = args.bar_active_color,
			valign = "center",
			halign = "center",
			handle_width = args.bar_height,
			handle_shape = gears.shape.circle,
			handle_color = args.bar_active_color,
			forced_width = args.forced_width,
			forced_height = args.forced_height,
			widget = wibox.widget.slider,
			backup_active_color = args.bar_active_color,
		},
		{
			id = "text_role",
			valign = "center",
			halign = "center",
			font = beautiful.nerd_font .. " 12",
			forced_height = args.bar_height,
			forced_width = 30,
			widget = wibox.widget.textbox,
		},
		spacing = 4,
		layout = wibox.layout.fixed.horizontal,
		set_value = function(self, new_value)
			self:get_children_by_id("slider_role")[1].value = new_value
			self.text_role.markup =
				helpers.get_colorized_markup("<b>" .. helpers.trim(new_value) .. "</b>", args.bar_active_color)
		end,
	})
end

Volume_slider = mkslider({
	minimum = 0,
	maximum = 150,
	icon = "",
	bar_active_color = beautiful.fg_focus,
	buttons = gears.table.join(awful.button({}, 1, function()
		awful.spawn("pavucontrol")
	end)),
})

Brightness_slider = mkslider({
	minimum = 0,
	maximum = 100,
	icon = "󱩔",
	bar_active_color = beautiful.fg_focus,
})

awful.spawn.easy_async_with_shell(
	"sleep 30 && pactl get-sink-volume $(pactl info | grep 'Default Sink' | cut -d ' ' -f3) | awk {'print $5'} | sed 's/%//'",
	function(out)
		Volume_slider.value = helpers.trim(out)
	end
)

awful.spawn.easy_async_with_shell("xrandr --verbose | grep 'Brightness' | awk {'print $2'}", function(out)
	Brightness_slider.value = out * 100
end)

Volume_popup = awful.popup({
	widget = {
		Volume_slider,
		margins = 20,
		widget = wibox.container.margin,
	},
	ontop = true,
	honor_workarea = true,
	bg = beautiful.bg_normal,
	visible = false,
	shape = helpers.mkroundrect(),
	placement = awful.placement.centered,
})

Brightness_popup = awful.popup({
	widget = {
		Brightness_slider,
		margins = 20,
		widget = wibox.container.margin,
	},
	ontop = true,
	honor_workarea = true,
	bg = beautiful.bg_normal,
	visible = false,
	shape = helpers.mkroundrect(),
	placement = awful.placement.centered,
})

Volume_slider:get_children_by_id("slider_role")[1]:connect_signal("property::value", function(self, new_value)
	awful.spawn.with_shell(
		"pactl set-sink-volume $(pactl info | grep 'Default Sink' | cut -d ' ' -f3) " .. new_value .. "%"
	)
	Volume_slider.text_role.markup = helpers.get_colorized_markup(
		"<b>" .. tostring(new_value) .. "</b>",
		new_value <= 100 and self.backup_active_color or beautiful.bg_urgent
	)
	Volume_slider.icon_role.markup =
		helpers.get_colorized_markup("", new_value <= 100 and self.backup_active_color or beautiful.bg_urgent)
	self.bar_active_color = new_value <= 100 and self.backup_active_color or beautiful.bg_urgent
	self.handle_color = new_value <= 100 and self.backup_active_color or beautiful.bg_urgent
end)

Brightness_slider:get_children_by_id("slider_role")[1]:connect_signal("property::value", function(self, new_value)
	awful.spawn.with_shell("xrandr --output LVDS-1 --brightness " .. new_value / 100)
	Brightness_slider.text_role.markup =
		helpers.get_colorized_markup("<b>" .. tostring(new_value) .. "</b>", self.bar_active_color)
end)

function Volume_popup.hide()
	Volume_popup.visible = false
end

function Volume_popup.show()
	Volume_popup.visible = true
end

function Brightness_popup.hide()
	Brightness_popup.visible = false
end

function Brightness_popup.show()
	Brightness_popup.visible = true
end

Brightness_down = awful.keygrabber({
	keybindings = {
		awful.key({}, "XF86MonBrightnessDown", function()
			awful.spawn.easy_async_with_shell(
				"xrandr --output LVDS-1 --brightness $[$(xrandr --verbose | grep 'Brightness' | awk {'print $2'}) - .1] && xrandr --verbose | grep 'Brightness' | awk {'print $2'}",
				function(out)
					Brightness_slider.value = out * 100
					Brightness_popup.show()
				end
			)
		end),
	},
	autostart = false,
	stop_key = "XF86MonBrightnessUp",
	timeout = 0.5,
	stop_event = "press",
	keypressed_callback = function()
		awful.spawn.easy_async_with_shell(
			"xrandr --output LVDS-1 --brightness $[$(xrandr --verbose | grep 'Brightness' | awk {'print $2'}) - .1] && xrandr --verbose | grep 'Brightness' | awk {'print $2'}",
			function(out)
				Brightness_slider.value = out * 100
			end
		)
	end,
	timeout_callback = function()
		Brightness_popup.hide()
	end,
	export_keybindings = true,
})

Brightness_up = awful.keygrabber({
	keybindings = {
		awful.key({}, "XF86MonBrightnessUp", function()
			awful.spawn.easy_async_with_shell(
				"xrandr --output LVDS-1 --brightness $[$(xrandr --verbose | grep 'Brightness' | awk {'print $2'}) + .1] && xrandr --verbose | grep 'Brightness' | awk {'print $2'}",
				function(out)
					Brightness_slider.value = out * 100
					Brightness_popup.show()
				end
			)
		end),
	},
	autostart = false,
	stop_key = "XF86MonBrightnessDown",
	timeout = 0.5,
	stop_event = "press",
	keypressed_callback = function()
		awful.spawn.easy_async_with_shell(
			"xrandr --output LVDS-1 --brightness $[$(xrandr --verbose | grep 'Brightness' | awk {'print $2'}) + .1] && xrandr --verbose | grep 'Brightness' | awk {'print $2'}",
			function(out)
				Brightness_slider.value = out * 100
			end
		)
	end,
	timeout_callback = function()
		Brightness_popup.hide()
	end,
	export_keybindings = true,
})

Volume_down = awful.keygrabber({
	keybindings = {
		awful.key({}, "XF86AudioLowerVolume", function()
			awful.spawn.easy_async_with_shell(
				"pactl set-sink-volume $(pactl info | grep 'Default Sink' | cut -d ' ' -f3) -5% && pactl get-sink-volume $(pactl info | grep 'Default Sink' | cut -d ' ' -f3) | awk {'print $5'} | sed 's/%//'",
				function(out)
					Volume_slider.value = out
					Volume_popup.show()
				end
			)
		end),
	},
	autostart = false,
	stop_key = "XF86AudioRaiseVolume",
	timeout = 0.5,
	stop_event = "press",
	keypressed_callback = function()
		awful.spawn.easy_async_with_shell(
			"pactl set-sink-volume $(pactl info | grep 'Default Sink' | cut -d ' ' -f3) -5% && pactl get-sink-volume $(pactl info | grep 'Default Sink' | cut -d ' ' -f3) | awk {'print $5'} | sed 's/%//'",
			function(out)
				Volume_slider.value = out
			end
		)
	end,
	timeout_callback = function()
		Volume_popup.hide()
	end,
	export_keybindings = true,
})

Volume_up = awful.keygrabber({
	keybindings = {
		awful.key({}, "XF86AudioRaiseVolume", function()
			awful.spawn.easy_async_with_shell(
				"pactl set-sink-volume $(pactl info | grep 'Default Sink' | cut -d ' ' -f3) +5% && pactl get-sink-volume $(pactl info | grep 'Default Sink' | cut -d ' ' -f3) | awk {'print $5'} | sed 's/%//'",
				function(out)
					Volume_slider.value = out
					Volume_popup.show()
				end
			)
		end),
	},
	autostart = false,
	stop_key = "XF86AudioLowerVolume",
	timeout = 0.5,
	stop_event = "press",
	keypressed_callback = function()
		awful.spawn.easy_async_with_shell(
			"pactl set-sink-volume $(pactl info | grep 'Default Sink' | cut -d ' ' -f3) +5% && pactl get-sink-volume $(pactl info | grep 'Default Sink' | cut -d ' ' -f3) | awk {'print $5'} | sed 's/%//'",
			function(out)
				Volume_slider.value = out
			end
		)
	end,
	timeout_callback = function()
		Volume_popup.hide()
	end,
	export_keybindings = true,
})

--The popup in the notification Sidebar
local sliders = wibox.widget({
	{
		{
			{
				{
					{
						Volume_slider,
						Brightness_slider,
						spacing = 6,
						layout = wibox.layout.fixed.vertical,
					},
					valign = "center",
					halign = "center",
					widget = wibox.container.place,
				},
				top = 10,
				bottom = 10,
				left = 10,
				right = 10,
				widget = wibox.container.margin,
			},
			shape = helpers.mkroundrect(),
			border_width = 2,
			border_color = beautiful.fg_focus,
			bg = beautiful.bg_normal,
			widget = wibox.container.background,
		},
		layout = wibox.layout.fixed.horizontal,
	},
	layout = wibox.layout.fixed.vertical,
})
--}}}

--{{{PowerButtons
local function mkpowerbutton(icon, button_action)
	local button = wibox.widget({
		{
			{
				image = icon,
				scaling_quality = "best",
				valign = "center",
				halign = "center",
				forced_width = 28,
				forced_height = 28,
				widget = wibox.widget.imagebox,
			},
			margins = 10,
			widget = wibox.container.margin,
		},
		bg = beautiful.bg_normal,
		border_width = 2,
		border_color = beautiful.fg_focus,
		shape = helpers.mkroundrect(),
		buttons = button_action,
		widget = wibox.container.background,
	})
	helpers.add_hover(button, beautiful.bg_normal .. "55", beautiful.bg_focus)
	return button
end

local powermenu = wibox.widget({
	{
		{
			{
				mkpowerbutton(
					beautiful.shutdown_icon,
					gears.table.join(awful.button({}, 1, function()
						awful.spawn.with_shell("shutdown now")
					end))
				),
				mkpowerbutton(
					beautiful.reboot_icon,
					gears.table.join(awful.button({}, 1, function()
						awful.spawn.with_shell("reboot")
					end))
				),
				mkpowerbutton(
					beautiful.logout_icon,
					gears.table.join(awful.button({}, 1, function()
						awesome.quit()
					end))
				),
				mkpowerbutton(
					beautiful.lockscreen_icon,
					gears.table.join(awful.button({}, 1, function()
						awful.spawn.with_shell("betterlockscreen -l")
					end))
				),
				spacing = 10,
				layout = wibox.layout.fixed.horizontal,
			},
			valign = "center",
			halign = "center",
			widget = wibox.container.place,
		},
		top = 10,
		bottom = 10,
		widget = wibox.container.margin,
	},
	shape = helpers.mkroundrect(),
	border_width = 2,
	border_color = beautiful.fg_focus,
	bg = beautiful.bg_normal,
	widget = wibox.container.background,
})
--}}}

--{{{Sensors
local function mk_sensor(args)
	args.icon = args.icon or ""
	args.min_value = args.min_value or 0
	args.max_value = args.max_value or 100
	args.color = args.color or beautiful.fg_normal
	args.max_color = args.max_color or beautiful.fg_critical
	args.min_color = args.min_color or beautiful.fg_calm
	return wibox.widget({
		{
			{
				{
					id = "icon_role",
					markup = helpers.get_colorized_markup(args.icon, args.color),
					font = beautiful.nerd_font .. " 24",
					valign = "center",
					halign = "center",
					forced_width = 30,
					forced_height = 30,
					widget = wibox.widget.textbox,
				},
				id = "radial_role",
				value = 0,
				min_value = args.min_value,
				max_value = args.max_value,
				color = args.color,
				border_width = 12,
				forced_width = 110,
				forced_height = 110,
				border_color = "#00000000",
				widget = wibox.container.radialprogressbar,
			},
			margins = 20,
			widget = wibox.container.margin,
		},
		bg = beautiful.bg_normal,
		-- shape = helpers.mkroundrect(),
		shape = gears.shape.circle,
		border_width = 2,
		border_color = beautiful.fg_focus,
		widget = wibox.container.background,
		set_value = function(self, new_value)
			self:get_children_by_id("radial_role")[1].value = new_value
		end,
		set_color = function(self, new_value)
			self:get_children_by_id("radial_role")[1].color = (new_value > 80 and args.max_color)
				or (new_value < 60 and args.min_color)
				or args.color
			self:get_children_by_id("icon_role")[1].markup = helpers.get_colorized_markup(
				args.icon,
				(new_value > 80 and args.max_color) or (new_value < 60 and args.min_color) or args.color
			)
		end,
	})
end

Temp_sensor = mk_sensor({
	icon = "  ",
	color = beautiful.fg_focus,
	min_value = 0,
	max_value = 105,
})
Ram_sensor = mk_sensor({ icon = "  ", min_value = 0, max_value = 100, color = beautiful.fg_focus })
Cpu_sensor = mk_sensor({ icon = "  ", color = beautiful.fg_focus })
Disk_sensor = mk_sensor({ icon = "  ", color = beautiful.fg_focus })

temp_timer = gears.timer({
	timeout = 4,
	call_now = true,
	autostart = false,
	callback = function()
		awful.spawn.easy_async_with_shell(conf_path .. "scripts/temp.sh cpu", function(output)
			Temp_sensor.value = tonumber(output)
			Temp_sensor.color = tonumber(output)
		end)
	end,
})
ram_timer = gears.timer({
	timeout = 4,
	call_now = true,
	autostart = false,
	callback = function()
		awful.spawn.easy_async_with_shell("free | grep Mem | awk '{print $3/$2}' ", function(output)
			Ram_sensor.value = tonumber(output) * 100
		end)
	end,
})
cpu_timer = gears.timer({
	timeout = 2,
	call_now = true,
	autostart = false,
	callback = function()
		awful.spawn.easy_async_with_shell(
			"awk '{u=$2+$4; t=$2+$4+$5; if (NR==1){u1=u; t1=t;} else print ($2+$4-u1) * 100 / (t-t1); }' <(grep 'cpu ' /proc/stat) <(sleep 1;grep 'cpu ' /proc/stat)",
			function(output)
				Cpu_sensor.value = tonumber(output)
			end
		)
	end,
})

disk_timer = gears.timer({
	timeout = 15,
	call_now = true,
	autostart = false,
	callback = function()
		awful.spawn.easy_async_with_shell("df --output=pcent / | tail -n 1 | sed 's/%//g' | xargs", function(output)
			Disk_sensor.value = tonumber(output)
		end)
	end,
})

--}}}

--{{{Calendar
local styles = {}
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
styles.month = {
	padding = 8,
	bg_color = beautiful.bg_normal,
	border_width = 0,
}
styles.normal = {
	shape = rounded_shape(5),
	fg_color = beautiful.fg_focus,
	bg_color = beautiful.calendar_bg_normal .. "aa",
}
styles.focus = {
	fg_color = beautiful.fg_normal,
	bg_color = beautiful.calendar_bg_focus,
	markup = function(t)
		return "<b>" .. t .. "</b>"
	end,
	shape = rounded_shape(5, true),
}
styles.header = {
	fg_color = beautiful.fg_normal,
	bg_color = beautiful.calendar_bg_normal .. "99",
	markup = function(t)
		return "<b>" .. t .. "</b>"
	end,
	shape = rounded_shape(10),
}
styles.weekday = {
	fg_color = beautiful.fg_calm_2,
	bg_color = beautiful.calendar_bg_normal .. "aa",
	markup = function(t)
		return "<b>" .. t .. "</b>"
	end,
	shape = rounded_shape(5),
}
local function decorate_cell(widget, flag, date)
	if flag == "monthheader" and not styles.monthheader then
		flag = "header"
	end
	local props = styles[flag] or {}
	if props.markup and widget.get_text and widget.set_markup then
		widget:set_markup(props.markup(widget:get_text()))
	end
	-- Change bg color for weekends
	local d = { year = date.year, month = (date.month or 1), day = (date.day or 1) }
	local weekday = tonumber(os.date("%w", os.time(d)))
	local default_bg = (weekday == 0 or weekday == 6) and "#232323" or "#383838"
	local ret = wibox.widget({
		{
			widget,
			margins = (props.padding or 2) + (props.border_width or 0),
			widget = wibox.container.margin,
		},
		shape = props.shape,
		border_color = props.border_color or "#b9214f",
		border_width = props.border_width or 0,
		fg = props.fg_color or "#999999",
		bg = props.bg_color or default_bg,
		widget = wibox.container.background,
	})
	return ret
end
local calendar_widget = wibox.widget({
	id = "calendar_role",
	date = os.date("*t"),
	spacing = 3,
	forced_height = 225,
	long_weekdays = true,
	start_sunday = true,
	fn_embed = decorate_cell,
	widget = wibox.widget.calendar.month,
})

local current_month = os.date("*t").month
Calendar = wibox.widget({
	{
		calendar_widget,
		{
			{
				{
					markup = helpers.get_colorized_markup(" ", beautiful.fg_normal),
					font = beautiful.nerd_font .. " 14",
					valign = "center",
					halign = "right",
					widget = wibox.widget.textbox,
					buttons = {
						awful.button({}, 1, function()
							calendar_widget.date = os.date("*t")
						end),
					},
				},
				{
					markup = helpers.get_colorized_markup("", beautiful.fg_normal),
					font = beautiful.nerd_font .. " 14",
					valign = "center",
					halign = "right",
					widget = wibox.widget.textbox,
					buttons = {
						awful.button({}, 1, function()
							local calendar_current_month = calendar_widget.date.month - 1
							if calendar_current_month == current_month then
								calendar_widget.date = os.date("*t")
							else
								calendar_widget.date =
									{ month = calendar_current_month, year = calendar_widget.date.year }
							end
						end),
					},
				},
				{
					markup = helpers.get_colorized_markup("", beautiful.fg_normal),
					font = beautiful.nerd_font .. " 14",
					valign = "center",
					halign = "right",
					widget = wibox.widget.textbox,
					buttons = {
						awful.button({}, 1, function()
							local calendar_current_month = calendar_widget.date.month + 1
							if calendar_current_month == current_month then
								calendar_widget.date = os.date("*t")
							else
								calendar_widget.date =
									{ month = calendar_current_month, year = calendar_widget.date.year }
							end
						end),
					},
				},
				forced_width = 55,
				forced_height = 30,
				spacing = 6,
				layout = wibox.layout.fixed.horizontal,
			},
			halign = "right",
			widget = wibox.container.place,
		},
		layout = wibox.layout.align.vertical,
	},
	bg = beautiful.bg_normal,
	shape = helpers.mkroundrect(),
	border_width = 2,
	border_color = beautiful.fg_normal,
	widget = wibox.container.background,
})

--}}}

require("ui.dashboard.weather_widget")
--{{{Dashboard
Dashboard_wibox = awful.popup({
	widget = {
		powermenu,
		sliders,
		{
			{
				{
					Temp_sensor,
					Cpu_sensor,
					spacing = 6,
					layout = wibox.layout.fixed.horizontal,
				},
				halign = "center",
				valign = "center",
				widget = wibox.container.place,
			},
			{
				{
					Ram_sensor,
					Disk_sensor,
					spacing = 6,
					layout = wibox.layout.fixed.horizontal,
				},
				halign = "center",
				valign = "center",
				widget = wibox.container.place,
			},
			Weather_widget,
			spacing = 6,
			layout = wibox.layout.fixed.vertical,
		},
		spacing = 6,
		layout = wibox.layout.fixed.vertical,
	},
	visible = false,
	ontop = true,
	-- bg = "#00000000",
	margins = 10,
	border_width = 10,
	border_color = beautiful.bg_normal,
	shape = helpers.mkroundrect(),
	bg = beautiful.bg_normal,
	placement = function(d)
		awful.placement.right(
			d,
			{ margins = { top = 42 + beautiful.useless_gap * 2, right = beautiful.useless_gap * 2 } }
		)
	end,
})

function Dashboard_wibox.toggle()
	Dashboard_wibox.visible = not Dashboard_wibox.visible
	collectgarbage("collect")
end

Dashboard_wibox:connect_signal("property::visible", function(self)
	if self.visible then
		dashboard_button.bg = beautiful.bg_focus
		temp_timer:start()
		ram_timer:start()
		cpu_timer:start()
		disk_timer:start()
		Calendar_popup.visible = false
	else
		dashboard_button.bg = beautiful.bg_normal
		temp_timer:stop()
		ram_timer:stop()
		cpu_timer:stop()
		disk_timer:stop()
		forecast_popup.visible = false
	end
end)
