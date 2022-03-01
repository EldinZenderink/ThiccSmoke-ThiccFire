FireDetector_Properties = {
    map_size="MEDIUM",
    max_fire_spread_distance=6,
    fire_reaction_time=2,
    fire_update_time=1,
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
    soot_sim = "YES",
    soot_max_size = 2.5,
    soot_min_size = 0.1,
    soot_dithering_max = 1,
    soot_dithering_min = 0.5,
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
FireDetector_LocalDB = {
    time_elapsed = 0,
    fire_count=0,
    fire_intensity=1,
    timer=0,
    random_timer=0
}

-- Store all shapes that could potentially be detached from shapes on fire (BPOF = shapes potentially on fire)
FireDetector_SPOF = {}

-- Courtesy of: https://www.fesliyanstudios.com/royalty-free-sound-effects-download/glass-shattering-and-breaking-124
FireDetector_GlassBreakingSnd = {}

---Initialize the properties of the module
---@param default bool -- set to true to set all properties to their default configured values
function FireDetector_Init()
    Settings_RegisterUpdateSettingsCallback(FireDetector_UpdateSettingsFromSettings)

    for i=1,12 do
        FireDetector_GlassBreakingSnd[i] = LoadSound("MOD/sound/glass/00 - www.fesliyanstudios.com - " .. i .. ".ogg")
    end

end

---Retrieve properties from storage and apply them
function FireDetector_UpdateSettingsFromSettings()
    FireDetector_Properties["map_size"] = Settings_GetValue("FireDetector", "map_size")
    FireDetector_Properties["max_fire_spread_distance"] = Settings_GetValue("FireDetector", "max_fire_spread_distance")
    FireDetector_Properties["fire_reaction_time"] = Settings_GetValue("FireDetector", "fire_reaction_time")
    FireDetector_Properties["fire_update_time"] = Settings_GetValue("FireDetector", "fire_update_time")
    FireDetector_Properties["max_fire"] = Settings_GetValue("FireDetector", "max_fire")
    FireDetector_Properties["min_fire_distance"] = Settings_GetValue("FireDetector", "min_fire_distance")
    FireDetector_Properties["max_group_fire_distance"] = Settings_GetValue("FireDetector", "max_group_fire_distance")
    FireDetector_Properties["visualize_fire_detection"] = Settings_GetValue("FireDetector", "visualize_fire_detection")
    FireDetector_Properties["fire_intensity"] = Settings_GetValue("FireDetector", "fire_intensity")
    FireDetector_Properties["fire_intensity_multiplier"] = Settings_GetValue("FireDetector", "fire_intensity_multiplier")
    FireDetector_Properties["fire_intensity_minimum"] = Settings_GetValue("FireDetector", "fire_intensity_minimum")
    FireDetector_Properties["fire_explosion"] = Settings_GetValue("FireDetector", "fire_explosion")
    FireDetector_Properties["fire_damage"] = Settings_GetValue("FireDetector", "fire_damage")
    FireDetector_Properties["spawn_fire"] = Settings_GetValue("FireDetector", "spawn_fire")
    FireDetector_Properties["soot_sim"] = Settings_GetValue("FireDetector", "soot_sim")
    FireDetector_Properties["soot_dithering_max"] = Settings_GetValue("FireDetector", "soot_dithering_max")
    FireDetector_Properties["soot_dithering_min"] = Settings_GetValue("FireDetector", "soot_dithering_min")
    FireDetector_Properties["soot_max_size"] = Settings_GetValue("FireDetector", "soot_max_size")
    FireDetector_Properties["soot_min_size"] = Settings_GetValue("FireDetector", "soot_min_size")
    FireDetector_Properties["fire_damage_soft"] = Settings_GetValue("FireDetector", "fire_damage_soft")
    FireDetector_Properties["fire_damage_medium"] = Settings_GetValue("FireDetector", "fire_damage_medium")
    FireDetector_Properties["fire_damage_hard"] = Settings_GetValue("FireDetector", "fire_damage_hard")
    FireDetector_Properties["teardown_max_fires"] = Settings_GetValue("FireDetector", "teardown_max_fires")
    FireDetector_Properties["teardown_fire_spread"] = Settings_GetValue("FireDetector", "teardown_fire_spread")
    SetInt("game.fire.maxcount",  math.floor(FireDetector_Properties["teardown_max_fires"]))
    SetInt("game.fire.spread",  math.floor(FireDetector_Properties["teardown_fire_spread"]))

    if FireDetector_Properties["soot_sim"] == nil or FireDetector_Properties["soot_sim"] == "" then
        FireDetector_Properties["soot_sim"] = "NO"
        Settings_SetValue("FireDetector", "soot_sim", "NO")
    end

    if FireDetector_Properties["soot_dithering_max"] == nil or FireDetector_Properties["soot_dithering_max"] == 0 then
        FireDetector_Properties["soot_dithering_max"] = 1
        Settings_SetValue("FireDetector", "soot_dithering_max", 1)
    end
    if FireDetector_Properties["soot_max_size"] == nil or FireDetector_Properties["soot_max_size"] == 0 then
        FireDetector_Properties["soot_max_size"] = 5
        Settings_SetValue("FireDetector", "soot_max_size", 5)
    end
    if FireDetector_Properties["soot_dithering_min"] == nil or FireDetector_Properties["soot_dithering_min"] == 0 then
        FireDetector_Properties["soot_dithering_min"] = 1
        Settings_SetValue("FireDetector", "soot_dithering_min", 1)
    end
    if FireDetector_Properties["soot_min_size"] == nil or FireDetector_Properties["soot_min_size"] == 0 then
        FireDetector_Properties["soot_min_size"] = 5
        Settings_SetValue("FireDetector", "soot_min_size", 5)
    end

    if FireDetector_Properties["map_size"] == nil or FireDetector_Properties["map_size"] == "" then
        FireDetector_Properties["map_size"] = "MEDIUM"
        Settings_SetValue("FireDetector", "map_size", "MEDIUM")
    end
end



function FireDetection_DrawDetectedFire(fire)
    Generic_CreateBox(fire[3], fire[4], nil, {0, fire[2] * 0.01, 0}, true)
    Generic_DrawPoint(fire[3], 1,0,0, true)
    Generic_DrawPoint(fire[1], 0,0,1, true)
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
    local fire_update_time = FireDetector_Properties["fire_update_time"]
    local max_fire_spread_distance = FireDetector_Properties["max_fire_spread_distance"] / 100 -- take procentile to multiply times intensity
    local material_allowed = FireDetector_Properties["material_allowed"]

    local max_fires = FireDetector_Properties["max_fire"]
    local min_fire_distance = FireDetector_Properties["min_fire_distance"] / 50 * FireDetector_LocalDB["fire_intensity"]
    if min_fire_distance < 0.5 then
        min_fire_distance = 0.5
    end
    local max_group_fire_distance = FireDetector_Properties["max_group_fire_distance"]
    local fire_intensity_multiplier = FireDetector_Properties["fire_intensity_multiplier"]
    local min_fire_intensity = FireDetector_Properties["fire_intensity_minimum"]

    local soot_sim = FireDetector_Properties["soot_sim"]
    local soot_dithering_max = FireDetector_Properties["soot_dithering_max"]
    local soot_max_size = FireDetector_Properties["soot_max_size"]
    local soot_dithering_min = FireDetector_Properties["soot_dithering_min"]
    local soot_min_size = FireDetector_Properties["soot_min_size"]

    local time_elapsed =  FireDetector_LocalDB["time_elapsed"]
    local timer = FireDetector_LocalDB["timer"]

    local max_intensity = 0
    local fire_count = 0



    if refresh or fire_count == 0 then

        for hash, fire in pairs(FireDetector_SPOF) do
            fire_count = fire_count + 1
            local intensity = fire["fire_intensity"]
            -- DebugPrint("timer " .. timer .. " timeout " .. fire["timeout"])
            if  timer > fire["timeout"] or fire["delete"] then
                if fire_explosion == "YES" then
                    Explosion(fire["location"], (4 / 100) * fire["fire_intensity"])
                end
                if fire_damage == "YES" then
                    if soot_sim == "YES" then
                        Paint(fire["location"], ((fire_damage_hard + 1)/ 100) * intensity, "explosion", Generic_rnd(soot_dithering_min, soot_dithering_max))
                    end
                    MakeHole(fire["location"], fire_damage_soft * intensity, fire_damage_medium * intensity, fire_damage_hard * intensity, true)
                end

                if spawn_fire == "YES" or fire_damage == "YES" then
                    for x=0, intensity / 2  do
                        local direction = Generic_rndVec(1)
                        local hit, dist,n,s = QueryRaycast(fire["location"], direction, max_fire_spread_distance * intensity + fire_damage_soft * intensity)
                        if hit then
                            local newpoint = VecAdd(fire["location"], VecScale(direction, dist))
                            local shape_mat = GetShapeMaterialAtPosition(s, newpoint)
                            if spawn_fire == "YES" then
                                SpawnFire(newpoint)
                            end
                            if fire_damage == "YES" and shape_mat == "glass" then
                                MakeHole(newpoint, intensity / Generic_rndInt(50, 75), intensity / Generic_rndInt(50, 75), intensity / Generic_rndInt(50, 75), true)
                                PlaySound(FireDetector_GlassBreakingSnd[Generic_rndInt(1,12)], newpoint, intensity / 200)
                            end
                        end
                    end
                end
                if soot_sim == "YES" then
                    local point_start = fire["location"]
                    local randomize = Generic_rndInt(soot_min_size, soot_max_size)
                    for x=0, intensity / 100  do
                        local direction = Vec(Generic_rnd(-0.15, 0.15), 1, Generic_rnd(-0.15, 0.15))
                        local newpoint = VecAdd(point_start, VecScale(direction, intensity / 20  + randomize))
                        local hit, point, normal, shape_hit = QueryClosestPoint(newpoint, randomize)
                        if hit then
                            Generic_DrawLine(point_start, point, 0,1,0,  (FireDetector_Properties["visualize_fire_detection"] == "ON"))
                            Paint(point, (Generic_rnd(soot_min_size, soot_max_size) / 100) * intensity, "explosion", Generic_rnd(soot_dithering_min, soot_dithering_max))
                            if normal[2] < -0.8 then
                                Generic_DrawLine(point_start, point, 1,0,0,  (FireDetector_Properties["visualize_fire_detection"] == "ON"))
                                break
                            else
                                Generic_DrawLine(point_start, point, 0,1,0,  (FireDetector_Properties["visualize_fire_detection"] == "ON"))
                            end
                            point_start = point
                        end
                    end
                end
                FireDetector_SPOF[hash] = nil
            else

                local shape_mat = GetShapeMaterialAtPosition(fire["shape"], fire["location"])
                if shape_mat == "" then
                    local hit, point, normal, shape_hit = QueryClosestPoint(fire["location"], min_fire_distance)
                    if hit then
                        if material_allowed[shape_mat] then
                            SpawnFire(point)
                            if soot_sim == "YES" then
                                Paint(point, (Generic_rnd(soot_min_size, soot_max_size) / 100) * intensity, "explosion", Generic_rnd(soot_dithering_min, soot_dithering_max))
                            end
                        end
                        if fire_damage == "YES" and shape_mat == "glass" then
                            MakeHole(point, intensity / Generic_rndInt(50, 75), intensity / Generic_rndInt(50, 75), intensity / Generic_rndInt(50, 75), true)
                            PlaySound(FireDetector_GlassBreakingSnd[Generic_rndInt(1,12)], point, intensity / 200)
                        end
                    end
                    fire["delete"] = true
                end

                if fire["soot"] == false and soot_sim == "YES" then
                    fire["soot"] = true
                    local point_start = fire["location"]
                    local randomize = Generic_rndInt(soot_min_size, soot_max_size)
                    for x=0, intensity / 100  do
                        local direction = Vec(Generic_rnd(-0.15, 0.15), 1, Generic_rnd(-0.15, 0.15))
                        local newpoint = VecAdd(point_start, VecScale(direction, intensity / 20  + randomize))
                        local hit, point, normal, shape_hit = QueryClosestPoint(newpoint, randomize)
                        if hit then
                            Paint(point, (Generic_rnd(soot_min_size, soot_max_size) / 100) * intensity, "explosion", Generic_rnd(soot_dithering_min, soot_dithering_max))
                            if normal[2] < -0.8 then
                                Generic_DrawLine(point_start, point, 1,0,0,  (FireDetector_Properties["visualize_fire_detection"] == "ON"))
                                break
                            else
                                Generic_DrawLine(point_start, point, 0,1,0,  (FireDetector_Properties["visualize_fire_detection"] == "ON"))
                            end
                            point_start = point
                        end
                    end
                end
                if max_intensity < intensity then
                    max_intensity = intensity
                end
                FireDetector_LocalDB["fire_intensity"] = max_intensity
                fire_count = fire_count + 1
            end
        end

            -- if refresh then
            -- Perform fire spread, damage/explosion after timeouts

        if time_elapsed > fire_update_time and fire_count < max_fires then
            time_elapsed = 0
                -- Search fire locations, onfire = lists with actual fire
            local modifier = 1
            if FireDetector_Properties["map_size"] == "MEDIUM" then
                modifier = 2
            end
            if FireDetector_Properties["map_size"] == "SMALL" then
                modifier = 4
            end
            if FireDetector_Properties["map_size"] == "TINY" then
                modifier = 8
            end
            if FireDetector_Properties["map_size"] == "ULTRATINY" then
                modifier = 16
            end

            local onfire = {}
            -- FireDetector_RecursiveBinarySearchFire(midpoint, size / 2,  size_fire_count, min_size, max_fires, onfire, intensity, light_location)
            local p = GetPlayerPos()
            local n = FireDetector_FindNearestPoint(p, 409.6 / 10 / modifier)
            FireDetector_RecursiveBinarySearchFire(Vec(0,0,0), 409.6 / modifier, max_group_fire_distance / modifier, min_fire_distance / modifier, max_fires - fire_count, onfire, 0, nil)


            for i=1, #onfire do
                local hash = ObjectDetector_HashVec(onfire[i][3])
                if FireDetector_SPOF[hash] == nil then
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
                            FireDetector_SPOF[hash] = {location=point, light_location=onfire[i][5], material=shape_mat, fire_intensity=intensity, shape=shape_hit, original=onfire[i], timeout=Generic_deepCopy(timer) + Generic_rnd(fire_reaction_time, fire_reaction_time * 2), delete=false, soot=false}
                            if max_intensity < intensity then
                                max_intensity = intensity
                            end
                            if soot_sim == "YES" then
                                Paint(point, (Generic_rnd(soot_min_size, soot_max_size) / 100) * intensity, "explosion", Generic_rnd(soot_dithering_min, soot_dithering_max))
                            end
                        end
                        if fire_damage == "YES" and shape_mat == "glass" then
                            MakeHole(point, intensity / Generic_rndInt(50, 75), intensity / Generic_rndInt(50, 75), intensity / Generic_rndInt(50, 75), true)
                            PlaySound(FireDetector_GlassBreakingSnd[Generic_rndInt(1,12)], point, intensity / 200)
                        end
                    end
                end
            end
            FireDetector_LocalDB["fire_intensity"] = max_intensity
        end
        FireDetector_LocalDB["time_elapsed"] = time_elapsed + time
    end
    -- end

    if FireDetector_Properties["visualize_fire_detection"] == "ON" then
        for hash, fire in pairs(FireDetector_SPOF) do
            FireDetection_DrawDetectedFire(fire["original"])
        end
    end

    FireDetector_LocalDB["fire_count"] = fire_count
    FireDetector_LocalDB["timer"] = timer + time

    return FireDetector_SPOF
end


function FireDetector_GetLightAndWindLocations()

    local added = {}
    local lightandwind = {}

    for hash, fire in pairs(FireDetector_SPOF) do
        if Generic_TableContainsTable(added, fire["light_location"]) == false then
            added[#added+1] = fire["light_location"]
            lightandwind[#lightandwind+1] = fire
        end
    end

    return lightandwind
end

function FireDetector_VecMidPoint(vec1, vec2)
    -- return {vec1[1]+vec2[1]/2, vec1[2]+vec2[2]/2, vec1[3]+vec2[3]/2}
    return VecLerp(vec1, vec2, 0.5)
end

function FireDetector_FindNearestPoint(point, size)
    -- local norm = VecNormalize(point)
    size = size * 2
    local x = (math.ceil((point[1] / size)) * size)
    local z = (math.ceil((point[2] / size)) * size)
    local y = (math.ceil((point[3] / size)) * size)
    Generic_DrawPoint({x, z, y}, 1,0,1, (FireDetector_Properties["visualize_fire_detection"] == "ON"))
    return {x, z, y}
end

--- Determine fire locations by recursively searching for fires in bounding boxes. Thanks to @Thomasims on the official Teardown discord for additional help and input.
---@param vecstart Location to start searching from
---@param size Size of the bounding box
---@param size_fire_count Size of the bouding box minimum, if reached it will count all the fires in that bounding box.
---@param min_size any Minimum size before it should stop searching
---@param max_fires any Maximum fires it can detected before it stops searching
---@param onfire any The list with fires detected.
---@param intensity any The intensity, calculated until size_fire_count is  reached and passed along till min_size is reached.
function FireDetector_RecursiveBinarySearchFire(vecstart, size, size_fire_count, min_size, max_fires, onfire, intensity, light_location)

    -- Draw bounding box
    local outerpoints = Generic_CreateBox(vecstart, size, nil, {1, 0, 0}, false)

    local firecount = QueryAabbFireCount(outerpoints[1], outerpoints[7])
    if firecount == 0 or #onfire >= max_fires then
        return
    end

    if size <= size_fire_count and (intensity == nil or intensity == 0) then
        intensity = firecount
        local hit, pos = QueryClosestFire(FireDetector_VecMidPoint(outerpoints[1], FireDetector_VecMidPoint(outerpoints[1], outerpoints[7])), size_fire_count)
        if hit then
            -- Add slight offset to light to a certain direction to move it outside the shape
            light_location = {pos, size_fire_count}
        else
            light_location = {vecstart, size_fire_count}
        end
    end



    if size < min_size and max_fires > #onfire then
        if min_size > 0.1 then
            local hit, pos = QueryClosestFire(FireDetector_VecMidPoint(outerpoints[1], FireDetector_VecMidPoint(outerpoints[1], outerpoints[7])), size )
            if hit then
                local ll = nil
                if light_location == nil  then
                    ll = nil
                else
                    ll = light_location
                    Generic_CreateBox(ll[1], ll[2], nil, {1,0,1}, false)
                end
                onfire[#onfire + 1] = {pos, intensity, vecstart, size, ll[1]}
            end
        end
        return
    end
    -- Calculate 4 boxes inside bounding b

-- if QueryAabbFireCount(outerpoints[1], outerpoints[7]) > 0 then
    midpoint = FireDetector_VecMidPoint(outerpoints[1], FireDetector_VecMidPoint(outerpoints[1], outerpoints[7]))
    -- Generic_CreateBox(midpoint, size / 2, nil, {1, 0, 0}, false)
    FireDetector_RecursiveBinarySearchFire(midpoint, size / 2,  size_fire_count, min_size, max_fires, onfire, intensity, light_location)
    midpoint = FireDetector_VecMidPoint(outerpoints[2], FireDetector_VecMidPoint(outerpoints[2], outerpoints[8]))
    -- Generic_CreateBox(midpoint, size / 2, nil, {1, 0, 0}, false)
    FireDetector_RecursiveBinarySearchFire(midpoint, size / 2,  size_fire_count, min_size, max_fires, onfire, intensity, light_location)

    midpoint = FireDetector_VecMidPoint(outerpoints[3], FireDetector_VecMidPoint(outerpoints[3], outerpoints[5]))
    -- Generic_CreateBox(midpoint, size / 2, nil, {1, 0, 0}, false)
    FireDetector_RecursiveBinarySearchFire(midpoint, size / 2,  size_fire_count, min_size, max_fires, onfire, intensity, light_location)

    midpoint = FireDetector_VecMidPoint(outerpoints[4], FireDetector_VecMidPoint(outerpoints[4], outerpoints[6]))
    -- Generic_CreateBox(midpoint, size / 2, nil, {1, 0, 0}, false)
    FireDetector_RecursiveBinarySearchFire(midpoint, size / 2,  size_fire_count, min_size, max_fires, onfire, intensity, light_location)

    midpoint = FireDetector_VecMidPoint(outerpoints[5], FireDetector_VecMidPoint(outerpoints[5], outerpoints[3]))
    -- Generic_CreateBox(midpoint, size / 2, nil, {1, 0, 0}, false)
    FireDetector_RecursiveBinarySearchFire(midpoint, size / 2,  size_fire_count, min_size, max_fires, onfire, intensity, light_location)

    midpoint = FireDetector_VecMidPoint(outerpoints[6], FireDetector_VecMidPoint(outerpoints[6], outerpoints[4]))
    -- Generic_CreateBox(midpoint, size / 2, nil, {1, 0, 0}, false)
    FireDetector_RecursiveBinarySearchFire(midpoint, size / 2,  size_fire_count, min_size, max_fires, onfire, intensity, light_location)

    midpoint = FireDetector_VecMidPoint(outerpoints[7], FireDetector_VecMidPoint(outerpoints[7], outerpoints[1]))
    -- Generic_CreateBox(midpoint, size / 2, nil, {1, 0, 0}, false)
    FireDetector_RecursiveBinarySearchFire(midpoint, size / 2,  size_fire_count, min_size, max_fires, onfire, intensity, light_location)

    midpoint = FireDetector_VecMidPoint(outerpoints[8], FireDetector_VecMidPoint(outerpoints[8], outerpoints[2]))
    -- Generic_CreateBox(midpoint, size / 2, nil, {1, 0, 0}, false)
    FireDetector_RecursiveBinarySearchFire(midpoint, size / 2, size_fire_count, min_size, max_fires, onfire, intensity, light_location)



    -- Generic_DrawPoint(vecstart, 1,0,1)

end

---Use this in the draw function!
function FireDetector_ShowStatus()
    if GeneralOptions_GetShowUiInGame() == "YES" then

        DebugWatch("FireDetector, Fire count", FireDetector_LocalDB["fire_count"])
        DebugWatch("FireDetector, time elapsed", tostring(FireDetector_LocalDB["time_elapsed"]))
        DebugWatch("FireDetector, intensity", tostring(FireDetector_LocalDB["fire_intensity"]))
        DebugWatch("FireDetector, randomtimer", tostring(FireDetector_LocalDB["random_timer"]))
        DebugWatch("FireDetector, timer", tostring(FireDetector_LocalDB["timer"]))
        DebugWatch("FireDetector, map_size", tostring(FireDetector_Properties["map_size"]))

    end
end

