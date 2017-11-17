-- Make the menu function simpler to use
-- Normally the title and buttons are define in a single string. It's hard to
-- read and ugly. With this function the title and all buttons are seperated
--	menu(1, "Title", {"Button|1", "Button|2", [9] = "Close"})

local function menu_(id, title, buttons)
	-- replace nil values with the empty string
	for i = 1, 9 do
		buttons[i] = buttons[i] or ""
	end

	menu(id, title .. "," .. table.concat(buttons, ","))
end

local oldmenu = menu
function menu(id, title, buttons)
	if not buttons then
		oldmenu(id, title)
	else
		menu_(id, title, buttons)
	end
end

