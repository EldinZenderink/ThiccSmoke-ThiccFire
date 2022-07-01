-- firedetector.lua
-- @date 2021-09-13
-- @author Eldin Zenderink
-- @brief This module spawns particles and adjust dynamically based on FPS, it can however be adjusted
--        if you do desire a slideshow :P.

ParticleSpawner_Properties = {
    fire = "YES",
    smoke = "YES",
    toggle_smoke_fire = "1:1",
    toggle_smoke_ash = "1:1",
    dynamic_fps = "ON",
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
ParticleSpawner_AshToSmokeSpawner = 0
ParticleSpawner_RefreshTimer = 0
ParticleSpawner_ParticleRefreshRate = 5.0
ParticleSpawner_TimeElapsed = 0


function ParticleSpawner_Init()
    ParticleSpawner_ParticleRefreshRate = ParticleSpawner_Properties["particle_refresh_max"]
    ParticleSpawner_FindNew = true
    Settings_RegisterUpdateSettingsCallback(ParticleSpawner_UpdateSettingsFromSettings)
end

function ParticleSpawner_UpdateSettingsFromSettings()
    ParticleSpawner_Properties["fire"] = Settings_GetValue("ParticleSpawner", "fire")
	ParticleSpawner_Properties["smoke"] = Settings_GetValue("ParticleSpawner", "smoke")
	ParticleSpawner_Properties["toggle_smoke_fire"] = Settings_GetValue("ParticleSpawner", "fire_to_smoke_ratio")
	ParticleSpawner_Properties["dynamic_fps"] = Settings_GetValue("ParticleSpawner", "dynamic_fps")
    ParticleSpawner_Properties["dynamic_fps_target"] = Settings_GetValue("ParticleSpawner", "dynamic_fps_target")
    ParticleSpawner_Properties["particle_refresh_max"] = Settings_GetValue("ParticleSpawner", "particle_refresh_max")
    ParticleSpawner_Properties["particle_refresh_min"] = Settings_GetValue("ParticleSpawner", "particle_refresh_min")
    ParticleSpawner_Properties["aggressivenes"] = Settings_GetValue("ParticleSpawner", "aggressivenes")


	ParticleSpawner_Properties["ash"] = Settings_GetValue("ParticleSpawner", "ash")

    if ParticleSpawner_Properties["ash"] == "" or ParticleSpawner_Properties["ash"] == nil then
        Settings_SetValue("ParticleSpawner", "ash", "YES")
        ParticleSpawner_Properties["ash"] = "YES"
    end
	ParticleSpawner_Properties["toggle_smoke_ash"] = Settings_GetValue("ParticleSpawner", "ash_to_smoke_ratio")
    if ParticleSpawner_Properties["toggle_smoke_ash"] == "" or ParticleSpawner_Properties["toggle_smoke_ash"] == nil then
        Settings_SetValue("ParticleSpawner", "ash_to_smoke_ratio", "1:30")
        ParticleSpawner_Properties["toggle_smoke_ash"] = "1:30"
    end


    ParticleSpawner_ParticleRefreshRate =  ParticleSpawner_Properties["particle_refresh_max"]
    ParticleSpawner_CurFPSTarget = ParticleSpawner_Properties["dynamic_fps_target"]
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
    local ash = ParticleSpawner_Properties["ash"]
    local toggle = ParticleSpawner_Properties["toggle_smoke_fire"]
    local toggle_ash = ParticleSpawner_Properties["toggle_smoke_ash"]

    local spawn_fire = false
    local spawn_smoke = true
    local spawn_ash = false

    if ParticleSpawner_ParticlesToSpawn then

        if ParticleSpawner_RefreshTimer > (1 / ParticleSpawner_ParticleRefreshRate) then

            if toggle == "1:1" then
                spawn_fire = true
            end
            if toggle_ash == "1:1" then
                spawn_ash = true
            end

            if toggle == "1:2" and ParticleSpawner_FireToSmokeSpawner < 2 then
                spawn_fire = false
                ParticleSpawner_FireToSmokeSpawner = ParticleSpawner_FireToSmokeSpawner + 1
            elseif toggle == "1:2" then
                spawn_fire = true
                ParticleSpawner_FireToSmokeSpawner = 0
            end

            if toggle == "1:4" and ParticleSpawner_FireToSmokeSpawner < 4 then
                spawn_fire = false
                ParticleSpawner_FireToSmokeSpawner = ParticleSpawner_FireToSmokeSpawner + 1
            elseif toggle == "1:4" then
                spawn_fire = true
                ParticleSpawner_FireToSmokeSpawner = 0
            end

            if toggle == "1:8" and ParticleSpawner_FireToSmokeSpawner < 8 then
                spawn_fire = false
                ParticleSpawner_FireToSmokeSpawner = ParticleSpawner_FireToSmokeSpawner + 1
            elseif toggle == "1:8" then
                spawn_fire = true
                ParticleSpawner_FireToSmokeSpawner = 0
            end

            if toggle == "1:15" and ParticleSpawner_FireToSmokeSpawner < 15 then
                spawn_fire = false
                ParticleSpawner_FireToSmokeSpawner = ParticleSpawner_FireToSmokeSpawner + 1
            elseif toggle == "1:15" then
                spawn_fire = true
                ParticleSpawner_FireToSmokeSpawner = 0
            end

            if toggle == "1:30" and ParticleSpawner_FireToSmokeSpawner < 30 then
                spawn_fire = false
                ParticleSpawner_FireToSmokeSpawner = ParticleSpawner_FireToSmokeSpawner + 1
            elseif toggle == "1:30" then
                spawn_fire = true
                ParticleSpawner_FireToSmokeSpawner = 0
            end

            if toggle == "1:60" and ParticleSpawner_FireToSmokeSpawner < 60 then
                spawn_fire = false
                ParticleSpawner_FireToSmokeSpawner = ParticleSpawner_FireToSmokeSpawner + 1
            elseif toggle == "1:60" then
                spawn_fire = true
                ParticleSpawner_FireToSmokeSpawner = 0
            end

            if toggle_ash == "1:2" and ParticleSpawner_AshToSmokeSpawner < 2 then
                spawn_ash = false
                ParticleSpawner_AshToSmokeSpawner = ParticleSpawner_AshToSmokeSpawner + 1
            elseif toggle_ash == "1:2" then
                spawn_ash = true
                ParticleSpawner_AshToSmokeSpawner = 0
            end

            if toggle_ash == "1:4" and ParticleSpawner_AshToSmokeSpawner < 4 then
                spawn_ash = false
                ParticleSpawner_AshToSmokeSpawner = ParticleSpawner_AshToSmokeSpawner + 1
            elseif toggle_ash == "1:4" then
                spawn_ash = true
                ParticleSpawner_AshToSmokeSpawner = 0
            end

            if toggle_ash == "1:8" and ParticleSpawner_AshToSmokeSpawner < 8 then
                spawn_ash = false
                ParticleSpawner_AshToSmokeSpawner = ParticleSpawner_AshToSmokeSpawner + 1
            elseif toggle_ash == "1:8" then
                spawn_ash = true
                ParticleSpawner_AshToSmokeSpawner = 0
            end

            if toggle_ash == "1:15" and ParticleSpawner_AshToSmokeSpawner < 15 then
                spawn_ash = false
                ParticleSpawner_AshToSmokeSpawner = ParticleSpawner_AshToSmokeSpawner + 1
            elseif toggle_ash == "1:15" then
                spawn_ash = true
                ParticleSpawner_AshToSmokeSpawner = 0
            end

            if toggle_ash == "1:30" and ParticleSpawner_AshToSmokeSpawner < 30 then
                spawn_ash = false
                ParticleSpawner_AshToSmokeSpawner = ParticleSpawner_AshToSmokeSpawner + 1
            elseif toggle_ash == "1:30" then
                spawn_ash = true
                ParticleSpawner_AshToSmokeSpawner = 0
            end

            if toggle_ash == "1:60" and ParticleSpawner_AshToSmokeSpawner < 60 then
                spawn_ash = false
                ParticleSpawner_AshToSmokeSpawner = ParticleSpawner_AshToSmokeSpawner + 1
            elseif toggle_ash == "1:60" then
                spawn_ash = true
                ParticleSpawner_AshToSmokeSpawner = 0
            end

            for hash, info in pairs(ParticleSpawner_ParticlesToSpawn) do
                if info ~= nil then
                    local firemat = Generic_deepCopy(FireMaterial_GetInfo(info["material"]))
                    local smokemat = Generic_deepCopy(SmokeMaterial_GetInfo(info["material"]))
                    if smoke == "YES" and spawn_smoke then
                        Particle_EmitParticle(smokemat, info["location"], "smoke", info["fire_intensity"])
                    end
                    if fire == "YES" and spawn_fire then
                        Particle_EmitParticle(firemat, info["location"], "fire", info["fire_intensity"])
                    end
                    if ash == "YES" and spawn_ash then
                        if Generic_rndInt(0,1) == 1 then
                            Particle_EmitParticle(smokemat, info["location"], "ash", info["fire_intensity"])
                        end
                        if Generic_rndInt(0,1) == 1 then
                            Particle_EmitParticle(firemat, info["location"], "ash_fire", info["fire_intensity"])
                        end
                    end
                end
            end

            Light_SpawnLight(ParticleSpawner_ParticlesToSpawn)
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