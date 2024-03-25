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
Particle_TypeSmoke = {0}
Particle_LocationRandomness = 0.5

Particle_EmitLight = false
Particle_Distance_Padding = 0.5
Particle_LightFlickerIntensity = 0.1 -- This determines the flickering of the lights  (simulating fire)
Particle_AlternateEmitters = false
Particle_UpdateRate = 60 -- update 60 times per second (60fps)
Particle_UpdateRateTimer = 0 -- update 60 times per second (60fps)
Particle_VisualizeSpawnLocationsSetting = false

Particle_MaxSpawnLocations = 1000

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

-- Optimize dynamic compile time, should compile only once localy?  According to: https://www.lua.org/gems/sample.pdf
local FuncRndNum = Generic_rnd
local FuncRndVec = Generic_rndVec
local FuncRndInt = Generic_rndInt
local FuncDeepCopy = Generic_deepCopy
local FuncCreateBox = Generic_CreateBox
local FuncVecDistance = Generic_VecDistance
local FuncHashVec = Generic_HashVec
local FuncParticleReset = ParticleReset
local FuncParticleCollide = ParticleCollide
local FuncParticleAlpha = ParticleAlpha
local FuncParticleTile = ParticleTile
local FuncParticleRadius = ParticleRadius
local FuncParticleGravity = ParticleGravity
local FuncParticleDrag = ParticleDrag
local FuncParticleRotation = ParticleRotation
local FuncParticleSticky = ParticleSticky
local FuncParticleColor = ParticleColor
local FuncParticleEmissive = ParticleEmissive
local FuncParticleType = ParticleType
local FuncParticleStretch = ParticleStretch
local FuncSpawnParticle = SpawnParticle

local FuncVec = Vec
local FuncVecAdd = VecAdd
local FuncVecScale = VecScale

-- local pairs = pairs

-- local Particle_EmitParticle = Particle_EmitParticle
-- local Particle_SpawnParticle = Particle_SpawnParticle

local FuncLightSpawnerDeleteLightFade = LightSpawner_DeleteLightFade

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
	Particle_Distance_Padding = Settings_GetValue("Particle", "min_particle_dist")
	Particle_Randomness = Settings_GetValue("Particle", "randomness")
	Particle_LocationRandomness = Settings_GetValue("Particle", "location_randomness")

    Particle_VisualizeSpawnLocationsSetting = Settings_GetValue("Particle", "visualize_spawn_locations")

	if Particle_VisualizeSpawnLocationsSetting == nil then
		Particle_VisualizeSpawnLocations = false
		Settings_SetValue("Particle", "visualize_spawn_locations", "OFF")
	elseif Particle_VisualizeSpawnLocationsSetting == "ON" then
		Particle_VisualizeSpawnLocations = true
	else
		Particle_VisualizeSpawnLocations = false
	end


	if Particle_Distance_Padding < 0.1 then
		Particle_Distance_Padding = 0.1
		Settings_SetValue("Particle", "min_particle_dist", Particle_Distance_Padding)
	end

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

function Particle_EmitParticleOld(emitter, location, particle, fire_intensity)

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
	alpha = alpha +  FuncRndNum( -variation, variation)
	-- gravity = gravity + FuncRndNum(gravity / 2 , gravity * 2)
	if alpha > 1 then
		alpha = 1
	end

	if alpha < 0 then
		alpha = 0
	end

	radius = radius * (fire_intensity / 100)

	--Set up the particle state
	FuncParticleReset()
	FuncParticleCollide(1, 1, "constant", 0.01)
	local iterator = Particle_Duplicator

	local rRandomness = FuncRndNum(-Particle_Randomness, Particle_Randomness)
	local rLocation = FuncRndVec(Particle_LocationRandomness)
	local rVelocity = FuncRndNum(-vel , vel)
	local rRotationStart = rVelocity
	local rRotationEnd = rVelocity / 4

	local fireFadeIn = Particle_FireFadeIn / 100
	local smokeFadeIn = Particle_SmokeFadeIn / 100
	local fireFadeOut = Particle_FireFadeOut / 100
	local smokeFadeOut = Particle_SmokeFadeOut / 100

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
		FuncParticleColor(red, green, blue)
		FuncParticleAlpha(1)

		iterator = FuncRndInt(1, fire_intensity / 10)
		for d=1, iterator do
			local random_sprite = FuncRndInt(1, #sprites)
			FuncParticleTile(sprites[random_sprite])
			life = (Particle_ash_life + rRandomness)
			if random_sprite == 8 then
				FuncParticleRadius(0.5, 0.1)
			else
				FuncParticleRadius(FuncRndNum(Particle_ash_size_min, (fire_intensity / 2000) ))
			end
			FuncParticleGravity(FuncRndNum(Particle_ash_gravity_min, Particle_ash_gravity_max))
			FuncParticleDrag(FuncRndNum(Particle_ash_drag_min, Particle_ash_drag_max))
			FuncParticleRotation(FuncRndNum(Particle_ash_rot_min, Particle_ash_rot_max), 0, "easein", 1)
			FuncParticleSticky(Particle_ash_sticky_min, FuncRndNum(Particle_ash_sticky_min, Particle_ash_sticky_max), "easeout")
			if  v == nil then
				v = FuncRndVec(rVelocity)
				if v[1] < 0 then
					v[1] = 0
				end
			end
			v = FuncVecAdd(v, FuncRndVec(rVelocity))
			v = FuncVecScale(v, rVelocity)
			v =  {v[1] + rRandomness, v[2] + rRandomness, v[3] + rRandomness}
			FuncParticleRotation(rRotationStart, rRotationEnd, "smooth")
			--Spawn particle into the world
			FuncSpawnParticle(FuncVecAdd(location, rLocation), v, life)
		end
	elseif particle == "ash_fire" then

		local sprites = {3, 8, 4, 6, 12}
		FuncParticleAlpha(1)
		iterator = FuncRndInt(1, fire_intensity / 10)
		for d=1, iterator do
			local random_sprite = FuncRndInt(1, #sprites)
			FuncParticleTile(sprites[random_sprite])

			local s_random = Particle_FireGradient[FuncRndInt(1, #Particle_FireGradient)]
			local s_red =  0.8 + s_random[1]
			local s_green = 0.6 + s_random[2]
			local s_blue =  0.3 + s_random[3]
			local emissive = FuncRndNum(Particle_FireEmissive / 2, Particle_FireEmissive * 2)
			FuncParticleColor(s_red, s_green, s_blue, 0.2,  0.2,  0.2)
			FuncParticleEmissive(emissive, 2, "easeout", 0,  fireFadeIn + rRandomness)
			life = (Particle_ash_life + rRandomness)
			if random_sprite == 8 then
				FuncParticleRadius(0.5, 0.1)
			else
				FuncParticleRadius(FuncRndNum(Particle_ash_size_min, (fire_intensity / 2000)))
			end
			local updown = Generic_rndInt(-1, 1);
			FuncParticleGravity(FuncRndNum(Particle_ash_gravity_min * updown, Particle_ash_gravity_max * updown))
			FuncParticleDrag(FuncRndNum(Particle_ash_drag_min, Particle_ash_drag_max))
			FuncParticleRotation(FuncRndNum(Particle_ash_rot_min, Particle_ash_rot_max), 0, "easein", 1)
			if  v == nil then
				v = FuncRndVec(rVelocity)
				if v[1] < 0 then
					v[1] = 0
				end
			end
			v = FuncVecAdd(v, FuncRndVec(rVelocity))
			v = FuncVecScale(v, rVelocity)
			v =  {v[1] + rRandomness, v[2] + rRandomness, v[3] + rRandomness}
			FuncParticleRotation(rRotationStart, rRotationEnd, "smooth")
			--Spawn particle into the world
			FuncSpawnParticle(FuncVecAdd(location, rLocation), v, life)
		end
	elseif particle == "fire" then
		local rand = FuncRndInt(1, #Particle_TypeFire)
		local particle_type = Particle_TypeFire[rand]

		FuncParticleType("smoke")
		FuncParticleTile(particle_type)
		FuncParticleDrag(drag)

		local s_random = Particle_FireGradient[FuncRndInt(1, #Particle_FireGradient)]
		local s_red =  0.8 + s_random[1]
		local s_green = 0.6 + s_random[2]
		local s_blue =  0.3 + s_random[3]
		-- 3 - 5 - 13 -  14
		-- 8 = fire embers
		life = life + rRandomness
		if life < 0.5 then
			life = 0.5
		end

		FuncParticleColor(s_red, s_green, s_blue, red, green, blue)
		FuncParticleStretch(0, rRandomness)

		FuncParticleAlpha(alpha, 0, "smooth",  fireFadeIn + rRandomness, fireFadeOut + rRandomness)	-- Ramp up fast, ramp down after 50%

		if particle_type == 5 then
			local emissive = FuncRndNum(Particle_FireEmissive, Particle_FireEmissive * 2)
			FuncParticleEmissive(emissive, 2, "easeout", 0,  fireFadeIn + rRandomness, fireFadeOut + rRandomness)
			FuncParticleRadius(radius + rRandomness , radius / 4 + rRandomness, "easein", fireFadeIn + rRandomness, fireFadeOut + rRandomness)
			-- life = radius * life * 2
		elseif particle_type == 8 then
			gravity = gravity +  FuncRndNum(1, 3)
			vel = vel + FuncRndNum(2 , 4)
			FuncParticleStretch(1, 10)
			local emissive = Particle_FireEmissive + rRandomness
			FuncParticleEmissive(emissive, 2, "easeout")
			FuncParticleRadius(radius + rRandomness , radius / 2, "easein", fireFadeIn + rRandomness, fireFadeOut + rRandomness)
		else
			-- life = radius * life * 2
			local emissive = Particle_FireEmissive + rRandomness
			FuncParticleEmissive(emissive, 2, "easeout", 0,  fireFadeIn * FuncRndNum(variation , variation * 3))
			FuncParticleRadius(radius + rRandomness , radius / 4 + rRandomness, "easein", fireFadeIn + rRandomness, fireFadeOut + rRandomness)
		end
		--Emit particles
		if  v == nil then
			v = FuncRndVec(rVelocity)
			if v[1] < 0 then
				v[1] = 0
			end
		end
		FuncParticleGravity(gravity + rRandomness, (gravity + rRandomness) / 2)  		-- Slightly randomized gravity looks better

		FuncParticleRotation(rRotationStart, rRotationEnd, "smooth", fireFadeIn + rRandomness, fireFadeOut + rRandomness)
		--Spawn particle into the world
		FuncSpawnParticle(FuncVecAdd(location, rLocation), v, life)

	else
		local rand = FuncRndInt(1, #Particle_TypeSmoke)
		local particle_type = Particle_TypeSmoke[rand]
		FuncParticleType("smoke")
		FuncParticleTile(particle_type)
		FuncParticleDrag(drag)
		if Particle_SmokeGradient then
			if fire_intensity < 10 then
				red = red + Particle_SmokeGradient[1][1]
				green = green + Particle_SmokeGradient[1][2]
				blue = blue + Particle_SmokeGradient[1][3]
			elseif fire_intensity < 20 then
				red = red + Particle_SmokeGradient[2][1]
				green = green + Particle_SmokeGradient[2][2]
				blue = blue + Particle_SmokeGradient[2][3]
			elseif fire_intensity < 40 then
				red = red + Particle_SmokeGradient[3][1]
				green = green + Particle_SmokeGradient[3][2]
				blue = blue + Particle_SmokeGradient[3][3]
			elseif fire_intensity < 60 then
				red = red + Particle_SmokeGradient[4][1]
				green = green + Particle_SmokeGradient[4][2]
				blue = blue + Particle_SmokeGradient[4][3]
			elseif fire_intensity <= 100 then
				red = red + Particle_SmokeGradient[5][1]
				green = green + Particle_SmokeGradient[5][2]
				blue = blue + Particle_SmokeGradient[5][3]
			end
		end
		local oneBasedFireIntensity = 0.8 - ((0.01 * fire_intensity) - FuncRndNum(-0.1, 0.1))
		local lRed =  oneBasedFireIntensity - red
		local lBlue =  oneBasedFireIntensity - blue
		local lGreen =  oneBasedFireIntensity - green

		if lRed < red / 2 then
			lRed = red / 2
		end

		if lBlue  < blue  / 2 then
			lBlue = blue  / 2
		end

		if lGreen <  green  / 2 then
			lGreen = green  / 2
		end

		FuncParticleAlpha(0.1, alpha + rRandomness, "easeout",  smokeFadeIn, smokeFadeOut)	-- Ramp up fast, ramp down after 50%
		FuncParticleRadius(0.1, radius + rRandomness, "easeout",  smokeFadeIn, smokeFadeOut)
		FuncParticleColor(lRed, lGreen, lBlue, lRed + 0.1 , lGreen +  0.1 , lBlue +  0.1 )
		FuncParticleGravity(gravity + rRandomness, (gravity + rRandomness) / 2)  		-- Slightly randomized gravity looks better
		--Emit particles
		if  v == nil then
			v = FuncRndVec(rVelocity)
			if v[1] < 0 then
				v[1] = 0
			end
		end

		for d=1, iterator do
			FuncParticleRotation(rRotationStart, rRotationEnd, "smooth", smokeFadeIn, smokeFadeOut)
			--Spawn particle into the world
			FuncSpawnParticle(FuncVecAdd(location, FuncRndVec(Particle_LocationRandomness)), v, life)
		end
	end

end

ParticleObject = {
	toclose=false,
	type=nil,
	emitters={},
	previoustypes={},
	location=nil,
	explosion=nil,
	fire_intensity_orig=nil,
	fire_intensity=0,
	lightinstance=nil,
	timer=nil,
	timeout=nil,
	fadein=true,
	fadeintime=0.5,
	fadeinreduction=nil,
	fadeout=false,
	fadeouttime=0.5,
	fadeoutreduction=nil
}

ParticleSpawnerList = {}
ParticleLightSpawning = {}


function Particle_FireSmoke(fire_emitter, smoke_emitter, fire_intensity, smoke_intensity, location, explosion, timeout, id)
	if timeout == nil then
		timeout = 0.1
	end
	local success_fire_emitter = Particle_EmitParticle(fire_emitter, location, "fire", fire_intensity, explosion, timeout, id)
	local success_smoke_emitter = Particle_EmitParticle(smoke_emitter, location, "smoke", smoke_intensity, explosion, timeout, id)
	return (success_fire_emitter and success_smoke_emitter)
end

function Particle_SpawnLight(point, material, intensity)
    material = FuncDeepCopy(material)
	if material == nil then
		return {point, intensity, Particle_MaxLightSize, {0,1,0}, false}
	end
	material["color"]["r"] =  material["color"]["r"] - 0
    material["color"]["g"] =  material["color"]["g"] - 0.1
    material["color"]["b"] =  material["color"]["b"] - 0.1

    if  material["color"]["r"] > 1 then
        material["color"]["r"] = 1
    end
    if  material["color"]["r"] < 0 then
        material["color"]["r"] = 0
    end

    if  material["color"]["g"] > 1 then
        material["color"]["g"] = 1
    end
    if  material["color"]["g"] < 0 then
        material["color"]["g"] = 0
    end

    if  material["color"]["b"] > 1 then
        material["color"]["b"] = 1
    end
    if  material["color"]["b"] < 0 then
        material["color"]["b"] = 0
    end
	local randomlightfactor = 0.5 + FuncRndNum(-Particle_LightFlickerIntensity, Particle_LightFlickerIntensity)
    local color = FuncVec(material["color"]["r"], material["color"]["g"], material["color"]["b"])
    return {point, intensity * randomlightfactor, Particle_MaxLightSize, color, true}
end


function Particle_TickParticle(dt)
	-- local last_pressed = InputLastPressedKey()
	-- if last_pressed == Particle_ToggleLightKey then
	-- 	if Particle_EmitLight then
	-- 		Particle_EmitLight = false
	-- 		LightSpawner_DeleteAll()
	-- 		-- DebugWatch("Disabled light during fire/explosions on plane (YOUR PC IS GRATEFULL)")
	-- 	else
	-- 		Particle_EmitLight = true
	-- 		-- DebugWatch("Enabled light during fire/explosions on plane(FPS KILLER)")
	-- 	end
	-- end

end

--- func desc
---@param dt any
---@param spawnfire if true spawn fire
function Particle_UpdateParticle(dt, spawnfire)
	-- Particle_CloseToLocationUpdate()


	ParticleLightSpawning = {}
	Particle_UpdateRateTimer = Particle_UpdateRateTimer + dt
	if Particle_UpdateRateTimer >= (1 / Particle_UpdateRate) then

		local count = 0
		for hash, particlespawner in pairs(ParticleSpawnerList) do

			if count > Particle_MaxSpawnLocations then
				break
			end
			local emitters = particlespawner["emitters"]
			local location = particlespawner["location"]
			local fire_intensity = particlespawner["fire_intensity"]
			local explosion = particlespawner["explosion"]
			local toclose = particlespawner["toclose"]

			local deleted = false
			if Particle_VisualizeSpawnLocations then
				local curintdist = fire_intensity / 100
				local color = {0,0,0}
				if toclose then
					color = {curintdist, curintdist, curintdist}
					ParticleSpawnerList[hash]["fadeout"] = true
				elseif ParticleSpawnerList[hash]["fadeout"] then
					color = {1 - curintdist, 0, curintdist}
				elseif ParticleSpawnerList[hash]["fadein"] then
					color = {curintdist, 1 - curintdist, 0}
				else
					color = {curintdist, 0, 1 - curintdist}
				end
				FuncCreateBox(location, curintdist, nil, color, true)

			end

			for type, emitter in pairs(emitters) do
				if particlespawner["previoustypes"][type] == nil then

					if spawnfire and type == "fire" then
						ParticleSpawner_SpawnParticle(location, emitter, type, fire_intensity, explosion)
					elseif type == "smoke" then
						ParticleSpawner_SpawnParticle(location, emitter, type, fire_intensity, explosion)
					end

					if Particle_AlternateEmitters then
						particlespawner["previoustypes"][type] = true
						break
					end
				end
			end

			ParticleLightSpawning[#ParticleLightSpawning+1] = FuncDeepCopy(hash)

			-- Timeout the particle

			if deleted == false then
				local hit, p, n, s = QueryClosestPoint(ParticleSpawnerList[hash]["location"], 0.1)
				if hit == false then
					ParticleSpawnerList[hash]["fire_intensity"] = 0
					ParticleSpawnerList[hash] = nil
					deleted = true
					LightSpawner_DeleteLight(particlespawner["lightinstance"])
				end

				if ParticleSpawnerList[hash]["timeout"] < ParticleSpawnerList[hash]["timer"] and ParticleSpawnerList[hash]["fadeout"] == false then
					ParticleSpawnerList[hash]["fadeout"] = true
					ParticleSpawnerList[hash]["fadein"] = false
					if particlespawner["lightinstance"] ~= nil then
						FuncLightSpawnerDeleteLightFade(particlespawner["lightinstance"], ParticleSpawnerList[hash]["fadeouttime"])
					end
				elseif ParticleSpawnerList[hash]["fadeout"] and ParticleSpawnerList[hash]["fire_intensity"] > 0 then
					if ParticleSpawnerList[hash]["fadeoutreduction"] == nil then
						ParticleSpawnerList[hash]["fadeoutreduction"] = ParticleSpawnerList[hash]["fire_intensity"] / (ParticleSpawnerList[hash]["fadeouttime"] / dt)
					end
					ParticleSpawnerList[hash]["fadein"] = false
					ParticleSpawnerList[hash]["fire_intensity"] = ParticleSpawnerList[hash]["fire_intensity"] - ParticleSpawnerList[hash]["fadeoutreduction"]

				elseif ParticleSpawnerList[hash]["fadein"] then
					if ParticleSpawnerList[hash]["fadeinreduction"] == nil then
						ParticleSpawnerList[hash]["fadeinreduction"] = ParticleSpawnerList[hash]["fire_intensity_orig"] / (ParticleSpawnerList[hash]["fadeintime"] / dt)
					end
					if ParticleSpawnerList[hash]["fire_intensity"] < ParticleSpawnerList[hash]["fire_intensity_orig"] then
						ParticleSpawnerList[hash]["fire_intensity"] = ParticleSpawnerList[hash]["fire_intensity"] + ParticleSpawnerList[hash]["fadeinreduction"]
					else
						ParticleSpawnerList[hash]["fadein"] = false
					end
				elseif ParticleSpawnerList[hash]["fadeout"] then
					ParticleSpawnerList[hash] = nil
					deleted = true
				end
				count = count + 1
					-- ParticleSpawnerList[hash]["fire_intensity"] = ParticleSpawnerList[hash]["fire_intensity_orig"]
				ParticleSpawnerList[hash]["timer"] = ParticleSpawnerList[hash]["timer"] + dt
			end

		end
		-- DebugWatch("Actual Spawn Locations", count)
		Particle_UpdateRateTimer = 0
	end
end




function ParticleSpawner_SpawnParticle(location, emitter, type, fire_intensity, explosion)

	-- Generate particle

	local radius = emitter["size"]
	local life = emitter["lifetime"]
	local vel = emitter["speed"]
	local rot = emitter["rotation"]
	local drag = emitter["drag"]
	local gravity = emitter["gravity"]
	-- Fire color
	local red = emitter["color"]["r"]
	local green = emitter["color"]["g"]
	local blue = emitter["color"]["b"]
	local alpha = emitter["color"]["a"]
	local variation = emitter["variation"]
	local custom_direction = emitter["custom_direction"]
	local location_random = Particle_LocationRandomness

	local iterator = Particle_Duplicator
	for d=1, iterator do
		alpha = alpha +  FuncRndNum( -variation, variation)
		-- gravity = gravity + FuncRndNum(gravity / 20 , gravity * 2)
		if alpha > 1 then
			alpha = 1
		end

		if alpha < 0 then
			alpha = 0.2
		end

		local randomness = 1 + FuncRndNum(-Particle_Randomness, Particle_Randomness)
		drag = (drag * randomness)
		if drag > 1 then
			drag = 1
		end

		if drag < 0 then
			drag = 0
		end
		randomness = 1 + FuncRndNum(-Particle_Randomness, Particle_Randomness)
		radius = ((radius * (fire_intensity / 100)) * randomness)
		if radius > 1 then
			radius = 1
		end
		if radius < 0 then
			radius = 0
		end

		location_random = ((location_random * (fire_intensity / 100)) * randomness)

		-- randomness = 1 + FuncRndNum(-Particle_Randomness, Particle_Randomness)
		-- vel = vel * randomness
		randomness = 1 + FuncRndNum(-Particle_Randomness, Particle_Randomness)
		rot = rot * randomness
		randomness = 1 + FuncRndNum(-Particle_Randomness, Particle_Randomness)
		gravity = ((gravity) * randomness)

		randomness = 1 + FuncRndNum(-Particle_Randomness, Particle_Randomness)
		life = ((life * (fire_intensity / 100)) * randomness)


		--Set up the particle state
		FuncParticleReset()
		FuncParticleType("smoke")
		FuncParticleDrag(0.1, drag, "easein")
		FuncParticleCollide(1, 1, "constant", 0.05)
		if type == "fire" then
			local rand = FuncRndInt(1, #Particle_TypeFire)
			local particle_type = Particle_TypeFire[rand]
			FuncParticleTile(particle_type)
			local s_random = Particle_FireGradient[FuncRndInt(1, #Particle_FireGradient)]
			local s_red =  0.8 + s_random[1]
			local s_green = 0.6 + s_random[2]
			local s_blue =  0.3 + s_random[3]
			-- 3 - 5 - 13 -  14
			-- 8 = fire embers
			if life < 0.25 then
				life = 0.25
			end
			randomness = 1 + FuncRndNum(-Particle_Randomness, Particle_Randomness)
			local firefadein = (Particle_FireFadeIn / 100) * randomness
			randomness = 1 + FuncRndNum(-Particle_Randomness, Particle_Randomness)
			local firefadeout = (Particle_FireFadeOut / 100) * randomness

			FuncParticleColor(s_red, s_green, s_blue, red, green, blue)
			FuncParticleAlpha(alpha, 0, "easein",  firefadein,  firefadeout)	-- Ramp up fast, ramp down after 50%

			local emissive = FuncRndNum(Particle_FireEmissive / 2, Particle_FireEmissive)
			if particle_type == 5 then
				-- life = radius * life * 2
			elseif particle_type == 8 then
				gravity = gravity +  FuncRndNum(1, 3)
				vel = vel + FuncRndNum(2 , 4)
			end


			FuncParticleEmissive(emissive, 1, "easein", firefadein, firefadeout)
			FuncParticleRadius(0.05, radius, "easein", firefadein, firefadeout)

			if explosion then
				FuncParticleEmissive(emissive, 1, "easein", 0, firefadeout)
				FuncParticleRadius(radius, radius, "easein", 0, firefadeout)
			end
			iterator = 1
		else
			randomness = 1 + FuncRndNum(-Particle_Randomness, Particle_Randomness)
			local smokefadein = (Particle_SmokeFadeIn / 100) * randomness
			randomness = 1 + FuncRndNum(-Particle_Randomness, Particle_Randomness)
			local smokefadeout = (Particle_SmokeFadeOut / 100) * randomness

			local rand = FuncRndInt(1, #Particle_TypeSmoke)
			local particle_type = Particle_TypeSmoke[rand]
			FuncParticleTile(particle_type)

			FuncParticleAlpha(alpha / 2, alpha, "easein", smokefadein, smokefadeout)
			FuncParticleRadius(radius, radius / 2, "easeout", smokefadein, smokefadeout)
			if explosion then
				FuncParticleAlpha(alpha, alpha / 2, "easeout", 0, smokefadeout)
				FuncParticleRadius(radius, radius / 2, "easeout", 0, smokefadeout)
			end
			FuncParticleColor(red, green, blue, red + 0.2, green + 0.2, blue + 0.2)
		end

		local grava = FuncRndNum(gravity * 2, gravity * 8)
		local gravb = FuncRndNum(gravity, gravity * 2)
		local gravc= FuncRndNum(gravity / 8, gravity/16)
		local v = custom_direction
		FuncParticleStretch(gravb, gravc, "easeout")
		FuncParticleGravity(gravb, gravc, "easeout")		-- Slightly randomized gravity looks better
		FuncParticleRotation(rot, rot / fire_intensity * randomness, "easeout")

		if explosion then
			FuncParticleStretch(grava, gravc, "easeout")
			FuncParticleGravity(grava, gravc, "easeout")		-- Slightly randomized gravity looks better
			FuncParticleRotation(rot * 10, rot / fire_intensity * randomness, "easeout")

			if v == nil then
				v = FuncRndVec(vel * 10)
			end
		end

		if v == nil then
			v = FuncRndVec(vel)
			v[2] = vel
		end
		--Emit particles
		--Spawn particle into the world
		FuncSpawnParticle(FuncVecAdd(location, FuncRndVec(location_random)), v, life)
	end
end

function Particle_CloseToLocationUpdate()
	local mindist = Particle_Distance_Padding
	local processed = {}
	for hash1, particlespawner1 in pairs(ParticleSpawnerList) do
		if processed[hash1] == nil and particlespawner1["toclose"] == false then
			local newlocation = particlespawner1["location"]
			local newintenisty = particlespawner1["fire_intensity_orig"]
			for hash2, particlespawner2 in pairs(ParticleSpawnerList) do
				if processed[hash2] == nil and particlespawner2["toclose"] == false then
					local location = particlespawner2["location"]
					local curintensity = particlespawner2["fire_intensity_orig"]

					-- The minimum distance should be relative to the intensity (prevent to much overlap)
					-- local curintdist = curintensity * 0.01
					-- local newintdist = newintenisty * 0.01
					local mindist = mindist / 50 * newintenisty
					-- DebugWatch("mindist", mindist)
					local distance = FuncVecDistance(newlocation, location)
					if distance < mindist and newintenisty < curintensity then
						ParticleSpawnerList[hash2]["toclose"] = true
					end
					processed[hash2] = true
				end
			end
			processed[hash1] = true
		end
	end
end

function Particle_CloseToLocation(newlocation, newintenisty)
	local mindist = Particle_Distance_Padding
	local found = false
	for hash, particlespawner in pairs(ParticleSpawnerList) do
		local location = particlespawner["location"]
		local curintensity = particlespawner["fire_intensity_orig"]

		-- The minimum distance should be relative to the intensity (prevent to much overlap)
		-- local curintdist = curintensity * 0.01
		-- local newintdist = newintenisty * 0.01
		local mindist = mindist / 50 * newintenisty
		local distance = FuncVecDistance(newlocation, location)
		if distance < mindist then
			if curintensity < newintenisty then
				ParticleSpawnerList[hash]["toclose"] = true
			else
				found = true
				break
			end
			-- end
		end
	end
	return found
end


function Particle_EmitParticle(emitter, location, type, fire_intensity, explosion, timeout, id, fadeintime, fadeouttime, customhash)
	Particle_CloseToLocationUpdate()
	local locationhash = customhash
	if locationhash == nil then
		locationhash = FuncHashVec(location)
	end

	-- If there is already a particle emitting of same type near (not at) that location, we do not add it to the list
	-- if the particle is near but already exists we may update that particle
	if explosion then
		if id == nil then
			locationhash = FuncRndInt(0, 1000000)
		else
			locationhash = id
		end
	end


	if ParticleSpawnerList[locationhash] == nil then
		if Particle_CloseToLocation(location, fire_intensity) then
			return false
		end
		ParticleSpawnerList[locationhash] = FuncDeepCopy(ParticleObject)
		ParticleSpawnerList[locationhash]["fadein"] = true
		ParticleSpawnerList[locationhash]["fadeintime"] = fadeintime
		ParticleSpawnerList[locationhash]["fadeouttime"] = fadeouttime
		ParticleSpawnerList[locationhash]["timeout"] = timeout
	end

	ParticleSpawnerList[locationhash]["emitters"][type] = emitter
	ParticleSpawnerList[locationhash]["location"] = location
	ParticleSpawnerList[locationhash]["explosion"] = explosion
	ParticleSpawnerList[locationhash]["fire_intensity_orig"] = fire_intensity
	ParticleSpawnerList[locationhash]["fire_intensity"] = fire_intensity
	ParticleSpawnerList[locationhash]["timer"] = 0  -- reset the timeout timer for existing locations


	return true

end

function Particle_GetSpawnedLights()
	return FuncDeepCopy(ParticleLightSpawning)
end
