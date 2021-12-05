-- particle.lua
-- @date 2021-09-06
-- @author Eldin Zenderink
-- @brief Helper module for generating particles

-- Global particle relevant settings
Particle_Intensity = ""
Particle_Drag = ""
Particle_Gravity = ""
Particle_Lifetime = ""
Particle_FireIntensityScale = 4
Particle_SmokeFadeIn = 5
Particle_SmokeFadeOut = 5
Particle_FireFadeIn = 5
Particle_FireFadeOut = 5
Particle_FireEmissive = 4
Particle_Embers = "LOW"

Particle_Type = {3, 5, 5, 13, 14, 8}

function Particle_Init()
    Settings_RegisterUpdateSettingsCallback(Particle_UpdateSettingsFromSettings)
end

-- Make it easier to generate menus
function Particle_UpdateSettingsFromSettings()
	Particle_Intensity = Settings_GetValue("Particle", "intensity_mp")
	Particle_Drag = Settings_GetValue("Particle", "drag_mp")
	Particle_Gravity = Settings_GetValue("Particle", "gravity_mp")
	Particle_Lifetime = Settings_GetValue("Particle", "lifetime_mp")
	Particle_FireIntensityScale = Settings_GetValue("Particle", "intensity_scale")
	Particle_SmokeFadeIn = Settings_GetValue("Particle", "smoke_fadein")
	Particle_SmokeFadeOut = Settings_GetValue("Particle", "smoke_fadeout")
	Particle_FireFadeIn = Settings_GetValue("Particle", "fire_fadein")
	Particle_FireFadeOut = Settings_GetValue("Particle", "fire_fadeout")
	Particle_FireEmissive = Settings_GetValue("Particle", "fire_emissive")
	Particle_Embers = Settings_GetValue("Particle", "embers")
	if Particle_Embers == "LOW" then
		Particle_Type = {3, 5, 5, 13, 14, 8}
	elseif Particle_Embers == "HIGH" then
		Particle_Type = {3, 5, 8, 13, 14, 8}
	else
		Particle_Type = {3, 5, 5, 13, 14, 5}
	end
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
	local red = emitter["color"]["r"]
	local green = emitter["color"]["g"]
	local blue = emitter["color"]["b"]
	local alpha = emitter["color"]["a"]
	local variation = emitter["variation"]
	alpha = alpha +  Generic_rnd(variation / 2 * - 1, variation * 2)
	-- gravity = gravity + Generic_rnd(gravity / 2 , gravity * 2)
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
		-- 8 = fire embers
		local original_life = life * 2
		life = ((life / (100 / Particle_FireIntensityScale)) * average_intensity)
		if life > original_life then
			life = original_life
		end

		if life < 0.5 then
			life = 0.5
		end

		local rand = Generic_rndInt(1, 6)
		particle_type = Particle_Type[rand]
		ParticleTile(particle_type)
		ParticleColor(red, green, blue, 1, 0.4, 0)
		ParticleStretch(0, 3)
		ParticleAlpha(alpha , alpha, "easein", life / 10 , 0.5)	-- Ramp up fast, ramp down after 50%

		if particle_type == 5 then

			local emissive = Generic_rnd(Particle_FireEmissive / 2, Particle_FireEmissive)
			ParticleEmissive(emissive - radius, 0, "smooth", 0, (Particle_FireFadeIn / 100) * Generic_rnd(variation , variation * 3))
			ParticleRadius(radius, radius, "easein", life *(Particle_FireFadeIn / 100), life * (Particle_FireFadeOut / 100))
			-- life = radius * life * 2
		elseif particle_type == 8 then
			life = life * 8
			gravity = gravity +  Generic_rnd(1, 3)
			vel = vel + Generic_rnd(2 , 4)
			ParticleStretch(10)
			local emissive = Generic_rnd(Particle_FireEmissive / 2, Particle_FireEmissive)
			ParticleEmissive(emissive - radius, 0, "smooth")
			ParticleRadius(radius, radius, "easein")
		else
			-- life = radius * life * 2
			local emissive = Generic_rnd(Particle_FireEmissive / 2, Particle_FireEmissive)
			ParticleEmissive(emissive - radius, 0, "smooth", 0, (Particle_FireFadeIn / 100) * Generic_rnd(variation , variation * 3))
			ParticleRadius(radius, radius, "easein", life * (Particle_FireFadeIn / 100), life * (Particle_FireFadeOut / 100))
		end
	else
		ParticleAlpha(alpha, alpha, "easein", life * (Particle_SmokeFadeIn / 1000), life * (Particle_SmokeFadeOut / 1000))	-- Ramp up fast, ramp down after 50%
		ParticleRadius(radius, radius, "easein",life * (Particle_SmokeFadeIn / 1000), life * (Particle_SmokeFadeOut / 1000))
		ParticleColor(red, green, blue, 0.4, 0.4, 0.4)
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
