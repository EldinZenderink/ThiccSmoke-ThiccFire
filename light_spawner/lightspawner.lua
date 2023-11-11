-- lightspwaner.lua
-- @date 2022-02-26
-- @author Eldin Zenderink
-- @brief Spawn FPS friendly lights using spawning of light points (instead of spotlight), side effect it looks a bit worse than spotlights (affects global illumination less), but faster and better than none ;P.

-- Needs to be set to true if update is called periodically
LightSpawner_DeleteFadeEnabled = false

-- List to keep track of light instance
LightSpawner_Lights = {}
LightSpawner_Entities = {}

---Deep copy function to create a unreferenced copy of a value (e.g. if you don't want the value you get to upate a existing referenced value in a table)
---@param o any
---@param seen any
---@return any
function LightSpawner_deepCopy(o, seen)
	seen = seen or {}
	if o == nil then return nil end
	if seen[o] then return seen[o] end
    local no
	if type(o) == 'table' then
		no = {}
		seen[o] = no

		for k, v in next, o, nil do
		no[LightSpawner_deepCopy(k, seen)] = LightSpawner_deepCopy(v, seen)
		end
		setmetatable(no, LightSpawner_deepCopy(getmetatable(o), seen))
	else -- number string, boolean, etc
		no = o
	end
	return no
end

---Helper function to compare two vectors
---@param vec1 Vec
---@param vec2 Vec
---@return boolean (true == the same)
function LightSpawner_VecCompare(vec1, vec2)
    return ((vec1[1] == vec2[1]) and (vec1[2] == vec2[2]) and (vec1[3] == vec2[3]))
end

---Convert RGB (0-255) to Teardown RGB values (0-1)
---@param r number Red color in values from 0-255
---@param g number Green color in values from 0-255
---@param b number Blue color in values from 0-255
---@return Vec Vector containing teardown compatible colors
function LightSpawner_RGBConv(r, g, b)
	return Vec(255 / r, 255 / g, 255 / b)
end



---XOR helper
---@param a any value to xor
---@param b any value to xor with
---@return integer xored value
function LightSpawner_xor(a, b)
  local r = 0
  for i = 0, 31 do
    local x = a / 2 + b / 2
    if x ~= math.floor (x) then
      r = r + 2^i
    end
    a =  math.floor (a / 2)
    b =  math.floor (b / 2)
  end
  return r
end

---Generates a unique hash for a vectore
---@param Vec vec
---@return integer
function LightSpawner_HashVec(vec)
    local p1 = 73856093
    local p2 = 19349663
    local p3 = 83492791
    local xor_p1_p2 = LightSpawner_xor((vec[1] * p1), vec[3] * p2)
    local xored_p1_2wp3 = LightSpawner_xor(xor_p1_p2, (vec[2] * p3))
    return xored_p1_2wp3
end

---Generate random vector with max lenght
---@param length number
---@return Vec
function LightSpawner_rndVec(length)
	local v = VecNormalize(Vec(math.random(-100,100), math.random(-100,100), math.random(-100,100)))
	return VecScale(v, length)
end

---Spawns a new light point.
---@param location Vec location of the light point
---@param size number size of the light
---@param intensity number intensity of the light
---@param color Vec color of the light (can be RGB 0-255 values!)
---@param enabled boolean if the light should emit or not (can be toggled)
---@return number id reference compatible with Teardown functions such as SetLightColor, SetLightIntensity, SetLightEnabled, also used as reference for LightSpawner, remember them!
function LightSpawner_Spawn(location, size, intensity, color, enabled, tag)
    if tag == nil then
        tag = ""
    end
    local light_instance = {
        location=location,
        locationstart=location,
        locationend=nil,
        animaterotation=0.5,
speed=nil,
        animatejitter=nil,
        animateinvert=false,
        animating=false,
        animate=false,
        animatecurtime=0,
        animatesteps=nil,
        size=size,
        color=color,
        intensity=intensity,
        enabled=enabled,
        entity=nil,
        entity_index=nil,
        light=nil,
        tag=tag,
        fadedelete=false,
        fadetime=1,
        fadereduction=nil
    }

    if color[1] > 1 or color[2] > 1 or color[3] > 1 then
        color = LightSpawner_RGBConv(color[1], color[2], color[3])
    end

    -- Generate random id
    local new_id = LightSpawner_HashVec(LightSpawner_rndVec(10000))

    -- Make sure no duplicates exist
    while LightSpawner_Lights[new_id] ~= nil do
        new_id = LightSpawner_HashVec(LightSpawner_rndVec(10000))
    end

    light_instance["entity"] = Spawn("<light name='light_" .. tostring(new_id) .. "' tags='ls_light_" .. tostring(new_id) .. " " .. tag .. " id="..tostring(new_id).."' color='1.0 1.0 1.0' scale='" .. tostring(size / 10) .. "' size='" ..  tostring(size / 100) .. "'/>", Transform(location))

    local light = FindLight("ls_light_" .. tostring(new_id), true)
    if LightSpawner_Lights[new_id] == nil then
        light_instance = light_instance
        light_instance["light"] = LightSpawner_deepCopy(light)
        SetLightColor(light, color[1], color[2], color[3])
        SetLightIntensity(light, intensity)
        SetLightEnabled(light, enabled)
        LightSpawner_Lights[new_id] = light_instance
        return new_id
    end
    return nil
end

--- Spawn and animate light
---@param locationstart start position
---@param locationend end position
---@param jitter jitter during interpolation
---@param speed speed of animation
---@param size any
---@param intensity any
---@param color any
---@param enabled any
---@param tag any
function LightSpawner_SpawnAnimate(locationstart, locationend, jitter, speed, size, intensity, color, enabled, tag)
    if tag == nil then
        tag = ""
    end
    local light_instance = {
        location=locationstart,
        locationstart=locationstart,
        locationend=locationend,
        animaterotation=0.5,
speed=speed,
        animatejitter=jitter,
        animateinvert=false,
        animating=false,
        animate=true,
        animatecurtime=0,
        animatesteps=nil,
        size=size,
        color=color,
        intensity=intensity,
        enabled=enabled,
        entity=nil,
        entity_index=nil,
        light=nil,
        tag=tag,
        fadedelete=false,
        fadetime=1,
        fadereduction=nil
    }

    if color[1] > 1 or color[2] > 1 or color[3] > 1 then
        color = LightSpawner_RGBConv(color[1], color[2], color[3])
    end

    -- Generate random id
    local new_id = LightSpawner_HashVec(LightSpawner_rndVec(10000))

    -- Make sure no duplicates exist
    while LightSpawner_Lights[new_id] ~= nil do
        new_id = LightSpawner_HashVec(LightSpawner_rndVec(10000))
    end

    light_instance["entity"] = Spawn("<light name='light_" .. tostring(new_id) .. "' tags='ls_light_" .. tostring(new_id) .. " " .. tag .. " id="..tostring(new_id).."' color='1.0 1.0 1.0' scale='" .. tostring(size / 10) .. "' size='" ..  tostring(size / 100) .. "'/>", Transform(location))

    local light = FindLight("ls_light_" .. tostring(new_id), true)
    if LightSpawner_Lights[new_id] == nil then
        light_instance = light_instance
        light_instance["light"] = LightSpawner_deepCopy(light)
        SetLightColor(light, color[1], color[2], color[3])
        SetLightIntensity(light, intensity)
        SetLightEnabled(light, enabled)
        LightSpawner_Lights[new_id] = light_instance
        return new_id
    end
    return nil
end

function LightSpawner_Status()
    local count = 0
    for id, instance in pairs(LightSpawner_Lights) do
        DebugPrint("Found: " .. count)
        count = count + 1
    end
    DebugWatch("Lights Spawned", count)
end

--- Needs to be called periodically to allow for fadeout timing
---@param dt time delta
function LightSpawner_Update(dt)
    LightSpawner_DeleteFadeEnabled = true
    for id, instance in pairs(LightSpawner_Lights) do
        if instance["fadedelete"] then
            if instance["intensity"] > 0 then
                if instance["fadereduction"] == nil then
                    instance["fadereduction"] = instance["intensity"] / (instance["fadetime"] / dt)
                end
                -- DebugWatch(id.."in", instance["intensity"])
                -- DebugWatch(id.."fr", instance["fadereduction"])
                local newintensity = instance["intensity"] - instance["fadereduction"]
                LightSpawner_ForceUpdateLightIntensity(id, newintensity)
            else
                LightSpawner_DeleteLight(id)
            end
        end

        if instance["animate"] then
            if instance["animatesteps"] == nil then
                instance["animatesteps"] = 1 / (instance["animatespeed"] / dt)
            end

            instance["animatecurtime"] = instance["animatecurtime"] + instance["animatesteps"]

            instance["animating"] = true
            if instance["animatecurtime"] >= 1 then
                instance["animatesteps"] = -instance["animatesteps"]
            end

            if instance["animatecurtime"] <= 0 then
                LightSpawner_ForceSetNewLightLocation(id, instance["location"])
                instance["locationstart"] = instance["location"]
                instance["animatecurtime"] = 0
                instance["animatesteps"] = nil
            else
                local newloc = VecLerp(instance["locationstart"], instance["locationend"], instance["animatecurtime"])
                newloc = VecAdd(newloc, Generic_rndVec(instance["animatejitter"]))
                LightSpawner_ForceSetNewLightLocation(id, newloc)
            end

        end
    end
end

---Spawns a new light point.
---@param id number light reference returned from LightSpawner_Spawn function
---@return number id reference compatible with Teardown functions such as SetLightColor, SetLightIntensity, SetLightEnabled, also used as reference for LightSpawner, remember them!
function LightSpawner_ReplaceSpawn(id)
    if LightSpawner_Lights[id] ~= nil then
        local light_instance = LightSpawner_deepCopy(LightSpawner_Lights[id])
        local color = light_instance["color"]
        local intensity = light_instance["intensity"]
        local location = light_instance["location"]
        local enabled = light_instance["enabled"]
        local size = light_instance["size"]
        if color[1] > 1 or color[2] > 1 or color[3] > 1 then
            color = LightSpawner_RGBConv(color[1], color[2], color[3])
        end

        LightSpawner_DeleteLight(id)

        light_instance["entity"] = Spawn("<light name='light_" .. tostring(id) .. "' tags='ls_light_" .. tostring(id) .. "' color='1.0 1.0 1.0' scale='" .. tostring(size / 10) .. "' size='" ..  tostring(size / 100) .. "'/>", Transform(location))

        local light = FindLight("ls_light_" .. tostring(id), true)
        if LightSpawner_Lights[id] == nil then
            light_instance["light"] = LightSpawner_deepCopy(light)
            LightSpawner_Lights[id] = light_instance
            SetLightColor(light, color[1], color[2], color[3])
            SetLightIntensity(light, intensity)
            SetLightEnabled(light, enabled)
            return id
        end
        return nil
    end
    return nil
end

--- Delete all lights spawned
--- @note Make sure if you store light handles locally to remove those as well!
function LightSpawner_DeleteAll()
    for id, instance in pairs(LightSpawner_Lights) do
        LightSpawner_DeleteLight(id)
    end
end

--- Delete all tagged lights spawned
--- @note Make sure if you store light handles locally to remove those as well!
function LightSpawner_DeleteTagged(tag)
    local lights = FindLights(tag, true)
    for l=1, #lights do
        SetLightEnabled(lights[l], false)
        LightSpawner_DeleteLight(tonumber(GetTagValue(lights[l], "id")))
    end
end

--- Delete a specific light (disables and removes light, then removes spawned entity)
---@param id number light reference returned from LightSpawner_Spawn function
---@return boolean -- Succeed or failed  (true or false) (failure could mean that the light reference has already been deleted once!)
function LightSpawner_DeleteLight(id)
    if LightSpawner_Lights[id] ~= nil then
        local light_instance = LightSpawner_Lights[id]
        local light = light_instance["light"]
        SetLightEnabled(light, false)
        Delete(light)
        Delete(light_instance["entity"])
        LightSpawner_Lights[id] = nil
        return true
    else
        return false
    end
end

--- Delete fade all lights spawned
--- @param fadetime = how much to bleed off intensity per call
--- @note Make sure if you store light handles locally to remove those as well!
function LightSpawner_DeleteFadeAll(fadetime)
    if LightSpawner_DeleteFadeEnabled == false then
        return LightSpawner_DeleteAll()
    end
    for id, instance in pairs(LightSpawner_Lights) do
        LightSpawner_Lights[id]["fadedelete"] = true
        LightSpawner_Lights[id]["fadetime"] = fadetime
    end
end

--- Delete all tagged lights spawned
--- @note Make sure if you store light handles locally to remove those as well!
function LightSpawner_DeleteTaggedFade(tag, fadetime)
    local lights = FindLights(tag, true)
    for l=1, #lights do
        LightSpawner_DeleteLightFade(tonumber(GetTagValue(lights[l], "id")), fadetime)
    end
end

--- Delete fade all lights spawned
--- @param id number light reference returned from LightSpawner_Spawn function
--- @param fadetime = how much to bleed off intensity per call
--- @note Make sure if you store light handles locally to remove those as well!
function LightSpawner_DeleteLightFade(id, fadetime)
    if LightSpawner_DeleteFadeEnabled == false then
        return LightSpawner_DeleteLight(id)
    end
    LightSpawner_Lights[id]["fadedelete"] = true
    LightSpawner_Lights[id]["fadetime"] = fadetime
end


--- Update light color.
---@param light number light reference returned from LightSpawner_Spawn function
---@param color Vec color of the light (can be RGB 0-255 values!)
---@return number The original light reference upon success, or nil on failure (light reference unknown)
function LightSpawner_UpdateLightColor(id, color)
    if color[1] > 1 or color[2] > 1 or color[3] > 1 then
        color = LightSpawner_RGBConv(color[1], color[2], color[3])
    end
    if LightSpawner_Lights[id] ~= nil then
        local light_instance = LightSpawner_Lights[id]
        light_instance["color"] = color
        SetLightColor(light_instance["light"], light_instance["color"][1], light_instance["color"][2], light_instance["color"][3])
        return id
    end
    return nil
end

--- Update light inensity
---@param id number light reference returned from LightSpawner_Spawn function
---@param intensity number Intensity value (normally between 0 and 1)
---@return number The original light reference upon success, or nil on failure (light reference unknown)
function LightSpawner_UpdateLightIntensity(id, intensity)
    if LightSpawner_Lights[id] ~= nil then
        if LightSpawner_Lights[id]["fadedelete"] == false then
            local light_instance = LightSpawner_Lights[id]
            light_instance["intensity"] = intensity
            SetLightIntensity(light_instance["light"], intensity)
            return id
        end
        return nil
    end
    return nil
end

--- Force Update light intensity (ignores if it is supposed to fade out!)
---@param id number light reference returned from LightSpawner_Spawn function
---@param intensity number Intensity value (normally between 0 and 1)
---@return number The original light reference upon success, or nil on failure (light reference unknown)
function LightSpawner_ForceUpdateLightIntensity(id, intensity)
    if LightSpawner_Lights[id] ~= nil then
        local light_instance = LightSpawner_Lights[id]
        light_instance["intensity"] = intensity
        SetLightIntensity(light_instance["light"], intensity)
        return id
    end
    return nil
end

--- Enable/Disable light
---@param id number light reference returned from LightSpawner_Spawn function
---@param enable boolean Enable or disable light
---@return number The original light reference upon success, or nil on failure (light reference unknown)
function LightSpawner_UpdateLightEnabled(id, enable)
    if LightSpawner_Lights[id] ~= nil then
        local light_instance = LightSpawner_Lights[id]
        light_instance["enabled"] = enable
        SetLightEnabled(light_instance["light"], enable)
        return id
    end
    return nil
end


--- Update light location
---@param id number light reference returned from LightSpawner_Spawn function
---@param location Vec Location of the light source.
---@return number The original light reference if no update has happend, updated light reference if changed or nil on failure (light reference unknown)
function LightSpawner_SetNewLightLocation(id, location)
    if LightSpawner_Lights[id] ~= nil then
        local light_instance = LightSpawner_Lights[id]
        if LightSpawner_VecCompare(light_instance["location"], location) == false then
            light_instance["location"] = location
            if light_instance["animating"] == false then
                LightSpawner_ReplaceSpawn(id)
            end
        end
        return id
    end
    return nil
end

--- Update light location
---@param id number light reference returned from LightSpawner_Spawn function
---@param location Vec Location of the light source.
---@return number The original light reference if no update has happend, updated light reference if changed or nil on failure (light reference unknown)
function LightSpawner_ForceSetNewLightLocation(id, location)
    if LightSpawner_Lights[id] ~= nil then
        local light_instance = LightSpawner_Lights[id]
        if LightSpawner_VecCompare(light_instance["location"], location) == false then
            light_instance["location"] = location
            LightSpawner_ReplaceSpawn(id)
        end
        return id
    end
    return nil
end


--- Update light size
---@param id number light reference returned from LightSpawner_Spawn function
---@param size number size of the light source.
---@return number The original light reference if no update has happend, updated light reference if changed or nil on failure (light reference unknown)
function LightSpawner_SetNewLightSize(id, size)
    if LightSpawner_Lights[id] ~= nil then
        local light_instance = LightSpawner_Lights[id]
        if light_instance["size"] ~= size then
            light_instance["size"] = size
            LightSpawner_ReplaceSpawn(id)
        end
        return id
    end
    return nil
end

---Get light location by light reference
---@param id number light reference returned from LightSpawner_Spawn function
---@return Vec location = unreferenced vec or nil upon failure (light might not exist)
function LightSpawner_GetLightLocation(id)
    if LightSpawner_Lights[id] ~= nil then
        local light_instance = LightSpawner_Lights[id]
        return LightSpawner_deepCopy(light_instance["location"])
    end
    return nil
end

---Get light intensity by light reference
---@param id number light reference returned from LightSpawner_Spawn function
---@return number intensity = unreferenced number or nil upon failure (light might not exist)
function LightSpawner_GetLightIntensity(id)
    if LightSpawner_Lights[id] ~= nil then
        local light_instance = LightSpawner_Lights[id]
        return LightSpawner_deepCopy(light_instance["intensity"])
    end
    return nil
end

---Get light size by light reference
---@param id number light reference returned from LightSpawner_Spawn function
---@return number size unreferenced number or nil upon failure (light might not exist)
function LightSpawner_GetLightSize(id)
    if LightSpawner_Lights[id] ~= nil then
        local light_instance = LightSpawner_Lights[id]
        return LightSpawner_deepCopy(light_instance["size"])
    end
    return nil
end

---Get light color by light reference
---@param id number light reference returned from LightSpawner_Spawn function
---@return Vec color  unreferenced vec or nil upon failure (light might not exist)
function LightSpawner_GetLightColor(id)
    if LightSpawner_Lights[id] ~= nil then
        local light_instance = LightSpawner_Lights[id]
        return LightSpawner_deepCopy(light_instance["color"])
    end
    return nil
end

---Get light entity compatible with teadown functions
---@param id number light reference returned from LightSpawner_Spawn function
---@return light number unreferenced number or nil upon failure (light might not exist)
function LightSpawner_GetTeardownLightEntity(id)
    if LightSpawner_Lights[id] ~= nil then
        local light_instance = LightSpawner_Lights[id]
        return LightSpawner_deepCopy(light_instance["light"])
    end
    return nil
end