-- firedetector.lua
-- @date 2021-09-06
-- @author Eldin Zenderink
-- @brief In here logic to detect an fire is put here, due to the limitations of the api where no actual fire can be detected,
--        we have to use some hacky workaround, by detecting broken blocks, the changing mass, etc.
--        Also handles user interaction, we dont want smoke on every action unless desired.
-- @note (to self) I need to rewrite all of this again and use some proper "class" like functions ;p

local FireDetector_Default = {
    enabled_preset="Default",
    user_input_disable="YES",
    user_input_disable_timer=3,
    user_radius=200,
    max_mass_detection=100,
    max_fire_detection_time=6,
    max_distance_detection=8,
    max_fire_on_body=90,
    visualize_fire_detection="OFF"
}

local FireDetector_Properties = {
    enabled_preset="Default",
    user_input_disable="YES",
    user_input_disable_timer=2,
    user_radius=200,
    max_mass_detection=100,
    max_fire_detection_time=3,
    max_distance_detection=1,
    max_fire_on_body=90,
    visualize_fire_detection="OFF"
}

--- Some global properties
local FireDetector_LocalDB = {
    time_elapsed = 0,
    fire_count=0,
    enabled=true,
    enabled_previous=true
}

-- Store all bodies that could potentially be detached from bodies on fire (BPOF = bodies potentially on fire)
local FireDetector_SPOF = {}


local FireDetector_Options =
{
	storage_module="firedetector",
	storage_prefix_key=nil,
	default=function() FireDetector_DefaultSettings() end,
	update=function() FireDetector_ApplyCustomSettings() end,
	option_items={
		{
			option_parent_text="",
			option_text="User Input Disable",
			option_note="Disables the mod on user action (hitting, etc.)",
            option_type="text",
			storage_key="user_input_disable",
			options={
				"YES",
				"NO"
			}
		},
        {
            option_parent_text="",
            option_text="User Input Disable Timer (Seconds)",
            option_note="How long the mod should be disabled after user performed an action.",
            option_type="int",
            storage_key="user_input_disable_timer",
            min_max={1, 30}
        },
        {
            option_parent_text="",
            option_text="User Fire Detection Radius",
            option_note="The size of the area around the player that fires can be detected in.",
            option_type="int",
            storage_key="user_radius",
            min_max={1, 400}
        },
        {
            option_parent_text="",
            option_text="Max Fire Detection Timer",
            option_note="The object is not always on fire.",
            option_type="int",
            storage_key="max_fire_detection_time",
            min_max={1, 100}
        },
        {
            option_parent_text="",
            option_text="Max Body Distance Detection",
            option_note="The broken body's distance to search for the nearest object when it becomes dynamic",
            option_type="int",
            storage_key="max_distance_detection",
            min_max={1, 100}
        },
        {
            option_parent_text="",
            option_text="Max Fire On Body (%)",
            option_note="How much % of the total fire can be detected on a single body (used to determine intensity).",
            option_type="int",
            storage_key="max_fire_on_body",
            min_max={1, 100}
        },
        {
            option_parent_text="",
            option_text="Max Debris Mass Detection",
            option_note="Debris caused by fire has most often a tiny mass. Debris is used to detect the actual fire!",
            option_type="int",
            storage_key="max_mass_detection",
            min_max={1, 1000}
        },
		{
			option_parent_text="",
			option_text="Visualize fire detection",
			option_note="Shows a cross where the mod thinks there is fire and where it spawns a particle",
            option_type="text",
			storage_key="visualize_fire_detection",
			options={
				"ON",
				"OFF"
			}
		}
	}
}

local FireDetector_Preset_Options =
{
	storage_module="firedetector",
	storage_prefix_key=nil,
	default=function() Particle_DefaultPresetSettings() end,
	update=function() Particle_UpdatePresetSettings() end,
	option_items={
		{
			option_parent_text="",
			option_text="Preset",
			option_note="Use pre-configured settings by developer. Setting a preset other than Custom will override your Custom settings!.",
			option_type="text",
			storage_key="enabled_preset",
			options={
                "Default",
				"Potato PC",
				"Somewhat Ok",
				"Realistic",
				"This is fine (meme)",
				"Fry my PC",
                "Custom"
			}
		},
		{
			option_parent_text="",
			option_text="Visualize fire detection",
			option_note="Shows a cross where the mod thinks there is fire and where it spawns a particle",
            option_type="text",
			storage_key="visualize_fire_detection",
			options={
				"ON",
				"OFF"
			}
		}
	}
}

function Particle_DefaultPresetSettings()
    Storage_SetString("firedetector", "enabled_preset", FireDetector_Default["enabled_preset"])
    FireDetector_Properties["enabled_preset"] = FireDetector_Default["enabled_preset"]
    FireDetector_DefaultSettings()
end

function Particle_UpdatePresetSettings()
    local enabled_preset = Storage_GetString("firedetector", "enabled_preset")

    if enabled_preset == "Default" then
        FireDetector_ApplySettings(
            FireDetector_Default["user_input_disable"],
            FireDetector_Default["user_input_disable_timer"],
            FireDetector_Default["user_radius"],
            FireDetector_Default["max_mass_detection"],
            FireDetector_Default["max_fire_detection_time"],
            FireDetector_Default["max_distance_detection"],
            FireDetector_Default["max_fire_on_body"]
        )
    elseif enabled_preset == "Potato PC" then
        FireDetector_ApplySettings(
            "YES",
            2,
            100,
            100,
            3,
            5,
            90
        )
    elseif enabled_preset == "Somewhat Ok" then
        FireDetector_ApplySettings(
            "YES",
            2,
            200,
            100,
            3,
            2,
            90
        )
    elseif enabled_preset == "Realistic" then
        FireDetector_ApplySettings(
            "YES",
            2,
            300,
            100,
            3,
            2,
            90
        )
    elseif enabled_preset == "This is fine (meme)" then
        FireDetector_ApplySettings(
            "YES",
            2,
            400,
            100,
            3,
            2,
            90
        )
    elseif enabled_preset == "Fry my PC" then
        FireDetector_ApplySettings(
            "YES",
            2,
            800,
            100,
            3,
            2,
            90
        )
    end
    FireDetector_UpdateSettingsFromStorage()
end


---Initialize the properties of the module
---@param default bool -- set to true to set all properties to their default configured values
function FireDetector_Init(default)
	if default then
		FireDetector_DefaultSettings()
	else
		Particle_UpdatePresetSettings()
	end
    FireDetector_LocalDB["time_elapsed"] = 0
    FireDetector_LocalDB["time_input_disabled_elapsed"] = 0
    FireDetector_LocalDB["fire_count"] = 0
end

---Provide a table to build a option menu for this module
---@return table
function FireDetector_GetOptionsMenu()
	return {
		menu_title = "Fire Detection Settings",
		sub_menus={

			{
				sub_menu_title="Fire Detection Presets",
				options=FireDetector_Preset_Options,
			},
			{
				sub_menu_title="Fire Detection Options",
				options=FireDetector_Options,
			}
		}
	}
end

--- Apply settings in the module, used for enabled_presets, note that it is possible to store
--- them by supplying store = true, however it is best practice to store them in the registers
--- then apply them from the registers, to not lose those settings.
---@param store boolean -- Store to registers
---@param user_input_disable any
---@param user_input_disable_timer any
---@param max_mass_detection any
---@param max_fire_detection_time any
---@param max_distance_detection any
---@param max_fire_on_body any

function FireDetector_ApplySettings(
    user_input_disable,
    user_input_disable_timer,
    user_radius,
    max_mass_detection,
    max_fire_detection_time,
    max_distance_detection,
    max_fire_on_body
)
    Storage_SetString("firedetector", "user_input_disable", user_input_disable)
    Storage_SetInt("firedetector", "user_input_disable_timer", user_input_disable_timer)
    Storage_SetInt("firedetector", "user_radius", user_radius)
    Storage_SetInt("firedetector", "max_mass_detection", max_mass_detection)
    Storage_SetInt("firedetector", "max_fire_detection_time", max_fire_detection_time)
    Storage_SetInt("firedetector", "max_distance_detection", max_distance_detection)
    Storage_SetInt("firedetector", "max_fire_on_body", max_fire_on_body)
end

---Retrieve properties from storage and apply them
function FireDetector_ApplyCustomSettings()
    Storage_SetString("firedetector", "enabled_preset", "Custom")
    FireDetector_UpdateSettingsFromStorage()
end


---Store and apply default properties.
function FireDetector_DefaultSettings()
    Storage_SetString("firedetector", "enabled_preset", FireDetector_Default["enabled_preset"])
    Storage_SetString("firedetector", "user_input_disable", FireDetector_Default["user_input_disable"])
	Storage_SetInt("firedetector", "user_input_disable_timer", FireDetector_Default["user_input_disable_timer"])
	Storage_SetInt("firedetector", "user_radius", FireDetector_Default["user_radius"])
	Storage_SetInt("firedetector", "max_mass_detection", FireDetector_Default["max_mass_detection"])
	Storage_SetInt("firedetector", "max_fire_detection_time", FireDetector_Default["max_fire_detection_time"])
    Storage_SetInt("firedetector", "max_distance_detection", FireDetector_Default["max_distance_detection"])
    Storage_SetInt("firedetector", "max_fire_on_body", FireDetector_Default["max_fire_on_body"])
    Storage_SetString("firedetector", "visualize_fire_detection", FireDetector_Default["visualize_fire_detection"])

    FireDetector_UpdateSettingsFromStorage()
end

---Retrieve properties from storage and apply them
function FireDetector_UpdateSettingsFromStorage()
	FireDetector_Properties["user_input_disable"] = Storage_GetString("firedetector", "user_input_disable")
	FireDetector_Properties["user_input_disable_timer"] = Storage_GetInt("firedetector", "user_input_disable_timer")
	FireDetector_Properties["user_radius"] = Storage_GetInt("firedetector", "user_radius")
	FireDetector_Properties["max_mass_detection"] = Storage_GetInt("firedetector", "max_mass_detection")
    FireDetector_Properties["max_fire_detection_time"] = Storage_GetInt("firedetector", "max_fire_detection_time")
    FireDetector_Properties["max_distance_detection"] = Storage_GetInt("firedetector", "max_distance_detection")
    FireDetector_Properties["max_fire_on_body"] = Storage_GetInt("firedetector", "max_fire_on_body")
    FireDetector_Properties["visualize_fire_detection"] = Storage_GetString("firedetector", "visualize_fire_detection")

end

---Determine if fire detection should happen when a mouse button is pressed
---@param time number -- A timestamp to keep track of how long the detection should be disabled
---@return boolean -- Returns true if it should be disabled, false if it should be enabled
function FireDetector_Enabled(time)
    if FireDetector_Properties["user_input_disable"] == "YES" then
        if FireDetector_LocalDB["time_input_disabled_elapsed"] == nil then
            FireDetector_LocalDB["time_input_disabled_elapsed"] = 0
        end
        if FireDetector_LocalDB["human_input_disabled"] == nil then
            FireDetector_LocalDB["human_input_disabled"] = false
        end

        -- Disable during mouse action, and start timer after all actions with the mouse are finished
        -- Reset the counter if the mouse action happens again within the timer
        if InputDown("lmb") or InputDown("rmb") then
            if FireDetector_LocalDB["human_input_disabled"] then
                FireDetector_LocalDB["time_input_disabled_elapsed"] = 0
            else
                FireDetector_LocalDB["human_input_disabled"] = true
            end
        end

        if FireDetector_LocalDB["human_input_disabled"] then
            if FireDetector_LocalDB["time_input_disabled_elapsed"] > FireDetector_Properties["user_input_disable_timer"] then
                FireDetector_LocalDB["time_input_disabled_elapsed"] = 0
                FireDetector_LocalDB["human_input_disabled"] = false
            end
            FireDetector_LocalDB["time_input_disabled_elapsed"] = FireDetector_LocalDB["time_input_disabled_elapsed"] + time
        end

        if GeneralOptions_GetEnabled() == "YES" then
            if FireDetector_LocalDB["enabled_previous"] == false then
                FireDetector_LocalDB["enabled_previous"] = true
                FireDetector_LocalDB["human_input_disabled"] = false
                return true
            end
            return not FireDetector_LocalDB["human_input_disabled"]
        end
        if GeneralOptions_GetEnabled() == "NO" then
            FireDetector_LocalDB["enabled_previous"] = false
            return false
        else
            FireDetector_LocalDB["enabled_previous"] = true
            return true
        end
    else

        if GeneralOptions_GetEnabled() == "NO" then
            FireDetector_LocalDB["enabled_previous"] = false
            return false
        else
            FireDetector_LocalDB["enabled_previous"] = true
            return true
        end
    end
end

---Calculate the a voxels shape's center by bounds
---@param body number -- the shapes id
---@return any -- Vec  with the point location of the center of the body
function FireDetector_ShapeCenter(shape)
    local min, max = GetShapeBounds(shape)
    return VecLerp(min, max, 0.5)
end

---Calculate the a voxels body's center by bounds
---@param body number -- the bodies id
---@return any -- Vec  with the point location of the center of the body
function FireDetector_BodyCenter(shape)
    local min, max = GetBodyBounds(shape)
    return VecLerp(min, max, 0.5)
end


function FireDetector_DrawPoint(point, r, g, b)
    if FireDetector_Properties["visualize_fire_detection"] == "ON" then
        DebugCross(point,  r, g, b)
    end
end

function FireDetector_CompareVec(a, b)
    local sub = VecSub(a, b)
    if sub[1] == 0 and sub[2] == 0 and sub[3] == 0 then
        return true
    end
    return false
end

---This function should be called in the tick(), it generates a list locations where
---assumed there is fire. This is done based on the following logic
--- 1. Query all dynamic physical small shapes: fire is most likely causing debris of small chunks to appear
--- 1.1 Store all shapes determined to be broken in a global list, together with a time stamp, however chunks are normally not the actual shape on fire.
---
--- 2. (note this step happens before 1.), For every shape in that list, determine if timestamp is within the timeout window (to prevent forever detection)
--- 3. Check if the shape is determined to be on fire or not.
---- 3.1 if in window but not on fire, do a closest point determination (query), this object IS highly likely on fire
---- 3.2 if in window and on fire, verify if the position detected to be on fire is still a valid voxel (using checkmaterial at position, empty == it does not exist)
---- 3.2.1 If the voxel is valid append the shape to a list to be returned
---- 3.2.2 If the voxel is not valid, then disable the fire step and go back to 3 (which will reevaluate the next best fire location)
---
--- Note that storing the objects found in 1. is necessary because QueryAabbShapes of "dynamic small physical" only seems to return
--- shapes that are actually visible/ infront the player/screen space, (ofcourse shapes behind other shapes as well),
--- If this was not stored globally, and the player looks away, it is no longer detected.
---@param timestamp number
---@return table
local FireDetector_SOF = {}
function FireDetector_FindFireLocations(time, max_fires)

    local random_query = {
        "large",
        "large",
        "large",
        "dynamic",
        "dynamic",
        "static",
        "static",
        "static",
        "static",
        "small"
    }

    local broken_materials = {}
    local currentSPOF = FireDetector_SPOF
    local currentSOF = FireDetector_SOF

    local time_elapsed = FireDetector_LocalDB["time_elapsed"]
    local fire_count = 0

    local max_fire_detection_time = FireDetector_Properties["max_fire_detection_time"]
    local max_fire_on_body = max_fires - (max_fires / 100 * FireDetector_Properties["max_fire_on_body"])
    local max_distance_detection = FireDetector_Properties["max_distance_detection"]
    local enabled = FireDetector_Enabled(time)

    -- If there is room for more fires to be detected, query new shapes
    local new_shapes = false
    if fire_count <= max_fires  then
        local player_t = GetPlayerTransform()
        QueryRequire("physical dynamic small")
        local user_radius = FireDetector_Properties["user_radius"] / 2
        local shape_list = QueryAabbShapes(VecSub(player_t.pos, {user_radius,user_radius,user_radius}), VecAdd(player_t.pos,{user_radius,user_radius,user_radius}))
        for i=1, #shape_list do
            local shape = shape_list[i]
            local body = GetShapeBody(shape)
            if IsShapeBroken(shape) then
                if currentSPOF[body] == nil then
                    local mass = GetShapeVoxelCount(shape)
                    if mass < FireDetector_Properties["max_mass_detection"]  then
                        local center = FireDetector_BodyCenter(body)
                        currentSPOF[body] = {shape=shape, parent_body=body, location=center, timestamp=time_elapsed, fire=true, fire_detected=false, material=nil, verified_timestamp=time_elapsed, enabled=FireDetector_LocalDB["enabled"], fire_on_body=1}
                    end
                end
            end
        end
    end

    -- Store the shape that is on fire, store the ammount it has been detected
    -- This is to prevent to many points detected on the same shape, but can also be used to
    -- determine the intensity of the smoke spawning, many detections =  more smoke?
    for body, properties in pairs(currentSPOF) do
        local shape = properties["shape"]
        local shape_timed_out = false
        if (time_elapsed - properties["timestamp"]) > max_fire_detection_time then
            shape_timed_out = true
        end


        if properties["enabled"] == false then
            FireDetector_DrawPoint(properties["location"],1,0,1)
            properties["fire"] = false
        elseif properties["fire"] and properties["fire_detected"] == false and shape_timed_out then
            properties["fire"] = not FireDetector_LocalDB["enabled"]
            properties["fire_detected"] = false
        elseif properties["fire"] and properties["fire_detected"] then
            local shape_mat = GetShapeMaterialAtPosition(shape, properties["location"])
            if shape_mat ~= "" then
                if shape_timed_out then
                    if enabled then
                        properties["fire"] = false
                    else
                        properties["timestamp"] = time_elapsed
                        properties["fire_detected"] = false
                    end
                else
                    FireDetector_DrawPoint(properties["location"], 0,0,1)
                    fire_count =  fire_count + 1
                    broken_materials[body] = properties
                end
            else
                if shape_timed_out then
                    if enabled then
                        properties["fire"] = false
                    else
                        properties["timestamp"] = time_elapsed
                        properties["fire_detected"] = false
                    end
                else
                    FireDetector_DrawPoint(properties["location"], 1,0,0)
                    fire_count =  fire_count + 1
                    broken_materials[body] = properties
                end
            end
        elseif properties["fire"] and properties["fire_detected"] == false then

            if shape_timed_out  then
                if enabled then
                    properties["fire"] = false
                else
                    properties["timestamp"] = time_elapsed
                    properties["fire_detected"] = false
                end
            else

                if enabled then
                    QueryRequire(random_query[Generic_rnd(1, #random_query)])
                    --QueryRequire(random_query[4])
                else
                    QueryRequire(random_query[4])
                end

                -- Make sure it cant find it's own shape
                QueryRejectShape(properties["shape"])
                QueryRejectBody(body)

                -- Find closest voxel point where the shape originate from. (dynamic means it broke from an object)
                local hit, point, normal, shape_hit = QueryClosestPoint(properties["location"], max_distance_detection)
                if hit then
                    -- Determine the material at this point
                    local shape_mat = GetShapeMaterialAtPosition(shape_hit, point)
                    -- Store the shape_hit that is actually on fire
                    local shape_bod = GetShapeBody(shape_hit)
                    if currentSOF[shape_bod] == nil or currentSOF[shape_bod] <= max_fire_on_body then
                        if fire_count <= max_fires then
                            if currentSOF[shape_bod] == nil then
                                currentSOF[shape_bod] = 0
                            end
                            if currentSOF[properties["parent_body"]] ~= nil then
                                currentSOF[properties["parent_body"]] = currentSOF[properties["parent_body"]] - 1
                            end
                            currentSOF[shape_bod] = currentSOF[shape_bod] + 1
                            properties["fire_on_body"] = currentSOF[shape_bod]
                            properties["material"] = shape_mat
                            properties["parent_body"] = shape_bod
                            properties["location"] = point
                            properties["shape"] = shape_hit
                            properties["fire_detected"] = true
                            FireDetector_DrawPoint(properties["location"], 0,1,0)
                            fire_count = fire_count + 1
                            broken_materials[body] = properties
                        end
                    end
                end
            end
        elseif properties["fire"] == false and properties["fire_detected"]  == false then
            properties = nil
        end

        -- Limit the amount of fires detected
        if  fire_count > max_fires then
            break
        end
    end

    -- Update gloabl storage
    FireDetector_SPOF = currentSPOF
    FireDetector_LocalDB["fire_count"] = fire_count
    FireDetector_LocalDB["enabled"] = enabled
    --- Count the time
    time_elapsed = time_elapsed + time
    FireDetector_LocalDB["time_elapsed"] = time_elapsed
    return {broken_materials, FireDetector_LocalDB["fire_count"], max_fire_on_body}
end


---Use this in the draw function!
function FireDetector_ShowStatus()
    if GeneralOptions_GetShowUiInGame() == "YES" then
        DebugWatch("FireDetector, Fire count:", FireDetector_LocalDB["fire_count"])
        DebugWatch("FireDetector, enabled:", tostring(FireDetector_LocalDB["enabled"]))
    end
end

