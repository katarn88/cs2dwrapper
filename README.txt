1. Player tables/objects
2. Hooking
3. Overridden functions
4. New Functions
5. Compatibility
6. Contacting the Author (Vehk)
7. Use


	This document will describe the wrapper and how to use it as well as a
few recommended practices. If you're a scripter and you have a suggestion for
anything that should be added or changed to this document or the API, or if you
think this is just sh**, let me know! My goal is to help make the CS2D Lua API
cleaner and simpler. Experienced Lua scripters and CS2D modders are needed to
make this the best possible!

	I was inspired by Livia's¹ Love API² which seems to be dead³.
	1. http://unrealsoftware.de/profile.php?userid=4917
	2. http://unrealsoftware.de/forum_posts.php?post=361865
	3. [404] https://github.com/tarjoilija/lapi

	The biggest part of this wrapper is player tables and metatables. These
tables make it possible to write code like this

	pl:equip("deagle")
	pl.speedmod = 10
	pl.health = pl.health + 10
	pl.weapons = {50, "laser"}

	Rather than

	parse("equip "..id.." deagle")
	parse("speedmod "..id.." 10")
	parse("sethealth "..id.." "..player(id, "health") + 10)

	parse("strip "..id.." 0")
	parse("equip "..id.." 50")
	parse("equip "..id.." laser")

	That's ugly and hard to read and edit!

	The wrapper also changes a few CS2D provided functions to simplify
usage. A major change is the menu function (see section 3 for details). All
functions that are overridden are reverse-compatible with existing scripts and
the standard CS2D API.

	To load the wrapper you must load wrapper.lua. By default it will be in
sys/lua/vw/wrapper.lua

	A global variable  _VEHKWRAPPER  is set to true when wrapper.lua is
loaded. You can use this to test if the wrapper is loaded.



### 1. Player tables/objects
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
	Examples of these:
	x	y	name	steamname	usgn	usgname	steamid	tilex
	tiley	health	armor	assists	score	deaths	gasmask	money	exists
	  ...
	Some from the above page could be missing from the script. If you find
any, let me know! Contact details are at the bottom of this document.  

	Player methods (as of now) are
	kill	spawn	slap	deathslap	maket	makect	makespec
	setweapon	setpos	settile	shake	flash	msg	banip
	banname	bansteam	banusgn	kick	equip	strip	cmsg
	customkill	damageobject

	There's a global table, `players`, that contains all player tables. You
can get a player's table like so

	pl = players[1]		-- player with ID of 1
	pl.health = 100

	It can also be used like CS2D's provided  player(0, "table")


	for pl in players() do
		-- iterate over all players
		pl:msg("hello, " .. pl.name)
	end

	for pl in players("tableliving") do
		-- iterate over all living players
		pl:kill()
	end


	If your script needs to store information about players in a player
table you should create a local `players` table.

	-- near top of script
	local players = setmetatable({}, playersmt)

	It can be used exactly like the global but now other scripts can't
overwrite anything you store into a player table! If the above line is confusing
to you, read up on Lua metatables! They're a very powerful feature of the
language!

	This does cause a problem if you need to share the `players` table with
other scripts. There's different ways to solve this problem. You could use a
global players table with a unique name, or a global function that returns the
table.

	myplayers = setmetatable({}, playersmt)
	local players = myplayers

	In other files,

	local players = myplayers

	Global function,


	local players = setmetatable({}, playersmt)
	function getmyplayerstable()
		return players
	end


	And in another file needing the same `players` table you'd do,

	local players = getmyplayerstable()

	There is of course other ways to get around this limitation.

	If you need to get the global `players` table, but are using a local one
with the same name you can get it with,

	_G.players		-- global players table

	Having the global `players` table allows different scripts/mods to share
data with each other. I don't know of a use for this yet, but someone might find
one.

--[!]--	You should not overwrite the global players table! And only store values
in it if it's to share them with other scripts! My recommendation is to always
use a local players table and to only access the global one with _G.players.



### 2. Hooking
	Adding hooks is a little different from CS2D's `addhook`. You add hooks
using `players:hook(hookname, hookfunction[, prio])`. Unlike `addhook` you must
pass a function as the second parameter.

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



### 3. Overridden Functions
	A few functions so far have been altered. msg, msg2, menu, and timer
They're all reverse-compatible with CS2D's version and existing scripts.

msg(msg)
	This can be called normally (as defined by CS2D) or it can now be called
by passing a table. When passing a table all elements are concatenated for the
message string. There's a few optional keys that can be passed that are used as
options

	sep	The seperater for the concatenation. A space by default.
	color	A table that has 3 numbers in the range 0-255, to define the
		color
	center	A boolean. When true the message is centered
	centered Same as center

	msg("hello")	-- hello
	msg{"red message", color={255}}
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



### 4. New Functions
C([r,[g,[b]]])
	Returns a color coded string. g and b are 0 by default.
	C(20,100,0) --> "©020100000"
	When called without any arguments it will return the colorcode
character. This character will be either   a9   or   c2 a9   (hex) for ASCII or
UTF-8 respectively.

	You should ALWAYS use this to get color strings. It will return a valid
string when using ASCII or UTF-8! If you put © directly or use string.char(169),
etc., your code will raise an error if UTF-8 is being used!



### 5. Compatibility
	These scripts shouldn't cause problems with most other scripts. If you
find a problem contact me.

	Compatibility has been added for EngiN33R's utf8 library. Loading it
before or after this should work, but I recommend loading his script first
(before any others).

	As mentioned in section 4, you should use the provided function `C` to
have compatibility with both UTF-8 and ASCII.



### 6. Contacting the Author (Vehk)
	http://www.unrealsoftware.de
	Username Vehk, profile link:
	http://unrealsoftware.de/profile.php?userid=159643

	If you have suggestions or find any bugs please let me know!



### 7. Use
	You can use this work for any purpose. You can redistribute, modify,
release modified versions, etc.

	If you do use this work I ask that you credit me, but I won't come after
you if you don't.


  	  
