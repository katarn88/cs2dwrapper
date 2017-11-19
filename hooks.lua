VWHOOKS = {}

do
	local addhook_ = addhook
	local freehook_ = freehook
	local prefix = "VWHOOKS."
	local hookinfo = {
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

	function genhook(hookname, fn, pl)
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
		end

		return fn
	end

--- Add a CS2D hook.
--  Creates a new CS2D hook. If the second parameter is a string, then this
--  function works like CS2D's addhook. When it's a function, any hooks that
--  pass players' ids will now pass player tables.
-- @param The name of the hook.
-- @param Name or definition of the hook function.
-- @param 
	function addhook(name, func, prio, pl)
		if type(prio) == "table" then
			pl = prio
			prio = 0
		end

		prio = prio or 0
		if type(func) == "string" then
			-- use CS2D's addhook
			addhook_(name, func, prio)
			return func
		elseif type(func) ~= "function" then
			error("Second parameter to addhook must be a string or function")
			return nil
		end

		-- create a hook function
		local hookfn = genhook(name, func, pl or players)
		-- create a unique name
		local fnname = "f"..tostring(hookfn):sub(11)
		-- add the hook
		local success, err = pcall(addhook_, name, prefix..fnname, prio)
		if not success then
			error(err)
			return nil
		end

		VWHOOKS[fnname] = hookfn
		return fnname
	end

	function freehook(name, func)
		if type(func) == "function" then
			for k,v in pairs(VWHOOKS) do
				if v == func then
					func = k
					break
				end
			end

			return freehook_(name, prefix..func)
		end

		if VWHOOKS[func] then
			VWHOOKS[func] = nil
		end

		return freehook_(name, func)
	end
end
