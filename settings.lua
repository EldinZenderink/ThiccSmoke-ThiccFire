-- settings.lua
-- @date 2021-10-30
-- @author Eldin Zenderink
-- @brief This module should provide a centralized system for maintaining and grouping settings, to allow for easier adjustments, restore funcitonalities etc.
--        Every module will have their properties  stored and accessed from here. Menus will also be generated from here. Presets will be created in separated modules based on this module. Catagorizing settings will be done through here.

Settings_UpdateCallbacks = {}

Settings_Template ={
    Settings = {
        ActivePreset="medium",
        description="Default preset (medium preset)."
    },
    GeneralOptions = {
        toggle_menu_key="U",
        ui_in_game="NO",
        debug="NO",
        enabled="YES"
    },
    FireDetector = {
        max_fire_spread_distance=2,
        fire_reaction_time=6,
        fire_update_time=0.5,
        min_fire_distance=2,
        max_group_fire_distance=4,
        max_fire=50,
        fire_intensity="ON",
        fire_intensity_multiplier=1,
        fire_intensity_minimum=10,
        visualize_fire_detection="OFF",
        fire_explosion = "NO",
        fire_damage = "NO",
        spawn_fire = "YES",
        fire_damage_soft = 0.1,
        fire_damage_medium = 0.05,
        fire_damage_hard = 0.01,
        teardown_max_fires = 200,
        teardown_fire_spread = 1,
        material_allowed = {
            wood = true,
            foliage = true,
            plaster = true,
            plastic = true,
            masonery = true,
        }
    },
    ParticleSpawner={
        fire = "YES",
        smoke = "YES",
        wind = "NO",
        spawn_light = "OFF",
        red_light_divider = 1,
        green_light_divider = 1.75,
        blue_light_divider = 4,
        light_flickering_intensity = 4,
        fire_to_smoke_ratio = "1:2",
        dynamic_fps = "ON",
        dynamic_fps_target = 35,
        particle_refresh_max = 48,
        particle_refresh_min = 12,
        aggressivenes = 1,
    },
    Particle = {
        intensity_mp = "Use Material Property",
        drag_mp = "Use Material Property",
        gravity_mp = "Use Material Property",
        lifetime_mp = "1x",
        intensity_scale = 1,
        duplicator = 1,
        smoke_fadein = 2,
        smoke_fadeout = 10,
        fire_fadein = 15,
        fire_fadeout = 20,
        fire_emissive = 4,
        embers = "LOW",
        windvisible = "OFF",
        windspawnrate = 4,
        windstrength = 10,
        winddirection = 360,
        windheight = 40,
        windwidth =  4,
        winddirrandom = 4,
        windstrengthrandom = 5,
        winddistancefrompoint = 4,
        windheightincrement = 4,
        windwidthincrement = 4,
    },
    FireMaterial = {
        wood={
            color={r=1.0, g=0.6, b=0.5, a=1},
            lifetime=1,
            size=0.7,
            gravity=2,
            speed=0.1,
            drag=0.2,
            variation=0.4,
        },
        foliage={
            color={r=1.0, g=0.6, b=0.5, a=1},
            lifetime=1,
            size=0.7,
            gravity=2,
            speed=0.1,
            drag=0.2,
            variation=0.4,
        },
        plaster={
            color={r=1.0, g=0.6, b=0.5, a=1},
            lifetime=1,
            size=0.7,
            gravity=2,
            speed=0.1,
            drag=0.2,
            variation=0.4,
        },
        plastic={
            color={r=1.0, g=0.6, b=0.5, a=1},
            lifetime=1,
            size=0.7,
            gravity=2,
            speed=0.1,
            drag=0.2,
            variation=0.4,
        },
        masonery={
            color={r=1.0, g=0.6, b=0.5, a=1},
            lifetime=1,
            size=0.7,
            gravity=2,
            speed=0.1,
            drag=0.2,
            variation=0.4,
        }
    },
    SmokeMaterial = {
        wood={
            color={r=0.15,g=0.15,b=0.15,a=0.2},
            lifetime=4,
            size=2,
            gravity=4,
            speed=2.5,
            drag=0.4,
            variation=1,
        },
        foliage={
            color={r=0.3,g=0.31,b=0.3,a=0.2},
            lifetime=4,
            size=2,
            gravity=3,
            speed=1.5,
            drag=0.7,
            variation=0.8,
        },
        plaster={
            color={r=0.2,g=0.2,b=0.22,a=0.2},
            lifetime=4,
            size=2,
            gravity=4,
            speed=1,
            drag=0.9,
            variation=0.4,
        },
        plastic={
            color={r=0.1,g=0.1,b=0.12,a=0.2},
            lifetime=4,
            size=2,
            gravity=3,
            speed=0.5,
            drag=1,
            variation=0.1,
        },
        masonery={
            color={r=0.4,g=0.4,b=0.4,a=0.2},
            lifetime=4,
            size=2,
            gravity=4,
            speed=2,
            drag=0.6,
            variation=0.3,
        },
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
    Menu_AppendMenu(Settings_GetPresetMenu())
    Menu_AppendMenu(Settings_GeneralOptions_GetOptionsMenu())
    Menu_AppendMenu(Settings_FireDetector_GetOptionsMenu())
    Menu_AppendMenu(Settings_ParticleSpawner_GetOptionsMenu())
    Menu_AppendMenu(Settings_Particle_GetOptionsMenu())
    Menu_AppendMenu(Settings_FireMaterial_GetOptionsMenu())
    Menu_AppendMenu(Settings_SmokeMaterial_GetOptionsMenu())
end

function Settings_StoreAll()
    Settings_GeneralOptions_Store()
    Settings_FireDetector_Store()
    Settings_ParticleSpawner_Store()
    Settings_Particle_Store()
    Settings_FireMaterial_Store()
    Settings_SmokeMaterial_Store()
end

function Settings_UpdateAll()
    Settings_GeneralOptions_Update()
    Settings_FireDetector_Update()
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
            min_max={0.1, 1.0, 0.1}
        },
        {
            option_parent_text="Particle Color",
            option_text="Green",
            option_note="Configure how green the fire is.",
            option_type="float",
            storage_key="color.g",
            min_max={0.1, 1.0, 0.1}
        },
        {
            option_parent_text="Particle Color",
            option_text="Blue",
            option_note="Configure how transparent the fire is.",
            option_type="float",
            storage_key="color.b",
            min_max={0.1, 1.0, 0.1}
        },
        {
            option_parent_text="Particle Color",
            option_text="Transparancy",
            option_note="Configure how transparent the fire is.",
            option_type="float",
            storage_key="color.a",
            min_max={0.1, 1.0, 0.1}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Life Time",
            option_note="Configure how long a single fire particle exists.",
            option_type="float",
            storage_key="lifetime",
            min_max={0.5, 30, 0.1}
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
            min_max={0.1, 1.0, 0.1}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Transparancy Variation",
            option_note="Configure transparancy variation between fire particles",
            option_type="float",
            storage_key="variation",
            min_max={0.1, 1.0, 0.1}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Size",
            option_note="Size of the fire particle.",
            option_type="float",
            storage_key="size",
            min_max={0.1, 1.0, 0.1}
        },
    }
}

function Settings_FireMaterial_Update(material)
    Settings_SetValue("FireMaterial", material .. ".color.r", Storage_GetFloat("fire_material", material .. ".color.r"))
    Settings_SetValue("FireMaterial", material .. ".color.g", Storage_GetFloat("fire_material", material .. ".color.g"))
    Settings_SetValue("FireMaterial", material .. ".color.b", Storage_GetFloat("fire_material", material .. ".color.b"))
    Settings_SetValue("FireMaterial", material .. ".color.a", Storage_GetFloat("fire_material", material .. ".color.a"))
    Settings_SetValue("FireMaterial", material .. ".lifetime", Storage_GetFloat("fire_material", material .. ".lifetime"))
    Settings_SetValue("FireMaterial", material .. ".size", Storage_GetFloat("fire_material", material .. ".size"))
    Settings_SetValue("FireMaterial", material .. ".gravity", Storage_GetFloat("fire_material", material .. ".gravity"))
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
            min_max={0.1, 1.0, 0.1}
        },
        {
            option_parent_text="Particle Color",
            option_text="Green",
            option_note="Configure how green the smoke is.",
            option_type="float",
            storage_key="color.g",
            min_max={0.1, 1.0, 0.1}
        },
        {
            option_parent_text="Particle Color",
            option_text="Blue",
            option_note="Configure how transparent the smoke is.",
            option_type="float",
            storage_key="color.b",
            min_max={0.1, 1.0, 0.1}
        },
        {
            option_parent_text="Particle Color",
            option_text="Transparancy",
            option_note="Configure how transparent the smoke is.",
            option_type="float",
            storage_key="color.a",
            min_max={0.1, 1.0, 0.1}
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
            min_max={0.1, 10, 0.1}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Drag",
            option_note="Configure drag it has on other smoke particles.",
            option_type="float",
            storage_key="drag",
            min_max={0.1, 1.0, 0.1}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Transparancy Variation",
            option_note="Configure transparancy variation between smoke particles",
            option_type="float",
            storage_key="variation",
            min_max={0.1, 1.0, 0.1}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Size",
            option_note="Size of the smoke particle.",
            option_type="float",
            storage_key="size",
            min_max={0.0, 4.0, 0.1}
        },
    }
}

function Settings_SmokeMaterial_Update(material)
    Settings_SetValue("SmokeMaterial", material .. ".color.r", Storage_GetFloat("smoke_material", material .. ".color.r"))
    Settings_SetValue("SmokeMaterial", material .. ".color.g", Storage_GetFloat("smoke_material", material .. ".color.g"))
    Settings_SetValue("SmokeMaterial", material .. ".color.b", Storage_GetFloat("smoke_material", material .. ".color.b"))
    Settings_SetValue("SmokeMaterial", material .. ".color.a", Storage_GetFloat("smoke_material", material .. ".color.a"))
    Settings_SetValue("SmokeMaterial", material .. ".lifetime", Storage_GetFloat("smoke_material", material .. ".lifetime"))
    Settings_SetValue("SmokeMaterial", material .. ".size", Storage_GetFloat("smoke_material", material .. ".size"))
    Settings_SetValue("SmokeMaterial", material .. ".gravity", Storage_GetFloat("smoke_material", material .. ".gravity"))
    Settings_SetValue("SmokeMaterial", material .. ".speed", Storage_GetFloat("smoke_material", material .. ".speed"))
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
Settings_FireDetector_OptionsDetection =
{
	storage_module="firedetector",
	storage_prefix_key=nil,
    buttons={
		{
			text = "Set Default",
			callback=function() Settings_FireDetector_Default() end,
		},
    },
	update=function() Settings_FireDetector_Update() end,
	option_items={
        {
            option_parent_text="",
            option_text="Max Fires",
            option_note="How many fires may be detected at once.",
            option_type="float",
            storage_key="max_fire",
            min_max={1, 1000, 1}
        },
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
            option_text="Max Group Size Fire Count",
            option_note="The max distance between fires that could be connected to the same fire. Must be larger than minimum distance between fires.",
            option_type="float",
            storage_key="max_group_fire_distance",
            min_max={
                0.5, -- min
                10,   -- max
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
            option_text="Min Distance Between Fires",
            option_note="Distance changes on fire detection radius. Must be smaller than max group size fire count.",
            option_type="float",
            storage_key="min_fire_distance",
            min_max={
                0.1,
                10,
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
            min_max={0.05, 10, 0.05}
        },
	}
}

Settings_FireDetector_OptionsFireBehavior =
{
	storage_module="firedetector",
	storage_prefix_key=nil,
    buttons={
		{
			text = "Set Default",
			callback=function() Settings_FireDetector_Default() end,
		},
    },
	update=function() Settings_FireDetector_Update() end,
	option_items={
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
            option_text="Max Fire Spread Distance",
            option_note="How far at max intensity a fire can spread.",
            option_type="float",
            storage_key="max_fire_spread_distance",
            min_max={1, 20, 1}
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
	}
}

Settings_FireDetector_OptionsFireIntensity =
{
	storage_module="firedetector",
	storage_prefix_key=nil,
    buttons={
		{
			text = "Set Default",
			callback=function() Settings_FireDetector_Default() end,
		},
    },
	update=function() Settings_FireDetector_Update() end,
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
            option_type="float",
            storage_key="fire_intensity_multiplier",
            min_max={1, 100, 1}
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


Settings_FireDetector_OptionsDebugging =
{
	storage_module="firedetector",
	storage_prefix_key=nil,
    buttons={
		{
			text = "Set Default",
			callback=function() Settings_FireDetector_Default() end,
		},
    },
	update=function() Settings_FireDetector_Update() end,
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

function Settings_FireDetector_Update()
    Settings_SetValue("FireDetector", "max_fire_spread_distance", Storage_GetFloat("firedetector", "max_fire_spread_distance"))
    Settings_SetValue("FireDetector", "fire_reaction_time", Storage_GetFloat("firedetector", "fire_reaction_time"))
    Settings_SetValue("FireDetector", "fire_update_time", Storage_GetFloat("firedetector", "fire_update_time"))
    Settings_SetValue("FireDetector", "min_fire_distance", Storage_GetFloat("firedetector", "min_fire_distance"))
    Settings_SetValue("FireDetector", "max_group_fire_distance", Storage_GetFloat("firedetector", "max_group_fire_distance"))
    Settings_SetValue("FireDetector", "max_fire", Storage_GetFloat("firedetector", "max_fire"))
    Settings_SetValue("FireDetector", "fire_intensity", Storage_GetString("firedetector", "fire_intensity"))
    Settings_SetValue("FireDetector", "fire_intensity_multiplier", Storage_GetFloat("firedetector", "fire_intensity_multiplier"))
    Settings_SetValue("FireDetector", "fire_intensity_minimum", Storage_GetFloat("firedetector", "fire_intensity_minimum"))
    Settings_SetValue("FireDetector", "visualize_fire_detection", Storage_GetString("firedetector", "visualize_fire_detection"))
    Settings_SetValue("FireDetector", "fire_explosion", Storage_GetString("firedetector", "fire_explosion"))
    Settings_SetValue("FireDetector", "fire_damage", Storage_GetString("firedetector", "fire_damage"))
    Settings_SetValue("FireDetector", "spawn_fire", Storage_GetString("firedetector", "spawn_fire"))
    Settings_SetValue("FireDetector", "fire_damage_soft", Storage_GetFloat("firedetector", "fire_damage_soft"))
    Settings_SetValue("FireDetector", "fire_damage_medium", Storage_GetFloat("firedetector", "fire_damage_medium"))
    Settings_SetValue("FireDetector", "fire_damage_hard", Storage_GetFloat("firedetector", "fire_damage_hard"))
    Settings_SetValue("FireDetector", "teardown_max_fires", Storage_GetFloat("firedetector", "teardown_max_fires"))
    Settings_SetValue("FireDetector", "teardown_fire_spread", Storage_GetFloat("firedetector", "teardown_fire_spread"))
    Settings_StoreActivePreset()
end

function Settings_FireDetector_Store()
    Storage_SetFloat("firedetector", "max_fire_spread_distance", Settings_GetValue("FireDetector", "max_fire_spread_distance"))
    Storage_SetFloat("firedetector", "fire_reaction_time", Settings_GetValue("FireDetector", "fire_reaction_time"))
    Storage_SetFloat("firedetector", "fire_update_time", Settings_GetValue("FireDetector", "fire_update_time"))
    Storage_SetFloat("firedetector", "min_fire_distance", Settings_GetValue("FireDetector", "min_fire_distance"))
    Storage_SetFloat("firedetector", "max_group_fire_distance", Settings_GetValue("FireDetector", "max_group_fire_distance"))
    Storage_SetFloat("firedetector", "max_fire", Settings_GetValue("FireDetector", "max_fire"))
    Storage_SetString("firedetector", "fire_intensity", Settings_GetValue("FireDetector", "fire_intensity"))
    Storage_SetFloat("firedetector", "fire_intensity_multiplier", Settings_GetValue("FireDetector", "fire_intensity_multiplier"))
    Storage_SetFloat("firedetector", "fire_intensity_minimum", Settings_GetValue("FireDetector", "fire_intensity_minimum"))
    Storage_SetString("firedetector", "visualize_fire_detection", Settings_GetValue("FireDetector", "visualize_fire_detection"))
    Storage_SetString("firedetector", "fire_explosion", Settings_GetValue("FireDetector", "fire_explosion"))
    Storage_SetString("firedetector", "fire_damage", Settings_GetValue("FireDetector", "fire_damage"))
    Storage_SetString("firedetector", "spawn_fire", Settings_GetValue("FireDetector", "spawn_fire"))
    Storage_SetFloat("firedetector", "fire_damage_soft", Settings_GetValue("FireDetector", "fire_damage_soft"))
    Storage_SetFloat("firedetector", "fire_damage_medium", Settings_GetValue("FireDetector", "fire_damage_medium"))
    Storage_SetFloat("firedetector", "fire_damage_hard", Settings_GetValue("FireDetector", "fire_damage_hard"))
    Storage_SetFloat("firedetector", "teardown_max_fires", Settings_GetValue("FireDetector", "teardown_max_fires"))
    Storage_SetFloat("firedetector", "teardown_fire_spread", Settings_GetValue("FireDetector", "teardown_fire_spread"))
    Settings_StoreActivePreset()
end

function Settings_FireDetector_Default()
    _LoadedSettings["FireDetector"] = Settings_Template["FireDetector"]
    Settings_FireDetector_Store()
end

function Settings_FireDetector_GetOptionsMenu()
    return {
        menu_title = "Fire Settings",
        sub_menus={
            {
                sub_menu_title="Detection",
                options=Settings_FireDetector_OptionsDetection,
                description="Change settings regarding fire detection, e.g. minimum distance, or the maximum size arround a fire it may use to detect intensity.\nNote: the size of the box to count fires is used to spawn lights in! Setting this 1:1 to minimum fire distance will make lights spawn for each detected fire!\n. Note: Teardown Max Fire and Fire Spread is part of the base game and has no relation to other fire spread settings in this mod!"
            },
            {
                sub_menu_title="Fire Behavior",
                options=Settings_FireDetector_OptionsFireBehavior,
                description="The fire bahavior settings allow for adjusting how fire behaves. \n Behavio includes: damage, fire spreading (not teardowns own fire spreading settings, but other method implemented by this mod.))\n Note: Spawn Fire option actually spawns more 'actual' fires (from the game) which this mod can detect again! \n This setting is related to Max Fire Spread option! \n If SpawnFire is disabled, the Max Fire Spread option is not used."
            },
            {
                sub_menu_title="Fire Intensity",
                options=Settings_FireDetector_OptionsFireIntensity,
                description="Intensity settings that determine how big fire particles/smoke particles are when spawned. \n Intensity also influences the damage if enabled, light intensity if enabled, \n and spreading if enabled (spawn fire), which are configured in the other menus!"
            },
            {
                sub_menu_title="Debugging",
                options=Settings_FireDetector_OptionsDebugging,
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
            min_max={35, 60, 1}
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
            option_text="Spawn Wind Particles [EXPERIMENTAL]",
            option_note="Enable this to spawn wind particles, wind particles are experimental and performance costly and sometimes buggy!",
            option_type="text",
            storage_key="wind",
            options={"YES", "NO"}
        },
        {
            option_parent_text="",
            option_text="Fire to Smoke ratio",
            option_note="How many fire particles per spawning of smoke particles should spawn. (e.g. 1 smoke every 8 fire particles)",
            option_type="text",
            storage_key="toggle_smoke_fire",
            options={"1:1", "1:2", "1:4", "1:8"}
        }
	}
}

Settings_ParticleSpawner_Light_Options =
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
            option_text="Enable Light Effect",
            option_note="Also spawn lights to simulate fire emitting more intense light.",
            option_type="text",
            storage_key="spawn_light",
            options={"ON", "OFF"}
        },
        {
            option_parent_text="",
            option_text="Red Light Divider",
            option_note="Note: Light color is based on fire color, dividers can be used to make adjustments to the light specifically!",
            option_type="float",
            storage_key="red_light_divider",
            min_max={1, 10, 0.05}
        },
        {
            option_parent_text="",
            option_text="Green Light Divider",
            option_note="Note: Light color is based on fire color, dividers can be used to make adjustments to the light specifically!",
            option_type="float",
            storage_key="green_light_divider",
            min_max={1, 10, 0.05}
        },
        {
            option_parent_text="",
            option_text="Blue Light Divider",
            option_note="Note: Light color is based on fire color, dividers can be used to make adjustments to the light specifically!",
            option_type="float",
            storage_key="blue_light_divider",
            min_max={1, 10, 0.05}
        },
        {
            option_parent_text="",
            option_text="Light Flickering Intensity",
            option_note="Note: changes how much the light flickers, which is based on the fire intensity.",
            option_type="float",
            storage_key="light_flickering_intensity",
            min_max={1, 10, 1}
        }
	}
}


function Settings_ParticleSpawner_Update()
    Settings_SetValue("ParticleSpawner", "fire", Storage_GetString("particlespawner", "fire"))
    Settings_SetValue("ParticleSpawner", "smoke", Storage_GetString("particlespawner", "smoke"))
    Settings_SetValue("ParticleSpawner", "wind", Storage_GetString("particlespawner", "wind"))
    Settings_SetValue("ParticleSpawner", "spawn_light", Storage_GetString("particlespawner", "spawn_light"))
    Settings_SetValue("ParticleSpawner", "red_light_divider", Storage_GetFloat("particlespawner", "red_light_divider"))
    Settings_SetValue("ParticleSpawner", "green_light_divider", Storage_GetFloat("particlespawner", "green_light_divider"))
    Settings_SetValue("ParticleSpawner", "blue_light_divider", Storage_GetFloat("particlespawner", "blue_light_divider"))
    Settings_SetValue("ParticleSpawner", "light_flickering_intensity", Storage_GetFloat("particlespawner", "light_flickering_intensity"))
    Settings_SetValue("ParticleSpawner", "fire_to_smoke_ratio", Storage_GetString("particlespawner", "fire_to_smoke_ratio"))
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
    Storage_SetString("particlespawner", "wind", Settings_GetValue("ParticleSpawner", "wind"))
    Storage_SetString("particlespawner", "spawn_light", Settings_GetValue("ParticleSpawner", "spawn_light"))
    Storage_SetFloat("particlespawner", "red_light_divider", Settings_GetValue("ParticleSpawner", "red_light_divider"))
    Storage_SetFloat("particlespawner", "green_light_divider", Settings_GetValue("ParticleSpawner", "green_light_divider"))
    Storage_SetFloat("particlespawner", "blue_light_divider", Settings_GetValue("ParticleSpawner", "blue_light_divider"))
    Storage_SetFloat("particlespawner", "light_flickering_intensity", Settings_GetValue("ParticleSpawner", "light_flickering_intensity"))
    Storage_SetString("particlespawner", "fire_to_smoke_ratio", Settings_GetValue("ParticleSpawner", "fire_to_smoke_ratio"))
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
			},
			{
				sub_menu_title="Light Settings",
				options=Settings_ParticleSpawner_Light_Options,
                description="This menu allows for adjusting light behavior. (Lights are extremely performance intensive!). \nThe particle spawner also takes care of light hence why it is here."
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

Settings_Wind_Particle_Options =
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
			option_text="Wind Spawn Rate",
			option_note="How often wind should be spawned (higher value is lower).",
			option_type="float",
			storage_key="windspawnrate",
			min_max={1, 60, 1}
		},
		{
			option_parent_text="",
			option_text="Wind Strength",
			option_note="Strength of the wind.",
			option_type="float",
			storage_key="windstrength",
			min_max={1, 100, 1}
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
			option_text="Wind Direction",
			option_note="Wind direction in degrees.",
			option_type="float",
			storage_key="winddirection",
			min_max={0, 360, 1}
		},
		{
			option_parent_text="",
			option_text="Wind Direction Randomness",
			option_note="How much the direction can vary.",
			option_type="float",
			storage_key="winddirrandom",
			min_max={0, 50, 1}
		},
		{
			option_parent_text="",
			option_text="Wind Height",
			option_note="How high the wind should blow.",
			option_type="float",
			storage_key="windheight",
			min_max={1, 100, 1}
		},
		{
			option_parent_text="",
			option_text="Wind Height Increment",
			option_note="The space between each wind particle in height.",
			option_type="float",
			storage_key="windheightincrement",
			min_max={1, 10, 1}
		},
		{
			option_parent_text="",
			option_text="Wind Width",
			option_note="How wide the wind should blow.",
			option_type="float",
			storage_key="windwidth",
			min_max={1, 100, 1}
		},
		{
			option_parent_text="",
			option_text="Wind Width Increment",
			option_note="The space between each wind particle in width.",
			option_type="float",
			storage_key="windwidthincrement",
			min_max={1, 10, 1}
		},
		{
			option_parent_text="",
			option_text="Wind Distance From Point",
			option_note="The space between each wind particle in width.",
			option_type="float",
			storage_key="winddistancefrompoint",
			min_max={1, 50, 1}
		},
		{
			option_parent_text="",
			option_text="Wind Visible",
			option_note="Make wind particles visible (to help debugging)",
			option_type="text",
			storage_key="windvisible",
			options={
				"OFF",
				"ON",
			}
		},
	}
}



function Settings_Particle_Update()
    Settings_SetValue("Particle", "intensity_mp", Storage_GetString("particle", "intensity_mp"))
    Settings_SetValue("Particle", "drag_mp", Storage_GetString("particle", "drag_mp"))
    Settings_SetValue("Particle", "gravity_mp", Storage_GetString("particle", "gravity_mp"))
    Settings_SetValue("Particle", "lifetime_mp", Storage_GetString("particle", "lifetime_mp"))
    Settings_SetValue("Particle", "intensity_scale", Storage_GetFloat("particle", "intensity_scale"))
    Settings_SetValue("Particle", "duplicator", Storage_GetFloat("particle", "duplicator"))
    Settings_SetValue("Particle", "smoke_fadein", Storage_GetFloat("particle", "smoke_fadein"))
    Settings_SetValue("Particle", "smoke_fadeout", Storage_GetFloat("particle", "smoke_fadeout"))
    Settings_SetValue("Particle", "fire_fadein", Storage_GetFloat("particle", "fire_fadein"))
    Settings_SetValue("Particle", "fire_fadeout", Storage_GetFloat("particle", "fire_fadeout"))
    Settings_SetValue("Particle", "fire_emissive", Storage_GetFloat("particle", "fire_emissive"))
    Settings_SetValue("Particle", "embers", Storage_GetString("particle", "embers"))
    Settings_SetValue("Particle", "windspawnrate", Storage_GetFloat("particle", "windspawnrate"))
    Settings_SetValue("Particle", "windvisible", Storage_GetString("particle", "windvisible"))
    Settings_SetValue("Particle", "windstrength", Storage_GetFloat("particle", "windstrength"))
    Settings_SetValue("Particle", "winddirection", Storage_GetFloat("particle", "winddirection"))
    Settings_SetValue("Particle", "windheight", Storage_GetFloat("particle", "windheight"))
    Settings_SetValue("Particle", "windwidth", Storage_GetFloat("particle", "windwidth"))
    Settings_SetValue("Particle", "winddirrandom", Storage_GetFloat("particle", "winddirrandom"))
    Settings_SetValue("Particle", "windstrengthrandom", Storage_GetFloat("particle", "windstrengthrandom"))
    Settings_SetValue("Particle", "winddistancefrompoint", Storage_GetFloat("particle", "winddistancefrompoint"))
    Settings_SetValue("Particle", "windheightincrement", Storage_GetFloat("particle", "windheightincrement"))
    Settings_SetValue("Particle", "windwidthincrement", Storage_GetFloat("particle", "windwidthincrement"))
    Settings_StoreActivePreset()
end

function Settings_Particle_Store()
    Storage_SetString("particle", "intensity_mp", Settings_GetValue("Particle", "intensity_mp"))
    Storage_SetString("particle", "drag_mp", Settings_GetValue("Particle", "drag_mp"))
    Storage_SetString("particle", "gravity_mp", Settings_GetValue("Particle", "gravity_mp"))
    Storage_SetString("particle", "lifetime_mp", Settings_GetValue("Particle", "lifetime_mp"))
    Storage_SetFloat("particle", "intensity_scale", Settings_GetValue("Particle", "intensity_scale"))
    Storage_SetFloat("particle", "duplicator", Settings_GetValue("Particle", "duplicator"))
    Storage_SetFloat("particle", "smoke_fadein", Settings_GetValue("Particle", "smoke_fadein"))
    Storage_SetFloat("particle", "smoke_fadeout", Settings_GetValue("Particle", "smoke_fadeout"))
    Storage_SetFloat("particle", "fire_fadein", Settings_GetValue("Particle", "fire_fadein"))
    Storage_SetFloat("particle", "fire_fadeout", Settings_GetValue("Particle", "fire_fadeout"))
    Storage_SetFloat("particle", "fire_emissive", Settings_GetValue("Particle", "fire_emissive"))
    Storage_SetString("particle", "embers", Settings_GetValue("Particle", "embers"))
    Storage_SetFloat("particle", "windspawnrate", Settings_GetValue("Particle", "windspawnrate"))
    Storage_SetString("particle", "windvisible", Settings_GetValue("Particle", "windvisible"))
    Storage_SetFloat("particle", "windstrength", Settings_GetValue("Particle", "windstrength"))
    Storage_SetFloat("particle", "winddirection", Settings_GetValue("Particle", "winddirection"))
    Storage_SetFloat("particle", "windheight",  Settings_GetValue("Particle", "windheight"))
    Storage_SetFloat("particle", "windwidth",  Settings_GetValue("Particle", "windwidth"))
    Storage_SetFloat("particle", "winddirrandom",  Settings_GetValue("Particle", "winddirrandom"))
    Storage_SetFloat("particle", "windstrengthrandom",  Settings_GetValue("Particle", "windstrengthrandom"))
    Storage_SetFloat("particle", "winddistancefrompoint",  Settings_GetValue("Particle", "winddistancefrompoint"))
    Storage_SetFloat("particle", "windheightincrement",  Settings_GetValue("Particle", "windheightincrement"))
    Storage_SetFloat("particle", "windwidthincrement",  Settings_GetValue("Particle", "windwidthincrement"))
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
                description="These settings are applied to all fire particles (independent of the material), for some quick adjustments if necessary."
			},
			{
				sub_menu_title="Smoke",
				options=Settings_Smoke_Particle_Options,
                description="These settings are applied to all smoke particles (independent of the material), for some quick adjustments if necessary."
			},
			{
				sub_menu_title="Wind [EXPERIMENTAL]",
				options=Settings_Wind_Particle_Options,
                description="These settings are applied to all wind particles (independent of the material), for some quick adjustments if necessary. \nNote that wind simulation is performance expensive and currently isn't 100% bug free!"
			}
		}
	}
end
