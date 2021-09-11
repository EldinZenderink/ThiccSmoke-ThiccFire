-- particle.lua
-- @date 2021-09-06
-- @author Eldin Zenderink
-- @brief Helper module for generating particles

-- Module config

-- Global storage
local _EnabledParticleEmitters = nil
local _DisabledParticleEmitters = nil

-- Default Options and Settings
-- Store everything needed to generate menu.
local Particle_Options =
{
	storage_module="particle",
	storage_prefix_key=nil,
	default=function() Particle_DefaultSettings() end,
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
		}
	}
}

-- Global particle relevant settings
local Particle_Intensity = ""
local Particle_Drag = ""
local Particle_Gravity = ""
local Particle_Lifetime = ""

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
		Storage_GetString("particle", "amount"),
		Storage_GetString("particle", "lifetime")
	)
end

function Particle_UpdateSettings(intensity, drag, gravity, lifetime)
	Particle_Intensity = intensity
	Particle_Drag = drag
	Particle_Gravity = gravity
	Particle_Lifetime = lifetime
end

function Particle_DefaultSettings()
	Particle_Intensity = Particle_Options["option_items"][1]["options"][1]
	Particle_Drag = Particle_Options["option_items"][2]["options"][1]
	Particle_Gravity = Particle_Options["option_items"][3]["options"][1]
	Particle_Lifetime = Particle_Options["option_items"][4]["options"][1]
	Particle_StoreSettings()
end

function Particle_StoreSettings()
	Storage_SetString("particle", "intensity", Particle_Intensity)
	Storage_SetString("particle", "drag", Particle_Drag)
	Storage_SetString("particle", "gravity", Particle_Gravity)
	Storage_SetString("particle", "lifetime", Particle_Lifetime)
end

-- Clear list of possible left over shapes
function Particle_ClearDisabledEmitters()
	local count = _EnabledParticleEmitters:length()
	DebugPrinter("Clear amount of disabled left overs: " .. count)
	for i=1, count do
		_DisabledParticleEmitters:remove_right(i)
	end
end

function Particle_EmitParticle(emitter, location, particle)
	if emitter == nil then
		return
	end
	local type = particle
	local radius = emitter["size"]
	local life = emitter["lifetime"]
	local vel = emitter["speed"]
	local drag = emitter["drag"]
	local gravity = emitter["gravity"]
	local random_alpha = math.random(-1 * emitter["variation"], emitter["variation"])
	local red = emitter["color"]["r"]
	local green = emitter["color"]["g"]
	local blue = emitter["color"]["b"]
	local alpha = emitter["color"]["a"] + random_alpha
	local radius_start= 0.1

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

	if Particle_Intensity == "Potato PC" then
		radius = radius - 0.1
		radius_start  = 0.1
		if radius > 0.2 then
			radius = 0.2
		end
	elseif Particle_Intensity == "Somewhat Ok" then
		radius = radius
		radius_start  = 0.15
		if radius > 0.3 then
			radius = 0.3
		end
	elseif Particle_Intensity == "Realistic" then
		radius = radius + 0.5
		radius_start  = 0.2
		if radius > 0.5 then
			radius = 0.5
		end
	elseif Particle_Intensity == "This is fine (meme)" then
		radius = radius + 1
		radius_start  = 0.5
		if radius > 5 then
			radius = 5
		end
	elseif Particle_Intensity == "Fry my PC" then
		radius = radius + 2
		radius_start  = 1
		if radius > 5 then
			radius = 5
		end
	end

	if radius < radius_start then
		radius = radius_start
	end

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
	elseif Particle_Gravity == "Upwards Low" then
		gravity = gravity * 1 + 3
		if gravity < 1 then
			gravity = 1
		end
	elseif Particle_Gravity == "Upwards High" then
		gravity = gravity * 1 + 6
		if gravity < 1 then
			gravity = 1
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

	--Set up the particle state
	ParticleReset()
	ParticleType(type)
	ParticleRadius(radius_start, radius, "linear", 0.001)
	ParticleAlpha(alpha, alpha, "constant", 0.1/life, 0.5)	-- Ramp up fast, ramp down after 50%
	ParticleGravity(gravity * Generic_rnd(0.3, 2.5))				-- Slightly randomized gravity looks better
	ParticleDrag(drag)
	ParticleColor(red, green, blue, 0.9, 0.9, 0.9)			-- Animating color towards white
	ParticleRotation(3, 1,"smooth", 1)
	ParticleCollide(1, 1, "constant", 0.05)

	--Emit particles
	-- for i=1, count do
	--Randomize velocity slightly
	-- local v = VecAdd(body_dir, rndVec(vel / 100))
	-- local v = Vec(VecAdd(body_dir, rndVec(0.002)), vel)
	local v = {Generic_rnd(-1, vel), Generic_rnd(0,vel), Generic_rnd(-1, vel)}

	--Include some of the movement of the attachment body
	-- v = VecAdd(v,  vel / 10000)

	--Randomize lifetime
	local l = Generic_rnd(life*0.5, life*1.5)

	--Spawn particle into the world
	-- body_pos[1] = body_pos[1] * -1
	local loc =
	SpawnParticle(location, v, l)
	-- end
end

