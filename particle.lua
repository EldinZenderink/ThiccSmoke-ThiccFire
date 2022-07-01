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
Particle_TypeSmoke = {0, 0, 0, 5, 5, 5}
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



-- Global ash particle relevant settings
Particle_ash_gravity_min = -16
Particle_ash_gravity_max = -50
Particle_ash_rot_max = 2
Particle_ash_rot_min = 1
Particle_ash_sticky_max = 1
Particle_ash_sticky_min = 0.8
Particle_ash_drag_max = 0.1
Particle_ash_drag_min = 0.3
Particle_ash_size_max = 0.04
Particle_ash_size_min = 0.01
Particle_ash_life = 16

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

	if Settings_GetValue("Particle", "ash_life") == 0  then
		Settings_SetValue("Particle", "ash_gravity_min", Particle_ash_gravity_min)
		Settings_SetValue("Particle", "ash_gravity_max", Particle_ash_gravity_max)
		Settings_SetValue("Particle", "ash_rot_max", Particle_ash_rot_max)
		Settings_SetValue("Particle", "ash_rot_min", Particle_ash_rot_min)
		Settings_SetValue("Particle", "ash_sticky_max", Particle_ash_sticky_max)
		Settings_SetValue("Particle", "ash_sticky_min", Particle_ash_sticky_min)
		Settings_SetValue("Particle", "ash_drag_max", Particle_ash_drag_max)
		Settings_SetValue("Particle", "ash_drag_min", Particle_ash_drag_min)
		Settings_SetValue("Particle", "ash_size_max", Particle_ash_size_max)
		Settings_SetValue("Particle", "ash_size_min", Particle_ash_size_min)
		Settings_SetValue("Particle", "ash_life", Particle_ash_life)
	end

	Particle_ash_gravity_min = Settings_GetValue("Particle", "ash_gravity_min")
	Particle_ash_gravity_max = Settings_GetValue("Particle", "ash_gravity_max")
	Particle_ash_rot_max = Settings_GetValue("Particle", "ash_rot_max")
	Particle_ash_rot_min = Settings_GetValue("Particle", "ash_rot_min")
	Particle_ash_sticky_max = Settings_GetValue("Particle", "ash_sticky_max")
	Particle_ash_sticky_min = Settings_GetValue("Particle", "ash_sticky_min")
	Particle_ash_drag_max = Settings_GetValue("Particle", "ash_drag_max")
	Particle_ash_drag_min = Settings_GetValue("Particle", "ash_drag_min")
	Particle_ash_size_max = Settings_GetValue("Particle", "ash_size_max")
	Particle_ash_size_min = Settings_GetValue("Particle", "ash_size_min")
	Particle_ash_life = Settings_GetValue("Particle", "ash_life")
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
	ParticleCollide(1, 1, "constant", 0.01)
	local iterator = Particle_Duplicator

	local v = custom_direction
	if particle == "ash" then
		local sprites = {3, 8, 4, 6, 12}
		if Particle_SmokeGradient then
			if fire_intensity < 100 then
				red = red + Particle_SmokeGradient[1][1]
				green = green + Particle_SmokeGradient[1][2]
				blue = blue + Particle_SmokeGradient[1][3]
			elseif fire_intensity < 80 then
				red = red + Particle_SmokeGradient[2][1]
				green = green + Particle_SmokeGradient[2][2]
				blue = blue + Particle_SmokeGradient[2][3]
			elseif fire_intensity < 60 then
				red = red + Particle_SmokeGradient[3][1]
				green = green + Particle_SmokeGradient[3][2]
				blue = blue + Particle_SmokeGradient[3][3]
			elseif fire_intensity < 40 then
				red = red + Particle_SmokeGradient[4][1]
				green = green + Particle_SmokeGradient[4][2]
				blue = blue + Particle_SmokeGradient[4][3]
			elseif fire_intensity <= 20 then
				red = red + Particle_SmokeGradient[5][1]
				green = green + Particle_SmokeGradient[5][2]
				blue = blue + Particle_SmokeGradient[5][3]
			end
		end
		ParticleColor(red, green, blue)
		ParticleAlpha(1)

		iterator = Generic_rndInt(1, fire_intensity / 10)
		for d=1, iterator do
			local random_sprite = Generic_rndInt(1, #sprites)
			ParticleTile(sprites[random_sprite])
			life = (Particle_ash_life + Generic_rnd(-Particle_Randomness, Particle_Randomness))
			if random_sprite == 8 then
				ParticleRadius(0.5, 0.1)
			else
				ParticleRadius(Generic_rnd(Particle_ash_size_min, (fire_intensity / 2000) ))
			end
			ParticleGravity(Generic_rnd(Particle_ash_gravity_min, Particle_ash_gravity_max))
			ParticleDrag(Generic_rnd(Particle_ash_drag_min, Particle_ash_drag_max))
			ParticleRotation(Generic_rnd(Particle_ash_rot_min, Particle_ash_rot_max), 0, "easein", 1)
			ParticleSticky(Particle_ash_sticky_min, Generic_rnd(Particle_ash_sticky_min, Particle_ash_sticky_max), "easeout")
			if  v == nil then
				v = {Generic_rnd(-vel, vel),Generic_rnd(0, -vel),Generic_rnd(-vel, vel)}
			end
			v = VecAdd(v, Generic_rndVec(Generic_rnd(vel * 4, vel)))
			v = VecScale(v, Generic_rnd(vel * 2, vel))
			v =  {v[1] * Generic_rnd(-1, 1), v[2] * Generic_rnd(-1, 1), v[3] * Generic_rnd(-1, 1)}
			ParticleRotation(Generic_rnd(-vel / 2 , vel / 2), Generic_rnd(-vel / 4 , vel / 4), "smooth")
			--Spawn particle into the world
			SpawnParticle(VecAdd(location, Generic_rndVec(Particle_LocationRandomness * 2)), v, life)
		end
	elseif particle == "ash_fire" then

		local sprites = {3, 8, 4, 6, 12}

		ParticleAlpha(1)
		iterator = Generic_rndInt(1, fire_intensity / 10)
		for d=1, iterator do
			local random_sprite = Generic_rndInt(1, #sprites)
			ParticleTile(sprites[random_sprite])

			local s_random = Particle_FireGradient[Generic_rndInt(1, #Particle_FireGradient)]
			local s_red =  0.8 + s_random[1]
			local s_green = 0.6 + s_random[2]
			local s_blue =  0.3 + s_random[3]
			local emissive = Generic_rnd(Particle_FireEmissive / 2, Particle_FireEmissive * 2)
			ParticleColor (s_red, s_green, s_blue, 0.2,  0.2,  0.2)
			ParticleEmissive(emissive, 2, "easeout", 0, (Particle_FireFadeIn / 100) * Generic_rnd(variation , variation * 3))
			life = (Particle_ash_life + Generic_rnd(-Particle_Randomness, Particle_Randomness))
			if random_sprite == 8 then
				ParticleRadius(0.5, 0.1)
			else
				ParticleRadius(Generic_rnd(Particle_ash_size_min, (fire_intensity / 2000)))
			end
			ParticleGravity(Generic_rnd(Particle_ash_gravity_min, Particle_ash_gravity_max))
			ParticleDrag(Generic_rnd(Particle_ash_drag_min, Particle_ash_drag_max))
			ParticleRotation(Generic_rnd(Particle_ash_rot_min, Particle_ash_rot_max), 0, "easein", 1)
			ParticleSticky(Particle_ash_sticky_min, Generic_rnd(Particle_ash_sticky_min, Particle_ash_sticky_max), "easeout")
			if  v == nil then
				v = {Generic_rnd(-vel, vel),Generic_rnd(0, -vel),Generic_rnd(-vel, vel)}
			end
			v = VecAdd(v, Generic_rndVec(Generic_rnd(vel * 4, vel)))
			v = VecScale(v, Generic_rnd(vel * 2, vel))
			v =  {v[1] * Generic_rnd(-1, 1), v[2] * Generic_rnd(-1, 1), v[3] * Generic_rnd(-1, 1)}
			ParticleRotation(Generic_rnd(-vel / 2 , vel / 2), Generic_rnd(-vel / 4 , vel / 4), "smooth")
			--Spawn particle into the world
			SpawnParticle(VecAdd(location, Generic_rndVec(Particle_LocationRandomness * 2)), v, life)
		end
	elseif particle == "fire" then
		local rand = Generic_rndInt(1, #Particle_TypeFire)
		local particle_type = Particle_TypeFire[rand]
		ParticleType("smoke")
		ParticleTile(particle_type)
		ParticleDrag(drag)

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
			ParticleRadius(radius / 2, radius * 2, "easein", life *(Particle_FireFadeIn / 100), life * (Particle_FireFadeOut / 100))
			-- life = radius * life * 2
		elseif particle_type == 8 then
			gravity = gravity +  Generic_rnd(1, 3)
			vel = vel + Generic_rnd(2 , 4)
			ParticleStretch(1, 10)
			local emissive = Generic_rnd(Particle_FireEmissive / 2, Particle_FireEmissive * 2)
			ParticleEmissive(emissive, 2, "easeout")
			ParticleRadius(radius / 2, radius * 2, "easein")
		else
			-- life = radius * life * 2
			local emissive = Generic_rnd(Particle_FireEmissive / 2, Particle_FireEmissive * 2)
			ParticleEmissive(emissive, 2, "easeout", 0, (Particle_FireFadeIn / 100) * Generic_rnd(variation , variation * 3))
			ParticleRadius(radius / 2, radius * 2, "easein")
		end
		iterator = 1
		--Emit particles
        if  v == nil then
            v = {Generic_rnd(-vel, vel),Generic_rnd(0, vel),Generic_rnd(-vel, vel)}
        end
		ParticleGravity(Generic_rnd(gravity / 2, gravity))		-- Slightly randomized gravity looks better

		for d=1, iterator do
			ParticleRotation(Generic_rnd(-vel / 2 , vel / 2), Generic_rnd(-vel / 4 , vel / 4), "smooth")
			--Spawn particle into the world
			SpawnParticle(VecAdd(location, Generic_rndVec(Particle_LocationRandomness)), v, life)
		end

	else
		local rand = Generic_rndInt(1, #Particle_TypeSmoke)
		local particle_type = Particle_TypeSmoke[rand]
		ParticleType("smoke")
		ParticleTile(particle_type)
		ParticleDrag(drag)
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
		ParticleAlpha(alpha, alpha/2, "easein", (life / 100) * Particle_SmokeFadeIn, (life / 100) * Particle_SmokeFadeOut)
		ParticleRadius(radius / 2, radius * 2, "easein")
		ParticleColor(red, green, blue, red + 0.2, green + 0.2, blue + 0.2)
		ParticleGravity(Generic_rnd(gravity / 2, gravity))		-- Slightly randomized gravity looks better
		--Emit particles
        local v = custom_direction
        if  v == nil then
            v = {Generic_rnd(-vel, vel),Generic_rnd(0, vel),Generic_rnd(-vel, vel)}
        end

		for d=1, iterator do
			ParticleRotation(Generic_rnd(-vel / 2 , vel / 2), Generic_rnd(-vel / 4 , vel / 4), "smooth")
			--Spawn particle into the world
			SpawnParticle(VecAdd(location, Generic_rndVec(Particle_LocationRandomness)), v, life)
		end
	end

end