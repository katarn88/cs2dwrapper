classes = {
	{"Soldier", mhp = 150, armor = 202, speed = -5,
			wpns = {40, 4, 51}},
	{"Spy", mhp = 100, armor = 206, speed = 5,
			wpns = {21, 1}},
	{"Engineer", mhp = 100, armor = 50, speed = 0,
			wpns = {10,2,74}},
	{"Pyro", mhp = 125, armor = 75, speed = 0,
			wpns = {46, 6, 73}}
	{"Scout", mhp = 75, armor = 0, speed = 15,
			wpns = {5, 69, 54}},
	{"Sniper", mhp = 75, armor = 25, speed = 0,
			wpns={35,3,53}}
}

function classmenu(pl)
	menu(pl.id, "Select Your Class", {
		"Soldier|Armor+MG",

addhook("spawn", function (pl)
	pl.maxhealth = pl.class.mhp
	pl.armor = pl.class.armor
	pl.speedmod = pl.class.speed
	pl.weapons = pl.class.wpns
end)


