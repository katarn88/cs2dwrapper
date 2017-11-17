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
	function kill(killer, victim)
		if killer.team == victim.team then
			killer:slap()
			killer.speedmod = 0
		else
			killer.speedmod = killer.speedmod + 2
		end
	end
	addhook("kill", kill)
---------------------------------------------------------------------
	Much more clear and saves a little typing!
]]--

-- Table containing player objects/tables. Can be called like a funciton to
-- return an iterator of players. Similar to CS2D's  player(0, "table")
players = {}
setmetatable(players, {
	-- Returns an iterator for all players. The second argument by default
	-- is "table" for other options see:
	-- http://www.cs2d.com/help.php?luacat=all&luacmd=player#cmd 
	__call = function (fn, table)
		table = table or "table"
		local t = player(0, table) or {}
		local i = 0

		return function ()
			i = i + 1
			return t[i] and players[t[i]] or nil
		end
	end,

	-- The `players' table holds other tables to describe players
	-- this metamethod will create this table if it doesn't exist
	__index = function (pl, key)
		if type(key) == "number" then
			if key < 1 or key > 32 then
				return nil
			end
		else
			return nil
		end

		pl[key] = {id = key}
		setmetatable(pl[key], players_mt)
		return pl[key]
	end
})

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
	if type(wpns) ~= "table" then
		wpns = {wpns}
	end

	parse("strip "..id.." 0")

	for _,v in ipairs(wpns) do
		parse("equip "..id.." "..v)
	end
end

-- This table defines what details about a player can be retrieved with the
-- `player' function provided by CS2D. If the value can be modified by Lua then
-- the value of the table index will be a function to set it.
local players_index = {
	exists		= false,
	name		= plset,
	ip		= false,
	port		= false,
	usgn		= false,
	ping		= false,
	idle		= false,
	bot		= false,
	team		= false,
	look		= false,
	x		= setx,
	y		= sety,
	rot		= false,
	tilex		= settilex,
	tiley		= settiley,
	health		= plset,
	armor		= plset,
	money		= plset,
	score		= plset,
	deaths		= plset,
	teamkills	= false,
	hostagekills	= false,
	teambuildingkills = false,
	weapontype	= false,
	weapon		= plset,
	nightvision	= false,
	defusekit	= false,
	gasmask		= false,
	bomb		= false,
	flag		= false,
	reloading	= false,
	process		= false,
	sprayname	= false,
	spraycolor	= false,
	votekick	= false,
	votemap		= false,
	favteam		= false,
	spectating	= false,
	speedmod	= speedmod,
	maxhealth	= plset,
	rcon		= false,
	ai_flash	= false,
	screenw		= false,
	screenh		= false,
	weapons		= setweapons
}

-- Metatable for player objects
players_mt = {
	__index = function (table, key)
		if key == "weapons" then
			return playerweapons(rawget(table, "id"))
		end

		if (players_index[key]) then
			return player(rawget(table, "id"), key)
		end

		return players_methods[key] or rawget(table, key)
	end,

	__newindex = function (table, key, value)
		local f = players_index[key]
		if (type(f) == "function") then
			f(rawget(table, "id"), value, key)
		else
			rawset(table, key, value)
		end
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
			parse("equip "..id.." "..item)
		end
	end,

	strip = function (pl, ...)
		local id = pl.id
		local items = {...}
		for _, item in ipairs(items) do
			parse("strip "..id.." "..item)
		end
	end,

	-- parsepl returns a function that calls the specified command
	kill =		parsepl("killplayer"),
	spawn =		parsepl("spawnplayer"),
	slap =		parsepl("slap"),
	maket =		parsepl("maket"),
	makect =	parsepl("makect"),
	makespec =	parsepl("makespec"),
	setweapon =	parsepl("setweapon"),
	setpos =	parsepl("setpos"),
	settile =	parsepl("settile"),
	shake =		parsepl("shake"),
	flash =		parsepl("flashplayer"),
	msg = 		function (pl, ...) msg2(pl.id, ...) end,
}
