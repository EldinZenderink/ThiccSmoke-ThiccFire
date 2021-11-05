-- settings.lua
-- @date 2021-10-30
-- @author Eldin Zenderink
-- @brief This module should provide a centralized system for maintaining and grouping settings, to allow for easier adjustments, restore funcitonalities etc.
--        Every module will have their properties  stored and accessed from here. Menus will also be generated from here. Presets will be created in separated modules based on this module. Catagorizing settings will be done through here.

local Settings_Template = {
    GeneralOptions = {
        toggle_menu_key="U",
        ui_in_game="NO",
        debug="NO",
        enabled="YES"
    },
    FireDetector = {
        max_fire_spread_distance=6,
        fire_reaction_time=2,
        fire_update_time=1,
        min_fire_distance=2,
        max_group_fire_distance=4,
        max_fire=150,
        fire_intensity="ON",
        fire_intensity_multiplier=1,
        fire_intensity_minimum=1,
        visualize_fire_detection="OFF",
        fire_explosion = "NO",
        fire_damage = "YES",
        spawn_fire = "YES",
        fire_damage_soft = 0.1,
        fire_damage_medium = 0.05,
        fire_damage_hard = 0.01,
        teardown_max_fires = 500,
        teardown_fire_spread = 2,
        material_allowed = {
            wood = true,
            foliage = true,
            plaster = true,
            plastic = true,
            masonery = true,
        }
    },
    ParticleSpawner={
        dynamic_fps = "ON",
        dynamic_fps_target = 48,
        particle_refresh_max = 60,
        particle_refresh_min = 24,
        aggressivenes = 1,
    },
    Particle = {
        fire = "YES",
        smoke = "YES",
        fire_to_smoke_ratio = "1:1",
        spawn_light = "ON",
        intensity = "Use Material Property",
        drag = "Use Material Property",
        gravity = "Use Material Property",
        lifetime = "1x",
        fireIntensityScale = 1,
        smokeFadeIn = 0,
        smokeFadeOut = 10,
        fireFadeIn = 35,
        fireFadeOut = 20,
        fireEmissive = 4,
        embers = "LOW"
    },
    FireMaterial = {
        wood={
            color={r=1.0, g=0.6, b=0.5, a=1},
            lifetime=2,
            size=0.7,
            gravity=2,
            speed=0.1,
            drag=0.2,
            variation=0.4,
        },
        foliage={
            color={r=1.0, g=0.6, b=0.5, a=1},
            lifetime=2,
            size=0.7,
            gravity=2,
            speed=0.1,
            drag=0.2,
            variation=0.4,
        },
        plaster={
            color={r=1.0, g=0.6, b=0.5, a=1},
            lifetime=2,
            size=0.7,
            gravity=2,
            speed=0.1,
            drag=0.2,
            variation=0.4,
        },
        plastic={
            color={r=1.0, g=0.6, b=0.5, a=1},
            lifetime=2,
            size=0.7,
            gravity=2,
            speed=0.1,
            drag=0.2,
            variation=0.4,
        },
        masonery={
            color={r=1.0, g=0.6, b=0.5, a=1},
            lifetime=2,
            size=0.7,
            gravity=2,
            speed=0.1,
            drag=0.2,
            variation=0.4,
        }
    },
    SmokeMaterial = {
        wood={
            color={r=0.15,g=0.15,b=0.15,a=0.8},
            lifetime=8,
            size=1,
            gravity=3,
            speed=2.5,
            drag=0.4,
            variation=1,
        },
        foliage={
            color={r=0.3,g=0.31,b=0.3,a=0.8},
            lifetime=8,
            size=1,
            gravity=2,
            speed=1.5,
            drag=0.7,
            variation=0.8,
        },
        plaster={
            color={r=0.2,g=0.2,b=0.22,a=0.8},
            lifetime=8,
            size=1,
            gravity=2,
            speed=1,
            drag=0.9,
            variation=0.4,
        },
        plastic={
            color={r=0.1,g=0.1,b=0.12,a=0.8},
            lifetime=8,
            size=1,
            gravity=1,
            speed=0.5,
            drag=1,
            variation=0.1,
        },
        masonery={
            color={r=0.4,g=0.4,b=0.4,a=0.8},
            lifetime=8,
            size=1,
            gravity=2,
            speed=2,
            drag=0.6,
            variation=0.3,
        },
    }
}

local _LoadedSettings = {}

function Settings_Init(default)
    local active_preset = Storage_GetString("settings", "active_preset")
    if default or active_preset == "" then
        Settings_SetDefault()
    else
        Settings_LoadActivePreset()
    end
end

function Settings_SetDefault()
    Settings_SetValuesRecursive("default", Settings_Template)
    Storage_SetString("settings", "active_preset", "default")
    Storage_SetString("settings", "presets", "default")
    Settings_LoadActivePreset()
end

-- Settings load and store
function Settings_SetValuesRecursive(category, table)
    for key, value in pairs(table) do
        if type(value) == "table" then
            Settings_SetValuesRecursive(category .. "." .. key, value)
        else
            if type(value) == "string" then
                Storage_SetString("settings", category .. "." .. key, value)
            end
            if type(value) == "number" then
                Storage_SetFloat("settings", category .. "." .. key, value)
            end
            if type(value) == "boolean" then
                Storage_SetBool("settings", category .. "." .. key, value)
            end
        end
    end
end

function Settings_GetValuesRecursive(preset, table)
    for key, value in pairs(table) do
        if type(value) == "table" then
            Settings_GetValuesRecursive(preset .. "." .. key, value)
        else
            local table_to_store = _LoadedSettings
            if type(preset) == "table" then
                for i=1, #preset do
                    if table_to_store[preset[i]] == nil then
                        DebugPrint("Trying to store to key: " .. preset[i])
                        table_to_store[preset[i]] = {}
                    else
                        table_to_store = table_to_store[preset[i]]
                    end
                end
            else
                if type(value) == "string" then
                    table_to_store[key] = Storage_GetString("settings", preset .. "." .. key)
                end
                if type(value) == "number" then
                    table_to_store[key] = Storage_GetFloat("settings", preset .. "." .. key)
                end
                if type(value) == "boolean" then
                    table_to_store[key] = Storage_GetBool("settings", preset .. "." .. key)
                end
            end
        end
    end
end

function Settings_GetValue(module, keys)
    if string.find(keys, ".") then
        local keys = Generic_SplitString(keys, ".")
        local value = _LoadedSettings[module]
        for i=1, #keys do
            module = module[keys[i]]
        end
        return value
    else
        return _LoadedSettings[module][keys]
    end
end

-- Preset related functions
function Settings_GetPresets()
    local presets = Storage_GetString("settings", "presets")
    return Generic_SplitString(presets, ',')
end

function Settings_AddPreset(preset)
    local presets = Storage_GetString("settings", "presets")

    DebugPrint("(Adding) Current presets : " .. presets )
    if presets == "" then
        presets = preset
    else
        presets = presets .. "," ..preset
    end
    DebugPrint("(Adding) New presets : " .. presets)
    Storage_SetString("settings", "presets", presets)
end

function Settings_DeletePreset(preset)
    local presets = Settings_GetPresets()
    local new_presets = ""
    for i = 1, #presets do
        if presets[i] ~= preset then
            if new_presets == "" then
                new_presets = presets[i]
            else
                new_presets = new_presets .. "," .. presets[i]
            end
        end
    end
    Storage_SetString("settings", "presets", new_presets)
end

function Settings_PresetExists(preset)
    local presets = Storage_GetString("settings", "presets")
    local preset_list = Generic_SplitString(presets, ',')

    if Generic_TableContains(preset_list, preset) then
        return true
    end

    return false
end

function Settings_CreatePreset()
    local preset = Storage_GetString("settings", "new_preset")
    DebugPrint("Creating new preset: " .. preset)
    if Settings_PresetExists(preset) then
        DebugPrint("Preset: " .. preset .. " already exists")
        return false
    else
        Settings_AddPreset(preset)
        Settings_SetValuesRecursive(preset, Settings_Template)
        Storage_SetString("settings", "active_preset", preset)
        Settings_LoadActivePreset()
    end
end

function Settings_LoadActivePreset()
    _LoadedSettings = {}
    local preset = Storage_GetString("settings", "active_preset")
    DebugPrint(" Loading Active Preset: " .. preset)
    Settings_GetValuesRecursive(preset, Settings_Template)
end

function Settings_DeleteActivePreset()
    local preset = Storage_GetString("settings", "active_preset")
    Settings_DeletePreset(preset)
    local presets = Settings_GetPresets()
    Storage_SetString("settings", "active_preset", presets[#presets])
    Settings_LoadActivePreset()
end



--- Generate option  menus


local Preset_Options =
{
	storage_module="settings",
	storage_prefix_key=nil,
	buttons={
		{
			text = "Clear All Presets",
			callback=function() Settings_SetDefault() end,
		},
		{
			text = "Create Preset",
			callback=function() Settings_CreatePreset() end,
		},
		{
			text = "Delete Active Preset",
			callback=function() Settings_DeleteActivePreset() end,
		},
	},
	update=function() Settings_LoadActivePreset() end,
	option_items={
        {
            option_parent_text="",
            option_text="Presets:",
            option_note="Click on a preset to load preset.",
            option_type="multi_select",
            storage_key="active_preset",
            -- Note: this should dynamically update the preset list
            options={
                module="settings",
                key="presets"
            }
        },
		{
			option_parent_text="",
			option_text="New Preset Name",
			option_note="The new presets name.",
            option_type="text_input",
			storage_key="new_preset"
		}
	}
}

function Settings_GetPresetMenu()
    return {
        menu_title = "Preset",
        sub_menus={
            {
                sub_menu_title="Edit Presets",
                options=Preset_Options,
            }
        }
    }
end


-- FireMaterial Module settings
local FireMaterial_Options =
{
    storage_module="fire_material",
    storage_prefix_key=nil,
    buttons={},
    update=nil,
    option_items={
        {
            option_parent_text="Particle Color",
            option_text="Transparancy",
            option_note="Configure how transparent the fire is.",
            option_type="float",
            storage_key="color.a",
            min_max={0.0, 1.0, 0.1}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Life Time",
            option_note="Configure how long a single fire particle exists.",
            option_type="float",
            storage_key="lifetime",
            min_max={0.5, 10, 0.1}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Gravity",
            option_note="Configure how gravity affects the fire particles.",
            option_type="float",
            storage_key="gravity",
            min_max={-20.0, 20.0, 0.5}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Speed",
            option_note="Configure the speed at which the fire particle shoots away.",
            option_type="float",
            storage_key="speed",
            min_max={0.1, 10, 0.1}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Drag",
            option_note="Configure drag it has on other fire particles.",
            option_type="float",
            storage_key="drag",
            min_max={0.0, 1.0, 0.1}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Transparancy Variation",
            option_note="Configure transparancy variation between fire particles",
            option_type="float",
            storage_key="variation",
            min_max={0.0, 1.0, 0.1}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Size",
            option_note="Size of the fire particle.",
            option_type="float",
            storage_key="size",
            min_max={0.0, 1.0, 0.1}
        },
    }
}

function Settings_FireMaterial_GetOptionsMenu()
    local materialMenus = {
        menu_title="Fire Materials",
        sub_menus={}
    }
    for material, properties in pairs(_FireMaterialConfiguration) do
        local materialOptions = Generic_deepCopy(FireMaterial_Options)
        materialOptions["storage_prefix_key"] = material
        local buttons = {{
            text="Set default",
            callback=function()FireMaterial_DefaultSettings(material)end
        }}
        materialOptions["buttons"] = buttons
        materialOptions["update"] = function()FireMaterial_UpdateSettingsFromStorage(material)end
        table.insert(materialMenus["sub_menus"], {
            sub_menu_title=material,
            options=materialOptions,
        })
	end
	return materialMenus
end

-- Fire Detector Module Settings

local Settings_FireDetector_OptionsDetection =
{
	storage_module="firedetector",
	storage_prefix_key=nil,
    buttons={
		{
			text = "Set Default",
			callback=function() FireDetector_DefaultSettings() end,
		},
    },
	update=function() FireDetector_ApplyCustomSettings() end,
	option_items={
        {
            option_parent_text="",
            option_text="Max Box Size Fire Count",
            option_note="The max distance between fires that could be connected to the same fire.",
            option_type="float",
            storage_key="max_group_fire_distance",
            min_max={0.1, 5, 0.1}
        },
        {
            option_parent_text="",
            option_text="Min Distance Between Fires",
            option_note="Distance changes on fire detection radius.",
            option_type="float",
            storage_key="min_fire_distance",
            min_max={0.1, 5, 0.1}
        },
        {
            option_parent_text="",
            option_text="Trigger Update Time",
            option_note="Update fire detection/locations.",
            option_type="float",
            storage_key="fire_update_time",
            min_max={0.1, 10, 0.1}
        },
	}
}

local Settings_FireDetector_OptionsFireBehavior =
{
	storage_module="firedetector",
	storage_prefix_key=nil,
    buttons={
		{
			text = "Set Default",
			callback=function() FireDetector_DefaultSettings() end,
		},
    },
	update=function() FireDetector_ApplyCustomSettings() end,
	option_items={
        {
            option_parent_text="",
            option_text="Max Fires",
            option_note="How many fires may be detected at once.",
            option_type="int",
            storage_key="max_fire",
            min_max={1, 1000}
        },
        {
            option_parent_text="",
            option_text="Trigger Fire Reaction Time",
            option_note="Will trigger fire damage and spreading after x seconds (note the smaller the harder it is to extinguish)",
            option_type="int",
            storage_key="fire_reaction_time",
            min_max={1, 100}
        },
        {
            option_parent_text="",
            option_text="Max fire spread distance",
            option_note="How far at max intensity a fire can spread.",
            option_type="int",
            storage_key="max_fire_spread_distance",
            min_max={1, 20}
        },
        {
            option_parent_text="",
            option_text="Explosive Fire",
            option_note="Triggers explosion based on fire intensity, for fun (currently not extinguishable).",
            option_type="text",
			storage_key="fire_explosion",
			options={
				"YES",
				"NO"
			}
        },
        {
            option_parent_text="",
            option_text="Fire Damage",
            option_note="Creates holes based on fire intensity, simulating fire damage (currently not extinguishable).",
            option_type="text",
			storage_key="fire_damage",
			options={
				"YES",
				"NO"
			}
        },
        {
            option_parent_text="",
            option_text="Spawn Fire",
            option_note="Spawnes additional (not particle) fire to the existing fire (currently not extinguishable)",
            option_type="text",
			storage_key="spawn_fire",
			options={
				"YES",
				"NO"
			}
        },
        {
            option_parent_text="",
            option_text="Fire Damage Soft",
            option_note="The damage radius on soft materials (only if Fire Damage is enabled).",
            option_type="float",
            storage_key="fire_damage_soft",
            min_max={0.01, 5, 0.01}
        },
        {
            option_parent_text="",
            option_text="Fire Damage Medium",
            option_note="The damage radius on materials between soft and hard (must be lower than soft) (only if Fire Damage is enabled).",
            option_type="float",
            storage_key="fire_damage_medium",
            min_max={0.01, 3, 0.01}
        },
        {
            option_parent_text="",
            option_text="Fire Damage Hard",
            option_note="The damage radius hard materials (must be lower than medium) (only if Fire Damage is enabled) .",
            option_type="float",
            storage_key="fire_damage_hard",
            min_max={0.01, 1, 0.01}
        },
        {
            option_parent_text="",
            option_text="Teardown Max Fire",
            option_note="Set the max fires of non mod related fires (from teardown) that can spawn.",
            option_type="int",
            storage_key="teardown_max_fires",
            min_max={1, 10000}
        },
        {
            option_parent_text="",
            option_text="Teardown Fire Spread",
            option_note="Set the max fire spread of non mod related fire from teardown.",
            option_type="int",
            storage_key="teardown_fire_spread",
            min_max={1, 10}
        },
	}
}

local Settings_FireDetector_OptionsFireIntensity =
{
	storage_module="firedetector",
	storage_prefix_key=nil,
    buttons={
		{
			text = "Set Default",
			callback=function() FireDetector_DefaultSettings() end,
		},
    },
	update=function() FireDetector_ApplyCustomSettings() end,
	option_items={
		{
			option_parent_text="",
			option_text="Detect Fire Intensity",
			option_note="Detects how big a fire potentially to adjust particle size",
            option_type="text",
			storage_key="fire_intensity",
			options={
				"ON",
				"OFF"
			}
		},
        {
            option_parent_text="",
            option_text="Fire Intensity Multiplier",
            option_note="If fires aren't getting big enough fast enough..",
            option_type="int",
            storage_key="fire_intensity_multiplier",
            min_max={1, 100}
        },
        {
            option_parent_text="",
            option_text="Fire Intensity Minimum (%)",
            option_note="The minimum size fires there should be.",
            option_type="int",
            storage_key="fire_intensity_minimum",
            min_max={1, 100}
        },
	}
}


local Settings_FireDetector_OptionsDebugging =
{
	storage_module="firedetector",
	storage_prefix_key=nil,
    buttons={
		{
			text = "Set Default",
			callback=function() FireDetector_DefaultSettings() end,
		},
    },
	update=function() FireDetector_ApplyCustomSettings() end,
	option_items={
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
