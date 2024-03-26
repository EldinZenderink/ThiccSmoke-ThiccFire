-- light.lua
-- @date 2022-02-26
-- @author Eldin Zenderink
-- @brief Helper module for generating winds

Light_Properties = {
    spawn_light = "ON",
    light_intensity = 0.2,
    light_flickering_intensity = 3,
    red_light_offset = 0.2,
    green_light_offset = 0.1,
    blue_light_offset = -0.3,
    legacy="NO"
}


Light_LightEntities = {}

Light_WindEnabled = "ON"
Light_WindStrength = 6
Light_WindDirection = 360
Light_WindStrenghtRandom = 1

Light_LocalDirection = 0
Light_LocaDirAdd = true

-- Optimize dynamic compile time, should compile only once localy?  According to: https://www.lua.org/gems/sample.pdf
-- local pairs = pairs

local FuncVec = Vec

local FuncDeepCopy = Generic_deepCopy


function Light_Init()
    Settings_RegisterUpdateSettingsCallback(Light_UpdateSettingsFromSettings)
end

function Light_UpdateSettingsFromSettings()

    Light_Properties["spawn_light"] = Settings_GetValue("Light", "spawn_light")
    Light_Properties["red_light_offset"] = Settings_GetValue("Light", "red_light_offset")
    Light_Properties["green_light_offset"] = Settings_GetValue("Light", "green_light_offset")
    Light_Properties["blue_light_offset"] = Settings_GetValue("Light", "blue_light_offset")
    Light_Properties["light_intensity"] = Settings_GetValue("Light", "light_intensity")
    Light_Properties["light_flickering_intensity"] = Settings_GetValue("Light", "light_flickering_intensity")
    Light_Properties["legacy"] = Settings_GetValue("Light", "legacy")

    if Light_Properties["legacy"] == "YES" then
        Light_Properties["legacy"] = "NO"
    end

    if Light_Properties["light_intensity"]  == nil or Light_Properties["light_intensity"] < 0.1 then
        Light_Properties["light_intensity"] = 1
        Settings_SetValue("Light", "light_intensity",  Light_Properties["light_intensity"])
        Settings_StoreActivePreset()
    end
    if Light_Properties["light_flickering_intensity"]  == nil or Light_Properties["light_flickering_intensity"] < 1 then
        Light_Properties["light_flickering_intensity"] = 5
        Settings_SetValue("Light", "light_flickering_intensity",  Light_Properties["light_flickering_intensity"])
        Settings_StoreActivePreset()
    end
    if Light_Properties["red_light_offset"]  == nil or  Light_Properties["red_light_offset"] > 1 or  Light_Properties["red_light_offset"] < -1 then
        Light_Properties["red_light_offset"] = 0
        Settings_SetValue("Light", "red_light_offset",  Light_Properties["red_light_offset"])
        Settings_StoreActivePreset()
    end
    if Light_Properties["green_light_offset"]  == nil or  Light_Properties["green_light_offset"] > 1 or  Light_Properties["green_light_offset"] < -1 then
        Light_Properties["green_light_offset"] = -0.2
        Settings_SetValue("Light", "green_light_offset", Light_Properties["green_light_offset"])
        Settings_StoreActivePreset()
    end
    if Light_Properties["blue_light_offset"]  == nil or  Light_Properties["blue_light_offset"] > 1 or  Light_Properties["blue_light_offset"] < -1 then
        Light_Properties["blue_light_offset"] = -0.2
        Settings_SetValue("Light", "blue_light_offset", Light_Properties["blue_light_offset"] )
        Settings_StoreActivePreset()
    end
    if Light_Properties["legacy"] == nil or Light_Properties["legacy"] == "" then
        Light_Properties["legacy"] = "NO"
        Settings_SetValue("Light", "legacy",  Light_Properties["legacy"])
        Settings_StoreActivePreset()
    end
    FireSim_RegisterUpdateFireCallback("updatelight", Light_UpdateFireCallback, 0.1)
    FireSim_RegisterDeleteFireCallback("spawnlight", Light_DeleteFireCallback, 0)
end


function Light_UpdateLights(dt)
    local count = 0
    for hash, light in pairs(Light_LightEntities) do
        if light["state"] == "lightup" then
            if Light_LightEntities[hash]["current_intensity"] < Light_LightEntities[hash]["current_intensity_max"] then
                Light_LightEntities[hash]["current_intensity"] = Light_LightEntities[hash]["current_intensity"] + 0.5
            else
                Light_LightEntities[hash]["state"] = "stable"
            end
        end

        if light["state"] == "stable" then
            Light_LightEntities[hash]["current_intensity"] = Light_LightEntities[hash]["current_intensity_max"]
        end

        if light["state"] == "lightdown" then
            if Light_LightEntities[hash]["current_intensity"] > 0  then
                Light_LightEntities[hash]["current_intensity"] = Light_LightEntities[hash]["current_intensity"] - 0.5
            else
                Light_LightEntities[hash]["state"] = "delete"
            end
        end

        if light["state"] == "delete" then
            LightSpawner_DeleteLight(light["id"])
            Light_LightEntities[hash] = nil
        else
            count = count + 1
            LightSpawner_UpdateLightIntensity(light["id"], light["current_intensity"])
        end
    end
    -- DebugWatch("lights", count)
end


function Light_UpdateFireCallback(hash, fire)

    if  Light_Properties["spawn_light"] == "ON" then
        -- local tenth = fire["fire_intensity"]  / 10
        -- tenth = Light_Properties["light_flickering_intensity"] * tenth
        -- local light_intensity = fire["fire_intensity"] + Generic_rnd(tenth * -1, tenth)
        -- light_intensity = light_intensity * Light_Properties["light_intensity"]
        if Light_LightEntities[hash] == nil then
            local firemat = Generic_deepCopy(FireMaterial_GetInfo(fire["material"]))
            firemat["color"]["r"] =  firemat["color"]["r"] + Light_Properties["red_light_offset"]
            firemat["color"]["g"] =  firemat["color"]["g"] + Light_Properties["green_light_offset"]
            firemat["color"]["b"] =  firemat["color"]["b"] + Light_Properties["blue_light_offset"]

            if  firemat["color"]["r"] > 1 then
                firemat["color"]["r"] = 1
            end
            if  firemat["color"]["r"] < 0 then
                firemat["color"]["r"] = 0
            end

            if  firemat["color"]["g"] > 1 then
                firemat["color"]["g"] = 1
            end
            if  firemat["color"]["g"] < 0 then
                firemat["color"]["g"] = 0
            end

            if  firemat["color"]["b"] > 1 then
                firemat["color"]["b"] = 1
            end
            if  firemat["color"]["b"] < 0 then
                firemat["color"]["b"] = 0
            end
            Light_LightEntities[hash] = LightSpawner_Spawn(VecAdd(fire["location"], VecScale(fire["normal"], 0.1)), fire["fire_intensity"] / 50, (fire["fire_intensity"] * fire["fire_intensity"])/ 200, FuncVec(firemat["color"]["r"],firemat["color"]["g"],firemat["color"]["n"]), true)
        else

            -- fire["light"] = FuncLightSpawnerSetNewLightLocation(fire["light"], VecAdd(fire["location"], VecScale(fire["normal"], 0.05)))
            local currentIntensity = LightSpawner_GetLightIntensity(fire["light"])
            local newlightIntensity = fire["fire_intensity"]
            if currentIntensity == 0 or currentIntensity == nil then
                currentIntensity = fire["fire_intensity"]
            end
            local adjustedLightIntesity = fire["fire_intensity"]
            if (currentIntensity < newlightIntensity or currentIntensity < 0) and (newlightIntensity / currentIntensity) > 0 then
                adjustedLightIntesity = currentIntensity + (newlightIntensity / currentIntensity)
            elseif (currentIntensity / newlightIntensity) > 0 then
                adjustedLightIntesity = currentIntensity - (newlightIntensity / currentIntensity)
            end
            Light_LightEntities[hash] = LightSpawner_UpdateLightIntensity(Light_LightEntities[hash], (adjustedLightIntesity * adjustedLightIntesity) / 200)
            Light_LightEntities[hash] = LightSpawner_SetNewLightSize(Light_LightEntities[hash] , adjustedLightIntesity / 50)
            Light_LightEntities[hash] = LightSpawner_SetNewLightLocation(Light_LightEntities[hash],VecAdd(fire["location"], VecScale(fire["normal"], 0.01)))
        end
    end

end

function Light_DeleteFireCallback(hash, fire)
    LightSpawner_DeleteLight(Light_LightEntities[hash])
end