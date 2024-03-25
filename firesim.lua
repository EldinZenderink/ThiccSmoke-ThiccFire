-- FireSim.lua
-- @date 2022-08-28
-- @author Eldin Zenderink
-- @brief Detects fires and 'manages' their behavior
#include "compatibility.lua"
#include "debug.lua"

FireSim_Properties = {
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
    disable_td_fire = "NO"
}

FireSim_MaterialInfo = {
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
FireSim_LocalDB = {
    time_elapsed = 0,
    fire_count = 0,
    fire_intensity = 1,
    timer = 0,
    random_timer = 0
}

-- Store all shapes that could potentially be detached from shapes on fire (BPOF = shapes potentially on fire)
FireSim_Fires = {}

-- Global trigger to update fires from particle spawner (makes sense...)
FireSim_UpdateFires = false

-- Courtesy of: https://www.fesliyanstudios.com/royalty-free-sound-effects-download/glass-shattering-and-breaking-124
FireSim_GlassBreakingSnd = {}

-- Visualize fires
FireSim_Visualize = false

-- Register fire handlers
FireSim_UpdateCallbacks = {}
FireSim_DeleteCallbacks = {}

-- Fire spread directions
FireSim_SpreadDirections = {
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



-- Optimize dynamic compile time, should compile only once localy?  According to: https://www.lua.org/gems/sample.pdf
local FuncCreateBox = Generic_CreateBox
local FuncPaint = Paint
local FuncDrawPoint = Generic_DrawPoint
local FuncMakeHole = MakeHole
local FuncVecAdd = VecAdd
local FuncVecScale = VecScale
local FuncRndInt = Generic_rndInt
local FuncRndNum = Generic_rnd
local FuncGetShapeMaterialAtPosition = GetShapeMaterialAtPosition
local FuncVec = Vec
local FuncQueryClosestPoint = QueryClosestPoint
local FuncDrawLine = Generic_DrawLine
local FuncDebugWatch = DebugWatch
-- local FireSim_RecursiveBinarySearchFire = FireSim_RecursiveBinarySearchFire
local FuncHashVec = ObjectDetector_HashVec
-- local pairs = pairs


---Initialize the properties of the module
---@param default bool -- set to true to set all properties to their default configured values
function FireSim_Init()
    Settings_RegisterUpdateSettingsCallback(
        FireSim_UpdateSettingsFromSettings)

    for i = 1, 12 do
        FireSim_GlassBreakingSnd[i] = LoadSound(
                                               "MOD/sound/glass/00 - www.fesliyanstudios.com - " ..
                                                   i .. ".ogg")
    end

end

---Retrieve properties from storage and apply them
function FireSim_UpdateSettingsFromSettings()
    FireSim_Properties["map_size"] =
        Settings_GetValue("FireSim", "map_size")
    FireSim_Properties["max_fire_spread_distance"] = Settings_GetValue(
                                                              "FireSim",
                                                              "max_fire_spread_distance")
    FireSim_Properties["fire_reaction_time"] = Settings_GetValue(
                                                        "FireSim",
                                                        "fire_reaction_time")
    FireSim_Properties["fire_update_time"] = Settings_GetValue(
                                                      "FireSim",
                                                      "fire_update_time")
    FireSim_Properties["max_fire"] =
        Settings_GetValue("FireSim", "max_fire")
    FireSim_Properties["min_fire_distance"] = Settings_GetValue(
                                                       "FireSim",
                                                       "min_fire_distance")
    FireSim_Properties["max_group_fire_distance"] = Settings_GetValue(
                                                             "FireSim",
                                                             "max_group_fire_distance")
    FireSim_Properties["visualize_fire_detection"] = Settings_GetValue(
                                                              "FireSim",
                                                              "visualize_fire_detection")
    FireSim_Properties["fire_intensity"] = Settings_GetValue(
                                                    "FireSim",
                                                    "fire_intensity")
    FireSim_Properties["fire_intensity_multiplier"] = Settings_GetValue(
                                                               "FireSim",
                                                               "fire_intensity_multiplier")
    FireSim_Properties["fire_intensity_minimum"] = Settings_GetValue(
                                                            "FireSim",
                                                            "fire_intensity_minimum")
    FireSim_Properties["fire_explosion"] = Settings_GetValue(
                                                    "FireSim",
                                                    "fire_explosion")
    FireSim_Properties["fire_damage"] =
        Settings_GetValue("FireSim", "fire_damage")
    FireSim_Properties["spawn_fire"] =
        Settings_GetValue("FireSim", "spawn_fire")
    FireSim_Properties["detect_inside"] =
        Settings_GetValue("FireSim", "detect_inside")
    FireSim_Properties["soot_sim"] =
        Settings_GetValue("FireSim", "soot_sim")
    FireSim_Properties["soot_dithering_max"] = Settings_GetValue(
                                                        "FireSim",
                                                        "soot_dithering_max")
    FireSim_Properties["soot_dithering_min"] = Settings_GetValue(
                                                        "FireSim",
                                                        "soot_dithering_min")
    FireSim_Properties["soot_max_size"] =
        Settings_GetValue("FireSim", "soot_max_size")
    FireSim_Properties["soot_min_size"] =
        Settings_GetValue("FireSim", "soot_min_size")
    FireSim_Properties["fire_damage_soft"] = Settings_GetValue(
                                                      "FireSim",
                                                      "fire_damage_soft")
    FireSim_Properties["fire_damage_medium"] = Settings_GetValue(
                                                        "FireSim",
                                                        "fire_damage_medium")
    FireSim_Properties["fire_damage_hard"] = Settings_GetValue(
                                                      "FireSim",
                                                      "fire_damage_hard")
    FireSim_Properties["teardown_max_fires"] = Settings_GetValue(
                                                        "FireSim",
                                                        "teardown_max_fires")
    FireSim_Properties["teardown_fire_spread"] = Settings_GetValue(
                                                          "FireSim",
                                                          "teardown_fire_spread")


    FireSim_Properties["despawn_td_fire"] = Settings_GetValue(
        "FireSim",
        "despawn_td_fire")


    if FireSim_Properties["visualize_fire_detection"] == "ON" then
        FireSim_Visualize = true
    else
        FireSim_Visualize = false
    end
    -- No Fire Limit mod is disabled/does not work when ThiccSmoke / ThiccFire is enabled, since it adjusts the same settings
    if Compatibility_IsSettingCompatible("teardown_max_fires") then
        SetInt("game.fire.maxcount",
               math.floor(FireSim_Properties["teardown_max_fires"]))
        SetInt("game.fire.spread",
               math.floor(FireSim_Properties["teardown_fire_spread"]))
    end

    if  FireSim_Properties["despawn_td_fire"] == nil or
        FireSim_Properties["despawn_td_fire"] == "" then
        FireSim_Properties["despawn_td_fire"] = "YES"
        Settings_SetValue("FireSim", "despawn_td_fire", "YES")
    end

    if FireSim_Properties["despawn_td_fire"] == "YES" then
        FireSim_Properties["spawn_fire"] = "YES" -- Must spawn additional fires otherwise fires will dissapear
    end

    if FireSim_Properties["detect_inside"] == nil or
        FireSim_Properties["detect_inside"] == "" then
        FireSim_Properties["detect_inside"] = "YES"
        Settings_SetValue("FireSim", "detect_inside", "YES")
    end

    if FireSim_Properties["soot_sim"] == nil or
        FireSim_Properties["soot_sim"] == "" then
        FireSim_Properties["soot_sim"] = "NO"
        Settings_SetValue("FireSim", "soot_sim", "NO")
    end

    if FireSim_Properties["soot_dithering_max"] == nil or
        FireSim_Properties["soot_dithering_max"] == 0 then
        FireSim_Properties["soot_dithering_max"] = 1
        Settings_SetValue("FireSim", "soot_dithering_max", 1)
    end
    if FireSim_Properties["soot_max_size"] == nil or
        FireSim_Properties["soot_max_size"] == 0 then
        FireSim_Properties["soot_max_size"] = 5
        Settings_SetValue("FireSim", "soot_max_size", 5)
    end
    if FireSim_Properties["soot_dithering_min"] == nil or
        FireSim_Properties["soot_dithering_min"] == 0 then
        FireSim_Properties["soot_dithering_min"] = 1
        Settings_SetValue("FireSim", "soot_dithering_min", 1)
    end
    if FireSim_Properties["soot_min_size"] == nil or
        FireSim_Properties["soot_min_size"] == 0 then
        FireSim_Properties["soot_min_size"] = 5
        Settings_SetValue("FireSim", "soot_min_size", 5)
    end

    if FireSim_Properties["map_size"] == nil or
        FireSim_Properties["map_size"] == "" then
        FireSim_Properties["map_size"] = "MEDIUM"
        Settings_SetValue("FireSim", "map_size", "MEDIUM")
    end

    FireSim_RegisterUpdateFireCallback("LocationCallback", FireSim_UpdateLocationCallback, FireSim_Properties["fire_update_time"])
    FireSim_RegisterUpdateFireCallback("IntensityCallback", FireSim_UpdateIntensityCallback, FireSim_Properties["fire_update_time"] * 4)
    FireSim_RegisterUpdateFireCallback("SpreadCallback", FireSim_UpdateSpreadCallback, FireSim_Properties["fire_update_time"] / 10)
    FireSim_RegisterUpdateFireCallback("Soot", FireSim_UpdateSoot, FireSim_Properties["fire_update_time"] * 10)
    FireSim_RegisterUpdateFireCallback("FireDamage", FireSim_UpdateFireDamage, FireSim_Properties["fire_update_time"] * 10)
end

function FireDetection_DrawDetectedFire(fire, inside, fireinfo)
    local showDebug = false
    if FireSim_Properties["visualize_fire_detection"] == "ON" then
        showDebug = true
    end

    FuncCreateBox(fire[3], 1 / 100 * (fireinfo["fire_intensity"]), nil, {fireinfo["fire_intensity"] * 0.01,0.0,0.0},
                      showDebug)
    FuncDrawPoint(fire[3], 1, 0, 0, showDebug)
    if inside then
        FuncDrawPoint(fire[1], 1, 0, 1, showDebug)
    else
        FuncDrawPoint(fire[1], 0, 1, 1, showDebug)
    end
end


function FireSim_GetCurrentFireLocations()
    return FireSim_Fires
end

function FireSim_RegisterUpdateFireCallback(id, callback, interval)
    FireSim_UpdateCallbacks[id] = {
        callback=callback,
        interval=interval,
        timer=0
    }
    for id, cb in pairs(FireSim_UpdateCallbacks) do
        DebugPrint("Callbacks: " .. id)
    end
end

function FireSim_RegisterDeleteFireCallback(id, callback, interval)
    FireSim_DeleteCallbacks[id] = {
        callback=callback,
        interval=interval,
        timer=0
    }
end


function FireSim_UpdateLocationCallback(hash, fire)
    local material = FuncGetShapeMaterialAtPosition(fire["shape"], fire["location"])
    local material_allowed = FireSim_Properties["material_allowed"]
    if material == "" then
        local hit, point, normal, shape_hit = FuncQueryClosestPoint(fire["location"], 1)
        if hit then
            local material = FuncGetShapeMaterialAtPosition(shape_hit, point)
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

function FireSim_UpdateIntensityCallback(hash, fire)

    local time = fire["timer"]
    local material = fire["material"]
    local rho = Generic_rnd(FireSim_MaterialInfo[material]["rho"]["min"], FireSim_MaterialInfo[material]["rho"]["max"])
    local heatcapacity = Generic_rnd(FireSim_MaterialInfo[material]["heatcapacity"]["min"], FireSim_MaterialInfo[material]["heatcapacity"]["max"])
    if fire["burnout"] == false then
        local newFireIntensity = ((math.ceil(time) * 1000)) / (rho * heatcapacity)
        DebugWatch("fire_intensity_"..hash, newFireIntensity)
        if newFireIntensity >= 100 then
            newFireIntensity = 100
            fire["burnout"] = true
        end
        fire["fire_intensity"] = newFireIntensity
    elseif fire["fire_intensity"] > 20  and fire["burnout"] == true then
        fire["fire_intensity"] = fire["fire_intensity"] - ((math.ceil(time) * 100)) / (rho * heatcapacity)
    else
        fire["delete"] = true
    end
end

function FireSim_UpdateSpreadCallback(hash, fire)
    if fire["spawnednew"] == false and fire["fire_intensity"] >= Generic_rndInt(50, 100) then
        local material = fire["material"]
        local time = fire["timer"]
        local rho = Generic_rnd(FireSim_MaterialInfo[material]["rho"]["min"], FireSim_MaterialInfo[material]["rho"]["max"])
        local heatcapacity = Generic_rnd(FireSim_MaterialInfo[material]["heatcapacity"]["min"], FireSim_MaterialInfo[material]["heatcapacity"]["max"])
        local newFireCount = Generic_rndInt(1, fire["fire_intensity"] / 4)
        if fire["amounttospawn"] == 0 then
            fire["amounttospawn"] = newFireCount
        else
            local showDebug = false
            if FireSim_Properties["visualize_fire_detection"] == "ON" then
                showDebug = true
            end


            local result = FireSim_CheckDirection(fire, 1)
            if result ~= nil then
                local outerpoints = FuncCreateBox(result[3], result[6], nil, {0, 1, 0}, showDebug)
                local firebaseinfo = {result[3], 0, result[4], result[6] / 2, result[3], fire["fire_intensity"] / 2, outerpoints}

                FireSim_Fires[result[1]] = {
                    location = result[4],
                    material = result[5],
                    fire_intensity = fire["fire_intensity"] / 2,
                    shape = result[7],
                    original = firebaseinfo,
                    amounttospawn=0,
                    spawnednew = false,
                    delete = false,
                    soot = false,
                    inside = nil,
                    damage = false,
                    burnout=false,
                    normal = result[8],
                    extinghuishing=false,
                    timer=0,
                    light=nil,
                    update_callbacks=Generic_deepCopy(FireSim_UpdateCallbacks),
                    delete_callbacks=Generic_deepCopy(FireSim_DeleteCallbacks),
                }
            end
            fire["amounttospawn"] = fire["amounttospawn"] - 1
            if fire["amounttospawn"] == 0 then
                fire["spawnednew"] = true
            end
        end
    end
end

function FireSim_UpdateSoot(hash, fire)
    local showDebug = false
    if FireSim_Properties["visualize_fire_detection"] == "ON" then
        showDebug = true
    end
    local soot_sim = FireSim_Properties["soot_sim"]
    local soot_dithering_max = FireSim_Properties["soot_dithering_max"]
    local soot_max_size = FireSim_Properties["soot_max_size"]
    local soot_dithering_min = FireSim_Properties["soot_dithering_min"]
    local soot_min_size = FireSim_Properties["soot_min_size"]

    if soot_sim == "YES"  then
        local point_start = fire["location"]
        local randomize = FuncRndInt(soot_min_size,
                                         soot_max_size)
        for x = 0, fire["fire_intensity"] / 10 do
            local direction =
                FuncVec(FuncRndNum(-0.15, 0.15), 1,
                    FuncRndNum(-0.15, 0.15))
            local newpoint =
                FuncVecAdd(point_start, FuncVecScale(direction, fire["fire_intensity"] / 40))
            local hit, point, normal, shape_hit = FuncQueryClosestPoint(
                                                      newpoint,
                                                      randomize)
            if hit then
                FuncDrawLine(point_start, point, 0, 1, 0,
                                 showDebug)
                FuncPaint(point, (FuncRndNum(soot_min_size,
                                          soot_max_size) / 100) *
                          fire["fire_intensity"], "explosion", FuncRndNum(
                          soot_dithering_min, soot_dithering_max))
                if normal[2] < -0.8 then
                    FuncDrawLine(point_start, point, 1, 0, 0,
                                     showDebug)
                    break
                else
                    FuncDrawLine(point_start, point, 0, 1, 0,
                                     showDebug)
                end
                point_start = point
            end
        end
    end
end

function FireSim_UpdateFireDamage(hash, fire)
    -- DebugPrint("Fire damage callback called for fire " .. hash)
    local fire_damage = FireSim_Properties["fire_damage"]
    if fire_damage == "YES" then
        -- DebugPrint("Fire damage is enabled, but intensity is still below 80: " .. fire["fire_intensity"])
        if fire["fire_intensity"] > 80 and  fire["damage"] == false then
            local fire_damage_soft = FireSim_Properties["fire_damage_soft"] / 100 -- take procentile to multiply times intensity
            local fire_damage_medium = FireSim_Properties["fire_damage_medium"] / 100 -- take procentile to multiply times intensity
            local fire_damage_hard = FireSim_Properties["fire_damage_hard"] / 100 -- take procentile to multiply times intensity
            FuncMakeHole(fire["location"], fire_damage_soft * fire["fire_intensity"],
                    fire_damage_medium * fire["fire_intensity"],
                    fire_damage_hard * fire["fire_intensity"], true)
            fire["damage"] = true
        end
    end
end

function FireSim_SimulateFire(dt)

    local stats = {}
    local total_callbacks = 0
    for hash, fire in pairs(FireSim_Fires) do
        FireDetection_DrawDetectedFire(fire["original"], false, fire)
        for id, callbackinfo in pairs(fire["update_callbacks"]) do
            if callbackinfo["timer"] >= callbackinfo["interval"] then
                callbackinfo["callback"](hash, fire)
                callbackinfo["timer"] = 0
                -- DebugPrint("Called callback: " .. id .. " with timer: " .. callbackinfo["timer"])
            end
            callbackinfo["timer"] = callbackinfo["timer"] + dt
            if stats[id] == nil then
                stats[id] = 0
            end
            stats[id] = stats[id] + 1
            total_callbacks = total_callbacks + 1
        end

        if fire["delete"] then
            for id, callbackinfo in pairs(fire["delete_callbacks"]) do
                if callbackinfo["timer"] >= callbackinfo["interval"] then
                    callbackinfo["callback"](hash, fire)
                    callbackinfo["timer"] = 0
                end
                callbackinfo["timer"] = callbackinfo["timer"] + dt
            end
            FireSim_Fires[hash] = nil
        end

        FireSim_Fires[hash]["timer"] = FireSim_Fires[hash]["timer"] + dt
    end

    for id, count in pairs(stats) do
        DebugWatch("Callback " .. id .. " Count", count)
    end

    DebugWatch("Total Callbacks Per Tick", total_callbacks)

end

function FireSim_SpawnFireOnButtonPress(dt)
    local showDebug = false
    if FireSim_Properties["visualize_fire_detection"] == "ON" then
        showDebug = true
    end

    local timer = FireSim_LocalDB["timer"]
    local fire_reaction_time = FireSim_Properties["fire_reaction_time"]
    local min_fire_intensity = FireSim_Properties["fire_intensity_minimum"]
    local min_fire_distance = FireSim_Properties["min_fire_distance"]
    local material_allowed = FireSim_Properties["material_allowed"]
    if min_fire_distance < 0.1 then min_fire_distance = 0.1 end
    if InputReleased("lmb") and GetString("game.player.tool") == "blowtorch" then
        -- DebugPrint("LMB Clicked")
        local ct = GetCameraTransform();
        local pos = ct.pos
        local dir = TransformToParentVec(ct, Vec(0, 0, -1))
        local hit, dist, normal, shape = QueryRaycast(pos, dir, 500)
        if hit then
            local hitPoint = VecAdd(pos, VecScale(dir, dist))
            local material = GetShapeMaterialAtPosition(shape, hitPoint)

            if material_allowed[material] then
                local hash = FuncHashVec(hitPoint)

                local newDist = min_fire_distance / 100 * min_fire_intensity
                local outerpoints = FuncCreateBox(hitPoint, newDist, nil, {1, 1, 0}, showDebug)
                local firebaseinfo = {hitPoint, 0, hitPoint, newDist, hitPoint, min_fire_intensity, outerpoints}




                local vecToCheck =  VecAdd(hitPoint, newDist * 4)

                for checkhash, checkFire in pairs(FireSim_Fires) do
                    local distToCheck = newDist

                    -- if checkFire["original"][6] > distToCheck then
                    --     distToCheck = checkFire["original"][6]
                    -- end
                    if Generic_VecDistance(checkFire["original"][3], vecToCheck) < distToCheck then
                        -- if FireSim_Fires[checkhash]["fire_intensity"] < 100 and distToCheck ~= newDist then
                        --     FireSim_Fires[checkhash]["fire_intensity"] = FireSim_Fires[checkhash]["fire_intensity"] + 10
                        -- end
                        DebugPrint("Did not spawn fire, already fire at location")
                        return nil
                    end
                end

                FireSim_Fires[hash] = {
                    location = hitPoint,
                    material = material,
                    original_fire_intensity = min_fire_intensity,
                    fire_intensity = min_fire_intensity,
                    shape = shape,
                    original = firebaseinfo,
                    amounttospawn=0,
                    spawnednew = false,
                    delete = false,
                    soot = false,
                    inside = nil,
                    damage = false,
                    normal = normal,
                    burnout=false,
                    extinghuishing=false,
                    timer=0,
                    light=nil,
                    update_callbacks=Generic_deepCopy(FireSim_UpdateCallbacks),
                    delete_callbacks=Generic_deepCopy(FireSim_DeleteCallbacks),
                }
            end
        end
    end
end

function FireSim_ExtinguishFire(hash, rate)
    FireSim_Fires[hash]["fire_intensity"] = FireSim_Fires[hash]["fire_intensity"] - rate
    if(FireSim_Fires[hash]["fire_intensity"] / FireSim_Fires[hash]["original_fire_intensity"] < 0.5) then
        FireSim_Fires[hash]["spawnnew"] = nil
    end
end

function FireSim_CheckDirection(fire, newDist)
    local material_allowed = FireSim_Properties["material_allowed"]
    local showDebug = false
    if FireSim_Properties["visualize_fire_detection"] == "ON" then
        showDebug = true
    end

    -- DebugPrint("Searching dir: {"..dir[1]..","..dir[2]..","..dir[3].."}, direction size: " .. newDist .. " amount: " .. newFireCount)

    local origin = fire["location"]
    local up = 0
    local tries =  10

    -- DebugPrint("Trying to find fire in {" .. tostring(math.ceil(fire["fire_intensity"] / tries)) .. "} tries")
    local actualtries = 20
    local y = 0
    for x = 0, actualtries do

        if y > 3 then
            origin = fire["location"]
            y = 0
        end
        y = y + 1

        -- Favor upwards fire trajectory
        if Generic_rndInt(0, tries)  == 0 then
            up = -1
        end

        -- Spread more upwards
        local direction =
            FuncVec(FuncRndNum(-1 , 1), FuncRndNum(up, 1),
                FuncRndNum(-1, 1))

        local newpoint =
            FuncVecAdd(origin, FuncVecScale(direction, newDist))
        local hit, point, normal, shape_hit = FuncQueryClosestPoint(
                                                    newpoint, newDist * 2)
        if hit then
            FuncDrawLine(origin, point, 0, 1, 0, showDebug)

            origin = point
            local inrange = false
            for checkhash, checkFire in pairs(FireSim_Fires) do
                local distToCheck = newDist

                -- if checkFire["original"][6] > distToCheck then
                --     distToCheck = checkFire["original"][6]
                -- end
                if Generic_VecDistance(checkFire["location"], point) < newDist then
                    inrange = true
                    DebugPrint("Found location already contains fire: " .. Generic_VecDistance(checkFire["location"], point))
                    break
                end
            end
            if inrange == false then
                local hash = FuncHashVec(point)
                local material = FuncGetShapeMaterialAtPosition(shape_hit, point)
                if material_allowed[material] then
                    return {hash, 1, point, newpoint, material, newDist, shape_hit, normal}
                end
            end
        end
    end
    return nil
end

function FireSim_GetFires(updatefires)
    FireSim_UpdateFires = updatefires
    return FireSim_Fires
end


---Use this in the draw function!
function FireSim_ShowStatus()
    if GeneralOptions_GetShowUiInGame() == "YES" then
        FuncDebugWatch("FireSim, Fire count",
                   FireSim_LocalDB["fire_count"])
        FuncDebugWatch("FireSim, time elapsed",
                   tostring(FireSim_LocalDB["time_elapsed"]))
        FuncDebugWatch("FireSim, intensity",
                   tostring(FireSim_LocalDB["fire_intensity"]))
        FuncDebugWatch("FireSim, randomtimer",
                   tostring(FireSim_LocalDB["random_timer"]))
        FuncDebugWatch("FireSim, timer",
                   tostring(FireSim_LocalDB["timer"]))
        FuncDebugWatch("FireSim, map_size",
                   tostring(FireSim_Properties["map_size"]))
    end
end

