-- Using the global `players` table because there is no player data needed
local function boostdrain()
	for pl in players("tableliving") do
		local sm = pl.speedmod - 2
		pl.speedmod = sm < -2 and -2 or sm
	end
end

timer(3000, 0, boostdrain)

local function boostkill(killer, victim)
	killer.speedmod = killer.speedmod + 3
end
players:hook("kill", boostkill)

local function boostspawn(pl)
	pl.speedmod = 4
end
players:hook("spawn", boostspawn)
