-- generic.lua
-- @date 2021-09-06
-- @author Teardown devs
-- @brief Helper functions originaly part of SmokeGun mode by Teardown


-- Optimize dynamic compile time according to  https://www.lua.org/gems/sample.pdf
local FuncVec = Vec
local FuncVecNormalize = VecNormalize
local FuncVecScale = VecScale
local FuncMathRandom = math.random
local FuncSetMetaTable = setmetatable
local FuncGetMetaTable = getmetatable
local FuncSum = sum
local FuncAverage = average
local FuncTableRemove = table.remove
local FuncStringGmatch = string.gmatch
local FuncUnpack = unpack
local FuncTableInsert = table.insert
local FuncTableConcat = table.concat
local FuncPairs = pairs
local FuncToString = tostring
local FuncType = type
local FuncNext = next
local FuncMathFloor = math.floor
local FuncDebugCross = DebugCross
local FuncDebugLine  = DebugLine
local FuncVecLength = VecLength
local FuncVecSub = VecSub
local FuncVecDot = VecDot
-- local Generic_deepCopy = Generic_deepCopy
-- local Generic_DrawLine = Generic_DrawLine
-- local Generic_DrawPoint = Generic_DrawPoint


--Helper to return a random vector of particular length
function Generic_rndVec(length)
	local v = FuncVecNormalize(FuncVec(FuncMathRandom(-100,100), FuncMathRandom(-100,100), FuncMathRandom(-100,100)))
	return FuncVecScale(v, length)
end

--Helper to return a random number in range mi to ma
function Generic_rnd(mi, ma)
	return FuncMathRandom(1000)/1000*(ma-mi) + mi
end

function Generic_rndInt(mi, ma)
	return FuncMathRandom(mi, ma)
end

-- Deep copy helper
function Generic_deepCopy(o, seen)
	seen = seen or {}
	if o == nil then return nil end
	if seen[o] then return seen[o] end

	local no
	if FuncType(o) == 'table' then
		no = {}
		seen[o] = no

		for k, v in FuncNext, o, nil do
		no[Generic_deepCopy(k, seen)] = Generic_deepCopy(v, seen)
		end
		FuncSetMetaTable(no, Generic_deepCopy(FuncGetMetaTable(o), seen))
	else -- number, string, boolean, etc
		no = o
	end
	return no
end

--- A moving average calculator

function Generic_sma(period)
	local t = {}
	function FuncSum(a, ...)
		if a then return a+FuncSum(...) else return 0 end
	end
	function FuncAverage(n)
		if #t == period then FuncTableRemove(t, 1) end
		t[#t + 1] = n
		return FuncSum(FuncUnpack(t)) / #t
	end
	return FuncAverage
end

function Generic_bool_to_number(value)
	return value and 1 or 0
end

function Generic_number_to_bool(value)
	return value and true or false
end

function Generic_SplitString(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={}
	for str in FuncStringGmatch(inputstr, "([^"..sep.."]+)") do
		FuncTableInsert(t, str)
	end
	return t
end

function Generic_TableContains(t1,contains)
    for i=1,#t1 do
        if t1[i] == contains then
			return true
		end
    end
    return false
end

function Generic_TableContainsTable(t1,contains)
    for i=1,#t1 do
        if FuncTableConcat(t1[i]) == FuncTableConcat(contains)  then
			return true
		end
    end
    return false
end

function Generic_TableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

function Generic_TableToStr(t1, prefix)
	local str = ""
	if prefix == nil then
		prefix = ""
	end
	for key, value in FuncPairs(t1) do
		if i == 1 then
			if FuncType(value) == "table" then
				str = prefix .. "key: " .. FuncToString(key) .. " => "
			else
				str = prefix .. FuncToString(value)
			end
		else
			if FuncType(value) == "table" then
				str = str .. "; key: " .. FuncToString(key) .. " => "
			else
				str = str .. ',' .. FuncToString(value)
			end
		end
	end
    return str
end

function Generic_RGBConv(r, g, b)
	return {255 / r, 255 / g, 255 / b}
end

function Generic_xor(a, b)
  local r = 0
  for i = 0, 31 do
    local x = a / 2 + b / 2
    if x ~= FuncMathFloor(x) then
      r = r + 2^i
    end
    a = FuncMathFloor(a / 2)
    b = FuncMathFloor(b / 2)
  end
  return r
end

function Generic_HashVec(vec)
    local p1 = 73856093
    local p2 = 19349663
    local p3 = 83492791
    local xor_p1_p2 = Generic_xor((vec[1] * p1), vec[3] * p2)
    local xored_p1_2wp3 = Generic_xor(xor_p1_p2, (vec[2] * p3))
    return xored_p1_2wp3
end



---Draw a point if visualize fire detection is turned on
---@param point Vec (array of 3 values) containing the position to draw the point
---@param r float intensity of the color red
---@param g float intensity of the color green
---@param b float intensity of the color blue
function Generic_DrawPoint(point, r, g, b, draw)
    if draw then
        FuncDebugCross(point,  r, g, b)
    end
end


---Draw a line between two points if visualize fire detection is turned on
---@param vec1 Vec (array of 3 values) containing the position to draw the point
---@param vec2 Vec (array of 3 values) containing the position to draw the point
---@param r float intensity of the color red
---@param g float intensity of the color green
---@param b float intensity of the color blue
function Generic_DrawLine(vec1, vec2, r, g, b, draw)
    if draw then
        FuncDebugLine(vec1, vec2, r, g, b)
    end
end

---Calculate distance between two 3D vectors
---@param vec1 Vec (array of 3 values) containing the position
---@param vec2 Vec (array of 3 values) containing the position
---@return number value of the distance
function Generic_VecDistance(vec1, vec2)
    return FuncVecLength(FuncVecSub(vec1, vec2))
end

function Generic_VecCompare(vec1, vec2)
    return ((vec1[1] and vec2[1]) and (vec1[2] and vec2[2]) and (vec1[3] and vec2[3]))
end

function Generic_CreateBox(point, size, point2, color, draw)
    local p1 = {point[1] - size, point[2] - size, point[3] - size}
    local p2 = {point[1] - size, point[2] + size, point[3] - size}
    local p3 = {point[1] - size, point[2] + size, point[3] + size}
    local p4 = {point[1] - size, point[2] - size, point[3] + size}

    local p5 = {point[1] + size, point[2] - size, point[3] - size}
    local p6 = {point[1] + size, point[2] + size, point[3] - size}
    local p7 = {point[1] + size, point[2] + size, point[3] + size}
    local p8 = {point[1] + size, point[2] - size, point[3] + size}

    if draw then
        Generic_DrawLine(p1, p2, color[1], color[2], color[3], draw)
        Generic_DrawLine(p2, p3, color[1], color[2], color[3], draw)
        Generic_DrawLine(p3, p4, color[1], color[2], color[3], draw)
        Generic_DrawLine(p4, p1, color[1], color[2], color[3], draw)


        Generic_DrawLine(p5, p6, color[1], color[2], color[3], draw)
        Generic_DrawLine(p6, p7, color[1], color[2], color[3], draw)
        Generic_DrawLine(p7, p8, color[1], color[2], color[3], draw)
        Generic_DrawLine(p8, p5, color[1], color[2], color[3], draw)


        Generic_DrawLine(p1, p5, color[1], color[2], color[3], draw)
        Generic_DrawLine(p2, p6, color[1], color[2], color[3], draw)
        Generic_DrawLine(p3, p7, color[1], color[2], color[3], draw)
        Generic_DrawLine(p4, p8, color[1], color[2], color[3], draw)
    end

    if point2 ~= nil then

        local u = FuncVecSub(p5, p1)
        local v = FuncVecSub(p5, p6)
        local w = FuncVecSub(p5, p8)

        local ud = FuncVecDot(u, point2)
        local vd = FuncVecDot(v, point2)
        local wd = FuncVecDot(w, point2)

        local u1 = FuncVecDot(u, p5)
        local u2 = FuncVecDot(u, p1)

        local v1 = FuncVecDot(v, p5)
        local v2 = FuncVecDot(v, p6)

        local w1 = FuncVecDot(w, p5)
        local w2 = FuncVecDot(w, p8)

        if  (ud > u2 and ud < u1) and (vd > v2 and vd < v1) and (wd > w2 and wd < w1) then


            Generic_DrawPoint(point2, 1,0,0, draw)
            return true
        else
            Generic_DrawPoint(point2, 0,1,0, draw)
            -- Generic_DrawPoint(point2, 1,0,0)
            return false
        end
    else
        return {p1,p2,p3,p4,p5,p6,p7,p8}
    end
end

function Generic_SpawnLight(point, material, intensity)
    material = Generic_deepCopy(material)
	material["color"]["r"] =  material["color"]["r"] - 0
    material["color"]["g"] =  material["color"]["g"] - 0.1
    material["color"]["b"] =  material["color"]["b"] - 0.1

    if  material["color"]["r"] > 1 then
        material["color"]["r"] = 1
    end
    if  material["color"]["r"] < 0 then
        material["color"]["r"] = 0
    end

    if  material["color"]["g"] > 1 then
        material["color"]["g"] = 1
    end
    if  material["color"]["g"] < 0 then
        material["color"]["g"] = 0
    end

    if  material["color"]["b"] > 1 then
        material["color"]["b"] = 1
    end
    if  material["color"]["b"] < 0 then
        material["color"]["b"] = 0
    end
    local color = FuncVec(material["color"]["r"], material["color"]["g"], material["color"]["b"])
    intensity = intensity
    return {point, intensity, intensity, color, true}
end