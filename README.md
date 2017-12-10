# cs2dwrapper
Wrapper for CS2D's Lua interface.
### See README.txt for more details
The intention behind this project is to improve the CS2D Lua API by making it
more readable, simple, and to improve some of the ugliest parts (menu function
for example).

To me, this is much more clear
```Lua
pl.health = pl.health + 25
```
than this:
```Lua
parse("sethealth "..id.." "..player(id, "health") + 25)
```

It's also easier to type and shorter!

## Function Changes
The functions are all reverse-compatible with existing CS2D scripts.
* msg
	Now takes either a string or a table. When given a table any array
    parts will be concatenated. There are a few optional parameters that can be
    passed by the table.
	* color		a table containing 3 integers in the range 0-255
	* sep		separator for items, space by default
	* centered	a boolean. if true the message is centered
	* center	same as centered
```Lua
msg("hello")
msg{"hello", pl.name, color={0,200,0}, sep=", ", center=true}
```

* msg2
	Same as before but now can be passed a table of IDs. Handles messages
    the same as the new msg function.
```Lua
msg2(1, "hello")
msg2({1, 2}, {"foo", "bar", color={0,0,0}})
```

* timer
	Can now pass multiple arguments to functions, given anonymous
    functions, and returns a unique identifier for timers.
```Lua
local id = timer(1000, 10, function (...) print(...) end, "hello", ",", "world")
```
* menu
	Now accepts three arguments. id, title, and buttons
	id is the player id to show the menu
	title is the menu title, and buttons is a table containing the button
	text
```Lua
menu(1, "Title", {"Button|1", "Button|2", [9] = "Close"})
```
Buttons that don't exist in the table are replaced with a blank/nil string.

## General Changes
* hooks
* players
