### Player tables/objects
	Player tables will be passed to hook functions when using the provided
hooking functions. A player table contains only the id of a player when
initialized, and it's metatable is set to `playerobj_mt`.

	When indexing a player table there will be a check to see if CS2D has
defined variable for that key. If so, the value is retrieved from CS2D and
returned. If not, it then will check for a player method.

	pl.health	  -- same as, player(pl.id, "health")
	pl:equip("ak-47") -- same as, player_methods.equip(pl.id, "ak-47")

	If a CS2D variable can be changed then you can do it like so

	pl.money = pl.money + 10
	-- same as: parse("setmoney "..pl.id.." "..player(pl.id, "money") + 10)

	If there's no CS2D variable and no method then that key is free to be
used for storing values. These variables can be retrieved from anywhere else in
the script.

	pl.level = 1
	pl.kills = 0

	Player variables provided by CS2D can be found at.
	http://www.cs2d.com/help.php?luacat=all&luacmd=player#cmd
	It's possible that some are missing from the script.

	Player methods (as of now) are
	kill	spawn	slap	deathslap	maket	makect	makespec
	setweapon	setpos	settile	shake	flash	msg	banip
	banname	bansteam	banusgn	kick	equip	strip	cmsg
	customkill	damageobject

	There's a global table, `players`, that contains all player tables. You
can get a player's table like so

	pl = players[1]		-- player with ID of 1

	It can also be used like CS2D's provided  player(0, "table")

	for pl in players() do
		-- iterate over all players
	end

	for pl in players("tableliving") do
		-- iterate over all living players
	end

	If you're script needs to store information about players in a player
table you should create a local players table.

	-- near top of script
	local players = setmetatable({}, playersmt)

	It can be used exactly like the global but now other scripts can't
overwrite anything you store into a player table!


### Hooking
	Adding hooks is a little different from CS2D's `addhook`. You add hooks
using `players:hook(hookname, hookfunction[, prio])`. Unlike `addhook` you must
pass a function as the second paramater.

	local function spawn(pl)
		pl.level = 1
	end
	-- NOTICE: The second argument is a function, not a string!
	players:hook("spawn", spawn)

	Notice that the `spawn` function is defined locally. This prevents other
scripts from overwriting the function. No more need to store everything in a
global table to prevent that! Example:

	myscript = {}
	addhook("spawn", "myscript.spawn")
	function myscript.spawn(id)
		...
	end

	The most used hooks that pass player ids can now pass player objects.
There are a few hooks that still pass player ids. This will probably change in
the future. Here's a list of some of these hooks:
	objectdamage
	objectkill
	objectupgrade

	You can still use player tables/objects with these hooks but you have to
manually get the table

	function objectdamagehook(id, dmg, pl)
		pl = players[pl]
		...
	end

	To free a hook use `players:unhook(hookname, hookfunc)`

	local function spawn(pl)
		...
	end
	players:hook("spawn", spawn)
	...
	players:unhook("spawn", spawn)


### Overridden Functions
	A few functions so far have been altered. msg, msg2, menu, and timer
They're all reverse-compatible with CS2D's version and existing scripts.

msg(msg)
	This can be called normally (as defined by CS2D) or it can now be called
by passing a table. When passing a table all elements are concatenated for the
message string. There's a few keys that can be passed that are used as options

	sep	The seperater for the concatenation. A space by default.
	color	A table that has 3 numbers in the range 0-255, to define the
		color
	center	A boolean. When true the message is centered
	centered Same as center

	msg("hello")	-- hello
	msg{"hello", pl.name, sep=", ", color = {0, 200, 0}, center = true}
	-- message is centered and green. the message is:
	-- hello, <player name>

msg2(id, msg)
	msg is handled like with the `msg` function.
	id can be a player id or a table of player ids.
	msg2({1,2}, "hello")

menu(id, title, button)
	Title and buttons are now separated. Buttons are defined in a table.

	menu(1, "Title", {"Button|1", "Button|2", [9] = "Close"})

timer(ms, count, func, ...)
	Can now accept anonymous functions, and any number of arguments to pass
to that function. Will also return a unique ID for the timer.

	id = timer(1000, 0, function (...) print(...) end, 1, 2, 3)
	--[[ ... somewhere else ... ]]--
	freetimer(id)


### New Functions
C(r,g,b)
	Returns a color coded string.
	C(20,100,0) --> "©020100000"


### Contacting the Author (Vehk)
	http://www.unrealsoftware.de
	Username Vehk, profile link:
	http://unrealsoftware.de/profile.php?userid=159643

	If you have suggestions or find any bugs please let me know!

### Use
	You can use this work for any purpose. You can redistribute, modify,
release modified versions, etc.

	If you do use this work I ask that you credit me, but I won't come after
you if you don't.


