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
Particle_Duplicator = 4
Particle_SmokeFadeIn = 5
Particle_SmokeFadeOut = 5
Particle_FireFadeIn = 5
Particle_FireFadeOut = 5
Particle_FireEmissive = 4
Particle_Embers = "LOW"
Particle_WindDirection = 300
Particle_WindStrength = 50
Particle_WindHeight = 40
Particle_WindWidth = 4
Particle_WindDirRandom = 10
Particle_WindStrenghtRandom = 5
Particle_WindDistanceFromPoint = 4
Particle_WindHeightIncrement = 4
Particle_WindWidthIncrement = 4
Particle_WindSpawnRate = 4
Particle_WindVisible = "OFF"
Particle_WindEnabled = "ON"

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
	Particle_Duplicator = Settings_GetValue("Particle", "duplicator")
	Particle_FireIntensityScale = Settings_GetValue("Particle", "intensity_scale")
	Particle_SmokeFadeIn = Settings_GetValue("Particle", "smoke_fadein")
	Particle_SmokeFadeOut = Settings_GetValue("Particle", "smoke_fadeout")
	Particle_FireFadeIn = Settings_GetValue("Particle", "fire_fadein")
	Particle_FireFadeOut = Settings_GetValue("Particle", "fire_fadeout")
	Particle_FireEmissive = Settings_GetValue("Particle", "fire_emissive")
	Particle_Embers = Settings_GetValue("Particle", "embers")
	Particle_WindEnabled= Settings_GetValue("Particle", "windenabled")
	Particle_WindStrength = Settings_GetValue("Particle", "windstrength")
	Particle_WindHeight = Settings_GetValue("Particle", "windheight")
	Particle_WindWidth = Settings_GetValue("Particle", "windwidth")
	Particle_WindVisible = Settings_GetValue("Particle", "windvisible")
	Particle_WindDirection = Settings_GetValue("Particle", "winddirection")
	Particle_WindDirRandom = Settings_GetValue("Particle", "winddirrandom")
	Particle_WindStrenghtRandom = Settings_GetValue("Particle", "windstrengthrandom")
	Particle_WindDistanceFromPoint = Settings_GetValue("Particle", "winddistancefrompoint")
	Particle_WindHeightIncrement = Settings_GetValue("Particle", "windheightincrement")
	Particle_WindWidthIncrement = Settings_GetValue("Particle", "windwidthincrement")
	Particle_WindSpawnRate = Settings_GetValue("Particle", "windspawnrate")
	if Particle_Embers == "LOW" then
		Particle_Type = {3, 5, 5, 13, 14, 3, 5, 5, 13, 14, 8}
	elseif Particle_Embers == "HIGH" then
		Particle_Type = {3, 5, 8, 13, 14, 8, 3, 5, 8, 13, 14, 8}
	else
		Particle_Type = {3, 5, 5, 13, 14, 5, 3, 5, 5, 13, 14, 5}
	end
end

Particle_WindSpawnRateCounter = 0
function Particle_SpawnWindWall(location)
	Particle_WindSpawnRateCounter = Particle_WindSpawnRateCounter + 1

	if Particle_WindSpawnRateCounter > Particle_WindSpawnRate then
		ParticleReset()
		ParticleType("smoke")
		ParticleRadius(10)
		ParticleGravity(0)		-- Slightly randomized gravity looks better
		ParticleDrag(0)
		if Particle_WindVisible == "ON" then
			ParticleAlpha(1)
		else
			ParticleAlpha(0)
		end
		ParticleCollide(1)
		--Emit particles

		local start = Particle_WindWidth * Particle_WindWidthIncrement
		start =  (start / 2) - start
		local dirdegstart = Particle_WindDirection - start
		for x=1, Particle_WindWidth do
			dirdegstart = dirdegstart + (x * Particle_WindWidthIncrement)
			local direction = Generic_rndInt(dirdegstart - Particle_WindDirRandom, dirdegstart + Particle_WindDirRandom)
			local radian = math.rad(direction)
			local vecdir = {math.cos(radian), 0,  math.sin(radian)}


			local temp = Generic_deepCopy(location)
			temp[2] = 0
			temp = VecAdd(temp, VecScale(vecdir, Particle_WindDistanceFromPoint))
			temp[2] = location[2]
			local direction = VecNormalize(VecSub(location, temp))
			-- local actualwidth = Particle_WindWidth
			-- temp[1] = temp[1] * ((actualwidth / 2) - actualwidth)
			-- temp[3] = temp[3] * ((actualwidth / 2) - actualwidth)
			-- local increment_start = (((Particle_WindWidthIncrement * Particle_WindWidth) / 2))
			-- increment_start = increment_start - (Particle_WindWidthIncrement * Particle_WindWidth)
			-- for x=1, Particle_WindWidthIncrement do

			-- 	local newincrement = increment_start + (Particle_WindWidthIncrement * x)
			-- 	temp[1] = temp[1] + newincrement
			-- 	temp[3] = temp[3] + newincrement


			local temp2 = Generic_deepCopy(temp)
			local height = Particle_WindHeight
			for i=1, height do
				local strength = Generic_rndInt(Particle_WindStrength - Particle_WindStrenghtRandom, Particle_WindStrength + Particle_WindStrenghtRandom)
				--Spawn particle into the world
				SpawnParticle(temp2, VecScale(direction, strength), 2)
				temp2[2] = temp2[2] + Particle_WindHeightIncrement
			end
		end
		-- end
		Particle_WindSpawnRateCounter = 0
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
	ParticleDrag(drag)
	ParticleCollide(1, 1, "constant", 0.01)
	local iterator = Particle_Duplicator
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

		local rand = Generic_rndInt(1, #Particle_Type)
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
			ParticleStretch(1, 10)
			local emissive = Generic_rnd(Particle_FireEmissive / 2, Particle_FireEmissive)
			ParticleEmissive(emissive - radius, 0, "smooth")
			ParticleRadius(radius / 2 , radius / 2, "easein")
		else
			-- life = radius * life * 2
			local emissive = Generic_rnd(Particle_FireEmissive / 2, Particle_FireEmissive)
			ParticleEmissive(emissive - radius, 0, "smooth", 0, (Particle_FireFadeIn / 100) * Generic_rnd(variation , variation * 3))
			ParticleRadius(radius, radius, "easein", life * (Particle_FireFadeIn / 100), life * (Particle_FireFadeOut / 100))
		end
		iterator = 1
	else
		ParticleAlpha(alpha / 2, alpha, "easein", (Particle_SmokeFadeIn / 100), (Particle_SmokeFadeOut / 100))	-- Ramp up fast, ramp down after 50%
		ParticleRadius(radius / 2, radius, "easein", (Particle_SmokeFadeIn / 100),  (Particle_SmokeFadeOut / 100))
		ParticleColor(red, green, blue, 0.4, 0.4, 0.4)
	end		-- Animating color towards fire color from near white

	for d=1, iterator do
		ParticleGravity(Generic_rnd(gravity - (gravity / 2), gravity + (gravity / 2)))		-- Slightly randomized gravity looks better

		ParticleRotation(Generic_rnd(vel * -2, vel * 2), 2, "smooth", 0.5/life)
		--Emit particles

		local v = {Generic_rnd(vel * - 2, vel * 2),Generic_rnd(vel * - 2, vel * 2),Generic_rnd(vel * - 2, vel * 2)}

		--Spawn particle into the world
		SpawnParticle(location, v, life)
	end
end
