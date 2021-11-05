-- firedetector.lua
-- @date 2021-09-13
-- @author Eldin Zenderink
-- @brief This module spawns particles and adjust dynamically based on FPS, it can however be adjusted
--        if you do desire a slideshow :P.


local ParticleSpawner_Default = {
    fire = "YES",
    smoke = "YES",
    toggle_smoke_fire = "1:1",
    dynamic_fps = "ON",
    spawn_light = "ON",
    dynamic_fps_target = 48,
    particle_refresh_max = 60,
    particle_refresh_min = 24,
    aggressivenes = 1,
}

local ParticleSpawner_Properties = {
    fire = "YES",
    smoke = "YES",
    toggle_smoke_fire = "1:1",
    dynamic_fps = "ON",
    spawn_light = "ON",
    dynamic_fps_target = 48,
    particle_refresh_max = 60,
    particle_refresh_min = 24,
    aggressivenes = 1,
}

local ParticleSpawner_ParticlesToSpawn = nil
local ParticleSpawner_CurFPSTarget = nil
local ParticleSpawner_CurFPS = nil
local ParticleSpawner_FindNew = true
local ParticleSpawner_FireToSmokeSpawner = 0
local ParticleSpawner_RefreshTimer = 0
local ParticleSpawner_ParticleRefreshRate = 5.0
local ParticleSpawner_SpawnLight = false
local ParticleSpawner_TimeElapsed = 0

local ParticleSpawner_Options =
{
	storage_module="particlespawner",
	storage_prefix_key=nil,
    buttons={
		{
			text = "Set Default",
			callback=function() ParticleSpawner_DefaultSettings() end,
		},
    },
	update=function() ParticleSpawner_UpdateSettingsFromStorage() end,
	option_items={
        {
            option_parent_text="",
            option_text="Spawn Smoke Particles",
            option_note="Enable this to spawn smoke particles",
            option_type="text",
            storage_key="smoke",
            options={"YES", "NO"}
        },
        {
            option_parent_text="",
            option_text="Spawn Fire Particles",
            option_note="Enable this to spawn fire particles",
            option_type="text",
            storage_key="fire",
            options={"YES", "NO"}
        },
        {
            option_parent_text="",
            option_text="Spawn Light",
            option_note="Also spawn lights to simulate fire emitting more intense light.",
            option_type="text",
            storage_key="spawn_light",
            options={"ON", "OFF"}
        },
        {
            option_parent_text="",
            option_text="Fire to Smoke ratio",
            option_note="How many fire particles per spawning of smoke particles should spawn. (e.g. 1 smoke every 8 fire particles)",
            option_type="text",
            storage_key="toggle_smoke_fire",
            options={"1:1", "1:2", "1:4", "1:8"}
        },
        {
            option_parent_text="",
            option_text="Dynamic FPS Adjust",
            option_note="Adjust based on fps. If disabled, only the max values will apply!",
            option_type="text",
            storage_key="dynamic_fps",
            options={"ON", "OFF"}
        },
        {
            option_parent_text="",
            option_text="FPS Target",
            option_note="Note: only taken into account when your FPS is above this value!",
            option_type="int",
            storage_key="dynamic_fps_target",
            min_max={35, 60}
        },
        {
            option_parent_text="",
            option_text="Particle Refresh Rate",
            option_note="Maximum particle spawn refresh rate per second (note will automatically adjust if fps is below target (more = thicker smoke).",
            option_type="int",
            storage_key="particle_refresh_max",
            min_max={1, 60}
        },
        {
            option_parent_text="",
            option_text="Min Particle Refresh Rate",
            option_note="Minimum particle spawn refresh rate per second.",
            option_type="int",
            storage_key="particle_refresh_min",
            min_max={1, 60}
        },
        {
            option_parent_text="",
            option_text="Adjust Aggressivenes",
            option_note="How quick parameters should be adjusted after dipping below target.",
            option_type="float",
            storage_key="aggressivenes",
            min_max={0.01, 1.0, 0.01}
        }
	}
}

function ParticleSpawner_GetOptionsMenu()
	return {
		menu_title = "Particle Spawner Settings",
		sub_menus={
			{
				sub_menu_title="Particle Spawner Options",
				options=ParticleSpawner_Options,
			}
		}
	}
end

function ParticleSpawner_Init(default)
    if default then
        ParticleSpawner_DefaultSettings()
    else
        ParticleSpawner_UpdateSettingsFromStorage()
    end
    ParticleSpawner_ParticleRefreshRate = ParticleSpawner_Properties["particle_refresh_max"]
    if ParticleSpawner_Properties["spawn_light"] == "ON" then
        ParticleSpawner_SpawnLight = true
    else
        ParticleSpawner_SpawnLight = false
    end
    ParticleSpawner_FindNew = true
end

function ParticleSpawner_UpdateSettingsFromStorage()
    ParticleSpawner_Properties["fire"] = Storage_GetString("particlespawner", "fire")
	ParticleSpawner_Properties["smoke"] = Storage_GetString("particlespawner", "smoke")
	ParticleSpawner_Properties["toggle_smoke_fire"] = Storage_GetString("particlespawner", "toggle_smoke_fire")
	ParticleSpawner_Properties["dynamic_fps"] = Storage_GetString("particlespawner", "dynamic_fps")
    ParticleSpawner_Properties["dynamic_fps_target"] = Storage_GetInt("particlespawner", "dynamic_fps_target")
    ParticleSpawner_Properties["particle_refresh_max"] = Storage_GetInt("particlespawner", "particle_refresh_max")
    ParticleSpawner_Properties["particle_refresh_min"] = Storage_GetInt("particlespawner", "particle_refresh_min")
    ParticleSpawner_Properties["aggressivenes"] = Storage_GetFloat("particlespawner", "aggressivenes")
    ParticleSpawner_Properties["spawn_light"] = Storage_GetString("particlespawner", "spawn_light")
    ParticleSpawner_ParticleRefreshRate =  ParticleSpawner_Properties["particle_refresh_max"]
    ParticleSpawner_CurFPSTarget = ParticleSpawner_Properties["dynamic_fps_target"]
    if ParticleSpawner_Properties["spawn_light"] == "ON" then
        ParticleSpawner_SpawnLight = true
    else
        ParticleSpawner_SpawnLight = false
    end
end

function ParticleSpawner_DefaultSettings()
    Storage_SetString("particlespawner", "fire", ParticleSpawner_Default["fire"])
    Storage_SetString("particlespawner", "smoke", ParticleSpawner_Default["smoke"])
    Storage_SetString("particlespawner", "toggle_smoke_fire", ParticleSpawner_Default["toggle_smoke_fire"])
    Storage_SetString("particlespawner", "dynamic_fps", ParticleSpawner_Default["dynamic_fps"])
    Storage_SetInt("particlespawner", "dynamic_fps_target", ParticleSpawner_Default["dynamic_fps_target"])
	Storage_SetInt("particlespawner", "particle_refresh_max", ParticleSpawner_Default["particle_refresh_max"])
	Storage_SetInt("particlespawner", "particle_refresh_min", ParticleSpawner_Default["particle_refresh_min"])
    Storage_SetFloat("particlespawner", "aggressivenes", ParticleSpawner_Default["aggressivenes"])
    Storage_SetString("particlespawner", "spawn_light", ParticleSpawner_Default["spawn_light"])
    ParticleSpawner_UpdateSettingsFromStorage()
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

    if ParticleSpawner_SpawnLight and ParticleSpawner_ParticlesToSpawn then
        for i=1, #ParticleSpawner_ParticlesToSpawn do
            local fire_info = ParticleSpawner_ParticlesToSpawn[i]
            if fire_info ~= nil then
                local tenth = fire_info["fire_intensity"]  / 10
                PointLight(VecAdd(fire_info["location"], Generic_rndVec(0.1)), 0.8, 0.1, 0.01, fire_info["fire_intensity"] + Generic_rnd(-tenth, tenth))
            end
        end
    end
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

            for i=1, #ParticleSpawner_ParticlesToSpawn do
                local info = ParticleSpawner_ParticlesToSpawn[i]

                if info ~= nil then
                    if smoke == "YES" and spawn_smoke then
                        Particle_EmitParticle(SmokeMaterial_GetInfo(info["material"]), info["location"], "smoke", info["fire_intensity"])
                    end
                    if fire == "YES" and spawn_fire then
                        Particle_EmitParticle(FireMaterial_GetInfo(info["material"]), info["location"], "fire", info["fire_intensity"])
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
    else
        ParticleSpawner_ParticlesToSpawn = FireDetector_FindFireLocationsV2(dt, false)
    end

    -- ParticleSpawner_UpdateTimer = ParticleSpawner_UpdateTimer + dt
    ParticleSpawner_RefreshTimer = ParticleSpawner_RefreshTimer + dt

    -- FireDetector_FindFireLocationsV2(dt, true)

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