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
Particle_WindHeightStart = 1
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
Particle_Randomness =  0.5
Particle_WindSpawnRateCounter = 0
Particle_TypeFire = {3, 5, 5, 13, 14, 8}
Particle_TypeSmoke = {3, 5, 3, 5, 3, 5}


Particle_FireGradient = {
    {-0.2, -0.3, -0.3},
    {0, -0.2, -0.2},
    {-0.2, -0.1, -0.1},
    {-0.3, 0, 0},
    {-0.3, 0.1, 0.2}
}


Particle_SmokeGradient = {
    {0.2, 0.2, 0.2},
    {0.1, 0.1, 0.1},
    {0.0, 0.0, 0.0},
    {-0.1, -0.1, -0.1},
    {-0.2, -0.2, -0.2},
}

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
	Particle_WindHeightStart = Settings_GetValue("Particle", "windheightstart")
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
	Particle_Randomness = Settings_GetValue("Particle", "randomness")
	if Particle_WindHeightStart == nil or Particle_WindHeightStart < 1 then
		Particle_WindHeightStart = 1
		Settings_SetValue("Particle", "windheightstart", 1)
	end
	if Particle_Randomness < 0.1 then
		Particle_Randomness = 0.5
		Settings_SetValue("Particle", "randomness", Particle_Randomness)
	end
	if Particle_Embers == "LOW" then
		Particle_TypeFire = {3, 5, 5, 13, 14, 3, 5, 5, 13, 14, 8}
	elseif Particle_Embers == "HIGH" then
		Particle_TypeFire = {3, 5, 8, 13, 14, 8, 3, 5, 8, 13, 14, 8}
	else
		Particle_TypeFire = {3, 5, 5, 13, 14, 5, 3, 5, 5, 13, 14, 5}
	end
end

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

		local direction = Generic_rndInt(Particle_WindDirection - Particle_WindDirRandom, Particle_WindDirection + Particle_WindDirRandom)
		local radian = math.rad(direction)
		local vecdir = {math.cos(radian), 0,  math.sin(radian)}

		local radian90 = math.rad(90 + Particle_WindDirection)
		local vecdir90 = {math.cos(radian90), 0,  math.sin(radian90)}
		local radian180 = math.rad(270 + Particle_WindDirection)
		local vecdir180 = {math.cos(radian180), 0,  math.sin(radian180)}
		local start = Particle_WindWidth / 2 - Particle_WindWidth

		for x=1, Particle_WindWidth do

			local temp = Generic_deepCopy(location)
			temp[2] = 0
			temp = VecAdd(temp, VecScale(vecdir, Particle_WindDistanceFromPoint * -1))
			temp[2] = Particle_WindHeightStart

			local temp3 = Generic_deepCopy(temp)

			temp3[2] = Particle_WindHeightStart
			if x < Particle_WindWidth / 2 then
				temp3 = VecAdd(temp3, VecScale(vecdir90, (start + x) * -1 * Particle_WindWidthIncrement))
			else
				temp3 = VecAdd(temp3, VecScale(vecdir180, (start + x) * Particle_WindWidthIncrement))
			end
			temp3[2] = temp3[2]

			local temp2 = Generic_deepCopy(temp3)
			local height = Particle_WindHeight
			for i=1, height do
				local strength = Generic_rndInt(Particle_WindStrength - Particle_WindStrenghtRandom, Particle_WindStrength + Particle_WindStrenghtRandom)
				--Spawn particle into the world
				SpawnParticle(temp2, VecScale(vecdir, strength), 6)
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
	alpha = alpha +  Generic_rnd( -variation, variation)
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

	fire_intensity = Generic_rnd(fire_intensity * Particle_Randomness, fire_intensity)
	drag = ((drag / (100 / Particle_FireIntensityScale)) * fire_intensity)
	radius = ((radius / (100 / Particle_FireIntensityScale)) * fire_intensity)
	gravity = ((gravity / (75 / Particle_FireIntensityScale)) * fire_intensity)

	if Particle_Drag == "Low" then
	-- DebugWatch("fire_intensity", fire_intensity)
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
	local rand = Generic_rndInt(1, #Particle_TypeFire)
	if type == "fire" then

		local particle_type = Particle_TypeFire[rand]
		ParticleTile(particle_type)

		local s_red = 1.0
		local s_green =0.8
		local s_blue = 0.4
		-- if Particle_FireGradient then
		-- 	if fire_intensity < 20 then
		-- 		red = red - Particle_FireGradient[1][1]
		-- 		green = green - Particle_FireGradient[1][2]
		-- 		blue = blue - Particle_FireGradient[1][3]

		-- 	elseif fire_intensity < 40 then
		-- 		red = red - Particle_FireGradient[2][1]
		-- 		green = green - Particle_FireGradient[2][2]
		-- 		blue = blue - Particle_FireGradient[2][3]


		-- 	elseif fire_intensity < 60 then
		-- 		red = red - Particle_FireGradient[3][1]
		-- 		green = green - Particle_FireGradient[3][2]
		-- 		blue = blue - Particle_FireGradient[3][3]

		-- 	elseif fire_intensity < 80 then
		-- 		red = red - Particle_FireGradient[4][1]
		-- 		green = green - Particle_FireGradient[4][2]
		-- 		blue = blue - Particle_FireGradient[4][3]
		-- 	elseif fire_intensity <= 100 then
		-- 		red = red - Particle_FireGradient[5][1]
		-- 		green = green - Particle_FireGradient[5][2]
		-- 		blue = blue - Particle_FireGradient[5][3]


		-- 	end
		-- end
		-- 3 - 5 - 13 -  14
		-- 8 = fire embers
		life = life + Generic_rnd(-Particle_Randomness, Particle_Randomness)
		if life < 0.5 then
			life = 0.5
		end

		if life > 2 then
			life = 2
		end

		life = life * radius


		ParticleColor (s_red, s_green, s_blue, red, green, blue)
		ParticleStretch(0, Generic_rnd(1, Particle_Randomness * 2))
		ParticleAlpha(alpha, 0, "smooth",  life * (Particle_FireFadeIn / 100),  life * (Particle_FireFadeOut / 100))	-- Ramp up fast, ramp down after 50%

		if particle_type == 5 then

			local emissive = Generic_rnd(Particle_FireEmissive / 2, Particle_FireEmissive * 2)
			ParticleEmissive(emissive - radius, 0, "smooth", 0, (Particle_FireFadeIn / 100) * Generic_rnd(variation , variation * 3))
			ParticleRadius(radius, radius, "easein", life *(Particle_FireFadeIn / 100), life * (Particle_FireFadeOut / 100))
			-- life = radius * life * 2
		elseif particle_type == 8 then
			life = life * 8
			gravity = gravity +  Generic_rnd(1, 3)
			vel = vel + Generic_rnd(2 , 4)
			ParticleStretch(1, 10)
			local emissive = Generic_rnd(Particle_FireEmissive / 2, Particle_FireEmissive * 2)
			ParticleEmissive(emissive - radius, 0, "smooth")
			ParticleRadius(radius / 2 , radius / 2, "easein")
		else
			-- life = radius * life * 2
			local emissive = Generic_rnd(Particle_FireEmissive / 2, Particle_FireEmissive * 2)
			ParticleEmissive(emissive, 0, "smooth", 0, (Particle_FireFadeIn / 100) * Generic_rnd(variation , variation * 3))
			ParticleRadius(radius * 0.5, radius, "easeout")
		end
		iterator = 1
	else
		if Particle_SmokeGradient then
			if fire_intensity < 20 then
				red = red + Particle_SmokeGradient[1][1]
				green = green + Particle_SmokeGradient[1][2]
				blue = blue + Particle_SmokeGradient[1][3]
			elseif fire_intensity < 40 then
				red = red + Particle_SmokeGradient[2][1]
				green = green + Particle_SmokeGradient[2][2]
				blue = blue + Particle_SmokeGradient[2][3]
			elseif fire_intensity < 60 then
				red = red + Particle_SmokeGradient[3][1]
				green = green + Particle_SmokeGradient[3][2]
				blue = blue + Particle_SmokeGradient[3][3]
			elseif fire_intensity < 80 then
				red = red + Particle_SmokeGradient[4][1]
				green = green + Particle_SmokeGradient[4][2]
				blue = blue + Particle_SmokeGradient[4][3]
			elseif fire_intensity <= 100 then
				red = red + Particle_SmokeGradient[5][1]
				green = green + Particle_SmokeGradient[5][2]
				blue = blue + Particle_SmokeGradient[5][3]
			end
		end
		local particle_type = Particle_TypeSmoke[rand]
		ParticleTile(particle_type)


		-- ParticleAlpha(alpha, alpha / 2, "smooth",  life * (Particle_SmokeFadeIn / 100),  life * (Particle_SmokeFadeOut / 100))	-- Ramp up fast, ramp down after 50%
		ParticleAlpha(alpha)
		ParticleRadius(radius * 0.5, radius, "easein")
		ParticleColor(red, green, blue, red + 0.2, green + 0.2, blue + 0.2)
	end		-- Animating color towards fire color from near white

	for d=1, iterator do
		ParticleGravity(Generic_rnd(gravity / 2, gravity))		-- Slightly randomized gravity looks better
		ParticleRotation(Generic_rnd(-vel , vel), Generic_rnd(-vel , vel), "smooth")
		--Emit particles

		local v = {Generic_rnd(-Particle_Randomness, Particle_Randomness),Generic_rnd(-Particle_Randomness, Particle_Randomness),Generic_rnd(-Particle_Randomness, Particle_Randomness)}

		--Spawn particle into the world
		SpawnParticle(location, v, life)
	end
end
