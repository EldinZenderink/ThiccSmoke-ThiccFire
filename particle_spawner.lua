-- firedetector.lua
-- @date 2021-09-13
-- @author Eldin Zenderink
-- @brief This module spawns particles and adjust dynamically based on FPS, it can however be adjusted
--        if you do desire a slideshow :P.


local ParticleSpawner_Default = {
    dynamic_fps = "ON",
    dynamic_fps_target = 40,
    particle_count_max = 300,
    particle_count_min = 50,
    particle_refresh_max = 10,
    particle_refresh_min = 2,
    aggressivenes = 0.05,
    particle_refresh_affect_count = 10
}

local ParticleSpawner_Properties = {
    dynamic_fps = "ON",
    dynamic_fps_target = 40,
    particle_count_max = 300,
    particle_count_min = 50,
    particle_refresh_max = 10,
    particle_refresh_min = 2,
    aggressivenes = 0.05,
    particle_refresh_affect_count = 10,
}

local ParticleSpawner_ParticlesToSpawn = nil
local ParticleSpawner_CurFPSTarget = nil
local ParticleSpawner_CurFPS = nil
local ParticleSpawner_FindNew = true
local ParticleSpawner_UpdateTimer = 0

local ParticleSpawner_TickRefreshCounter = 0
local ParticleSpawner_ParticleCount = 300.0
local ParticleSpawner_ParticleRefreshRate = 10.0
local ParticleSpawner_TimeElapsed = 0

local ParticleSpawner_Options =
{
	storage_module="particlespawner",
	storage_prefix_key=nil,
	default=function() ParticleSpawner_DefaultSettings() end,
	update=function() ParticleSpawner_UpdateSettingsFromStorage() end,
	option_items={
        {
            option_parent_text="",
            option_text="Dynamic FPS Adjust",
            option_note="Adjust based on fps. If disabled, only the max values will apply!",
            option_type="text",
            storage_key="dynamic_fps",
            options={"YES", "NO"}
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
            option_text="Particle Count",
            option_note="Maximum particles to spawned at once every particle refresh.",
            option_type="int",
            storage_key="particle_count_max",
            min_max={1, 1000}
        },
        {
            option_parent_text="",
            option_text="Min Particle Count",
            option_note="Mininum particles to spawned at once every particle refresh.",
            option_type="int",
            storage_key="particle_count_min",
            min_max={1, 1000}
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
        },
        {
            option_parent_text="",
            option_text="Affect Particle Count",
            option_note="Starts affecting particle count if particle refresh rate is below this value.",
            option_type="int",
            storage_key="particle_refresh_affect_count",
            min_max={1, 60}
        },
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
    ParticleSpawner_ParticleCount = ParticleSpawner_Properties["particle_count_max"]
    ParticleSpawner_ParticleRefreshRate = ParticleSpawner_Properties["particle_refresh_max"]
end

function ParticleSpawner_UpdateSettingsFromStorage()
	ParticleSpawner_Properties["dynamic_fps"] = Storage_GetString("particlespawner", "dynamic_fps")
    ParticleSpawner_Properties["dynamic_fps_target"] = Storage_GetInt("particlespawner", "dynamic_fps_target")
    ParticleSpawner_Properties["particle_count_max"] = Storage_GetInt("particlespawner", "particle_count_max")
    ParticleSpawner_Properties["particle_count_min"] = Storage_GetInt("particlespawner", "particle_count_min")
    ParticleSpawner_Properties["particle_refresh_max"] = Storage_GetInt("particlespawner", "particle_refresh_max")
    ParticleSpawner_Properties["particle_refresh_min"] = Storage_GetInt("particlespawner", "particle_refresh_min")
    ParticleSpawner_Properties["particle_refresh_affect_count"] = Storage_GetInt("particlespawner", "particle_refresh_affect_count")
    ParticleSpawner_Properties["aggressivenes"] = Storage_GetFloat("particlespawner", "aggressivenes")
    ParticleSpawner_ParticleRefreshRate =  ParticleSpawner_Properties["particle_refresh_max"]
    ParticleSpawner_ParticleCount = ParticleSpawner_Properties["particle_count_max"]
    ParticleSpawner_CurFPSTarget = ParticleSpawner_Properties["dynamic_fps_target"]
end

function ParticleSpawner_DefaultSettings()
    Storage_SetString("particlespawner", "dynamic_fps", ParticleSpawner_Default["dynamic_fps"])
    Storage_SetInt("particlespawner", "dynamic_fps_target", ParticleSpawner_Default["dynamic_fps_target"])
	Storage_SetInt("particlespawner", "particle_count_max", ParticleSpawner_Default["particle_count_max"])
	Storage_SetInt("particlespawner", "particle_count_min", ParticleSpawner_Default["particle_count_min"])
	Storage_SetInt("particlespawner", "particle_refresh_max", ParticleSpawner_Default["particle_refresh_max"])
	Storage_SetInt("particlespawner", "particle_refresh_min", ParticleSpawner_Default["particle_refresh_min"])
    Storage_SetInt("particlespawner", "particle_refresh_affect_count", ParticleSpawner_Default["particle_refresh_affect_count"])
    Storage_SetFloat("particlespawner", "aggressivenes", ParticleSpawner_Default["aggressivenes"])
    ParticleSpawner_UpdateSettingsFromStorage()
end

function ParticleSpawner_tick(dt)
    local Particle_RefershMax = ParticleSpawner_Properties["particle_refresh_max"]
    local Particle_RefreshMin = ParticleSpawner_Properties["particle_refresh_min"]
    local Particle_CountMax = ParticleSpawner_Properties["particle_count_max"]
    local Particle_CountMin = ParticleSpawner_Properties["particle_count_min"]
    local Particle_CountRefresh = ParticleSpawner_Properties["particle_refresh_affect_count"]
    local FPS_Target = ParticleSpawner_Properties["dynamic_fps_target"]
    local enabled = ParticleSpawner_Properties["dynamic_fps"]
    local aggressivenes = ParticleSpawner_Properties["aggressivenes"]

    ParticleSpawner_CurFPS = 1 / dt
    if ParticleSpawner_CurFPSTarget == nil then
        ParticleSpawner_CurFPSTarget = FPS_Target
    end


    if ParticleSpawner_TickRefreshCounter > ParticleSpawner_CurFPS / ParticleSpawner_ParticleRefreshRate or enabled == "OFF" then
        if enabled == "ON" then

            local below_target = false
            if ParticleSpawner_CurFPS < ParticleSpawner_CurFPSTarget then
                below_target = true
            end

            if below_target == true and ParticleSpawner_ParticleRefreshRate > Particle_RefreshMin then
                ParticleSpawner_ParticleRefreshRate = ParticleSpawner_ParticleRefreshRate - aggressivenes
            elseif below_target == false and ParticleSpawner_ParticleRefreshRate < Particle_RefershMax then
                ParticleSpawner_ParticleRefreshRate = ParticleSpawner_ParticleRefreshRate + aggressivenes
            end

            if ParticleSpawner_ParticleRefreshRate < Particle_CountRefresh then
                if ParticleSpawner_ParticleCount > Particle_CountMin then
                    ParticleSpawner_ParticleCount = ParticleSpawner_ParticleCount - aggressivenes * 100
                end
            else
                if ParticleSpawner_ParticleCount < Particle_CountMax then
                    ParticleSpawner_ParticleCount = ParticleSpawner_ParticleCount + aggressivenes * 100
                end
            end

            if Particle_CountRefresh == Particle_RefreshMin then
                if below_target and (ParticleSpawner_CurFPSTarget > 35 or ParticleSpawner_CurFPSTarget > FPS_Target) then
                    ParticleSpawner_CurFPSTarget =  ParticleSpawner_CurFPSTarget - 5
                elseif below_target == false and ParticleSpawner_CurFPSTarget < FPS_Target then
                    ParticleSpawner_CurFPSTarget =  ParticleSpawner_CurFPSTarget + 5
                end
            end
        end

        if ParticleSpawner_ParticlesToSpawn and ParticleSpawner_ParticlesToSpawn[1] then
            for body, info in pairs(ParticleSpawner_ParticlesToSpawn[1]) do
                -- DebugPrinter(ParticleSpawner_TimeElapsed .. " - Dynamic FPS ".. enabled .. " - BODY[" .. body .. "] MATERIAL[" .. tostring(info["material"]) .. "] TIME [" .. info["timestamp"] .. "]" .. " FIRE [" .. info["fire_on_body"] .. "]")
                Particle_EmitParticle(Material_GetInfo(info["material"]), info["location"], "smoke", info["fire_on_body"], ParticleSpawner_ParticlesToSpawn[3])
            end
            ParticleSpawner_FindNew = true
        end
        ParticleSpawner_TickRefreshCounter = 0
    end
    ParticleSpawner_TimeElapsed = ParticleSpawner_TimeElapsed + dt
    ParticleSpawner_TickRefreshCounter = ParticleSpawner_TickRefreshCounter + 1
end

function ParticleSpawner_update(dt)
    if ParticleSpawner_FindNew then
        ParticleSpawner_ParticlesToSpawn = FireDetector_FindFireLocations(ParticleSpawner_UpdateTimer, ParticleSpawner_ParticleCount)
        ParticleSpawner_UpdateTimer = 0
    end
    ParticleSpawner_FindNew = false
    ParticleSpawner_UpdateTimer = ParticleSpawner_UpdateTimer + dt
end

function ParticleSpawner_ShowStatus()
    if GeneralOptions_GetShowUiInGame() == "YES" then
        DebugWatch("ParticleSpawner, FPS:", ParticleSpawner_CurFPS)
        DebugWatch("ParticleSpawner, FPS Target:", ParticleSpawner_CurFPSTarget)
        DebugWatch("ParticleSpawner, Find Fire:", ParticleSpawner_FindNew)
        DebugWatch("ParticleSpawner, Particle Refresh Rate:", ParticleSpawner_ParticleRefreshRate)
        DebugWatch("ParticleSpawner, Max Particle Count:", ParticleSpawner_ParticleCount)
    end
end