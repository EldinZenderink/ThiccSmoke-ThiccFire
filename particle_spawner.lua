-- firedetector.lua
-- @date 2021-09-13
-- @author Eldin Zenderink
-- @brief This module spawns particles and adjust dynamically based on FPS, it can however be adjusted
--        if you do desire a slideshow :P.

ParticleSpawner_Properties = {
    fire = "YES",
    smoke = "YES",
    toggle_smoke_fire = "1:1",
    dynamic_fps = "ON",
    spawn_light = "ON",
    red_light_divider = 1,
    green_light_divider = 1.75,
    blue_light_divider = 4,
    light_flickering_intensity = 4,
    light_intensity = 0.5,
    dynamic_fps_target = 48,
    particle_refresh_max = 60,
    particle_refresh_min = 24,
    aggressivenes = 1,
}

ParticleSpawner_ParticlesToSpawn = {}
ParticleSpawner_LightEntities = {}
ParticleSpawner_CurFPSTarget = nil
ParticleSpawner_CurFPS = nil
ParticleSpawner_FindNew = true
ParticleSpawner_FireToSmokeSpawner = 0
ParticleSpawner_RefreshTimer = 0
ParticleSpawner_ParticleRefreshRate = 5.0
ParticleSpawner_SpawnLight = false
ParticleSpawner_TimeElapsed = 0


function ParticleSpawner_Init()
    ParticleSpawner_ParticleRefreshRate = ParticleSpawner_Properties["particle_refresh_max"]
    if ParticleSpawner_Properties["spawn_light"] == "ON" then
        ParticleSpawner_SpawnLight = true
    else
        ParticleSpawner_SpawnLight = false
    end
    ParticleSpawner_FindNew = true
    Settings_RegisterUpdateSettingsCallback(ParticleSpawner_UpdateSettingsFromSettings)
end

function ParticleSpawner_UpdateSettingsFromSettings()
    ParticleSpawner_Properties["fire"] = Settings_GetValue("ParticleSpawner", "fire")
	ParticleSpawner_Properties["smoke"] = Settings_GetValue("ParticleSpawner", "smoke")
	ParticleSpawner_Properties["toggle_smoke_fire"] = Settings_GetValue("ParticleSpawner", "toggle_smoke_fire")
	ParticleSpawner_Properties["dynamic_fps"] = Settings_GetValue("ParticleSpawner", "dynamic_fps")
    ParticleSpawner_Properties["dynamic_fps_target"] = Settings_GetValue("ParticleSpawner", "dynamic_fps_target")
    ParticleSpawner_Properties["particle_refresh_max"] = Settings_GetValue("ParticleSpawner", "particle_refresh_max")
    ParticleSpawner_Properties["particle_refresh_min"] = Settings_GetValue("ParticleSpawner", "particle_refresh_min")
    ParticleSpawner_Properties["aggressivenes"] = Settings_GetValue("ParticleSpawner", "aggressivenes")
    ParticleSpawner_Properties["spawn_light"] = Settings_GetValue("ParticleSpawner", "spawn_light")
    ParticleSpawner_Properties["red_light_divider"] = Settings_GetValue("ParticleSpawner", "red_light_divider")
    ParticleSpawner_Properties["green_light_divider"] = Settings_GetValue("ParticleSpawner", "green_light_divider")
    ParticleSpawner_Properties["blue_light_divider"] = Settings_GetValue("ParticleSpawner", "blue_light_divider")
    ParticleSpawner_Properties["light_intensity"] = Settings_GetValue("ParticleSpawner", "light_intensity")
    ParticleSpawner_Properties["light_flickering_intensity"] = Settings_GetValue("ParticleSpawner", "light_flickering_intensity")


    if ParticleSpawner_Properties["light_intensity"]  == nil or  ParticleSpawner_Properties["light_intensity"] < 0.1 then
        ParticleSpawner_Properties["light_intensity"] = 1
        Settings_SetValue("ParticleSpawner", "light_intensity",  ParticleSpawner_Properties["light_intensity"])
        Settings_StoreActivePreset()
    end

    if ParticleSpawner_Properties["red_light_divider"]  == nil or  ParticleSpawner_Properties["red_light_divider"] > 1 or  ParticleSpawner_Properties["red_light_divider"] < -1 then
        ParticleSpawner_Properties["red_light_divider"] = 0
        Settings_SetValue("ParticleSpawner", "red_light_divider",  ParticleSpawner_Properties["red_light_divider"])
        Settings_StoreActivePreset()
    end
    if ParticleSpawner_Properties["green_light_divider"]  == nil or  ParticleSpawner_Properties["green_light_divider"] > 1 or  ParticleSpawner_Properties["green_light_divider"] < -1 then
        ParticleSpawner_Properties["green_light_divider"] = -0.2
        Settings_SetValue("ParticleSpawner", "green_light_divider", ParticleSpawner_Properties["green_light_divider"])
        Settings_StoreActivePreset()
    end
    if ParticleSpawner_Properties["blue_light_divider"]  == nil or  ParticleSpawner_Properties["blue_light_divider"] > 1 or  ParticleSpawner_Properties["blue_light_divider"] < -1 then
        ParticleSpawner_Properties["blue_light_divider"] = -0.4
        Settings_SetValue("ParticleSpawner", "blue_light_divider", ParticleSpawner_Properties["blue_light_divider"] )
        Settings_StoreActivePreset()
    end


    ParticleSpawner_ParticleRefreshRate =  ParticleSpawner_Properties["particle_refresh_max"]
    ParticleSpawner_CurFPSTarget = ParticleSpawner_Properties["dynamic_fps_target"]
    if ParticleSpawner_Properties["spawn_light"] == "ON" then
        ParticleSpawner_SpawnLight = true
    else
        ParticleSpawner_SpawnLight = false
    end

end

function ParticleSpawner_tick(dt)
    local Particle_RefreshMax = ParticleSpawner_Properties["particle_refresh_max"]
    local Particle_RefreshMin = ParticleSpawner_Properties["particle_refresh_min"]
    local FPS_Target = ParticleSpawner_Properties["dynamic_fps_target"]
    local enabled = ParticleSpawner_Properties["dynamic_fps"]
    local aggressivenes = ParticleSpawner_Properties["aggressivenes"]

    ParticleSpawner_CurFPS = 1 / dt
    if ParticleSpawner_CurFPSTarget == nil then
        ParticleSpawner_CurFPSTarget = FPS_Target
    end
    if enabled == "ON" then
        local below_target = false
        if ParticleSpawner_CurFPS < ParticleSpawner_CurFPSTarget then
            below_target = true
        end
        if below_target == true and ParticleSpawner_ParticleRefreshRate > Particle_RefreshMin then
            ParticleSpawner_ParticleRefreshRate = ParticleSpawner_ParticleRefreshRate - aggressivenes
        elseif below_target == false and ParticleSpawner_ParticleRefreshRate < Particle_RefreshMax then
            ParticleSpawner_ParticleRefreshRate = ParticleSpawner_ParticleRefreshRate + aggressivenes
        end
    else
        ParticleSpawner_ParticleRefreshRate = Particle_RefreshMax
    end
    ParticleSpawner_TimeElapsed = ParticleSpawner_TimeElapsed + dt
end

function ParticleSpawner_update(dt)
    local fire = ParticleSpawner_Properties["fire"]
    local smoke = ParticleSpawner_Properties["smoke"]
    local toggle = ParticleSpawner_Properties["toggle_smoke_fire"]

    local spawn_fire = true
    local spawn_smoke = true

    if ParticleSpawner_ParticlesToSpawn then

        if ParticleSpawner_RefreshTimer > (1 / ParticleSpawner_ParticleRefreshRate) then

            if toggle == "1:1" then
                spawn_fire = true
                spawn_smoke = true
            end

            if toggle == "1:2" and ParticleSpawner_FireToSmokeSpawner < 2 then
                spawn_fire = true
                spawn_smoke = false
                ParticleSpawner_FireToSmokeSpawner = ParticleSpawner_FireToSmokeSpawner + 1
            elseif toggle == "1:2" then
                spawn_smoke = true
                spawn_fire = true
                ParticleSpawner_FireToSmokeSpawner = 0
            end

            if toggle == "1:4" and ParticleSpawner_FireToSmokeSpawner < 4 then
                spawn_fire = true
                spawn_smoke = false
                ParticleSpawner_FireToSmokeSpawner = ParticleSpawner_FireToSmokeSpawner + 1
            elseif toggle == "1:4" then
                spawn_smoke = true
                spawn_fire = true
                ParticleSpawner_FireToSmokeSpawner = 0
            end


            if toggle == "1:8" and ParticleSpawner_FireToSmokeSpawner < 8 then
                spawn_fire = true
                spawn_smoke = false
                ParticleSpawner_FireToSmokeSpawner = ParticleSpawner_FireToSmokeSpawner + 1
            elseif toggle == "1:8" then
                spawn_smoke = true
                spawn_fire = true
                ParticleSpawner_FireToSmokeSpawner = 0
            end
            LightSpawner_DeleteAll()
            for hash, info in pairs(ParticleSpawner_ParticlesToSpawn) do
                if info ~= nil then
                    local firemat = Generic_deepCopy(FireMaterial_GetInfo(info["material"]))
                    if smoke == "YES" and spawn_smoke then
                        Particle_EmitParticle(SmokeMaterial_GetInfo(info["material"]), info["location"], "smoke", info["fire_intensity"])
                    end
                    if fire == "YES" and spawn_fire then
                        Particle_EmitParticle(firemat, info["location"], "fire", info["fire_intensity"])
                    end
                    if ParticleSpawner_SpawnLight then
                        local tenth = info["fire_intensity"]  / ParticleSpawner_Properties["light_flickering_intensity"]
                        local light_intensity = info["fire_intensity"] + Generic_rnd(tenth * -1, tenth)
                        if light_intensity < 5 then
                            light_intensity = 5 + Generic_rnd(-1.5, 1.5)
                        end
                        light_intensity = light_intensity * ParticleSpawner_Properties["light_intensity"]
                        firemat["color"]["r"] =  firemat["color"]["r"] + ParticleSpawner_Properties["red_light_divider"]
                        firemat["color"]["g"] =  firemat["color"]["g"] + ParticleSpawner_Properties["green_light_divider"]
                        firemat["color"]["b"] =  firemat["color"]["b"] + ParticleSpawner_Properties["blue_light_divider"]

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
                        LightSpawner_Spawn(info["location"], light_intensity, light_intensity, Vec(firemat["color"]["r"],firemat["color"]["g"],firemat["color"]["n"]), true)
                    end
                end
            end


            ParticleSpawner_RefreshTimer = 0
            ParticleSpawner_FindNew = true
        end
    else
        ParticleSpawner_FindNew = true
    end

    if ParticleSpawner_FindNew then
        ParticleSpawner_FindNew = false
        ParticleSpawner_ParticlesToSpawn = FireDetector_FindFireLocationsV2(dt, true)
        Wind_ChangeWind(dt, true) -- Dont have to do it 60 times a second ;P.

    else
        ParticleSpawner_ParticlesToSpawn = FireDetector_FindFireLocationsV2(dt, false)
        Wind_ChangeWind(dt, false) -- Dont have to do it 60 times a second ;P.
    end
    ParticleSpawner_RefreshTimer = ParticleSpawner_RefreshTimer + dt
end

function ParticleSpawner_ShowStatus()
    if GeneralOptions_GetShowUiInGame() == "YES" then
        DebugWatch(Version_GetName() .. " - ParticleSpawner, Particle Refresh Rate", ParticleSpawner_ParticleRefreshRate)
        DebugWatch(Version_GetName() .. " - ParticleSpawner, Spawn Period",  (1 / ParticleSpawner_ParticleRefreshRate))
        DebugWatch(Version_GetName() .. " - ParticleSpawner, Spawn Timer", ParticleSpawner_RefreshTimer)
        DebugWatch(Version_GetName() .. " - ParticleSpawner, FPS", ParticleSpawner_CurFPS)
        DebugWatch(Version_GetName() .. " - ParticleSpawner, FPS Target", ParticleSpawner_CurFPSTarget)
    end
end