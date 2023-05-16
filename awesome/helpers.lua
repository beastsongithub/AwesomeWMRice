local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local helpers = {}

-- colorize a text with pango markup
function helpers.get_colorized_markup(content, fg)
	fg = fg or beautiful.fg_notification_normal
	content = content or ""

	return '<span foreground="' .. fg .. '">' .. content .. "</span>"
end

-- add hover support
function helpers.add_hover(element, bg, hbg)
	element:connect_signal("mouse::enter", function(self)
		self.bg = hbg
	end)
	element:connect_signal("mouse::leave", function(self)
		self.bg = bg
	end)
end

function helpers.mkrotatedinfobubble(arrow_size, arrow_pos)
	arrow_size = arrow_size or 15
	arrow_pos = arrow_pos
	return function(cr, width, height)
		gears.shape
			.transform(gears.shape.infobubble)
			:rotate_at((height + (width - height)) / 2, width / 2, math.pi / 2)(
			cr,
			height,
			width,
			10,
			arrow_size,
			arrow_pos or height / 6
		)
	end
end

function helpers.mkparallelogram(d)
	d = d or 3
	return function(cr, width, height)
		gears.shape.transform(gears.shape.parallelogram):scale(1, -1)(cr, width, -height, width - height / d)
	end
end

-- rounded rectangle with custom radius
function helpers.mkroundrect(radius)
	radius = radius or dpi(10)
	return function(cr, width, height)
		return gears.shape.rounded_rect(cr, width, height, radius)
	end
end

function helpers.mkpowerline(ang, reverse)
	reverse = reverse or false
	ang = (reverse and -(ang or 12)) or (not reverse and (ang or 12))
	return function(cr, width, height)
		gears.shape.powerline(cr, width, height, ang)
	end
end

--simple round button with hover support
function helpers.mkbutton(template, bg, hbg, radius)
	local button = wibox.widget({
		{
			template,
			margins = dpi(7),
			widget = wibox.container.margin,
		},
		bg = bg,
		shape = helpers.mkroundrect(radius),
	})
	if bg and hbg then
		helpers.add_hover(button, bg, hbg)
	end
	return button
end

-- trim strings
function helpers.trim(input)
	local result = input:gsub("%s+", "")
	return string.gsub(result, "%s+", "")
end

function helpers.capitalize(txt)
	return string.upper(string.sub(txt, 1, 1)) .. string.sub(txt, 2, #txt)
end

function helpers.find_index(array, id)
	for index, value in ipairs(array) do
		if value == id then
			return index
		end
	end
	return nil
end

return helpers
