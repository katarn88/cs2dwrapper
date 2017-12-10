Timer = {tickfuncs = {}, prefix = "Timer.tickfuncs."}

-- This has the advantage of passing more than one argument vs. cs2d's timer,
-- passing anonymous functions, and giving a unique identifier to all timers
function Timer.RepeatEvery(ms, count, tickfunc, ...)
	local args = {...}
	-- the cs2d timer function requires a named function as a parameter
	-- create a unique name for this function
	local name = "f" .. tostring(args):sub(8)
	local fullname = Timer.prefix .. name
	-- define a new function to call tickfunc with all passed arguments
	local f = function () tickfunc(unpack(args)) end
	-- create our timer using a unique name and a closure
	Timer.tickfuncs[name] = f
	timer(ms, fullname, name, count)
	return fullname
end

-- Override timer and freetimer
do
	local oldfreetimer = freetimer
	function freetimer(name, param)
		local basename = name:sub(string.len(Timer.prefix) + 1)
		if (Timer.tickfuncs[basename]) then
			Timer.tickfuncs[basename] = nil
			param = basename
		end

		oldfreetimer(name, param)
	end

	-- This function is still compatible with code using CS2D's timer but it will
	-- be usable also like Timer.RepeatEvery
	-- timer(1000, "func", "param", 1)   < will use CS2D's timer
	-- timer(1000, 1, func, params, ...) < will use Timer.RepeatEvery
	local oldtimer = timer
	function timer(ms, count, tickfunc, ...)
		if (type(count) == "string") then
			return oldtimer(ms, count, tickfunc, ...)
		end

		return Timer.RepeatEvery(ms, count, tickfunc, ...)
	end

end
  	  
