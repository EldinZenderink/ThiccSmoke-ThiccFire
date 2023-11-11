-- firedetector.lua
-- @date 2022-08-28
-- @author Eldin Zenderink
-- @brief Detects fires and 'manages' their behavior
#include "compatibility.lua"
#include "debug.lua"

FireDetector_Properties = {
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
        plastic = true,
        masonery = true
    },
    disable_td_fire = "NO"
}

--- Some global properties
FireDetector_LocalDB = {
    time_elapsed = 0,
    fire_count = 0,
    fire_intensity = 1,
    timer = 0,
    random_timer = 0
}

-- Store all shapes that could potentially be detached from shapes on fire (BPOF = shapes potentially on fire)
FireDetector_SPOF = {}

-- Courtesy of: https://www.fesliyanstudios.com/royalty-free-sound-effects-download/glass-shattering-and-breaking-124
FireDetector_GlassBreakingSnd = {}


-- Optimize dynamic compile time, should compile only once localy?  According to: https://www.lua.org/gems/sample.pdf
local FuncExplosion = Explosion
local FuncCreateBox = Generic_CreateBox
local FuncPaint = Paint
local FuncDrawPoint = Generic_DrawPoint
local FuncMakeHole = MakeHole
local FuncVecAdd = VecAdd
local FuncVecScale = VecScale
local FuncRndVec = Generic_rndVec
local FuncRndInt = Generic_rndInt
local FuncRndNum = Generic_rnd
local FuncQueryRaycast = QueryRaycast
local FuncGetShapeMaterialAtPosition = GetShapeMaterialAtPosition
local FuncSpawnFire = SpawnFire
local FuncPlaySound = PlaySound
local FuncVec = Vec
local FuncQueryClosestPoint = QueryClosestPoint
local FuncDrawLine = Generic_DrawLine
local FuncRemoveAaBbFires = RemoveAabbFires
local FuncDebugWatch = DebugWatch
-- local FireDetector_RecursiveBinarySearchFire = FireDetector_RecursiveBinarySearchFire
local FuncHashVec = ObjectDetector_HashVec
local FuncQueryAabbFireCount = QueryAabbFireCount
local FuncDeepCopy = Generic_deepCopy
-- local pairs = pairs
local FuncQueryRequire = QueryRequire
local FuncTableContainsTable = Generic_TableContainsTable
local FuncVecLerp = VecLerp
local FuncMathCeil = math.ceil
local FuncQueryClosestFire = QueryClosestFire
local FireDetector_VecMidPoint = FireDetector_VecMidPoint



---Initialize the properties of the module
---@param default bool -- set to true to set all properties to their default configured values
function FireDetector_Init()
    Settings_RegisterUpdateSettingsCallback(
        FireDetector_UpdateSettingsFromSettings)

    for i = 1, 12 do
        FireDetector_GlassBreakingSnd[i] = LoadSound(
                                               "MOD/sound/glass/00 - www.fesliyanstudios.com - " ..
                                                   i .. ".ogg")
    end

end

FireDetector_Visualize = false

---Retrieve properties from storage and apply them
function FireDetector_UpdateSettingsFromSettings()
    FireDetector_Properties["map_size"] =
        Settings_GetValue("FireDetector", "map_size")
    FireDetector_Properties["max_fire_spread_distance"] = Settings_GetValue(
                                                              "FireDetector",
                                                              "max_fire_spread_distance")
    FireDetector_Properties["fire_reaction_time"] = Settings_GetValue(
                                                        "FireDetector",
                                                        "fire_reaction_time")
    FireDetector_Properties["fire_update_time"] = Settings_GetValue(
                                                      "FireDetector",
                                                      "fire_update_time")
    FireDetector_Properties["max_fire"] =
        Settings_GetValue("FireDetector", "max_fire")
    FireDetector_Properties["min_fire_distance"] = Settings_GetValue(
                                                       "FireDetector",
                                                       "min_fire_distance")
    FireDetector_Properties["max_group_fire_distance"] = Settings_GetValue(
                                                             "FireDetector",
                                                             "max_group_fire_distance")
    FireDetector_Properties["visualize_fire_detection"] = Settings_GetValue(
                                                              "FireDetector",
                                                              "visualize_fire_detection")
    FireDetector_Properties["fire_intensity"] = Settings_GetValue(
                                                    "FireDetector",
                                                    "fire_intensity")
    FireDetector_Properties["fire_intensity_multiplier"] = Settings_GetValue(
                                                               "FireDetector",
                                                               "fire_intensity_multiplier")
    FireDetector_Properties["fire_intensity_minimum"] = Settings_GetValue(
                                                            "FireDetector",
                                                            "fire_intensity_minimum")
    FireDetector_Properties["fire_explosion"] = Settings_GetValue(
                                                    "FireDetector",
                                                    "fire_explosion")
    FireDetector_Properties["fire_damage"] =
        Settings_GetValue("FireDetector", "fire_damage")
    FireDetector_Properties["spawn_fire"] =
        Settings_GetValue("FireDetector", "spawn_fire")
    FireDetector_Properties["detect_inside"] =
        Settings_GetValue("FireDetector", "detect_inside")
    FireDetector_Properties["soot_sim"] =
        Settings_GetValue("FireDetector", "soot_sim")
    FireDetector_Properties["soot_dithering_max"] = Settings_GetValue(
                                                        "FireDetector",
                                                        "soot_dithering_max")
    FireDetector_Properties["soot_dithering_min"] = Settings_GetValue(
                                                        "FireDetector",
                                                        "soot_dithering_min")
    FireDetector_Properties["soot_max_size"] =
        Settings_GetValue("FireDetector", "soot_max_size")
    FireDetector_Properties["soot_min_size"] =
        Settings_GetValue("FireDetector", "soot_min_size")
    FireDetector_Properties["fire_damage_soft"] = Settings_GetValue(
                                                      "FireDetector",
                                                      "fire_damage_soft")
    FireDetector_Properties["fire_damage_medium"] = Settings_GetValue(
                                                        "FireDetector",
                                                        "fire_damage_medium")
    FireDetector_Properties["fire_damage_hard"] = Settings_GetValue(
                                                      "FireDetector",
                                                      "fire_damage_hard")
    FireDetector_Properties["teardown_max_fires"] = Settings_GetValue(
                                                        "FireDetector",
                                                        "teardown_max_fires")
    FireDetector_Properties["teardown_fire_spread"] = Settings_GetValue(
                                                          "FireDetector",
                                                          "teardown_fire_spread")


    FireDetector_Properties["despawn_td_fire"] = Settings_GetValue(
        "FireDetector",
        "despawn_td_fire")


    if FireDetector_Properties["visualize_fire_detection"] == "ON" then
        FireDetector_Visualize = true
    else
        FireDetector_Visualize = false
    end
    -- No Fire Limit mod is disabled/does not work when ThiccSmoke / ThiccFire is enabled, since it adjusts the same settings
    if Compatibility_IsSettingCompatible("teardown_max_fires") then
        SetInt("game.fire.maxcount",
               math.floor(FireDetector_Properties["teardown_max_fires"]))
        SetInt("game.fire.spread",
               math.floor(FireDetector_Properties["teardown_fire_spread"]))
    end

    if  FireDetector_Properties["despawn_td_fire"] == nil or
        FireDetector_Properties["despawn_td_fire"] == "" then
        FireDetector_Properties["despawn_td_fire"] = "YES"
        Settings_SetValue("FireDetector", "despawn_td_fire", "YES")
    end

    if FireDetector_Properties["despawn_td_fire"] == "YES" then
        FireDetector_Properties["spawn_fire"] = "YES" -- Must spawn additional fires otherwise fires will dissapear
    end

    if FireDetector_Properties["detect_inside"] == nil or
        FireDetector_Properties["detect_inside"] == "" then
        FireDetector_Properties["detect_inside"] = "YES"
        Settings_SetValue("FireDetector", "detect_inside", "YES")
    end

    if FireDetector_Properties["soot_sim"] == nil or
        FireDetector_Properties["soot_sim"] == "" then
        FireDetector_Properties["soot_sim"] = "NO"
        Settings_SetValue("FireDetector", "soot_sim", "NO")
    end

    if FireDetector_Properties["soot_dithering_max"] == nil or
        FireDetector_Properties["soot_dithering_max"] == 0 then
        FireDetector_Properties["soot_dithering_max"] = 1
        Settings_SetValue("FireDetector", "soot_dithering_max", 1)
    end
    if FireDetector_Properties["soot_max_size"] == nil or
        FireDetector_Properties["soot_max_size"] == 0 then
        FireDetector_Properties["soot_max_size"] = 5
        Settings_SetValue("FireDetector", "soot_max_size", 5)
    end
    if FireDetector_Properties["soot_dithering_min"] == nil or
        FireDetector_Properties["soot_dithering_min"] == 0 then
        FireDetector_Properties["soot_dithering_min"] = 1
        Settings_SetValue("FireDetector", "soot_dithering_min", 1)
    end
    if FireDetector_Properties["soot_min_size"] == nil or
        FireDetector_Properties["soot_min_size"] == 0 then
        FireDetector_Properties["soot_min_size"] = 5
        Settings_SetValue("FireDetector", "soot_min_size", 5)
    end

    if FireDetector_Properties["map_size"] == nil or
        FireDetector_Properties["map_size"] == "" then
        FireDetector_Properties["map_size"] = "MEDIUM"
        Settings_SetValue("FireDetector", "map_size", "MEDIUM")
    end
end

function FireDetection_DrawDetectedFire(fire, inside)
    FuncCreateBox(fire[3], fire[4], nil, {fire[2] * 0.01, 0.753, 0.796},
                      true)
    FuncDrawPoint(fire[3], 1, 0, 0, true)
    if inside then
        FuncDrawPoint(fire[1], 1, 0, 1, true)
    else
        FuncDrawPoint(fire[1], 0, 1, 1, true)
    end
end

function FireDetector_FindFireLocationsV2(time, refresh)
    local fire_damage = FireDetector_Properties["fire_damage"]
    local fire_damage_soft = FireDetector_Properties["fire_damage_soft"] / 100 -- take procentile to multiply times intensity
    local fire_damage_medium = FireDetector_Properties["fire_damage_medium"] /
                                   100 -- take procentile to multiply times intensity
    local fire_damage_hard = FireDetector_Properties["fire_damage_hard"] / 100 -- take procentile to multiply times intensity
    local fire_explosion = FireDetector_Properties["fire_explosion"]
    local spawn_fire = FireDetector_Properties["spawn_fire"]
    local fire_intensity_enabled = FireDetector_Properties["fire_intensity"]
    local fire_reaction_time = FireDetector_Properties["fire_reaction_time"]
    local fire_update_time = FireDetector_Properties["fire_update_time"]
    local max_fire_spread_distance =
        FireDetector_Properties["max_fire_spread_distance"] / 100 -- take procentile to multiply times intensity
    local material_allowed = FireDetector_Properties["material_allowed"]
    local despawn_td_fire = FireDetector_Properties["despawn_td_fire"]

    local max_fires = FireDetector_Properties["max_fire"]
    local min_fire_distance = FireDetector_Properties["min_fire_distance"]
    if min_fire_distance < 0.1 then min_fire_distance = 0.1 end
    local max_group_fire_distance =
        FireDetector_Properties["max_group_fire_distance"]
    local fire_intensity_multiplier =
        FireDetector_Properties["fire_intensity_multiplier"]
    local min_fire_intensity = FireDetector_Properties["fire_intensity_minimum"]

    local soot_sim = FireDetector_Properties["soot_sim"]
    local soot_dithering_max = FireDetector_Properties["soot_dithering_max"]
    local soot_max_size = FireDetector_Properties["soot_max_size"]
    local soot_dithering_min = FireDetector_Properties["soot_dithering_min"]
    local soot_min_size = FireDetector_Properties["soot_min_size"]

    local time_elapsed = FireDetector_LocalDB["time_elapsed"]
    local timer = FireDetector_LocalDB["timer"]

    local max_intensity = 0
    local fire_count = 0

    if refresh or fire_count == 0 then

        for hash, fire in pairs(FireDetector_SPOF) do

            fire_count = fire_count + 1

            local outerpoints = FuncCreateBox(fire["location"],
                                                  max_group_fire_distance / 2,
                                                  nil, {1, 1, 0},
                                                  FireDetector_Visualize)

            local actualfirecount = FuncQueryAabbFireCount(outerpoints[1], outerpoints[7])
            local intensity =
                actualfirecount *
                    fire_intensity_multiplier
            if intensity > 100 or fire_intensity_enabled == false then
                intensity = 100
            elseif intensity < min_fire_intensity then
                intensity = min_fire_intensity
            end

            if FireDetector_SPOF[hash]["inside"] and intensity > 50 then
                intensity = 50
            end

            if actualfirecount ~= 0 then
                FireDetector_SPOF[hash]["fire_intensity"] = intensity
            else
                intensity = FireDetector_SPOF[hash]["fire_intensity"]
            end


            if timer > fire["timeout"] or fire["delete"] then
                if fire_explosion == "YES" then
                    FuncExplosion(fire["location"],
                              (4 / 100) * fire["fire_intensity"])
                end
                if fire_damage == "YES" then
                    if soot_sim == "YES" then
                        FuncPaint(fire["location"],
                              ((fire_damage_hard + 1) / 100) * intensity,
                              "explosion", FuncRndNum(soot_dithering_min,
                                                       soot_dithering_max))
                    end
                    FuncMakeHole(fire["location"], fire_damage_soft * intensity,
                             fire_damage_medium * intensity,
                             fire_damage_hard * intensity, true)
                end
                if spawn_fire == "YES" or fire_damage == "YES" then
                    for x = 0, actualfirecount * 1.2 do
                        local direction = FuncRndVec(1)
                        local hit, dist, n, s =
                            FuncQueryRaycast(fire["location"], direction,
                                            (max_fire_spread_distance * intensity +
                                                fire_damage_soft * intensity) + fire["original"][4])
                        if hit then
                            local newpoint =
                                FuncVecAdd(fire["location"],
                                        FuncVecScale(direction, dist))
                            local shape_mat =
                                FuncGetShapeMaterialAtPosition(s, newpoint)
                            if spawn_fire == "YES" then
                                FuncSpawnFire(newpoint)
                            end
                            if fire_damage == "YES" and shape_mat == "glass" then
                                FuncMakeHole(newpoint,
                                            intensity / FuncRndInt(50, 75),
                                            intensity / FuncRndInt(50, 75),
                                            intensity / FuncRndInt(50, 75),
                                            true)
                                FuncPlaySound(
                                    FireDetector_GlassBreakingSnd[FuncRndInt(
                                        1, 12)], newpoint, intensity / 200)
                            end
                        end
                    end
                end

                if soot_sim == "YES" then
                    local point_start = fire["location"]
                    local randomize = FuncRndInt(soot_min_size,
                                                     soot_max_size)
                    for x = 0, intensity / 100 do
                        local direction =
                            FuncVec(FuncRndNum(-0.15, 0.15), 1,
                                FuncRndNum(-0.15, 0.15))
                        local newpoint =
                            FuncVecAdd(point_start, FuncVecScale(direction, intensity /
                                                             20 + randomize))
                        local hit, point, normal, shape_hit = FuncQueryClosestPoint(
                                                                  newpoint,
                                                                  randomize)
                        if hit then
                            FuncDrawLine(point_start, point, 0, 1, 0,
                                             FireDetector_Visualize)
                            FuncPaint(point, (FuncRndNum(soot_min_size,
                                                      soot_max_size) / 100) *
                                      intensity, "explosion", FuncRndNum(
                                      soot_dithering_min, soot_dithering_max))
                            if normal[2] < -0.8 then
                                FuncDrawLine(point_start, point, 1, 0, 0,
                                                 FireDetector_Visualize)
                                break
                            else
                                FuncDrawLine(point_start, point, 0, 1, 0,
                                                 FireDetector_Visualize)
                            end
                            point_start = point
                        end
                    end
                end

                FireDetector_SPOF[hash] = nil
            else
                if actualfirecount == 0 then
                    local hit, point, normal, shape_hit = FuncQueryClosestPoint(
                                                              fire["location"],
                                                              min_fire_distance)
                    if hit then
                        local shape_mat =
                            FuncGetShapeMaterialAtPosition(shape_hit, point)
                        if material_allowed[shape_mat] then
                            FuncSpawnFire(point)
                            if soot_sim == "YES" then
                                FuncPaint(point, (FuncRndNum(soot_min_size,
                                                          soot_max_size) / 100) *
                                          intensity, "explosion", FuncRndNum(
                                          soot_dithering_min, soot_dithering_max))
                            end
                        end
                        if fire_damage == "YES" and shape_mat == "glass" then
                            FuncMakeHole(point, intensity / FuncRndInt(50, 75),
                                     intensity / FuncRndInt(50, 75),
                                     intensity / FuncRndInt(50, 75), true)
                            FuncPlaySound(
                                FireDetector_GlassBreakingSnd[FuncRndInt(1,
                                                                             12)],
                                point, intensity / 200)
                        end
                    end
                    fire["delete"] = true
                else

                    local outerpoints = fire["original"][7]
                    if despawn_td_fire == "YES" and actualfirecount > 10 then
                        local count = FuncRemoveAaBbFires(outerpoints[1], outerpoints[7])
                        -- if count > 0 then
                        --     DebugPrint("removed " .. count .. " fires")
                        -- end
                    end

                    if fire["soot"] == false and soot_sim == "YES" then
                        fire["soot"] = true
                        local point_start = fire["location"]
                        local randomize = FuncRndInt(soot_min_size,
                                                         soot_max_size)
                        for x = 0, intensity / 100 do
                            local direction =
                                FuncVec(FuncRndNum(-0.15, 0.15), 1,
                                    FuncRndNum(-0.15, 0.15))
                            local newpoint =
                                FuncVecAdd(point_start, FuncVecScale(direction, intensity /
                                                                 20 + randomize))
                            local hit, point, normal, shape_hit = FuncQueryClosestPoint(
                                                                      newpoint,
                                                                      randomize)
                            if hit then
                                FuncPaint(point, (FuncRndNum(soot_min_size,
                                                          soot_max_size) / 100) *
                                          intensity, "explosion", FuncRndNum(
                                          soot_dithering_min, soot_dithering_max))
                                if normal[2] < -0.8 then
                                    FuncDrawLine(point_start, point, 1, 0, 0,
                                                     FireDetector_Visualize)
                                    break
                                else
                                    FuncDrawLine(point_start, point, 0, 1, 0,
                                                     FireDetector_Visualize)
                                end
                                point_start = point
                            end
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
            FireDetector_RecursiveBinarySearchFire(FuncVec(0, 0, 0),
                                          409.6 / modifier,
                                          max_group_fire_distance / modifier,
                                          min_fire_distance / modifier,
                                          max_fires - fire_count,
                                          onfire,
                                          0,
                                          fire_intensity_multiplier,
                                          false)

            for i = 1, #onfire do
                local hash = FuncHashVec(onfire[i][3])
                if FireDetector_SPOF[hash] == nil then
                    local hit, point, normal, shape_hit = FuncQueryClosestPoint(
                                                              onfire[i][1],
                                                              min_fire_distance)
                    if hit then
                        local intensity = onfire[i][6]

                        local shape_mat =
                            FuncGetShapeMaterialAtPosition(shape_hit, point)
                        if material_allowed[shape_mat] then
                            local firepoint = FuncVecAdd(point,
                                                     FuncVecScale(normal, 0.1))

                            if intensity > 100 or fire_intensity_enabled ==
                                false then
                                intensity = 100
                            elseif intensity < min_fire_intensity then
                                intensity = min_fire_intensity
                            end

                            local timeout = FuncDeepCopy(timer) +
                            FuncRndNum(fire_reaction_time,
                                        fire_reaction_time * 2)

                            FireDetector_SPOF[hash] = {
                                location = firepoint,
                                light_location = onfire[i][5],
                                material = shape_mat,
                                fire_intensity = intensity,
                                shape = shape_hit,
                                original = onfire[i],
                                timeout = timeout,
                                delete = false,
                                soot = false,
                                inside = nil,
                                normal = normal
                            }
                            if max_intensity < intensity then
                                max_intensity = intensity
                            end
                            if soot_sim == "YES" then
                                FuncPaint(point, (FuncRndNum(soot_min_size,
                                                          soot_max_size) / 100) *
                                          intensity, "explosion", FuncRndNum(
                                          soot_dithering_min, soot_dithering_max))
                            end
                        end
                    end
                end
            end
            FireDetector_LocalDB["fire_intensity"] = max_intensity
        end

        FireDetector_LocalDB["time_elapsed"] = time_elapsed + time

        if FireDetector_Properties["detect_inside"] == "YES" then

            for hash, fire in pairs(FireDetector_SPOF) do
                if FireDetector_SPOF[hash]["inside"] == nil and
                    FireDetector_SPOF[hash]["fire_intensity"] > 50 then
                    local hitcount = 0
                    for x = 1, 6 do
                        local direction =
                            FuncVecAdd(fire["normal"], FuncVec(FuncRndNum(-0.5, 0.5),
                                                       FuncRndNum(0, 1),
                                                       FuncRndNum(-0.5, 0.5)))
                        local newpoint =
                            FuncVecAdd(fire["location"], FuncVecScale(direction, 15))
                        FuncQueryRequire("static")
                        local hit, dist =
                            FuncQueryRaycast(fire["location"], direction, 15)

                        if hit and dist ~= 0 then
                            FuncDrawLine(fire["location"], newpoint, 1, 0,
                                             1, FireDetector_Visualize)
                            hitcount = hitcount + 1
                        end
                    end
                    if hitcount > 0 then
                        FireDetector_SPOF[hash]["fire_intensity"] = 50
                        FireDetector_SPOF[hash]["inside"] = true
                    else
                        FireDetector_SPOF[hash]["inside"] = false
                    end
                end
            end
        end
    end

    if FireDetector_Properties["visualize_fire_detection"] == "ON" then

        for hash, fire in pairs(FireDetector_SPOF) do
            FireDetection_DrawDetectedFire(fire["original"], fire["inside"])
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
        if FuncTableContainsTable(added, fire["light_location"]) == false then
            added[#added + 1] = fire["light_location"]
            lightandwind[#lightandwind + 1] = fire
        end
    end

    return lightandwind
end

function FireDetector_VecMidPoint(vec1, vec2)
    -- return {vec1[1]+vec2[1]/2, vec1[2]+vec2[2]/2, vec1[3]+vec2[3]/2}
    return FuncVecLerp(vec1, vec2, 0.5)
end

function FireDetector_FindNearestPoint(point, size)
    -- local norm = VecNormalize(point)
    size = size * 2
    local x = (FuncMathCeil((point[1] / size)) * size)
    local z = (FuncMathCeil((point[2] / size)) * size)
    local y = (FuncMathCeil((point[3] / size)) * size)
    FuncDrawPoint({x, z, y}, 1, 0, 1, FireDetector_Visualize)
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
function FireDetector_RecursiveBinarySearchFire(vecstart,
                                                size,
                                                size_fire_count,
                                                min_size,
                                                max_fires,
                                                onfire,
                                                intensity,
                                                fire_intensity_multiplier,
                                                ignore
                                        )

    -- Draw bounding box

    local hash = FuncHashVec(vecstart)
    if FireDetector_SPOF[hash] ~= nil and ignore == false then
        ignore = true
        return
    end
    local outerpoints = FuncCreateBox(vecstart, size, nil, {1, 0, 0}, false)
    if outerpoints == nil then return; end

    local firecount = FuncQueryAabbFireCount(outerpoints[1], outerpoints[7])
    if firecount == 0 or #onfire >= max_fires then return end

    -- Dynamic sizing of fire
    if size <= size_fire_count and intensity == 0  then
        intensity  = firecount * fire_intensity_multiplier
        if intensity > 100 then
            intensity = 100
        end
        min_size = size_fire_count / 100 * intensity / 2
    end

    if (size < min_size and max_fires > #onfire) or intensity > 99 then
        if min_size > 0.04 and ignore == false then
            local hit, pos = FuncQueryClosestFire(
                                 FireDetector_VecMidPoint(outerpoints[1],
                                                          FireDetector_VecMidPoint(
                                                              outerpoints[1],
                                                              outerpoints[7])),
                                 size)
            if hit then
                local hit, point, normal, shape_hit =
                    FuncQueryClosestPoint(pos, size)
                if hit then
                    pos = FuncVecAdd(point, FuncVecScale(normal, 0.1))
                end
                onfire[#onfire + 1] = {pos, 0, vecstart, size, pos, intensity, outerpoints}
            end
        end
        return
    end
    -- Calculate 4 boxes inside bounding b

    -- if FuncQueryAabbFireCount(outerpoints[1], outerpoints[7]) > 0 then
    local midpoint = FireDetector_VecMidPoint(outerpoints[1],
                                        FireDetector_VecMidPoint(outerpoints[1],
                                                                 outerpoints[7]))
    -- FuncCreateBox(midpoint, size / 2, nil, {1, 0, 0}, false)
    FireDetector_RecursiveBinarySearchFire(midpoint, size / 2, size_fire_count,
                                           min_size, max_fires, onfire,
                                           intensity, fire_intensity_multiplier, ignore)
    midpoint = FireDetector_VecMidPoint(outerpoints[2],
                                        FireDetector_VecMidPoint(outerpoints[2],
                                                                 outerpoints[8]))
    -- FuncCreateBox(midpoint, size / 2, nil, {1, 0, 0}, false)
    FireDetector_RecursiveBinarySearchFire(midpoint, size / 2, size_fire_count,
                                           min_size, max_fires, onfire,
                                           intensity, fire_intensity_multiplier, ignore)

    midpoint = FireDetector_VecMidPoint(outerpoints[3],
                                        FireDetector_VecMidPoint(outerpoints[3],
                                                                 outerpoints[5]))
    -- FuncCreateBox(midpoint, size / 2, nil, {1, 0, 0}, false)
    FireDetector_RecursiveBinarySearchFire(midpoint, size / 2, size_fire_count,
                                           min_size, max_fires, onfire,
                                           intensity, fire_intensity_multiplier, ignore)

    midpoint = FireDetector_VecMidPoint(outerpoints[4],
                                        FireDetector_VecMidPoint(outerpoints[4],
                                                                 outerpoints[6]))
    -- FuncCreateBox(midpoint, size / 2, nil, {1, 0, 0}, false)
    FireDetector_RecursiveBinarySearchFire(midpoint, size / 2, size_fire_count,
                                           min_size, max_fires, onfire,
                                           intensity, fire_intensity_multiplier, ignore)

    midpoint = FireDetector_VecMidPoint(outerpoints[5],
                                        FireDetector_VecMidPoint(outerpoints[5],
                                                                 outerpoints[3]))
    -- FuncCreateBox(midpoint, size / 2, nil, {1, 0, 0}, false)
    FireDetector_RecursiveBinarySearchFire(midpoint, size / 2, size_fire_count,
                                           min_size, max_fires, onfire,
                                           intensity, fire_intensity_multiplier, ignore)

    midpoint = FireDetector_VecMidPoint(outerpoints[6],
                                        FireDetector_VecMidPoint(outerpoints[6],
                                                                 outerpoints[4]))
    -- FuncCreateBox(midpoint, size / 2, nil, {1, 0, 0}, false)
    FireDetector_RecursiveBinarySearchFire(midpoint, size / 2, size_fire_count,
                                           min_size, max_fires, onfire,
                                           intensity, fire_intensity_multiplier, ignore)

    midpoint = FireDetector_VecMidPoint(outerpoints[7],
                                        FireDetector_VecMidPoint(outerpoints[7],
                                                                 outerpoints[1]))
    -- FuncCreateBox(midpoint, size / 2, nil, {1, 0, 0}, false)
    FireDetector_RecursiveBinarySearchFire(midpoint, size / 2, size_fire_count,
                                           min_size, max_fires, onfire,
                                           intensity, fire_intensity_multiplier, ignore)

    midpoint = FireDetector_VecMidPoint(outerpoints[8],
                                        FireDetector_VecMidPoint(outerpoints[8],
                                                                 outerpoints[2]))
    -- FuncCreateBox(midpoint, size / 2, nil, {1, 0, 0}, false)
    FireDetector_RecursiveBinarySearchFire(midpoint, size / 2, size_fire_count,
                                           min_size, max_fires, onfire,
                                           intensity, fire_intensity_multiplier, ignore)

    -- FuncDrawPoint(vecstart, 1,0,1)

end

---Use this in the draw function!
function FireDetector_ShowStatus()
    if GeneralOptions_GetShowUiInGame() == "YES" then
        FuncDebugWatch("FireDetector, Fire count",
                   FireDetector_LocalDB["fire_count"])
        FuncDebugWatch("FireDetector, time elapsed",
                   tostring(FireDetector_LocalDB["time_elapsed"]))
        FuncDebugWatch("FireDetector, intensity",
                   tostring(FireDetector_LocalDB["fire_intensity"]))
        FuncDebugWatch("FireDetector, randomtimer",
                   tostring(FireDetector_LocalDB["random_timer"]))
        FuncDebugWatch("FireDetector, timer",
                   tostring(FireDetector_LocalDB["timer"]))
        FuncDebugWatch("FireDetector, map_size",
                   tostring(FireDetector_Properties["map_size"]))
    end
end

