local FireDetector_Default = {
    max_fire_spread_distance=6,
    fire_reaction_time=2,
    min_fire_distance=2,
    max_group_fire_distance=4,
    max_fire=150,
    fire_intensity="ON",
    fire_intensity_multiplier=1,
    fire_intensity_minimum=1,
    visualize_fire_detection="OFF",
    fire_explosion = "NO",
    fire_damage = "YES",
    spawn_fire = "YES",
    fire_damage_soft = 0.1,
    fire_damage_medium = 0.05,
    fire_damage_hard = 0.01,
    teardown_max_fires = 500,
    teardown_fire_spread = 2,
    material_allowed = {
        wood = true,
        foliage = true,
        plaster = true,
        plastic = true,
        masonery = true,
    }
}

local FireDetector_Properties = {
    max_fire_spread_distance=6,
    fire_reaction_time=2,
    min_fire_distance=2,
    max_group_fire_distance=4,
    max_fire=150,
    fire_intensity="ON",
    fire_intensity_multiplier=10,
    fire_intensity_minimum=1,
    visualize_fire_detection="OFF",
    fire_explosion = "NO",
    fire_damage = "YES",
    spawn_fire = "YES",
    fire_damage_soft = 0.1,
    fire_damage_medium = 0.05,
    fire_damage_hard = 0.01,
    teardown_max_fires = 500,
    teardown_fire_spread = 2,
    material_allowed = {
        wood = true,
        foliage = true,
        plaster = true,
        plastic = true,
        masonery = true,
    }
}

--- Some global properties
local FireDetector_LocalDB = {
    time_elapsed = 0,
    fire_count=0,
    fire_intensity=0
}

-- Store all shapes that could potentially be detached from shapes on fire (BPOF = shapes potentially on fire)
local FireDetector_SPOF = {}



local FireDetector_OptionsDetection =
{
	storage_module="firedetector",
	storage_prefix_key=nil,
    buttons={
		{
			text = "Set Default",
			callback=function() FireDetector_DefaultSettings() end,
		},
    },
	update=function() FireDetector_ApplyCustomSettings() end,
	option_items={
        {
            option_parent_text="",
            option_text="Max Box Size Fire Count",
            option_note="The max distance between fires that could be connected to the same fire.",
            option_type="float",
            storage_key="max_group_fire_distance",
            min_max={0.1, 5, 0.1}
        },
        {
            option_parent_text="",
            option_text="Min Distance Between Fires",
            option_note="Distance changes on fire detection radius.",
            option_type="float",
            storage_key="min_fire_distance",
            min_max={0.1, 5, 0.1}
        },
	}
}

local FireDetector_OptionsFireBehavior =
{
	storage_module="firedetector",
	storage_prefix_key=nil,
    buttons={
		{
			text = "Set Default",
			callback=function() FireDetector_DefaultSettings() end,
		},
    },
	update=function() FireDetector_ApplyCustomSettings() end,
	option_items={
        {
            option_parent_text="",
            option_text="Max Fires",
            option_note="How many fires may be detected at once.",
            option_type="int",
            storage_key="max_fire",
            min_max={1, 1000}
        },
        {
            option_parent_text="",
            option_text="Trigger Fire Reaction Time",
            option_note="Will trigger fire damage and spreading after x seconds (note the smaller the harder it is to extinguish)",
            option_type="int",
            storage_key="fire_reaction_time",
            min_max={1, 20}
        },
        {
            option_parent_text="",
            option_text="Max fire spread distance",
            option_note="How far at max intensity a fire can spread.",
            option_type="int",
            storage_key="max_fire_spread_distance",
            min_max={1, 20}
        },
        {
            option_parent_text="",
            option_text="Explosive Fire",
            option_note="Triggers explosion based on fire intensity, for fun (currently not extinguishable).",
            option_type="text",
			storage_key="fire_explosion",
			options={
				"YES",
				"NO"
			}
        },
        {
            option_parent_text="",
            option_text="Fire Damage",
            option_note="Creates holes based on fire intensity, simulating fire damage (currently not extinguishable).",
            option_type="text",
			storage_key="fire_damage",
			options={
				"YES",
				"NO"
			}
        },
        {
            option_parent_text="",
            option_text="Spawn Fire",
            option_note="Spawnes additional (not particle) fire to the existing fire (currently not extinguishable)",
            option_type="text",
			storage_key="spawn_fire",
			options={
				"YES",
				"NO"
			}
        },
        {
            option_parent_text="",
            option_text="Fire Damage Soft",
            option_note="The damage radius on soft materials (only if Fire Damage is enabled).",
            option_type="float",
            storage_key="fire_damage_soft",
            min_max={0.01, 5, 0.01}
        },
        {
            option_parent_text="",
            option_text="Fire Damage Medium",
            option_note="The damage radius on materials between soft and hard (must be lower than soft) (only if Fire Damage is enabled).",
            option_type="float",
            storage_key="fire_damage_medium",
            min_max={0.01, 3, 0.01}
        },
        {
            option_parent_text="",
            option_text="Fire Damage Hard",
            option_note="The damage radius hard materials (must be lower than medium) (only if Fire Damage is enabled) .",
            option_type="float",
            storage_key="fire_damage_hard",
            min_max={0.01, 1, 0.01}
        },
        {
            option_parent_text="",
            option_text="Teardown Max Fire",
            option_note="Set the max fires of non mod related fires (from teardown) that can spawn.",
            option_type="int",
            storage_key="teardown_max_fires",
            min_max={1, 10000}
        },
        {
            option_parent_text="",
            option_text="Teardown Fire Spread",
            option_note="Set the max fire spread of non mod related fire from teardown.",
            option_type="int",
            storage_key="teardown_fire_spread",
            min_max={1, 10}
        },
	}
}

local FireDetector_OptionsFireIntensity =
{
	storage_module="firedetector",
	storage_prefix_key=nil,
    buttons={
		{
			text = "Set Default",
			callback=function() FireDetector_DefaultSettings() end,
		},
    },
	update=function() FireDetector_ApplyCustomSettings() end,
	option_items={
		{
			option_parent_text="",
			option_text="Detect Fire Intensity",
			option_note="Detects how big a fire potentially to adjust particle size",
            option_type="text",
			storage_key="fire_intensity",
			options={
				"ON",
				"OFF"
			}
		},
        {
            option_parent_text="",
            option_text="Fire Intensity Multiplier",
            option_note="If fires aren't getting big enough fast enough..",
            option_type="int",
            storage_key="fire_intensity_multiplier",
            min_max={1, 100}
        },
        {
            option_parent_text="",
            option_text="Fire Intensity Minimum (%)",
            option_note="The minimum size fires there should be.",
            option_type="int",
            storage_key="fire_intensity_minimum",
            min_max={1, 100}
        },
	}
}


local FireDetector_OptionsDebugging =
{
	storage_module="firedetector",
	storage_prefix_key=nil,
    buttons={
		{
			text = "Set Default",
			callback=function() FireDetector_DefaultSettings() end,
		},
    },
	update=function() FireDetector_ApplyCustomSettings() end,
	option_items={
		{
			option_parent_text="",
			option_text="Visualize fire detection",
			option_note="Shows a cross where the mod thinks there is fire and where it spawns a particle",
            option_type="text",
			storage_key="visualize_fire_detection",
			options={
				"ON",
				"OFF"
			}
		}
	}
}


function Particle_DefaultPresetSettings()
    FireDetector_DefaultSettings()
end


---Initialize the properties of the module
---@param default bool -- set to true to set all properties to their default configured values
function FireDetector_Init(default)
	if default then
		FireDetector_DefaultSettings()
	else
		FireDetector_UpdateSettingsFromStorage()
	end
    FireDetector_LocalDB["time_elapsed"] = 0
    FireDetector_LocalDB["time_input_disabled_elapsed"] = 0
    FireDetector_LocalDB["fire_count"] = 0
end

---Provide a table to build a option menu for this module
---@return table
function FireDetector_GetOptionsMenu()
    return {
        menu_title = "Fire Detection Settings",
        sub_menus={
            {
                sub_menu_title="Detection",
                options=FireDetector_OptionsDetection,
            },
            {
                sub_menu_title="Fire Behavior",
                options=FireDetector_OptionsFireBehavior,
            },
            {
                sub_menu_title="Fire Intensity",
                options=FireDetector_OptionsFireIntensity,
            },
            {
                sub_menu_title="Debugging",
                options=FireDetector_OptionsDebugging,
            }
        }
    }
end



---Retrieve properties from storage and apply them
function FireDetector_ApplyCustomSettings()
    FireDetector_UpdateSettingsFromStorage()
end


---Store and apply default properties.
function FireDetector_DefaultSettings()
	Storage_SetInt("firedetector", "fire_reaction_time", FireDetector_Default["fire_reaction_time"])
	Storage_SetInt("firedetector", "max_fire_spread_distance", FireDetector_Default["max_fire_spread_distance"])
    Storage_SetInt("firedetector", "max_fire", FireDetector_Default["max_fire"])
    Storage_SetString("firedetector", "visualize_fire_detection", FireDetector_Default["visualize_fire_detection"])
    Storage_SetFloat("firedetector", "min_fire_distance", FireDetector_Default["min_fire_distance"])
    Storage_SetFloat("firedetector", "max_group_fire_distance", FireDetector_Default["max_group_fire_distance"])
    Storage_SetString("firedetector", "fire_intensity", FireDetector_Default["fire_intensity"])
    Storage_SetInt("firedetector", "fire_intensity_multiplier", FireDetector_Default["fire_intensity_multiplier"])
    Storage_SetInt("firedetector", "fire_intensity_minimum", FireDetector_Default["fire_intensity_minimum"])
    Storage_SetString("firedetector", "fire_explosion", FireDetector_Default["fire_explosion"])
    Storage_SetString("firedetector", "fire_damage", FireDetector_Default["fire_damage"])
    Storage_SetString("firedetector", "spawn_fire", FireDetector_Default["spawn_fire"])
    Storage_SetFloat("firedetector", "fire_damage_soft", FireDetector_Default["fire_damage_soft"])
    Storage_SetFloat("firedetector", "fire_damage_medium", FireDetector_Default["fire_damage_medium"])
    Storage_SetFloat("firedetector", "fire_damage_hard", FireDetector_Default["fire_damage_hard"])
    Storage_SetInt("firedetector", "teardown_max_fires", FireDetector_Default["teardown_max_fires"])
    Storage_SetInt("firedetector", "teardown_fire_spread", FireDetector_Default["teardown_fire_spread"])
    FireDetector_UpdateSettingsFromStorage()
end

---Retrieve properties from storage and apply them
function FireDetector_UpdateSettingsFromStorage()
    FireDetector_Properties["fire_reaction_time"] = Storage_GetInt("firedetector", "fire_reaction_time")
    FireDetector_Properties["max_fire_spread_distance"] = Storage_GetInt("firedetector", "max_fire_spread_distance")
    FireDetector_Properties["max_fire"] = Storage_GetInt("firedetector", "max_fire")
    FireDetector_Properties["min_fire_distance"] = Storage_GetFloat("firedetector", "min_fire_distance")
    FireDetector_Properties["max_group_fire_distance"] = Storage_GetFloat("firedetector", "max_group_fire_distance")
    FireDetector_Properties["visualize_fire_detection"] = Storage_GetString("firedetector", "visualize_fire_detection")
    FireDetector_Properties["fire_intensity"] = Storage_GetString("firedetector", "fire_intensity")
    FireDetector_Properties["fire_intensity_multiplier"] = Storage_GetInt("firedetector", "fire_intensity_multiplier")
    FireDetector_Properties["fire_intensity_minimum"] = Storage_GetInt("firedetector", "fire_intensity_minimum")
    FireDetector_Properties["fire_explosion"] = Storage_GetString("firedetector", "fire_explosion")
    FireDetector_Properties["fire_damage"] = Storage_GetString("firedetector", "fire_damage")
    FireDetector_Properties["spawn_fire"] = Storage_GetString("firedetector", "spawn_fire")
    FireDetector_Properties["fire_damage_soft"] = Storage_GetFloat("firedetector", "fire_damage_soft")
    FireDetector_Properties["fire_damage_medium"] = Storage_GetFloat("firedetector", "fire_damage_medium")
    FireDetector_Properties["fire_damage_hard"] = Storage_GetFloat("firedetector", "fire_damage_hard")
    FireDetector_Properties["teardown_max_fires"] = Storage_GetInt("firedetector", "teardown_max_fires")
    FireDetector_Properties["teardown_fire_spread"] = Storage_GetInt("firedetector", "teardown_fire_spread")
    SetInt("game.fire.maxcount",  FireDetector_Properties["teardown_max_fires"])
    SetInt("game.fire.spread",  FireDetector_Properties["teardown_fire_spread"])

end




---Draw a point if visualize fire detection is turned on
---@param point Vec (array of 3 values) containing the position to draw the point
---@param r float intensity of the color red
---@param g float intensity of the color green
---@param b float intensity of the color blue
function FireDetector_DrawPoint(point, r, g, b)
    if FireDetector_Properties["visualize_fire_detection"] == "ON" then
        DebugCross(point,  r, g, b)
    end
end


---Draw a line between two points if visualize fire detection is turned on
---@param vec1 Vec (array of 3 values) containing the position to draw the point
---@param vec2 Vec (array of 3 values) containing the position to draw the point
---@param r float intensity of the color red
---@param g float intensity of the color green
---@param b float intensity of the color blue
function FireDetector_DrawLine(vec1, vec2, r, g, b)
    if FireDetector_Properties["visualize_fire_detection"] == "ON" then
        DebugLine(vec1, vec2, r, g, b)
    end
end

---Calculate distance between two 3D vectors
---@param vec1 Vec (array of 3 values) containing the position
---@param vec2 Vec (array of 3 values) containing the position
---@return number value of the distance
function FireDetector_VecDistance(vec1, vec2)
    return VecLength(VecSub(vec1, vec2))
end


function FireDetector_CreateBox(point, size, point2, color, draw)
    local p1 = {point[1] - size, point[2] - size, point[3] - size}
    local p2 = {point[1] - size, point[2] + size, point[3] - size}
    local p3 = {point[1] - size, point[2] + size, point[3] + size}
    local p4 = {point[1] - size, point[2] - size, point[3] + size}

    local p5 = {point[1] + size, point[2] - size, point[3] - size}
    local p6 = {point[1] + size, point[2] + size, point[3] - size}
    local p7 = {point[1] + size, point[2] + size, point[3] + size}
    local p8 = {point[1] + size, point[2] - size, point[3] + size}

    if draw then
        FireDetector_DrawLine(p1, p2, color[1], color[2], color[3])
        FireDetector_DrawLine(p2, p3, color[1], color[2], color[3])
        FireDetector_DrawLine(p3, p4, color[1], color[2], color[3])
        FireDetector_DrawLine(p4, p1, color[1], color[2], color[3])


        FireDetector_DrawLine(p5, p6, color[1], color[2], color[3])
        FireDetector_DrawLine(p6, p7, color[1], color[2], color[3])
        FireDetector_DrawLine(p7, p8, color[1], color[2], color[3])
        FireDetector_DrawLine(p8, p5, color[1], color[2], color[3])


        FireDetector_DrawLine(p1, p5, color[1], color[2], color[3])
        FireDetector_DrawLine(p2, p6, color[1], color[2], color[3])
        FireDetector_DrawLine(p3, p7, color[1], color[2], color[3])
        FireDetector_DrawLine(p4, p8, color[1], color[2], color[3])
    end

    if point2 ~= nil then

        local u = VecSub(p5, p1)
        local v = VecSub(p5, p6)
        local w = VecSub(p5, p8)

        local ud = VecDot(u, point2)
        local vd = VecDot(v, point2)
        local wd = VecDot(w, point2)

        local u1 = VecDot(u, p5)
        local u2 = VecDot(u, p1)

        local v1 = VecDot(v, p5)
        local v2 = VecDot(v, p6)

        local w1 = VecDot(w, p5)
        local w2 = VecDot(w, p8)

        if  (ud > u2 and ud < u1) and (vd > v2 and vd < v1) and (wd > w2 and wd < w1) then


            FireDetector_DrawPoint(point2, 1,0,0)
            return true
        else
            FireDetector_DrawPoint(point2, 0,1,0)
            -- FireDetector_DrawPoint(point2, 1,0,0)
            return false
        end
    else
        return {p1,p2,p3,p4,p5,p6,p7,p8}
    end
end

function FireDetection_DrawDetectedFire(fire)
    FireDetector_CreateBox(fire[3], fire[4], nil, {0, fire[2] * 0.01, 0}, true)
    FireDetector_DrawPoint(fire[3], 1,0,0)
    FireDetector_DrawPoint(fire[1], 0,0,1)
end

function FireDetector_FindFireLocationsV2(time, refresh)
    local fire_damage = FireDetector_Properties["fire_damage"]
    local fire_damage_soft = FireDetector_Properties["fire_damage_soft"] / 100 -- take procentile to multiply times intensity
    local fire_damage_medium = FireDetector_Properties["fire_damage_medium"] / 100 -- take procentile to multiply times intensity
    local fire_damage_hard = FireDetector_Properties["fire_damage_hard"] / 100 -- take procentile to multiply times intensity
    local fire_explosion = FireDetector_Properties["fire_explosion"]
    local spawn_fire = FireDetector_Properties["spawn_fire"]
    local fire_intensity_enabled = FireDetector_Properties["fire_intensity"]
    local fire_reaction_time = FireDetector_Properties["fire_reaction_time"]
    local max_fire_spread_distance = FireDetector_Properties["max_fire_spread_distance"] / 100 -- take procentile to multiply times intensity
    local material_allowed = FireDetector_Properties["material_allowed"]

    local time_elapsed =  FireDetector_LocalDB["time_elapsed"]

    local fires = {}
    local max_intensity = 0
    if refresh then
        local max_fires = FireDetector_Properties["max_fire"]
        local min_fire_distance = FireDetector_Properties["min_fire_distance"]
        local max_group_fire_distance = FireDetector_Properties["max_group_fire_distance"]
        local fire_intensity_multiplier = FireDetector_Properties["fire_intensity_multiplier"]
        local min_fire_intensity = FireDetector_Properties["fire_intensity_minimum"]


        -- Perform fire spread, damage/explosion after timeouts
        if time_elapsed > fire_reaction_time then
            for i=1, #FireDetector_SPOF do
                local fire = FireDetector_SPOF[i]

                local intensity = fire["fire_intensity"]
                if fire_explosion == "YES" then
                    Explosion(fire["location"], (4 / 100) * fire["fire_intensity"])
                end
                if fire_damage == "YES" then
                    MakeHole(fire["location"], fire_damage_soft * intensity, fire_damage_medium * intensity, fire_damage_hard * intensity)
                end
                if spawn_fire == "YES" then
                    QueryRejectShape(fire["shape"])
                    local direction = Generic_rndVec(1)
                    local hit, dist = QueryRaycast(fire["location"], direction, max_fire_spread_distance * intensity)
                    if hit then
                        local newpoint = VecAdd(fire["location"], VecScale(direction, dist))
                        SpawnFire(newpoint)
                    end
                end
            end
            time_elapsed = 0
        end

        -- Search fire locations, onfire = lists with actual fires
        local onfire = {}
        FireDetector_RecursiveBinarySearchFire({0,0,0}, 409.6, max_group_fire_distance, min_fire_distance , max_fires, onfire, 1)

        -- Parse all fires
        for i=1, #onfire do
            local intensity = onfire[i][2] * fire_intensity_multiplier

            if intensity > 100 or fire_intensity_enabled == false then
                intensity = 100
            elseif intensity < min_fire_intensity then
                intensity = min_fire_intensity
            end

            local hit, point, normal, shape_hit = QueryClosestPoint(onfire[i][1], min_fire_distance)
            if hit then
                local shape_mat = GetShapeMaterialAtPosition(shape_hit, point)
                if material_allowed[shape_mat] then
                    fires[#fires+1] = {location=point, material=shape_mat, fire_intensity=intensity, shape=shape_hit, original=onfire[i]}
                    if max_intensity < intensity then
                        max_intensity = intensity
                    end
                    FireDetection_DrawDetectedFire(onfire[i])
                end
            end
        end

        FireDetector_LocalDB["fire_intensity"] = max_intensity
        FireDetector_LocalDB["fire_count"] = #fires
    else
        -- Return previously detected fires
        fires = FireDetector_SPOF
        for i=1, #fires do
            local fire = fires[i]
            FireDetector_DrawPoint(fire["location"], 1,1,0)
            if max_intensity < fire["fire_intensity"] then
                max_intensity = fire["fire_intensity"]
            end
            if max_intensity < fire["fire_intensity"] then
                max_intensity = fire["fire_intensity"]
            end
            FireDetection_DrawDetectedFire(fire["original"])

        end
        FireDetector_LocalDB["fire_intensity"] = max_intensity
        FireDetector_LocalDB["fire_count"] = #fires
    end

    FireDetector_LocalDB["time_elapsed"] = time_elapsed + time
    FireDetector_SPOF = fires
    return fires
end

function FireDetector_VecMidPoint(vec1, vec2)
    -- return {vec1[1]+vec2[1]/2, vec1[2]+vec2[2]/2, vec1[3]+vec2[3]/2}
    return VecLerp(vec1, vec2, 0.5)
end

--- Determine fire locations by recursively searching for fires in bounding boxes. Thanks to @Thomasims on the official Teardown discord for additional help and input.
---@param vecstart Location to start searching from
---@param size Size of the bounding box
---@param size_fire_count Size of the bouding box minimum, if reached it will count all the fires in that bounding box.
---@param min_size any Minimum size before it should stop searching
---@param max_fires any Maximum fires it can detected before it stops searching
---@param onfire any The list with fires detected.
---@param intensity any The intensity, calculated until size_fire_count is  reached and passed along till min_size is reached.
function FireDetector_RecursiveBinarySearchFire(vecstart, size, size_fire_count, min_size, max_fires, onfire, intensity)

    -- Draw bounding box
    local outerpoints = FireDetector_CreateBox(vecstart, size, nil, {1, 0, 0}, false)
    local firecount = QueryAabbFireCount(outerpoints[1], outerpoints[7])
    if firecount == 0 or #onfire >= max_fires then
        return
    end


    if size < min_size and max_fires > #onfire then
        if min_size > 0.1 then
            local hit, pos = QueryClosestFire(FireDetector_VecMidPoint(outerpoints[1], FireDetector_VecMidPoint(outerpoints[1], outerpoints[7])), size )
            if hit then
                onfire[#onfire + 1] = {pos, intensity, vecstart, size}
            end
        else
            FireDetector_CreateBox(vecstart, size, nil, {intensity * 0.01, 0, 0}, true)
            onfire[#onfire + 1] = {vecstart, intensity, vecstart, size}
            FireDetector_DrawPoint(vecstart, 1,0,0)
        end
        return
    end

    if size >= size_fire_count then
        intensity = firecount
    elseif size_fire_count < min_size and min_size > size_fire_count then
        intensity = firecount
    end

    -- Calculate 4 boxes inside bounding b

-- if QueryAabbFireCount(outerpoints[1], outerpoints[7]) > 0 then
    midpoint = FireDetector_VecMidPoint(outerpoints[1], FireDetector_VecMidPoint(outerpoints[1], outerpoints[7]))
    -- FireDetector_CreateBox(midpoint, size / 2, nil, {1, 0, 0}, false)
    FireDetector_RecursiveBinarySearchFire(midpoint, size / 2,  size_fire_count, min_size, max_fires, onfire, intensity)
    midpoint = FireDetector_VecMidPoint(outerpoints[2], FireDetector_VecMidPoint(outerpoints[2], outerpoints[8]))
    -- FireDetector_CreateBox(midpoint, size / 2, nil, {1, 0, 0}, false)
    FireDetector_RecursiveBinarySearchFire(midpoint, size / 2,  size_fire_count, min_size, max_fires, onfire, intensity)

    midpoint = FireDetector_VecMidPoint(outerpoints[3], FireDetector_VecMidPoint(outerpoints[3], outerpoints[5]))
    -- FireDetector_CreateBox(midpoint, size / 2, nil, {1, 0, 0}, false)
    FireDetector_RecursiveBinarySearchFire(midpoint, size / 2,  size_fire_count, min_size, max_fires, onfire, intensity)

    midpoint = FireDetector_VecMidPoint(outerpoints[4], FireDetector_VecMidPoint(outerpoints[4], outerpoints[6]))
    -- FireDetector_CreateBox(midpoint, size / 2, nil, {1, 0, 0}, false)
    FireDetector_RecursiveBinarySearchFire(midpoint, size / 2,  size_fire_count, min_size, max_fires, onfire, intensity)

    midpoint = FireDetector_VecMidPoint(outerpoints[5], FireDetector_VecMidPoint(outerpoints[5], outerpoints[3]))
    -- FireDetector_CreateBox(midpoint, size / 2, nil, {1, 0, 0}, false)
    FireDetector_RecursiveBinarySearchFire(midpoint, size / 2,  size_fire_count, min_size, max_fires, onfire, intensity)

    midpoint = FireDetector_VecMidPoint(outerpoints[6], FireDetector_VecMidPoint(outerpoints[6], outerpoints[4]))
    -- FireDetector_CreateBox(midpoint, size / 2, nil, {1, 0, 0}, false)
    FireDetector_RecursiveBinarySearchFire(midpoint, size / 2,  size_fire_count, min_size, max_fires, onfire, intensity)

    midpoint = FireDetector_VecMidPoint(outerpoints[7], FireDetector_VecMidPoint(outerpoints[7], outerpoints[1]))
    -- FireDetector_CreateBox(midpoint, size / 2, nil, {1, 0, 0}, false)
    FireDetector_RecursiveBinarySearchFire(midpoint, size / 2,  size_fire_count, min_size, max_fires, onfire, intensity)

    midpoint = FireDetector_VecMidPoint(outerpoints[8], FireDetector_VecMidPoint(outerpoints[8], outerpoints[2]))
    -- FireDetector_CreateBox(midpoint, size / 2, nil, {1, 0, 0}, false)
    FireDetector_RecursiveBinarySearchFire(midpoint, size / 2, size_fire_count, min_size, max_fires, onfire, intensity)



    -- FireDetector_DrawPoint(vecstart, 1,0,1)

end

---Use this in the draw function!
function FireDetector_ShowStatus()
    if GeneralOptions_GetShowUiInGame() == "YES" then

        DebugWatch("FireDetector, Fire count:", FireDetector_LocalDB["fire_count"])
        DebugWatch("FireDetector, time elapsed:", tostring(FireDetector_LocalDB["time_elapsed"]))
        DebugWatch("FireDetector, intensity:", tostring(FireDetector_LocalDB["fire_intensity"]))

    end
end

