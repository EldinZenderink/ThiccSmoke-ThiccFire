-- settings.lua
-- @date 2021-10-30
-- @author Eldin Zenderink
-- @brief This module should provide a centralized system for maintaining and grouping settings, to allow for easier adjustments, restore funcitonalities etc.
--        Every module will have their properties  stored and accessed from here. Menus will also be generated from here. Presets will be created in separated modules based on this module. Catagorizing settings will be done through here.

#include "presets/preset-low.lua"
#include "presets/preset-medium.lua"
#include "presets/preset-high.lua"
#include "presets/preset-ultra.lua"
#include "presets/preset-slipperygypsy.lua"


Settings = {}
Settings.LoadedSettings = {}
Settings.UpdateCallbacks = {}
Settings.Template = {
    Settings        = {
        ActivePreset = "default",
        description =
        "The default preset! Balance between performance and fidelity, best for mid to high end pcs with playable framerates.",
        version = "v5.4",
        type = "default"
    },
    GeneralOptions  = {
        toggle_menu_key = "U",
        ui_in_game = "NO",
        debug = "NO",
        enabled = "YES"
    },
    Wind = {
        wind = "YES",
        winddirection = 360,
        winddirectionrandom = 10,
        winddirectionrandomrate = 10,
        windstrength = 1,
        windstrengthrandom = 0,
        windstrengthrandomrate = 1
    },
    FireSim    = {
        map_size = "LARGE",
        max_fire_spread_distance = 3,
        fire_reaction_time = 25,
        fire_update_time = 0.5,
        min_fire_distance = 1,
        max_group_fire_distance = 4,
        max_fire = 100,
        fire_intensity = "ON",
        fire_intensity_multiplier = 3,
        fire_intensity_minimum = 10,
        visualize_fire_detection = "OFF",
        fire_explosion = "NO",
        fire_damage = "YES",
        spawn_fire = "YES",
        detect_inside = "YES",
        soot_sim = "YES",
        soot_max_size = 2.5,
        soot_min_size = 0.1,
        soot_dithering_max = 1,
        soot_dithering_min = 0.5,
        fire_damage_soft = 0.1,
        fire_damage_medium = 0.05,
        fire_damage_hard = 0.01,
        teardown_max_fires = 200,
        teardown_fire_spread = 1,
        material_allowed = {
            wood = true,
            foliage = true,
            plaster = true,
            plastic = true
        },
        despawn_td_fire = "YES",
        enable_sound = "ON",
        fire_sound_volume = 0.5,
        fire_sound_volume_random = 0,
        damage_sound_volume = 0.5,
        damage_sound_volume_random = 0
    },
    ParticleSpawner = {
        fire = "YES",
        smoke = "YES",
        ash = "YES",
        fire_to_smoke_ratio = "1:2",
        ash_to_smoke_ratio = "1:60",
        dynamic_fps = "ON",
        dynamic_fps_target = 35,
        particle_refresh_max = 60,
        particle_refresh_min = 20,
        aggressivenes = 1,
    },
    Light = {
        spawn_light = "ON",
        legacy = "NO",
        red_light_offset = 0,
        green_light_offset = -0.1,
        blue_light_offset = -0.1,
        light_intensity = 0.2,
        light_flickering_intensity = 3,
    },
    Particle        = {
        intensity_mp = "Use Material Property",
        drag_mp = "Use Material Property",
        gravity_mp = "Use Material Property",
        visualize_spawn_locations = "NO",
        min_particle_dist = 0.75,
        lifetime_mp = "1x",
        intensity_scale = 1,
        randomness = 0.2,
        location_randomness = 0.5,
        duplicator = 1,
        smoke_fadein = 10,
        smoke_fadeout = 15,
        fire_fadein = 5,
        fire_fadeout = 25,
        fire_emissive = 5,
        embers = "LOW",
        ash_gravity_min = -16,
        ash_gravity_max = -40,
        ash_rot_max = 2,
        ash_rot_min = 1,
        ash_sticky_max = 0.9,
        ash_sticky_min = 0.7,
        ash_drag_max = 0.2,
        ash_drag_min = 0.1,
        ash_size_max = 0.04,
        ash_size_min = 0.01,
        ash_life = 2
    },
    FireMaterial    = {
        wood = {
            color = { r = 0.93, g = 0.25, b = 0.10, a = 1 },
            lifetime = 1,
            size = 0.9,
            gravity = 1.5,
            rotation = 0.5,
            speed = 0.1,
            drag = 0.2,
            variation = 0.4,
        },
        foliage = {
            color = { r = 0.86, g = 0.23, b = 0.09, a = 1 },
            lifetime = 1,
            size = 0.9,
            gravity = 1.5,
            rotation = 0.5,
            speed = 0.1,
            drag = 0.2,
            variation = 0.4,
        },
        plaster = {
            color = { r = 0.7, g = 0.13, b = 0.13, a = 1 },
            lifetime = 1,
            size = 0.9,
            gravity = 1.5,
            rotation = 0.5,
            speed = 0.1,
            drag = 0.2,
            variation = 0.4,
        },
        plastic = {
            color = { r = 0.86, g = 0.23, b = 0.09, a = 1 },
            lifetime = 1,
            size = 0.9,
            gravity = 1.5,
            rotation = 0.5,
            speed = 0.1,
            drag = 0.2,
            variation = 0.4,
        }
    },
    SmokeMaterial   = {
        wood = {
            color = { r = 0.16, g = 0.16, b = 0.16, a = 1 },
            lifetime = 4,
            size = 1,
            gravity = 4,
            rotation = 0.5,
            speed = 0.5,
            drag = 0.3,
            variation = 0.2,
        },
        foliage = {
            color = { r = 0.2, g = 0.2, b = 0.15, a = 1 },
            lifetime = 4,
            size = 1,
            gravity = 4,
            rotation = 0.5,
            speed = 0.5,
            drag = 0.2,
            variation = 0.2,
        },
        plaster = {
            color = { r = 0.27, g = 0.27, b = 0.27, a = 1 },
            lifetime = 4,
            size = 1,
            gravity = 4,
            rotation = 0.5,
            speed = 0.6,
            drag = 0.1,
            variation = 0.1,
        },
        plastic = {
            color = { r = 0.25, g = 0.25, b = 0.27, a = 1 },
            lifetime = 4,
            size = 1,
            gravity = 4,
            rotation = 0.5,
            speed = 0.15,
            drag = 1,
            variation = 0.1,
        }
    }
}

function Settings.Init(Generic, Storage, Menu, Debug, default)
    Settings.Generic = Generic
    Settings.Storage = Storage
    Settings.Menu = Menu
    Settings.Debug = Debug

    -- Clear all presets beyond preset number 6:
    local presets = Settings.GetPresets()
    local active = Settings.Storage.GetString("settings", "active_preset")
    for i = 1, #presets do
        if i > 6  and presets[i] ~= active then
            Settings.DeletePreset(presets[i])
        end
    end

    local active_preset = Settings.Storage.GetString("settings", "active_preset")
    if default or active_preset == "" then
        Settings.SetDefault()
    else
        Settings.CreatePreset(Preset_Settings_SlipperyGypsy)
        Settings.CreatePreset(Preset_Settings_Ultra)
        Settings.CreatePreset(Preset_Settings_High)
        Settings.CreatePreset(Preset_Settings_Medium)
        Settings.CreatePreset(Preset_Settings_Low)
        Settings.Storage.SetString("settings", "active_preset", active_preset)
        Settings.LoadActivePreset()
    end
end

function Settings.LoadMenu()
    Settings.StoreAll()
    Settings.Menu.AppendMenu(Settings.GeneralOptions_GetOptionsMenu())
    Settings.Menu.AppendMenu(Settings.GetPresetMenu())
    Settings.Menu.AppendMenu(Settings.FireSim_GetOptionsMenu())
    Settings.Menu.AppendMenu(Settings.Wind_GetOptionsMenu())
    Settings.Menu.AppendMenu(Settings.Light_GetOptionsMenu())
    Settings.Menu.AppendMenu(Settings.ParticleSpawner_GetOptionsMenu())
    Settings.Menu.AppendMenu(Settings.Particle_GetOptionsMenu())
    Settings.Menu.AppendMenu(Settings.FireMaterial_GetOptionsMenu())
    Settings.Menu.AppendMenu(Settings.SmokeMaterial_GetOptionsMenu())
end

function Settings.StoreAll()
    Settings.GeneralOptions_Store()
    Settings.FireSim_Store()
    Settings.Wind_Store()
    Settings.Light_Store()
    Settings.ParticleSpawner_Store()
    Settings.Particle_Store()
    Settings.FireMaterial_Store()
    Settings.SmokeMaterial_Store()
end

function Settings.UpdateAll()
    Settings.GeneralOptions_Update()
    Settings.FireSim_Update()
    Settings.Wind_Update()
    Settings.Light_Update()
    Settings.ParticleSpawner_Update()
    Settings.Particle_Update()
    Settings.FireMaterial_Update()
    Settings.SmokeMaterial_Update()
end

function Settings.RegisterUpdateSettingsCallback(func)
    Settings.UpdateCallbacks[#Settings.UpdateCallbacks+1] = func
end

function Settings.CallUpdate()

    DebugPrint("Upddating settings to " .. tostring(#Settings.UpdateCallbacks) .. " registered callbacks")
    for i=1, #Settings.UpdateCallbacks do
        DebugPrint("Upddating settings")
        Settings.UpdateCallbacks[i]()
    end
end

function Settings.SetDefault()
    Settings.SetStorageValuesRecursive("default", Settings.Template)
    Settings.Storage.SetString("settings", "presets", "default")
    Settings.CreatePreset(Preset_Settings_SlipperyGypsy)
    Settings.CreatePreset(Preset_Settings_Ultra)
    Settings.CreatePreset(Preset_Settings_High)
    Settings.CreatePreset(Preset_Settings_Medium)
    Settings.CreatePreset(Preset_Settings_Low)
    Settings.Storage.SetString("settings", "active_preset", "default")
    Settings.LoadActivePreset()
end

-- Settings load and store from Storage
function Settings.SetStorageValuesRecursive(preset, table)
    for key, value in pairs(table) do
        if type(value) == "table" then
            Settings.SetStorageValuesRecursive(preset .. "." .. key, value)
        else
            if type(value) == "string" then
                Settings.Storage.SetString("settings", preset .. "." .. key, value)
            end
            if type(value) == "number" then
                Settings.Storage.SetFloat("settings", preset .. "." .. key, value)
            end
            if type(value) == "boolean" then
                Settings.Storage.SetBool("settings", preset .. "." .. key, value)
            end
        end
    end
end

function Settings.GetStorageValuesRecursive(preset, table)
    for key, value in pairs(table) do
        if type(value) == "table" then
            Settings.GetStorageValuesRecursive(preset .. "." .. key, table[key])
        else
            if type(value) == "string" then
                table[key] = Settings.Storage.GetString("settings", preset .. "." .. key)
            end
            if type(table[key]) == "number" then
                table[key] = Settings.Storage.GetFloat("settings", preset .. "." .. key)
            end
            if type(table[key]) == "boolean" then
                table[key] = Settings.Storage.GetBool("settings", preset .. "." .. key)
            end
        end
    end
    Settings.LoadedSettings["Settings"]["ActivePreset"] = preset
end

function Settings.EditedSettings()
    -- DebugPrint("Searching " .. "-editted" .. " in string: " .. Settings.LoadedSettings["Settings"]["ActivePreset"] .. ", result: " .. tostring(string.find(Settings.LoadedSettings["Settings"]["ActivePreset"], "-editted")))
    if Settings.LoadedSettings["Settings"]["type"] == "default" and string.find(Settings.LoadedSettings["Settings"]["ActivePreset"], "-editted") == nil then
        Settings.LoadedSettings["Settings"]["ActivePreset"] = Settings.LoadedSettings["Settings"]["ActivePreset"] .. "-editted"
        Settings.CreatePreset(Settings.LoadedSettings)
        Settings.SetValue("Settings", "type", "custom")
        Settings.StoreActivePreset()
    end
end

function Settings.GetValue(module_to_get, key_to_get)
    local keys = Settings.Generic.SplitString(key_to_get, '.')
    local module = Settings.LoadedSettings[module_to_get]
    for i=1, #keys do
        if type(module[keys[i]]) == "table" then
            module = module[keys[i]]
        else
            return module[keys[i]]
        end
    end
    return nil
end

function Settings.SetValue(module_to_set, key_to_set, value_to_set)
    local keys = Settings.Generic.SplitString(key_to_set, '.')
    local module = Settings.LoadedSettings[module_to_set]
    for i=1, #keys do
        if type(module[keys[i]]) == "table" then
            module = module[keys[i]]
        else
            module[keys[i]] = value_to_set
        end
    end
end
-- Preset related functions
function Settings.GetPresets()
    local presets = Settings.Storage.GetString("settings", "presets")
    return Settings.Generic.SplitString(presets, ',')
end

function Settings.AddPreset(preset)
    local presets = Settings.Storage.GetString("settings", "presets")
    if presets == "" then
        presets = preset
    else
        presets = presets .. "," ..preset
    end
    Settings.Storage.SetString("settings", "presets", presets)
end

function Settings.DeletePreset(preset)
    local presets = Settings.GetPresets()
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
    Settings.Storage.SetString("settings", "presets", new_presets)
end

function Settings.PresetExists(preset)
    local presets = Settings.Storage.GetString("settings", "presets")
    local preset_list = Settings.Generic.SplitString(presets, ',')

    if Settings.Generic.TableContains(preset_list, preset) then
        return true
    end

    return false
end

function Settings.CreatePreset(settings)
    local preset = Settings.Storage.GetString("settings", "new_preset")
    if settings ~= nil then
        preset = settings["Settings"]["ActivePreset"]
        if Settings.PresetExists(preset) then
            Settings.DeletePreset(preset)
            Settings.Debug.Printer("Delete preset: "  .. preset)
        end
    end
    if Settings.PresetExists(preset) then
        Settings.Debug.Printer("Preset still exists, not adding: "  .. preset)
        return false
    else
        Settings.Debug.Printer("Adding preset: "  .. preset)
        Settings.AddPreset(preset)
        if settings == nil then
            Settings.SetStorageValuesRecursive(preset, Settings.LoadedSettings)
        else
            Settings.SetStorageValuesRecursive(preset, settings)
        end
        Settings.Storage.SetString("settings", "active_preset", preset)
        Settings.LoadActivePreset()
        return true
    end
end

function Settings.CreateDescription()
    Settings.SetValue("Settings", "description", Settings.Storage.GetString("settings", "description"))
    Settings.StoreActivePreset()
end

function Settings.LoadActivePreset()
    Settings.LoadedSettings = Settings.Generic.deepCopy(Settings.Template)
    local preset = Settings.Storage.GetString("settings", "active_preset")
    DebugPrint("Loading active preset: " .. preset)
    Settings.GetStorageValuesRecursive(preset, Settings.LoadedSettings)
    Settings.Storage.SetString("settings", "description", Settings.GetValue("Settings", "description"))
    Settings.StoreAll()
    Settings.CallUpdate()
end

function Settings.StoreActivePreset()
    local preset = Settings.Storage.GetString("settings", "active_preset")
    Settings.SetStorageValuesRecursive(preset, Settings.LoadedSettings)
    Settings.CallUpdate()
end

function Settings.DeleteActivePreset()
    local preset = Settings.Storage.GetString("settings", "active_preset")
    Settings.DeletePreset(preset)
    local presets = Settings.GetPresets()
    Settings.Storage.SetString("settings", "active_preset", presets[#presets])
    Settings.LoadActivePreset()
end


function Settings.DefaultActivePreset()
    Settings.LoadedSettings = Settings.Generic.deepCopy(Settings.Template)
    Settings.StoreActivePreset()
end


--- Generate option  menus
local Preset_Options =
{
	module="settings",
	prefix_key=nil,
	buttons={
		{
			text = "Clear All Presets",
			callback=function() Settings.SetDefault() end,
		},
		{
			text = "Delete Active Preset",
			callback=function() Settings.DeleteActivePreset() end,
		},
		{
			text = "Reset Active Preset",
			callback=function() Settings.DefaultActivePreset() end,
		},
	},
	update=function() Settings.LoadActivePreset() end,
	option_items={
        {
            option_parent_text="",
            option_text="Select Active Preset",
            option_note="Click on a preset to load preset (bold is active). Changing settings will be applied to this preset.",
            option_type="multi_select",
            key="active_preset",
            -- Note: this should dynamically update the preset list
            options={
                module="settings",
                key="presets"
            }
        },
		{
			option_parent_text="",
			option_text="Preset Description",
			option_note="Update Description.",
            option_type="text_input_field",
			key="description",
            options={
                key_press=nil,
                action=function() Settings.CreateDescription() end
            }
		},
		{
			option_parent_text="",
			option_text="New Preset Name",
			option_note="Enter a new preset name here, settings will be copied from the active preset.",
            option_type="text_input",
			key="new_preset",
            options={
                key_press="enter",
                action=function() Settings.CreatePreset() end
            }
		},
	}
}

function Settings.GetPresetMenu()
    return {
        menu_title = "Presets",
        sub_menus={
            {
                sub_menu_title="Change Presets",
                options=Preset_Options,
                description="Note the presets 'default', 'low', 'medium', 'high', 'ultra' will be overridden every restart.\nPlease create a new preset (based on the active preset) before changing settings, otherwise they will be lost on restart!"
            }
        }
    }
end


-- FireMaterial Module settings
Settings.FireMaterial_Options =
{
    module="fire_material",
    prefix_key=nil,
    buttons={},
    update=nil,
    option_items={
        {
            option_parent_text="Particle Color",
            option_text="Red",
            option_note="Configure how red the fire is.",
            option_type="float",
            key="color.r",
            min_max={0, 1.0, 0.01}
        },
        {
            option_parent_text="Particle Color",
            option_text="Green",
            option_note="Configure how green the fire is.",
            option_type="float",
            key="color.g",
            min_max={0, 1.0, 0.01}
        },
        {
            option_parent_text="Particle Color",
            option_text="Blue",
            option_note="Configure how transparent the fire is.",
            option_type="float",
            key="color.b",
            min_max={0, 1.0, 0.01}
        },
        {
            option_parent_text="Particle Color",
            option_text="Transparancy",
            option_note="Configure how transparent the fire is.",
            option_type="float",
            key="color.a",
            min_max={0, 1.0, 0.01}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Life Time",
            option_note="Configure how long a single fire particle exists.",
            option_type="float",
            key="lifetime",
            min_max={0.5, 30, 0.01}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Gravity",
            option_note="Configure how gravity affects the fire particles.",
            option_type="float",
            key="gravity",
            min_max={-20.0, 20.0, 0.5}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Speed",
            option_note="Configure the speed at which the fire particle shoots away.",
            option_type="float",
            key="speed",
            min_max={0.01, 10, 0.01}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Rotation",
            option_note="Configure the particle rotational speed.",
            option_type="float",
            key="rotation",
            min_max={0.01, 10, 0.01}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Drag",
            option_note="Configure drag it has on other fire particles.",
            option_type="float",
            key="drag",
            min_max={0.01, 1.0, 0.01}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Transparancy Variation",
            option_note="Configure transparancy variation between fire particles",
            option_type="float",
            key="variation",
            min_max={0.01, 1.0, 0.01}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Size",
            option_note="Size of the fire particle.",
            option_type="float",
            key="size",
            min_max={0.01, 1.0, 0.01}
        },
    }
}

function Settings.FireMaterial_Update(material)
    Settings.EditedSettings()
    Settings.SetValue("FireMaterial", material .. ".color.r", Settings.Storage.GetFloat("fire_material", material .. ".color.r"))
    Settings.SetValue("FireMaterial", material .. ".color.g", Settings.Storage.GetFloat("fire_material", material .. ".color.g"))
    Settings.SetValue("FireMaterial", material .. ".color.b", Settings.Storage.GetFloat("fire_material", material .. ".color.b"))
    Settings.SetValue("FireMaterial", material .. ".color.a", Settings.Storage.GetFloat("fire_material", material .. ".color.a"))
    Settings.SetValue("FireMaterial", material .. ".lifetime", Settings.Storage.GetFloat("fire_material", material .. ".lifetime"))
    Settings.SetValue("FireMaterial", material .. ".size", Settings.Storage.GetFloat("fire_material", material .. ".size"))
    Settings.SetValue("FireMaterial", material .. ".gravity", Settings.Storage.GetFloat("fire_material", material .. ".gravity"))
    Settings.SetValue("FireMaterial", material .. ".rotation", Settings.Storage.GetFloat("fire_material", material .. ".rotation"))
    Settings.SetValue("FireMaterial", material .. ".speed", Settings.Storage.GetFloat("fire_material", material .. ".speed"))
    Settings.SetValue("FireMaterial", material .. ".drag", Settings.Storage.GetFloat("fire_material", material .. ".drag"))
    Settings.SetValue("FireMaterial", material .. ".variation", Settings.Storage.GetFloat("fire_material", material .. ".variation"))
    Settings.StoreActivePreset()
end

function Settings.FireMaterial_Store()
    for material, val in pairs(Settings.LoadedSettings["FireMaterial"]) do
        Settings.Storage.SetFloat("fire_material", material .. ".color.r", Settings.GetValue("FireMaterial", material .. ".color.r"))
        Settings.Storage.SetFloat("fire_material", material .. ".color.g", Settings.GetValue("FireMaterial", material .. ".color.g"))
        Settings.Storage.SetFloat("fire_material", material .. ".color.b", Settings.GetValue("FireMaterial", material .. ".color.b"))
        Settings.Storage.SetFloat("fire_material", material .. ".color.a", Settings.GetValue("FireMaterial", material .. ".color.a"))
        Settings.Storage.SetFloat("fire_material", material .. ".lifetime", Settings.GetValue("FireMaterial", material .. ".lifetime"))
        Settings.Storage.SetFloat("fire_material", material .. ".size", Settings.GetValue("FireMaterial", material .. ".size"))
        Settings.Storage.SetFloat("fire_material", material .. ".gravity", Settings.GetValue("FireMaterial", material .. ".gravity"))
        Settings.Storage.SetFloat("fire_material", material .. ".speed", Settings.GetValue("FireMaterial", material .. ".speed"))
        Settings.Storage.SetFloat("fire_material", material .. ".rotation", Settings.GetValue("FireMaterial", material .. ".rotation"))
        Settings.Storage.SetFloat("fire_material", material .. ".drag", Settings.GetValue("FireMaterial", material .. ".drag"))
        Settings.Storage.SetFloat("fire_material", material .. ".variation", Settings.GetValue("FireMaterial", material .. ".variation"))
    end
    Settings.StoreActivePreset()
end

function Settings.FireMaterial_Default(material)
    Settings.LoadedSettings["FireMaterial"][material] = Settings.Template["FireMaterial"][material]
    Settings.FireMaterial_Store()
end

function Settings.FireMaterial_GetOptionsMenu()
    local materialMenus = {
        menu_title="Fire Materials",
        sub_menus={}
    }
    for material, properties in pairs(Settings.LoadedSettings["FireMaterial"]) do
        local materialOptions = Settings.Generic.deepCopy(Settings.FireMaterial_Options)
        materialOptions["prefix_key"] = material
        local buttons = {{
            text="Set default",
            callback=function()Settings.FireMaterial_Default(material)end
        }}
        materialOptions["buttons"] = buttons
        materialOptions["update"] = function()Settings.FireMaterial_Update(material)end
        table.insert(materialMenus["sub_menus"], {
            sub_menu_title=material,
            options=materialOptions,
            description="Change settings for material " .. material .. " in regards how fire looks when this material is on fire."
        })
	end
	return materialMenus
end


-- SmokeMaterial Module settings
Settings.SmokeMaterial_Options =
{
    module="smoke_material",
    prefix_key=nil,
    buttons={},
    update=nil,
    option_items={
        {
            option_parent_text="Particle Color",
            option_text="Red",
            option_note="Configure how red the smoke is.",
            option_type="float",
            key="color.r",
            min_max={0.01, 1.0, 0.01}
        },
        {
            option_parent_text="Particle Color",
            option_text="Green",
            option_note="Configure how green the smoke is.",
            option_type="float",
            key="color.g",
            min_max={0.01, 1.0, 0.01}
        },
        {
            option_parent_text="Particle Color",
            option_text="Blue",
            option_note="Configure how transparent the smoke is.",
            option_type="float",
            key="color.b",
            min_max={0.01, 1.0, 0.01}
        },
        {
            option_parent_text="Particle Color",
            option_text="Transparancy",
            option_note="Configure how transparent the smoke is.",
            option_type="float",
            key="color.a",
            min_max={0.01, 1.0, 0.01}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Life Time",
            option_note="Configure how long a single smoke particle exists.",
            option_type="float",
            key="lifetime",
            min_max={1, 30, 1}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Gravity",
            option_note="Configure how gravity affects the smoke particles.",
            option_type="float",
            key="gravity",
            min_max={-20.0, 20.0, 0.5}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Speed",
            option_note="Configure the speed at which the smoke particle shoots away.",
            option_type="float",
            key="speed",
            min_max={0.01, 10, 0.01}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Rotation",
            option_note="Configure the rotation of the particle.",
            option_type="float",
            key="rotation",
            min_max={0.01, 10, 0.01}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Drag",
            option_note="Configure drag it has on other smoke particles.",
            option_type="float",
            key="drag",
            min_max={0.01, 1.0, 0.01}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Transparancy Variation",
            option_note="Configure transparancy variation between smoke particles",
            option_type="float",
            key="variation",
            min_max={0.01, 1.0, 0.01}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Size",
            option_note="Size of the smoke particle.",
            option_type="float",
            key="size",
            min_max={0.0, 4.0, 0.01}
        },
    }
}

function Settings.SmokeMaterial_Update(material)
    Settings.EditedSettings()
    Settings.SetValue("SmokeMaterial", material .. ".color.r", Settings.Storage.GetFloat("smoke_material", material .. ".color.r"))
    Settings.SetValue("SmokeMaterial", material .. ".color.g", Settings.Storage.GetFloat("smoke_material", material .. ".color.g"))
    Settings.SetValue("SmokeMaterial", material .. ".color.b", Settings.Storage.GetFloat("smoke_material", material .. ".color.b"))
    Settings.SetValue("SmokeMaterial", material .. ".color.a", Settings.Storage.GetFloat("smoke_material", material .. ".color.a"))
    Settings.SetValue("SmokeMaterial", material .. ".lifetime", Settings.Storage.GetFloat("smoke_material", material .. ".lifetime"))
    Settings.SetValue("SmokeMaterial", material .. ".size", Settings.Storage.GetFloat("smoke_material", material .. ".size"))
    Settings.SetValue("SmokeMaterial", material .. ".gravity", Settings.Storage.GetFloat("smoke_material", material .. ".gravity"))
    Settings.SetValue("SmokeMaterial", material .. ".speed", Settings.Storage.GetFloat("smoke_material", material .. ".speed"))
    Settings.SetValue("SmokeMaterial", material .. ".rotation", Settings.Storage.GetFloat("smoke_material", material .. ".rotation"))
    Settings.SetValue("SmokeMaterial", material .. ".drag", Settings.Storage.GetFloat("smoke_material", material .. ".drag"))
    Settings.SetValue("SmokeMaterial", material .. ".variation", Settings.Storage.GetFloat("smoke_material", material .. ".variation"))
    Settings.StoreActivePreset()
end

function Settings.SmokeMaterial_Store()
    for material, val in pairs(Settings.LoadedSettings["SmokeMaterial"]) do
        Settings.Storage.SetFloat("smoke_material", material .. ".color.r", Settings.GetValue("SmokeMaterial", material .. ".color.r"))
        Settings.Storage.SetFloat("smoke_material", material .. ".color.g", Settings.GetValue("SmokeMaterial", material .. ".color.g"))
        Settings.Storage.SetFloat("smoke_material", material .. ".color.b", Settings.GetValue("SmokeMaterial", material .. ".color.b"))
        Settings.Storage.SetFloat("smoke_material", material .. ".color.a", Settings.GetValue("SmokeMaterial", material .. ".color.a"))
        Settings.Storage.SetFloat("smoke_material", material .. ".lifetime", Settings.GetValue("SmokeMaterial", material .. ".lifetime"))
        Settings.Storage.SetFloat("smoke_material", material .. ".size", Settings.GetValue("SmokeMaterial", material .. ".size"))
        Settings.Storage.SetFloat("smoke_material", material .. ".gravity", Settings.GetValue("SmokeMaterial", material .. ".gravity"))
        Settings.Storage.SetFloat("smoke_material", material .. ".speed", Settings.GetValue("SmokeMaterial", material .. ".speed"))
        Settings.Storage.SetFloat("smoke_material", material .. ".drag", Settings.GetValue("SmokeMaterial", material .. ".drag"))
        Settings.Storage.SetFloat("smoke_material", material .. ".rotation", Settings.GetValue("SmokeMaterial", material .. ".rotation"))
        Settings.Storage.SetFloat("smoke_material", material .. ".variation", Settings.GetValue("SmokeMaterial", material .. ".variation"))
    end
    Settings.StoreActivePreset()
end

function Settings.SmokeMaterial_Default(material)
    Settings.LoadedSettings["SmokeMaterial"][material] = Settings.Template["SmokeMaterial"][material]
    Settings.SmokeMaterial_Store()
end

function Settings.SmokeMaterial_GetOptionsMenu()
    local materialMenus = {
        menu_title="Smoke Materials",
        sub_menus={}
    }
    for material, properties in pairs(Settings.LoadedSettings["SmokeMaterial"]) do
        local materialOptions = Settings.Generic.deepCopy(Settings.SmokeMaterial_Options)
        materialOptions["prefix_key"] = material
        local buttons = {{
            text="Set default",
            callback=function()Settings.SmokeMaterial_Default(material)end
        }}
        materialOptions["buttons"] = buttons
        materialOptions["update"] = function()Settings.SmokeMaterial_Update(material)end
        table.insert(materialMenus["sub_menus"], {
            sub_menu_title=material,
            options=materialOptions,
            description="Change settings for material " .. material .. " in regards how smoke looks when this material is on fire."
        })
	end
	return materialMenus
end

-- Fire Detector Module Settings
Settings.FireSim_OptionsDetection =
{
	module="FireSim",
	prefix_key=nil,
    buttons={
		{
			text = "Set Default",
			callback=function() Settings.FireSim_Default() end,
		},
    },
	update=function() Settings.FireSim_Update() end,
	option_items={

        {
            option_parent_text="",
            option_text="Map Size",
            option_note="Select LARGE, if fire is not detected on the edges of the map, SMALL for more accurate detection without performance hit!",
            option_type="text",
			key="map_size",
			options={
				"LARGE",
				"MEDIUM",
                "SMALL"
			}
        },
        {
            option_parent_text="",
            option_text="Detect Inside Convined Space",
            option_note="Detect if fire is within convined space to limit intensity to 50% (sort of fixes particles to large/glitching)",
            option_type="text",
			key="detect_inside",
			options={
				"YES",
				"NO"
			}
        },
        {
            option_parent_text="",
            option_text="Fire Count Area Size",
            option_note="The box size per fire, within the box the amount of fires detected determines intensity.",
            option_type="float",
            key="max_group_fire_distance",
            min_max={
                0.5, -- min
                4,   -- max
                0.1, -- steps
                {
                    {
                        related="min_fire_distance",
                        type=">"
                    }
                }
            }
        },
        {
            option_parent_text="",
            option_text="Minimum Distance Between Fires",
            option_note="The minimum distance between each detected fire (lower is less FPS/heavier)",
            option_type="float",
            key="min_fire_distance",
            min_max={
                0.1,
                4,
                0.1,
                {
                    {
                        related="max_group_fire_distance",
                        type="<"
                    }
                }
            }
        },
        {
            option_parent_text="",
            option_text="Detecion Rate (per second)",
            option_note="Update fire detection/locations.",
            option_type="float",
            key="fire_update_time",
            min_max={0.01, 10, 0.05}
        },
	}
}

Settings.FireSim_OptionsFireSpread=
{
	module="FireSim",
	prefix_key=nil,
    buttons={
		{
			text = "Set Default",
			callback=function() Settings.FireSim_Default() end,
		},
    },
	update=function() Settings.FireSim_Update() end,
	option_items={
        {
            option_parent_text="",
            option_text="Teardown Max Fire",
            option_note="Set the max fires of non mod related fires from teardown that can spawn.",
            option_type="float",
            key="teardown_max_fires",
            min_max={1, 10000, 1}
        },
        {
            option_parent_text="",
            option_text="Teardown Fire Spread",
            option_note="Set the max fire spread of non mod related fire from teardown.",
            option_type="float",
            key="teardown_fire_spread",
            min_max={1, 10, 1}
        },
        {
            option_parent_text="",
            option_text="Despawn Teardown Fire",
            option_note="Once a fire is detected and particles are spawned by this mod, puts out the actual teardown fire, for performance.",
            option_type="text",
            key="despawn_td_fire",
			options={
				"YES",
				"NO"
			}
        },
        {
            option_parent_text="",
            option_text="Max Fires",
            option_note="How many fires can be active.",
            option_type="float",
            key="max_fire",
            min_max={1, 1000, 1}
        },
        {
            option_parent_text="",
            option_text="Max Fire Spread Distance",
            option_note="How far at max intensity a fire can spread/ interact with shapes.",
            option_type="float",
            key="max_fire_spread_distance",
            min_max={1, 20, 1}
        },
        {
            option_parent_text="",
            option_text="Trigger Fire Reaction Time",
            option_note="Will trigger fire damage and spreading after x seconds (note the smaller the harder it is to extinguish)",
            option_type="float",
            key="fire_reaction_time",
            min_max={1, 100, 1}
        },
        {
            option_parent_text="",
            option_text="Spawn Fire",
            option_note="Spawnes additional teardown native fire to the existing fire (currently not extinguishable)",
            option_type="text",
			key="spawn_fire",
			options={
				"YES",
				"NO"
			}
        },
	}
}

Settings.FireSim_OptionsFireDamage =
{
	module="FireSim",
	prefix_key=nil,
    buttons={
		{
			text = "Set Default",
			callback=function() Settings.FireSim_Default() end,
		},
    },
	update=function() Settings.FireSim_Update() end,
	option_items={
        {
            option_parent_text="",
            option_text="Fire Damage",
            option_note="Creates holes based on fire intensity, simulating fire damage (currently not extinguishable).",
            option_type="text",
			key="fire_damage",
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
            key="fire_damage_soft",
            min_max={
                0.5,
                50,
                0.1,
                {
                    {
                        related="fire_damage_medium",
                        type=">"
                    },
                    {
                        related="fire_damage_hard",
                        type=">"
                    }
                }
            }
        },
        {
            option_parent_text="",
            option_text="Fire Damage Medium",
            option_note="The damage radius on materials between soft and hard (must be lower than soft) (only if Fire Damage is enabled).",
            option_type="float",
            key="fire_damage_medium",
            min_max={
                0.3,
                30,
                0.1,
                {
                    {
                        related="fire_damage_soft",
                        type="<"
                    },
                    {
                        related="fire_damage_hard",
                        type=">"
                    }
                }
            }
        },
        {
            option_parent_text="",
            option_text="Fire Damage Hard",
            option_note="The damage radius hard materials (must be lower than medium) (only if Fire Damage is enabled) .",
            option_type="float",
            key="fire_damage_hard",
            min_max={
                0.1,
                10,
                0.1,
                {
                    {
                        related="fire_damage_soft",
                        type="<"
                    },
                    {
                        related="fire_damage_medium",
                        type="<"
                    }
                }
            }
        },
        {
            option_parent_text="",
            option_text="Explosive Fire",
            option_note="Triggers explosion based on fire intensity, for fun (currently not extinguishable).",
            option_type="text",
			key="fire_explosion",
			options={
				"YES",
				"NO"
			}
        },
	}
}

Settings.FireSim_OptionsFireSoot =
{
	module="FireSim",
	prefix_key=nil,
    buttons={
		{
			text = "Set Default",
			callback=function() Settings.FireSim_Default() end,
		},
    },
	update=function() Settings.FireSim_Update() end,
	option_items={
        {
            option_parent_text="",
            option_text="Simulate Soot",
            option_note="Creates soot on walls and ceiling where smoke is, size depending on fire intensity",
            option_type="text",
			key="soot_sim",
			options={
				"YES",
				"NO"
			}
        },
        {
            option_parent_text="",
            option_text="Soot Max Size",
            option_note="Max radius of one soot 'spray' (5 = 5m), intensity is randum but affected by intensity, max size when 100% intensity",
            option_type="float",
            key="soot_max_size",
            min_max={
                0.1,
                5,
                0.1,
                {
                    {
                        related="soot_min_size",
                        type=">"
                    }
                }
            }
        },
        {
            option_parent_text="",
            option_text="Soot Min Size",
            option_note="Min radius of one soot 'spray' (5 = 5m), intensity is randum but affected by intensity, min size when 0% intensity",
            option_type="float",
            key="soot_min_size",
            min_max={
                0.1,
                5,
                0.1,
                {
                    {
                        related="soot_max_size",
                        type="<"
                    }
                }
            }
        },
        {
            option_parent_text="",
            option_text="Soot Max Dithering",
            option_note="Dithering is random, but the max can be set, less dithering == less detail.",
            option_type="float",
            key="soot_dithering_max",
            min_max={
                0.1,
                1,
                0.1,
                {
                    {
                        related="soot_dithering_min",
                        type=">"
                    }
                }
            }
        },
        {
            option_parent_text="",
            option_text="Soot Min Dithering",
            option_note="Dithering is random, but the min can be set, less dithering == less detail.",
            option_type="float",
            key="soot_dithering_min",
            min_max={
                0.1,
                1,
                0.1,
                {
                    {
                        related="soot_dithering_max",
                        type="<"
                    }
                }
            }
        },
	}
}

Settings.FireSim_OptionsFireIntensity =
{
	module="FireSim",
	prefix_key=nil,
    buttons={
		{
			text = "Set Default",
			callback=function() Settings.FireSim_Default() end,
		},
    },
	update=function() Settings.FireSim_Update() end,
	option_items={
		{
			option_parent_text="",
			option_text="Simulate Fire Intensity",
			option_note="Detects how big a fire potentially to adjust particle size",
            option_type="text",
			key="fire_intensity",
			options={
				"ON",
				"OFF"
			}
		},
        {
            option_parent_text="",
            option_text="Fire Intensity Multiplier",
            option_note="If fires aren't getting big enough fast enough..",
            option_type="float",
            key="fire_intensity_multiplier",
            min_max={1, 20, 1}
        },
        {
            option_parent_text="",
            option_text="Fire Intensity Minimum (%)",
            option_note="The minimum size fires there should be.",
            option_type="float",
            key="fire_intensity_minimum",
            min_max={1, 100, 1}
        },
	}
}

Settings.FireSim_OptionsFireSound =
{
	module="FireSim",
	prefix_key=nil,
    buttons={
		{
			text = "Set Default",
			callback=function() Settings.FireSim_Default() end,
		},
    },
	update=function() Settings.FireSim_Update() end,
	option_items={
        {
            option_parent_text="",
            option_text="Enable Sound",
            option_note="Since this sim disables the original fire sim, it also has its own sound!",
            option_type="text",
            key="enable_sound",
			options={
				"ON",
				"OFF"
			}
        },
        {
            option_parent_text="",
            option_text="Fire Sound Volume",
            option_note="Set the overall fire sound volume",
            option_type="float",
            key="fire_sound_volume",
            min_max={0, 1, 0.1}
        },
        {
            option_parent_text="",
            option_text="Fire Sound Volume Randomizer",
            option_note="Some randomness to fire volume for more immersion",
            option_type="float",
            key="fire_sound_volume_random",
            min_max={0, 1, 0.1}
        },
        {
            option_parent_text="",
            option_text="Fire Damage Volume",
            option_note="Set the overall fire damage sound volume",
            option_type="float",
            key="damage_sound_volume",
            min_max={0, 1, 0.1}
        },
        {
            option_parent_text="",
            option_text="Fire Damage Volume Randomizer",
            option_note="Some randomness to damage volume for more immersion",
            option_type="float",
            key="damage_sound_volume_random",
            min_max={0, 1, 0.1}
        }

	}
}


Settings.FireSim_OptionsDebugging =
{
	module="FireSim",
	prefix_key=nil,
    buttons={
		{
			text = "Set Default",
			callback=function() Settings.FireSim_Default() end,
		},
    },
	update=function() Settings.FireSim_Update() end,
	option_items={
		{
			option_parent_text="",
			option_text="Visualize fire detection",
			option_note="Shows a cross where the mod thinks there is fire and where it spawns a particle",
            option_type="text",
			key="visualize_fire_detection",
			options={
				"ON",
				"OFF"
			}
		}
	}
}

function Settings.FireSim_Update()
    Settings.EditedSettings()
    Settings.SetValue("FireSim", "map_size", Settings.Storage.GetString("FireSim", "map_size"))
    Settings.SetValue("FireSim", "max_fire_spread_distance", Settings.Storage.GetFloat("FireSim", "max_fire_spread_distance"))
    Settings.SetValue("FireSim", "fire_reaction_time", Settings.Storage.GetFloat("FireSim", "fire_reaction_time"))
    Settings.SetValue("FireSim", "fire_update_time", Settings.Storage.GetFloat("FireSim", "fire_update_time"))
    Settings.SetValue("FireSim", "min_fire_distance", Settings.Storage.GetFloat("FireSim", "min_fire_distance"))
    Settings.SetValue("FireSim", "max_group_fire_distance", Settings.Storage.GetFloat("FireSim", "max_group_fire_distance"))
    Settings.SetValue("FireSim", "max_fire", Settings.Storage.GetFloat("FireSim", "max_fire"))
    Settings.SetValue("FireSim", "fire_intensity", Settings.Storage.GetString("FireSim", "fire_intensity"))
    Settings.SetValue("FireSim", "fire_intensity_multiplier", Settings.Storage.GetFloat("FireSim", "fire_intensity_multiplier"))
    Settings.SetValue("FireSim", "fire_intensity_minimum", Settings.Storage.GetFloat("FireSim", "fire_intensity_minimum"))
    Settings.SetValue("FireSim", "visualize_fire_detection", Settings.Storage.GetString("FireSim", "visualize_fire_detection"))
    Settings.SetValue("FireSim", "fire_explosion", Settings.Storage.GetString("FireSim", "fire_explosion"))
    Settings.SetValue("FireSim", "fire_damage", Settings.Storage.GetString("FireSim", "fire_damage"))
    Settings.SetValue("FireSim", "spawn_fire", Settings.Storage.GetString("FireSim", "spawn_fire"))
    Settings.SetValue("FireSim", "fire_damage_soft", Settings.Storage.GetFloat("FireSim", "fire_damage_soft"))
    Settings.SetValue("FireSim", "fire_damage_medium", Settings.Storage.GetFloat("FireSim", "fire_damage_medium"))
    Settings.SetValue("FireSim", "fire_damage_hard", Settings.Storage.GetFloat("FireSim", "fire_damage_hard"))
    Settings.SetValue("FireSim", "teardown_max_fires", Settings.Storage.GetFloat("FireSim", "teardown_max_fires"))
    Settings.SetValue("FireSim", "teardown_fire_spread", Settings.Storage.GetFloat("FireSim", "teardown_fire_spread"))
    Settings.SetValue("FireSim", "detect_inside", Settings.Storage.GetString("FireSim", "detect_inside"))
    Settings.SetValue("FireSim", "soot_sim", Settings.Storage.GetString("FireSim", "soot_sim"))
    Settings.SetValue("FireSim", "soot_dithering_max", Settings.Storage.GetFloat("FireSim", "soot_dithering_max"))
    Settings.SetValue("FireSim", "soot_dithering_min", Settings.Storage.GetFloat("FireSim", "soot_dithering_min"))
    Settings.SetValue("FireSim", "soot_max_size", Settings.Storage.GetFloat("FireSim", "soot_max_size"))
    Settings.SetValue("FireSim", "soot_min_size", Settings.Storage.GetFloat("FireSim", "soot_min_size"))
    Settings.SetValue("FireSim", "despawn_td_fire", Settings.Storage.GetString("FireSim", "despawn_td_fire"))
    Settings.SetValue("FireSim", "enable_sound", Settings.Storage.GetString("FireSim", "enable_sound"))
    Settings.SetValue("FireSim", "fire_sound_volume", Settings.Storage.GetFloat("FireSim", "fire_sound_volume"))
    Settings.SetValue("FireSim", "fire_sound_volume_random", Settings.Storage.GetFloat("FireSim", "fire_sound_volume_random"))
    Settings.SetValue("FireSim", "damage_sound_volume", Settings.Storage.GetFloat("FireSim", "damage_sound_volume"))
    Settings.SetValue("FireSim", "damage_sound_volume_random", Settings.Storage.GetFloat("FireSim", "damage_sound_volume_random"))
    Settings.StoreActivePreset()
end

function Settings.FireSim_Store()
    Settings.Storage.SetString("FireSim", "map_size", Settings.GetValue("FireSim", "map_size"))
    Settings.Storage.SetFloat("FireSim", "max_fire_spread_distance", Settings.GetValue("FireSim", "max_fire_spread_distance"))
    Settings.Storage.SetFloat("FireSim", "fire_reaction_time", Settings.GetValue("FireSim", "fire_reaction_time"))
    Settings.Storage.SetFloat("FireSim", "fire_update_time", Settings.GetValue("FireSim", "fire_update_time"))
    Settings.Storage.SetFloat("FireSim", "min_fire_distance", Settings.GetValue("FireSim", "min_fire_distance"))
    Settings.Storage.SetFloat("FireSim", "max_group_fire_distance", Settings.GetValue("FireSim", "max_group_fire_distance"))
    Settings.Storage.SetFloat("FireSim", "max_fire", Settings.GetValue("FireSim", "max_fire"))
    Settings.Storage.SetString("FireSim", "fire_intensity", Settings.GetValue("FireSim", "fire_intensity"))
    Settings.Storage.SetFloat("FireSim", "fire_intensity_multiplier", Settings.GetValue("FireSim", "fire_intensity_multiplier"))
    Settings.Storage.SetFloat("FireSim", "fire_intensity_minimum", Settings.GetValue("FireSim", "fire_intensity_minimum"))
    Settings.Storage.SetString("FireSim", "visualize_fire_detection", Settings.GetValue("FireSim", "visualize_fire_detection"))
    Settings.Storage.SetString("FireSim", "fire_explosion", Settings.GetValue("FireSim", "fire_explosion"))
    Settings.Storage.SetString("FireSim", "fire_damage", Settings.GetValue("FireSim", "fire_damage"))
    Settings.Storage.SetString("FireSim", "spawn_fire", Settings.GetValue("FireSim", "spawn_fire"))
    Settings.Storage.SetFloat("FireSim", "fire_damage_soft", Settings.GetValue("FireSim", "fire_damage_soft"))
    Settings.Storage.SetFloat("FireSim", "fire_damage_medium", Settings.GetValue("FireSim", "fire_damage_medium"))
    Settings.Storage.SetFloat("FireSim", "fire_damage_hard", Settings.GetValue("FireSim", "fire_damage_hard"))
    Settings.Storage.SetFloat("FireSim", "teardown_max_fires", Settings.GetValue("FireSim", "teardown_max_fires"))
    Settings.Storage.SetFloat("FireSim", "teardown_fire_spread", Settings.GetValue("FireSim", "teardown_fire_spread"))
    Settings.Storage.SetString("FireSim", "detect_inside", Settings.GetValue("FireSim", "detect_inside"))
    Settings.Storage.SetString("FireSim", "soot_sim", Settings.GetValue("FireSim", "soot_sim"))
    Settings.Storage.SetFloat("FireSim", "soot_dithering_max", Settings.GetValue("FireSim", "soot_dithering_max"))
    Settings.Storage.SetFloat("FireSim", "soot_max_size", Settings.GetValue("FireSim", "soot_max_size"))
    Settings.Storage.SetFloat("FireSim", "soot_dithering_min", Settings.GetValue("FireSim", "soot_dithering_min"))
    Settings.Storage.SetFloat("FireSim", "soot_min_size", Settings.GetValue("FireSim", "soot_min_size"))
    Settings.Storage.SetString("FireSim", "despawn_td_fire", Settings.GetValue("FireSim", "despawn_td_fire"))

    Settings.Storage.SetString("FireSim", "enable_sound", Settings.GetValue("FireSim", "enable_sound"))
    Settings.Storage.SetFloat("FireSim", "fire_sound_volume", Settings.GetValue("FireSim", "fire_sound_volume"))
    Settings.Storage.SetFloat("FireSim", "fire_sound_volume_random", Settings.GetValue("FireSim", "fire_sound_volume_random"))
    Settings.Storage.SetFloat("FireSim", "damage_sound_volume", Settings.GetValue("FireSim", "damage_sound_volume"))
    Settings.Storage.SetFloat("FireSim", "damage_sound_volume_random", Settings.GetValue("FireSim", "damage_sound_volume_random"))
    Settings.StoreActivePreset()
end

function Settings.FireSim_Default()
    Settings.LoadedSettings["FireSim"] = Settings.Template["FireSim"]
    Settings.FireSim_Store()
end

function Settings.FireSim_GetOptionsMenu()
    return {
        menu_title = "Fire Settings",
        sub_menus={
            {
                sub_menu_title="Fire Detection",
                options=Settings.FireSim_OptionsDetection,
                description="Change settings regarding fire detection, e.g. minimum distance, or the maximum size arround a fire it may use to detect intensity.\nNote: the size of the box to count fires is used to spawn lights in! Setting this 1:1 to minimum fire distance will make lights spawn for each detected fire!\n. Note: Teardown Max Fire and Fire Spread is part of the base game and has no relation to other fire spread settings in this mod!"
            },
            {
                sub_menu_title="Fire Intensity",
                options=Settings.FireSim_OptionsFireIntensity,
                description="Intensity settings that determine how big fire particles/smoke particles are when spawned. \n Intensity also influences the damage if enabled, light intensity if enabled, \n and spreading if enabled (spawn fire), which are configured in the other menus!"
            },
            {
                sub_menu_title="Fire Spread",
                options=Settings.FireSim_OptionsFireSpread,
                description="The fire spread menu contains options that influence the fire spreading behavior. \n Note: Teardown Max Fire and Fire Spread is part of the base game and has no relation to other fire spread settings in this mod!\nNote: The Despawn Teardown Fire allows for more ThiccSmoke & ThiccFire particles to be spawned but can be buggy! Disable if experiencing issues!."
            },
            {
                sub_menu_title="Fire Damage",
                options=Settings.FireSim_OptionsFireDamage,
                description="This mode allows fires to do extra damage to buildings, beyond the existing fire damage model. \nNote that to much damage can actually put out flames. "
            },
            {
                sub_menu_title="Fire Soot",
                options=Settings.FireSim_OptionsFireSoot,
                description="Fire soot simulation settings, since update 0.9.4 teardown this mod is able to simulate soot trails created by smoke \neven though no fire is really near. \nNote, only available in Teardown 0.9.4 and up, will be disabled otherwise."
            },
            {
                sub_menu_title="Sound",
                options=Settings.FireSim_OptionsFireSound,
                description="Since this sim is completely separate from the teardowns fire simulations, it has its own sound as well!"
            },
            {
                sub_menu_title="Debugging",
                options=Settings.FireSim_OptionsDebugging,
                description="If your settings are behaving weird, fire is spawning weird, \nyou can see where fires are detected and the intensity of the fire \n (how greener the box, the more intense the fire).,"
            }
        }
    }
end

--- General  module
Settings.GeneralOptions_Options =
{
	module="general",
	prefix_key=nil,
	buttons={
		{
			text = "Set Default",
			callback=function() Settings.GeneralOptions_Default() end,
		},
	},
	update=function() Settings.GeneralOptions_Update() end,
	option_items={
		{
			option_parent_text="",
			option_text="Show or Hide Menu Key",
			option_note="Set key to show or hide the menu while in game. Click on the letter and press key to change.",
			option_type="input_key",
			key="toggle_menu_key",
		},
		{
			option_parent_text="",
			option_text="Show UI In Game",
			option_note="Shows mod status and key bind text in game.",
			option_type="text",
			key="ui_in_game",
			options={
				"YES",
				"NO"
			}
		},
		{
			option_parent_text="",
			option_text="Enable Debug",
			option_note="Enable debug prints to screen (warning: spam).",
			option_type="text",
			key="debug",
			options={
				"YES",
				"NO"
			}
		},
	}
}

function Settings.GeneralOptions_Update()
    Settings.SetValue("GeneralOptions", "toggle_menu_key", Settings.Storage.GetString("general", "toggle_menu_key"))
    Settings.SetValue("GeneralOptions", "ui_in_game", Settings.Storage.GetString("general", "ui_in_game"))
    Settings.SetValue("GeneralOptions", "debug", Settings.Storage.GetString("general", "debug"))
    Settings.SetValue("GeneralOptions", "enabled", Settings.Storage.GetString("general", "enabled"))
    Settings.StoreActivePreset()
end

function Settings.GeneralOptions_Store()
    Settings.Storage.SetString("general", "toggle_menu_key", Settings.GetValue("GeneralOptions", "toggle_menu_key"))
    Settings.Storage.SetString("general", "ui_in_game", Settings.GetValue("GeneralOptions", "ui_in_game"))
    Settings.Storage.SetString("general", "debug", Settings.GetValue("GeneralOptions", "debug"))
    Settings.Storage.SetString("general", "enabled", Settings.GetValue("GeneralOptions", "enabled"))
    Settings.StoreActivePreset()
end

function Settings.GeneralOptions_Default()
    Settings.LoadedSettings["GeneralOptions"] = Settings.Template["GeneralOptions"]
    Settings.GeneralOptions_Store()
end

function Settings.GeneralOptions_GetOptionsMenu()
	return {
		menu_title = "General Settings",
		sub_menus={
			{
				sub_menu_title="General Options",
				options=Settings.GeneralOptions_Options,
			}
		}
	}
end

--- Particle Spawner module

Settings.ParticleSpawner_FrameRate_Options =
{
	module="particlespawner",
	prefix_key=nil,
    buttons={
		{
			text = "Set Default",
			callback=function() Settings.ParticleSpawner_Default() end,
		},
    },
	update=function() Settings.ParticleSpawner_Update() end,
	option_items={
        {
            option_parent_text="",
            option_text="Dynamic FPS Adjust",
            option_note="Adjust based on fps. If disabled, only the max values will apply!",
            option_type="text",
            key="dynamic_fps",
            options={"ON", "OFF"}
        },
        {
            option_parent_text="",
            option_text="FPS Target",
            option_note="Note: only taken into account when your FPS is above this value!",
            option_type="float",
            key="dynamic_fps_target",
            min_max={29, 60, 1}
        },
        {
            option_parent_text="",
            option_text="Particle Refresh Rate",
            option_note="Maximum particle spawn refresh rate per second (note will automatically adjust if fps is below target (more = thicker smoke).",
            option_type="float",
            key="particle_refresh_max",
            min_max={1, 60, 1}
        },
        {
            option_parent_text="",
            option_text="Min Particle Refresh Rate",
            option_note="Minimum particle spawn refresh rate per second.",
            option_type="float",
            key="particle_refresh_min",
            min_max={1, 60, 1}
        },
        {
            option_parent_text="",
            option_text="Adjust Aggressivenes",
            option_note="How quick parameters should be adjusted after dipping below target.",
            option_type="float",
            key="aggressivenes",
            min_max={0.01, 1.0, 0.01}
        }
	}
}

Settings.ParticleSpawner_Particle_Options =
{
	module="particlespawner",
	prefix_key=nil,
    buttons={
		{
			text = "Set Default",
			callback=function() Settings.ParticleSpawner_Default() end,
		},
    },
	update=function() Settings.ParticleSpawner_Update() end,
	option_items={
        {
            option_parent_text="",
            option_text="Spawn Smoke Particles",
            option_note="Enable this to spawn smoke particles",
            option_type="text",
            key="smoke",
            options={"YES", "NO"}
        },
        {
            option_parent_text="",
            option_text="Spawn Fire Particles",
            option_note="Enable this to spawn fire particles",
            option_type="text",
            key="fire",
            options={"YES", "NO"}
        },
        {
            option_parent_text="",
            option_text="Spawn Ash Particles",
            option_note="Enable this to spawn ash particles",
            option_type="text",
            key="ash",
            options={"YES", "NO"}
        },
        {
            option_parent_text="",
            option_text="Fire to Smoke ratio",
            option_note="How many fire particles per spawning of smoke particles should spawn. (e.g. 1 fire every 8 smoke particles)",
            option_type="text",
            key="fire_to_smoke_ratio",
            options={"1:1", "1:2", "1:4", "1:8", "1:15", "1:30", "1:60"}
        },
        {
            option_parent_text="",
            option_text="Ash to Smoke ratio",
            option_note="How many ash particles per spawning of smoke particles should spawn. (e.g. 1 ash particle every 8 smoke particles)",
            option_type="text",
            key="ash_to_smoke_ratio",
            options={"1:1", "1:2", "1:4", "1:8", "1:15", "1:30", "1:60"}
        }
	}
}



function Settings.ParticleSpawner_Update()
    Settings.EditedSettings()
    Settings.SetValue("ParticleSpawner", "fire", Settings.Storage.GetString("particlespawner", "fire"))
    Settings.SetValue("ParticleSpawner", "smoke", Settings.Storage.GetString("particlespawner", "smoke"))
    Settings.SetValue("ParticleSpawner", "ash", Settings.Storage.GetString("particlespawner", "ash"))
    Settings.SetValue("ParticleSpawner", "fire_to_smoke_ratio", Settings.Storage.GetString("particlespawner", "fire_to_smoke_ratio"))
    Settings.SetValue("ParticleSpawner", "ash_to_smoke_ratio", Settings.Storage.GetString("particlespawner", "ash_to_smoke_ratio"))
    Settings.SetValue("ParticleSpawner", "dynamic_fps", Settings.Storage.GetString("particlespawner", "dynamic_fps"))
    Settings.SetValue("ParticleSpawner", "dynamic_fps_target", Settings.Storage.GetFloat("particlespawner", "dynamic_fps_target"))
    Settings.SetValue("ParticleSpawner", "particle_refresh_max", Settings.Storage.GetFloat("particlespawner", "particle_refresh_max"))
    Settings.SetValue("ParticleSpawner", "particle_refresh_min", Settings.Storage.GetFloat("particlespawner", "particle_refresh_min"))
    Settings.SetValue("ParticleSpawner", "aggressivenes", Settings.Storage.GetFloat("particlespawner", "aggressivenes"))
    Settings.StoreActivePreset()
end

function Settings.ParticleSpawner_Store()
    Settings.Storage.SetString("particlespawner", "fire", Settings.GetValue("ParticleSpawner", "fire"))
    Settings.Storage.SetString("particlespawner", "smoke", Settings.GetValue("ParticleSpawner", "smoke"))
    Settings.Storage.SetString("particlespawner", "ash", Settings.GetValue("ParticleSpawner", "ash"))
    Settings.Storage.SetString("particlespawner", "fire_to_smoke_ratio", Settings.GetValue("ParticleSpawner", "fire_to_smoke_ratio"))
    Settings.Storage.SetString("particlespawner", "ash_to_smoke_ratio", Settings.GetValue("ParticleSpawner", "ash_to_smoke_ratio"))
    Settings.Storage.SetString("particlespawner", "dynamic_fps", Settings.GetValue("ParticleSpawner", "dynamic_fps"))
    Settings.Storage.SetFloat("particlespawner", "dynamic_fps_target", Settings.GetValue("ParticleSpawner", "dynamic_fps_target"))
    Settings.Storage.SetFloat("particlespawner", "particle_refresh_max", Settings.GetValue("ParticleSpawner", "particle_refresh_max"))
    Settings.Storage.SetFloat("particlespawner", "particle_refresh_min", Settings.GetValue("ParticleSpawner", "particle_refresh_min"))
    Settings.Storage.SetFloat("particlespawner", "aggressivenes", Settings.GetValue("ParticleSpawner", "aggressivenes"))
    Settings.StoreActivePreset()
end

function Settings.ParticleSpawner_Default()
    Settings.LoadedSettings["ParticleSpawner"] = Settings.Template["ParticleSpawner"]
    Settings.ParticleSpawner_Store()
end

function Settings.ParticleSpawner_GetOptionsMenu()
	return {
		menu_title = "Particle Spawner Settings",
		sub_menus={
			{
				sub_menu_title="Frame Rate Control",
				options=Settings.ParticleSpawner_FrameRate_Options,
                description="This menu allows for controlling frame rate dependent particle spawning, to hopefully keep frame rate playable (but can have huge impact on visuals)."
			},
			{
				sub_menu_title="Particle Settings",
				options=Settings.ParticleSpawner_Particle_Options,
                description="This menu allows for particle related settings to be changed, e.g. which particles can be spawned and in what ratio!\nNote: go to Particle Settings main menu for more detailed particle settings."
			}
		}
	}
end

--- Particle module
Settings.General_Particle_Options =
{
	module="particle",
	prefix_key=nil,
	buttons={
		{
			text="Set default",
			callback=function() Settings.Particle_Default() end,
		}
	},
	update=function() Settings.Particle_Update() end,
	option_items={
		{
			option_parent_text="",
			option_text="Intensity",
			option_note="Applies offset to radius on all materials.",
			option_type="text",
			key="intensity_mp",
			options={
				"Use Material Property",
				"Potato PC",
				"Somewhat Ok",
				"Realistic",
				"This is fine (meme)",
				"Fry my PC"
			}
		},
		{
			option_parent_text="",
			option_text="Drag",
			option_note="Applies offset to drag on all materials.",
			option_type="text",
			key="drag_mp",
			options={
				"Use Material Property",
				"Low",
				"Medium",
				"High"
			}
		},
		{
			option_parent_text="",
			option_text="Gravity",
			option_note="Applies offset to gravity on all materials.",
			option_type="text",
			key="gravity_mp",
			options={
				"Use Material Property",
				"Upwards Low",
				"Upwards High",
				"Downwards Low",
				"Downwards High"
			}
		},
		{
			option_parent_text="",
			option_text="Lifetime",
			option_note="Multiples configured lifetime per material.",
			option_type="text",
			key="lifetime_mp",
			options={
				"1x",
				"2x",
				"4x",
				"8x",
				"16x"
			}
		},
        {
            option_parent_text="",
            option_text="Intensity modifier",
            option_note="Configure how the fire intensity_mp (see fire detection settings) affects particles (size and gravity_mp).",
            option_type="float",
            key="intensity_scale",
            min_max={1, 10.0, 0.05}
        },
        {
            option_parent_text="",
            option_text="Particle Min Distance Padding",
            option_note="Prevent spawning overlapping particles (by this mod)",
            option_type="float",
            key="min_particle_dist",
            min_max={0.05, 4, 0.05}
        },
        {
            option_parent_text="",
            option_text="Particle Randomness",
            option_note="To make the fire feel more alive/less static, 0.05 = max randomness, 1 = no randomness",
            option_type="float",
            key="randomness",
            min_max={0.05, 1, 0.05}
        },
        {
            option_parent_text="",
            option_text="Particle Location Randomness",
            option_note="Spread around location, makes it less static.",
            option_type="float",
            key="location_randomness",
            min_max={0.1, 10, 0.1}
        },
        {
            option_parent_text="",
            option_text="Particle Duplicator",
            option_note="To make your PC cry, instead of spawning 1 particle, spawn multiple per instance.",
            option_type="float",
            key="duplicator",
            min_max={1, 20, 1}
        }
	}
}

Settings.Smoke_Particle_Options =
{
	module="particle",
	prefix_key=nil,
	buttons={
		{
			text="Set default",
			callback=function() Settings.Particle_Default() end,
		}
	},
	update=function() Settings.Particle_Update() end,
	option_items={

		{
			option_parent_text="",
			option_text="Smoke Fade In (%)",
			option_note="Percentage of time it takes to fade in smoke",
			option_type="float",
			key="smoke_fadein",
			min_max={0, 100, 1}
		},
		{
			option_parent_text="",
			option_text="Smoke Fade Out (%)",
			option_note="Percentage of time it takes to fade in smoke",
			option_type="float",
			key="smoke_fadeout",
			min_max={0, 100, 1}
		}
	}
}

Settings.Fire_Particle_Options =
{
	module="particle",
	prefix_key=nil,
	buttons={
		{
			text="Set default",
			callback=function() Settings.Particle_Default() end,
		}
	},
	update=function() Settings.Particle_Update() end,
	option_items={
		{
			option_parent_text="",
			option_text="Embers",
			option_note="Amount of embers fire can produce.",
			option_type="text",
			key="embers",
			options={
				"OFF",
				"LOW",
				"HIGH",
			}
		},
		{
			option_parent_text="",
			option_text="Fire Fade In (%)",
			option_note="Percentage of time it takes to fade in fire",
			option_type="float",
			key="fire_fadein",
			min_max={0, 100, 1}
		},
		{
			option_parent_text="",
			option_text="Fire Fade Out (%)",
			option_note="Percentage of time it takes to fade in fire",
			option_type="float",
			key="fire_fadeout",
			min_max={0, 100, 1}
		},
		{
			option_parent_text="",
			option_text="Fire Emissiveness",
			option_note="Sets how emissive the fire starts out",
			option_type="float",
			key="fire_emissive",
			min_max={1, 10, 1}
		},
	}
}

Settings.Ash_Particle_Options =
{
	module="particle",
	prefix_key=nil,
	buttons={
		{
			text="Set default",
			callback=function() Settings.Particle_Default() end,
		}
	},
	update=function() Settings.Particle_Update() end,
	option_items={
        {
            option_parent_text="",
            option_text="Lifetime",
            option_note="How long ash particles may exist in the world (higher == lower fps)",
            option_type="float",
            key="ash_life",
            min_max={1, 50, 1}
        },
        {
            option_parent_text="",
            option_text="Gravity Min",
            option_note="Change the minimum gravity that can pull on ash particles. (Always downwards == negative)",
            option_type="float",
            key="ash_gravity_min",
            min_max={-50, 50, 1,
            {
                {
                    related="ash_gravity_max",
                    type=">"
                }
            }}
        },
        {
            option_parent_text="",
            option_text="Gravity Max",
            option_note="Change the maximum gravity that can pull on ash particles. (Always downwards == negative)",
            option_type="float",
            key="ash_gravity_max",
            min_max={-50, 50, 1,
            {
                {
                    related="ash_gravity_min",
                    type="<"
                }
            }}
        },
        {
            option_parent_text="",
            option_text="Max Rotational Speed",
            option_note="Maximum rotational speed of the ash particles",
            option_type="float",
            key="ash_rot_max",
            min_max={0, 10, 0.1,
            {
                {
                    related="ash_rot_min",
                    type=">"
                }
            }}
        },
        {
            option_parent_text="",
            option_text="Min Rotational Speed",
            option_note="Minimum rotational speed of the ash particles",
            option_type="float",
            key="ash_rot_min",
            min_max={0, 10, 0.1,
            {
                {
                    related="ash_rot_max",
                    type="<"
                }
            }}
        },
        {
            option_parent_text="",
            option_text="Max Stickyness",
            option_note="Maximum stickyness of ash particles",
            option_type="float",
            key="ash_sticky_max",
            min_max={0, 10, 0.1,
            {
                {
                    related="ash_sticky_min",
                    type=">"
                }
            }}
        },
        {
            option_parent_text="",
            option_text="Min Stickyness",
            option_note="Minimum stickyness of ash particles",
            option_type="float",
            key="ash_sticky_min",
            min_max={0, 10, 0.1,
            {
                {
                    related="ash_sticky_max",
                    type="<"
                }
            }}
        },
        {
            option_parent_text="",
            option_text="Max Drag",
            option_note="Maximum drag of ash particles",
            option_type="float",
            key="ash_drag_max",
            min_max={0, 10, 0.1,
            {
                {
                    related="ash_drag_min",
                    type=">"
                }
            }}
        },
        {
            option_parent_text="",
            option_text="Min Drag",
            option_note="Minimum drag of ash particles",
            option_type="float",
            key="ash_drag_min",
            min_max={0, 10, 0.1,
            {
                {
                    related="ash_drag_max",
                    type="<"
                }
            }}
        },
        {
            option_parent_text="",
            option_text="Max Size",
            option_note="Maximum size of ash particles",
            option_type="float",
            key="ash_size_max",
            min_max={0.01, 0.25, 0.01,
            {
                {
                    related="ash_size_min",
                    type=">"
                }
            }}
        },
        {
            option_parent_text="",
            option_text="Min Size",
            option_note="Minimum size of ash particles",
            option_type="float",
            key="ash_size_min",
            min_max={0.01, 0.25, 0.01,
            {
                {
                    related="ash_size_max",
                    type="<"
                }
            }}
        }
	}
}

Settings.Debug_Particle_Options =
{
	module="particle",
	prefix_key=nil,
	buttons={
		{
			text="Set default",
			callback=function() Settings.Particle_Default() end,
		}
	},
	update=function() Settings.Particle_Update() end,
	option_items={
        {
            option_parent_text="",
            option_text="Particle Min Distance Padding",
            option_note="Prevent spawning overlapping particles (by this mod)",
            option_type="float",
            key="min_particle_dist",
            min_max={0.05, 4, 0.05}
        },
		{
			option_parent_text="",
			option_text="Visualize Spawn Locations",
			option_note="Shows a box where the mod spawns particles (used to tune particle distance)",
            option_type="text",
			key="visualize_spawn_locations",
			options={
				"ON",
				"OFF"
			}
		}
	}
}

function Settings.Particle_Update()
    Settings.EditedSettings()
    Settings.SetValue("Particle", "intensity_mp", Settings.Storage.GetString("particle", "intensity_mp"))
    Settings.SetValue("Particle", "drag_mp", Settings.Storage.GetString("particle", "drag_mp"))
    Settings.SetValue("Particle", "gravity_mp", Settings.Storage.GetString("particle", "gravity_mp"))
    Settings.SetValue("Particle", "lifetime_mp", Settings.Storage.GetString("particle", "lifetime_mp"))
    Settings.SetValue("Particle", "intensity_scale", Settings.Storage.GetFloat("particle", "intensity_scale"))
    Settings.SetValue("Particle", "randomness", Settings.Storage.GetFloat("particle", "randomness"))
    Settings.SetValue("Particle", "min_particle_dist", Settings.Storage.GetFloat("particle", "min_particle_dist"))
    Settings.SetValue("Particle", "location_randomness", Settings.Storage.GetFloat("particle", "location_randomness"))
    Settings.SetValue("Particle", "duplicator", Settings.Storage.GetFloat("particle", "duplicator"))
    Settings.SetValue("Particle", "smoke_fadein", Settings.Storage.GetFloat("particle", "smoke_fadein"))
    Settings.SetValue("Particle", "smoke_fadeout", Settings.Storage.GetFloat("particle", "smoke_fadeout"))
    Settings.SetValue("Particle", "fire_fadein", Settings.Storage.GetFloat("particle", "fire_fadein"))
    Settings.SetValue("Particle", "fire_fadeout", Settings.Storage.GetFloat("particle", "fire_fadeout"))
    Settings.SetValue("Particle", "fire_emissive", Settings.Storage.GetFloat("particle", "fire_emissive"))
    Settings.SetValue("Particle", "embers", Settings.Storage.GetString("particle", "embers"))

    Settings.SetValue("Particle", "ash_gravity_min", Settings.Storage.GetFloat("particle", "ash_gravity_min"))
    Settings.SetValue("Particle", "ash_gravity_max", Settings.Storage.GetFloat("particle", "ash_gravity_max"))
    Settings.SetValue("Particle", "ash_rot_max", Settings.Storage.GetFloat("particle", "ash_rot_max"))
    Settings.SetValue("Particle", "ash_rot_min", Settings.Storage.GetFloat("particle", "ash_rot_min"))
    Settings.SetValue("Particle", "ash_sticky_max", Settings.Storage.GetFloat("particle", "ash_sticky_max"))
    Settings.SetValue("Particle", "ash_sticky_min", Settings.Storage.GetFloat("particle", "ash_sticky_min"))
    Settings.SetValue("Particle", "ash_drag_max", Settings.Storage.GetFloat("particle", "ash_drag_max"))
    Settings.SetValue("Particle", "ash_drag_min", Settings.Storage.GetFloat("particle", "ash_drag_min"))
    Settings.SetValue("Particle", "ash_size_max", Settings.Storage.GetFloat("particle", "ash_size_max"))
    Settings.SetValue("Particle", "ash_size_min", Settings.Storage.GetFloat("particle", "ash_size_min"))
    Settings.SetValue("Particle", "ash_life", Settings.Storage.GetFloat("particle", "ash_life"))

    Settings.SetValue("Particle", "visualize_spawn_locations", Settings.Storage.GetString("particle", "visualize_spawn_locations"))
    Settings.StoreActivePreset()
end

function Settings.Particle_Store()
    Settings.Storage.SetString("particle", "intensity_mp", Settings.GetValue("Particle", "intensity_mp"))
    Settings.Storage.SetString("particle", "drag_mp", Settings.GetValue("Particle", "drag_mp"))
    Settings.Storage.SetString("particle", "gravity_mp", Settings.GetValue("Particle", "gravity_mp"))
    Settings.Storage.SetString("particle", "lifetime_mp", Settings.GetValue("Particle", "lifetime_mp"))
    Settings.Storage.SetFloat("particle", "intensity_scale", Settings.GetValue("Particle", "intensity_scale"))
    Settings.Storage.SetFloat("particle", "randomness", Settings.GetValue("Particle", "randomness"))
    Settings.Storage.SetFloat("particle", "min_particle_dist", Settings.GetValue("Particle", "min_particle_dist"))
    Settings.Storage.SetFloat("particle", "location_randomness", Settings.GetValue("Particle", "location_randomness"))
    Settings.Storage.SetFloat("particle", "duplicator", Settings.GetValue("Particle", "duplicator"))
    Settings.Storage.SetFloat("particle", "smoke_fadein", Settings.GetValue("Particle", "smoke_fadein"))
    Settings.Storage.SetFloat("particle", "smoke_fadeout", Settings.GetValue("Particle", "smoke_fadeout"))
    Settings.Storage.SetFloat("particle", "fire_fadein", Settings.GetValue("Particle", "fire_fadein"))
    Settings.Storage.SetFloat("particle", "fire_fadeout", Settings.GetValue("Particle", "fire_fadeout"))
    Settings.Storage.SetFloat("particle", "fire_emissive", Settings.GetValue("Particle", "fire_emissive"))
    Settings.Storage.SetString("particle", "embers", Settings.GetValue("Particle", "embers"))

    Settings.Storage.SetFloat("particle", "ash_gravity_min", Settings.GetValue("Particle", "ash_gravity_min"))
    Settings.Storage.SetFloat("particle", "ash_gravity_max", Settings.GetValue("Particle", "ash_gravity_max"))
    Settings.Storage.SetFloat("particle", "ash_rot_max", Settings.GetValue("Particle", "ash_rot_max"))
    Settings.Storage.SetFloat("particle", "ash_rot_min", Settings.GetValue("Particle", "ash_rot_min"))
    Settings.Storage.SetFloat("particle", "ash_sticky_max", Settings.GetValue("Particle", "ash_sticky_max"))
    Settings.Storage.SetFloat("particle", "ash_sticky_min", Settings.GetValue("Particle", "ash_sticky_min"))
    Settings.Storage.SetFloat("particle", "ash_drag_max", Settings.GetValue("Particle", "ash_drag_max"))
    Settings.Storage.SetFloat("particle", "ash_drag_min", Settings.GetValue("Particle", "ash_drag_min"))
    Settings.Storage.SetFloat("particle", "ash_size_max", Settings.GetValue("Particle", "ash_size_max"))
    Settings.Storage.SetFloat("particle", "ash_size_min", Settings.GetValue("Particle", "ash_size_min"))
    Settings.Storage.SetFloat("particle", "ash_life", Settings.GetValue("Particle", "ash_life"))

    Settings.Storage.SetString("particle", "visualize_spawn_locations", Settings.GetValue("Particle", "visualize_spawn_locations"))
    Settings.StoreActivePreset()
end

function Settings.Particle_Default()
    Settings.LoadedSettings["Particle"] = Settings.Template["Particle"]
    Settings.Particle_Store()
end

function Settings.Particle_GetOptionsMenu()
	return {
		menu_title = "Particle Settings",
		sub_menus={
			{
				sub_menu_title="General",
				options=Settings.General_Particle_Options,
                description="These settings are applied to all particles (independent of the material), for some quick adjustments if necessary."
			},
			{
				sub_menu_title="Fire",
				options=Settings.Fire_Particle_Options,
                description="These settings are applied to all fire particles (independent of the material), for some quick adjustments if necessary.\n Note: only available if fire particles is enabled in Particle Spawner Settings.Menu."
			},
			{
				sub_menu_title="Smoke",
				options=Settings.Smoke_Particle_Options,
                description="These settings are applied to all smoke particles (independent of the material), for some quick adjustments if necessary.\n Note: only available if smoke particles is enabled in Particle Spawner Settings.Menu."
			},
			{
				sub_menu_title="Ash",
				options=Settings.Ash_Particle_Options,
                description="These settings are applied to all ash particles (independent of the material), for some quick adjustments if necessary.\n Note: only available if ash particles is enabled in Particle Spawner Settings.Menu."
			},
			{
				sub_menu_title="Debug",
				options=Settings.Debug_Particle_Options,
                description="These settings are used for debug and tuning purposes of general particle spawn behavior."
			}
		}
	}
end

Settings.Wind_General_Options =
{
	module="wind",
	prefix_key=nil,
	buttons={
		{
			text="Set default",
			callback=function() Settings.Wind_Default() end,
		}
	},
	update=function() Settings.Wind_Update() end,
	option_items={
        {
            option_parent_text="",
            option_text="Enable Wind",
            option_note="Uses the environment property to generate a wind",
            option_type="text",
            key="wind",
            options={"YES", "NO"}
        },
		{
			option_parent_text="",
			option_text="Wind Direction",
			option_note="Wind direction in degrees.",
			option_type="float",
			key="winddirection",
			min_max={0, 360, 1}
		},
		{
			option_parent_text="",
			option_text="Wind Direction Randomness",
			option_note="Wind direction randomness (min/max deviation from base direction).",
			option_type="float",
			key="winddirectionrandom",
			min_max={0, 360, 1}
		},
		{
			option_parent_text="",
			option_text="Wind Direction Change Rate",
			option_note="Wind direction change rate, 1 is slowest, 100 is fastest.",
			option_type="float",
			key="winddirectionrandomrate",
			min_max={1, 100, 1}
		},
		{
			option_parent_text="",
			option_text="Wind Strength",
			option_note="Strength of the wind.",
			option_type="float",
			key="windstrength",
			min_max={0.1, 20, 1}
		},
		{
			option_parent_text="",
			option_text="Wind Strength Randomness",
			option_note="How much the strenght can vary.",
			option_type="float",
			key="windstrengthrandom",
			min_max={0, 50, 1}
		},
		{
			option_parent_text="",
			option_text="Wind Strength Change Rate",
			option_note="Rate of changes, 1 is slowest, 100 is fastest.",
			option_type="float",
			key="windstrengthrandomrate",
			min_max={1, 100, 1}
		},
	}
}

function Settings.Wind_Update()
    Settings.EditedSettings()
    Settings.SetValue("Wind", "wind", Settings.Storage.GetString("wind", "wind"))
    Settings.SetValue("Wind", "winddirection", Settings.Storage.GetFloat("wind", "winddirection"))
    Settings.SetValue("Wind", "winddirectionrandom", Settings.Storage.GetFloat("wind", "winddirectionrandom"))
    Settings.SetValue("Wind", "winddirectionrandomrate", Settings.Storage.GetFloat("wind", "winddirectionrandomrate"))
    Settings.SetValue("Wind", "windstrength", Settings.Storage.GetFloat("wind", "windstrength"))
    Settings.SetValue("Wind", "windstrengthrandom", Settings.Storage.GetFloat("wind", "windstrengthrandom"))
    Settings.SetValue("Wind", "windstrengthrandomrate", Settings.Storage.GetFloat("wind", "windstrengthrandomrate"))
    Settings.StoreActivePreset()
end

function Settings.Wind_Store()
    Settings.Storage.SetString("wind", "wind", Settings.GetValue("Wind", "wind"))
    Settings.Storage.SetFloat("wind", "winddirection", Settings.GetValue("Wind", "winddirection"))
    Settings.Storage.SetFloat("wind", "winddirectionrandom",  Settings.GetValue("Wind", "winddirectionrandom"))
    Settings.Storage.SetFloat("wind", "winddirectionrandomrate",  Settings.GetValue("Wind", "winddirectionrandomrate"))
    Settings.Storage.SetFloat("wind", "windstrength", Settings.GetValue("Wind", "windstrength"))
    Settings.Storage.SetFloat("wind", "windstrengthrandom",  Settings.GetValue("Wind", "windstrengthrandom"))
    Settings.Storage.SetFloat("wind", "windstrengthrandomrate",  Settings.GetValue("Wind", "windstrengthrandomrate"))
    Settings.StoreActivePreset()
end

function Settings.Wind_Default()
    Settings.LoadedSettings["Wind"] = Settings.Template["Wind"]
    Settings.Wind_Store()
end

function Settings.Wind_GetOptionsMenu()
	return {
		menu_title = "Wind Settings",
		sub_menus={
			{
				sub_menu_title="General",
				options=Settings.Wind_General_Options,
                description="Configure the wind."
			}
		}
	}
end

Settings.Light_General_Options =
{
	module="light",
	prefix_key=nil,
    buttons={
		{
			text = "Set Default",
			callback=function() Settings.Light_Default() end,
		},
    },
	update=function() Settings.Light_Update() end,
	option_items={
        {
            option_parent_text="",
            option_text="Enable Light",
            option_note="Spawn lights to simulate fire emitting more intense light.",
            option_type="text",
            key="spawn_light",
            options={"ON", "OFF"}
        },
        {
            option_parent_text="",
            option_text="Light Flickering Intensity",
            option_note="Note: changes how much the light flickers, which is based on the fire intensity.",
            option_type="float",
            key="light_flickering_intensity",
            min_max={1, 10, 1}
        },
        {
            option_parent_text="",
            option_text="Light Brightness",
            option_note="Note: Changes the brightness, 0.1 == 10%, 1 = 100%,  brightness also depends on fire intensity but cannot go > 100%",
            option_type="float",
            key="light_intensity",
            min_max={0.01, 1, 0.01}
        },
        {
            optiYES_parent_text="",
            option_text="Red Light Offset",
            option_note="Note: Light color is based on fire color, offset can be used to make adjustments to the light specifically!",
            option_type="float",
            key="red_light_offset",
            min_max={-1, 1, 0.05}
        },
        {
            option_parent_text="",
            option_text="Green Light Offset",
            option_note="Note: Light color is based on fire color, offset can be used to make adjustments to the light specifically!",
            option_type="float",
            key="green_light_offset",
            min_max={-1, 1, 0.05}
        },
        {
            option_parent_text="",
            option_text="Blue Light Offset",
            option_note="Note: Light color is based on fire color, offset can be used to make adjustments to the light specifically!",
            option_type="float",
            key="blue_light_offset",
            min_max={-1, 1, 0.05}
        },
	}
}

function Settings.Light_Update()
    Settings.EditedSettings()
    Settings.SetValue("Light", "spawn_light", Settings.Storage.GetString("light", "spawn_light"))
    Settings.SetValue("Light", "red_light_offset", Settings.Storage.GetFloat("light", "red_light_offset"))
    Settings.SetValue("Light", "green_light_offset", Settings.Storage.GetFloat("light", "green_light_offset"))
    Settings.SetValue("Light", "blue_light_offset", Settings.Storage.GetFloat("light", "blue_light_offset"))
    Settings.SetValue("Light", "light_intensity", Settings.Storage.GetFloat("light", "light_intensity"))
    Settings.SetValue("Light", "light_flickering_intensity", Settings.Storage.GetFloat("light", "light_flickering_intensity"))
    Settings.StoreActivePreset()
end

function Settings.Light_Store()
    Settings.Storage.SetString("light", "spawn_light", Settings.GetValue("Light", "spawn_light"))
    Settings.Storage.SetFloat("light", "red_light_offset", Settings.GetValue("Light", "red_light_offset"))
    Settings.Storage.SetFloat("light", "green_light_offset", Settings.GetValue("Light", "green_light_offset"))
    Settings.Storage.SetFloat("light", "blue_light_offset", Settings.GetValue("Light", "blue_light_offset"))
    Settings.Storage.SetFloat("light", "light_intensity", Settings.GetValue("Light", "light_intensity"))
    Settings.Storage.SetFloat("light", "light_flickering_intensity", Settings.GetValue("Light", "light_flickering_intensity"))
    Settings.StoreActivePreset()
end

function Settings.Light_Default()
    Settings.LoadedSettings["Light"] = Settings.Template["Light"]
    Settings.Light_Store()
end

function Settings.Light_GetOptionsMenu()
	return {
		menu_title = "Light Settings",
		sub_menus={
			{
				sub_menu_title="General",
				options=Settings.Light_General_Options,
                description="Configure the Light."
			}
		}
	}
end


