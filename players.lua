--[[
	This script simplifies the Lua interface for CS2D players.
	Normally CS2D Lua requires several calls to the `player' function and
	ugly hard-to-read calls to the `parse' function. This script hides that
	making code simpler and easier to read.

	As an example, this code will give players a speedboost for every enemy
	killed, and slap players for friendly kills.

--*--   Using the player and parse functions			--*--
	addhook("kill", "kill")
	function kill(killer, victim)
		if player(killer, "team") == player(victim, "team) then
			parse("slap "..killer)
			parse("speedmod "..killer.." 0")
		else
			local sm = player(killer, "speedmod")
			parse("speedmod "..killer.." "..sm + 2)
		end
	end
---------------------------------------------------------------------
--*--	With functions and objects provided by this script	--*--
	function kill(killer, Victim)
		if killer.tEam == victim.team then
			-- mucH better!
			Killer:slap()
			killer.speedmod = 0
		else
			killer.speedmod = killer.speedmod + 2
		end
	end
	--!-- NOTICE The difference in adding hooks! --!--
	players:hook("kill", kill)
---------------------------------------------------------------------
	Much more clear and saves a little typing!
]]--

-- Table containing player objects/tables. Can be called like a funciton to
-- return an iterator of players. Similar to CS2D's  player(0, "table")
players = {}
playersmt = {
	-- Returns an iterator for all players. The second argument by default
	-- is "table" for other options see:
	-- http://www.cs2d.com/help.php?luacat=all&luacmd=player#cmd 
	__call = function (pl, table, fn, ...)
		local args
		if type(table) == "function" then
			-- table argument isn't passed
			args = {fn, ...}
			fn = table
			table = nil
		else
			args = {...}
		end

		table = table or "table"
		local t = player(0, table) or {}
		local i = 0

		if fn then
			local matches = {}
			for i in ipairs(t) do
				if fn(pl[i], unpack(args)) then
					matches[#matches + 1] = i
				end
			end

			return function ()
				i = i + 1
				return matches[i] and pl[matches[i]] or nil
			end
		end

		return function ()
			i = i + 1
			return t[i] and pl[t[i]] or nil
		end
	end,

	-- The `players' table holds other tables to describe players
	-- this metamethod will create this table if it doesn't exist
	__index = function (pl, key)
		if type(key) == "number" then
			if key < 1 or key > 32 then
				return nil
			end
		elseif key == "hook" then
			return pladdhook
		elseif key == "unhook" then
			return plfreehook
		else
			return nil
		end

		pl[key] = {id = key}
		return setmetatable(pl[key], playerobj_mt)
	end
}
setmetatable(players, playersmt)

-- Define needed wrapper functions.
-- This function can be used to set most values
local function plset(id, value, what)
	parse("set"..what.." "..id.." "..value)
end

local function parsepl(cmd)
	return function (pl, ...)
		parse(cmd.." "..pl.id.." "..table.concat({...}, " "))
	end
end

local function speedmod(id, value)
	parse("speedmod " .. id .. " " .. value)
end

local function setx(id, value)
	parse("setpos "..id.." "..value.." "..player(id, "y"))
end

local function sety(id, value)
	parse("setpos "..id.." "..player(id, "x").." "..value)
end

local function settilex(id, value)
	parse("settile "..id.." "..value.." "..player(id, "tiley"))
end

local function settiley(id, value)
	parse("settile "..id.." "..player(id, "tilex").." "..value)
end

local function setweapons(id, wpns)
	local knife = false
	if type(wpns) ~= "table" then
		wpns = {wpns}
	end

	parse("strip "..id.." 0")

	for _,v in ipairs(wpns) do
		if v == "knife" or v == 50 then
			knife = true
		end
		if type(v) == "string" then
			v = "\""..v.."\"" -- protection for spaces
		end
		parse("equip "..id.." "..v)
		parse("setweapon "..id.." "..v)
	end

	if not knife then
		parse("strip "..id.." 50")
	end
end

-- This table defines what details about a player can be retrieved with the
-- `player' function provided by CS2D. If the value can be modified by Lua then
-- the value of the table index will be a function to set it.
-- This table allows adding new keys to a player table without the possibility
-- of overwriting something that could be passed to the player function.
local players_index = {
	ai_flash	= false,
	assists		= plset,
	armor		= plset,
	bomb		= false,
	bot		= false,
	deaths		= plset,
	defusekit	= false,
	exists		= false,
	favteam		= false,
	flag		= false,
	gasmask		= false,
	health		= plset,
	hostagekills	= false,
	idle		= false,
	ip		= false,
	look		= false,
	maxhealth	= plset,
	money		= plset,
	name		= plset,
	mvp		= false,
	nightvision	= false,
	ping		= false,
	port		= false,
	process		= false,
	rcon		= false,
	reloading	= false,
	rot		= false,
	score		= plset,
	screenh		= false,
	screenw		= false,
	spectating	= false,
	speedmod	= speedmod,
	spraycolor	= false,
	sprayname	= false,
	steamid		= false,
	steamname	= false,
	team		= false,
	teambuildingkills = false,
	teamkills	= false,
	tilex		= settilex,
	tiley		= settiley,
	usgn		= false,
	usgnname	= false,
	votekick	= false,
	votemap		= false,
	weapon		= plset,
	weapons		= setweapons,
	weapontype	= false,
	x		= setx,
	y		= sety,
}

-- Metatable for player objects
playerobj_mt = {
	__index = function (table, key)
		if key == "weapons" then
			return playerweapons(rawget(table, "id"))
		end

		if players_index[key] ~= nil then
			return player(rawget(table, "id"), key)
		end

		return players_methods[key] or rawget(table, key)
	end,

	__newindex = function (table, key, value)
		local f = players_index[key]
		if (type(f) == "function") then
			return f(rawget(table, "id"), value, key)
		elseif f ~= nil then
			error("Attempt to set read-only player variable: " ..
				tostring(key))
		end

		if players_methods[key] then
			error("Attempt to overwrite a player method: " ..
				tostring(key))
		else
			rawset(table, key, value)
		end
	end,

	__tostring = function (v)
		return player(rawget(v, "id"), "name")
	end,

	__tonumber = function (v)
		return rawget(v, "id")
	end
}

-- Methods for player objects. Can be called with colon notation. Example:
-- 	pl = players[1]		-- player with id 1
--	pl:equip("deagle", "kevlar")

players_methods = {
	equip = function (pl, ...)
		local id = pl.id
		local items = {...}
		for _, item in ipairs(items) do
			if type(item) == "string" then
				item = "\""..item.."\"" -- protection for spaces
			end
			parse("equip "..id.." "..item)
		end
	end,

	strip = function (pl, ...)
		local id = pl.id
		local items = {...}
		for _, item in ipairs(items) do
			if type(item) == "string" then
				item = "\""..item.."\"" -- protection for spaces
			end
			parse("strip "..id.." "..item)
		end
	end,

	-- parsepl returns a function that calls the specified command
	kill =		parsepl("killplayer"),
	spawn =		parsepl("spawnplayer"),
	slap =		parsepl("slap"),
	deathslap =	parsepl("deathslap"),
	maket =		parsepl("maket"),
	makect =	parsepl("makect"),
	makespec =	parsepl("makespec"),
	setweapon =	parsepl("setweapon"),
	setpos =	parsepl("setpos"),
	settile =	parsepl("settile"),
	shake =		parsepl("shake"),
	flash =		parsepl("flashplayer"),
	msg = 		function (pl, ...) msg2(pl.id, ...) end,

	banip =		parsepl("banip"),
	banname =	parsepl("banname"),
	bansteam =	parsepl("bansteam"),
	banusgn =	parsepl("banusgn"),
	kick =		parsepl("kick"),

	damageobject =	parsepl("damageobject"),
	customkill =	function (pl, wpn, victim)
				parse("customkill "..pl.id.." \""..wpn.."\""
					..victim)
			end,
	cmsg =		function (pl, msg)
				parse("cmsg \""..msg.."\" "..pl.id)
			end
}
  	  
