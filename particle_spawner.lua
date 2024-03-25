-- FireSim.lua
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
ParticleSpawner_SpawnTimer = 0
ParticleSpawner_ParticleRefreshRate = 5.0
ParticleSpawner_TimeElapsed = 0

-- Optimize dynamic compile time, should compile only once localy?  According to: https://www.lua.org/gems/sample.pdf
-- local pairs = pairs

local FuncDeepCopy = Generic_deepCopy
local FuncRndNum = Generic_rnd
local FuncRndInt = Generic_rndInt

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

    -- Register callback with fire sim
    FireSim_RegisterUpdateFireCallback("particle", ParticleSpawner_SpawnFireCallback, (1 / ParticleSpawner_ParticleRefreshRate))
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
    local fire = ParticleSpawner_Properties["fire"]
    local smoke = ParticleSpawner_Properties["smoke"]
    local ash = ParticleSpawner_Properties["ash"]
    local toggle = ParticleSpawner_Properties["toggle_smoke_fire"]
    local toggle_ash = ParticleSpawner_Properties["toggle_smoke_ash"]

    local spawn_ash = false
    local spawn_fire = false

    if ParticleSpawner_ParticlesToSpawn then

        if ParticleSpawner_SpawnTimer > (1 / ParticleSpawner_ParticleRefreshRate) then

            if toggle == "1:1" then
                ParticleSpawner_FireToSmokeSpawner = 0
                spawn_fire = true
            end
            if toggle_ash == "1:1" then
                spawn_ash = true
            end

            if toggle == "1:2" and ParticleSpawner_FireToSmokeSpawner < 2 then
                ParticleSpawner_FireToSmokeSpawner = ParticleSpawner_FireToSmokeSpawner + 1
            elseif toggle == "1:2" then
                ParticleSpawner_FireToSmokeSpawner = 0
                spawn_fire = true
            end

            if toggle == "1:4" and ParticleSpawner_FireToSmokeSpawner < 4 then
                ParticleSpawner_FireToSmokeSpawner = ParticleSpawner_FireToSmokeSpawner + 1
            elseif toggle == "1:4" then
                ParticleSpawner_FireToSmokeSpawner = 0
                spawn_fire = true
            end

            if toggle == "1:8" and ParticleSpawner_FireToSmokeSpawner < 8 then
                ParticleSpawner_FireToSmokeSpawner = ParticleSpawner_FireToSmokeSpawner + 1
            elseif toggle == "1:8" then
                ParticleSpawner_FireToSmokeSpawner = 0
            end

            if toggle == "1:15" and ParticleSpawner_FireToSmokeSpawner < 15 then
                ParticleSpawner_FireToSmokeSpawner = ParticleSpawner_FireToSmokeSpawner + 1
            elseif toggle == "1:15" then
                ParticleSpawner_FireToSmokeSpawner = 0
                spawn_fire = true
            end

            if toggle == "1:30" and ParticleSpawner_FireToSmokeSpawner < 30 then
                ParticleSpawner_FireToSmokeSpawner = ParticleSpawner_FireToSmokeSpawner + 1
            elseif toggle == "1:30" then
                ParticleSpawner_FireToSmokeSpawner = 0
                spawn_fire = true
            end

            if toggle == "1:60" and ParticleSpawner_FireToSmokeSpawner < 60 then
                ParticleSpawner_FireToSmokeSpawner = ParticleSpawner_FireToSmokeSpawner + 1
            elseif toggle == "1:60" then
                ParticleSpawner_FireToSmokeSpawner = 0
                spawn_fire = true
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


            local lights = {}
            for hash, info in pairs(ParticleSpawner_ParticlesToSpawn) do
                if info ~= nil then
                    local firemat = FuncDeepCopy(FireMaterial_GetInfo(info["material"]))
                    local smokemat = FuncDeepCopy(SmokeMaterial_GetInfo(info["material"]))
                    if smoke == "YES" then
                        ParticleSpawner_SpawnParticle(info["location"], smokemat, "smoke", info["fire_intensity"], false)
                    end
                    if fire == "YES" and spawn_fire then
                        ParticleSpawner_SpawnParticle(info["location"],firemat,  "fire", info["fire_intensity"], false)
                        -- if light then
                        --     lights[hash] = info
                        -- end
                        lights[hash] = info
                    end
                    if ash == "YES" and spawn_ash then
                        if FuncRndInt(0,1) == 1 then
                            Particle_EmitParticleOld(smokemat, info["location"], "ash", info["fire_intensity"])
                        end
                        if FuncRndInt(0,1) == 1 then
                            Particle_EmitParticleOld(firemat, info["location"], "ash_fire", info["fire_intensity"])
                        end
                    end
                end
            end


            ParticleSpawner_SpawnTimer = 0
            ParticleSpawner_FindNew = true
        end
    else
        ParticleSpawner_FindNew = true
    end

    ParticleSpawner_ParticlesToSpawn =  FireSim_GetFires(ParticleSpawner_FindNew)

    if ParticleSpawner_FindNew then
        ParticleSpawner_FindNew = false
    end


    if ParticleSpawner_RefreshTimer > (1 / ParticleSpawner_ParticleRefreshRate) then
        spawn_fire = false
        ParticleSpawner_RefreshTimer = 0
    end

    ParticleSpawner_RefreshTimer = ParticleSpawner_RefreshTimer + dt
    ParticleSpawner_SpawnTimer = ParticleSpawner_SpawnTimer + dt


end

--- Spawn particles for specific fires
---@param fire table object containing fire info.
function ParticleSpawner_SpawnFireCallback(hash, fire)
    local firemat = FireMaterial_GetInfo(fire["material"])
    local smokemat = SmokeMaterial_GetInfo(fire["material"])
    if ParticleSpawner_Properties["smoke"] == "YES" then
        ParticleSpawner_SpawnParticle(VecAdd(fire["location"], VecScale(fire["normal"], 0.05)), smokemat, "smoke", fire["fire_intensity"], false)
    end
    if ParticleSpawner_Properties["fire"] == "YES" then
        ParticleSpawner_SpawnParticle(VecAdd(fire["location"], VecScale(fire["normal"], 0.05)), firemat,  "fire", fire["fire_intensity"], false)
    end
    if ParticleSpawner_Properties["ash"] == "YES" then
        if FuncRndInt(0,1) == 1 then
            Particle_EmitParticleOld(firemat, VecAdd(fire["location"], VecScale(fire["normal"], 0.05)), "ash_fire", fire["fire_intensity"])
        end
    end
end

function ParticleSpawner_ShowStatus()
    if GeneralOptions_GetShowUiInGame() == "YES" then
        DebugWatch(Version_GetName() .. " - ParticleSpawner Rate", ParticleSpawner_ParticleRefreshRate)
        DebugWatch(Version_GetName() .. " - ParticleSpawner Period",  (1 / ParticleSpawner_ParticleRefreshRate))
        DebugWatch(Version_GetName() .. " - ParticleSpawner Timer", ParticleSpawner_SpawnTimer)
        DebugWatch(Version_GetName() .. " - ParticleSpawner, FPS", ParticleSpawner_CurFPS)
        DebugWatch(Version_GetName() .. " - ParticleSpawner, FPS Target", ParticleSpawner_CurFPSTarget)
    end
end