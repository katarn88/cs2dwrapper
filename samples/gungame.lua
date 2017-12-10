-- This table will hold player data for our script.
-- Using this table instead of the already defined global `players` table
-- prevents other scripts from overwriting any of our data
local players = setmetatable({}, playersmt)
local ggwpn = {45,48,49,30,38,20,21,10,4,50}
parse("sv_gamemode 1")
parse("mp_randomspawn 1")
parse("mp_infammo 1")

local function start()
	for pl in players() do
		pl:equip(ggwpn[1])
		pl:strip(ggwpn[pl.level])
		-- because we are using a local `players` table, other scripts
		-- cannot change these variables
		pl.level = 1
		pl.kills = 0
	end
end
-- this function doesn't pass player ids/tables, but using this method rather
-- than cs2d's addhook means `start` can be defined as local 
players:hook("startround", start)

-- wrapper hook, pl will be a player table instead of an ID
-- also allows the use of a local function and not have to worry about
-- another script using the name 'join'
local function join(pl)
	pl.level = 1
	pl.kills = 0
end
players:hook("join", join)

local function spawn(pl)
	if pl.level < #ggwpn then
		pl:strip(50)
	end
	return ggwpn[pl.level]
end
players:hook("spawn", spawn)

local function kill(pl, victim)
	if pl == victim then
		pl.kills = math.max(0, pl.kills - 1)
		return
	end

	pl.kills = pl.kills + 1
	if pl.kills >= 3 then
		pl.kills = 0
		pl.level = pl.level + 1
		if pl.level >= #ggwpn then
			msg{pl.name, "has won the game!", color = {0,255,0},
				center= true}
			parse("restart")
		else
			pl:equip(ggwpn[pl.level])
			pl:setweapon(ggwpn[pl.level])
			pl:strip(ggwpn[pl.level-1])
		end
	end

	if pl.level < #ggwpn then
		pl:msg{"Level:", pl.level, "Kills:", pl.kills}
	end
end
players:hook("kill", kill)

function ret1()
	return 1
end

local function walkover(pl, iid, type)
	if type >= 61 and type <= 68 then
		return 0
	end

	return 1
end
players:hook("walkover", walkover)

addhook("buy", "ret1")
addhook("drop", "ret1")
addhook("die", "ret1")
