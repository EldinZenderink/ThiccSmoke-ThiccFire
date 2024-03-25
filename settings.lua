-- settings.lua
-- @date 2021-10-30
-- @author Eldin Zenderink
-- @brief This module should provide a centralized system for maintaining and grouping settings, to allow for easier adjustments, restore funcitonalities etc.
--        Every module will have their properties  stored and accessed from here. Menus will also be generated from here. Presets will be created in separated modules based on this module. Catagorizing settings will be done through here.

Settings_UpdateCallbacks = {}

Settings_Template ={
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
    Wind            = {
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
        despawn_td_fire = "YES"
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
    Light           = {
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

_LoadedSettings = {}

function Settings_Init(default)
    local active_preset = Storage_GetString("settings", "active_preset")
    if default or active_preset == "" then
        Settings_SetDefault()
    else
        Settings_CreatePreset(Preset_Settings_SlipperyGypsy)
        Settings_CreatePreset(Preset_Settings_Ultra)
        Settings_CreatePreset(Preset_Settings_High)
        Settings_CreatePreset(Preset_Settings_Medium)
        Settings_CreatePreset(Preset_Settings_Low)
        Storage_SetString("settings", "active_preset", active_preset)
        Settings_LoadActivePreset()
    end
end

function Settings_LoadMenu()
    Settings_StoreAll()
    Menu_AppendMenu(Settings_GeneralOptions_GetOptionsMenu())
    Menu_AppendMenu(Settings_GetPresetMenu())
    Menu_AppendMenu(Settings_FireSim_GetOptionsMenu())
    Menu_AppendMenu(Settings_Wind_GetOptionsMenu())
    Menu_AppendMenu(Settings_Light_GetOptionsMenu())
    Menu_AppendMenu(Settings_ParticleSpawner_GetOptionsMenu())
    Menu_AppendMenu(Settings_Particle_GetOptionsMenu())
    Menu_AppendMenu(Settings_FireMaterial_GetOptionsMenu())
    Menu_AppendMenu(Settings_SmokeMaterial_GetOptionsMenu())
end

function Settings_StoreAll()
    Settings_GeneralOptions_Store()
    Settings_FireSim_Store()
    Settings_Wind_Store()
    Settings_Light_Store()
    Settings_ParticleSpawner_Store()
    Settings_Particle_Store()
    Settings_FireMaterial_Store()
    Settings_SmokeMaterial_Store()
end

function Settings_UpdateAll()
    Settings_GeneralOptions_Update()
    Settings_FireSim_Update()
    Settings_Wind_Update()
    Settings_Light_Update()
    Settings_ParticleSpawner_Update()
    Settings_Particle_Update()
    Settings_FireMaterial_Update()
    Settings_SmokeMaterial_Update()
end

function Settings_RegisterUpdateSettingsCallback(func)
    Settings_UpdateCallbacks[#Settings_UpdateCallbacks+1] = func
end

function Settings_CallUpdate()
    for i=1, #Settings_UpdateCallbacks do
        Settings_UpdateCallbacks[i]()
    end
end

function Settings_SetDefault()
    Settings_SetStorageValuesRecursive("default", Settings_Template)
    Storage_SetString("settings", "presets", "default")
    Settings_CreatePreset(Preset_Settings_SlipperyGypsy)
    Settings_CreatePreset(Preset_Settings_Ultra)
    Settings_CreatePreset(Preset_Settings_High)
    Settings_CreatePreset(Preset_Settings_Medium)
    Settings_CreatePreset(Preset_Settings_Low)
    Storage_SetString("settings", "active_preset", "default")
    Settings_LoadActivePreset()
end

-- Settings load and store from Storage
function Settings_SetStorageValuesRecursive(preset, table)
    for key, value in pairs(table) do
        if type(value) == "table" then
            Settings_SetStorageValuesRecursive(preset .. "." .. key, value)
        else
            if type(value) == "string" then
                Storage_SetString("settings", preset .. "." .. key, value)
            end
            if type(value) == "number" then
                Storage_SetFloat("settings", preset .. "." .. key, value)
            end
            if type(value) == "boolean" then
                Storage_SetBool("settings", preset .. "." .. key, value)
            end
        end
    end
end

function Settings_GetStorageValuesRecursive(preset, table)
    for key, value in pairs(table) do
        if type(value) == "table" then
            Settings_GetStorageValuesRecursive(preset .. "." .. key, table[key])
        else
            if type(value) == "string" then
                table[key] = Storage_GetString("settings", preset .. "." .. key)
            end
            if type(table[key]) == "number" then
                table[key] = Storage_GetFloat("settings", preset .. "." .. key)
            end
            if type(table[key]) == "boolean" then
                table[key] = Storage_GetBool("settings", preset .. "." .. key)
            end
        end
    end
    _LoadedSettings["Settings"]["ActivePreset"] = preset
end

function Settings_EditedSettings()
    if _LoadedSettings["Settings"]["type"] == "default" then
        _LoadedSettings["Settings"]["ActivePreset"] = _LoadedSettings["Settings"]["ActivePreset"] .. "-editted"
        Settings_CreatePreset(_LoadedSettings)
        Settings_SetValue("Settings", "type", "custom")
        Settings_StoreActivePreset()
    end
end

function Settings_GetValue(module, key_to_get)
    local keys = Generic_SplitString(key_to_get, '.')
    local module = _LoadedSettings[module]
    for i=1, #keys do
        if type(module[keys[i]]) == "table" then
            module = module[keys[i]]
        else
            return module[keys[i]]
        end
    end
end

function Settings_SetValue(module, key_to_set, value_to_set)
    local keys = Generic_SplitString(key_to_set, '.')
    local module = _LoadedSettings[module]
    for i=1, #keys do
        if type(module[keys[i]]) == "table" then
            module = module[keys[i]]
        else
            module[keys[i]] = value_to_set
        end
    end
end
-- Preset related functions
function Settings_GetPresets()
    local presets = Storage_GetString("settings", "presets")
    return Generic_SplitString(presets, ',')
end

function Settings_AddPreset(preset)
    local presets = Storage_GetString("settings", "presets")
    if presets == "" then
        presets = preset
    else
        presets = presets .. "," ..preset
    end
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

function Settings_CreatePreset(settings)
    local preset = Storage_GetString("settings", "new_preset")
    if settings ~= nil then
        preset = settings["Settings"]["ActivePreset"]
        if Settings_PresetExists(preset) then
            Settings_DeletePreset(preset)
            DebugPrinter("Delete preset: "  .. preset)
        end
    end
    if Settings_PresetExists(preset) then
        DebugPrinter("Preset still exists, not adding: "  .. preset)
        return false
    else
        DebugPrinter("Adding preset: "  .. preset)
        Settings_AddPreset(preset)
        if settings == nil then
            Settings_SetStorageValuesRecursive(preset, _LoadedSettings)
        else
            Settings_SetStorageValuesRecursive(preset, settings)
        end
        Storage_SetString("settings", "active_preset", preset)
        Settings_LoadActivePreset()
    end
end

function Settings_CreateDescription()
    Settings_SetValue("Settings", "description", Storage_GetString("settings", "description"))
    Settings_StoreActivePreset()
end

function Settings_LoadActivePreset()
    _LoadedSettings = Generic_deepCopy(Settings_Template)
    local preset = Storage_GetString("settings", "active_preset")
    Settings_GetStorageValuesRecursive(preset, _LoadedSettings)
    Storage_SetString("settings", "description", Settings_GetValue("Settings", "description"))
    Settings_StoreAll()
    Settings_CallUpdate()
end

function Settings_StoreActivePreset()
    local preset = Storage_GetString("settings", "active_preset")
    Settings_SetStorageValuesRecursive(preset, _LoadedSettings)
    Settings_CallUpdate()
end

function Settings_DeleteActivePreset()
    local preset = Storage_GetString("settings", "active_preset")
    Settings_DeletePreset(preset)
    local presets = Settings_GetPresets()
    Storage_SetString("settings", "active_preset", presets[#presets])
    Settings_LoadActivePreset()
end


function Settings_DefaultActivePreset()
    _LoadedSettings = Generic_deepCopy(Settings_Template)
    Settings_StoreActivePreset()
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
			text = "Delete Active Preset",
			callback=function() Settings_DeleteActivePreset() end,
		},
		{
			text = "Reset Active Preset",
			callback=function() Settings_DefaultActivePreset() end,
		},
	},
	update=function() Settings_LoadActivePreset() end,
	option_items={
        {
            option_parent_text="",
            option_text="Select Active Preset",
            option_note="Click on a preset to load preset (bold is active). Changing settings will be applied to this preset.",
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
			option_text="Preset Description",
			option_note="Update Description.",
            option_type="text_input_field",
			storage_key="description",
            options={
                key_press=nil,
                action=function() Settings_CreateDescription() end
            }
		},
		{
			option_parent_text="",
			option_text="New Preset Name",
			option_note="Enter a new preset name here, settings will be copied from the active preset.",
            option_type="text_input",
			storage_key="new_preset",
            options={
                key_press="enter",
                action=function() Settings_CreatePreset() end
            }
		},
	}
}

function Settings_GetPresetMenu()
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
Settings_FireMaterial_Options =
{
    storage_module="fire_material",
    storage_prefix_key=nil,
    buttons={},
    update=nil,
    option_items={
        {
            option_parent_text="Particle Color",
            option_text="Red",
            option_note="Configure how red the fire is.",
            option_type="float",
            storage_key="color.r",
            min_max={0, 1.0, 0.01}
        },
        {
            option_parent_text="Particle Color",
            option_text="Green",
            option_note="Configure how green the fire is.",
            option_type="float",
            storage_key="color.g",
            min_max={0, 1.0, 0.01}
        },
        {
            option_parent_text="Particle Color",
            option_text="Blue",
            option_note="Configure how transparent the fire is.",
            option_type="float",
            storage_key="color.b",
            min_max={0, 1.0, 0.01}
        },
        {
            option_parent_text="Particle Color",
            option_text="Transparancy",
            option_note="Configure how transparent the fire is.",
            option_type="float",
            storage_key="color.a",
            min_max={0, 1.0, 0.01}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Life Time",
            option_note="Configure how long a single fire particle exists.",
            option_type="float",
            storage_key="lifetime",
            min_max={0.5, 30, 0.01}
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
            min_max={0.01, 10, 0.01}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Rotation",
            option_note="Configure the particle rotational speed.",
            option_type="float",
            storage_key="rotation",
            min_max={0.01, 10, 0.01}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Drag",
            option_note="Configure drag it has on other fire particles.",
            option_type="float",
            storage_key="drag",
            min_max={0.01, 1.0, 0.01}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Transparancy Variation",
            option_note="Configure transparancy variation between fire particles",
            option_type="float",
            storage_key="variation",
            min_max={0.01, 1.0, 0.01}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Size",
            option_note="Size of the fire particle.",
            option_type="float",
            storage_key="size",
            min_max={0.01, 1.0, 0.01}
        },
    }
}

function Settings_FireMaterial_Update(material)
    Settings_EditedSettings()
    Settings_SetValue("FireMaterial", material .. ".color.r", Storage_GetFloat("fire_material", material .. ".color.r"))
    Settings_SetValue("FireMaterial", material .. ".color.g", Storage_GetFloat("fire_material", material .. ".color.g"))
    Settings_SetValue("FireMaterial", material .. ".color.b", Storage_GetFloat("fire_material", material .. ".color.b"))
    Settings_SetValue("FireMaterial", material .. ".color.a", Storage_GetFloat("fire_material", material .. ".color.a"))
    Settings_SetValue("FireMaterial", material .. ".lifetime", Storage_GetFloat("fire_material", material .. ".lifetime"))
    Settings_SetValue("FireMaterial", material .. ".size", Storage_GetFloat("fire_material", material .. ".size"))
    Settings_SetValue("FireMaterial", material .. ".gravity", Storage_GetFloat("fire_material", material .. ".gravity"))
    Settings_SetValue("FireMaterial", material .. ".rotation", Storage_GetFloat("fire_material", material .. ".rotation"))
    Settings_SetValue("FireMaterial", material .. ".speed", Storage_GetFloat("fire_material", material .. ".speed"))
    Settings_SetValue("FireMaterial", material .. ".drag", Storage_GetFloat("fire_material", material .. ".drag"))
    Settings_SetValue("FireMaterial", material .. ".variation", Storage_GetFloat("fire_material", material .. ".variation"))
    Settings_StoreActivePreset()
end

function Settings_FireMaterial_Store()
    for material, val in pairs(_LoadedSettings["FireMaterial"]) do
        Storage_SetFloat("fire_material", material .. ".color.r", Settings_GetValue("FireMaterial", material .. ".color.r"))
        Storage_SetFloat("fire_material", material .. ".color.g", Settings_GetValue("FireMaterial", material .. ".color.g"))
        Storage_SetFloat("fire_material", material .. ".color.b", Settings_GetValue("FireMaterial", material .. ".color.b"))
        Storage_SetFloat("fire_material", material .. ".color.a", Settings_GetValue("FireMaterial", material .. ".color.a"))
        Storage_SetFloat("fire_material", material .. ".lifetime", Settings_GetValue("FireMaterial", material .. ".lifetime"))
        Storage_SetFloat("fire_material", material .. ".size", Settings_GetValue("FireMaterial", material .. ".size"))
        Storage_SetFloat("fire_material", material .. ".gravity", Settings_GetValue("FireMaterial", material .. ".gravity"))
        Storage_SetFloat("fire_material", material .. ".speed", Settings_GetValue("FireMaterial", material .. ".speed"))
        Storage_SetFloat("fire_material", material .. ".rotation", Settings_GetValue("FireMaterial", material .. ".rotation"))
        Storage_SetFloat("fire_material", material .. ".drag", Settings_GetValue("FireMaterial", material .. ".drag"))
        Storage_SetFloat("fire_material", material .. ".variation", Settings_GetValue("FireMaterial", material .. ".variation"))
    end
    Settings_StoreActivePreset()
end

function Settings_FireMaterial_Default(material)
    _LoadedSettings["FireMaterial"][material] = Settings_Template["FireMaterial"][material]
    Settings_FireMaterial_Store()
end

function Settings_FireMaterial_GetOptionsMenu()
    local materialMenus = {
        menu_title="Fire Materials",
        sub_menus={}
    }
    for material, properties in pairs(_LoadedSettings["FireMaterial"]) do
        local materialOptions = Generic_deepCopy(Settings_FireMaterial_Options)
        materialOptions["storage_prefix_key"] = material
        local buttons = {{
            text="Set default",
            callback=function()Settings_FireMaterial_Default(material)end
        }}
        materialOptions["buttons"] = buttons
        materialOptions["update"] = function()Settings_FireMaterial_Update(material)end
        table.insert(materialMenus["sub_menus"], {
            sub_menu_title=material,
            options=materialOptions,
            description="Change settings for material " .. material .. " in regards how fire looks when this material is on fire."
        })
	end
	return materialMenus
end


-- SmokeMaterial Module settings
Settings_SmokeMaterial_Options =
{
    storage_module="smoke_material",
    storage_prefix_key=nil,
    buttons={},
    update=nil,
    option_items={
        {
            option_parent_text="Particle Color",
            option_text="Red",
            option_note="Configure how red the smoke is.",
            option_type="float",
            storage_key="color.r",
            min_max={0.01, 1.0, 0.01}
        },
        {
            option_parent_text="Particle Color",
            option_text="Green",
            option_note="Configure how green the smoke is.",
            option_type="float",
            storage_key="color.g",
            min_max={0.01, 1.0, 0.01}
        },
        {
            option_parent_text="Particle Color",
            option_text="Blue",
            option_note="Configure how transparent the smoke is.",
            option_type="float",
            storage_key="color.b",
            min_max={0.01, 1.0, 0.01}
        },
        {
            option_parent_text="Particle Color",
            option_text="Transparancy",
            option_note="Configure how transparent the smoke is.",
            option_type="float",
            storage_key="color.a",
            min_max={0.01, 1.0, 0.01}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Life Time",
            option_note="Configure how long a single smoke particle exists.",
            option_type="float",
            storage_key="lifetime",
            min_max={1, 30, 1}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Gravity",
            option_note="Configure how gravity affects the smoke particles.",
            option_type="float",
            storage_key="gravity",
            min_max={-20.0, 20.0, 0.5}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Speed",
            option_note="Configure the speed at which the smoke particle shoots away.",
            option_type="float",
            storage_key="speed",
            min_max={0.01, 10, 0.01}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Rotation",
            option_note="Configure the rotation of the particle.",
            option_type="float",
            storage_key="rotation",
            min_max={0.01, 10, 0.01}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Drag",
            option_note="Configure drag it has on other smoke particles.",
            option_type="float",
            storage_key="drag",
            min_max={0.01, 1.0, 0.01}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Transparancy Variation",
            option_note="Configure transparancy variation between smoke particles",
            option_type="float",
            storage_key="variation",
            min_max={0.01, 1.0, 0.01}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Size",
            option_note="Size of the smoke particle.",
            option_type="float",
            storage_key="size",
            min_max={0.0, 4.0, 0.01}
        },
    }
}

function Settings_SmokeMaterial_Update(material)
    Settings_EditedSettings()
    Settings_SetValue("SmokeMaterial", material .. ".color.r", Storage_GetFloat("smoke_material", material .. ".color.r"))
    Settings_SetValue("SmokeMaterial", material .. ".color.g", Storage_GetFloat("smoke_material", material .. ".color.g"))
    Settings_SetValue("SmokeMaterial", material .. ".color.b", Storage_GetFloat("smoke_material", material .. ".color.b"))
    Settings_SetValue("SmokeMaterial", material .. ".color.a", Storage_GetFloat("smoke_material", material .. ".color.a"))
    Settings_SetValue("SmokeMaterial", material .. ".lifetime", Storage_GetFloat("smoke_material", material .. ".lifetime"))
    Settings_SetValue("SmokeMaterial", material .. ".size", Storage_GetFloat("smoke_material", material .. ".size"))
    Settings_SetValue("SmokeMaterial", material .. ".gravity", Storage_GetFloat("smoke_material", material .. ".gravity"))
    Settings_SetValue("SmokeMaterial", material .. ".speed", Storage_GetFloat("smoke_material", material .. ".speed"))
    Settings_SetValue("SmokeMaterial", material .. ".rotation", Storage_GetFloat("smoke_material", material .. ".rotation"))
    Settings_SetValue("SmokeMaterial", material .. ".drag", Storage_GetFloat("smoke_material", material .. ".drag"))
    Settings_SetValue("SmokeMaterial", material .. ".variation", Storage_GetFloat("smoke_material", material .. ".variation"))
    Settings_StoreActivePreset()
end

function Settings_SmokeMaterial_Store()
    for material, val in pairs(_LoadedSettings["SmokeMaterial"]) do
        Storage_SetFloat("smoke_material", material .. ".color.r", Settings_GetValue("SmokeMaterial", material .. ".color.r"))
        Storage_SetFloat("smoke_material", material .. ".color.g", Settings_GetValue("SmokeMaterial", material .. ".color.g"))
        Storage_SetFloat("smoke_material", material .. ".color.b", Settings_GetValue("SmokeMaterial", material .. ".color.b"))
        Storage_SetFloat("smoke_material", material .. ".color.a", Settings_GetValue("SmokeMaterial", material .. ".color.a"))
        Storage_SetFloat("smoke_material", material .. ".lifetime", Settings_GetValue("SmokeMaterial", material .. ".lifetime"))
        Storage_SetFloat("smoke_material", material .. ".size", Settings_GetValue("SmokeMaterial", material .. ".size"))
        Storage_SetFloat("smoke_material", material .. ".gravity", Settings_GetValue("SmokeMaterial", material .. ".gravity"))
        Storage_SetFloat("smoke_material", material .. ".speed", Settings_GetValue("SmokeMaterial", material .. ".speed"))
        Storage_SetFloat("smoke_material", material .. ".drag", Settings_GetValue("SmokeMaterial", material .. ".drag"))
        Storage_SetFloat("smoke_material", material .. ".rotation", Settings_GetValue("SmokeMaterial", material .. ".rotation"))
        Storage_SetFloat("smoke_material", material .. ".variation", Settings_GetValue("SmokeMaterial", material .. ".variation"))
    end
    Settings_StoreActivePreset()
end

function Settings_SmokeMaterial_Default(material)
    _LoadedSettings["SmokeMaterial"][material] = Settings_Template["SmokeMaterial"][material]
    Settings_SmokeMaterial_Store()
end

function Settings_SmokeMaterial_GetOptionsMenu()
    local materialMenus = {
        menu_title="Smoke Materials",
        sub_menus={}
    }
    for material, properties in pairs(_LoadedSettings["SmokeMaterial"]) do
        local materialOptions = Generic_deepCopy(Settings_SmokeMaterial_Options)
        materialOptions["storage_prefix_key"] = material
        local buttons = {{
            text="Set default",
            callback=function()Settings_SmokeMaterial_Default(material)end
        }}
        materialOptions["buttons"] = buttons
        materialOptions["update"] = function()Settings_SmokeMaterial_Update(material)end
        table.insert(materialMenus["sub_menus"], {
            sub_menu_title=material,
            options=materialOptions,
            description="Change settings for material " .. material .. " in regards how smoke looks when this material is on fire."
        })
	end
	return materialMenus
end

-- Fire Detector Module Settings
Settings_FireSim_OptionsDetection =
{
	storage_module="FireSim",
	storage_prefix_key=nil,
    buttons={
		{
			text = "Set Default",
			callback=function() Settings_FireSim_Default() end,
		},
    },
	update=function() Settings_FireSim_Update() end,
	option_items={

        {
            option_parent_text="",
            option_text="Map Size",
            option_note="Select LARGE, if fire is not detected on the edges of the map, SMALL for more accurate detection without performance hit!",
            option_type="text",
			storage_key="map_size",
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
			storage_key="detect_inside",
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
            storage_key="max_group_fire_distance",
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
            option_text="Minimum Detection Distance",
            option_note="The minimum distance between each detected fire (lower is less FPS/heavier)",
            option_type="float",
            storage_key="min_fire_distance",
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
            storage_key="fire_update_time",
            min_max={0.01, 10, 0.05}
        },
	}
}

Settings_FireSim_OptionsFireSpread=
{
	storage_module="FireSim",
	storage_prefix_key=nil,
    buttons={
		{
			text = "Set Default",
			callback=function() Settings_FireSim_Default() end,
		},
    },
	update=function() Settings_FireSim_Update() end,
	option_items={
        {
            option_parent_text="",
            option_text="Teardown Max Fire",
            option_note="Set the max fires of non mod related fires from teardown that can spawn.",
            option_type="float",
            storage_key="teardown_max_fires",
            min_max={1, 10000, 1}
        },
        {
            option_parent_text="",
            option_text="Teardown Fire Spread",
            option_note="Set the max fire spread of non mod related fire from teardown.",
            option_type="float",
            storage_key="teardown_fire_spread",
            min_max={1, 10, 1}
        },
        {
            option_parent_text="",
            option_text="Despawn Teardown Fire",
            option_note="Once a fire is detected and particles are spawned by this mod, puts out the actual teardown fire, for performance.",
            option_type="text",
            storage_key="despawn_td_fire",
			options={
				"YES",
				"NO"
			}
        },
        {
            option_parent_text="",
            option_text="Max Fires Detected",
            option_note="How many fires may be detected at once by this mod, spawns particles on detected fires.",
            option_type="float",
            storage_key="max_fire",
            min_max={1, 1000, 1}
        },
        {
            option_parent_text="",
            option_text="Max Fire Spread Distance",
            option_note="How far at max intensity a fire can spread/ interact with shapes.",
            option_type="float",
            storage_key="max_fire_spread_distance",
            min_max={1, 20, 1}
        },
        {
            option_parent_text="",
            option_text="Trigger Fire Reaction Time",
            option_note="Will trigger fire damage and spreading after x seconds (note the smaller the harder it is to extinguish)",
            option_type="float",
            storage_key="fire_reaction_time",
            min_max={1, 100, 1}
        },
        {
            option_parent_text="",
            option_text="Spawn Fire",
            option_note="Spawnes additional teardown native fire to the existing fire (currently not extinguishable)",
            option_type="text",
			storage_key="spawn_fire",
			options={
				"YES",
				"NO"
			}
        },
	}
}

Settings_FireSim_OptionsFireDamage =
{
	storage_module="FireSim",
	storage_prefix_key=nil,
    buttons={
		{
			text = "Set Default",
			callback=function() Settings_FireSim_Default() end,
		},
    },
	update=function() Settings_FireSim_Update() end,
	option_items={
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
            option_text="Fire Damage Soft",
            option_note="The damage radius on soft materials (only if Fire Damage is enabled).",
            option_type="float",
            storage_key="fire_damage_soft",
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
            storage_key="fire_damage_medium",
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
            storage_key="fire_damage_hard",
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
			storage_key="fire_explosion",
			options={
				"YES",
				"NO"
			}
        },
	}
}

Settings_FireSim_OptionsFireSoot =
{
	storage_module="FireSim",
	storage_prefix_key=nil,
    buttons={
		{
			text = "Set Default",
			callback=function() Settings_FireSim_Default() end,
		},
    },
	update=function() Settings_FireSim_Update() end,
	option_items={
        {
            option_parent_text="",
            option_text="Simulate Soot",
            option_note="Creates soot on walls and ceiling where smoke is, size depending on fire intensity",
            option_type="text",
			storage_key="soot_sim",
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
            storage_key="soot_max_size",
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
            storage_key="soot_min_size",
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
            storage_key="soot_dithering_max",
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
            storage_key="soot_dithering_min",
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

Settings_FireSim_OptionsFireIntensity =
{
	storage_module="FireSim",
	storage_prefix_key=nil,
    buttons={
		{
			text = "Set Default",
			callback=function() Settings_FireSim_Default() end,
		},
    },
	update=function() Settings_FireSim_Update() end,
	option_items={
		{
			option_parent_text="",
			option_text="Simulate Fire Intensity",
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
            option_type="float",
            storage_key="fire_intensity_multiplier",
            min_max={1, 20, 1}
        },
        {
            option_parent_text="",
            option_text="Fire Intensity Minimum (%)",
            option_note="The minimum size fires there should be.",
            option_type="float",
            storage_key="fire_intensity_minimum",
            min_max={1, 100, 1}
        },
	}
}


Settings_FireSim_OptionsDebugging =
{
	storage_module="FireSim",
	storage_prefix_key=nil,
    buttons={
		{
			text = "Set Default",
			callback=function() Settings_FireSim_Default() end,
		},
    },
	update=function() Settings_FireSim_Update() end,
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

function Settings_FireSim_Update()
    Settings_EditedSettings()
    Settings_SetValue("FireSim", "map_size", Storage_GetString("FireSim", "map_size"))
    Settings_SetValue("FireSim", "max_fire_spread_distance", Storage_GetFloat("FireSim", "max_fire_spread_distance"))
    Settings_SetValue("FireSim", "fire_reaction_time", Storage_GetFloat("FireSim", "fire_reaction_time"))
    Settings_SetValue("FireSim", "fire_update_time", Storage_GetFloat("FireSim", "fire_update_time"))
    Settings_SetValue("FireSim", "min_fire_distance", Storage_GetFloat("FireSim", "min_fire_distance"))
    Settings_SetValue("FireSim", "max_group_fire_distance", Storage_GetFloat("FireSim", "max_group_fire_distance"))
    Settings_SetValue("FireSim", "max_fire", Storage_GetFloat("FireSim", "max_fire"))
    Settings_SetValue("FireSim", "fire_intensity", Storage_GetString("FireSim", "fire_intensity"))
    Settings_SetValue("FireSim", "fire_intensity_multiplier", Storage_GetFloat("FireSim", "fire_intensity_multiplier"))
    Settings_SetValue("FireSim", "fire_intensity_minimum", Storage_GetFloat("FireSim", "fire_intensity_minimum"))
    Settings_SetValue("FireSim", "visualize_fire_detection", Storage_GetString("FireSim", "visualize_fire_detection"))
    Settings_SetValue("FireSim", "fire_explosion", Storage_GetString("FireSim", "fire_explosion"))
    Settings_SetValue("FireSim", "fire_damage", Storage_GetString("FireSim", "fire_damage"))
    Settings_SetValue("FireSim", "spawn_fire", Storage_GetString("FireSim", "spawn_fire"))
    Settings_SetValue("FireSim", "fire_damage_soft", Storage_GetFloat("FireSim", "fire_damage_soft"))
    Settings_SetValue("FireSim", "fire_damage_medium", Storage_GetFloat("FireSim", "fire_damage_medium"))
    Settings_SetValue("FireSim", "fire_damage_hard", Storage_GetFloat("FireSim", "fire_damage_hard"))
    Settings_SetValue("FireSim", "teardown_max_fires", Storage_GetFloat("FireSim", "teardown_max_fires"))
    Settings_SetValue("FireSim", "teardown_fire_spread", Storage_GetFloat("FireSim", "teardown_fire_spread"))
    Settings_SetValue("FireSim", "detect_inside", Storage_GetString("FireSim", "detect_inside"))
    Settings_SetValue("FireSim", "soot_sim", Storage_GetString("FireSim", "soot_sim"))
    Settings_SetValue("FireSim", "soot_dithering_max", Storage_GetFloat("FireSim", "soot_dithering_max"))
    Settings_SetValue("FireSim", "soot_dithering_min", Storage_GetFloat("FireSim", "soot_dithering_min"))
    Settings_SetValue("FireSim", "soot_max_size", Storage_GetFloat("FireSim", "soot_max_size"))
    Settings_SetValue("FireSim", "soot_min_size", Storage_GetFloat("FireSim", "soot_min_size"))
    Settings_SetValue("FireSim", "despawn_td_fire", Storage_GetString("FireSim", "despawn_td_fire"))
    Settings_StoreActivePreset()
end

function Settings_FireSim_Store()
    Storage_SetString("FireSim", "map_size", Settings_GetValue("FireSim", "map_size"))
    Storage_SetFloat("FireSim", "max_fire_spread_distance", Settings_GetValue("FireSim", "max_fire_spread_distance"))
    Storage_SetFloat("FireSim", "fire_reaction_time", Settings_GetValue("FireSim", "fire_reaction_time"))
    Storage_SetFloat("FireSim", "fire_update_time", Settings_GetValue("FireSim", "fire_update_time"))
    Storage_SetFloat("FireSim", "min_fire_distance", Settings_GetValue("FireSim", "min_fire_distance"))
    Storage_SetFloat("FireSim", "max_group_fire_distance", Settings_GetValue("FireSim", "max_group_fire_distance"))
    Storage_SetFloat("FireSim", "max_fire", Settings_GetValue("FireSim", "max_fire"))
    Storage_SetString("FireSim", "fire_intensity", Settings_GetValue("FireSim", "fire_intensity"))
    Storage_SetFloat("FireSim", "fire_intensity_multiplier", Settings_GetValue("FireSim", "fire_intensity_multiplier"))
    Storage_SetFloat("FireSim", "fire_intensity_minimum", Settings_GetValue("FireSim", "fire_intensity_minimum"))
    Storage_SetString("FireSim", "visualize_fire_detection", Settings_GetValue("FireSim", "visualize_fire_detection"))
    Storage_SetString("FireSim", "fire_explosion", Settings_GetValue("FireSim", "fire_explosion"))
    Storage_SetString("FireSim", "fire_damage", Settings_GetValue("FireSim", "fire_damage"))
    Storage_SetString("FireSim", "spawn_fire", Settings_GetValue("FireSim", "spawn_fire"))
    Storage_SetFloat("FireSim", "fire_damage_soft", Settings_GetValue("FireSim", "fire_damage_soft"))
    Storage_SetFloat("FireSim", "fire_damage_medium", Settings_GetValue("FireSim", "fire_damage_medium"))
    Storage_SetFloat("FireSim", "fire_damage_hard", Settings_GetValue("FireSim", "fire_damage_hard"))
    Storage_SetFloat("FireSim", "teardown_max_fires", Settings_GetValue("FireSim", "teardown_max_fires"))
    Storage_SetFloat("FireSim", "teardown_fire_spread", Settings_GetValue("FireSim", "teardown_fire_spread"))
    Storage_SetString("FireSim", "detect_inside", Settings_GetValue("FireSim", "detect_inside"))
    Storage_SetString("FireSim", "soot_sim", Settings_GetValue("FireSim", "soot_sim"))
    Storage_SetFloat("FireSim", "soot_dithering_max", Settings_GetValue("FireSim", "soot_dithering_max"))
    Storage_SetFloat("FireSim", "soot_max_size", Settings_GetValue("FireSim", "soot_max_size"))
    Storage_SetFloat("FireSim", "soot_dithering_min", Settings_GetValue("FireSim", "soot_dithering_min"))
    Storage_SetFloat("FireSim", "soot_min_size", Settings_GetValue("FireSim", "soot_min_size"))
    Storage_SetString("FireSim", "despawn_td_fire", Settings_GetValue("FireSim", "despawn_td_fire"))
    Settings_StoreActivePreset()
end

function Settings_FireSim_Default()
    _LoadedSettings["FireSim"] = Settings_Template["FireSim"]
    Settings_FireSim_Store()
end

function Settings_FireSim_GetOptionsMenu()
    return {
        menu_title = "Fire Settings",
        sub_menus={
            {
                sub_menu_title="Fire Detection",
                options=Settings_FireSim_OptionsDetection,
                description="Change settings regarding fire detection, e.g. minimum distance, or the maximum size arround a fire it may use to detect intensity.\nNote: the size of the box to count fires is used to spawn lights in! Setting this 1:1 to minimum fire distance will make lights spawn for each detected fire!\n. Note: Teardown Max Fire and Fire Spread is part of the base game and has no relation to other fire spread settings in this mod!"
            },
            {
                sub_menu_title="Fire Intensity",
                options=Settings_FireSim_OptionsFireIntensity,
                description="Intensity settings that determine how big fire particles/smoke particles are when spawned. \n Intensity also influences the damage if enabled, light intensity if enabled, \n and spreading if enabled (spawn fire), which are configured in the other menus!"
            },
            {
                sub_menu_title="Fire Spread",
                options=Settings_FireSim_OptionsFireSpread,
                description="The fire spread menu contains options that influence the fire spreading behavior. \n Note: Teardown Max Fire and Fire Spread is part of the base game and has no relation to other fire spread settings in this mod!\nNote: The Despawn Teardown Fire allows for more ThiccSmoke & ThiccFire particles to be spawned but can be buggy! Disable if experiencing issues!."
            },
            {
                sub_menu_title="Fire Damage",
                options=Settings_FireSim_OptionsFireDamage,
                description="This mode allows fires to do extra damage to buildings, beyond the existing fire damage model. \nNote that to much damage can actually put out flames. "
            },
            {
                sub_menu_title="Fire Soot",
                options=Settings_FireSim_OptionsFireSoot,
                description="Fire soot simulation settings, since update 0.9.4 teardown this mod is able to simulate soot trails created by smoke \neven though no fire is really near. \nNote, only available in Teardown 0.9.4 and up, will be disabled otherwise."
            },
            {
                sub_menu_title="Debugging",
                options=Settings_FireSim_OptionsDebugging,
                description="If your settings are behaving weird, fire is spawning weird, \nyou can see where fires are detected and the intensity of the fire \n (how greener the box, the more intense the fire).,"
            }
        }
    }
end

--- General  module
Settings_GeneralOptions_Options =
{
	storage_module="general",
	storage_prefix_key=nil,
	buttons={
		{
			text = "Set Default",
			callback=function() Settings_GeneralOptions_Default() end,
		},
	},
	update=function() Settings_GeneralOptions_Update() end,
	option_items={
		{
			option_parent_text="",
			option_text="Show or Hide Menu Key",
			option_note="Set key to show or hide the menu while in game. Click on the letter and press key to change.",
			option_type="input_key",
			storage_key="toggle_menu_key",
		},
		{
			option_parent_text="",
			option_text="Show UI In Game",
			option_note="Shows mod status and key bind text in game.",
			option_type="text",
			storage_key="ui_in_game",
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
			storage_key="debug",
			options={
				"YES",
				"NO"
			}
		},
	}
}

function Settings_GeneralOptions_Update()
    Settings_SetValue("GeneralOptions", "toggle_menu_key", Storage_GetString("general", "toggle_menu_key"))
    Settings_SetValue("GeneralOptions", "ui_in_game", Storage_GetString("general", "ui_in_game"))
    Settings_SetValue("GeneralOptions", "debug", Storage_GetString("general", "debug"))
    Settings_SetValue("GeneralOptions", "enabled", Storage_GetString("general", "enabled"))
    Settings_StoreActivePreset()
end

function Settings_GeneralOptions_Store()
    Storage_SetString("general", "toggle_menu_key", Settings_GetValue("GeneralOptions", "toggle_menu_key"))
    Storage_SetString("general", "ui_in_game", Settings_GetValue("GeneralOptions", "ui_in_game"))
    Storage_SetString("general", "debug", Settings_GetValue("GeneralOptions", "debug"))
    Storage_SetString("general", "enabled", Settings_GetValue("GeneralOptions", "enabled"))
    Settings_StoreActivePreset()
end

function Settings_GeneralOptions_Default()
    _LoadedSettings["GeneralOptions"] = Settings_Template["GeneralOptions"]
    Settings_GeneralOptions_Store()
end

function Settings_GeneralOptions_GetOptionsMenu()
	return {
		menu_title = "General Settings",
		sub_menus={
			{
				sub_menu_title="General Options",
				options=Settings_GeneralOptions_Options,
			}
		}
	}
end

--- Particle Spawner module

Settings_ParticleSpawner_FrameRate_Options =
{
	storage_module="particlespawner",
	storage_prefix_key=nil,
    buttons={
		{
			text = "Set Default",
			callback=function() Settings_ParticleSpawner_Default() end,
		},
    },
	update=function() Settings_ParticleSpawner_Update() end,
	option_items={
        {
            option_parent_text="",
            option_text="Dynamic FPS Adjust",
            option_note="Adjust based on fps. If disabled, only the max values will apply!",
            option_type="text",
            storage_key="dynamic_fps",
            options={"ON", "OFF"}
        },
        {
            option_parent_text="",
            option_text="FPS Target",
            option_note="Note: only taken into account when your FPS is above this value!",
            option_type="float",
            storage_key="dynamic_fps_target",
            min_max={29, 60, 1}
        },
        {
            option_parent_text="",
            option_text="Particle Refresh Rate",
            option_note="Maximum particle spawn refresh rate per second (note will automatically adjust if fps is below target (more = thicker smoke).",
            option_type="float",
            storage_key="particle_refresh_max",
            min_max={1, 60, 1}
        },
        {
            option_parent_text="",
            option_text="Min Particle Refresh Rate",
            option_note="Minimum particle spawn refresh rate per second.",
            option_type="float",
            storage_key="particle_refresh_min",
            min_max={1, 60, 1}
        },
        {
            option_parent_text="",
            option_text="Adjust Aggressivenes",
            option_note="How quick parameters should be adjusted after dipping below target.",
            option_type="float",
            storage_key="aggressivenes",
            min_max={0.01, 1.0, 0.01}
        }
	}
}

Settings_ParticleSpawner_Particle_Options =
{
	storage_module="particlespawner",
	storage_prefix_key=nil,
    buttons={
		{
			text = "Set Default",
			callback=function() Settings_ParticleSpawner_Default() end,
		},
    },
	update=function() Settings_ParticleSpawner_Update() end,
	option_items={
        {
            option_parent_text="",
            option_text="Spawn Smoke Particles",
            option_note="Enable this to spawn smoke particles",
            option_type="text",
            storage_key="smoke",
            options={"YES", "NO"}
        },
        {
            option_parent_text="",
            option_text="Spawn Fire Particles",
            option_note="Enable this to spawn fire particles",
            option_type="text",
            storage_key="fire",
            options={"YES", "NO"}
        },
        {
            option_parent_text="",
            option_text="Spawn Ash Particles",
            option_note="Enable this to spawn ash particles",
            option_type="text",
            storage_key="ash",
            options={"YES", "NO"}
        },
        {
            option_parent_text="",
            option_text="Fire to Smoke ratio",
            option_note="How many fire particles per spawning of smoke particles should spawn. (e.g. 1 fire every 8 smoke particles)",
            option_type="text",
            storage_key="fire_to_smoke_ratio",
            options={"1:1", "1:2", "1:4", "1:8", "1:15", "1:30", "1:60"}
        },
        {
            option_parent_text="",
            option_text="Ash to Smoke ratio",
            option_note="How many ash particles per spawning of smoke particles should spawn. (e.g. 1 ash particle every 8 smoke particles)",
            option_type="text",
            storage_key="ash_to_smoke_ratio",
            options={"1:1", "1:2", "1:4", "1:8", "1:15", "1:30", "1:60"}
        }
	}
}



function Settings_ParticleSpawner_Update()
    Settings_EditedSettings()
    Settings_SetValue("ParticleSpawner", "fire", Storage_GetString("particlespawner", "fire"))
    Settings_SetValue("ParticleSpawner", "smoke", Storage_GetString("particlespawner", "smoke"))
    Settings_SetValue("ParticleSpawner", "ash", Storage_GetString("particlespawner", "ash"))
    Settings_SetValue("ParticleSpawner", "fire_to_smoke_ratio", Storage_GetString("particlespawner", "fire_to_smoke_ratio"))
    Settings_SetValue("ParticleSpawner", "ash_to_smoke_ratio", Storage_GetString("particlespawner", "ash_to_smoke_ratio"))
    Settings_SetValue("ParticleSpawner", "dynamic_fps", Storage_GetString("particlespawner", "dynamic_fps"))
    Settings_SetValue("ParticleSpawner", "dynamic_fps_target", Storage_GetFloat("particlespawner", "dynamic_fps_target"))
    Settings_SetValue("ParticleSpawner", "particle_refresh_max", Storage_GetFloat("particlespawner", "particle_refresh_max"))
    Settings_SetValue("ParticleSpawner", "particle_refresh_min", Storage_GetFloat("particlespawner", "particle_refresh_min"))
    Settings_SetValue("ParticleSpawner", "aggressivenes", Storage_GetFloat("particlespawner", "aggressivenes"))
    Settings_StoreActivePreset()
end

function Settings_ParticleSpawner_Store()
    Storage_SetString("particlespawner", "fire", Settings_GetValue("ParticleSpawner", "fire"))
    Storage_SetString("particlespawner", "smoke", Settings_GetValue("ParticleSpawner", "smoke"))
    Storage_SetString("particlespawner", "ash", Settings_GetValue("ParticleSpawner", "ash"))
    Storage_SetString("particlespawner", "fire_to_smoke_ratio", Settings_GetValue("ParticleSpawner", "fire_to_smoke_ratio"))
    Storage_SetString("particlespawner", "ash_to_smoke_ratio", Settings_GetValue("ParticleSpawner", "ash_to_smoke_ratio"))
    Storage_SetString("particlespawner", "dynamic_fps", Settings_GetValue("ParticleSpawner", "dynamic_fps"))
    Storage_SetFloat("particlespawner", "dynamic_fps_target", Settings_GetValue("ParticleSpawner", "dynamic_fps_target"))
    Storage_SetFloat("particlespawner", "particle_refresh_max", Settings_GetValue("ParticleSpawner", "particle_refresh_max"))
    Storage_SetFloat("particlespawner", "particle_refresh_min", Settings_GetValue("ParticleSpawner", "particle_refresh_min"))
    Storage_SetFloat("particlespawner", "aggressivenes", Settings_GetValue("ParticleSpawner", "aggressivenes"))
    Settings_StoreActivePreset()
end

function Settings_ParticleSpawner_Default()
    _LoadedSettings["ParticleSpawner"] = Settings_Template["ParticleSpawner"]
    Settings_ParticleSpawner_Store()
end

function Settings_ParticleSpawner_GetOptionsMenu()
	return {
		menu_title = "Particle Spawner Settings",
		sub_menus={
			{
				sub_menu_title="Frame Rate Control",
				options=Settings_ParticleSpawner_FrameRate_Options,
                description="This menu allows for controlling frame rate dependent particle spawning, to hopefully keep frame rate playable (but can have huge impact on visuals)."
			},
			{
				sub_menu_title="Particle Settings",
				options=Settings_ParticleSpawner_Particle_Options,
                description="This menu allows for particle related settings to be changed, e.g. which particles can be spawned and in what ratio!\nNote: go to Particle Settings main menu for more detailed particle settings."
			}
		}
	}
end

--- Particle module
Settings_General_Particle_Options =
{
	storage_module="particle",
	storage_prefix_key=nil,
	buttons={
		{
			text="Set default",
			callback=function() Settings_Particle_Default() end,
		}
	},
	update=function() Settings_Particle_Update() end,
	option_items={
		{
			option_parent_text="",
			option_text="Intensity",
			option_note="Applies offset to radius on all materials.",
			option_type="text",
			storage_key="intensity_mp",
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
			storage_key="drag_mp",
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
			storage_key="gravity_mp",
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
			storage_key="lifetime_mp",
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
            storage_key="intensity_scale",
            min_max={1, 10.0, 0.05}
        },
        {
            option_parent_text="",
            option_text="Particle Min Distance Padding",
            option_note="Prevent spawning overlapping particles (by this mod)",
            option_type="float",
            storage_key="min_particle_dist",
            min_max={0.05, 4, 0.05}
        },
        {
            option_parent_text="",
            option_text="Particle Randomness",
            option_note="To make the fire feel more alive/less static, 0.05 = max randomness, 1 = no randomness",
            option_type="float",
            storage_key="randomness",
            min_max={0.05, 1, 0.05}
        },
        {
            option_parent_text="",
            option_text="Particle Location Randomness",
            option_note="Spread around location, makes it less static.",
            option_type="float",
            storage_key="location_randomness",
            min_max={0.1, 10, 0.1}
        },
        {
            option_parent_text="",
            option_text="Particle Duplicator",
            option_note="To make your PC cry, instead of spawning 1 particle, spawn multiple per instance.",
            option_type="float",
            storage_key="duplicator",
            min_max={1, 20, 1}
        }
	}
}

Settings_Smoke_Particle_Options =
{
	storage_module="particle",
	storage_prefix_key=nil,
	buttons={
		{
			text="Set default",
			callback=function() Settings_Particle_Default() end,
		}
	},
	update=function() Settings_Particle_Update() end,
	option_items={

		{
			option_parent_text="",
			option_text="Smoke Fade In (%)",
			option_note="Percentage of time it takes to fade in smoke",
			option_type="float",
			storage_key="smoke_fadein",
			min_max={0, 100, 1}
		},
		{
			option_parent_text="",
			option_text="Smoke Fade Out (%)",
			option_note="Percentage of time it takes to fade in smoke",
			option_type="float",
			storage_key="smoke_fadeout",
			min_max={0, 100, 1}
		}
	}
}

Settings_Fire_Particle_Options =
{
	storage_module="particle",
	storage_prefix_key=nil,
	buttons={
		{
			text="Set default",
			callback=function() Settings_Particle_Default() end,
		}
	},
	update=function() Settings_Particle_Update() end,
	option_items={
		{
			option_parent_text="",
			option_text="Embers",
			option_note="Amount of embers fire can produce.",
			option_type="text",
			storage_key="embers",
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
			storage_key="fire_fadein",
			min_max={0, 100, 1}
		},
		{
			option_parent_text="",
			option_text="Fire Fade Out (%)",
			option_note="Percentage of time it takes to fade in fire",
			option_type="float",
			storage_key="fire_fadeout",
			min_max={0, 100, 1}
		},
		{
			option_parent_text="",
			option_text="Fire Emissiveness",
			option_note="Sets how emissive the fire starts out",
			option_type="float",
			storage_key="fire_emissive",
			min_max={1, 10, 1}
		},
	}
}

Settings_Ash_Particle_Options =
{
	storage_module="particle",
	storage_prefix_key=nil,
	buttons={
		{
			text="Set default",
			callback=function() Settings_Particle_Default() end,
		}
	},
	update=function() Settings_Particle_Update() end,
	option_items={
        {
            option_parent_text="",
            option_text="Lifetime",
            option_note="How long ash particles may exist in the world (higher == lower fps)",
            option_type="float",
            storage_key="ash_life",
            min_max={1, 50, 1}
        },
        {
            option_parent_text="",
            option_text="Gravity Min",
            option_note="Change the minimum gravity that can pull on ash particles. (Always downwards == negative)",
            option_type="float",
            storage_key="ash_gravity_min",
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
            storage_key="ash_gravity_max",
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
            storage_key="ash_rot_max",
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
            storage_key="ash_rot_min",
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
            storage_key="ash_sticky_max",
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
            storage_key="ash_sticky_min",
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
            storage_key="ash_drag_max",
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
            storage_key="ash_drag_min",
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
            storage_key="ash_size_max",
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
            storage_key="ash_size_min",
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

Settings_Debug_Particle_Options =
{
	storage_module="particle",
	storage_prefix_key=nil,
	buttons={
		{
			text="Set default",
			callback=function() Settings_Particle_Default() end,
		}
	},
	update=function() Settings_Particle_Update() end,
	option_items={
        {
            option_parent_text="",
            option_text="Particle Min Distance Padding",
            option_note="Prevent spawning overlapping particles (by this mod)",
            option_type="float",
            storage_key="min_particle_dist",
            min_max={0.05, 4, 0.05}
        },
		{
			option_parent_text="",
			option_text="Visualize Spawn Locations",
			option_note="Shows a box where the mod spawns particles (used to tune particle distance)",
            option_type="text",
			storage_key="visualize_spawn_locations",
			options={
				"ON",
				"OFF"
			}
		}
	}
}

function Settings_Particle_Update()
    Settings_EditedSettings()
    Settings_SetValue("Particle", "intensity_mp", Storage_GetString("particle", "intensity_mp"))
    Settings_SetValue("Particle", "drag_mp", Storage_GetString("particle", "drag_mp"))
    Settings_SetValue("Particle", "gravity_mp", Storage_GetString("particle", "gravity_mp"))
    Settings_SetValue("Particle", "lifetime_mp", Storage_GetString("particle", "lifetime_mp"))
    Settings_SetValue("Particle", "intensity_scale", Storage_GetFloat("particle", "intensity_scale"))
    Settings_SetValue("Particle", "randomness", Storage_GetFloat("particle", "randomness"))
    Settings_SetValue("Particle", "min_particle_dist", Storage_GetFloat("particle", "min_particle_dist"))
    Settings_SetValue("Particle", "location_randomness", Storage_GetFloat("particle", "location_randomness"))
    Settings_SetValue("Particle", "duplicator", Storage_GetFloat("particle", "duplicator"))
    Settings_SetValue("Particle", "smoke_fadein", Storage_GetFloat("particle", "smoke_fadein"))
    Settings_SetValue("Particle", "smoke_fadeout", Storage_GetFloat("particle", "smoke_fadeout"))
    Settings_SetValue("Particle", "fire_fadein", Storage_GetFloat("particle", "fire_fadein"))
    Settings_SetValue("Particle", "fire_fadeout", Storage_GetFloat("particle", "fire_fadeout"))
    Settings_SetValue("Particle", "fire_emissive", Storage_GetFloat("particle", "fire_emissive"))
    Settings_SetValue("Particle", "embers", Storage_GetString("particle", "embers"))

    Settings_SetValue("Particle", "ash_gravity_min", Storage_GetFloat("particle", "ash_gravity_min"))
    Settings_SetValue("Particle", "ash_gravity_max", Storage_GetFloat("particle", "ash_gravity_max"))
    Settings_SetValue("Particle", "ash_rot_max", Storage_GetFloat("particle", "ash_rot_max"))
    Settings_SetValue("Particle", "ash_rot_min", Storage_GetFloat("particle", "ash_rot_min"))
    Settings_SetValue("Particle", "ash_sticky_max", Storage_GetFloat("particle", "ash_sticky_max"))
    Settings_SetValue("Particle", "ash_sticky_min", Storage_GetFloat("particle", "ash_sticky_min"))
    Settings_SetValue("Particle", "ash_drag_max", Storage_GetFloat("particle", "ash_drag_max"))
    Settings_SetValue("Particle", "ash_drag_min", Storage_GetFloat("particle", "ash_drag_min"))
    Settings_SetValue("Particle", "ash_size_max", Storage_GetFloat("particle", "ash_size_max"))
    Settings_SetValue("Particle", "ash_size_min", Storage_GetFloat("particle", "ash_size_min"))
    Settings_SetValue("Particle", "ash_life", Storage_GetFloat("particle", "ash_life"))

    Settings_SetValue("Particle", "visualize_spawn_locations", Storage_GetString("particle", "visualize_spawn_locations"))
    Settings_StoreActivePreset()
end

function Settings_Particle_Store()
    Storage_SetString("particle", "intensity_mp", Settings_GetValue("Particle", "intensity_mp"))
    Storage_SetString("particle", "drag_mp", Settings_GetValue("Particle", "drag_mp"))
    Storage_SetString("particle", "gravity_mp", Settings_GetValue("Particle", "gravity_mp"))
    Storage_SetString("particle", "lifetime_mp", Settings_GetValue("Particle", "lifetime_mp"))
    Storage_SetFloat("particle", "intensity_scale", Settings_GetValue("Particle", "intensity_scale"))
    Storage_SetFloat("particle", "randomness", Settings_GetValue("Particle", "randomness"))
    Storage_SetFloat("particle", "min_particle_dist", Settings_GetValue("Particle", "min_particle_dist"))
    Storage_SetFloat("particle", "location_randomness", Settings_GetValue("Particle", "location_randomness"))
    Storage_SetFloat("particle", "duplicator", Settings_GetValue("Particle", "duplicator"))
    Storage_SetFloat("particle", "smoke_fadein", Settings_GetValue("Particle", "smoke_fadein"))
    Storage_SetFloat("particle", "smoke_fadeout", Settings_GetValue("Particle", "smoke_fadeout"))
    Storage_SetFloat("particle", "fire_fadein", Settings_GetValue("Particle", "fire_fadein"))
    Storage_SetFloat("particle", "fire_fadeout", Settings_GetValue("Particle", "fire_fadeout"))
    Storage_SetFloat("particle", "fire_emissive", Settings_GetValue("Particle", "fire_emissive"))
    Storage_SetString("particle", "embers", Settings_GetValue("Particle", "embers"))

    Storage_SetFloat("particle", "ash_gravity_min", Settings_GetValue("Particle", "ash_gravity_min"))
    Storage_SetFloat("particle", "ash_gravity_max", Settings_GetValue("Particle", "ash_gravity_max"))
    Storage_SetFloat("particle", "ash_rot_max", Settings_GetValue("Particle", "ash_rot_max"))
    Storage_SetFloat("particle", "ash_rot_min", Settings_GetValue("Particle", "ash_rot_min"))
    Storage_SetFloat("particle", "ash_sticky_max", Settings_GetValue("Particle", "ash_sticky_max"))
    Storage_SetFloat("particle", "ash_sticky_min", Settings_GetValue("Particle", "ash_sticky_min"))
    Storage_SetFloat("particle", "ash_drag_max", Settings_GetValue("Particle", "ash_drag_max"))
    Storage_SetFloat("particle", "ash_drag_min", Settings_GetValue("Particle", "ash_drag_min"))
    Storage_SetFloat("particle", "ash_size_max", Settings_GetValue("Particle", "ash_size_max"))
    Storage_SetFloat("particle", "ash_size_min", Settings_GetValue("Particle", "ash_size_min"))
    Storage_SetFloat("particle", "ash_life", Settings_GetValue("Particle", "ash_life"))

    Storage_SetString("particle", "visualize_spawn_locations", Settings_GetValue("Particle", "visualize_spawn_locations"))
    Settings_StoreActivePreset()
end

function Settings_Particle_Default()
    _LoadedSettings["Particle"] = Settings_Template["Particle"]
    Settings_Particle_Store()
end

function Settings_Particle_GetOptionsMenu()
	return {
		menu_title = "Particle Settings",
		sub_menus={
			{
				sub_menu_title="General",
				options=Settings_General_Particle_Options,
                description="These settings are applied to all particles (independent of the material), for some quick adjustments if necessary."
			},
			{
				sub_menu_title="Fire",
				options=Settings_Fire_Particle_Options,
                description="These settings are applied to all fire particles (independent of the material), for some quick adjustments if necessary.\n Note: only available if fire particles is enabled in Particle Spawner Menu."
			},
			{
				sub_menu_title="Smoke",
				options=Settings_Smoke_Particle_Options,
                description="These settings are applied to all smoke particles (independent of the material), for some quick adjustments if necessary.\n Note: only available if smoke particles is enabled in Particle Spawner Menu."
			},
			{
				sub_menu_title="Ash",
				options=Settings_Ash_Particle_Options,
                description="These settings are applied to all ash particles (independent of the material), for some quick adjustments if necessary.\n Note: only available if ash particles is enabled in Particle Spawner Menu."
			},
			{
				sub_menu_title="Debug",
				options=Settings_Debug_Particle_Options,
                description="These settings are used for debug and tuning purposes of general particle spawn behavior."
			}
		}
	}
end

Settings_Wind_General_Options =
{
	storage_module="wind",
	storage_prefix_key=nil,
	buttons={
		{
			text="Set default",
			callback=function() Settings_Wind_Default() end,
		}
	},
	update=function() Settings_Wind_Update() end,
	option_items={
        {
            option_parent_text="",
            option_text="Enable Wind",
            option_note="Uses the environment property to generate a wind",
            option_type="text",
            storage_key="wind",
            options={"YES", "NO"}
        },
		{
			option_parent_text="",
			option_text="Wind Direction",
			option_note="Wind direction in degrees.",
			option_type="float",
			storage_key="winddirection",
			min_max={0, 360, 1}
		},
		{
			option_parent_text="",
			option_text="Wind Direction Randomness",
			option_note="Wind direction randomness (min/max deviation from base direction).",
			option_type="float",
			storage_key="winddirectionrandom",
			min_max={0, 360, 1}
		},
		{
			option_parent_text="",
			option_text="Wind Direction Change Rate",
			option_note="Wind direction change rate, 1 is slowest, 100 is fastest.",
			option_type="float",
			storage_key="winddirectionrandomrate",
			min_max={1, 100, 1}
		},
		{
			option_parent_text="",
			option_text="Wind Strength",
			option_note="Strength of the wind.",
			option_type="float",
			storage_key="windstrength",
			min_max={0.1, 20, 1}
		},
		{
			option_parent_text="",
			option_text="Wind Strength Randomness",
			option_note="How much the strenght can vary.",
			option_type="float",
			storage_key="windstrengthrandom",
			min_max={0, 50, 1}
		},
		{
			option_parent_text="",
			option_text="Wind Strength Change Rate",
			option_note="Rate of changes, 1 is slowest, 100 is fastest.",
			option_type="float",
			storage_key="windstrengthrandomrate",
			min_max={1, 100, 1}
		},
	}
}

function Settings_Wind_Update()
    Settings_EditedSettings()
    Settings_SetValue("Wind", "wind", Storage_GetString("wind", "wind"))
    Settings_SetValue("Wind", "winddirection", Storage_GetFloat("wind", "winddirection"))
    Settings_SetValue("Wind", "winddirectionrandom", Storage_GetFloat("wind", "winddirectionrandom"))
    Settings_SetValue("Wind", "winddirectionrandomrate", Storage_GetFloat("wind", "winddirectionrandomrate"))
    Settings_SetValue("Wind", "windstrength", Storage_GetFloat("wind", "windstrength"))
    Settings_SetValue("Wind", "windstrengthrandom", Storage_GetFloat("wind", "windstrengthrandom"))
    Settings_SetValue("Wind", "windstrengthrandomrate", Storage_GetFloat("wind", "windstrengthrandomrate"))
    Settings_StoreActivePreset()
end

function Settings_Wind_Store()
    Storage_SetString("wind", "wind", Settings_GetValue("Wind", "wind"))
    Storage_SetFloat("wind", "winddirection", Settings_GetValue("Wind", "winddirection"))
    Storage_SetFloat("wind", "winddirectionrandom",  Settings_GetValue("Wind", "winddirectionrandom"))
    Storage_SetFloat("wind", "winddirectionrandomrate",  Settings_GetValue("Wind", "winddirectionrandomrate"))
    Storage_SetFloat("wind", "windstrength", Settings_GetValue("Wind", "windstrength"))
    Storage_SetFloat("wind", "windstrengthrandom",  Settings_GetValue("Wind", "windstrengthrandom"))
    Storage_SetFloat("wind", "windstrengthrandomrate",  Settings_GetValue("Wind", "windstrengthrandomrate"))
    Settings_StoreActivePreset()
end

function Settings_Wind_Default()
    _LoadedSettings["Wind"] = Settings_Template["Wind"]
    Settings_Wind_Store()
end

function Settings_Wind_GetOptionsMenu()
	return {
		menu_title = "Wind Settings",
		sub_menus={
			{
				sub_menu_title="General",
				options=Settings_Wind_General_Options,
                description="Configure the wind."
			}
		}
	}
end

Settings_Light_General_Options =
{
	storage_module="light",
	storage_prefix_key=nil,
    buttons={
		{
			text = "Set Default",
			callback=function() Settings_Light_Default() end,
		},
    },
	update=function() Settings_Light_Update() end,
	option_items={
        {
            option_parent_text="",
            option_text="Enable Light",
            option_note="Spawn lights to simulate fire emitting more intense light.",
            option_type="text",
            storage_key="spawn_light",
            options={"ON", "OFF"}
        },
        {
            option_parent_text="",
            option_text="Light Flickering Intensity",
            option_note="Note: changes how much the light flickers, which is based on the fire intensity.",
            option_type="float",
            storage_key="light_flickering_intensity",
            min_max={1, 10, 1}
        },
        {
            option_parent_text="",
            option_text="Light Brightness",
            option_note="Note: Changes the brightness, 0.1 == 10%, 1 = 100%,  brightness also depends on fire intensity but cannot go > 100%",
            option_type="float",
            storage_key="light_intensity",
            min_max={0.01, 1, 0.01}
        },
        {
            optiYES_parent_text="",
            option_text="Red Light Offset",
            option_note="Note: Light color is based on fire color, offset can be used to make adjustments to the light specifically!",
            option_type="float",
            storage_key="red_light_offset",
            min_max={-1, 1, 0.05}
        },
        {
            option_parent_text="",
            option_text="Green Light Offset",
            option_note="Note: Light color is based on fire color, offset can be used to make adjustments to the light specifically!",
            option_type="float",
            storage_key="green_light_offset",
            min_max={-1, 1, 0.05}
        },
        {
            option_parent_text="",
            option_text="Blue Light Offset",
            option_note="Note: Light color is based on fire color, offset can be used to make adjustments to the light specifically!",
            option_type="float",
            storage_key="blue_light_offset",
            min_max={-1, 1, 0.05}
        },
	}
}

function Settings_Light_Update()
    Settings_EditedSettings()
    Settings_SetValue("Light", "spawn_light", Storage_GetString("light", "spawn_light"))
    Settings_SetValue("Light", "red_light_offset", Storage_GetFloat("light", "red_light_offset"))
    Settings_SetValue("Light", "green_light_offset", Storage_GetFloat("light", "green_light_offset"))
    Settings_SetValue("Light", "blue_light_offset", Storage_GetFloat("light", "blue_light_offset"))
    Settings_SetValue("Light", "light_intensity", Storage_GetFloat("light", "light_intensity"))
    Settings_SetValue("Light", "light_flickering_intensity", Storage_GetFloat("light", "light_flickering_intensity"))
    Settings_StoreActivePreset()
end

function Settings_Light_Store()
    Storage_SetString("light", "spawn_light", Settings_GetValue("Light", "spawn_light"))
    Storage_SetFloat("light", "red_light_offset", Settings_GetValue("Light", "red_light_offset"))
    Storage_SetFloat("light", "green_light_offset", Settings_GetValue("Light", "green_light_offset"))
    Storage_SetFloat("light", "blue_light_offset", Settings_GetValue("Light", "blue_light_offset"))
    Storage_SetFloat("light", "light_intensity", Settings_GetValue("Light", "light_intensity"))
    Storage_SetFloat("light", "light_flickering_intensity", Settings_GetValue("Light", "light_flickering_intensity"))
    Settings_StoreActivePreset()
end

function Settings_Light_Default()
    _LoadedSettings["Light"] = Settings_Template["Light"]
    Settings_Light_Store()
end

function Settings_Light_GetOptionsMenu()
	return {
		menu_title = "Light Settings",
		sub_menus={
			{
				sub_menu_title="General",
				options=Settings_Light_General_Options,
                description="Configure the Light."
			}
		}
	}
end


