-- Particle Spawner New.lua
-- @date 2024-08-10
-- @author Eldin Zenderink
-- @brief This module spawns particles and adjust dynamically based on FPS, it can however be adjusted
--        if you do desire a slideshow :P.

ParticleSpawner = {}

ParticleSpawner.Time = 0

ParticleSpawner.Properties = {
    particle_refresh_rate = 60,
    smoke_fadein = 5,
    smoke_fadeout = 5,
    fire_fadein  = 5,
    fire_fadeout  = 5,
    fire_emissive = 5,
    randomness = 0.1
}

ParticleSpawner.ParticleTypeFire = {3, 5, 8, 13, 14, 8, 3, 5, 8, 13, 14, 8}
ParticleSpawner.ParticleFireGradient = {
    {0, 0, -0},
    {-0.1, 0, 0},
    {-0.15, 0, 0},
    {-0.2, 0, 0},
    {-0.25, 0,0}
}


ParticleSpawner.ParticleSmokeGradient = {
    {0.2, 0.2, 0.2},
    {0.1, 0.1, 0.1},
    {0.0, 0.0, 0.0},
    {-0.1, -0.1, -0.1},
    {-0.2, -0.2, -0.2},
}

function ParticleSpawner.Init(argGeneric, argSettings, argFireMaterial, argSmokeMaterial)
    ParticleSpawner.Generic = argGeneric
    ParticleSpawner.Settings = argSettings
    ParticleSpawner.FireMaterial = argFireMaterial
    ParticleSpawner.SmokeMaterial = argSmokeMaterial

    ParticleSpawner.ParticleRefreshRate = ParticleSpawner.Properties["particle_refresh_max"]
     ParticleSpawner.Settings.RegisterUpdateSettingsCallback(ParticleSpawner.UpdateSettingsFromSettings)
    -- Register callback with fire sim
end

function ParticleSpawner.UpdateSettingsFromSettings()

	ParticleSpawner.Properties["smoke_fadein"] =  ParticleSpawner.Settings.GetValue("Particle", "smoke_fadein")
	ParticleSpawner.Properties["smoke_fadeout"] =  ParticleSpawner.Settings.GetValue("Particle", "smoke_fadeout")
	ParticleSpawner.Properties["fire_fadein"] =  ParticleSpawner.Settings.GetValue("Particle", "fire_fadein")
	ParticleSpawner.Properties["fire_fadeout"] =  ParticleSpawner.Settings.GetValue("Particle", "fire_fadeout")
	ParticleSpawner.Properties["fire_emissive"] =  ParticleSpawner.Settings.GetValue("Particle", "fire_emissive")
	ParticleSpawner.Properties["randomness"] =  ParticleSpawner.Settings.GetValue("Particle", "randomness")

    ParticleSpawner.Properties["particle_refresh_max"] =  ParticleSpawner.Settings.GetValue("ParticleSpawner", "particle_refresh_max")
    ParticleSpawner.ParticleRefreshRate =  ParticleSpawner.Properties["particle_refresh_max"]
end

function ParticleSpawner.Update(dt)
    ParticleSpawner.Time = ParticleSpawner.Time + dt
end


-- Function to generate fire colors
function  ParticleSpawner.getFireColor(red,green,blue, intensity, t)

    -- return r, g, b

    local intensityvalue = ParticleSpawner.Generic.rnd(intensity / 2, 100)


    if intensityvalue > 0 then
        return 1.0, 0.25, 0.05
    elseif intensityvalue > 40 then
        return 1.0, 0.3, 0.05
    elseif intensityvalue > 70 then
        return 1.0, 0.8, 0.05
    elseif intensityvalue > 85 then
        return 1.0, 0.8, 0.1
    elseif intensityvalue > 95 then
        return 1.0, 1.0, 0.6
    elseif intensityvalue >= 100 then
        return 1.0, 1.0, 1.0
    end


end

function ParticleSpawner.SpawnParticleFireSmoke(location, material, intensity, time, type)
    -- Generic particle Settings
    -- DebugPrint("Retrieving generic particle settings")
    local emissive = ParticleSpawner.Properties["fire_emissive"]
    local fadein = ParticleSpawner.Properties["fire_fadein"] / 10
    local fadeout = ParticleSpawner.Properties["fire_fadeout"]/ 10
    if type == "smoke" then
        fadein = ParticleSpawner.Properties["smoke_fadein"]/ 10
        fadeout = ParticleSpawner.Properties["smoke_fadeout"]/ 10
    end

    local randomness_factor = ParticleSpawner.Generic.rnd(0,ParticleSpawner.Properties["randomness"])
    local fire_intensity = intensity / 100

    -- DebugPrint(fire_intensity)

    -- Particle behavior
    -- DebugPrint("Retrieving particle behavior: " .. material["size"])
	local radius = material["size"]

    -- DebugPrint("Retrieving particle behavior: size")
	local life = material["lifetime"]

    -- DebugPrint("Retrieving particle behavior: lifetime")
	local vel = material["speed"]

    -- DebugPrint("Retrieving particle behavior: speed")
	local rot = material["rotation"]

    -- DebugPrint("Retrieving particle behavior: rotation")
	local drag = material["drag"]

    -- DebugPrint("Retrieving particle behavior: drag")
	local gravity = material["gravity"]

    -- DebugPrint("Retrieving particle behavior: gravity")
	local red = material["color"]["r"]

    -- DebugPrint("Retrieving particle behavior: r")
	local green = material["color"]["g"]

    -- DebugPrint("Retrieving particle behavior: g")
	local blue = material["color"]["b"]

    -- DebugPrint("Retrieving particle behavior: b")
	local alpha = material["color"]["a"]

    -- DebugPrint("Retrieving particle behavior: a")
	local variation = material["variation"]

    -- DebugPrint("Retrieving particle behavior: variation")

    -- Manipulation of behavior
    -- DebugPrint("Manipulate particle behavior")
    local rand = 1
    local particle_type = 0
    local s_random = 1


    if type == "smoke" then
        emissive = 0
    end
    local emissive_start = emissive
    local emissive_end = emissive
    local emissive_int = "easeout"
    local emissive_fadein = fadein
    local emissive_fadeout = fadeout

    local radius_start = fire_intensity * radius
    local radius_end = fire_intensity * 2 * radius
    if radius_end > 1 then
        radius_end = 1
    end
    local radius_int = "easeout"
    local radius_fadein = fadein
    local radius_fadeout = fadeout

    local stretch_start = 3
    local stretch_end = 1
    local stretch_int = "easeout"
    local stretch_fadein = fadein
    local stretch_fadeout = fadeout

    local gravity_start = gravity
    local gravity_end = gravity
    local gravity_int = "smooth"
    local gravity_fadein = fadein
    local gravity_fadeout = fadeout

    local rotation_start = rot * (1+fire_intensity)
    local rotation_end = 0
    local rotation_int = "smooth"
    local rotation_fadein = fadein
    local rotation_fadeout = fadeout

    local alpha_start = alpha * (1 + ParticleSpawner.Generic.rnd(-variation, variation))
    local alpha_end = alpha
    local alpha_int = "smooth"
    local alpha_fadein = fadein
    local alpha_fadeout = fadeout


    local drag_start = drag * (1 + ParticleSpawner.Generic.rnd(-variation, variation))
    local drag_end = drag
    local drag_int = "smooth"
    local drag_fadein = fadein
    local drag_fadeout = fadeout

    local collide_start = 0
    local collide_end = 1



    if type == "fire" then
        rand = ParticleSpawner.Generic.rndInt(1, #ParticleSpawner.ParticleTypeFire)
        particle_type = ParticleSpawner.ParticleTypeFire[rand]
        -- if fire_intensity < 0.1 then
        --     s_random = ParticleSpawner.ParticleFireGradient[1]
        -- elseif fire_intensity < 0.2 then
        --     s_random = ParticleSpawner.ParticleFireGradient[2]
        -- elseif fire_intensity < 0.4 then
        --     s_random = ParticleSpawner.ParticleFireGradient[3]
        -- elseif fire_intensity < 0.5 then
        --     s_random = ParticleSpawner.ParticleFireGradient[4]
        -- elseif fire_intensity <= 0.7 then
        --     s_random = ParticleSpawner.ParticleFireGradient[5]
        -- end

        red, green ,blue = ParticleSpawner.getFireColor(red, green, blue, intensity, time + ParticleSpawner.Generic.rnd(0 , 30))

        if particle_type == 5 then
            emissive_start = ParticleSpawner.Generic.rnd(emissive, emissive * 2)
            emissive_end = randomness_factor
            radius_end = radius / 4
            radius_int = "easein"
            -- life = radius * life * 2
            collide_end = 0
            drag_start = 0
            drag_end = 0
        elseif particle_type == 8 then
            gravity = gravity +  ParticleSpawner.Generic.rnd(1, 3)
            vel = vel + ParticleSpawner.Generic.rnd(2 , 4)
            stretch_start = 10
            stretch_end = 1
            radius_start = radius / 4
            radius_end = radius / 2
            radius_int = "easein"
            collide_end = 0
            drag_start = 0
            drag_end = 0
        else
            -- life = radius * life * 2
            -- emissive_fadein = emissive_fadein * ParticleSpawner.Generic.rnd(variation , variation * 3)
            -- radius_start = radius / 4
            radius_int = "easein"
        end
    end


    --     radius_start = fire_intensity
    --     radius_end = fire_intensity * 4
    --     radius_int = "easein"
    --     radius_fadein = fadein
    --     radius_fadeout = fadeout

    --     if fire_intensity < 0.1 then
    --         s_random = ParticleSpawner.ParticleSmokeGradient[1]
    --     elseif fire_intensity < 0.2 then
    --         s_random = ParticleSpawner.ParticleSmokeGradient[2]
    --     elseif fire_intensity < 0.4 then
    --         s_random = ParticleSpawner.ParticleSmokeGradient[3]
    --     elseif fire_intensity < 0.5 then
    --         s_random = ParticleSpawner.ParticleSmokeGradient[4]
    --     elseif fire_intensity <= 0.7 then
    --         s_random = ParticleSpawner.ParticleSmokeGradient[5]
    --     end

    --     if type == "smoke" then
    --         emissive_start = 0
    --         emissive_end = 0
    --     end
    -- end

    -- local s_red =  red + s_random[1]
    -- local s_green = green + s_random[2]
    -- local s_blue =  blue + s_random[3]


    -- randomise:

    -- emissive_start = emissive_start
    -- emissive_end = emissive_end

    -- radius_start =  radius_start
    -- radius_end = radius_end

    -- stretch_start = stretch_start
    -- stretch_end = stretch_end

    -- gravity_start = gravity_start
    -- gravity_end = gravity_end

    -- rotation_start = rotation_start
    -- rotation_end = rotation_end

    --Emit particles
    ParticleType("smoke")
    ParticleTile(particle_type)
    -- ParticleColor(s_red, s_green, s_blue, red, green, blue)
    ParticleColor(red, green, blue)
    ParticleCollide(collide_start, collide_end, "smooth", 0.01)
    ParticleEmissive(emissive_start, emissive_end, emissive_int, emissive_fadein, emissive_fadeout)
    ParticleAlpha(alpha_start, alpha_end, alpha_int, alpha_fadein, alpha_fadeout)
    ParticleRadius(radius_start, radius_end, radius_int, radius_fadein, radius_fadeout)
    ParticleDrag(drag_start, drag_end, drag_int, drag_fadein, drag_fadeout)
    ParticleRotation(rotation_start, rotation_end, rotation_int, rotation_fadein, rotation_fadeout)
    ParticleGravity(gravity_start, gravity_end, gravity_int, gravity_fadein, gravity_fadeout)
    ParticleStretch(stretch_start, stretch_end, stretch_int, stretch_fadein, stretch_fadeout)
    SpawnParticle(VecAdd(location, randomness_factor), vel, life)

    -- DebugPrint("Spawned")

end

--- Spawn particles for specific fires
---@param fire table object containing fire info.
function ParticleSpawner.SpawnFireCallback(hash, fire)
    -- DebugPrint("Spawning particle!")
    local firemat = ParticleSpawner.FireMaterial.GetInfo(fire["material"])
    local smokemat = ParticleSpawner.SmokeMaterial.GetInfo(fire["material"])
    -- DebugPrint("Got materials!")
   ParticleSpawner.SpawnParticleFireSmoke(VecAdd(fire["location"], VecScale(fire["normal"], 0.05)), smokemat, fire["fire_intensity"], fire["timer"],  "smoke")
    ParticleSpawner.SpawnParticleFireSmoke(VecAdd(fire["location"], VecScale(fire["normal"], 0.01)), firemat, fire["fire_intensity"], fire["timer"], "fire")
end