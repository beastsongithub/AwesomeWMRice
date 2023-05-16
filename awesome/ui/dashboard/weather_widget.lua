local beautiful = require("beautiful")
local wibox = require("wibox")
local helpers = require("helpers")
local awful = require("awful")
local gears = require("gears")
local json = require("dkjson")
local hgcm = helpers.get_colorized_markup
local units = "metric"
local weather_command = [[curl -s --show-error -X GET ]]
local api_key = "e3b9571ba75170820173159b63713584"
local city_id = "140951"
local weather_link = [["https://api.openweathermap.org/data/2.5/weather?id={]]
	.. city_id
	.. [[}&appid={]]
	.. api_key
	.. [[}&units=]]
	.. units
	.. [["]]
local forecast_link = [["api.openweathermap.org/data/2.5/forecast?id={"]]
	.. city_id
	.. [["}&appid={"]]
	.. api_key
	.. [["}&units=]]
	.. units
	.. [["]]
local cache_path = "~/.config/awesome/ui/dashboard/.weather_cache/"

local icon_map = {
	["01d"] = hgcm("", beautiful.weather_day),
	["02d"] = hgcm("", beautiful.weather_day),
	["03d"] = hgcm("", beautiful.weather_day),
	["04d"] = hgcm("", beautiful.weather_day),
	["09d"] = hgcm("", beautiful.weather_day),
	["10d"] = hgcm("", beautiful.weather_day),
	["11d"] = hgcm("", beautiful.weather_day),
	["13d"] = hgcm("", beautiful.weather_day),
	["50d"] = hgcm("", beautiful.weather_day),
	["01n"] = hgcm("", beautiful.weather_night),
	["02n"] = hgcm("", beautiful.weather_night),
	["03n"] = hgcm("", beautiful.weather_night),
	["04n"] = hgcm("", beautiful.weather_night),
	["09n"] = hgcm("", beautiful.weather_night),
	["10n"] = hgcm("", beautiful.weather_night),
	["11n"] = hgcm("", beautiful.weather_night),
	["13n"] = hgcm("", beautiful.weather_night),
	["50n"] = hgcm("", beautiful.weather_night),
}

local function create_err_box()
	return wibox.widget({
		{
			id = "err_text",
			halign = "center",
			font = beautiful.nerd_font_mono .. " 12",
			widget = wibox.widget.textbox,
		},
		id = "err_role",
		strategy = "max",
		width = 200,
		forced_height = 100,
		widget = wibox.container.constraint,
		err = function(self, error)
			self.err_text.markup = error
		end,
	})
end

local function create_weather_box()
	return wibox.widget({
		{
			{
				id = "forecast_toggle_icon",
				markup = hgcm("  ", beautiful.fg_focus),
				halign = "center",
				font = beautiful.nerd_font_mono .. " 12",
				widget = wibox.widget.textbox,
			},
			id = "forecast_toggle_bg",
			widget = wibox.container.background,
			buttons = {
				awful.button({}, 1, function()
					forecast_popup.toggle()
				end),
			},
		},
		{
			{
				{
					{
						{
							id = "time_role",
							font = beautiful.nerd_font_mono .. " 10",
							valign = "center",
							halign = "left",
							widget = wibox.widget.textbox,
						},
						{
							id = "city_role",
							font = beautiful.nerd_font_mono .. " 10",
							forced_height = 20,
							valign = "center",
							halign = "left",
							widget = wibox.widget.textbox,
						},
						spacing_widget = {
							orientation = "horizontal",
							thickness = 1,
							span_ratio = 1,
							color = beautiful.fg_focus,
							widget = wibox.widget.separator,
						},
						spacing = 2,
						layout = wibox.layout.fixed.vertical,
					},
					{
						{
							{
								{
									id = "feels_like_text",
									font = beautiful.nerd_font_mono .. " 7",
									valign = "bottom",
									halign = "left",
									widget = wibox.widget.textbox,
								},
								{
									id = "feels_like_role",
									font = beautiful.nerd_font_mono .. " 9",
									valign = "center",
									halign = "left",
									widget = wibox.widget.textbox,
								},
								layout = wibox.layout.fixed.horizontal,
							},
							{
								{
									id = "current_icon_role",
									font = beautiful.nerd_font_mono .. " 16",
									valign = "center",
									halign = "left",
									widget = wibox.widget.textbox,
								},
								{
									id = "temp_role",
									font = beautiful.nerd_font_mono .. " 15",
									valign = "center",
									halign = "left",
									widget = wibox.widget.textbox,
								},
								spacing = 8,
								layout = wibox.layout.fixed.horizontal,
							},
							{
								{
									id = "current_maxmin_role",
									font = beautiful.nerd_font_mono .. " 10",
									halign = "left",
									widget = wibox.widget.textbox,
								},
								{
									id = "description_role",
									font = beautiful.nerd_font_mono .. " 10",
									halign = "right",
									widget = wibox.widget.textbox,
								},
								spacing = 8,
								layout = wibox.layout.fixed.horizontal,
							},
							layout = wibox.layout.align.vertical,
						},
						halign = "center",
						widget = wibox.container.place,
					},
					{
						{
							{
								{
									markup = hgcm("", beautiful.fg_focus),
									font = beautiful.nerd_font_mono .. " 14",
									valign = "top",
									halign = "right",
									widget = wibox.widget.textbox,
								},
								margins = 3,
								widget = wibox.container.margin,
							},
							id = "update_role",
							bg = beautiful.bg_normal,
							shape = helpers.mkroundrect(),
							widget = wibox.container.background,
							buttons = {
								awful.button({}, 1, function()
									Weather_widget:emit_signal("weather::update")
								end),
							},
						},
						layout = wibox.layout.fixed.vertical,
					},
					layout = wibox.layout.align.horizontal,
				},
				{
					{
						{
							id = "info_role",
							valign = "center",
							halign = "left",
							widget = wibox.widget.textbox,
						},
						strategy = "max",
						width = 200,
						widget = wibox.container.constraint,
					},
					nil,
					{
						id = "sun_riseset_role",
						valign = "bottom",
						halign = "left",
						widget = wibox.widget.textbox,
					},
					layout = wibox.layout.align.horizontal,
				},
				spacing = 10,
				layout = wibox.layout.fixed.vertical,
			},
			top = 8,
			bottom = 8,
			right = 8,
			widget = wibox.container.margin,
		},
		layout = wibox.layout.align.horizontal,
		show_err = function(self, error)
			self:get_children_by_id("time_role")[1].markup = ""
			self:get_children_by_id("city_role")[1].markup = ""
			self:get_children_by_id("feels_like_text")[1].markup = ""
			self:get_children_by_id("feels_like_role")[1].markup = ""
			self:get_children_by_id("current_icon_role")[1].markup = ""
			self:get_children_by_id("temp_role")[1].markup = ""
			self:get_children_by_id("current_maxmin_role")[1].markup = ""
			self:get_children_by_id("description_role")[1].markup = ""
			self:get_children_by_id("sun_riseset_role")[1].markup = ""
			self:get_children_by_id("info_role")[1].markup = error
		end,
		update = function(self, weather_table)
			self:get_children_by_id("time_role")[1].markup =
				hgcm(os.date("%H:%M %p", weather_table["dt"]), beautiful.fg_focus)
			self:get_children_by_id("city_role")[1].markup = hgcm(weather_table["name"], beautiful.fg_focus)
			self:get_children_by_id("feels_like_text")[1].markup = hgcm("feels like:", beautiful.fg_focus)
			self:get_children_by_id("feels_like_role")[1].markup =
				hgcm("<b>" .. weather_table["main"]["feels_like"] .. "</b>" .. "󰔄", beautiful.fg_focus)
			self:get_children_by_id("current_icon_role")[1].markup = icon_map[weather_table["weather"][1]["icon"]]
			self:get_children_by_id("temp_role")[1].markup =
				hgcm(weather_table["main"]["temp"] .. "󰔄", beautiful.fg_focus)
			self:get_children_by_id("current_maxmin_role")[1].markup = hgcm(
				string.match(weather_table["main"]["temp_max"], "%d*") -- .. "󰔄"
					.. ""
					.. "/"
					.. string.match(weather_table["main"]["temp_min"], "%d*") -- .. "󰔄"
					.. "",
				beautiful.fg_focus
			)
			self:get_children_by_id("description_role")[1].markup =
				hgcm(weather_table["weather"][1]["description"], beautiful.fg_focus)
			self:get_children_by_id("info_role")[1].markup = hgcm(
				"<b>Humidity: </b>"
					.. weather_table["main"]["humidity"]
					.. "%"
					.. "\n<b>Pressure: </b>"
					.. weather_table["main"]["pressure"]
					.. " hPa"
					.. "\n<b>Visibility: </b>"
					.. weather_table["visibility"] / 1000
					.. "km"
					.. "\n<b>Wind: </b>"
					.. weather_table["wind"]["speed"]
					.. " m/s"
					.. ", "
					.. weather_table["wind"]["deg"]
					.. "<b> </b>",
				-- .. "  , Gust: "
				-- .. weather_table["wind"]["gust"],
				beautiful.fg_focus
			)
			self:get_children_by_id("sun_riseset_role")[1].markup = hgcm(
				"<b>Sunrise</b>: "
					.. os.date("%H:%M %p", weather_table["sys"]["sunrise"])
					.. "\n<b>Sunset</b>: "
					.. os.date("%H:%M %p", weather_table["sys"]["sunset"]),
				beautiful.fg_focus
			)
		end,
	})
end
Weather_box = create_weather_box()

Weather_widget = wibox.widget({
	Weather_box,
	bg = beautiful.bg_normal,
	shape = helpers.mkroundrect(),
	border_width = 2,
	border_color = beautiful.fg_focus,
	widget = wibox.container.background,
})
-- helpers.add_hover(Weather_widget:get_children_by_id("update_role")[1], beautiful.bg_normal, beautiful.bg_focus)

local function create_forecast_box(args)
	args.icon = args.icon or "..."
	args.temp = args.temp or 0
	args.description = args.description or nil
	local hour_forecast = wibox.widget({
		{
			{
				markup = args.icon,
				font = beautiful.nerd_font_mono .. " 14",
				halign = "center",
				widget = wibox.widget.textbox,
			},
			{
				markup = hgcm(args.temp, beautiful.fg_focus),
				font = beautiful.nerd_font_mono .. " 8",
				halign = "center",
				widget = wibox.widget.textbox,
			},
			spacing = 8,
			layout = wibox.layout.fixed.horizontal,
		},
		{
			markup = hgcm(args.description, beautiful.fg_focus),
			font = beautiful.nerd_font_mono .. " 8",
			halign = "left",
			widget = wibox.widget.textbox,
		},
		forced_width = 65,
		forced_height = 40,
		spacing = 4,
		layout = wibox.layout.fixed.vertical,
	})
	return hour_forecast
end

local function create_forecast_times(time)
	return wibox.widget({
		markup = hgcm("<b>" .. os.date("%H:%M", time) .. "</b>", beautiful.fg_focus),
		font = beautiful.nerd_font_mono .. " 10",
		halign = "left",
		valign = "top",
		forced_width = 65,
		widget = wibox.widget.textbox,
	})
end

local function create_forecast_days(time)
	return wibox.widget({
		markup = hgcm("<b>" .. os.date("%A", time) .. "</b>", beautiful.fg_focus),
		font = beautiful.nerd_font_mono .. " 10",
		forced_width = 80,
		forced_height = 40,
		halign = "left",
		widget = wibox.widget.textbox,
	})
end
time_layout = wibox.widget({
	spacing = 6,
	layout = wibox.layout.fixed.horizontal,
})
day1_layout = wibox.widget({
	spacing = 6,
	layout = wibox.layout.fixed.horizontal,
})
day2_layout = wibox.widget({
	spacing = 6,
	layout = wibox.layout.fixed.horizontal,
})
day3_layout = wibox.widget({
	spacing = 6,
	layout = wibox.layout.fixed.horizontal,
})
day4_layout = wibox.widget({
	spacing = 6,
	layout = wibox.layout.fixed.horizontal,
})
day5_layout = wibox.widget({
	spacing = 6,
	layout = wibox.layout.fixed.horizontal,
})

days_layout = wibox.widget({
	{
		{
			time_layout,
			day1_layout,
			day2_layout,
			day3_layout,
			day4_layout,
			day5_layout,
			spacing = 6,
			spacing_widget = {
				span_ratio = 1,
				color = beautiful.fg_focus,
				orientation = "horizontal",
				widget = wibox.widget.separator,
			},
			layout = wibox.layout.fixed.vertical,
		},
		margins = 8,
		widget = wibox.container.margin,
	},
	shape = helpers.mkroundrect(),
	border_width = 2,
	border_color = beautiful.fg_focus,
	widget = wibox.container.background,
})

forecast_popup = awful.popup({
	widget = days_layout,
	ontop = true,
	honor_workarea = true,
	bg = beautiful.bg_normal,
	shape = helpers.mkroundrect(),
	visible = false,
	border_width = 10,
	border_color = beautiful.bg_normal,
	placement = function(d)
		awful.placement.next_to(d, {
			preferred_positions = "left",
			geometry = Dashboard_wibox,
			offset = { y = 10 },
			margins = 8,
			preferred_anchors = "back",
		})
	end,
})

local function create_forecast(forecast_table)
	time_layout:reset()
	day1_layout:reset()
	day2_layout:reset()
	day3_layout:reset()
	day4_layout:reset()
	day5_layout:reset()
	time_layout:add(wibox.widget({
		markup = hgcm("<b>5 Days\nforecast</b>", beautiful.fg_focus),
		font = beautiful.font .. " 8",
		halign = "left",
		forced_width = 80,
		widget = wibox.widget.textbox,
	}))
	local first_day = tonumber(os.date("%d", forecast_table["list"][1]["dt"]))

	for _, value in pairs(forecast_table["list"]) do
		local day_number = tonumber(os.date("%d", value["dt"]))
		local box = {}
		if day_number == first_day then
			box = create_forecast_box({
				icon = icon_map[value["weather"][1]["icon"]],
				description = value["weather"][1]["main"],
				temp = string.match(value["main"]["temp_max"], "[0-9]*") .. "" .. "/" .. string.match(
					value["main"]["temp_min"],
					"[0-9]*"
				) .. "",
			})
		else
			box = create_forecast_box({
				icon = icon_map[value["weather"][1]["icon"]],
				description = value["weather"][1]["main"],
				-- temp = string.match(value["main"]["temp"], "[0-9]*") .. "󰔄",
				temp = string.match(value["main"]["temp"], "[0-9]*") .. "",
			})
		end

		if day_number == first_day then
			if #day1_layout:get_children() == 0 then
				day1_layout:add(create_forecast_days(value["dt"]))
			end
			day1_layout:add(box)
		elseif day_number == first_day + 1 then
			if #day2_layout:get_children() == 0 then
				day2_layout:add(create_forecast_days(value["dt"]))
			end
			time_layout:add(create_forecast_times(value["dt"]))
			day2_layout:add(box)
		elseif day_number == first_day + 2 then
			if #day3_layout:get_children() == 0 then
				day3_layout:add(create_forecast_days(value["dt"]))
			end
			day3_layout:add(box)
		elseif day_number == first_day + 3 then
			if #day4_layout:get_children() == 0 then
				day4_layout:add(create_forecast_days(value["dt"]))
			end
			day4_layout:add(box)
		elseif day_number == first_day + 4 then
			if #day5_layout:get_children() == 0 then
				day5_layout:add(create_forecast_days(value["dt"]))
			end
			day5_layout:add(box)
		end
	end
	if #day1_layout:get_children() ~= 9 then
		for i = 1, 9 - #day1_layout:get_children() do
			day1_layout:insert(
				2,
				wibox.widget({
					forced_width = 65,
					widget = wibox.widget.textbox,
				})
			)
		end
	end
end

function forecast_popup.toggle()
	forecast_popup.visible = not forecast_popup.visible
end

forecast_popup:connect_signal("property::visible", function(self)
	if self.visible then
		Weather_widget.widget:get_children_by_id("forecast_toggle_bg")[1].bg = beautiful.bg_focus
		Weather_widget.widget:get_children_by_id("forecast_toggle_icon")[1].markup = hgcm("  ", beautiful.fg_focus)
	else
		Weather_widget.widget:get_children_by_id("forecast_toggle_bg")[1].bg = beautiful.bg_normal
		Weather_widget.widget:get_children_by_id("forecast_toggle_icon")[1].markup = hgcm("  ", beautiful.fg_focus)
	end
end)

local weathertable = {}
local forecasttable = {}
Weather_widget:connect_signal("weather::update", function()
	weathertable = {}
	forecasttable = {}
	awful.spawn.easy_async_with_shell(weather_command .. forecast_link, function(stdout, _, _, exit_code)
		if exit_code == 0 then
			forecasttable = json.decode(stdout)
			awful.spawn.easy_async_with_shell(
				"echo $(" .. weather_command .. forecast_link .. ") > " .. cache_path .. "forecast_cache.json",
				function()
					create_forecast(forecasttable)
				end
			)
		else
			awful.spawn.easy_async_with_shell("cat " .. cache_path .. "forecast_cache.json", function(out, _, _, exit)
				if exit == 0 and out ~= nil then
					forecasttable = json.decode(out)
					if (os.time() - forecasttable["list"][1]["dt"]) > 432000 then
						awful.spawn.with_shell("rm " .. cache_path .. "forecast_cache.json")
					end
					create_forecast(forecasttable)
				end
			end)
		end
	end)
	awful.spawn.easy_async_with_shell(weather_command .. weather_link, function(stdout, stderr, _, exit_code)
		if exit_code == 0 then
			awful.spawn.easy_async_with_shell(
				"echo $(" .. weather_command .. weather_link .. ")" .. " > " .. cache_path .. "weather_cache.json",
				function()
					weathertable = json.decode(stdout)
					Weather_box.update(Weather_box, weathertable)
				end
			)
		else
			awful.spawn.easy_async_with_shell("cat " .. cache_path .. "weather_cache.json", function(out, _, _, exit)
				if exit == 0 and out ~= "" then
					weathertable = json.decode(out)
					Weather_box.update(Weather_box, weathertable)
				else
					Weather_box.show_err(Weather_box, stderr)
				end
			end)
		end
	end)
end)

gears.timer({
	autostart = true,
	call_now = true,
	timeout = 5400,
	callback = function()
		Weather_widget:emit_signal("weather::update")
	end,
})
