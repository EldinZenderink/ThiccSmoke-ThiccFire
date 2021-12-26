FireDetector_Properties = {
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
    fire_intensity=0,
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
    FireDetector_LocalDB["time_elapsed"] = 0
    FireDetector_LocalDB["time_input_disabled_elapsed"] = 0
    FireDetector_LocalDB["fire_count"] = 0
    Settings_RegisterUpdateSettingsCallback(FireDetector_UpdateSettingsFromSettings)

    for i=1,12 do
        FireDetector_GlassBreakingSnd[i] = LoadSound("MOD/sound/glass/00 - www.fesliyanstudios.com - " .. i .. ".ogg")
    end

end

---Retrieve properties from storage and apply them
function FireDetector_UpdateSettingsFromSettings()
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
    FireDetector_Properties["fire_damage_soft"] = Settings_GetValue("FireDetector", "fire_damage_soft")
    FireDetector_Properties["fire_damage_medium"] = Settings_GetValue("FireDetector", "fire_damage_medium")
    FireDetector_Properties["fire_damage_hard"] = Settings_GetValue("FireDetector", "fire_damage_hard")
    FireDetector_Properties["teardown_max_fires"] = Settings_GetValue("FireDetector", "teardown_max_fires")
    FireDetector_Properties["teardown_fire_spread"] = Settings_GetValue("FireDetector", "teardown_fire_spread")
    SetInt("game.fire.maxcount",  math.floor(FireDetector_Properties["teardown_max_fires"]))
    SetInt("game.fire.spread",  math.floor(FireDetector_Properties["teardown_fire_spread"]))
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
    local fire_update_time = FireDetector_Properties["fire_update_time"]
    local max_fire_spread_distance = FireDetector_Properties["max_fire_spread_distance"] / 100 -- take procentile to multiply times intensity
    local material_allowed = FireDetector_Properties["material_allowed"]

    local time_elapsed =  FireDetector_LocalDB["time_elapsed"]
    local timer = FireDetector_LocalDB["timer"]

    local max_intensity = 0
    if refresh then
        local max_fires = FireDetector_Properties["max_fire"]
        local min_fire_distance = FireDetector_Properties["min_fire_distance"]
        local max_group_fire_distance = FireDetector_Properties["max_group_fire_distance"]
        local fire_intensity_multiplier = FireDetector_Properties["fire_intensity_multiplier"]
        local min_fire_intensity = FireDetector_Properties["fire_intensity_minimum"]


        -- Perform fire spread, damage/explosion after timeouts

        if FireDetector_LocalDB["random_timer"] == 0 then
            local randomActionTime  = Generic_rndInt(fire_reaction_time, fire_reaction_time * 2)
            FireDetector_LocalDB["random_timer"] = randomActionTime + timer
        end

        if #FireDetector_SPOF > 4 and timer > FireDetector_LocalDB["random_timer"] then
            for i=1, #FireDetector_SPOF do
                local fire = FireDetector_SPOF[i]
                local intensity = fire["fire_intensity"]
                if fire_explosion == "YES" then
                    Explosion(fire["location"], (4 / 100) * fire["fire_intensity"])
                end
                if fire_damage == "YES" then
                    MakeHole(fire["location"], fire_damage_soft * intensity, fire_damage_medium * intensity, fire_damage_hard * intensity, true)
                end
                if spawn_fire == "YES" or fire_damage == "YES" then
                    for x=0, intensity / 5  do
                        local direction = Generic_rndVec(1)
                        local hit, dist,n,s = QueryRaycast(fire["location"], direction, max_fire_spread_distance * intensity + fire_damage_soft * intensity)
                        if hit then
                            local newpoint = VecAdd(fire["location"], VecScale(direction, dist))
                            local shape_mat = GetShapeMaterialAtPosition(s, newpoint)
                            if spawn_fire == "YES" then
                                SpawnFire(newpoint)
                                fire["location"] = newpoint
                            end
                            if fire_damage == "YES" and shape_mat == "glass" then
                                MakeHole(newpoint, intensity / Generic_rndInt(50, 75), intensity / Generic_rndInt(50, 75), intensity / Generic_rndInt(50, 75), true)
                                PlaySound(FireDetector_GlassBreakingSnd[Generic_rndInt(1,12)], newpoint, intensity / 200)
                            end
                        end
                    end
                end
            end
            FireDetector_LocalDB["random_timer"] = 0
        end

        if time_elapsed > fire_update_time or #FireDetector_SPOF < 2 then
            time_elapsed = 0
                -- Search fire locations, onfire = lists with actual fires
            local onfire = {}

            -- FireDetector_RecursiveBinarySearchFire(midpoint, size / 2,  size_fire_count, min_size, max_fires, onfire, intensity, light_location)
            FireDetector_RecursiveBinarySearchFire({0,0,0}, 409.6, max_group_fire_distance, min_fire_distance , max_fires, onfire, 0, nil)

            -- Parse all fires
            FireDetector_SPOF = {}
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
                        FireDetector_SPOF[#FireDetector_SPOF + 1] = {location=point, light_location=onfire[i][5], material=shape_mat, fire_intensity=intensity, shape=shape_hit, original=onfire[i]}
                        if max_intensity < intensity then
                            max_intensity = intensity
                        end
                        FireDetection_DrawDetectedFire(onfire[i])
                    end
                end
            end
            FireDetector_LocalDB["fire_intensity"] = max_intensity
        end

    end

    if FireDetector_Properties["visualize_fire_detection"] == "ON" then
        for i=1, #FireDetector_SPOF do
            local fire = FireDetector_SPOF[i]
            FireDetection_DrawDetectedFire(fire["original"])
        end
    end

    FireDetector_LocalDB["fire_count"] = #FireDetector_SPOF
    FireDetector_LocalDB["time_elapsed"] = time_elapsed + time
    FireDetector_LocalDB["timer"] = timer + time

    return FireDetector_SPOF
end


function FireDetector_GetLightAndWindLocations()

    local added = {}
    local lightandwind = {}

    for i=1, #FireDetector_SPOF do
        local fire = FireDetector_SPOF[i]
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
    local outerpoints = FireDetector_CreateBox(vecstart, size, nil, {1, 0, 0}, false)
    local firecount = QueryAabbFireCount(outerpoints[1], outerpoints[7])
    if firecount == 0 or #onfire >= max_fires then
        return
    end

    if size <= size_fire_count and (intensity == nil or intensity == 0) then
        intensity = firecount
        local hit, pos = QueryClosestFire(FireDetector_VecMidPoint(outerpoints[1], FireDetector_VecMidPoint(outerpoints[1], outerpoints[7])), size_fire_count)
        if hit then
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
                    FireDetector_CreateBox(ll[1], ll[2], nil, {1,0,1}, true)
                end
                onfire[#onfire + 1] = {pos, intensity, vecstart, size, ll[1]}
            end
        -- else
        --     FireDetector_CreateBox(vecstart, size, nil, {intensity * 0.01, 0, 0}, true)
        --     FireDetector_CreateBox(light_location[1], light_location[2], nil, {1, 0, 1}, true)
        --     onfire[#onfire + 1] = {vecstart, intensity, vecstart, size, light_location[1]}
        --     FireDetector_DrawPoint(vecstart, 1,0,0)
        end
        return
    end
    -- Calculate 4 boxes inside bounding b

-- if QueryAabbFireCount(outerpoints[1], outerpoints[7]) > 0 then
    midpoint = FireDetector_VecMidPoint(outerpoints[1], FireDetector_VecMidPoint(outerpoints[1], outerpoints[7]))
    -- FireDetector_CreateBox(midpoint, size / 2, nil, {1, 0, 0}, false)
    FireDetector_RecursiveBinarySearchFire(midpoint, size / 2,  size_fire_count, min_size, max_fires, onfire, intensity, light_location)
    midpoint = FireDetector_VecMidPoint(outerpoints[2], FireDetector_VecMidPoint(outerpoints[2], outerpoints[8]))
    -- FireDetector_CreateBox(midpoint, size / 2, nil, {1, 0, 0}, false)
    FireDetector_RecursiveBinarySearchFire(midpoint, size / 2,  size_fire_count, min_size, max_fires, onfire, intensity, light_location)

    midpoint = FireDetector_VecMidPoint(outerpoints[3], FireDetector_VecMidPoint(outerpoints[3], outerpoints[5]))
    -- FireDetector_CreateBox(midpoint, size / 2, nil, {1, 0, 0}, false)
    FireDetector_RecursiveBinarySearchFire(midpoint, size / 2,  size_fire_count, min_size, max_fires, onfire, intensity, light_location)

    midpoint = FireDetector_VecMidPoint(outerpoints[4], FireDetector_VecMidPoint(outerpoints[4], outerpoints[6]))
    -- FireDetector_CreateBox(midpoint, size / 2, nil, {1, 0, 0}, false)
    FireDetector_RecursiveBinarySearchFire(midpoint, size / 2,  size_fire_count, min_size, max_fires, onfire, intensity, light_location)

    midpoint = FireDetector_VecMidPoint(outerpoints[5], FireDetector_VecMidPoint(outerpoints[5], outerpoints[3]))
    -- FireDetector_CreateBox(midpoint, size / 2, nil, {1, 0, 0}, false)
    FireDetector_RecursiveBinarySearchFire(midpoint, size / 2,  size_fire_count, min_size, max_fires, onfire, intensity, light_location)

    midpoint = FireDetector_VecMidPoint(outerpoints[6], FireDetector_VecMidPoint(outerpoints[6], outerpoints[4]))
    -- FireDetector_CreateBox(midpoint, size / 2, nil, {1, 0, 0}, false)
    FireDetector_RecursiveBinarySearchFire(midpoint, size / 2,  size_fire_count, min_size, max_fires, onfire, intensity, light_location)

    midpoint = FireDetector_VecMidPoint(outerpoints[7], FireDetector_VecMidPoint(outerpoints[7], outerpoints[1]))
    -- FireDetector_CreateBox(midpoint, size / 2, nil, {1, 0, 0}, false)
    FireDetector_RecursiveBinarySearchFire(midpoint, size / 2,  size_fire_count, min_size, max_fires, onfire, intensity, light_location)

    midpoint = FireDetector_VecMidPoint(outerpoints[8], FireDetector_VecMidPoint(outerpoints[8], outerpoints[2]))
    -- FireDetector_CreateBox(midpoint, size / 2, nil, {1, 0, 0}, false)
    FireDetector_RecursiveBinarySearchFire(midpoint, size / 2, size_fire_count, min_size, max_fires, onfire, intensity, light_location)



    -- FireDetector_DrawPoint(vecstart, 1,0,1)

end

---Use this in the draw function!
function FireDetector_ShowStatus()
    if GeneralOptions_GetShowUiInGame() == "YES" then

        DebugWatch("FireDetector, Fire count:", FireDetector_LocalDB["fire_count"])
        DebugWatch("FireDetector, time elapsed:", tostring(FireDetector_LocalDB["time_elapsed"]))
        DebugWatch("FireDetector, intensity:", tostring(FireDetector_LocalDB["fire_intensity"]))
        DebugWatch("FireDetector, randomtimer:", tostring(FireDetector_LocalDB["random_timer"]))
        DebugWatch("FireDetector, timer:", tostring(FireDetector_LocalDB["timer"]))

    end
end

