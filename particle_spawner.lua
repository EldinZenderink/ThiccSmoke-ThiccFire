-- firedetector.lua
-- @date 2021-09-13
-- @author Eldin Zenderink
-- @brief This module spawns particles and adjust dynamically based on FPS, it can however be adjusted
--        if you do desire a slideshow :P.


local ParticleSpawner_Default = {
    fire = "YES",
    smoke = "YES",
    toggle_smoke_fire = "YES",
    dynamic_fps = "ON",
    dynamic_fps_target = 48,
    particle_refresh_max = 60,
    particle_refresh_min = 24,
    aggressivenes = 1,
}

local ParticleSpawner_Properties = {
    fire = "YES",
    smoke = "YES",
    toggle_smoke_fire = "YES",
    dynamic_fps = "ON",
    dynamic_fps_target = 48,
    particle_refresh_max = 60,
    particle_refresh_min = 24,
    aggressivenes = 1,
}

local ParticleSpawner_ParticlesToSpawn = nil
local ParticleSpawner_CurFPSTarget = nil
local ParticleSpawner_CurFPS = nil
local ParticleSpawner_FindNew = true
local ParticleSpawner_UpdateTimer = 0
local ParticleSpawner_RefreshTimer = 0
local ParticleSpawner_ParticleRefreshRate = 5.0
local ParticleSpawner_TimeElapsed = 0
local ParticleSpawner_toggleType = true

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
            option_text="Alternate Fire & Smoke",
            option_note="Yes = alternate between spawning smoke/fire (fast), No = Spawn both at the same time (slow)",
            option_type="text",
            storage_key="toggle_smoke_fire",
            options={"YES", "NO"}
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
    ParticleSpawner_ParticleRefreshRate =  ParticleSpawner_Properties["particle_refresh_max"]
    ParticleSpawner_CurFPSTarget = ParticleSpawner_Properties["dynamic_fps_target"]
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
end

function ParticleSpawner_update(dt)
    local fire = ParticleSpawner_Properties["fire"]
    local smoke = ParticleSpawner_Properties["smoke"]
    local toggle = ParticleSpawner_Properties["toggle_smoke_fire"]

    if ParticleSpawner_ParticlesToSpawn then
        if ParticleSpawner_RefreshTimer > (1 / ParticleSpawner_ParticleRefreshRate) then
            for i=1, #ParticleSpawner_ParticlesToSpawn do
                local info = ParticleSpawner_ParticlesToSpawn[i]
                if toggle == "YES" then
                    if ParticleSpawner_toggleType and smoke == "YES" then
                        Particle_EmitParticle(SmokeMaterial_GetInfo(info["material"]), info["location"], "smoke", info["fire_intensity"])
                        if fire == "YES" then
                            ParticleSpawner_toggleType = false
                        end
                    elseif fire == "YES" and ParticleSpawner_toggleType == false then
                        Particle_EmitParticle(FireMaterial_GetInfo(info["material"]), info["location"], "fire", info["fire_intensity"])
                        ParticleSpawner_toggleType = true
                    end
                else
                    if smoke == "YES" then
                        Particle_EmitParticle(SmokeMaterial_GetInfo(info["material"]), info["location"], "smoke", info["fire_intensity"])
                    end
                    if fire == "YES" then
                        Particle_EmitParticle(FireMaterial_GetInfo(info["material"]), info["location"], "fire", info["fire_intensity"])
                    end
                end
            end
            ParticleSpawner_RefreshTimer = 0
            -- ParticleSpawner_FindNew = true
        end
    end

    ParticleSpawner_ParticlesToSpawn = FireDetector_FindFireLocationsV2(ParticleSpawner_UpdateTimer, ParticleSpawner_FindNew)
    ParticleSpawner_FindNew = false

    if ParticleSpawner_UpdateTimer > 0.25 then
        ParticleSpawner_UpdateTimer = 0
        ParticleSpawner_FindNew = true
    end
    ParticleSpawner_UpdateTimer = ParticleSpawner_UpdateTimer + dt
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