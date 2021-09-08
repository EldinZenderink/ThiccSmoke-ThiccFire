--	Script loosly based on "smokegun" mod by Tuxedo Labs
--  Author: Eldin Zenderink
--  Description:  Create some thicker smoke, with colors matched to materials on fire.
--  Note: Unfortunately there is no way to know if a "shape" is on fire or not, only if it is destroyed, this means
--  	  that this causes that just breaking stuff would also generate smoke, so just use it when your into burning stuff.

-- Some global stuff to store.
local default_smoke_types = {}

default_smoke_types["metal"] = {
	color={r=0.3,g=0.3,b=0.3,a=0.7},
	amount=3,
	life=10,
	radius=0.3,
	gravity=1,
	velocity=3,
	drag=1,
	random_alpha=0.1,
	emit_duration=25
}
default_smoke_types["masonery"] = {
	color={r=0.4,g=0.4,b=0.4,a=0.7},
	amount=3,
	life=25,
	radius=0.2,
	gravity=1,
	velocity=2,
	drag=1,
	random_alpha=0.1,
	emit_duration=25
}
default_smoke_types["wood"] = {
	color={r=0.15,g=0.15,b=0.15,a=0.6},
	amount=4,
	life=15,
	radius=0.4,
	gravity=2,
	velocity=1,
	drag=1,
	random_alpha=0.4,
	emit_duration=25
}
default_smoke_types["plaster"] = {
	color={r=0.2,g=0.2,b=0.25,a=0.8},
	amount=3,
	life=20,
	radius=0.3,
	gravity=1,
	velocity=2,
	drag=1,
	random_alpha=0.5,
	emit_duration=25
}
default_smoke_types["foliage"] = {
	color={r=0.3,g=0.33,b=0.3,a=0.7},
	amount=4,
	life=25,
	radius=0.4,
	gravity=1,
	velocity=1,
	drag=1,
	random_alpha=0.4,
	emit_duration=25
}
default_smoke_types["plastic"] = {
	color={r=0.1,g=0.1,b=0.15,a=0.9},
	amount=4,
	life=30,
	radius=0.3,
	gravity=1,
	velocity=3,
	drag=1,
	random_alpha=0.1,
	emit_duration=25
}

local smoke_materials = {"wood", "foliage", "plaster", "plastic", "masonery", "metal"}

local smoke_types = {}

local to_emit = {}

-- Determine if a user action happend (left mouse click)
-- Used to store shapes destroyed within configured time of that action
local to_emit_during_disabled = {}
local temp_disabled = false
local temp_disabled_last_time = 0
local temp_disabled_timer = 0

-- Clear the list with shapes that were found destroyed during the user action
-- Do this every 4 seconds
local temp_disabled_clear_timer = 0
local temp_disabled_clear_last_time = 0
local temp_disabled_clear_timout = 10


-- Debug helper functions
function ClearDebugPrinter()
	for i = 0, 20 do
		DebugPrint("")
	end
end


function DebugPrinter(line)
	if GetString("savegame.mod.thiccsmoke.debug") == "ON" then
		DebugPrint(line)
	end
end

-- Store an emitter, and if already stored do not store again (prevent multiple emitters for performance)
function push_emitter(t)
	local found = false
	for i=1, #to_emit do
		if to_emit[i]["id"] == t["id"] then
			found = true
			break
		end
	end

	for i=1, #to_emit_during_disabled do
		if to_emit_during_disabled[i]["id"] == t["id"] then
			table.remove(to_emit, i)
			found = true
			break
		end
	end

	if found then
		return false
	end
	table.insert(to_emit, t)
	return true
end

-- Store shapes that should not emit (broken by user action)
function push_emitter_during_disabled(t)
	local found = false
	for i=1, #to_emit_during_disabled do
		if to_emit_during_disabled[i]["id"] == t["id"] then
			found = true
			break
		end
	end

	if found then
		return false
	end
	table.insert(to_emit_during_disabled, t)
	return true
end

-- Clear list of possible left over shapes
function clear_emitter_during_disabled()
	local found = false
	local count = 0
	for i=1, #to_emit_during_disabled do
		to_emit_during_disabled[i] = nil
		count = i
	end
	DebugPrinter("Clear amount left overs: " .. count)
end

-- Get and remove the first emitter in the list
function get_emitter()
    local emitter = table.remove(to_emit, 1)
	if emitter then
		if emitter["emit_duration"] > 0 then
			emitter["emit_duration"] = emitter["emit_duration"] - 1
			push_emitter(emitter)
		end
	end
	return emitter
end

--Helper to return a random vector of particular length
function rndVec(length)
	local v = VecNormalize(Vec(math.random(-100,100), math.random(-100,100), math.random(-100,100)))
	return VecScale(v, length)
end


--Helper to return a random number in range mi to ma
function rnd(mi, ma)
	return math.random(1000)/1000*(ma-mi) + mi
end

-- Helper to update or reset smoke properties per material
function update_smoke_types(material, reset)

	DebugPrinter("Trying to update material: " .. material .. ", reset: " .. tostring(reset))
	if GetBool("savegame.mod.thiccsmoke.material." .. material .. ".stored") == nil then
		SetBool("savegame.mod.thiccsmoke.material." .. material .. ".stored", false)
	end


	if GetBool("savegame.mod.thiccsmoke.material." .. material .. ".stored") == false or reset then
		DebugPrinter("Resetting values!")
		SetFloat("savegame.mod.thiccsmoke.material." .. material .. ".color.red", default_smoke_types[material]["color"]["r"])
		SetFloat("savegame.mod.thiccsmoke.material." .. material .. ".color.green", default_smoke_types[material]["color"]["g"])
		SetFloat("savegame.mod.thiccsmoke.material." .. material .. ".color.blue", default_smoke_types[material]["color"]["b"])
		SetFloat("savegame.mod.thiccsmoke.material." .. material .. ".color.alpha", default_smoke_types[material]["color"]["a"])
		SetInt("savegame.mod.thiccsmoke.material." .. material .. ".amount", default_smoke_types[material]["amount"])
		SetInt("savegame.mod.thiccsmoke.material." .. material .. ".life", default_smoke_types[material]["life"])
		SetFloat("savegame.mod.thiccsmoke.material." .. material .. ".radius", default_smoke_types[material]["radius"])
		SetInt("savegame.mod.thiccsmoke.material." .. material .. ".gravity", default_smoke_types[material]["gravity"])
		SetInt("savegame.mod.thiccsmoke.material." .. material .. ".velocity", default_smoke_types[material]["velocity"])
		SetFloat("savegame.mod.thiccsmoke.material." .. material .. ".drag", default_smoke_types[material]["drag"])
		SetFloat("savegame.mod.thiccsmoke.material." .. material .. ".random_alpha", default_smoke_types[material]["random_alpha"])
		SetInt("savegame.mod.thiccsmoke.material." .. material .. ".emit_duration", default_smoke_types[material]["emit_duration"])
		SetBool("savegame.mod.thiccsmoke.material." .. material .. ".stored", true)
	end

	smoke_types[material] = {}
	smoke_types[material]["color"] = {}
	smoke_types[material]["color"]["r"] = GetFloat("savegame.mod.thiccsmoke.material." .. material .. ".color.red")
	smoke_types[material]["color"]["g"] = GetFloat("savegame.mod.thiccsmoke.material." .. material .. ".color.green")
	smoke_types[material]["color"]["b"] = GetFloat("savegame.mod.thiccsmoke.material." .. material .. ".color.blue")
	smoke_types[material]["color"]["a"] = GetFloat("savegame.mod.thiccsmoke.material." .. material .. ".color.alpha")
	smoke_types[material]["amount"] = GetInt("savegame.mod.thiccsmoke.material." .. material .. ".amount")
	smoke_types[material]["life"] = GetInt("savegame.mod.thiccsmoke.material." .. material .. ".life")
	smoke_types[material]["radius"] = GetFloat("savegame.mod.thiccsmoke.material." .. material .. ".radius")
	smoke_types[material]["gravity"] = GetInt("savegame.mod.thiccsmoke.material." .. material .. ".gravity")
	smoke_types[material]["velocity"] = GetInt("savegame.mod.thiccsmoke.material." .. material .. ".velocity")
	smoke_types[material]["drag"] = GetFloat("savegame.mod.thiccsmoke.material." .. material .. ".drag")
	smoke_types[material]["random_alpha"] = GetFloat("savegame.mod.thiccsmoke.material." .. material .. ".random_alpha")
	smoke_types[material]["emit_duration"] = GetInt("savegame.mod.thiccsmoke.material." .. material .. ".emit_duration")
end


--Helper function for UI to configure properties
function property(name, notes, list, key)
	local current = GetString(key)
	if current == "" then
		current = list[1]
	end
	UiTranslate(0, 44)
	UiPush()
		UiFont("bold.ttf", 11)
		UiText(notes)
		UiTranslate(0, 22)
		UiFont("regular.ttf", 22)
		UiText(name)
		UiTranslate(250, 0)
		UiFont("bold.ttf", 22)
		if UiTextButton(current) then
			local new = nil
			for i=1, #list-1 do
				if list[i] == current then
					new = list[i+1]
				end
			end
			if new then
				SetString(key, new)
			else
				SetString(key, list[1])
			end
		end
	UiPop()
end


function ui_float_incre_decrementer(name, key)
	local update = false
	UiTranslate(0,22)
	UiPush()
		local val = GetFloat(key)
		UiTranslate(0, 22)
		UiFont("regular.ttf", 22)
		UiText(name .. ":")
		UiTranslate(250, 0)
		UiText(string.format("%.03f", val))
		UiFont("bold.ttf", 22)
		UiTranslate(99, 0)

		if UiTextButton("-1") then
			val = val - 1
			DebugPrinter("Updating: " .. key .. " with value: " .. string.format("%.03f", val))
			SetFloat(key, val)
			update = true
		end
		UiTranslate(66, 0)
		if UiTextButton("-0.1") then
			val = val - 0.1
			DebugPrinter("Updating: " .. key .. " with value: " .. string.format("%.03f", val))
			SetFloat(key, val)
			update = true
		end
		UiTranslate(66, 0)
		if UiTextButton("-0.01") then
			val = val - 0.01
			DebugPrinter("Updating: " .. key .. " with value: " .. string.format("%.03f", val))
			SetFloat(key, val)
			update = true
		end
		UiTranslate(99, 0)
		if UiTextButton("+1") then
			val = val + 1
			DebugPrinter("Updating: " .. key .. " with value: " .. string.format("%.03f", val))
			SetFloat(key, val)
			update = true
		end
		UiTranslate(66, 0)
		if UiTextButton("+0.1") then
			val = val + 0.1
			DebugPrinter("Updating: " .. key .. " with value: " .. string.format("%.03f", val))
			SetFloat(key, val)
			update = true
		end
		UiTranslate(66, 0)
		if UiTextButton("+0.01") then
			val = val + 0.01
			DebugPrinter("Updating: " .. key .. " with value: " .. string.format("%.03f", val))
			SetFloat(key, val)
			update = true
		end
		-- UiTranslate(-266, 0)
	UiPop()
	return update
end

function ui_int_incre_decrementer(name, key)
	local update = false
	UiTranslate(0,22)
	UiPush()
		local val = GetInt(key)
		UiTranslate(0, 22)
		UiFont("regular.ttf", 22)
		UiText(name .. ":")
		UiTranslate(250, 0)
		UiText(tostring(val))
		UiFont("bold.ttf", 22)
		UiTranslate(99, 0)

		if UiTextButton("-1") then
			val = val - 1
			DebugPrinter("Updating: " .. key .. " with value: " .. tostring(val))
			SetInt(key, val)
			update = true
		end
		UiTranslate(66, 0)
		if UiTextButton("-10") then
			val = val - 10
			DebugPrinter("Updating: " .. key .. " with value: " .. tostring(val))
			SetInt(key, val)
			update = true
		end
		UiTranslate(66, 0)
		if UiTextButton("-100") then
			val = val - 100
			DebugPrinter("Updating: " .. key .. " with value: " .. tostring(val))
			SetInt(key, val)
			update = true
		end

		UiTranslate(99, 0)
		if UiTextButton("+1") then
			val = val + 1
			DebugPrinter("Updating: " .. key .. " with value: " .. tostring(val))
			SetInt(key, val)
			update = true
		end
		UiTranslate(66, 0)
		if UiTextButton("+10") then
			val = val + 10
			DebugPrinter("Updating: " .. key .. " with value: " .. tostring(val))
			SetInt(key, val)
			update = true
		end
		UiTranslate(66, 0)
		if UiTextButton("+100") then
			val = val + 100
			DebugPrinter("Updating: " .. key .. " with value: " .. tostring(val))
			SetInt(key, val)
			update = true
		end
		-- UiTranslate(-266, 0
	UiPop()
	return update
end

function ui_smoke_material_configurator(material)
	UiPush()
		UiTranslate(0,33)
		UiFont("regular.ttf", 22)
		UiText("Color:")
		if ui_float_incre_decrementer("Red", "savegame.mod.thiccsmoke.material." .. material .. ".color.red") then
			update_smoke_types(material, false)
		end
		if ui_float_incre_decrementer("Green", "savegame.mod.thiccsmoke.material." .. material .. ".color.green") then
			update_smoke_types(material, false)
		end
		if ui_float_incre_decrementer("Blue", "savegame.mod.thiccsmoke.material." .. material .. ".color.blue") then
			update_smoke_types(material, false)
		end
		if ui_float_incre_decrementer("Alpha", "savegame.mod.thiccsmoke.material." .. material .. ".color.alpha") then
			update_smoke_types(material, false)
		end
		if ui_float_incre_decrementer("Randomness Alpha", "savegame.mod.thiccsmoke.material." .. material .. ".color.random_alpha") then
			update_smoke_types(material, false)
		end

		UiTranslate(0,66)
		UiFont("regular.ttf", 22)
		UiText("Particle Properties:")
		if ui_int_incre_decrementer("Amount", "savegame.mod.thiccsmoke.material." .. material .. ".amount") then
			update_smoke_types(material, false)
		end
		if ui_int_incre_decrementer("Life", "savegame.mod.thiccsmoke.material." .. material .. ".life") then
			update_smoke_types(material, false)
		end
		if ui_float_incre_decrementer("Radius", "savegame.mod.thiccsmoke.material." .. material .. ".radius") then
			update_smoke_types(material, false)
		end
		if ui_int_incre_decrementer("Gravity", "savegame.mod.thiccsmoke.material." .. material .. ".gravity") then
			update_smoke_types(material, false)
		end
		if ui_int_incre_decrementer("Velocity", "savegame.mod.thiccsmoke.material." .. material .. ".velocity") then
			update_smoke_types(material, false)
		end
		if ui_float_incre_decrementer("Drag", "savegame.mod.thiccsmoke.material." .. material .. ".drag") then
			update_smoke_types(material, false)
		end
		if ui_int_incre_decrementer("Emit Duration", "savegame.mod.thiccsmoke.material." .. material .. ".emit_duration") then
			update_smoke_types(material, false)
		end

		UiTranslate(0,66)
		if UiTextButton("Reset To Default") then
			update_smoke_types(material, true)
		end
	UiPop()
end

function ui_smoke_material()
	local current_i = GetInt("thiccsmoke.material.index")
	local current = "Not Set"
	if current_i == 0 then
		current = smoke_materials[1]
		current_i = 1
		SetInt("thiccsmoke.material.index", current_i)
	end
	current = smoke_materials[current_i]
	UiPush()
		UiTranslate(0, 66)
		UiFont("bold.ttf", 11)
		UiText("Note: Configure particle properties per material.")
		UiTranslate(0, 22)
		UiFont("regular.ttf", 22)
		UiText("Material config:")
		UiTranslate(250, 0)
		UiFont("bold.ttf", 22)
		if UiTextButton(current) then
			if current_i + 1 > table.getn(smoke_materials) then
				current_i = 0
			end
			current = smoke_materials[current_i + 1]
			current_i = current_i + 1
			SetInt("thiccsmoke.material.index", current_i)
		end
		UiTranslate(-200, 0)
		ui_smoke_material_configurator(current)
	UiPop()
end




-- Draw/emit the particle for a given type, body position, velocity and direction (rotation)
function emit_particle(smoke_type, body_pos, body_vel, body_dir)
	local radius = smoke_type["radius"]
	local life = smoke_type["life"]
	local count = smoke_type["amount"]
	local vel = smoke_type["velocity"]
	local drag = smoke_type["drag"]
	local gravity = smoke_type["gravity"]
	local random_alpha = math.random(-1 * smoke_type["random_alpha"], smoke_type["random_alpha"])
	local red = smoke_type["color"]["r"]
	local green = smoke_type["color"]["g"]
	local blue = smoke_type["color"]["b"]
	local alpha = smoke_type["color"]["a"] + random_alpha

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

	local itensity = GetString("savegame.mod.thiccsmoke.intensity")
	if itensity == "Potato PC" then
		radius = radius - 0.5
		if radius > 0.2 then
			radius = 0.2
		end
		if radius < 0 then
			radius  = 0.1
		end
	elseif itensity == "Somewhat Ok" then
		radius = radius - 0.25
		if radius > 0.3 then
			radius = 0.3
		end
		if radius < 0 then
			radius  = 0.1
		end
	elseif itensity == "Realistic" then
		radius = radius - 0.15
		if radius > 0.5 then
			radius = 0.5
		end
		if radius < 0 then
			radius  = 0.1
		end
	elseif itensity == "This is fine (meme)" then
		radius = radius + 0.15
		if radius > 0.8 then
			radius = 0.8
		end
		if radius < 0 then
			radius  = 0.1
		end
	elseif itensity == "Fry my PC" then
		radius = radius + 0.3
		if radius > 0.8 then
			radius = 0.8
		end
		if radius < 0 then
			radius  = 0.1
		end
	end

	local propDrag = GetString("savegame.mod.thiccsmoke.drag")
	if propDrag == "Low" then
		drag = drag - 0.2
		if drag > 0.3 then
			drag = 0.3
		end
		if drag < 0 then
			drag  = 0.1
		end
	elseif propDrag == "Medium" then
		drag = drag - 0.1
		if drag > 0.5 then
			drag = 0.5
		end
		if drag < 0 then
			drag  = 0.1
		end
	elseif propDrag == "High" then
		drag = drag + 0.2
		if drag > 1 then
			drag = 1
		end
		if drag < 0 then
			drag  = 0.1
		end
	end

	local propGravity = GetString("savegame.mod.thiccsmoke.gravity")
	if propGravity == "Downwards Low" then
		gravity = gravity * -1 - 3
		if gravity > -1 then
			gravity = -1
		end
	elseif propGravity == "Downwards High" then
		gravity = gravity * -1 - 6
		if gravity > -1 then
			gravity = -1
		end
	elseif propGravity == "Upwards Low" then
		gravity = gravity * 1 + 3
		if gravity < 1 then
			gravity = 1
		end
	elseif propGravity == "Upwards High" then
		gravity = gravity * 1 + 6
		if gravity < 1 then
			gravity = 1
		end
	end

	local amountMp = GetString("savegame.mod.thiccsmoke.amount")
	if amountMp == "2x" then
		count = count * 2
	elseif amountMp == "4x" then
		count = count * 4
	elseif amountMp == "8x" then
		count = count * 8
	elseif amountMp == "16x" then
		count = count * 16
	end

	local lifetimeMp = GetString("savegame.mod.thiccsmoke.lifetime")
	if lifetimeMp == "2x" then
		life = life * 2
	elseif lifetimeMp == "4x" then
		life = life * 4
	elseif lifetimeMp == "8x" then
		life = life * 8
	elseif lifetimeMp == "16x" then
		life = life * 16
	end


	--Set up the particle state
	-- ParticleReset()
	ParticleType("smoke")
	ParticleRadius(radius)
	ParticleAlpha(alpha, alpha, "constant", 0.1/life, 0.5)	-- Ramp up fast, ramp down after 50%
	ParticleGravity(gravity * rnd(0.5, 1.5))				-- Slightly randomized gravity looks better
	ParticleDrag(drag)
	ParticleColor(red, green, blue, 0.9, 0.9, 0.9)			-- Animating color towards white

	--Emit particles
	for i=1, count do
		--Randomize velocity slightly
		-- local v = VecAdd(body_dir, rndVec(vel / 100))
		local v = VecScale(VecAdd(body_dir, rndVec(0.002)), vel)

		--Include some of the movement of the attachment body
		-- v = VecAdd(v,  vel / 10000)

		--Randomize lifetime
		local l = rnd(life*0.5, life*1.5)

		--Spawn particle into the world
		-- body_pos[1] = body_pos[1] * -1
		local p = VecAdd(body_pos, rndVec(radius / 10))
		SpawnParticle(p, VecNormalize(v), l)
	end
end

function init()
	ui = false
	-- edit below if you want to add different materials or change color
	for i=1, #smoke_materials do
		update_smoke_types(smoke_materials[i], false)
	end
	DebugPrinter("Finished updating materials")
	if GetInt("savegame.mod.thiccsmoke.temporary_disable.time") == 0 then
		SetInt("savegame.mod.thiccsmoke.temporary_disable.time", 2)
	end
end


--Main tick function handles tool logic
function tick(dt)
	local enabled = GetString("savegame.mod.thiccsmoke.enabled")
	if InputPressed("lmb") and GetString("savegame.mod.thiccsmoke.temporary_disable") == "ON" then
		temp_disabled = true
		temp_disabled_last_time = 0
		temp_disabled_timer = 0
		DebugPrinter("Entering timeout, no particles will be emitted!")
	end

	local temp_disable_timer_timeout =  GetInt("savegame.mod.thiccsmoke.temporary_disable.time")
	if temp_disabled_timer - temp_disabled_last_time > temp_disable_timer_timeout then
		temp_disabled = false
		temp_disabled_timer = 0
		DebugPrinter("Enabled after timeout")
	end

	if temp_disabled_clear_timer - temp_disabled_clear_last_time > temp_disabled_clear_timout then
		temp_disabled_clear_timer = 0
		clear_emitter_during_disabled()
		DebugPrinter("Clearing emitter during disabled list")
	end

	if temp_disabled then
		temp_disabled_timer = temp_disabled_timer + dt
		DebugPrinter("Disabled temp_disabled_timer: " .. tostring(temp_disabled_timer))
	else
		temp_disabled_clear_timer = temp_disabled_clear_timer + dt
	end

	if enabled == "ON" then
		local shape_list = FindShapes("", true)
		for i=1, #shape_list do
			local shape_found = shape_list[i]
			if IsShapeBroken(shape_found) then
				local shape_tf = GetShapeWorldTransform(shape_found)
				local shape_mat = GetShapeMaterialAtPosition(shape_found, shape_tf.pos)
				local shape_bod = GetShapeBody(shape_found)
				if IsBodyDynamic(shape_bod) and IsBodyActive(shape_bod) and shape_mat ~= "" then
					local shape_bod_tf = GetBodyTransform(shape_bod)
					local shape_bod_vel = GetBodyVelocityAtPos(shape_bod, shape_bod_tf.pos)
					DebugPrinter("Found a broken shape of material: " .. shape_mat .. "!")
					if smoke_types[shape_mat] then
						local to_emit = {
							id=shape_found,
							emit_duration=smoke_types[shape_mat]["emit_duration"],
							smoke_type=smoke_types[shape_mat],
							pos=shape_tf.pos,
							vel=shape_bod_vel,
							rot=TransformToParentVec(shape_bod_tf,TransformToLocalVec(shape_bod_tf, VecNormalize(shape_bod_tf.rot)))
						}
						if temp_disabled then
							if push_emitter_during_disabled(to_emit) then
								DebugPrinter("Successfully pushed emitter to disabled list: " .. shape_found)
							else
								DebugPrinter("Emitter already pushed to disabled list: " .. shape_found)
							end
						else
							if push_emitter(to_emit) then
								DebugPrinter("Successfully pushed emitter: " .. shape_found)
							else
								DebugPrinter("Emitter already pushed: " .. shape_found)
							end
						end
					end
				end
			end
		end
	end
end


--Update function handles smoke emission
	--It is important to put it in update and not tick for constant emission rate
function update(dt)
	local emit = get_emitter()
	if emit ~= nil then
		if emit["smoke_type"] ~= nil then
			emit_particle(emit["smoke_type"], emit["pos"], emit["vel"], emit["rot"])
		end
	end
end


--Configuration UI
function draw()
	UiFont("regular.ttf", 22)
	UiTextShadow(0, 0, 0, 0.5, 0.5)
	if not uix then uix = UiWidth() - 200 end
	if not uiy then uiy = 50 end

	UiTranslate(uix, uiy)

	if InputPressed("u") then
		ui = not ui
		if ui then
			SetValue("uix", UiCenter()-400, "cosine", 0.25)
			SetValue("uiy", UiMiddle()-400, "cosine", 0.25)
		else
			SetValue("uix", UiWidth()-200, "cosine", 0.25)
			SetValue("uiy", 50, "cosine", 0.25)
		end
		ClearDebugPrinter()
	end

	if InputPressed("y") then
		local enabled = GetString("savegame.mod.thiccsmoke.enabled")
		if enabled == "ON" then
			SetString("savegame.mod.thiccsmoke.enabled", "OFF")
		else
			SetString("savegame.mod.thiccsmoke.enabled", "ON")
		end
		ClearDebugPrinter()
	end


	if ui then
		UiMakeInteractive()
		UiText("Press U to hide")
		UiTranslate(0, 8)
		property("Disable on click", "Note: Disables the mod temporarily when user performs a action with tools.", {"ON", "OFF"}, "savegame.mod.thiccsmoke.temporary_disable")
		ui_int_incre_decrementer("Disable Time", "savegame.mod.thiccsmoke.temporary_disable.time")
		property("Gravity", "Note: Applies offset to gravity on all materials.", {"Use Material Property", "Upwards Low", "Upwards High", "Downwards Low", "Downwards High"}, "savegame.mod.thiccsmoke.gravity")
		property("Drag", "Note: Applies offset to drag on all materials.", {"Use Material Property", "Low", "Medium", "High", }, "savegame.mod.thiccsmoke.drag")
		property("Intensity", "Note: Applies offset to radius on all materials.", {"Use Material Property", "Potato PC", "Somewhat Ok", "Realistic", "This is fine (meme)", "Fry my PC" }, "savegame.mod.thiccsmoke.intensity")
		property("Amount Multiplier", "Note multiplies amount across all materials.", {"1x", "2x", "4x", "8x", "16x" }, "savegame.mod.thiccsmoke.amount")
		property("Particle Lifetime Multiplier", "Note multiplies lifetime across all materials.", {"1x", "2x", "4x", "8x", "16x" }, "savegame.mod.thiccsmoke.lifetime")
		property("Debug", "Note: if a problem occurs, make screenshot with this on!", {"ON", "OFF"}, "savegame.mod.thiccsmoke.debug")
		property("Enabled", "Note: Disables or enables the mod.", {"ON", "OFF"}, "savegame.mod.thiccsmoke.enabled")
		ui_smoke_material()
	else
		local enabled = GetString("savegame.mod.thiccsmoke.enabled")
		UiTranslate(-250, 0)
		UiText("Press U to configure ThiccSmoke")
		if enabled == "ON" then
			UiTranslate(0, 22)
			UiText("Press Y to toggle ThiccSmoke [ENABLED]")
		else
			UiTranslate(0, 22)
			UiText("Press Y to toggle ThiccSmoke [DISABLED]")
		end
	end
end