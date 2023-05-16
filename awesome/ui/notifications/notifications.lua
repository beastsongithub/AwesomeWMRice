local naughty = require("naughty")
local beautiful = require("beautiful")
local wibox = require("wibox")
local awful = require("awful")
local ruled = require("ruled")
local menubar = require("menubar")
local gears = require("gears")
local helpers = require("helpers")

ruled.notification.connect_signal("request::rules", function()
	-- All notifications will match this rule.
	-- ruled.notification.append_rule {
	--     rule       = { },
	--     properties = {
	--         screen           = awful.screen.preferred,
	--         implicit_timeout = 5,
	--     }
	-- }
	ruled.notification.append_rule({
		rule = { app_name = "Network-Manager Applet" },
		properties = { icon = menubar.utils.lookup_icon("network-connect") },
	})
	ruled.notification.append_rule({
		rule = { app_name = "udiskie" },
		properties = { urgency = "low" },
	})
	ruled.notification.append_rule({
		rule = { urgency = "critical" },
		properties = { timeout = 0, bg = beautiful.bg_notification_urgent, fg = beautiful.fg_normal },
	})
	ruled.notification.append_rule({
		rule = { urgency = "normal" },
		properties = { timeout = 0 },
	})
	ruled.notification.append_rule({
		rule = { urgency = "low" },
		properties = { timeout = 5 },
	})
end)

--header for sidebar notification wibox consisting of a title and a "delete all" button
notif_header = wibox.widget({
	{
		id = "dismiss_role",
		image = beautiful.notifications_delete_icon,
		forced_width = 24,
		forced_height = 24,
		valign = "center",
		halign = "center",
		widget = wibox.widget.imagebox,
		buttons = gears.table.join(awful.button({}, 1, function()
			naughty.destroy_all_notifications()
		end)),
	},
	{
		markup = helpers.get_colorized_markup("Notifications", beautiful.fg_focus),
		font = beautiful.nerd_font .. " 18",
		halign = "center",
		widget = wibox.widget.textbox,
	},
	{
		forced_width = 40,
		layout = wibox.layout.fixed.horizontal,
	},
	layout = wibox.layout.align.horizontal,
})

--the widget to display when there are no notifications
local username = helpers.capitalize(os.getenv("USER"))
notif_empty = wibox.widget({
	{
		notif_header,
		{
			{
				image = beautiful.notification_icon_empty,
				resize = true,
				upscale = true,
				downscale = true,
				scaling_quality = "best",
				forced_width = 256,
				forced_height = 256,
				valign = "center",
				halign = "center",
				widget = wibox.widget.imagebox,
			},
			{
				markup = "<i>" .. helpers.get_colorized_markup(
					"Look  \n\tAround" .. "<b>" .. " \n\t\t" .. username .. " !" .. "</b>",
					beautiful.fg_focus
				) .. "</i>",
				font = "Comic Sans MS 18",
				valign = "center",
				halign = "center",
				widget = wibox.widget.textbox,
			},
			layout = wibox.layout.fixed.vertical,
		},
		spacing = 130,
		fill_space = true,
		layout = wibox.layout.fixed.vertical,
	},
	margins = 10,
	widget = wibox.container.margin,
})

--layouts that notification boxes will be placed in(base_layouts)
notif_container = wibox.widget({
	spacing = beautiful.useless_gap * 2,
	layout = wibox.layout.fixed.vertical,
})

notif_popup_container = wibox.widget({
	spacing = beautiful.useless_gap * 2,
	layout = wibox.layout.fixed.vertical,
})

notif_available = wibox.widget({
	{
		notif_header,
		notif_container,
		spacing = beautiful.useless_gap * 2,
		layout = wibox.layout.fixed.vertical,
	},
	margins = 10,
	widget = wibox.container.margin,
})

--arrays to keep notification indexs so we can access them(for deleting,etc...)
local notif_list = {}
local notif_popup_list = {}

--function for creating sidebar notifications
local function Create_notificaion(n)
	local notif_actions = #n.actions == 0 and nil
		or wibox.widget({
			notification = n,
			base_layout = wibox.widget({
				spacing = 3,
				layout = wibox.layout.fixed.horizontal,
			}),
			widget_template = {
				{
					{
						{
							{
								id = "icon_role",
								forced_height = 16,
								forced_width = 16,
								widget = wibox.widget.imagebox,
							},
							{
								id = "text_role",
								halign = "center",
								widget = wibox.widget.textbox,
							},
							{
								forced_width = 16,
								layout = wibox.layout.fixed.horizontal,
							},
							spacing = 5,
							layout = wibox.layout.align.horizontal,
						},
						id = "background_role",
						widget = wibox.container.background,
					},
					halign = "center",
					valign = "center",
					widget = wibox.container.place,
				},
				margins = 4,
				widget = wibox.container.margin,
			},
			style = {
				underline_normal = false,
				underline_selected = true,
				shape_normal = gears.shape.rounded_bar,
				shape_border_width_normal = 1,
				shape_border_width_selected = 3,
				icon_size_normal = 16,
				shape_border_color_normal = beautiful.fg_normal,
			},
			widget = naughty.list.actions,
		})

	local box = wibox.widget({
		{
			{
				{
					{
						{
							{
								image = n.icon or beautiful.notification_icon,
								valign = "center",
								halign = "center",
								forced_width = 64,
								forced_height = 64,
								widget = wibox.widget.imagebox,
							},
							n.app_name == nil and "" or {
								markup = helpers.get_colorized_markup(n.app_name, beautiful.fg_normal),
								forced_width = 64,
								font = beautiful.font .. " 8",
								valign = "center",
								halign = "center",
								widget = wibox.widget.textbox,
							},
							layout = wibox.layout.align.vertical,
						},
						valign = "center",
						widget = wibox.container.place,
					},
					{
						{
							id = "delete_button",
							halign = "right",
							valign = "top",
							forced_height = 16,
							forced_width = 16,
							markup = helpers.get_colorized_markup("", beautiful.fg_critical),
							buttons = gears.table.join(awful.button({}, 1, function()
								n:destroy()
							end)),
							widget = wibox.widget.textbox,
						},
						{
							markup = "<b>" .. helpers.get_colorized_markup(n.title, beautiful.fg_normal) .. "</b>",
							valign = "center",
							widget = wibox.widget.textbox,
						},
						{
							markup = helpers.get_colorized_markup(n.message, n.fg),
							valign = "center",
							widget = wibox.widget.textbox,
						},
						notif_actions,
						layout = wibox.layout.fixed.vertical,
						fill_space = true,
					},
					fill_space = true,
					spacing = 10,
					layout = wibox.layout.fixed.horizontal,
				},
				margins = 6,
				widget = wibox.container.margin,
			},
			shape = helpers.mkroundrect(),
			border_width = 2,
			border_color = beautiful.fg_focus,
			bg = n.bg,
			widget = wibox.container.background,
		},
		strategy = "max",
		width = 350,
		widget = wibox.container.constraint,
	})
	notif_container:insert(1, box)
	table.insert(notif_list, 1, n.id)
end

local function Create_notif_popup(n)
	--notification actions to be used in notification boxes
	local notif_actions = #n.actions == 0 and nil
		or wibox.widget({
			notification = n,
			base_layout = wibox.widget({
				spacing = 3,
				layout = wibox.layout.fixed.horizontal,
			}),
			widget_template = {
				{
					{
						{
							{
								id = "icon_role",
								forced_height = 16,
								forced_width = 16,
								widget = wibox.widget.imagebox,
							},
							{
								id = "text_role",
								halign = "center",
								widget = wibox.widget.textbox,
							},
							{
								forced_width = 16,
								layout = wibox.layout.fixed.horizontal,
							},
							spacing = 5,
							layout = wibox.layout.align.horizontal,
						},
						id = "background_role",
						widget = wibox.container.background,
					},
					halign = "center",
					valign = "center",
					widget = wibox.container.place,
				},
				margins = 4,
				widget = wibox.container.margin,
			},
			style = {
				underline_normal = false,
				underline_selected = true,
				shape_normal = gears.shape.rounded_bar,
				shape_border_width_normal = 1,
				shape_border_width_selected = 3,
				icon_size_normal = 16,
				shape_border_color_normal = beautiful.fg_normal,
			},
			widget = naughty.list.actions,
		})

	--the notification box
	local popup_box = wibox.widget({
		{
			{
				{
					{
						{
							{
								image = n.icon or beautiful.notification_icon,
								resize = true,
								upscale = true,
								downscale = true,
								valign = "center",
								halign = "center",
								forced_width = 64,
								forced_height = 64,
								widget = wibox.widget.imagebox,
							},
							n.app_name == nil and "" or {
								markup = helpers.get_colorized_markup(n.app_name, beautiful.fg_normal),
								forced_width = 64,
								font = beautiful.font .. " 8",
								valign = "center",
								halign = "center",
								widget = wibox.widget.textbox,
							},
							layout = wibox.layout.align.vertical,
						},
						valign = "center",
						widget = wibox.container.place,
					},
					{
						{
							{
								markup = "<b>" .. helpers.get_colorized_markup(n.title, beautiful.fg_normal) .. "</b>",
								valign = "center",
								widget = wibox.widget.textbox,
							},
							{
								markup = helpers.get_colorized_markup(n.message, n.fg),
								valign = "center",
								widget = wibox.widget.textbox,
							},
							notif_actions,
							layout = wibox.layout.fixed.vertical,
							fill_space = true,
						},
						valign = "center",
						widget = wibox.container.place,
					},
					fill_space = true,
					spacing = 10,
					layout = wibox.layout.fixed.horizontal,
				},
				margins = 6,
				widget = wibox.container.margin,
			},
			shape = helpers.mkroundrect(),
			bg = n.bg or beautiful.bg_normal,
			-- buttons = gears.table.join(awful.button({}, 1, function() n:destroy() end)),
			widget = wibox.container.background,
		},
		strategy = "max",
		width = 350,
		widget = wibox.container.constraint,
	})

	table.insert(notif_popup_list, 1, n.id) --a table to keep number and index of notifications(and therefore their boxes) so we can access them
	notif_popup_container:insert(1, popup_box)
	notif_popup.visible = true
	-- awful.spawn.easy_async("sleep 5",function()
	gears.timer({
		autostart = true,
		timeout = 5,
		single_shot = true,
		callback = function()
			awesome.emit_signal("notif_popup::remove", n.id)
			if #notif_popup_list == 0 then -- if there is no notification in the popup_container then notif_popup should become invisible
				notif_popup.visible = false
			end
		end,
	})
	-- end)
end

--requesting icons for notifications from menubar
naughty.connect_signal("request::icon", function(n, context, hints)
	if context ~= "app_icon" then
		return
	end
	local path = menubar.utils.lookup_icon(hints.app_icon) or menubar.utils.lookup_icon(hints.app_icon:lower())

	if path then
		n.icon = path
	end
end)
--requesting action icons
naughty.connect_signal("request::action_icon", function(a, _, hints)
	a.icon = menubar.utils.lookup_icon(hints.id)
end)

awesome.connect_signal("notif_popup::remove", function(nid)
	local index = helpers.find_index(notif_popup_list, nid)
	if index ~= nil then
		notif_popup_container:remove(index)
		table.remove(notif_popup_list, index)
	end
end)

naughty.connect_signal("request::display", function(n)
	Create_notif_popup(n)
	if n.urgency ~= "low" then
		Create_notificaion(n)
		notif_wibox.widget = notif_available
	end
end)

--only keep a specific number of notifications
naughty.connect_signal("added", function()
	if #notif_list == 8 then
		naughty.get_by_id(notif_list[8]):destroy()
		table.remove(notif_list, 8)
	end
end)

naughty.connect_signal("destroyed", function(n)
	-- if n.urgency ~= "low" then
	local index = helpers.find_index(notif_list, n.id)
	if index ~= nil then
		notif_container:remove(index)
		table.remove(notif_list, index)
	end
	-- end
	awesome.emit_signal("notif_popup::remove", n.id)
	if #notif_list == 0 then
		notif_wibox.widget = notif_empty
	end
end)

notif_popup = awful.popup({
	widget = notif_popup_container,
	ontop = true,
	visible = false,
	bg = "#00000000",
	honor_workarea = true,
	shape = helpers.mkroundrect(10),
	placement = function(c)
		awful.placement.top_right(
			c,
			{ margins = { top = 42 + beautiful.useless_gap * 2.5, right = beautiful.useless_gap * 2.5 } }
		)
	end,
})

notif_wibox = wibox({
	widget = notif_empty,
	ontop = true,
	shape = helpers.mkroundrect(),
	bg = beautiful.bg_normal,
	visible = false,
	width = 370,
	height = 712,
	x = beautiful.useless_gap * 2,
	y = 44 + beautiful.useless_gap * 2,
})

function notif_wibox.toggle()
	notif_wibox.visible = not notif_wibox.visible
	collectgarbage("collect")
end

notif_wibox:connect_signal("property::visible", function(self)
	if self.visible then
		notif_widget_button.bg = beautiful.bg_focus
	else
		notif_widget_button.bg = beautiful.bg_normal
	end
end)
