-- lightspwaner.lua
-- @date 2022-02-26
-- @author Eldin Zenderink
-- @brief Spawn FPS friendly lights using spawning of light points (instead of spotlight), side effect it looks a bit worse than spotlights (affects global illumination less), but faster and better than none ;P.


-- List to keep track of light instance
LightSpawner_Lights = {}

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


---Spawns a new light point.
---@param location Vec location of the light point
---@param size number size of the light
---@param intensity number intensity of the light
---@param color Vec color of the light (can be RGB 0-255 values!)
---@param enabled boolean if the light should emit or not (can be toggled)
---@return number light reference compatible with Teardown functions such as SetLightColor, SetLightIntensity, SetLightEnabled, also used as reference for LightSpawner, remember them!
function LightSpawner_Spawn(location, size, intensity, color, enabled)
    local light_instance = {
        location=location,
        size=size,
        color=color,
        intensity=intensity,
        enabled=enabled,
        entity=nil,
        light=nil
    }

    if color[1] > 1 or color[2] > 1 or color[3] > 1 then
        color = LightSpawner_RGBConv(color[1], color[2], color[3])
    end

    light_instance["entity"] = Spawn("<light name='light' tags='ls_light' color='1.0 1.0 1.0' scale='" .. tostring(size / 10) .. "' size='" ..  tostring(size / 100) .. "'/>", Transform(location))

    local lights = FindLights("ls_light", true)
    for i=1, #lights do
        local light = lights[i]
        if LightSpawner_Lights[light] == nil then
            light_instance[light] = light_instance
            light_instance[light]["light"] = LightSpawner_deepCopy(light)
            LightSpawner_Lights[light] = light_instance

            SetLightColor(light, color[1], color[2], color[3])
            SetLightIntensity(light, intensity)
            SetLightEnabled(light, enabled)
            return light
        end
    end
    return nil
end

--- Delete all lights spawned
--- @note Make sure if you store light handles locally to remove those as well!
function LightSpawner_DeleteAll()
    for light, instance in pairs(LightSpawner_Lights) do
        LightSpawner_DeleteLight(light)
    end
end

--- Delete a specific light (disables and removes light, then removes spawned entity)
---@param light number light reference returned from LightSpawner_Spawn function or updated by LightSpawner_SetNewLightLocation or LightSpawner_SetNewLightSize.
---@return boolean -- Succeed or failed  (true or false) (failure could mean that the light reference has already been deleted once!)
function LightSpawner_DeleteLight(light)
    if LightSpawner_Lights[light] ~= nil then
        local light_instance = LightSpawner_Lights[light]
        SetLightEnabled(light, false)
        Delete(light)
        Delete(light_instance["entity"])
        LightSpawner_Lights[light] = nil
        return true
    else
        return false
    end
end

--- Update light color.
---@param light number light reference returned from LightSpawner_Spawn function or updated by LightSpawner_SetNewLightLocation or LightSpawner_SetNewLightSize.
---@param color Vec color of the light (can be RGB 0-255 values!)
---@return number The original light reference upon success, or nil on failure (light reference unknown)
function LightSpawner_UpdateLightColor(light, color)
    if color[1] > 1 or color[2] > 1 or color[3] > 1 then
        color = LightSpawner_RGBConv(color[1], color[2], color[3])
    end
    if LightSpawner_Lights[light] ~= nil then
        local light_instance = LightSpawner_Lights[light]
        light_instance["color"] = color
        SetLightColor(light_instance["light"], light_instance["color"][1], light_instance["color"][2], light_instance["color"][3])
        return light
    end
    return nil
end

--- Update light inensity
---@param light number light reference returned from LightSpawner_Spawn function or updated by LightSpawner_SetNewLightLocation or LightSpawner_SetNewLightSize.
---@param intensity number Intensity value (normally between 0 and 1)
---@return number The original light reference upon success, or nil on failure (light reference unknown)
function LightSpawner_UpdateLightIntensity(light, intensity)
    if LightSpawner_Lights[light] ~= nil then
        local light_instance = LightSpawner_Lights[light]
        light_instance["intensity"] = intensity
        SetLightIntensity(light, intensity)
        return light
    end
    return nil
end


--- Update light location
---@note Returns a NEW reference to the updated light (internally spawns a new light)
---@param light number light reference returned from LightSpawner_Spawn function or updated by LightSpawner_SetNewLightLocation or LightSpawner_SetNewLightSize.
---@param location Vec Location of the light source.
---@return number The original light reference if no update has happend, updated light reference if changed or nil on failure (light reference unknown)
function LightSpawner_SetNewLightLocation(light, location)
    if LightSpawner_Lights[light] ~= nil then
        local light_instance = LightSpawner_Lights[light]
        if LightSpawner_VecCompare(light_instance["location"], location) == false then
            LightSpawner_DeleteLight(light)
            local new_light_instance = LightSpawner_Spawn(location, light_instance["size"], light_instance["intensity"], light_instance["color"], light_instance["enabled"])
            return new_light_instance
        end
        return light
    end
    return nil
end

--- Update light size
---@note Returns a NEW reference to the updated light (internally spawns a new light)
---@param light number light reference returned from LightSpawner_Spawn function or updated by LightSpawner_SetNewLightLocation or LightSpawner_SetNewLightSize.
---@param size number size of the light source.
---@return number The original light reference if no update has happend, updated light reference if changed or nil on failure (light reference unknown)
function LightSpawner_SetNewLightSize(light, size)
    if LightSpawner_Lights[light] ~= nil then
        local light_instance = LightSpawner_Lights[light]
        if light_instance["size"] ~= size then
            LightSpawner_DeleteLight(light)
            local new_light_instance = LightSpawner_Spawn(light_instance["location"], size, light_instance["intensity"], light_instance["color"], light_instance["enabled"])
            return new_light_instance
        end
        return light
    end
    return nil
end


---Get light location by light reference
---@param light number light reference returned from LightSpawner_Spawn function or updated by LightSpawner_SetNewLightLocation or LightSpawner_SetNewLightSize.
---@return Vec location or nil upon failure (light might not exist)
function LightSpawner_GetLightLocation(light)
    if LightSpawner_Lights[light] ~= nil then
        local light_instance = LightSpawner_Lights[light]
        return LightSpawner_deepCopy(light_instance["location"])
    end
    return nil
end

---Get light intensity by light reference
---@param light number light reference returned from LightSpawner_Spawn function or updated by LightSpawner_SetNewLightLocation or LightSpawner_SetNewLightSize.
---@return number intensity or nil upon failure (light might not exist)
function LightSpawner_GetLightIntensity(light)
    if LightSpawner_Lights[light] ~= nil then
        local light_instance = LightSpawner_Lights[light]
        return LightSpawner_deepCopy(light_instance["intensity"])
    end
    return nil
end

---Get light size by light reference
---@param light number light reference returned from LightSpawner_Spawn function or updated by LightSpawner_SetNewLightLocation or LightSpawner_SetNewLightSize.
---@return number size or nil upon failure (light might not exist)
function LightSpawner_GetLightSize(light)
    if LightSpawner_Lights[light] ~= nil then
        local light_instance = LightSpawner_Lights[light]
        return LightSpawner_deepCopy(light_instance["size"])
    end
    return nil
end

---Get light color by light reference
---@param light number light reference returned from LightSpawner_Spawn function or updated by LightSpawner_SetNewLightLocation or LightSpawner_SetNewLightSize.
---@return Vec color or nil upon failure (light might not exist)
function LightSpawner_GetLightColor(light)
    if LightSpawner_Lights[light] ~= nil then
        local light_instance = LightSpawner_Lights[light]
        return LightSpawner_deepCopy(light_instance["color"])
    end
    return nil
end