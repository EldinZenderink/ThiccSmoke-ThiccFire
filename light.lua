-- wind.lua
-- @date 2022-02-26
-- @author Eldin Zenderink
-- @brief Helper module for generating winds

Light_Properties = {
    spawn_light = "ON",
    light_intensity = 0.5,
    light_flickering_intensity = 4,
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
end


function Light_SpawnLightLegacy()
    if Light_Properties["legacy"] == "YES" and Light_Properties["spawn_light"] == "ON" then
        local fires = FireDetector_GetLightAndWindLocations()
        for i=1, #fires do
            local fire_info = fires[i]
            if fire_info ~= nil and fire_info["light_location"] ~= nil then
                if Light_SpawnLight then
                    local tenth = fire_info["fire_intensity"]  / Light_Properties["light_flickering_intensity"]
                    local light_intensity = fire_info["fire_intensity"] + Generic_rnd(tenth * -1, tenth)
                    if light_intensity < 5 then
                        light_intensity = 5 + Generic_rnd(-1.5, 1.5)
                    end
                    local firemat = Generic_deepCopy(FireMaterial_GetInfo(fire_info["material"]))

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
                    PointLight(VecAdd(fire_info["light_location"], Generic_rndVec(0.01)), firemat["color"]["r"], firemat["color"]["g"], firemat["color"]["b"], light_intensity * Light_Properties["light_intensity"] )
                end
            end
        end
    end
end

function Light_SpawnLight(fires)
    if Light_Properties["legacy"] == "NO" and Light_Properties["spawn_light"] == "ON" then
        LightSpawner_DeleteAll()
        for hash, fire_info in pairs(fires) do
            local tenth = fire_info["fire_intensity"]  / Light_Properties["light_flickering_intensity"]
            local light_intensity = fire_info["fire_intensity"] + Generic_rnd(tenth * -1, tenth)
            if light_intensity < 5 then
                light_intensity = 5 + Generic_rnd(-1.5, 1.5)
            end
            light_intensity = light_intensity * Light_Properties["light_intensity"]
            local firemat = Generic_deepCopy(FireMaterial_GetInfo(fire_info["material"]))
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
            LightSpawner_Spawn(fire_info["location"], light_intensity, light_intensity, Vec(firemat["color"]["r"],firemat["color"]["g"],firemat["color"]["n"]), true)
        end
    else
        LightSpawner_DeleteAll()
    end
end

