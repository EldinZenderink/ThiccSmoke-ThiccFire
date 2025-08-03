-- FireSim.lua
-- @date 2022-08-28
-- @author Eldin Zenderink
-- @brief Detects fires and 'manages' their behavior

-- #include "light_spawner\lightspawner.lua"
FireSim = {}

FireSim.Properties = {
    map_size = "MEDIUM",
    max_fire_spread_distance = 6,
    fire_reaction_time = 2,
    fire_update_time = 1,
    min_fire_distance = 1,
    max_group_fire_distance = 4,
    max_fire = 150,
    fire_intensity = "ON",
    fire_intensity_multiplier = 3,
    fire_intensity_minimum = 1,
    visualize_fire_detection = "OFF",
    fire_explosion = "NO",
    fire_damage = "YES",
    spawn_fire = "YES",
    fire_damage_soft = 0.5,
    fire_damage_medium = 0.3,
    fire_damage_hard = 0.1,
    detect_inside = "YES",
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
        plastic = true
    },
    disable_td_fire = "NO",
    enable_sound = "ON",
    fire_sound_volume = 0.5,
    fire_sound_volume_random = 0,
    damage_sound_volume = 0.5,
    damage_sound_volume_random = 0
}

FireSim.MaterialInfo = {
    -- density loosly based on https://en.wikipedia.org/wiki/Density
    -- heat capacity loosly based on https://www.engineeringtoolbox.com/specific-heat-solids-d_154.html
    wood = {
        rho = {
            -- min=37.3,
            -- max=85.0
            min=152,
            max=426
        },
        heatcapacity = {
            min=1,
            max=20
        }
    },
    foliage =
    {
        rho = {
            -- min=24.0,
            -- max=35.0

            min=120.0,
            max=175.0
        },
        heatcapacity = {
            min=1,
            max=8
        }
    },
    plaster =
    {
        rho = {
            min=60.0,
            max=160.0
        },
        heatcapacity = {
            min=0.9,
            max=1
        }
    },
    plastic =
    {
        rho = {
            min=100.0,
            max=120.0
        },
        heatcapacity = {
            min=1.3,
            max=1.7
        }
    }
}

--- Some global properties
FireSim.LocalDB = {
    time_elapsed = 0,
    fire_count = 0,
    fire_intensity = 1,
    timer = 0,
    random_timer = 0
}

-- Store all shapes that could potentially be detached from shapes on fire (BPOF = shapes potentially on fire)
FireSim.Fires = {}
FireSim.FiresToDelete = {}

-- Global trigger to update fires from particle spawner (makes sense...)
FireSim.UpdateFires = false

-- Courtesy of: https://www.fesliyanstudios.com/royalty-free-sound-effects-download/glass-shattering-and-breaking-124
FireSim.GlassBreakingSnd = {}

-- Visualize fires
FireSim.Visualize = false

-- Register fire handlers
FireSim.UpdateCallbacks = {}
FireSim.DeleteCallbacks = {}

-- Fire spread directions
FireSim.SpreadDirections = {
    {-1, -1, 1},
    {-1, 0, 1},
    {-1, 1, 1},
    {0, -1, 1},
    {0, 0, 1},
    {0, 1, 1},
    {1, -1, 1},
    {1, 0, 1},
    {0, 1, 0},
    {1, 1, 1},
    {1, 1, -1},
    {0, 1, -1},
    {-1, 1, -1},
    {-1, -1, 0},
    {-1, 0, 0},
    {-1, 1, 0},
    {0, 0, 0},
    {1, -1, 0},
    {1, 0, 0},
    {1, 1, 0},
    {0, 0, -1},
    {-1, 0, -1},
    {1, 0, -1},
    {-1, -1, -1},
    {0, -1, -1},
    {1, -1, -1},
    {0, -1, 0},
}

-- Sound playlist
FireSim.FireSound = {}
FireSim.FireDestructionSound = {}



-- local FireSim.RecursiveBinarySearchFire = FireSim.RecursiveBinarySearchFire
-- local pairs = pairs


---Initialize the properties of the module
---@param default bool -- set to true to set all properties to their default configured values
function FireSim.Init(argGeneric, argParticleSpawner, argSettings, argGeneralOptions, argCompatibility)
    FireSim.Generic = argGeneric
    FireSim.ParticleSpawner = argParticleSpawner
    FireSim.Settings = argSettings
    FireSim.GeneralOptions = argGeneralOptions
    FireSim.Compatibility = argCompatibility

    FireSim.Settings.RegisterUpdateSettingsCallback(FireSim.UpdateSettingsFromSettings)

    for i = 1, 12 do
        FireSim.GlassBreakingSnd[i] = LoadSound(
                                               "MOD/sound/glass/00 - www.fesliyanstudios.com - " ..
                                                   i .. ".ogg")
    end


    -- Load sound
    for x = 0, 1 do
        FireSim.FireDestructionSound[#FireSim.FireDestructionSound+1] = LoadSound("MOD/sound/firecollapse/fc"..x..".ogg")
    end

    for x = 0, 3 do
        FireSim.FireSound[#FireSim.FireSound+1] = LoadLoop("MOD/sound/fire/"..x..".ogg")
    end
end

---Retrieve properties from storage and apply them
function FireSim.UpdateSettingsFromSettings()
    -- DebugPrint("Update from settings")
    FireSim.Properties["map_size"] =
        FireSim.Settings.GetValue("FireSim", "map_size")
    FireSim.Properties["max_fire_spread_distance"] = FireSim.Settings.GetValue(
                                                              "FireSim",
                                                              "max_fire_spread_distance")
    FireSim.Properties["fire_reaction_time"] = FireSim.Settings.GetValue(
                                                        "FireSim",
                                                        "fire_reaction_time")
    FireSim.Properties["fire_update_time"] = FireSim.Settings.GetValue(
                                                      "FireSim",
                                                      "fire_update_time")
    FireSim.Properties["max_fire"] =
        FireSim.Settings.GetValue("FireSim", "max_fire")
    FireSim.Properties["min_fire_distance"] = FireSim.Settings.GetValue(
                                                       "FireSim",
                                                       "min_fire_distance")
    FireSim.Properties["max_group_fire_distance"] = FireSim.Settings.GetValue(
                                                             "FireSim",
                                                             "max_group_fire_distance")
    FireSim.Properties["visualize_fire_detection"] = FireSim.Settings.GetValue(
                                                              "FireSim",
                                                              "visualize_fire_detection")
    FireSim.Properties["fire_intensity"] = FireSim.Settings.GetValue(
                                                    "FireSim",
                                                    "fire_intensity")
    FireSim.Properties["fire_intensity_multiplier"] = FireSim.Settings.GetValue(
                                                               "FireSim",
                                                               "fire_intensity_multiplier")
    FireSim.Properties["fire_intensity_minimum"] = FireSim.Settings.GetValue(
                                                            "FireSim",
                                                            "fire_intensity_minimum")
    FireSim.Properties["fire_explosion"] = FireSim.Settings.GetValue(
                                                    "FireSim",
                                                    "fire_explosion")
    FireSim.Properties["fire_damage"] =
        FireSim.Settings.GetValue("FireSim", "fire_damage")
    FireSim.Properties["spawn_fire"] =
        FireSim.Settings.GetValue("FireSim", "spawn_fire")
    FireSim.Properties["detect_inside"] =
        FireSim.Settings.GetValue("FireSim", "detect_inside")
    FireSim.Properties["soot_sim"] =
        FireSim.Settings.GetValue("FireSim", "soot_sim")
    FireSim.Properties["soot_dithering_max"] = FireSim.Settings.GetValue(
                                                        "FireSim",
                                                        "soot_dithering_max")
    FireSim.Properties["soot_dithering_min"] = FireSim.Settings.GetValue(
                                                        "FireSim",
                                                        "soot_dithering_min")
    FireSim.Properties["soot_max_size"] =
        FireSim.Settings.GetValue("FireSim", "soot_max_size")
    FireSim.Properties["soot_min_size"] =
        FireSim.Settings.GetValue("FireSim", "soot_min_size")
    FireSim.Properties["fire_damage_soft"] = FireSim.Settings.GetValue(
                                                      "FireSim",
                                                      "fire_damage_soft")
    FireSim.Properties["fire_damage_medium"] = FireSim.Settings.GetValue(
                                                        "FireSim",
                                                        "fire_damage_medium")
    FireSim.Properties["fire_damage_hard"] = FireSim.Settings.GetValue(
                                                      "FireSim",
                                                      "fire_damage_hard")
    FireSim.Properties["teardown_max_fires"] = FireSim.Settings.GetValue(
                                                        "FireSim",
                                                        "teardown_max_fires")
    FireSim.Properties["teardown_fire_spread"] = FireSim.Settings.GetValue(
                                                          "FireSim",
                                                          "teardown_fire_spread")


    FireSim.Properties["despawn_td_fire"] = FireSim.Settings.GetValue(
        "FireSim",
        "despawn_td_fire")


    FireSim.Properties["enable_sound"] = FireSim.Settings.GetValue(
        "FireSim",
        "enable_sound")

    FireSim.Properties["fire_sound_volume"] = FireSim.Settings.GetValue(
        "FireSim",
        "fire_sound_volume")

    FireSim.Properties["fire_sound_volume_random"] = FireSim.Settings.GetValue(
        "FireSim",
        "fire_sound_volume_random")

    FireSim.Properties["damage_sound_volume"] = FireSim.Settings.GetValue(
        "FireSim",
        "damage_sound_volume")

    FireSim.Properties["damage_sound_volume_random"] = FireSim.Settings.GetValue(
        "FireSim",
        "damage_sound_volume_random")


    if FireSim.Properties["visualize_fire_detection"] == "ON" then
        FireSim.Visualize = true
    else
        FireSim.Visualize = false
    end
    -- No Fire Limit mod is disabled/does not work when ThiccSmoke / ThiccFire is enabled, since it adjusts the same settings
    if FireSim.Compatibility.IsSettingCompatible("teardown_max_fires") then
        SetInt("game.fire.maxcount",
               math.floor(FireSim.Properties["teardown_max_fires"]))
        SetInt("game.fire.spread",
               math.floor(FireSim.Properties["teardown_fire_spread"]))
    end

    if  FireSim.Properties["despawn_td_fire"] == nil or
        FireSim.Properties["despawn_td_fire"] == "" then
        FireSim.Properties["despawn_td_fire"] = "YES"
        FireSim.Settings.SetValue("FireSim", "despawn_td_fire", "YES")
    end

    if FireSim.Properties["despawn_td_fire"] == "YES" then
        FireSim.Properties["spawn_fire"] = "YES" -- Must spawn additional fires otherwise fires will dissapear
    end

    if FireSim.Properties["detect_inside"] == nil or
        FireSim.Properties["detect_inside"] == "" then
        FireSim.Properties["detect_inside"] = "YES"
        FireSim.Settings.SetValue("FireSim", "detect_inside", "YES")
    end

    if FireSim.Properties["soot_sim"] == nil or
        FireSim.Properties["soot_sim"] == "" then
        FireSim.Properties["soot_sim"] = "NO"
        FireSim.Settings.SetValue("FireSim", "soot_sim", "NO")
    end

    if FireSim.Properties["soot_dithering_max"] == nil or
        FireSim.Properties["soot_dithering_max"] == 0 then
        FireSim.Properties["soot_dithering_max"] = 1
        FireSim.Settings.SetValue("FireSim", "soot_dithering_max", 1)
    end
    if FireSim.Properties["soot_max_size"] == nil or
        FireSim.Properties["soot_max_size"] == 0 then
        FireSim.Properties["soot_max_size"] = 5
        FireSim.Settings.SetValue("FireSim", "soot_max_size", 5)
    end
    if FireSim.Properties["soot_dithering_min"] == nil or
        FireSim.Properties["soot_dithering_min"] == 0 then
        FireSim.Properties["soot_dithering_min"] = 1
        FireSim.Settings.SetValue("FireSim", "soot_dithering_min", 1)
    end
    if FireSim.Properties["soot_min_size"] == nil or
        FireSim.Properties["soot_min_size"] == 0 then
        FireSim.Properties["soot_min_size"] = 5
        FireSim.Settings.SetValue("FireSim", "soot_min_size", 5)
    end

    if FireSim.Properties["map_size"] == nil or
        FireSim.Properties["map_size"] == "" then
        FireSim.Properties["map_size"] = "MEDIUM"
        FireSim.Settings.SetValue("FireSim", "map_size", "MEDIUM")
    end

    if FireSim.Properties["enable_sound"] == nil or
        FireSim.Properties["enable_sound"] == "" then
        FireSim.Properties["enable_sound"] = "ON"
        FireSim.Settings.SetValue("FireSim", "enable_sound", "ON")
    end

    if FireSim.Properties["fire_sound_volume"] == nil or
        FireSim.Properties["fire_sound_volume"] == "" then
        FireSim.Properties["fire_sound_volume"] = 0.5
        FireSim.Settings.SetValue("FireSim", "fire_sound_volume", 0.5)
    end


    if FireSim.Properties["fire_sound_volume_random"] == nil or
        FireSim.Properties["fire_sound_volume_random"] == "" then
        FireSim.Properties["fire_sound_volume_random"] = 0
        FireSim.Settings.SetValue("FireSim", "fire_sound_volume_random", 0)
    end


    if FireSim.Properties["damage_sound_volume"] == nil or
        FireSim.Properties["damage_sound_volume"] == "" then
        FireSim.Properties["damage_sound_volume"] = 0.5
        FireSim.Settings.SetValue("FireSim", "damage_sound_volume", 0.5)
    end


    if FireSim.Properties["damage_sound_volume_random"] == nil or
        FireSim.Properties["damage_sound_volume_random"] == "" then
        FireSim.Properties["damage_sound_volume_random"] = 0
        FireSim.Settings.SetValue("FireSim", "damage_sound_volume_random", 0)
    end


    -- FireSim.RegisterUpdateFireCallback("FireSound", FireSim.SoundPlayback, 0) -- 0 == every tic
    -- FireSim.RegisterUpdateFireCallback("update", "LocationCallback", FireSim.UpdateLocationCallback, FireSim.Properties["fire_update_time"])
    -- FireSim.RegisterUpdateFireCallback("update", "IntensityCallback", FireSim.UpdateIntensityCallback, FireSim.Properties["fire_update_time"] * 2)
    -- FireSim.RegisterUpdateFireCallback("update", "SpreadCallback", FireSim.UpdateSpreadCallback, FireSim.Properties["fire_update_time"])
    -- FireSim.RegisterUpdateFireCallback("update", "Soot", FireSim.UpdateSoot, FireSim.Properties["fire_update_time"] * 10)
    -- FireSim.RegisterUpdateFireCallback("update", "FireDamage", FireSim.UpdateFireDamage, FireSim.Properties["fire_update_time"] * 10)
    -- FireSim.RegisterUpdateFireCallback("tick", "DrawFire", FireSim.DrawFire, 0)
    -- FireSim.RegisterUpdateFireCallback("tick", "ParticleSpawner", FireSim.ParticleSpawner.SpawnFireCallback, 0.050)




end

function FireSim.DrawDetectedFire(fireinfo)
    local showDebug = false
    if FireSim.Properties["visualize_fire_detection"] == "ON" then
        showDebug = true
    end
    local fireInensityPercentageNormalized = 0.01 * (fireinfo["fire_intensity"])
    if fireinfo["extinghuishing"] then
        local fireIntensityColors = {
            1 - fireInensityPercentageNormalized,
            1 - fireInensityPercentageNormalized,
            0.0
        }
        FireSim.Generic.CreateBox(
            fireinfo["original"][3],
            fireInensityPercentageNormalized,
            nil,
            fireIntensityColors,
            showDebug
        )
    else
        local fireIntensityColors = {
            fireInensityPercentageNormalized,
            0.0,
            0.0
        }
        FireSim.Generic.CreateBox(
            fireinfo["original"][3],
            fireInensityPercentageNormalized,
            nil,
            fireIntensityColors,
            showDebug
        )
    end
    FireSim.Generic.DrawPoint(fireinfo["original"][3], 1, 0, 0, showDebug)
    if fireinfo["inside"] ~= nil and fireinfo["inside"] == true then
        FireSim.Generic.DrawPoint(fireinfo["original"][1], 1, 0, 1, showDebug)
    else
        FireSim.Generic.DrawPoint(fireinfo["original"][1], 0, 1, 1, showDebug)
    end
end

function FireSim.RegisterUpdateFireCallback(type, id, callback, interval)
    FireSim.UpdateCallbacks[id] = {
        callback=callback,
        interval=interval,
        type=type,
        timer=0
    }
    DebugPrint("Registered fire callback: " .. id .. "  at interval: " .. interval)

    for h, f in pairs(FireSim.Fires) do
        FireSim.Fires[h]["update_callbacks"] = FireSim.Generic.deepCopy(FireSim.UpdateCallbacks)
    end
end

function FireSim.RegisterDeleteFireCallback(type, id, callback, interval)
    FireSim.DeleteCallbacks[id] = {
        callback=callback,
        interval=interval,
        type=type,
        timer=0
    }
    for h, f in pairs(FireSim.Fires) do
        FireSim.Fires[h]["delete_callbacks"] = FireSim.Generic.deepCopy(FireSim.DeleteCallbacks)
    end
end

function FireSim.SoundPlayback(dt)
    for hash, fire in pairs(FireSim.Fires) do
        local random = FireSim.Properties["fire_sound_volume_random"]
        local fire_volume = FireSim.Properties["fire_sound_volume"]
        if fire["playsound"] ~= nil and fire["playsound"] > 0 and FireSim.Properties["enable_sound"] == "ON" then
            -- DebugPrint("Playing loop: " .. fire["playsound"] .. " for: " .. hash)

            if fire["playsound_random"] == 0 then
                fire["playsound_random"] = 1 + FireSim.Generic.rnd(-random, random)
            end

            PlayLoop(FireSim.FireSound[fire["playsound"]], fire["location"], ((fire["fire_intensity"] / 100) * fire_volume) * fire["playsound_random"])
        end
    end
end


function FireSim.OverlapCheck(fires, current_location, current_intensity, marginInsidePercentage, hash)
    -- DebugPrint("Searching overlap: " .. tostring(fires[1]))
    for x = 1, #fires do
        DebugPrint(tostring(fires[x]))

        local largestintensity = current_intensity

        local distToCheck = 1 / 100 * largestintensity

        -- if f["original"][6] > distToCheck then
        --     distToCheck = f["original"][6]
        -- end
        local fireDist = FireSim.Generic.VecDistance(fires[x], current_location)

        if fireDist < distToCheck then
            -- DebugPrint("Did not spawn fire, already fire at location")
            DebugPrint("Fire: is to close,  distance: " .. fireDist .. " < " .. distToCheck)
            return true
        end
    end
    DebugPrint("Return nothing found")
    return false
end

function FireSim.UpdateLocationCallback(dt)
    -- DebugPrint("Updating fire location")
    local material_allowed = FireSim.Properties["material_allowed"]
    local min_fire_distance = FireSim.Properties["min_fire_distance"]

    for hash, fire in pairs(FireSim.Fires) do
        -- If the current fire is overlapping try to move it outside the overlapping range
        -- otherwise remove the fire to prevent performance issues
        local distanceBasedOnFireIntensity = fire["fire_intensity"] / 100 + 0.75
        if distanceBasedOnFireIntensity < min_fire_distance then
            distanceBasedOnFireIntensity = min_fire_distance
        end

        -- local checkOverlap = FireSim.OverlapCheck(fire["location"], fire["fire_intensity"], 0.75, hash)

        -- if checkOverlap[1] == true then
        --     DebugPrint("Overlap detected")
        --     local result = FireSim.CheckDirection(fire, distanceBasedOnFireIntensity, 16)
        --     if result ~= nil then
        --         local firebaseinfo = {result[3], 0, result[4], result[6] / 2, result[3], fire["fire_intensity"], fire["original"][7]}
        --         FireSim.Fires[result[1]] = FireSim.GenerateFireObject(result[4], result[8], result[5], result[7], firebaseinfo, fire["original_fire_intensity"])
        --     end
        --     FireSim.Fires["delete"] = true
        -- end

        -- Detect if the fire is still at an existing location (not floating in the air)
        -- If it is floating, move it to the closest by location
        local material = GetShapeMaterialAtPosition(fire["shape"], fire["location"])
        if material == "" then
            local hit, point, normal, shape_hit = QueryClosestPoint(fire["location"], 1)
            if hit then
                material = GetShapeMaterialAtPosition(shape_hit, point)

                -- Find nearby fires with lower intensity
                local locations = {}
                local delete = false
                for h, f in pairs(FireSim.Fires) do
                    if h ~= hash then
                        locations[#locations+1] = f["location"]
                    end
                end

                if #locations > 0 then
                    local inrange = FireSim.Generic.isWithinRange(point, locations, min_fire_distance * 2)

                    -- Take over fires
                    if inrange ~= nil then
                        delete = true
                    end
                end

                if material_allowed[material] and delete == false then
                    FireSim.Fires[hash]["location"] = point
                    FireSim.Fires[hash]["original"][3] = point
                    FireSim.Fires[hash]["shape"] = shape_hit
                    FireSim.Fires[hash]["normal"] = normal
                    FireSim.Fires[hash]["fire_intensity"] = FireSim.Fires[hash]["fire_intensity"]
                else
                    FireSim.Fires[hash]["fire_intensity"] = 0
                    FireSim.Fires[hash]["delete"] = true
                end
            else
                FireSim.Fires[hash]["fire_intensity"] = 0
                FireSim.Fires[hash]["delete"] = true
            end
        end
    end
end

function FireSim.UpdateIntensityCallback(dt)
    local speedmultiplier = FireSim.Properties["fire_intensity_multiplier"]


    for hash, fire in pairs(FireSim.Fires) do
        local time = fire["timer"]
        local material = fire["material"]
        local rho = FireSim.Generic.rnd(FireSim.MaterialInfo[material]["rho"]["min"], FireSim.MaterialInfo[material]["rho"]["max"])
        local heatcapacity = FireSim.Generic.rnd(FireSim.MaterialInfo[material]["heatcapacity"]["min"], FireSim.MaterialInfo[material]["heatcapacity"]["max"])

        if fire["burnout"] == false and fire["extinghuishing"] == false  then
            -- newFireIntensity = FireSim.Generic.rnd(newFireIntensity / 1.1, newFireIntensity)
            local maxprc = fire["max_percentage"]

            if fire["fire_intensity"] > maxprc then
                FireSim.Fires[hash]["fire_intensity"] = maxprc
            elseif fire['spawnednew'] == false then
                FireSim.Fires[hash]["fire_intensity"] = fire["fire_intensity"] + FireSim.Generic.rnd( (((math.ceil(time * 15)) / (rho * heatcapacity)))  * -0.5,   (((math.ceil(time * 50)) / (rho * heatcapacity)) * speedmultiplier))  - (fire["extinghuishing_rate"])
            end

            if fire["fire_intensity"] > fire["burnout_percentage"] then
                if fire["burnout_timestamp"] == 0 then
                    FireSim.Fires[hash]["burnout_timestamp"] = fire["timer"]
                end

                if fire["timer"] > FireSim.Generic.rnd(0,2) + fire["burnout_timestamp"] then
                    FireSim.Fires[hash]["burnout"] = true
                end
            end

            if fire["extinghuishing_rate"] > 0 then
                FireSim.Fires[hash]["extinghuishing_rate"] = fire["extinghuishing_rate"] - 0.5
            end
            -- DebugWatch("fire_intensity_"..hash, tostring(fire["fire_intensity"]) .. "%_burning_"..fire["extinghuishing_rate"].."%_extinguisingrate")
        elseif fire["fire_intensity"] > 0  and fire["extinghuishing"] == true then
            FireSim.Fires[hash]["fire_intensity"] = fire["fire_intensity"] - (fire["extinghuishing_rate"] / 20)
            -- DebugWatch("fire_intensity_"..hash, tostring(fire["fire_intensity"]) .. "%_extinguishing_"..fire["extinghuishing_rate"].."%_extinguisingrate")
        elseif fire["fire_intensity"] > 0  and fire["burnout"] == true then
            FireSim.Fires[hash]["fire_intensity"] = fire["fire_intensity"] - 1
            if fire["fire_intensity"] <= fire["burnout_percentage"] then
                fire["extinghuishing"] = true
            end
            -- DebugWatch("fire_intensity_"..hash, tostring(fire["fire_intensity"]) .. "%_burnout")
        elseif fire["burnout"] == true or fire["extinghuishing"] == true then
            -- DebugWatch("fire_intensity_"..hash, tostring(fire["fire_intensity"]) .. "%_deleted")
            FireSim.Fires[hash]["delete"] = true
        end


        if fire["fire_intensity"] < 15 or fire["playsound"] == nil then
            FireSim.Fires[hash]["playsound"] = 1
        elseif fire["fire_intensity"] > 15 and fire["playsound"] < 2 then
            FireSim.Fires[hash]["playsound"] = 2
        elseif fire["fire_intensity"] > 25 and fire["playsound"] < 3 then
            FireSim.Fires[hash]["playsound"] = 3
        elseif fire["fire_intensity"] > 75 and fire["playsound"] < 4 then
            FireSim.Fires[hash]["playsound"] = 4
        end
    end
end

function FireSim.UpdateSpreadCallback(dt)
    local max_fires = FireSim.Properties["max_fire"]
    local current_fires = FireSim.LocalDB["fire_count"]
    local min_fire_distance = FireSim.Properties["min_fire_distance"]

    local min_fire_intensity = FireSim.Properties["fire_intensity_minimum"]
    local new_fires_to_add = {}


    -- Find new fires.
    for hash, fire in pairs(FireSim.Fires) do
        DebugWatch("max_fires_vs_current_fires", tostring(max_fires) .. " vs " .. tostring(current_fires))

        if  current_fires <= max_fires  and
            fire["spawnnew"] == true and
            (fire["burnout"] == true or fire["damage"] == true) and
            fire["spawnednew"] == false then
            if  fire["amounttospawn"] == 0 then
                local newFireCount = math.ceil(FireSim.Generic.rnd(1, fire["fire_intensity"] / 20))
                FireSim.Fires[hash]["amounttospawn"] = newFireCount
                DebugPrint(hash .. "New fire count to spwn: " .. tostring(fire["amounttospawn"]))
            else
                local distanceToCheck = (1 / 100) * (fire["fire_intensity"])
                if distanceToCheck < min_fire_distance then
                    distanceToCheck = min_fire_distance
                end

                for x=1, fire["amounttospawn"] do
                    local showDebug = false
                    if FireSim.Properties["visualize_fire_detection"] == "ON" then
                        showDebug = true
                    end

                    DebugPrint("Check dist: " .. tostring(distanceToCheck))

                    local result = FireSim.CheckDirection(hash, fire, distanceToCheck, 2, min_fire_distance)

                    if result ~= nil then

                        local extinghuished = 0
                        if result[9] ~= nil then
                            for i, hash in ipairs(result[9]) do
                                DebugPrint("In range: " .. hashes[hash])
                                FireSim.Fires[hashes[hash]]["delete"] = true
                                extinghuished = extinghuished + 1
                            end
                        end
                        DebugPrint("In range: " .. tostring(extinghuished))

                        -- Add new fire to the LOCAL array (do not change table while iterating!)
                        local outerpoints = FireSim.Generic.CreateBox(result[3], result[6], nil, {0, 1, 0}, showDebug)
                        local firebaseinfo = {result[3], 0, result[4], result[6] / 2, result[3], fire["fire_intensity"] + (extinghuished * 5), outerpoints}
                        local startinIntensity = min_fire_intensity
                        new_fires_to_add[result[1]] = FireSim.GenerateFireObject(result[4], result[8], result[5], result[7], firebaseinfo, startinIntensity)
                        DebugPrint(hash .. " - Spawned fire")
                    end
                end
                FireSim.Fires[hash]["spawnednew"] = true
                FireSim.Fires[hash]["spawnnew"] = false
            end
        end
    end

    -- Append all new found fires to the global FireSim.Fires table.
    for hash, fire in pairs(new_fires_to_add) do
        FireSim.Fires[hash] = fire
    end
end

function FireSim.UpdateSoot(dt)

    local showDebug = false
    if FireSim.Properties["visualize_fire_detection"] == "ON" then
        showDebug = true
    end
    local soot_sim = FireSim.Properties["soot_sim"]
    local soot_dithering_max = FireSim.Properties["soot_dithering_max"]
    local soot_max_size = FireSim.Properties["soot_max_size"]
    local soot_dithering_min = FireSim.Properties["soot_dithering_min"]
    local soot_min_size = FireSim.Properties["soot_min_size"]

    for hash, fire in pairs(FireSim.Fires) do
        if soot_sim == "YES"  then
            local point_start = fire["location"]
            local randomize = FireSim.Generic.rndInt(soot_min_size,
                                            soot_max_size)
            for x = 0, fire["fire_intensity"] / 25 do
                local direction =
                    Vec(FireSim.Generic.rnd(-0.15, 0.15), 1,
                        FireSim.Generic.rnd(-0.15, 0.15))
                local newpoint =
                    VecAdd(point_start, VecScale(direction, fire["fire_intensity"] / 40))
                local hit, point, normal, _ = QueryClosestPoint(
                                                        newpoint,
                                                        randomize)
                if hit then
                    FireSim.Generic.DrawLine(point_start, point, 0, 1, 0,
                                    showDebug)
                    Paint(point, (FireSim.Generic.rnd(soot_min_size,
                                            soot_max_size) / 100) *
                            fire["fire_intensity"], "explosion", FireSim.Generic.rnd(
                            soot_dithering_min, soot_dithering_max))
                    if normal[2] < -0.8 then
                        FireSim.Generic.DrawLine(point_start, point, 1, 0, 0,
                                        showDebug)
                        break
                    else
                        FireSim.Generic.DrawLine(point_start, point, 0, 1, 0,
                                        showDebug)
                    end
                    point_start = point
                end
            end
        end
    end
end

function FireSim.UpdateFireDamage(dt)
    local fire_damage = FireSim.Properties["fire_damage"]
    local sound_enabled = FireSim.Properties["enable_sound"]
    local damage_volume = FireSim.Properties["damage_sound_volume"]
    local random_volume = 1 + FireSim.Generic.rnd(-FireSim.Properties["damage_sound_volume_random"],FireSim.Properties["damage_sound_volume_random"])

    for hash, fire in pairs(FireSim.Fires) do
        if fire_damage == "YES" then
            -- DebugPrint("Fire damage is enabled, but intensity is still below 80: " .. fire["fire_intensity"])
            if fire["burnout"] == true and  fire["damage"] == false then
                if sound_enabled == "ON" then
                    local playSound = FireSim.Generic.rndInt(1, #FireSim.FireDestructionSound)
                    PlaySound(FireSim.FireDestructionSound[playSound], fire["location"], (fire["fire_intensity"] / (100 - (damage_volume * 100)))*random_volume)
                end
                local fire_damage_soft = FireSim.Properties["fire_damage_soft"] / 100 -- take procentile to multiply times intensity
                local fire_damage_medium = FireSim.Properties["fire_damage_medium"] / 100 -- take procentile to multiply times intensity
                local fire_damage_hard = FireSim.Properties["fire_damage_hard"] / 100 -- take procentile to multiply times intensity
                MakeHole(fire["location"], fire_damage_soft * fire["fire_intensity"],
                        fire_damage_medium * fire["fire_intensity"],
                        fire_damage_hard * fire["fire_intensity"], true)
                FireSim.Fires[hash]["damage"] = true
            end
        end
    end
end

function FireSim.DrawFire(dt)
    -- DebugPrint("Drawing Fire Debug")
    local count = 0
    for hash, fire in pairs(FireSim.Fires) do
        count = count + 1
        FireSim.DrawDetectedFire(fire)
    end

    DebugWatch("fires drawn:", tostring(count))
end

function FireSim.Update(dt)
    FireSim.FireSimSequence(dt)
    -- FireSim.FireSim("update", dt)
    -- FireSim.FireSim("tick", dt)

end

function FireSim.Tick(dt)
end

FireSim.Stats = {}


function FireSim.UpdateFireTimers(dt)
    -- DebugPrint("Updating Fire Timers")
    for hash, fire in pairs(FireSim.Fires) do
        FireSim.Fires[hash]["timer"] = FireSim.Fires[hash]["timer"] + dt
        FireSim.Fires[hash]["particle_spawn_timer"] = FireSim.Fires[hash]["particle_spawn_timer"] + dt
    end
end

function FireSim.UpdateBurnStatus(dt)
    -- DebugPrint("Updating Burn Status")
    for hash, fire in pairs(FireSim.Fires) do
        if fire["timer"] > fire["fire_life"] then
            FireSim.Fires[hash]["burnout"] = true
        end

        -- -- If for some reason the fire does not burnout, delete it
        if fire["timer"] > fire["fire_life"] + 10 then
            FireSim.Fires[hash]["delete"] = true
        end
    end


end

function FireSim.DeleteFireItems(dt)

    local to_delete = {}
    for hash, fire in pairs(FireSim.Fires) do
        if fire["delete"] == true then
            -- LightSpawner_UpdateLightIntensity(FireSim.Fires[hash]["light"], 0)
            to_delete[#to_delete+1] = hash
        end
    end

    for _, todelete in ipairs(to_delete) do

        LightSpawner_DeleteLight(FireSim.Fires[todelete]["light"])
        DebugPrint("Deleted light succesfully")
        FireSim.Fires[todelete] = nil
    end
end

function FireSim.UpdateFireStats(dt)
    -- DebugPrint("Updating Fire Stats")
    local total_fires = 0
    for hash, fire in pairs(FireSim.Fires) do
        total_fires = total_fires + 1
    end

    FireSim.LocalDB["fire_count"] = total_fires
end

function FireSim.SpawnFiresParticles(dt)
    for hash, fire in pairs(FireSim.Fires) do
        if FireSim.Fires[hash]["particle_spawn_timer"] > 0.032 then
            FireSim.ParticleSpawner.SpawnFireCallback(hash, fire)

            --FireSim.Fires[hash]["light"] = LightSpawner_SetNewLightLocation(fire["light"],VecAdd(fire["location"], VecScale(fire["normal"], 0.01)))
            --fire["light"] = LightSpawner_SetNewLightSize(fire["light"], FireSim.Generic.rnd( fire["fire_intensity"] / 6 , fire["fire_intensity"] / 4))
            LightSpawner_UpdateLightIntensity(fire["light"], (fire["fire_intensity"] *  FireSim.Generic.rnd(fire["fire_intensity"] / 125, fire["fire_intensity"] / 75) ) / 25)

            FireSim.Fires[hash]["particle_spawn_timer"] = 0
        end
    end
end

local deletelightstimer = 0

function FireSim.FireSimSequence(dt)
    FireSim.SpawnFireOnButtonPress(dt)
    FireSim.UpdateLocationCallback(dt)
    FireSim.UpdateBurnStatus(dt)
    FireSim.UpdateSpreadCallback(dt)
    FireSim.UpdateIntensityCallback(dt)
    FireSim.SpawnFiresParticles(dt)
    FireSim.UpdateFireStats(dt)
    FireSim.UpdateFireTimers(dt)
    FireSim.UpdateSoot(dt)
    FireSim.UpdateFireDamage(dt)
    FireSim.DrawFire(dt)
    FireSim.DeleteFireItems(dt)

    if deletelightstimer > 1 then
        deletelightstimer = 0
        LightSpawner_DeleteAll()
    end
    deletelightstimer = deletelightstimer + dt

    -- for hash, fire in pairs(FireSim.Fires) do

    --     if fire["delete"] then
    --         -- LightSpawner_UpdateLightIntensity(FireSim.Fires[hash]["light"], 0)
    --         FireSim.Fires[hash] = nil


    --     else
    --         total_fires = total_fires + 1

    --         FireSim.UpdateSpreadCallback(hash, fire)
    --         FireSim.UpdateIntensityCallback(hash, fire)
    --         FireSim.UpdateSoot(hash, fire)
    --         FireSim.UpdateFireDamage(hash, fire)
    --         FireSim.DrawFire(hash, fire)
    --         FireSim.UpdateLocationCallback(hash, fire)
    --         --FireSim.ParticleSpawner.SpawnFireCallback(hash, fire)
    --         FireSim.Fires[hash]["timer"] = FireSim.Fires[hash]["timer"] + dt

    --         if FireSim.Fires[hash]["timer"] > FireSim.Fires[hash]["fire_life"] then
    --             FireSim.Fires[hash]["burnout"] = true
    --         end

    --         -- If for some reason the fire does not burnout, delete it
    --         if FireSim.Fires[hash]["timer"] > FireSim.Fires[hash]["fire_life"] + 10 then
    --             FireSim.Fires[hash]["delete"] = true
    --         end
    --     end
    -- end
end

function FireSim.FireSim(type, dt)

    -- local tick_total_callbacks = 0
    -- local update_total_callbacks = 0
    -- local total_fires = 0
    -- for hash, fire in pairs(FireSim.Fires) do
    --     total_fires = total_fires + 1
    --     for id, callbackinfo in pairs(fire["update_callbacks"]) do
    --         if callbackinfo["type"] == type then
    --             if callbackinfo["timer"] >= callbackinfo["interval"] then
    --                 callbackinfo["callback"](hash, fire)
    --                 callbackinfo["timer"] = 0

    --                 if FireSim.Stats[id .. "_" .. type] == nil then
    --                     FireSim.Stats[id .. "_" .. type] = 0
    --                 end
    --                 FireSim.Stats[id .. "_" .. type] = FireSim.Stats[id .. "_" .. type] + 1
    --                 if callbackinfo["type"] == "update" then
    --                     update_total_callbacks = update_total_callbacks + 1
    --                 else
    --                     tick_total_callbacks = tick_total_callbacks + 1
    --                 end
    --             end
    --             callbackinfo["timer"] = callbackinfo["timer"] + dt
    --         end
    --     end


    --     if fire["delete"] then
    --         for id, callbackinfo in pairs(fire["delete_callbacks"]) do
    --             if callbackinfo["timer"] >= callbackinfo["interval"] then
    --                 callbackinfo["callback"](hash, fire)
    --                 callbackinfo["timer"] = 0
    --             end
    --             callbackinfo["timer"] = callbackinfo["timer"] + dt
    --         end
    --        LightSpawner_UpdateLightIntensity(fire["light"], 0)
    --         FireSim.Fires[hash] = nil
    --     end

    --     FireSim.Fires[hash]["timer"] = FireSim.Fires[hash]["timer"] + dt
    -- end

    -- for id, count in pairs(FireSim.Stats) do
    --     DebugWatch("Callback " .. id .. " Count", count)
    -- end
    -- if type == "tick" then
    --     DebugWatch("Dt | Total Callbacks Per Tick", tostring(dt) .. "|"..  tostring(tick_total_callbacks))
    -- else
    --     DebugWatch("Dt | Total Callbacks Per Update", tostring(dt) .. "|"..  tostring(update_total_callbacks))
    -- end
    -- FireSim.LocalDB["fire_count"] = total_fires

end

function FireSim.GenerateFireObject(location, normal, material, shape, firebaseinfo, start_fire_intensity)

    local min_fire_intensity = FireSim.Properties["fire_intensity_minimum"]
    local min_fire_distance = FireSim.Properties["min_fire_distance"]
    if min_fire_distance < 0.1 then min_fire_distance = 0.1 end
    local rho = FireSim.Generic.rnd(FireSim.MaterialInfo[material]["rho"]["min"], FireSim.MaterialInfo[material]["rho"]["max"])
    local heatcapacity = FireSim.Generic.rnd(FireSim.MaterialInfo[material]["heatcapacity"]["min"], FireSim.MaterialInfo[material]["heatcapacity"]["max"])
    local burnout_percentage = FireSim.Generic.rndInt(15, 80)
	local x, y, z = GetShapeSize(shape)
    local max_percentage =  ((x + y + z))
    -- DebugPrint("Max fire precentag: " .. max_percentage)
    if max_percentage  > 100 then
        max_percentage = 100
    end

    if burnout_percentage > max_percentage then
        burnout_percentage = max_percentage * 0.75
    end

    local firemat = ParticleSpawner.FireMaterial.GetInfo(material)


    local light =  LightSpawner_Spawn(VecAdd(location, VecScale(normal, 0.1)), min_fire_intensity / 25, (min_fire_intensity * min_fire_intensity)/ 25, Vec(firemat["color"]["r"],firemat["color"]["g"],firemat["color"]["n"]), true)
    local fire_life = FireSim.Generic.rnd(5, 20)

    if start_fire_intensity == nil then
        start_fire_intensity = min_fire_intensity
    end

    local new_obj = {
        location = location,
        material = material,
        rho = rho,
        heatcapacity = heatcapacity,
        original_fire_intensity = start_fire_intensity,
        fire_intensity = start_fire_intensity,
        shape = shape,
        original = firebaseinfo,
        amounttospawn=0,
        spawnnew = true,
        spawnednew = false,
        delete = false,
        soot = false,
        inside = nil,
        burnout_percentage = burnout_percentage,
        max_percentage = max_percentage,
        damage = false,
        normal = normal,
        burnout=false,
        burnout_timestamp=0,
        fire_life=fire_life,
        extinghuishing=false,
        extinghuishing_rate=0,
        particle_spawn_timer=0,
        timer=0,
        light=light,
        playsound=nil,
        playsound_random = 0,
        playsound_damage_random = 0
    }
    return new_obj
end

function FireSim.SpawnFireOnButtonPress(dt)
    local showDebug = false
    if FireSim.Properties["visualize_fire_detection"] == "ON" then
        showDebug = true
    end

    local min_fire_intensity = FireSim.Properties["fire_intensity_minimum"]
    local min_fire_distance = FireSim.Properties["min_fire_distance"]
    local material_allowed = FireSim.Properties["material_allowed"]
    if min_fire_distance < 0.1 then min_fire_distance = 0.1 end
    if InputReleased("lmb") and GetString("game.player.tool") == "blowtorch" then
        -- DebugPrint("LMB Clicked")
        local ct = GetCameraTransform()
        local pos = ct.pos
        local dir = TransformToParentVec(ct, Vec(0, 0, -1))
        local hit, dist, normal, shape = QueryRaycast(pos, dir, 500)
        if hit then
            -- DebugPrint("HIT")
            local hitPoint = VecAdd(pos, VecScale(dir, dist))
            local material = GetShapeMaterialAtPosition(shape, hitPoint)
            -- DebugPrint(material)

            if material_allowed[material] then
                -- DebugPrint("Allowed")
                local hash = FireSim.Generic.HashVec(hitPoint)

                local newDist = min_fire_distance / 100 * min_fire_intensity
                local outerpoints = FireSim.Generic.CreateBox(hitPoint, newDist, nil, {1, 1, 0}, showDebug)
                local firebaseinfo = {hitPoint, 0, hitPoint, newDist, hitPoint, min_fire_intensity, outerpoints}


                local vecToCheck =  VecAdd(hitPoint, newDist * 4)

                for checkhash, checkFire in pairs(FireSim.Fires) do
                    local distToCheck = newDist

                    -- if checkFire["original"][6] > distToCheck then
                    --     distToCheck = checkFire["original"][6]
                    -- end
                    if FireSim.Generic.VecDistance(checkFire["original"][3], vecToCheck) < distToCheck then
                        DebugPrint("Did not spawn fire, already fire at location")
                        return false
                    end
                end

                DebugPrint("Adding fire")
                FireSim.Fires[hash] = FireSim.GenerateFireObject(hitPoint, normal, material, shape, firebaseinfo, min_fire_intensity)
                DebugPrint("Fire Added")
            end
        end
    end

    return true
end

function FireSim.ExtinguishFire(hash, rate)
    FireSim.Fires[hash]["extinghuishing_rate"] = FireSim.Fires[hash]["extinghuishing_rate"] + rate
    DebugPrint("Extinguishing fire: " .. hash .. ", Extinguishrate: " .. tostring(FireSim.Fires[hash]["extinghuishing_rate"]) .. "%, Current Intensity: " .. tostring(FireSim.Fires[hash]["fire_intensity"]))
    if(FireSim.Fires[hash]["fire_intensity"] < FireSim.Fires[hash]["original_fire_intensity"] ) or FireSim.Fires[hash]["extinghuishing_rate"] > FireSim.Fires[hash]["fire_intensity"]  then
        FireSim.Fires[hash]["extinghuishing"] = true
        FireSim.Fires[hash]["spawnnew"] = false
    end
end


function FireSim.CheckDirection(hash, fire, newDist, tries, min_fire_distance)
    local material_allowed = FireSim.Properties["material_allowed"]

    -- DebugPrint("Searching dir: {"..dir[1]..","..dir[2]..","..dir[3].."}, direction size: " .. newDist .. " amount: " .. newFireCount)

    local origin = fire["location"]
    local actualNewDist = newDist
    local toReturn = nil
    local vectors = {
        {1, 0, 0},  -- Positive x-direction
        {-1, 0, 0}, -- Negative x-direction
        {0, 1, 0},  -- Positive y-direction
        {0, -1, 0}, -- Negative y-direction
        {0, 0, 1},  -- Positive z-direction
        {0, 0, -1}, -- Negative z-direction
        {1, 1, 0},  -- Positive x and y direction
        {1, -1, 0}, -- Positive x and negative y direction
        {-1, 1, 0}, -- Negative x and positive y direction
        {-1, -1, 0},-- Negative x and y direction
        {1, 0, 1},  -- Positive x and z direction
        {1, 0, -1}, -- Positive x and negative z direction
        {-1, 0, 1}, -- Negative x and positive z direction
        {-1, 0, -1},-- Negative x and z direction
        {0, 1, 1},  -- Positive y and z direction
        {0, 1, -1}, -- Positive y and negative z direction
        {0, -1, 1}, -- Negative y and positive z direction
        {0, -1, -1},-- Negative y and z direction
        {1, 1, 1},  -- Positive x, y, and z direction
        {1, 1, -1}, -- Positive x, y, and negative z direction
        {1, -1, 1}, -- Positive x, negative y, and positive z direction
        {1, -1, -1},-- Positive x, negative y, and z direction
        {-1, 1, 1}, -- Negative x, positive y, and z direction
        {-1, 1, -1},-- Negative x, positive y, and negative z direction
        {-1, -1, 1},-- Negative x, y, and positive z direction
        {-1, -1, -1}-- Negative x, y, and z direction
    }

    local locations = {}
    local hashes = {}
    for h, f in pairs(FireSim.Fires) do
        -- DebugPrint("Copying location: " .. tostring(f["location"]))
        if fire['fire_intensity'] > f["fire_intensity"] and h ~= hash then
            locations[#locations+1] = f["location"]
            hashes[#hashes+1] = h
        end
    end

    DebugPrint("Trying to find fire in {" .. tostring(tries) .. "} tries")


    for x = 1, tries do

        -- Spread more upwards
        local direction = vectors[FireSim.Generic.rndInt(1 , #vectors-1)]

        if FireSim.Generic.rndInt(1 , 2) == 1 and direction[2] ~= 1 then
            direction[2]  = 1
        end
        -- DebugPrint("Trying to find fire in direction")
        -- DebugPrint(direction)

        local newpoint = VecAdd(origin, VecScale(direction, actualNewDist))


        -- DebugPrint("searching points:")
        -- DebugPrint(origin)
        -- DebugPrint(newpoint)
        local hit, point, normal, shape_hit = QueryClosestPoint(newpoint, actualNewDist)
        if hit then
            DebugPrint("Found, total locs to check: " .. #locations)
            local inrange = nil
            if #locations > 0 then
                inrange = FireSim.Generic.isWithinRange(point, locations, min_fire_distance)
            end

            local hash = FireSim.Generic.HashVec(point)
            local material = GetShapeMaterialAtPosition(shape_hit, point)
            if material_allowed[material] then
                DebugPrint("New point!")
                toReturn = {hash, 1, point, newpoint, material, actualNewDist, shape_hit, normal, inrange}
                break
            end
        else
            actualNewDist = actualNewDist + (fire['fire_intensity'] / 200)
            DebugPrint("No hit at dist, try: " .. actualNewDist)
        end
    end
    -- end
    -- DebugPrint("Finished finding fires")
    return toReturn
end

---Use this in the draw function!
function FireSim.ShowStatus()
    if FireSim.GeneralOptions.GetShowUiInGame() == "YES" then
        DebugWatch("FireSim, Fire count",
                   FireSim.LocalDB["fire_count"])
        DebugWatch("FireSim, time elapsed",
                   tostring(FireSim.LocalDB["time_elapsed"]))
        DebugWatch("FireSim, intensity",
                   tostring(FireSim.LocalDB["fire_intensity"]))
        DebugWatch("FireSim, randomtimer",
                   tostring(FireSim.LocalDB["random_timer"]))
        DebugWatch("FireSim, timer",
                   tostring(FireSim.LocalDB["timer"]))
        DebugWatch("FireSim, map_size",
                   tostring(FireSim.Properties["map_size"]))
    end
end

