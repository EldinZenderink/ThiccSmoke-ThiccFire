-- FireSimPerFireCallback.lua
-- @date 2022-08-28
-- @author Eldin Zenderink
-- @brief Detects fires and 'manages' their behavior

FireSim = {}

FireSimPerFireCallback.Properties = {
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
    fire_damage_soft = 0.1,
    fire_damage_medium = 0.05,
    fire_damage_hard = 0.01,
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

FireSimPerFireCallback.MaterialInfo = {
    -- density loosly based on https://en.wikipedia.org/wiki/Density
    -- heat capacity loosly based on https://www.engineeringtoolbox.com/specific-heat-solids-d_154.html
    wood = {
        rho = {
            min=373,
            max=850
        },
        heatcapacity = {
            min=2,
            max=2.9
        }
    },
    foliage =
    {
        rho = {
            min=240,
            max=350
        },
        heatcapacity = {
            min=1.2,
            max=1.6
        }
    },
    plaster =
    {
        rho = {
            min=600,
            max=1600
        },
        heatcapacity = {
            min=0.9,
            max=1
        }
    },
    plastic =
    {
        rho = {
            min=1000,
            max=1200
        },
        heatcapacity = {
            min=1.3,
            max=1.7
        }
    }
}

--- Some global properties
FireSimPerFireCallback.LocalDB = {
    time_elapsed = 0,
    fire_count = 0,
    fire_intensity = 1,
    timer = 0,
    random_timer = 0
}

-- Store all shapes that could potentially be detached from shapes on fire (BPOF = shapes potentially on fire)
FireSimPerFireCallback.Fires = {}

-- Global trigger to update fires from particle spawner (makes sense...)
FireSimPerFireCallback.UpdateFires = false

-- Courtesy of: https://www.fesliyanstudios.com/royalty-free-sound-effects-download/glass-shattering-and-breaking-124
FireSimPerFireCallback.GlassBreakingSnd = {}

-- Visualize fires
FireSimPerFireCallback.Visualize = false

-- Register fire handlers
FireSimPerFireCallback.UpdateCallbacks = {}
FireSimPerFireCallback.DeleteCallbacks = {}

-- Fire spread directions
FireSimPerFireCallback.SpreadDirections = {
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
FireSimPerFireCallback.FireSound = {}
FireSimPerFireCallback.FireDestructionSound = {}



-- local FireSimPerFireCallback.RecursiveBinarySearchFire = FireSimPerFireCallback.RecursiveBinarySearchFire
-- local pairs = pairs


---Initialize the properties of the module
---@param default bool -- set to true to set all properties to their default configured values
function FireSimPerFireCallback.Init(argGeneric, argParticleSpawner, argSettings, argGeneralOptions, argCompatibility)
    FireSimPerFireCallback.Generic = argGeneric
    FireSimPerFireCallback.ParticleSpawner = argParticleSpawner
    FireSimPerFireCallback.Settings = argSettings
    FireSimPerFireCallback.GeneralOptions = argGeneralOptions
    FireSimPerFireCallback.Compatibility = argCompatibility

    FireSimPerFireCallback.Settings.RegisterUpdateSettingsCallback(FireSimPerFireCallback.UpdateSettingsFromSettings)

    for i = 1, 12 do
        FireSimPerFireCallback.GlassBreakingSnd[i] = LoadSound(
                                               "MOD/sound/glass/00 - www.fesliyanstudios.com - " ..
                                                   i .. ".ogg")
    end


    -- Load sound
    for x = 0, 1 do
        FireSimPerFireCallback.FireDestructionSound[#FireSimPerFireCallback.FireDestructionSound+1] = LoadSound("MOD/sound/firecollapse/fc"..x..".ogg")
    end

    for x = 0, 3 do
        FireSimPerFireCallback.FireSound[#FireSimPerFireCallback.FireSound+1] = LoadLoop("MOD/sound/fire/"..x..".ogg")
    end
end

---Retrieve properties from storage and apply them
function FireSimPerFireCallback.UpdateSettingsFromSettings()
    DebugPrint("Update from settings")
    FireSimPerFireCallback.Properties["map_size"] =
        FireSimPerFireCallback.Settings.GetValue("FireSim", "map_size")
    FireSimPerFireCallback.Properties["max_fire_spread_distance"] = FireSimPerFireCallback.Settings.GetValue(
                                                              "FireSim",
                                                              "max_fire_spread_distance")
    FireSimPerFireCallback.Properties["fire_reaction_time"] = FireSimPerFireCallback.Settings.GetValue(
                                                        "FireSim",
                                                        "fire_reaction_time")
    FireSimPerFireCallback.Properties["fire_update_time"] = FireSimPerFireCallback.Settings.GetValue(
                                                      "FireSim",
                                                      "fire_update_time")
    FireSimPerFireCallback.Properties["max_fire"] =
        FireSimPerFireCallback.Settings.GetValue("FireSim", "max_fire")
    FireSimPerFireCallback.Properties["min_fire_distance"] = FireSimPerFireCallback.Settings.GetValue(
                                                       "FireSim",
                                                       "min_fire_distance")
    FireSimPerFireCallback.Properties["max_group_fire_distance"] = FireSimPerFireCallback.Settings.GetValue(
                                                             "FireSim",
                                                             "max_group_fire_distance")
    FireSimPerFireCallback.Properties["visualize_fire_detection"] = FireSimPerFireCallback.Settings.GetValue(
                                                              "FireSim",
                                                              "visualize_fire_detection")
    FireSimPerFireCallback.Properties["fire_intensity"] = FireSimPerFireCallback.Settings.GetValue(
                                                    "FireSim",
                                                    "fire_intensity")
    FireSimPerFireCallback.Properties["fire_intensity_multiplier"] = FireSimPerFireCallback.Settings.GetValue(
                                                               "FireSim",
                                                               "fire_intensity_multiplier")
    FireSimPerFireCallback.Properties["fire_intensity_minimum"] = FireSimPerFireCallback.Settings.GetValue(
                                                            "FireSim",
                                                            "fire_intensity_minimum")
    FireSimPerFireCallback.Properties["fire_explosion"] = FireSimPerFireCallback.Settings.GetValue(
                                                    "FireSim",
                                                    "fire_explosion")
    FireSimPerFireCallback.Properties["fire_damage"] =
        FireSimPerFireCallback.Settings.GetValue("FireSim", "fire_damage")
    FireSimPerFireCallback.Properties["spawn_fire"] =
        FireSimPerFireCallback.Settings.GetValue("FireSim", "spawn_fire")
    FireSimPerFireCallback.Properties["detect_inside"] =
        FireSimPerFireCallback.Settings.GetValue("FireSim", "detect_inside")
    FireSimPerFireCallback.Properties["soot_sim"] =
        FireSimPerFireCallback.Settings.GetValue("FireSim", "soot_sim")
    FireSimPerFireCallback.Properties["soot_dithering_max"] = FireSimPerFireCallback.Settings.GetValue(
                                                        "FireSim",
                                                        "soot_dithering_max")
    FireSimPerFireCallback.Properties["soot_dithering_min"] = FireSimPerFireCallback.Settings.GetValue(
                                                        "FireSim",
                                                        "soot_dithering_min")
    FireSimPerFireCallback.Properties["soot_max_size"] =
        FireSimPerFireCallback.Settings.GetValue("FireSim", "soot_max_size")
    FireSimPerFireCallback.Properties["soot_min_size"] =
        FireSimPerFireCallback.Settings.GetValue("FireSim", "soot_min_size")
    FireSimPerFireCallback.Properties["fire_damage_soft"] = FireSimPerFireCallback.Settings.GetValue(
                                                      "FireSim",
                                                      "fire_damage_soft")
    FireSimPerFireCallback.Properties["fire_damage_medium"] = FireSimPerFireCallback.Settings.GetValue(
                                                        "FireSim",
                                                        "fire_damage_medium")
    FireSimPerFireCallback.Properties["fire_damage_hard"] = FireSimPerFireCallback.Settings.GetValue(
                                                      "FireSim",
                                                      "fire_damage_hard")
    FireSimPerFireCallback.Properties["teardown_max_fires"] = FireSimPerFireCallback.Settings.GetValue(
                                                        "FireSim",
                                                        "teardown_max_fires")
    FireSimPerFireCallback.Properties["teardown_fire_spread"] = FireSimPerFireCallback.Settings.GetValue(
                                                          "FireSim",
                                                          "teardown_fire_spread")


    FireSimPerFireCallback.Properties["despawn_td_fire"] = FireSimPerFireCallback.Settings.GetValue(
        "FireSim",
        "despawn_td_fire")


    FireSimPerFireCallback.Properties["enable_sound"] = FireSimPerFireCallback.Settings.GetValue(
        "FireSim",
        "enable_sound")

    FireSimPerFireCallback.Properties["fire_sound_volume"] = FireSimPerFireCallback.Settings.GetValue(
        "FireSim",
        "fire_sound_volume")

    FireSimPerFireCallback.Properties["fire_sound_volume_random"] = FireSimPerFireCallback.Settings.GetValue(
        "FireSim",
        "fire_sound_volume_random")

    FireSimPerFireCallback.Properties["damage_sound_volume"] = FireSimPerFireCallback.Settings.GetValue(
        "FireSim",
        "damage_sound_volume")

    FireSimPerFireCallback.Properties["damage_sound_volume_random"] = FireSimPerFireCallback.Settings.GetValue(
        "FireSim",
        "damage_sound_volume_random")


    if FireSimPerFireCallback.Properties["visualize_fire_detection"] == "ON" then
        FireSimPerFireCallback.Visualize = true
    else
        FireSimPerFireCallback.Visualize = false
    end
    -- No Fire Limit mod is disabled/does not work when ThiccSmoke / ThiccFire is enabled, since it adjusts the same settings
    if FireSimPerFireCallback.Compatibility.IsSettingCompatible("teardown_max_fires") then
        SetInt("game.fire.maxcount",
               math.floor(FireSimPerFireCallback.Properties["teardown_max_fires"]))
        SetInt("game.fire.spread",
               math.floor(FireSimPerFireCallback.Properties["teardown_fire_spread"]))
    end

    if  FireSimPerFireCallback.Properties["despawn_td_fire"] == nil or
        FireSimPerFireCallback.Properties["despawn_td_fire"] == "" then
        FireSimPerFireCallback.Properties["despawn_td_fire"] = "YES"
        FireSimPerFireCallback.Settings.SetValue("FireSim", "despawn_td_fire", "YES")
    end

    if FireSimPerFireCallback.Properties["despawn_td_fire"] == "YES" then
        FireSimPerFireCallback.Properties["spawn_fire"] = "YES" -- Must spawn additional fires otherwise fires will dissapear
    end

    if FireSimPerFireCallback.Properties["detect_inside"] == nil or
        FireSimPerFireCallback.Properties["detect_inside"] == "" then
        FireSimPerFireCallback.Properties["detect_inside"] = "YES"
        FireSimPerFireCallback.Settings.SetValue("FireSim", "detect_inside", "YES")
    end

    if FireSimPerFireCallback.Properties["soot_sim"] == nil or
        FireSimPerFireCallback.Properties["soot_sim"] == "" then
        FireSimPerFireCallback.Properties["soot_sim"] = "NO"
        FireSimPerFireCallback.Settings.SetValue("FireSim", "soot_sim", "NO")
    end

    if FireSimPerFireCallback.Properties["soot_dithering_max"] == nil or
        FireSimPerFireCallback.Properties["soot_dithering_max"] == 0 then
        FireSimPerFireCallback.Properties["soot_dithering_max"] = 1
        FireSimPerFireCallback.Settings.SetValue("FireSim", "soot_dithering_max", 1)
    end
    if FireSimPerFireCallback.Properties["soot_max_size"] == nil or
        FireSimPerFireCallback.Properties["soot_max_size"] == 0 then
        FireSimPerFireCallback.Properties["soot_max_size"] = 5
        FireSimPerFireCallback.Settings.SetValue("FireSim", "soot_max_size", 5)
    end
    if FireSimPerFireCallback.Properties["soot_dithering_min"] == nil or
        FireSimPerFireCallback.Properties["soot_dithering_min"] == 0 then
        FireSimPerFireCallback.Properties["soot_dithering_min"] = 1
        FireSimPerFireCallback.Settings.SetValue("FireSim", "soot_dithering_min", 1)
    end
    if FireSimPerFireCallback.Properties["soot_min_size"] == nil or
        FireSimPerFireCallback.Properties["soot_min_size"] == 0 then
        FireSimPerFireCallback.Properties["soot_min_size"] = 5
        FireSimPerFireCallback.Settings.SetValue("FireSim", "soot_min_size", 5)
    end

    if FireSimPerFireCallback.Properties["map_size"] == nil or
        FireSimPerFireCallback.Properties["map_size"] == "" then
        FireSimPerFireCallback.Properties["map_size"] = "MEDIUM"
        FireSimPerFireCallback.Settings.SetValue("FireSim", "map_size", "MEDIUM")
    end

    if FireSimPerFireCallback.Properties["enable_sound"] == nil or
        FireSimPerFireCallback.Properties["enable_sound"] == "" then
        FireSimPerFireCallback.Properties["enable_sound"] = "ON"
        FireSimPerFireCallback.Settings.SetValue("FireSim", "enable_sound", "ON")
    end

    if FireSimPerFireCallback.Properties["fire_sound_volume"] == nil or
        FireSimPerFireCallback.Properties["fire_sound_volume"] == "" then
        FireSimPerFireCallback.Properties["fire_sound_volume"] = 0.5
        FireSimPerFireCallback.Settings.SetValue("FireSim", "fire_sound_volume", 0.5)
    end


    if FireSimPerFireCallback.Properties["fire_sound_volume_random"] == nil or
        FireSimPerFireCallback.Properties["fire_sound_volume_random"] == "" then
        FireSimPerFireCallback.Properties["fire_sound_volume_random"] = 0
        FireSimPerFireCallback.Settings.SetValue("FireSim", "fire_sound_volume_random", 0)
    end


    if FireSimPerFireCallback.Properties["damage_sound_volume"] == nil or
        FireSimPerFireCallback.Properties["damage_sound_volume"] == "" then
        FireSimPerFireCallback.Properties["damage_sound_volume"] = 0.5
        FireSimPerFireCallback.Settings.SetValue("FireSim", "damage_sound_volume", 0.5)
    end


    if FireSimPerFireCallback.Properties["damage_sound_volume_random"] == nil or
        FireSimPerFireCallback.Properties["damage_sound_volume_random"] == "" then
        FireSimPerFireCallback.Properties["damage_sound_volume_random"] = 0
        FireSimPerFireCallback.Settings.SetValue("FireSim", "damage_sound_volume_random", 0)
    end


    -- FireSimPerFireCallback.RegisterUpdateFireCallback("FireSound", FireSimPerFireCallback.SoundPlayback, 0) -- 0 == every tic
    FireSimPerFireCallback.RegisterUpdateFireCallback("update", "LocationCallback", FireSimPerFireCallback.UpdateLocationCallback, FireSimPerFireCallback.Properties["fire_update_time"])
    FireSimPerFireCallback.RegisterUpdateFireCallback("update", "IntensityCallback", FireSimPerFireCallback.UpdateIntensityCallback, FireSimPerFireCallback.Properties["fire_update_time"] * 2)
    FireSimPerFireCallback.RegisterUpdateFireCallback("update", "SpreadCallback", FireSimPerFireCallback.UpdateSpreadCallback, FireSimPerFireCallback.Properties["fire_update_time"])
    FireSimPerFireCallback.RegisterUpdateFireCallback("update", "Soot", FireSimPerFireCallback.UpdateSoot, FireSimPerFireCallback.Properties["fire_update_time"] * 10)
    FireSimPerFireCallback.RegisterUpdateFireCallback("update", "FireDamage", FireSimPerFireCallback.UpdateFireDamage, FireSimPerFireCallback.Properties["fire_update_time"] * 10)
    FireSimPerFireCallback.RegisterUpdateFireCallback("tick", "DrawFire", FireSimPerFireCallback.DrawFire, 0)
    FireSimPerFireCallback.RegisterUpdateFireCallback("tick", "ParticleSpawner", FireSimPerFireCallback.ParticleSpawner.SpawnFireCallback, 0.050)




end

function FireSimPerFireCallback.DrawDetectedFire(fireinfo)
    local showDebug = false
    if FireSimPerFireCallback.Properties["visualize_fire_detection"] == "ON" then
        showDebug = true
    end

    local fireInensityPercentageNormalized = 0.01 * (fireinfo["fire_intensity"])
    if fireinfo["extinghuishing"] then
        local fireIntensityColors = {
            1 - fireInensityPercentageNormalized,
            1 - fireInensityPercentageNormalized,
            0.0
        }
        FireSimPerFireCallback.Generic.CreateBox(
            fireinfo["original"][3],
            fireInensityPercentageNormalized / 2,
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
        FireSimPerFireCallback.Generic.CreateBox(
            fireinfo["original"][3],
            fireInensityPercentageNormalized / 2,
            nil,
            fireIntensityColors,
            showDebug
        )
    end
    FireSimPerFireCallback.Generic.DrawPoint(fireinfo["original"][3], 1, 0, 0, showDebug)
    if fireinfo["inside"] ~= nil and fireinfo["inside"] == true then
        FireSimPerFireCallback.Generic.DrawPoint(fireinfo["original"][1], 1, 0, 1, showDebug)
    else
        FireSimPerFireCallback.Generic.DrawPoint(fireinfo["original"][1], 0, 1, 1, showDebug)
    end
end

function FireSimPerFireCallback.RegisterUpdateFireCallback(type, id, callback, interval)
    FireSimPerFireCallback.UpdateCallbacks[id] = {
        callback=callback,
        interval=interval,
        type=type,
        timer=0
    }
    DebugPrint("Registered fire callback: " .. id .. "  at interval: " .. interval)

    for h, f in pairs(FireSimPerFireCallback.Fires) do
        FireSimPerFireCallback.Fires[h]["update_callbacks"] = FireSimPerFireCallback.Generic.deepCopy(FireSimPerFireCallback.UpdateCallbacks)
    end
end

function FireSimPerFireCallback.RegisterDeleteFireCallback(type, id, callback, interval)
    FireSimPerFireCallback.DeleteCallbacks[id] = {
        callback=callback,
        interval=interval,
        type=type,
        timer=0
    }
    for h, f in pairs(FireSimPerFireCallback.Fires) do
        FireSimPerFireCallback.Fires[h]["delete_callbacks"] = FireSimPerFireCallback.Generic.deepCopy(FireSimPerFireCallback.DeleteCallbacks)
    end
end

function FireSimPerFireCallback.SoundPlayback(hash, fire)
    local random = FireSimPerFireCallback.Properties["fire_sound_volume_random"]
    local fire_volume = FireSimPerFireCallback.Properties["fire_sound_volume"]
    if fire["playsound"] ~= nil and fire["playsound"] > 0 and FireSimPerFireCallback.Properties["enable_sound"] == "ON" then
        -- DebugPrint("Playing loop: " .. fire["playsound"] .. " for: " .. hash)

        if fire["playsound_random"] == 0 then
            fire["playsound_random"] = 1 + FireSimPerFireCallback.Generic.rnd(-random, random)
        end

        PlayLoop(FireSimPerFireCallback.FireSound[fire["playsound"]], fire["location"], ((fire["fire_intensity"] / 100) * fire_volume) * fire["playsound_random"])
    end
end


function FireSimPerFireCallback.IsFireOverlapping(hash, marginInsidePercentage)
    for checkhash, checkFire in pairs(FireSimPerFireCallback.Fires) do
        if checkhash ~= hash and checkFire["fire_intensity"] > FireSimPerFireCallback.Fires[hash]["fire_intensity"] then
            local distToCheck = marginInsidePercentage

            distToCheck = distToCheck * (checkFire["fire_intensity"] / 100) * 2

            local fireDistance = FireSimPerFireCallback.Generic.VecDistance(checkFire["location"], FireSimPerFireCallback.Fires[hash]["location"])

            if fireDistance < distToCheck then
                -- Return only true if the fire that is used for comparing is smaller than the overlapping fire in intensity
                -- e.g. to be used to determine if a fire should be extinghuished by another fire
                DebugPrint("Fire: " .. hash .. " is to closer to fire: " .. checkhash .. ", distance: " .. fireDistance)
                return checkFire
            end
        end
    end
    return nil
end

function FireSimPerFireCallback.UpdateLocationCallback(hash, fire)
    local material = GetShapeMaterialAtPosition(fire["shape"], fire["location"])
    local material_allowed = FireSimPerFireCallback.Properties["material_allowed"]
    if material == "" then
        local hit, point, normal, shape_hit = QueryClosestPoint(fire["location"], 1)
        if hit then
            material = GetShapeMaterialAtPosition(shape_hit, point)
            if material_allowed[material] then
                fire["location"] = point
                fire["original"][3] = point
                fire["shape"] = shape_hit
                fire["normal"] = normal
            else
                fire["fire_intensity"] = 0
                fire["delete"] = true
            end
        else
            fire["fire_intensity"] = 0
            fire["delete"] = true
        end
    end
end

function FireSimPerFireCallback.UpdateIntensityCallback(hash, fire)

    local showDebug = false
    if FireSimPerFireCallback.Properties["visualize_fire_detection"] == "ON" then
        showDebug = true
    end
    local time = fire["timer"]
    local speedmultiplier = FireSimPerFireCallback.Properties["fire_intensity_multiplier"]
    local min_fire_distance = FireSimPerFireCallback.Properties["min_fire_distance"]
    local material = fire["material"]
    local rho = FireSimPerFireCallback.Generic.rnd(FireSimPerFireCallback.MaterialInfo[material]["rho"]["min"], FireSimPerFireCallback.MaterialInfo[material]["rho"]["max"])
    local heatcapacity = FireSimPerFireCallback.Generic.rnd(FireSimPerFireCallback.MaterialInfo[material]["heatcapacity"]["min"], FireSimPerFireCallback.MaterialInfo[material]["heatcapacity"]["max"])

    if fire["burnout"] == false and fire["extinghuishing"] == false  then
        local newFireIntensity = fire["fire_intensity"] + FireSimPerFireCallback.Generic.rnd( (((math.ceil(time * 50)) / (rho * heatcapacity)))  * -0.5,   (((math.ceil(time * 100)) / (rho * heatcapacity)) * speedmultiplier))  - (fire["extinghuishing_rate"])
        newFireIntensity = FireSimPerFireCallback.Generic.rnd(newFireIntensity / 1.25, newFireIntensity)
        if newFireIntensity >= 100 then
            newFireIntensity = 100
        end

        if newFireIntensity > fire["burnout_percentage"] then
            if fire["burnout_timestamp"] == 0 then
                fire["burnout_timestamp"] = fire["timer"]
            end

            if fire["timer"] > FireSimPerFireCallback.Generic.rndInt(5, 10) + fire["burnout_timestamp"] then
                fire["burnout"] = true
            end
        end

        local checkOverlap = FireSimPerFireCallback.IsFireOverlapping(hash, min_fire_distance)

        -- If there is overlap we must burnout to prevent unecesarily stacking fire
        if checkOverlap ~= nil then

            DebugPrint("Trying to spawn new fire for " .. hash)
            local distanceBasedOnFireIntensity = checkOverlap["fire_intensity"] / 100 ;
            local result = FireSimPerFireCallback.CheckDirection(fire, distanceBasedOnFireIntensity, 4)
            if result ~= nil then
                local outerpoints = FireSimPerFireCallback.Generic.CreateBox(result[3], result[6], nil, {0, 1, 0}, showDebug)
                local firebaseinfo = {result[3], 0, result[4], result[6] / 2, result[3], fire["fire_intensity"], outerpoints}
                local startinIntensity = fire["fire_intensity"]
                FireSimPerFireCallback.Fires[result[1]] = FireSimPerFireCallback.GenerateFireObject(result[4], result[8], result[5], result[7], firebaseinfo, startinIntensity)
            end
            fire["delete"] = true
        end
        fire["fire_intensity"] = newFireIntensity
        if fire["extinghuishing_rate"] > 0 then
            fire["extinghuishing_rate"] = fire["extinghuishing_rate"] - 0.5
        end
        -- DebugWatch("fire_intensity_"..hash, tostring(fire["fire_intensity"]) .. "%_burning_"..fire["extinghuishing_rate"].."%_extinguisingrate")
    elseif fire["fire_intensity"] > 0  and fire["extinghuishing"] == true then
        fire["fire_intensity"] = fire["fire_intensity"] - (fire["extinghuishing_rate"] / 20)
        -- DebugWatch("fire_intensity_"..hash, tostring(fire["fire_intensity"]) .. "%_extinguishing_"..fire["extinghuishing_rate"].."%_extinguisingrate")
    elseif fire["fire_intensity"] > 0  and fire["burnout"] == true then
        fire["fire_intensity"] = fire["fire_intensity"] -  1
        -- DebugWatch("fire_intensity_"..hash, tostring(fire["fire_intensity"]) .. "%_burnout")
    else
        -- DebugWatch("fire_intensity_"..hash, tostring(fire["fire_intensity"]) .. "%_deleted")
        fire["delete"] = true
    end


    if fire["fire_intensity"] < 15 or fire["playsound"] == nil then
        fire["playsound"] = 1
    elseif fire["fire_intensity"] > 15 and fire["playsound"] < 2 then
        fire["playsound"] = 2
    elseif fire["fire_intensity"] > 25 and fire["playsound"] < 3 then
        fire["playsound"] = 3
    elseif fire["fire_intensity"] > 75 and fire["playsound"] < 4 then
        fire["playsound"] = 4
    end
end

function FireSimPerFireCallback.UpdateSpreadCallback(hash, fire)
    local max_fires = FireSimPerFireCallback.Properties["max_fire"]
    local current_fires = FireSimPerFireCallback.LocalDB["fire_count"]
    local min_fire_distance = FireSimPerFireCallback.Properties["min_fire_distance"]
    DebugWatch("max_fires_vs_current_fires", tostring(max_fires) .. " vs " .. tostring(current_fires))

    if  current_fires <= max_fires  and
        fire["spawnnew"] == true and
        fire["spawnednew"] == false and
        fire["fire_intensity"] >= 25 then
        local newFireCount = FireSimPerFireCallback.Generic.rndInt(2, fire["fire_intensity"] / 5 + 2)
        if  FireSimPerFireCallback.Fires[hash]["amounttospawn"] == 0 then
            FireSimPerFireCallback.Fires[hash]["amounttospawn"] = newFireCount
            DebugPrint(hash .. "New fire count to spwn: " .. tostring(FireSimPerFireCallback.Fires[hash]["amounttospawn"]))
        else
            local showDebug = false
            if FireSimPerFireCallback.Properties["visualize_fire_detection"] == "ON" then
                showDebug = true
            end

            DebugPrint("Trying to spawn new fire for " .. hash)
            local distanceBasedOnFireIntensity = fire["fire_intensity"] / 100;
            if distanceBasedOnFireIntensity < min_fire_distance then
                distanceBasedOnFireIntensity = min_fire_distance
            end
            local result = FireSimPerFireCallback.CheckDirection(fire, distanceBasedOnFireIntensity, 4)
            if result ~= nil then
                local outerpoints = FireSimPerFireCallback.Generic.CreateBox(result[3], result[6], nil, {0, 1, 0}, showDebug)
                local firebaseinfo = {result[3], 0, result[4], result[6] / 2, result[3], fire["fire_intensity"], outerpoints}
                local min_fire_intensity = FireSimPerFireCallback.Properties["fire_intensity_minimum"]
                local startinIntensity = FireSimPerFireCallback.Generic.rndInt(min_fire_intensity, fire["fire_intensity"])

                FireSimPerFireCallback.Fires[result[1]] = FireSimPerFireCallback.GenerateFireObject(result[4], result[8], result[5], result[7], firebaseinfo, startinIntensity)
            end

            FireSimPerFireCallback.Fires[hash]["amounttospawn"] = FireSimPerFireCallback.Fires[hash]["amounttospawn"] - 1
            if FireSimPerFireCallback.Fires[hash]["amounttospawn"] == 0 then
                FireSimPerFireCallback.Fires[hash]["spawnednew"] = true
                FireSimPerFireCallback.Fires[hash]["spawnnew"] = false
            end
        end
    end
end

function FireSimPerFireCallback.UpdateSoot(hash, fire)
    local showDebug = false
    if FireSimPerFireCallback.Properties["visualize_fire_detection"] == "ON" then
        showDebug = true
    end
    local soot_sim = FireSimPerFireCallback.Properties["soot_sim"]
    local soot_dithering_max = FireSimPerFireCallback.Properties["soot_dithering_max"]
    local soot_max_size = FireSimPerFireCallback.Properties["soot_max_size"]
    local soot_dithering_min = FireSimPerFireCallback.Properties["soot_dithering_min"]
    local soot_min_size = FireSimPerFireCallback.Properties["soot_min_size"]

    if soot_sim == "YES"  then
        local point_start = fire["location"]
        local randomize = FireSimPerFireCallback.Generic.rndInt(soot_min_size,
                                         soot_max_size)
        for x = 0, fire["fire_intensity"] / 25 do
            local direction =
                Vec(FireSimPerFireCallback.Generic.rnd(-0.15, 0.15), 1,
                    FireSimPerFireCallback.Generic.rnd(-0.15, 0.15))
            local newpoint =
                VecAdd(point_start, VecScale(direction, fire["fire_intensity"] / 40))
            local hit, point, normal, _ = QueryClosestPoint(
                                                      newpoint,
                                                      randomize)
            if hit then
                FireSimPerFireCallback.Generic.DrawLine(point_start, point, 0, 1, 0,
                                 showDebug)
                Paint(point, (FireSimPerFireCallback.Generic.rnd(soot_min_size,
                                          soot_max_size) / 100) *
                          fire["fire_intensity"], "explosion", FireSimPerFireCallback.Generic.rnd(
                          soot_dithering_min, soot_dithering_max))
                if normal[2] < -0.8 then
                    FireSimPerFireCallback.Generic.DrawLine(point_start, point, 1, 0, 0,
                                     showDebug)
                    break
                else
                    FireSimPerFireCallback.Generic.DrawLine(point_start, point, 0, 1, 0,
                                     showDebug)
                end
                point_start = point
            end
        end
    end
end

function FireSimPerFireCallback.UpdateFireDamage(hash, fire)
    -- DebugPrint("Fire damage callback called for fire " .. hash)
    local fire_damage = FireSimPerFireCallback.Properties["fire_damage"]
    local sound_enabled = FireSimPerFireCallback.Properties["enable_sound"]
    local damage_volume = FireSimPerFireCallback.Properties["damage_sound_volume"]
    local random_volume = 1 + FireSimPerFireCallback.Generic.rnd(-FireSimPerFireCallback.Properties["damage_sound_volume_random"],FireSimPerFireCallback.Properties["damage_sound_volume_random"])
    if fire_damage == "YES" then
        -- DebugPrint("Fire damage is enabled, but intensity is still below 80: " .. fire["fire_intensity"])
        if fire["fire_intensity"] >= FireSimPerFireCallback.Generic.rndInt(50, 100) and fire["burnout"] == true then
            if sound_enabled == "ON" then
                local playSound = FireSimPerFireCallback.Generic.rndInt(1, #FireSimPerFireCallback.FireDestructionSound)
                PlaySound(FireSimPerFireCallback.FireDestructionSound[playSound], fire["location"], (fire["fire_intensity"] / (100 - (damage_volume * 100)))*random_volume)
            end
            local fire_damage_soft = FireSimPerFireCallback.Properties["fire_damage_soft"] / 100 -- take procentile to multiply times intensity
            local fire_damage_medium = FireSimPerFireCallback.Properties["fire_damage_medium"] / 100 -- take procentile to multiply times intensity
            local fire_damage_hard = FireSimPerFireCallback.Properties["fire_damage_hard"] / 100 -- take procentile to multiply times intensity
            MakeHole(fire["location"], fire_damage_soft * fire["fire_intensity"],
                    fire_damage_medium * fire["fire_intensity"],
                    fire_damage_hard * fire["fire_intensity"], true)
            fire["damage"] = true
        end
    end
end

function FireSimPerFireCallback.DrawFire(hash, fire)
    FireSimPerFireCallback.DrawDetectedFire(fire)
end

function FireSimPerFireCallback.Update(dt)
    FireSimPerFireCallback.FireSim("update", dt)
    FireSimPerFireCallback.FireSim("tick", dt)

end

function FireSimPerFireCallback.Tick(dt)
end

FireSimPerFireCallback.Stats = {}

function FireSimPerFireCallback.FireSim(type, dt)

    local tick_total_callbacks = 0
    local update_total_callbacks = 0
    local total_fires = 0
    for hash, fire in pairs(FireSimPerFireCallback.Fires) do
        total_fires = total_fires + 1
        for id, callbackinfo in pairs(fire["update_callbacks"]) do
            if callbackinfo["type"] == type then
                if callbackinfo["timer"] >= callbackinfo["interval"] then
                    callbackinfo["callback"](hash, fire)
                    callbackinfo["timer"] = 0

                    if FireSimPerFireCallback.Stats[id .. "_" .. type] == nil then
                        FireSimPerFireCallback.Stats[id .. "_" .. type] = 0
                    end
                    FireSimPerFireCallback.Stats[id .. "_" .. type] = FireSimPerFireCallback.Stats[id .. "_" .. type] + 1
                    if callbackinfo["type"] == "update" then
                        update_total_callbacks = update_total_callbacks + 1
                    else
                        tick_total_callbacks = tick_total_callbacks + 1
                    end
                end
                callbackinfo["timer"] = callbackinfo["timer"] + dt
            end
        end

        if fire["delete"] then
            for id, callbackinfo in pairs(fire["delete_callbacks"]) do
                if callbackinfo["timer"] >= callbackinfo["interval"] then
                    callbackinfo["callback"](hash, fire)
                    callbackinfo["timer"] = 0
                end
                callbackinfo["timer"] = callbackinfo["timer"] + dt
            end
            FireSimPerFireCallback.Fires[hash] = nil
        end

        FireSimPerFireCallback.Fires[hash]["timer"] = FireSimPerFireCallback.Fires[hash]["timer"] + dt
    end

    for id, count in pairs(FireSimPerFireCallback.Stats) do
        DebugWatch("Callback " .. id .. " Count", count)
    end
    if type == "tick" then
        DebugWatch("Dt | Total Callbacks Per Tick", tostring(dt) .. "|"..  tostring(tick_total_callbacks))
    else
        DebugWatch("Dt | Total Callbacks Per Update", tostring(dt) .. "|"..  tostring(update_total_callbacks))
    end
    FireSimPerFireCallback.LocalDB["fire_count"] = total_fires

end

function FireSimPerFireCallback.GenerateFireObject(location, normal, material, shape, firebaseinfo, start_fire_intensity)

    local min_fire_intensity = FireSimPerFireCallback.Properties["fire_intensity_minimum"]
    local min_fire_distance = FireSimPerFireCallback.Properties["min_fire_distance"]
    if min_fire_distance < 0.1 then min_fire_distance = 0.1 end
    local rho = FireSimPerFireCallback.Generic.rnd(FireSimPerFireCallback.MaterialInfo[material]["rho"]["min"], FireSimPerFireCallback.MaterialInfo[material]["rho"]["max"])
    local heatcapacity = FireSimPerFireCallback.Generic.rnd(FireSimPerFireCallback.MaterialInfo[material]["heatcapacity"]["min"], FireSimPerFireCallback.MaterialInfo[material]["heatcapacity"]["max"])
    local burnout_percentage = FireSimPerFireCallback.Generic.rndInt(60, 100)



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
        amounttospawn=2,
        spawnnew = true,
        spawnednew = false,
        delete = false,
        soot = false,
        inside = nil,
        burnout_percentage = burnout_percentage,
        damage = false,
        normal = normal,
        burnout=false,
        burnout_timestamp=0,
        extinghuishing=false,
        extinghuishing_rate=0,
        timer=0,
        light=nil,
        playsound=nil,
        playsound_random = 0,
        playsound_damage_random = 0,
        update_callbacks=FireSimPerFireCallback.Generic.deepCopy(FireSimPerFireCallback.UpdateCallbacks),
        delete_callbacks=FireSimPerFireCallback.Generic.deepCopy(FireSimPerFireCallback.DeleteCallbacks),
    }
    return new_obj
end

function FireSimPerFireCallback.SpawnFireOnButtonPress(dt)
    local showDebug = false
    if FireSimPerFireCallback.Properties["visualize_fire_detection"] == "ON" then
        showDebug = true
    end

    local min_fire_intensity = FireSimPerFireCallback.Properties["fire_intensity_minimum"]
    local min_fire_distance = FireSimPerFireCallback.Properties["min_fire_distance"]
    local material_allowed = FireSimPerFireCallback.Properties["material_allowed"]
    if min_fire_distance < 0.1 then min_fire_distance = 0.1 end
    if InputReleased("lmb") and GetString("game.player.tool") == "blowtorch" then
        -- DebugPrint("LMB Clicked")
        local ct = GetCameraTransform();
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
                local hash = FireSimPerFireCallback.Generic.HashVec(hitPoint)

                local newDist = min_fire_distance / 100 * min_fire_intensity
                local outerpoints = FireSimPerFireCallback.Generic.CreateBox(hitPoint, newDist, nil, {1, 1, 0}, showDebug)
                local firebaseinfo = {hitPoint, 0, hitPoint, newDist, hitPoint, min_fire_intensity, outerpoints}


                local vecToCheck =  VecAdd(hitPoint, newDist * 4)

                for checkhash, checkFire in pairs(FireSimPerFireCallback.Fires) do
                    local distToCheck = newDist

                    -- if checkFire["original"][6] > distToCheck then
                    --     distToCheck = checkFire["original"][6]
                    -- end
                    if FireSimPerFireCallback.Generic.VecDistance(checkFire["original"][3], vecToCheck) < distToCheck then
                        -- if FireSimPerFireCallback.Fires[checkhash]["fire_intensity"] < 100 and distToCheck ~= newDist then
                        --     FireSimPerFireCallback.Fires[checkhash]["fire_intensity"] = FireSimPerFireCallback.Fires[checkhash]["fire_intensity"] + 10
                        -- end
                        -- DebugPrint("Did not spawn fire, already fire at location")
                        return false
                    end
                end

                -- DebugPrint("Adding fire")
                FireSimPerFireCallback.Fires[hash] = FireSimPerFireCallback.GenerateFireObject(hitPoint, normal, material, shape, firebaseinfo, min_fire_intensity)

                -- DebugPrint("Spawned fire!")
            end
        end
    end

    return true
end

function FireSimPerFireCallback.ExtinguishFire(hash, rate)
    FireSimPerFireCallback.Fires[hash]["extinghuishing_rate"] = FireSimPerFireCallback.Fires[hash]["extinghuishing_rate"] + rate
    DebugPrint("Extinguishing fire: " .. hash .. ", Extinguishrate: " .. tostring(FireSimPerFireCallback.Fires[hash]["extinghuishing_rate"]) .. "%, Current Intensity: " .. tostring(FireSimPerFireCallback.Fires[hash]["fire_intensity"]))
    if(FireSimPerFireCallback.Fires[hash]["fire_intensity"] < FireSimPerFireCallback.Fires[hash]["original_fire_intensity"] ) or FireSimPerFireCallback.Fires[hash]["extinghuishing_rate"] > FireSimPerFireCallback.Fires[hash]["fire_intensity"]  then
        FireSimPerFireCallback.Fires[hash]["extinghuishing"] = true
        FireSimPerFireCallback.Fires[hash]["spawnnew"] = false
    end
end

function FireSimPerFireCallback.CheckDirection(fire, newDist, tries)
    local material_allowed = FireSimPerFireCallback.Properties["material_allowed"]
    local showDebug = false
    if FireSimPerFireCallback.Properties["visualize_fire_detection"] == "ON" then
        showDebug = true
    end

    -- DebugPrint("Searching dir: {"..dir[1]..","..dir[2]..","..dir[3].."}, direction size: " .. newDist .. " amount: " .. newFireCount)

    local origin = fire["location"]
    local up = 0
    local uptries =  3
    DebugPrint("Trying to find fie in {" .. tostring(math.ceil(fire["fire_intensity"] / tries)) .. "} tries")
    local actualtries =  tries
    local y = 0
    local actualNewDist = newDist
    for x = 0, actualtries do

        if y > 3 then
            origin = fire["location"]
            y = 0
        end
        y = y + 1

        -- Favor upwards fire trajectory
        if FireSimPerFireCallback.Generic.rndInt(0, uptries)  == 0 then
            up = -1
        end

        -- Spread more upwards
        local direction =
            Vec(FireSimPerFireCallback.Generic.rnd(-1 , 1), FireSimPerFireCallback.Generic.rnd(up, 1),
                FireSimPerFireCallback.Generic.rnd(-1, 1))

        local newpoint =
            VecAdd(origin, VecScale(direction, actualNewDist))
        local hit, point, normal, shape_hit = QueryClosestPoint(
                                                    newpoint, 1)
        if hit then
            FireSimPerFireCallback.Generic.DrawLine(origin, point, 0, 1, 0, showDebug)

            local inrange = false
            local distToCheck = actualNewDist
            for checkhash, checkFire in pairs(FireSimPerFireCallback.Fires) do
                if FireSimPerFireCallback.Generic.VecDistance(checkFire["location"], point) < distToCheck then
                    inrange = true
                    break
                end
            end
            if inrange == false then
                local hash = FireSimPerFireCallback.Generic.HashVec(point)
                local material = GetShapeMaterialAtPosition(shape_hit, point)
                if material_allowed[material] then
                    return {hash, 1, point, newpoint, material, actualNewDist, shape_hit, normal}
                end
            else
                actualNewDist = actualNewDist + 0.01
            end
        end
    end
    return nil
end

function FireSimPerFireCallback.GetFires(updatefires)
    FireSimPerFireCallback.UpdateFires = updatefires
    return FireSimPerFireCallback.Fires
end


---Use this in the draw function!
function FireSimPerFireCallback.ShowStatus()
    if FireSimPerFireCallback.GeneralOptions.GetShowUiInGame() == "YES" then
        DebugWatch("FireSim, Fire count",
                   FireSimPerFireCallback.LocalDB["fire_count"])
        DebugWatch("FireSim, time elapsed",
                   tostring(FireSimPerFireCallback.LocalDB["time_elapsed"]))
        DebugWatch("FireSim, intensity",
                   tostring(FireSimPerFireCallback.LocalDB["fire_intensity"]))
        DebugWatch("FireSim, randomtimer",
                   tostring(FireSimPerFireCallback.LocalDB["random_timer"]))
        DebugWatch("FireSim, timer",
                   tostring(FireSimPerFireCallback.LocalDB["timer"]))
        DebugWatch("FireSim, map_size",
                   tostring(FireSimPerFireCallback.Properties["map_size"]))
    end
end

