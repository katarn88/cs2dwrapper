local firstblood = false
local players = setmetatable({}, playersmt)

local function start()
	parse("sv_sound fun/prepare.wav")
	firstblood = false
	for pl in players() do
		pl.time = 0
		pl.kills = 0
	end
end
players:hook("startround", start)

local function spawn(pl)
	pl.time = 0
	pl.kills = 0
end
players:hook("spawn", spawn)

local utlevels = {
	false,
	{"doublekill", "made a Doublekill!"},
	{"multikill", "made a Multikill!"},
	{"ultrakill", "made an ULTRAKILL!"},
	{"monsterkill", "made a MO-O-O-O-ONSTERKILL-ILL-ILL!"},
}

local function kill(killer, victim, weapon)
	if os.clock() - killer.time > 3 then
		killer.kills = 0
	end

	if killer == victim then
		killer.kills = 0
		return
	end

	killer.kills = killer.kills + 1
	local kills = killer.kills
	killer.time = os.clock()

	if not firstblood then
		firstblood = true
		parse("sv_sound fun/firstblood.wav")
		msg{killer.name, "sheds FIRST BLOOD by killing",
			victim.name.."!", color = {180}}
	end

	if weapon == 50 then
		parse("sv_sound fun/humiliation.wav")
		msg{killer.name, "humiliated", victim.name.."!"}
	elseif kills < 6 and utlevels[kills] then
		parse("sv_sound fun/"..utlevels[kills][1]..".wav")
		msg{killer.name, utlevels[kills][2]}
	elseif kills > 5 then
		parse("sv_sound fun/unstoppable.wav")
		msg{killer.name, "is UNSTOPPABLE!", kills, "KILLS!"}
	end
end
players:hook("kill", kill)

