
---Find the nearest fire by sorting a list of vectors of known fires by distance, connecting the two closest vectors
---Determines fire intensity by simply seeing how many vectors hit the same location regarding their closest neighbour (more == more intense fire)
---@param vector_list any List purely consistent of the body identifie + location
---@param detected_fires any List with the full fire iformation, but only containing actual active fires
---@param global_list_fires any Full lists with all possible fire locations, including inactive fires (to track progress)
---@return integer The max intensity detected.
function FireDetector_CalculateIntensity(vector_list, detected_fires, global_list_fires)
    local min_fire_distance = FireDetector_Properties["min_fire_distance"]
    local max_group_fire_distance = FireDetector_Properties["max_group_fire_distance"]
    local fire_intensity_multiplier = FireDetector_Properties["fire_intensity_multiplier"]
    local min_fire_intensity = FireDetector_Properties["fire_intensity_minimum"]

    local fires_disabled = 0


    local body_count = {}
    for i=1, #vector_list do
        local center = vector_list[i][2]
        local box_size = min_fire_distance / 2
        FireDetector_DrawLine(center[1] )
        if vector_list[i][1] ~= nil then
            for a=1, #vector_list do
                if a ~= i and vector_list[a][1] ~= nil then
                    if FireDetector_CreateBox(center, box_size, vector_list[a][2]) then
                        if vector_list[a] ~= nil then
                            detected_fires[vector_list[a][1]] = nil
                            global_list_fires[vector_list[a][1]]["fire"] = false
                            fires_disabled = fires_disabled + 1
                            vector_list[a][1] = nil
                            if body_count[vector_list[i][1]] == nil then
                                body_count[vector_list[i][1]] = 1
                            end
                            body_count[vector_list[i][1]] = body_count[vector_list[i][1]] + 1
                            -- DebugWatch(vector_list[i][1], body_count[vector_list[i][1]])
                            break
                        end
                        -- break
                    end
                end
            end
        end
    end

    local vector_list_min_distance = {}
    for i=1, #vector_list do
        if vector_list_min_distance[i] == nil and vector_list[i][1] ~= nil then
            local minimum_distance = 1000
            local index_min_distance = 0
            for a=1, #vector_list do
                if a ~= i and vector_list[a][1] ~= nil then
                    if vector_list_min_distance[a] == nil then
                        local distance = FireDetector_VecDistance(vector_list[i][2], vector_list[a][2]) * 10
                        if distance < minimum_distance and distance > 0 then
                            minimum_distance = distance
                            index_min_distance = a
                        end
                    end
                end
            end
            -- DebugWatch(i, index_min_distance .. "," .. minimum_distance )
            if index_min_distance > 0 and minimum_distance < max_group_fire_distance then
                if vector_list_min_distance[i] == nil then
                    if body_count[vector_list[i][1]] == nil then
                        body_count[vector_list[i][1]] = 1
                    end
                    body_count[vector_list[i][1]] = body_count[vector_list[i][1]] + 1
                    if body_count[vector_list[index_min_distance][1]] == nil then
                        body_count[vector_list[index_min_distance][1]] = 1
                    end
                    body_count[vector_list[index_min_distance][1]] = body_count[vector_list[index_min_distance][1]] + 1
                end
                vector_list_min_distance[i] = {vector_list[i][1], vector_list[i][2], vector_list[index_min_distance][1], vector_list[index_min_distance][2], minimum_distance}

            end
        end
    end


    local max_fires_intensity = 0

    for i=1, #vector_list_min_distance do
        if vector_list_min_distance[i] ~= nil and detected_fires[vector_list_min_distance[i][1]] ~= nil and detected_fires[vector_list_min_distance[i][3]] ~= nil then
            FireDetector_DrawLine(vector_list_min_distance[i][2], vector_list_min_distance[i][4], 0,1,0)

            FireDetector_DrawPoint(vector_list_min_distance[i][2], body_count[vector_list_min_distance[i][1]] * 0.1, 0, 0)
            FireDetector_DrawPoint(vector_list_min_distance[i][4], body_count[vector_list_min_distance[i][3]] * 0.1, 0, 0)

            local intensity_b1 = body_count[vector_list_min_distance[i][1]] * fire_intensity_multiplier + min_fire_intensity
            if intensity_b1 > 100 then
                intensity_b1 = 100
            end
            if intensity_b1 > max_fires_intensity then
                max_fires_intensity = intensity_b1
            end

            local intensity_b2 = body_count[vector_list_min_distance[i][3]] * fire_intensity_multiplier + min_fire_intensity
            if intensity_b2 > 100 then
                intensity_b2 = 100
            end
            if intensity_b2 > max_fires_intensity then
                max_fires_intensity = intensity_b2
            end
            if detected_fires[vector_list_min_distance[i][1]] ~= nil and detected_fires[vector_list_min_distance[i][3]] ~= nil then
                detected_fires[vector_list_min_distance[i][1]]["fire_intensity"] = intensity_b1
                detected_fires[vector_list_min_distance[i][3]]["fire_intensity"] = itensity_b2
            end
            global_list_fires[vector_list_min_distance[i][1]]["fire_intensity"] = itensity_b1
            global_list_fires[vector_list_min_distance[i][3]]["fire_intensity"] = itensity_b2
        end
    end
    return {max_fires_itensity, fires_disabled}
end




---This function should be called in the tick(), it generates a list locations where
---assumed there is fire. This is done based on the following logic
--- 1. Query all dynamic physical small shapes: fire is most likely causing debris of small chunks to appear
--- 1.1 Store all shapes determined to be broken in a global list, together with a time stamp, however chunks are normally not the actual shape on fire.
---
--- 2. (note this step happens before 1.), For every shape in that list, determine if timestamp is within the timeout window (to prevent forever detection)
--- 3. Check if the shape is determined to be on fire or not.
---- 3.1 if in window but not on fire, do a closest point determination (query), this object IS highly likely on fire
---- 3.2 if in window and on fire, verify if the position detected to be on fire is still a valid voxel (using checkmaterial at position, empty == it does not exist)
---- 3.2.1 If the voxel is valid append the shape to a list to be returned
---- 3.2.2 If the voxel is not valid, then disable the fire step and go back to 3 (which will reevaluate the next best fire location)
---
--- Note that storing the objects found in 1. is necessary because QueryAabbShapes of "dynamic small physical" only seems to return
--- shapes that are actually visible/ infront the player/screen space, (ofcourse shapes behind other shapes as well),
--- If this was not stored globally, and the player looks away, it is no longer detected.
---@param timestamp number
---@return table
function FireDetector_FindFireLocations(time, refresh)

    local random_query = {
        "static",
        "static",
        "dynamic",
        "dynamic",
        "static",
        "static",
        "dynamic",
        "dynamic"
    }

    local fire_intensity_minimum = FireDetector_Properties["fire_intensity_minimum"]
    local material_allowed = FireDetector_Properties["material_allowed"]

    local currentSPOF = FireDetector_SPOF

    local time_elapsed = FireDetector_LocalDB["time_elapsed"]
    local fire_count = 0

    local max_fires = FireDetector_Properties["max_fire"]
    local max_fire_detection_time = FireDetector_Properties["max_fire_detection_time"]
    -- -- local max_fire_on_body = FireDetector_Properties["max_fire_detection_time"] - (max_fires / 100 * FireDetector_Properties["max_fire_on_body"])
    -- -- local max_fire_detect_distance = FireDetector_Properties["max_fire_detect_distance"]
    local enabled = FireDetector_Enabled(time)
    local fire_damage = FireDetector_Properties["fire_damage"]
    local fire_damage_soft = FireDetector_Properties["fire_damage_soft"] / 100
    local fire_damage_medium = FireDetector_Properties["fire_damage_medium"] / 100
    local fire_damage_hard = FireDetector_Properties["fire_damage_hard"] / 100
    local fire_explosion = FireDetector_Properties["fire_explosion"]
    local spawn_fire = FireDetector_Properties["spawn_fire"]
    local fire_intensity_enabled = FireDetector_Properties["fire_intensity"]
    -- -- local fire_randomness = FireDetector_Properties["fire_randomness"]
    if fire_intensity_enabled == "OFF" then
        fire_intensity_minimum = 100
    end

    -- If there is room for more fires to be detected, query new shapes


    -- If the fire count is not at it's max, it may add more fire
    -- Fire is detected by finding small broken bits. The whole detection is based on the assumption that fire creates small debris
    -- It is then determined if the shapes found are already part for a body that has been detected earlier.
    -- if the body is not detected yet, add to a global list with potentially bodies that could be on fire.
    -- Also add a timestamp at for detection time.
    -- There is a maximum mass that might be used for detecting fire, to prevent large bodies to be seen as potential fire.
    if fire_count <= max_fires then
        local player_t = GetPlayerTransform()
        QueryRequire("physical dynamic small")
        local user_radius = FireDetector_Properties["user_radius"] / 2
        local shape_list = QueryAabbShapes(VecSub(player_t.pos, {user_radius,user_radius,user_radius}), VecAdd(player_t.pos,{user_radius,user_radius,user_radius}))
        for i=1, #shape_list do
            local shape = shape_list[i]
            local body = GetShapeBody(shape)
            if IsShapeBroken(shape) then
                if currentSPOF[body] == nil then
                    local mass = GetShapeVoxelCount(shape)
                    -- if mass < FireDetector_Properties["max_mass_detection"]  then
                        local center = FireDetector_BodyCenter(body)
                        currentSPOF[body] = {shape=shape, location=center, timeout=max_fire_detection_time, timestamp=time_elapsed, fire=true, fire_detected=false, material=nil, verified_timestamp=time_elapsed, enabled=FireDetector_LocalDB["enabled"], fire_intensity=fire_intensity_minimum}
                    end
                end
            end
        end
    end

    -- We then iterate again over this list with potential fires, this time to actually detect if the body is on fire or not.
    -- Obviously, it is not (only) the shape itself that is on fire, but the body it broke of from.
    -- So the first thing first it tries to find the closest point to the detected body that it broke of from.  The range where it can search the body for is limited.
    -- If it hits a body then it must mean that that body is on fire (shown by a green cross (however it is so quick it wont be visible)).
    -- Right after the flag is set that the body is actually on fire, and the location of where it hit is stored.
    -- Also a time stamp is stored
    --  On a side note, when disable on user action is enabled, the bodies/locations detected during that time period are stored as inactive, and cannot be detected again unless the original debry is cleared (which is shown as a pink cross)
    -- If a fire is detected, then it will go to a state where, so long as the timestamp of the body is within the timeout period, it will verify it the location for that body is still a valid location (a.k.a if there is material detected at that location)
    -- If there is not, it will once again try to detect the closest valid point.
    -- If there is valid location, it is represented with a blue cross (also a blue line is drawn between the closest detected other fire (see FireDetector_FilterActualFires))
    -- When the timestamp is outside the timeout period, the body that is on fire will be disabled, and if fire damage and/or explosion is enabled it will trigger that explosion/damage. (This also generates a loop of infinite destructions, limited by the max fire distance)

    local list_locations = {}
    local list_fires = {}
    -- local list_index = 1
    for body, properties in pairs(currentSPOF) do
        local shape = properties["shape"]
        local shape_timed_out = false
        if (time_elapsed - properties["timestamp"]) > properties["timeout"] then
            shape_timed_out = true
        end
        if properties["enabled"] == false then
            FireDetector_DrawPoint(properties["location"],1,0,1)
            properties["fire"] = false
        elseif properties["fire"] and properties["fire_detected"] == false and shape_timed_out then
            properties["fire"] = false
        elseif properties["fire"] and properties["fire_detected"] then
            local shape_mat = GetShapeMaterialAtPosition(shape, properties["location"])
            if shape_mat ~= "" then
                if shape_timed_out then
                    local intensity = properties["fire_intensity"]
                    if fire_explosion == "YES" then
                        Explosion(properties["location"], (4 / 100) * properties["fire_intensity"])
                    end
                    if fire_damage == "YES" then
                        MakeHole(properties["location"], fire_damage_soft * intensity, fire_damage_medium * intensity, fire_damage_hard * intensity)
                    end

                    if spawn_fire == "YES" then
                        SpawnFire(properties["location"])
                    end
                    properties["fire"] = false
                else
                    local intensity = 1 / 100 * properties["fire_intensity"]
                    FireDetector_DrawPoint(properties["location"], intensity,0,0)
                    fire_count =  fire_count + 1
                    list_locations[fire_count] = {body, properties["location"]}
                    list_fires[body] = properties
                end
            else
                properties["fire_detected"] = false
            end
        elseif properties["fire"] and properties["fire_detected"] == false and shape_timed_out == false and refresh then
            if enabled then
                QueryRequire(random_query[Generic_rndInt(1, #random_query)])
                --QueryRequire(random_query[4])
            end

            -- Make sure it cant find it's own shape
            QueryRejectShape(properties["shape"])
            QueryRejectBody(body)

            -- Find closest voxel point where the shape originate from. (dynamic means it broke from an object)
            -- local hit, point, normal, shape_hit = QueryClosestPoint(properties["location"], max_fire_detect_distance)
            -- DebugWatch("distance", distance)
            local skip = Generic_rndInt(0, 100)
            -- if hit and skip <= (100 - fire_randomness)  then                       -- Determine the material at this point
                local shape_mat = GetShapeMaterialAtPosition(shape_hit, point)
                -- Store the shape_hit that is actually on fire
                if fire_count <= max_fires and shape_mat and material_allowed[shape_mat] == true then
                    properties["material"] = shape_mat
                    properties["location"] = point
                    properties["shape"] = shape_hit
                    properties["fire_detected"] = true
                    list_fires[body] = properties
                    fire_count = fire_count + 1
                    list_locations[fire_count] = {body, properties["location"]}
                end
            end
        elseif shape_timed_out == false then
            properties["fire_detected"] = false
        end

        -- Limit the amount of fires detected
        if fire_count > max_fires then
            break
        end
    end

    if fire_intensity_enabled == "ON" then
        local intensity = FireDetector_CalculateIntensity(list_locations, list_fires, currentSPOF)
        FireDetector_LocalDB["fire_intensity"] = intensity[1]
        fire_count = fire_count - intensity[2]
    else
        FireDetector_LocalDB["fire_intensity"] = 100
    end

    FireDetector_LocalDB["fire_count"] = fire_count
    FireDetector_SPOF = currentSPOF
    -- Update gloabl storage
    FireDetector_LocalDB["enabled"] = enabled
    --- Count the time
    time_elapsed = time_elapsed + time
    FireDetector_LocalDB["time_elapsed"] = time_elapsed
    -- return {list_fires, FireDetector_LocalDB["fire_count"], max_fire_on_body}
end