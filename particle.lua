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
Particle_TypeFire = {3, 5, 5, 13, 14, 8}
Particle_TypeSmoke = {3, 5, 3, 5, 3, 5}
Particle_LocationRandomness = 0.5
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
	Particle_Randomness = Settings_GetValue("Particle", "randomness")
	Particle_LocationRandomness = Settings_GetValue("Particle", "location_randomness")

	if Particle_Randomness < 0.1 then
		Particle_Randomness = 0.5
		Settings_SetValue("Particle", "randomness", Particle_Randomness)
	end
	if Particle_LocationRandomness < 0.1 then
		Particle_LocationRandomness = 0.5
		Settings_SetValue("Particle", "location_randomness", Particle_LocationRandomness)
	end
	if Particle_Embers == "LOW" then
		Particle_TypeFire = {3, 5, 5, 13, 14, 3, 5, 5, 13, 14, 8}
	elseif Particle_Embers == "HIGH" then
		Particle_TypeFire = {3, 5, 8, 13, 14, 8, 3, 5, 8, 13, 14, 8}
	else
		Particle_TypeFire = {3, 5, 5, 13, 14, 5, 3, 5, 5, 13, 14, 5}
	end
end

function Particle_EmitParticle(emitter, location, particle, fire_intensity)

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
    local custom_direction = emitter["custom_direction"]
	alpha = alpha +  Generic_rnd( -variation, variation)
	-- gravity = gravity + Generic_rnd(gravity / 2 , gravity * 2)
	if alpha > 1 then
		alpha = 1
	end

	if alpha < 0 then
		alpha = 0
	end

	drag = ((drag / (100 / 1.5)) * fire_intensity)
	radius = ((radius / (100 / 1.5)) * fire_intensity)
	gravity = ((gravity / (75 / 1.5)) * fire_intensity)

	--Set up the particle state
	ParticleReset()
	ParticleType("smoke")
	ParticleDrag(drag)
	ParticleCollide(1, 1, "constant", 0.01)
	local iterator = Particle_Duplicator
	local rand = Generic_rndInt(1, #Particle_TypeFire)
	if particle == "fire" then
		local particle_type = Particle_TypeFire[rand]
		ParticleTile(particle_type)

		local s_random = Particle_FireGradient[Generic_rndInt(1, #Particle_FireGradient)]
		local s_red =  0.8 + s_random[1]
		local s_green = 0.6 + s_random[2]
		local s_blue =  0.3 + s_random[3]
		-- 3 - 5 - 13 -  14
		-- 8 = fire embers
		life = life + Generic_rnd(-Particle_Randomness, Particle_Randomness)
		if life < 0.5 then
			life = 0.5
		end


		ParticleColor (s_red, s_green, s_blue, red, green, blue)
		ParticleStretch(0, Generic_rnd(1, Particle_Randomness * 2))
		ParticleAlpha(alpha, 0, "smooth",  life * (Particle_FireFadeIn / 100),  life * (Particle_FireFadeOut / 100))	-- Ramp up fast, ramp down after 50%

		if particle_type == 5 then
			local emissive = Generic_rnd(Particle_FireEmissive, Particle_FireEmissive * 2)
			ParticleEmissive(emissive, 2, "easeout", 0, (Particle_FireFadeIn / 100) * Generic_rnd(variation , variation * 3))
			ParticleRadius(radius, radius / 4, "easein", life *(Particle_FireFadeIn / 100), life * (Particle_FireFadeOut / 100))
			-- life = radius * life * 2
		elseif particle_type == 8 then
			gravity = gravity +  Generic_rnd(1, 3)
			vel = vel + Generic_rnd(2 , 4)
			ParticleStretch(1, 10)
			local emissive = Generic_rnd(Particle_FireEmissive / 2, Particle_FireEmissive * 2)
			ParticleEmissive(emissive, 2, "easeout")
			ParticleRadius(radius , radius / 2, "easein")
		else
			-- life = radius * life * 2
			local emissive = Generic_rnd(Particle_FireEmissive / 2, Particle_FireEmissive * 2)
			ParticleEmissive(emissive, 2, "easeout", 0, (Particle_FireFadeIn / 100) * Generic_rnd(variation , variation * 3))
			ParticleRadius(radius, radius / 4, "easeout")
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
		ParticleAlpha(alpha, alpha / 2, "easein", (life / 100) * Particle_SmokeFadeIn, (life / 100) * Particle_SmokeFadeOut)
		ParticleRadius(radius * 0.75, radius, "constant")
		ParticleColor(red, green, blue, red + 0.2, green + 0.2, blue + 0.2)
	end

	for d=1, iterator do
		ParticleGravity(Generic_rnd(gravity / 2, gravity))		-- Slightly randomized gravity looks better
		ParticleRotation(Generic_rnd(-vel / 2 , vel / 2), Generic_rnd(-vel / 4 , vel / 4), "smooth")
		--Emit particles
        local v = custom_direction
        if  v == nil then
            v = {Generic_rnd(-vel, vel),Generic_rnd(0, vel),Generic_rnd(-vel, vel)}
        end

		--Spawn particle into the world
		SpawnParticle(VecAdd(location, Generic_rndVec(Particle_LocationRandomness)), v, life)
	end
end