-- particle.lua
-- @date 2021-09-06
-- @author Eldin Zenderink
-- @brief Helper module for generating particles

-- Module config

-- Default Options and Settings
-- Store everything needed to generate menu.
local Particle_Options =
{
	storage_module="particle",
	storage_prefix_key=nil,
	buttons={
		{
			text="Set default",
			callback=function() Particle_DefaultSettings() end,
		}
	},
	update=function() Particle_UpdateSettingsFromStorage() end,
	option_items={
		{
			option_parent_text="",
			option_text="Intensity",
			option_note="Applies offset to radius on all materials.",
			option_type="text",
			storage_key="intensity",
			options={
				"Use Material Property",
				"Potato PC",
				"Somewhat Ok",
				"Realistic",
				"This is fine (meme)",
				"Fry my PC"
			}
		},
		{
			option_parent_text="",
			option_text="Drag",
			option_note="Applies offset to drag on all materials.",
			option_type="text",
			storage_key="drag",
			options={
				"Use Material Property",
				"Low",
				"Medium",
				"High"
			}
		},
		{
			option_parent_text="",
			option_text="Gravity",
			option_note="Applies offset to gravity on all materials.",
			option_type="text",
			storage_key="gravity",
			options={
				"Use Material Property",
				"Upwards Low",
				"Upwards High",
				"Downwards Low",
				"Downwards High"
			}
		},
		{
			option_parent_text="",
			option_text="Lifetime",
			option_note="Multiples configured lifetime per material.",
			option_type="text",
			storage_key="lifetime",
			options={
				"1x",
				"2x",
				"4x",
				"8x",
				"16x"
			}
		},
		{
			option_parent_text="",
			option_text="Smoke Fade In (%)",
			option_note="Percentage of time it takes to fade in smoke",
			option_type="int",
			storage_key="smoke_fadein",
			min_max={0, 100}
		},
		{
			option_parent_text="",
			option_text="Smoke Fade Out (%)",
			option_note="Percentage of time it takes to fade in smoke",
			option_type="int",
			storage_key="smoke_fadeout",
			min_max={0, 100}
		},
		{
			option_parent_text="",
			option_text="Fire Fade In (%)",
			option_note="Percentage of time it takes to fade in fire",
			option_type="int",
			storage_key="fire_fadein",
			min_max={0, 100}
		},
		{
			option_parent_text="",
			option_text="Fire Fade Out (%)",
			option_note="Percentage of time it takes to fade in fire",
			option_type="int",
			storage_key="fire_fadeout",
			min_max={0, 100}
		},
		{
			option_parent_text="",
			option_text="Fire Emissiveness",
			option_note="Sets how emissive the fire starts out",
			option_type="int",
			storage_key="fire_emissive",
			min_max={1, 10}
		},
        {
            option_parent_text="",
            option_text="Intensity modifier",
            option_note="Configure how the fire intensity (see fire detection settings) affects particles (size and gravity).",
            option_type="float",
            storage_key="intensity_scale",
            min_max={1, 10.0, 0.05}
        },
	}
}


-- Default particle relevant settings
local Particle_Default_Intensity = "Use Material Property"
local Particle_Default_Drag = "Use Material Property"
local Particle_Default_Gravity = "Use Material Property"
local Particle_Default_Lifetime = "1x"
local Particle_Default_FireIntensityScale = 1
local Particle_Default_SmokeFadeIn = 0
local Particle_Default_SmokeFadeOut = 10
local Particle_Default_FireFadeIn = 35
local Particle_Default_FireFadeOut = 20
local Particle_Default_FireEmissive = 4

-- Global particle relevant settings
local Particle_Intensity = ""
local Particle_Drag = ""
local Particle_Gravity = ""
local Particle_Lifetime = ""
local Particle_FireIntensityScale = 4
local Particle_SmokeFadeIn = 5
local Particle_SmokeFadeOut = 5
local Particle_FireFadeIn = 5
local Particle_FireFadeOut = 5
local Particle_FireEmissive = 4

local Particle_Type = {8, 3, 5, 8, 13, 14}
-- Init function
-- @param default = when set to true set the default values and store them.
function Particle_Init(default)
	if default then
		Particle_DefaultSettings()
	else
		Particle_UpdateSettingsFromStorage()
	end
end

-- Make it easier to generate menus
function Particle_GetOptionsMenu()
	return {
		menu_title = "Particle Settings",
		sub_menus={
			{
				sub_menu_title="Particle Options",
				options=Particle_Options,
			}
		}
	}
end

function Particle_UpdateSettingsFromStorage()
	Particle_UpdateSettings(
		Storage_GetString("particle", "intensity"),
		Storage_GetString("particle", "drag"),
		Storage_GetString("particle", "gravity"),
		Storage_GetString("particle", "lifetime"),
		Storage_GetFloat("particle", "intensity_scale"),
		Storage_GetInt("particle", "smoke_fadein"),
		Storage_GetInt("particle", "smoke_fadeout"),
		Storage_GetInt("particle", "fire_fadein"),
		Storage_GetInt("particle", "fire_fadeout"),
		Storage_GetInt("particle", "fire_emissive")
	)
end

function Particle_UpdateSettings(intensity, drag, gravity, lifetime, intensity_scale, smokefadein, smokefadeout, firefadein, firefadeout, fireemissive)
	Particle_Intensity = intensity
	Particle_Drag = drag
	Particle_Gravity = gravity
	Particle_Lifetime = lifetime
	Particle_FireIntensityScale = intensity_scale
	Particle_SmokeFadeIn = smokefadein
	Particle_SmokeFadeOut = smokefadeout
	Particle_FireFadeIn = firefadein
	Particle_FireFadeOut = firefadeout
	Particle_FireEmissive = fireemissive
	Particle_StoreSettings()
end

function Particle_DefaultSettings()
	Particle_Intensity = Particle_Default_Intensity
	Particle_Drag = Particle_Default_Drag
	Particle_Gravity = Particle_Default_Gravity
	Particle_Lifetime = Particle_Default_Lifetime
	Particle_FireIntensityScale = Particle_Default_FireIntensityScale
	Particle_SmokeFadeIn = Particle_Default_SmokeFadeIn
	Particle_SmokeFadeOut = Particle_Default_SmokeFadeOut
	Particle_FireFadeIn = Particle_Default_FireFadeIn
	Particle_FireFadeOut = Particle_Default_FireFadeOut
	Particle_FireEmissive = Particle_Default_FireEmissive
	Particle_StoreSettings()
end

function Particle_StoreSettings()
	Storage_SetString("particle", "intensity", Particle_Intensity)
	Storage_SetString("particle", "drag", Particle_Drag)
	Storage_SetString("particle", "gravity", Particle_Gravity)
	Storage_SetString("particle", "lifetime", Particle_Lifetime)
	Storage_SetFloat("particle", "intensity_scale", Particle_FireIntensityScale)
	Storage_SetInt("particle", "smoke_fadein", Particle_SmokeFadeIn)
	Storage_SetInt("particle", "smoke_fadeout", Particle_SmokeFadeOut)
	Storage_SetInt("particle", "fire_fadein", Particle_FireFadeIn)
	Storage_SetInt("particle", "fire_fadeout", Particle_FireFadeOut)
	Storage_SetInt("particle", "fire_emissive", Particle_FireEmissive)
end


function Particle_EmitParticle(emitter, location, particle, fire_intensity)
	if emitter == nil or fire_intensity == nil or location == nil then
		-- DebugPrinter("Not spawning particle: emitter:" .. tostring(emitter) .. ", location: " .. tostring(location) .. ", intensity: " .. tostring(fire_intensity))
		return nil
	end
	local average_intensity = fire_intensity
	local type = particle
	local radius = emitter["size"]
	local life = emitter["lifetime"]
	local vel = emitter["speed"]
	local drag = emitter["drag"]
	local gravity = emitter["gravity"]
	-- Fire color
	local red = 1.0
	local green = 0.6
	local blue = 0.5
	-- Smoke may have different color
	if type == "smoke" then
		red = emitter["color"]["r"]
		green = emitter["color"]["g"]
		blue = emitter["color"]["b"]
	end
	local alpha = emitter["color"]["a"]
	local variation = emitter["variation"]
	alpha = alpha +  Generic_rnd(variation / 2 * - 1, variation * 2)
	gravity = gravity + Generic_rnd(gravity / 2 , gravity * 2)
	if alpha > 1 then
		alpha = 1
	end

	if alpha < 0 then
		alpha = 0
	end

	if red < 0 then
		red = 0
	end
	if green < 0 then
		green = 0
	end
	if blue < 0 then
		blue = 0
	end


	-- DebugWatch("average_intensity", average_intensity)
	radius = ((radius / (100 / Particle_FireIntensityScale)) * average_intensity)
	gravity = ((gravity / (75 / Particle_FireIntensityScale)) * average_intensity)

	if Particle_Drag == "Low" then
		drag = drag - 0.2
		if drag > 0.3 then
			drag = 0.3
		end
		if drag < 0 then
			drag  = 0.1
		end
	elseif Particle_Drag == "Medium" then
		drag = drag - 0.1
		if drag > 0.5 then
			drag = 0.5
		end
		if drag < 0 then
			drag  = 0.1
		end
	elseif Particle_Drag == "High" then
		drag = drag + 0.2
		if drag > 1 then
			drag = 1
		end
		if drag < 0 then
			drag  = 0.1
		end
	end


	if Particle_Lifetime == "2x" then
		life = life * 2
	elseif Particle_Lifetime == "4x" then
		life = life * 4
	elseif Particle_Lifetime == "8x" then
		life = life * 8
	elseif Particle_Lifetime == "16x" then
		life = life * 16
	end

	if Particle_Gravity == "Downwards Low" then
		gravity = gravity * -1 - 3
		if gravity > -1 then
			gravity = -1
		end
	elseif Particle_Gravity == "Downwards High" then
		gravity = gravity * -1 - 6
		if gravity > -1 then
			gravity = -1
		end
	elseif Particle_Gravity == "Upwards High" then
		gravity = gravity * 2
		if gravity < 1 then
			gravity = 1
		end
	end

	if Particle_Intensity == "Potato PC" then
		radius = radius / 4
	elseif Particle_Intensity == "Somewhat Ok" then
		radius = radius / 2
	elseif Particle_Intensity == "Realistic" then
		radius = radius * 2
	elseif Particle_Intensity == "This is fine (meme)" then
		radius = radius * 4
	elseif Particle_Intensity == "Fry my PC" then
		radius = radius * 8
	end


	--Set up the particle state
	ParticleReset()
	ParticleType("smoke")
	if type == "fire" then
		-- 3 - 5 - 13 -  14
		-- 8 = fire emblems
		life = ((life / (100 / Particle_FireIntensityScale)) * average_intensity)

		if life < 0.5 then
			life = 0.5
		end

		local rand = Generic_rndInt(1, 6)
		local particle_type = Particle_Type[rand]
		ParticleTile(particle_type)
		ParticleColor(red, green, blue, 1, 0.4, 0)
		ParticleStretch(0, 3)
		ParticleAlpha(alpha , alpha, "easein", life / 10 , 0.5)	-- Ramp up fast, ramp down after 50%

		if particle_type == 5 then

			local emissive = Generic_rnd(Particle_FireEmissive / 2, Particle_FireEmissive)
			ParticleEmissive(emissive - radius, 0, "smooth", 0, (Particle_SmokeFadeIn / 100) * Generic_rnd(variation , variation * 3))
			ParticleRadius(radius, radius, "easein", life *(Particle_SmokeFadeIn / 100), life * (Particle_SmokeFadeOut / 100))
			-- life = radius * life * 2
		elseif particle_type == 8 then
			life = life * 8
			gravity = gravity +  Generic_rnd(1, 3)
			vel = vel + Generic_rnd(2 , 4)
			ParticleStretch(10)
			local emissive = Generic_rnd(Particle_FireEmissive / 2, Particle_FireEmissive)
			ParticleEmissive(emissive - radius, 0, "smooth", 0, (Particle_SmokeFadeIn / 100) * Generic_rnd(variation , variation * 3))
			ParticleRadius(radius, radius, "easein", life * (Particle_SmokeFadeIn / 100), life * (Particle_SmokeFadeOut / 100))
		else
			-- life = radius * life * 2
			local emissive = Generic_rnd(Particle_FireEmissive / 2, Particle_FireEmissive)
			ParticleEmissive(emissive - radius, 0, "smooth", 0, (Particle_SmokeFadeIn / 100) * Generic_rnd(variation , variation * 3))
			ParticleRadius(radius, radius, "easein", life * (Particle_SmokeFadeIn / 100), life * (Particle_SmokeFadeOut / 100))
		end
	else
		ParticleAlpha(alpha, alpha, "easein", life * (Particle_SmokeFadeIn / 100), life * (Particle_SmokeFadeOut / 100))	-- Ramp up fast, ramp down after 50%
		ParticleRadius(radius, radius, "easein",life * (Particle_SmokeFadeIn / 100), life * (Particle_SmokeFadeOut / 100))
		ParticleColor(red, green, blue, 0.9, 0.9, 0.9)
	end		-- Animating color towards fire color from near white
	--Randomize lifetime

	ParticleGravity(gravity)		-- Slightly randomized gravity looks better
	ParticleDrag(drag)
	ParticleCollide(1, 1, "constant", 0.01)

	ParticleRotation(Generic_rnd(vel * -1, vel), 1, "smooth", 0.5/life)
	--Emit particles

	local v = {Generic_rnd(vel * - 1, vel * 1),Generic_rnd(vel * - 1, vel * 1),Generic_rnd(vel * - 1, vel * 1)}

	--Spawn particle into the world
	SpawnParticle(location, v, life)
	-- end
end
