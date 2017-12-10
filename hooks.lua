VWHOOKS = {}
local prefix = "VWHOOKS."
local hookinfo = {
	assist = 3,
	attack = 1,
	attack2 = 1,
	bombdefuse = 1,
	bombexplode = 1,
	bombplant = 1,
	build = 1,
	buildattempt = 1,
	buy = 1,
	clientdata = 1,
	collect = 1,
	die = 1,
	dominate = 1,
	drop = 1,
	flagcapture = 1,
	flagtake = 1,
	flashlight = 1,
	hit = 2,
	hostagerescue = 1,
	join = 1,
	key = 1,
	kill = 2,
	leave = 1,
	menu = 1,
	move = 1,
	movetile = 1,
	name = 1,
	radio = 1,
	reload = 1,
	say = 1,
	sayteam = 1,
	select = 1,
	serveraction = 1,
	shieldhit = 2,
	spawn = 1,
	specswitch = 2,
	spray = 1,
	suicide = 1,
	team = 1,
	use = 1,
	usebutton = 1,
	vipescape = 1,
	vote = 1,
	walkover = 1
}

local function genhook(hookname, fn, pl)
	-- this method works for now, but as more hooks are added that pass
	-- player ids non-consecutively another method will be needed
	local t = hookinfo[hookname]
	if not t then
		return fn
	end

	if t == 1 then
		return function (id, ...)
			return fn(pl[id], ...)
		end
	elseif t == 2 then
		return function (id, id2, ...)
			return fn(pl[id], pl[id2], ...)
		end
	elseif t == 3 then
		return function (id, id2, id3, ...)
			return fn(pl[id], pl[id2], pl[id3], ...)
		end
	end

	return fn
end

--- Add a CS2D hook.
-- Adds a CS2D hook. For hooks that pass player ids they will now pass player
-- tables instead.
-- @param Player table to use. Allows scripts to seperate player data.
-- @param The name of the hook.
-- @param Hook function.
-- @param (optional) Hook priority.
function pladdhook(pl, hook, func, prio)
	prio = prio or 0

	-- create a hook function
	local hookfn = genhook(hook, func, pl)
	-- unique name
	local fnname = "f"..tostring(hookfn):sub(11)
	-- add the hook
	local success, err = pcall(addhook, hook, prefix..fnname, prio)
	if not success then
		error(err)
		return false
	end

	-- the entry for `func` provides a way to free the hook
	-- the entry for `fnname` gives CS2D a global named function to call
	VWHOOKS[func] = hookfn
	VWHOOKS[fnname] = hookfn
	return true, fnname
end

function plfreehook(pl, hook, func)
	local hookfn = VWHOOKS[func]

	if not hookfn then
		error("No hook for "..tostring(func))
		return nil
	end

	local name = "f"..tostring(hookfn):sub(11)
	VWHOOKS[func] = nil
	VWHOOKS[name] = nil
	return freehook(hook, prefix .. name)
end

