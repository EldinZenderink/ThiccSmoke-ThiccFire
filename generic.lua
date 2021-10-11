-- generic.lua
-- @date 2021-09-06
-- @author Teardown devs
-- @brief Helper functions originaly part of SmokeGun mode by Teardown

--Helper to return a random vector of particular length
function Generic_rndVec(length)
	local v = VecNormalize(Vec(math.random(-100,100), math.random(-100,100), math.random(-100,100)))
	return VecScale(v, length)
end

--Helper to return a random number in range mi to ma
function Generic_rnd(mi, ma)
	return math.random(1000)/1000*(ma-mi) + mi
end

function Generic_rndInt(mi, ma)
	return math.random(mi, ma)
end

-- Deep copy helper
function Generic_deepCopy(o, seen)
	seen = seen or {}
	if o == nil then return nil end
	if seen[o] then return seen[o] end

	local no
	if type(o) == 'table' then
		no = {}
		seen[o] = no

		for k, v in next, o, nil do
		no[Generic_deepCopy(k, seen)] = Generic_deepCopy(v, seen)
		end
		setmetatable(no, Generic_deepCopy(getmetatable(o), seen))
	else -- number, string, boolean, etc
		no = o
	end
	return no
end

--- A moving average calculator

function Generic_sma(period)
	local t = {}
	function sum(a, ...)
		if a then return a+sum(...) else return 0 end
	end
	function average(n)
		if #t == period then table.remove(t, 1) end
		t[#t + 1] = n
		return sum(unpack(t)) / #t
	end
	return average
end

function Generic_bool_to_number(value)
	return value and 1 or 0
end

function Generic_number_to_bool(value)
	return value and true or false
end