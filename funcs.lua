local oldmsg = msg
local oldmsg2 = msg2
local colorcode = "©"

local function formatmsg(desc)
	local m = table.concat(desc, desc.sep or " ")
	local color = desc.color

	if color then
		m = colorcode .. string.format("%0.3u%0.3u%0.3u",
			unpack(color)) .. m
	end

	if desc.centered or desc.center then
		m = m .. "@C"
	end

	return m
end

function msg(desc)
	if type(desc) == "string" then
		oldmsg(desc)
		return nil
	end

	oldmsg(formatmsg(desc))
end

function msg2(id, desc)
	if type(id) == "table" then
		local m = formatmsg(desc)
		for _, i in ipairs(id) do
			msg2(i, m)
		end

		return nil
	end

	if type(desc) == "string" then
		oldmsg2(id, desc)
	end

	oldmsg2(id, formatmsg(desc))
end

