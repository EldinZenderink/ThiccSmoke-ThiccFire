-- fire_material.lua
-- @date 2021-09-06
-- @author Eldin Zenderink
-- @brief Configure material types for fire

-- Contain the material default configuration
-- Material should contain the following properties
--  [material_tag] =
--      color={r=[float],g=[float],b=[float],a=[float]},    <= Color (r = red (0 .. 1.0), g = green (0 .. 1.0), b = blue (0 .. 1.0), a = transparancy (0 .. 1.0))
--      lifetime=[int],                                     <= How long should the fire particle exist (unlimited, recommended 1 .. 30)
--      size=[float],                                       <= Size of the fire particle (0 .. 1.0),
--      gravity=[int],                                      <= How much gravity pulls the fire up (positive) or down (negative) (unlimited, recommended -10 .. 10)
--      speed=[int],                                        <= The speed it goes up initially (unlimited, recommended 1 .. 5)
--      drag=[float],                                       <= How much the particle affects other particle movements (0 .. 1)
--      transparancy_variation=[float],                     <= How much variation in transparancy there can be (0 .. 1)

local _FireMaterialDefaultConfiguration = {
    wood={
        color={a=1},
        lifetime=2,
        size=0.7,
        gravity=2,
        speed=0.1,
        drag=0.2,
        variation=0.4,
    },
    foliage={
        color={a=1},
        lifetime=2,
        size=0.7,
        gravity=2,
        speed=0.1,
        drag=0.2,
        variation=0.4,
    },
    plaster={
        color={a=1},
        lifetime=2,
        size=0.7,
        gravity=2,
        speed=0.1,
        drag=0.2,
        variation=0.4,
    },
    plastic={
        color={a=1},
        lifetime=2,
        size=0.7,
        gravity=2,
        speed=0.1,
        drag=0.2,
        variation=0.4,
    },
    masonery={
        color={a=1},
        lifetime=2,
        size=0.7,
        gravity=2,
        speed=0.1,
        drag=0.2,
        variation=0.4,
    }
}

-- Material settings menu
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

-- To be filled in the FireMaterial_Init function
local _FireMaterialConfiguration = {}

-- Init function
-- @param default = when set to true set the default values and store them.
function FireMaterial_Init(default)
    _FireMaterialConfiguration = Generic_deepCopy(_FireMaterialDefaultConfiguration)
    if default then
        FireMaterial_DefaultSettingsAll()
        FireMaterial_StoreSettingsAll()
    end
    FireMaterial_UpdateSettingsFromStorageAll()
end

---Provide a table to build a option menu for this module
---@return table
function FireMaterial_GetOptionsMenu()
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

---Return a single table entry containing material information such as
--- color
--- lifetime
--- size
--- gravity
--- speed
--- drag
--- variation
---  These properties are used by the particle generator
---@param material any
---@return table
function FireMaterial_GetSettings(material)
    return _FireMaterialConfiguration[material]
end

---Configure the materials default settings.
---@param material string - the material
function FireMaterial_DefaultSettings(material)
    _FireMaterialConfiguration[material] = Generic_deepCopy(_FireMaterialDefaultConfiguration[material])
    FireMaterial_StoreSettings(material)
    FireMaterial_UpdateSettingsFromStorageAll()
end

---Store default settings for all materials
function FireMaterial_DefaultSettingsAll()
    for material, properties in pairs(_FireMaterialDefaultConfiguration) do
        _FireMaterialConfiguration[material] = Generic_deepCopy(properties)
        FireMaterial_StoreSettings(material)
	end
    FireMaterial_UpdateSettingsFromStorageAll()
end

--- Apply material configuration stored in storage to a specific material
---@param material string -- the material to store the data for
function FireMaterial_UpdateSettingsFromStorage(material)
    _FireMaterialConfiguration[material]["color"]["a"] = Storage_GetFloat("fire_material", material .. ".color.a")
    _FireMaterialConfiguration[material]["lifetime"] = Storage_GetFloat("fire_material", material .. ".lifetime")
    _FireMaterialConfiguration[material]["size"] = Storage_GetFloat("fire_material", material .. ".size")
    _FireMaterialConfiguration[material]["gravity"] = Storage_GetFloat("fire_material", material .. ".gravity")
    _FireMaterialConfiguration[material]["speed"] = Storage_GetFloat("fire_material", material .. ".speed")
    _FireMaterialConfiguration[material]["drag"] = Storage_GetFloat("fire_material", material .. ".drag")
    _FireMaterialConfiguration[material]["variation"] = Storage_GetFloat("fire_material", material .. ".variation")
end

--- Update the configuration for all materials from storage at once
function FireMaterial_UpdateSettingsFromStorageAll()
    for material, properties in pairs(_FireMaterialDefaultConfiguration) do
        FireMaterial_UpdateSettingsFromStorage(material)
	end
end

---Store configuration from materials configured during run time to storage
---@param material string - the material to store
function FireMaterial_StoreSettings(material)
    Storage_SetFloat("fire_material", material .. ".color.a", _FireMaterialConfiguration[material]["color"]["a"])
    Storage_SetFloat("fire_material", material .. ".lifetime", _FireMaterialConfiguration[material]["lifetime"])
    Storage_SetFloat("fire_material", material .. ".size", _FireMaterialConfiguration[material]["size"])
    Storage_SetFloat("fire_material", material .. ".gravity", _FireMaterialConfiguration[material]["gravity"])
    Storage_SetFloat("fire_material", material .. ".speed", _FireMaterialConfiguration[material]["speed"])
    Storage_SetFloat("fire_material", material .. ".drag", _FireMaterialConfiguration[material]["drag"])
    Storage_SetFloat("fire_material", material .. ".variation", _FireMaterialConfiguration[material]["variation"])
end

--- Store configuration for all materials configured during run time at once
function FireMaterial_StoreSettingsAll()
    for material, properties in pairs(_FireMaterialConfiguration) do
        FireMaterial_StoreSettings(material)
	end
end

---Reetrieve specific material configuration as table.
---@param material string - the material to get the configuration for
---@return table - the table containing the materials configuration
function FireMaterial_GetInfo(material)
    return _FireMaterialConfiguration[material]
end