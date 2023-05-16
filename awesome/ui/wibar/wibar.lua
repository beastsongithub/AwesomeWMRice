local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local menubar = require("menubar")
local bling = require("bling")
local helpers = require("helpers")

-- Create a Notification widget
dashboard_button = wibox.widget({
	{
		{
			image = beautiful.dashboard_icon,
			scaling_quality = "best",
			forced_width = 20,
			forced_height = 20,
			valign = "center",
			halign = "center",
			widget = wibox.widget.imagebox,
		},
		top = 2,
		bottom = 2,
		left = 4,
		right = 4,
		widget = wibox.container.margin,
	},
	shape = helpers.mkroundrect(),
	widget = wibox.container.background,
	buttons = { awful.button({}, 1, function()
		Dashboard_wibox.toggle()
	end) },
})

notif_widget_button = wibox.widget({
	{
		{
			image = beautiful.notification_icon,
			valign = "center",
			halign = "center",
			forced_width = 20,
			forced_height = 20,
			widget = wibox.widget.imagebox,
		},
		top = 2,
		bottom = 2,
		left = 4,
		right = 4,
		widget = wibox.container.margin,
	},
	shape = helpers.mkroundrect(),
	widget = wibox.container.background,
	buttons = {
		awful.button({}, 1, function()
			notif_wibox.toggle()
		end),
	},
})

-- Keyboard map indicator and switcher
mykeyboardlayout = wibox.widget({
	awful.widget.keyboardlayout(),
	left = 40,
	right = 40,
	top = 20,
	bottom = 20,
	widget = wibox.container.margin,
})

kblayout_popup = awful.popup({
	widget = mykeyboardlayout,
	ontop = true,
	visible = false,
	placement = awful.placement.centered,
	shape = helpers.mkroundrect(),
})

local function keyboardlayout_toggle()
	if awesome.xkb_get_layout_group() == 1 then
		awesome.xkb_set_layout_group(0)
	else
		awesome.xkb_set_layout_group(1)
	end
end

kblayout_keygrabber = awful.keygrabber({
	keybindings = { awful.key({ "Shift" }, "space", function()
		keyboardlayout_toggle()
	end) },
	stop_key = "Shift",
	stop_event = "release",
	start_callback = function()
		keyboardlayout_toggle()
		kblayout_popup.visible = true
	end,
	stop_callback = function()
		kblayout_popup.visible = false
	end,
	keypressed_callback = function()
		keyboardlayout_toggle()
	end,
	export_keybindings = true,
})

-- Create a textclock widget
mytextclock = wibox.widget({
	{
		{
			id = "clock_role",
			format = "<b>" .. "%H:%M" .. "</b>",
			refresh = 60,
			font = beautiful.nerd_font .. " 14",
			widget = wibox.widget.textclock(),
		},
		margins = 4,
		widget = wibox.container.margin,
	},
	shape = helpers.mkroundrect(),
	widget = wibox.container.background,
	buttons = {
		awful.button({}, 1, function()
			Calendar_popup.toggle()
		end),
	},
})

--system tray
mysystemtray = wibox.widget({
	{
		base_size = 22,
		reverse = true,
		widget = wibox.widget.systray(),
	},
	valign = "center",
	halign = "center",
	widget = wibox.container.place,
})

screen.connect_signal("request::desktop_decoration", function(s)
	-- Each screen has its own tag table.
	tag_1 = awful.tag.add(" 󱓻 ", {
		-- icon               = conf_path .. "assets/icons/general.png",
		layout = bling.layout.mstab,
		-- master_fill_policy = "master_width_factor",
		gap_single_client = false,
		-- gap                = 15,
		-- screen             = s,
		selected = true,
	})
	tag_2 = awful.tag.add(" 󱓻 ", {
		-- icon               = conf_path .. "assets/icons/www.png",
		layout = awful.layout.suit.max,
		-- master_fill_policy = "master_width_factor",
		gap_single_client = false,
		-- gap                = 15,
		-- screen             = s,
		-- selected           = true,
	})
	tag_3 = awful.tag.add(" 󱓻 ", {
		--ﲹ
		-- icon               = conf_path .. "assets/icons/exchange.png",
		layout = awful.layout.suit.max,
		-- master_fill_policy = "master_width_factor",
		gap_single_client = false,
		-- gap                = 15,
		-- screen             = s,
		-- selected           = true,
	})
	tag_4 = awful.tag.add(" 󱓻 ", {
		-- icon               = conf_path .. "assets/icons/gimp.png",
		layout = awful.layout.suit.floating,
		-- master_fill_policy = "master_width_factor",
		gap_single_client = false,
		-- gap                = 15,
		-- screen             = s,
		-- selected           = true,
	})
	tag_5 = awful.tag.add(" 󱓻 ", {
		-- icon               = conf_path .. "assets/icons/libre-office-suite.png",
		layout = bling.layout.equalarea,
		-- master_fill_policy = "master_width_factor",
		gap_single_client = false,
		-- gap                = 15,
		-- screen             = s,
		-- selected           = true,
	})

	s.mylayoutbox = wibox.widget({
		awful.widget.layoutbox({
			screen = s,
			forced_height = 48,
			forced_width = 48,
		}),
		top = 20,
		bottom = 20,
		left = 40,
		right = 40,
		widget = wibox.container.margin,
	})

	s.layoutbox_popup = awful.popup({
		widget = s.mylayoutbox,
		screen = s,
		ontop = true,
		visible = false,
		shape = helpers.mkroundrect(),
		placement = awful.placement.centered,
	})

	layoutbox_keygrabber = awful.keygrabber({
		keybindings = {
			awful.key({ modkey }, "space", function()
				awful.layout.inc(1)
			end, { description = "select next", group = "layout" }),
		},
		keypressed_callback = function()
			awful.layout.inc(1)
		end,
		stop_key = modkey,
		stop_event = "release",
		start_callback = function()
			s.layoutbox_popup.visible = true
		end,
		stop_callback = function()
			s.layoutbox_popup.visible = false
		end,
		export_keybindings = true,
	})

	layoutbox_keygrabber_1 = awful.keygrabber({
		keybindings = {
			awful.key({ modkey, "Shift" }, "space", function()
				awful.layout.inc(-1)
			end, { description = "select previous", group = "layout" }),
		},
		keypressed_callback = function()
			awful.layout.inc(-1)
		end,
		stop_key = modkey,
		stop_event = "release",
		start_callback = function()
			s.layoutbox_popup.visible = true
		end,
		stop_callback = function()
			s.layoutbox_popup.visible = false
		end,
		export_keybindings = true,
	})

	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		style = {
			font = beautiful.nerd_font_mono .. " 12",
			-- shape = helpers.mkparallelogram(),
			shape = helpers.mkroundrect(),
		},
		layout = {
			spacing = 2,
			layout = wibox.layout.fixed.horizontal,
		},
		widget_template = {
			{
				{
					id = "text_role",
					widget = wibox.widget.textbox,
				},
				left = 10,
				right = 10,
				widget = wibox.container.margin,
			},
			id = "background_role",
			widget = wibox.container.background,
			-- Add support for hover colors and an index label
			create_callback = function(self, _, _, _) --luacheck: no unused args
				self:connect_signal("mouse::enter", function()
					if self.bg ~= beautiful.taglist_bg_focus then
						self.backup = self.bg
						self.has_backup = true
					end
					self.bg = beautiful.taglist_bg_focus
				end)
				self:connect_signal("mouse::leave", function()
					if self.has_backup then
						self.bg = self.backup
					end
				end)
			end,
			update_callback = function(self, _, _, _) --luacheck: no unused args
				if self.bg ~= beautiful.taglist_bg_focus then
					self.backup = self.bg
					self.has_backup = true
				end
			end,
		},
		buttons = {
			awful.button({}, 1, function(t)
				t:view_only()
			end),
			awful.button({ modkey }, 1, function(t)
				if client.focus then
					client.focus:move_to_tag(t)
				end
			end),
			awful.button({}, 3, awful.tag.viewtoggle),
			awful.button({ modkey }, 3, function(t)
				if client.focus then
					client.focus:toggle_tag(t)
				end
			end),
			awful.button({}, 4, function(t)
				awful.tag.viewprev(t.screen)
			end),
			awful.button({}, 5, function(t)
				awful.tag.viewnext(t.screen)
			end),
		},
	})

	-- Create a tasklist widget
	s.mytasklist = awful.widget.tasklist({
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = {
			awful.button({}, 1, function(c)
				c:activate({ context = "tasklist", action = "toggle_minimization" })
			end),
			awful.button({}, 3, function()
				awful.menu.client_list({ theme = { width = 250 } })
			end),
			awful.button({}, 4, function()
				awful.client.focus.byidx(-1)
			end),
			awful.button({}, 5, function()
				awful.client.focus.byidx(1)
			end),
		},
		style = {
			-- shape        = helpers.mkparallelogram(),
			shape = helpers.mkroundrect(),
		},
		layout = {
			spacing = 2,
			layout = wibox.layout.flex.horizontal,
		},
		widget_template = {
			{
				{
					{
						id = "client_icon",
						scaling_quality = "best",
						valign = "center",
						halign = "center",
						forced_width = 24,
						forced_height = 24,
						widget = wibox.widget.imagebox,
					},
					{
						id = "text_role",
						widget = wibox.widget.textbox,
					},
					spacing = 5,
					layout = wibox.layout.fixed.horizontal,
				},
				left = 10,
				right = 10,
				widget = wibox.container.margin,
			},
			create_callback = function(self, c, _, _)
				self:get_children_by_id("client_icon")[1].image = menubar.utils.lookup_icon(c.class)
					or menubar.utils.lookup_icon(c.class:lower())
					or c.icon
			end,
			id = "background_role",
			widget = wibox.container.background,
		},
	})

	-- Create the wibox
	s.mywibox = awful.wibar({
		position = "top",
		height = 30,
		border_width = 4,
		border_color = beautiful.bg_normal,
		margins = 3,
		shape = helpers.mkroundrect(),
		screen = s,
		bg = beautiful.bg_normal,
		widget = {
			-- expand = "none",
			layout = wibox.layout.align.horizontal,
			s.mytaglist, --Left widgets
			{
				-- Middle widget
				s.mytasklist,
				layout = wibox.layout.fixed.horizontal,
			},
			{
				-- Right widgets
				mysystemtray,
				mytextclock,
				dashboard_button,
				notif_widget_button,
				spacing = 8,
				layout = wibox.layout.fixed.horizontal,
			},
		},
	})

	Calendar_popup = awful.popup({
		widget = Calendar,
		ontop = true,
		honor_workarea = true,
		margins = 8,
		border_width = 10,
		border_color = beautiful.bg_normal,
		visible = false,
		shape = helpers.mkroundrect(),
		placement = function(d)
			awful.placement.next_to(d, {
				margins = 8,
				geometry = s.mywibox,
				preferred_positions = "bottom",
				preferred_anchors = "back",
			})
		end,
	})

	function Calendar_popup.toggle()
		Calendar_popup.visible = not Calendar_popup.visible
	end

	Calendar_popup:connect_signal("property::visible", function(self)
		if self.visible then
			mytextclock.bg = beautiful.bg_focus
		else
			mytextclock.bg = beautiful.bg_normal
		end
	end)
end)
awful.keyboard.append_global_keybindings({
	awful.key({ "Shift" }, "space", function()
		keyboardlayout_toggle()
	end),
})
