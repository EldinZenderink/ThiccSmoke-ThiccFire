-- material.lua
-- @date 2021-09-06
-- @author Eldin Zenderink
-- @brief Configure smoke material types

-- Contain the material default configuration
-- Material should contain the following properties
--  [material_tag] =
--      color={r=[float],g=[float],b=[float],a=[float]},    <= Color (r = red (0 .. 1.0), g = green (0 .. 1.0), b = blue (0 .. 1.0), a = transparancy (0 .. 1.0))
--      lifetime=[int],                                     <= How long should the smoke particle exist (unlimited, recommended 1 .. 30)
--      size=[float],                                       <= Size of the smoke particle (0 .. 1.0),
--      gravity=[int],                                      <= How much gravity pulls the smoke up (positive) or down (negative) (unlimited, recommended -10 .. 10)
--      speed=[int],                                        <= The speed it goes up initially (unlimited, recommended 1 .. 5)
--      drag=[float],                                       <= How much the particle affects other particle movements (0 .. 1)
--      transparancy_variation=[float],                     <= How much variation in transparancy there can be (0 .. 1)

local _SmokeMaterialDefaultConfiguration = {
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

-- Material settings menu
local SmokeMaterial_Options =
{
    storage_module="smoke_material",
    storage_prefix_key=nil,
    default=nil,
    update=nil,
    option_items={
        {
            option_parent_text="Particle Color",
            option_text="Red",
            option_note="Configure how red the smoke is.",
            option_type="float",
            storage_key="color.r",
            min_max={0.0, 1.0, 0.1}
        },
        {
            option_parent_text="Particle Color",
            option_text="Green",
            option_note="Configure how green the smoke is.",
            option_type="float",
            storage_key="color.g",
            min_max={0.0, 1.0, 0.1}
        },
        {
            option_parent_text="Particle Color",
            option_text="Blue",
            option_note="Configure how blue the smoke is.",
            option_type="float",
            storage_key="color.b",
            min_max={0.0, 1.0, 0.1}
        },
        {
            option_parent_text="Particle Color",
            option_text="Transparancy",
            option_note="Configure how transparent the smoke is.",
            option_type="float",
            storage_key="color.a",
            min_max={0.0, 1.0, 0.1}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Life Time",
            option_note="Configure how long a single smoke particle exists.",
            option_type="float",
            storage_key="lifetime",
            min_max={1, 100, 0.5}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Size",
            option_note="Configure how big a single smoke particle is.",
            option_type="float",
            storage_key="size",
            min_max={0.0, 10.0, 0.1}
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
            min_max={0.0, 1.0, 0.1}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Transparancy Variation",
            option_note="Configure transparancy variation between smoke particles",
            option_type="float",
            storage_key="variation",
            min_max={0.0, 1.0, 0.1}
        }
    }
}
-- To be filled in the SmokeMaterial_Init function
local _SmokeMaterialConfiguration = {}

-- Init function
-- @param default = when set to true set the default values and store them.
function SmokeMaterial_Init(default)
    _SmokeMaterialConfiguration = Generic_deepCopy(_SmokeMaterialDefaultConfiguration)
    if default then
        SmokeMaterial_DefaultSettingsAll()
        SmokeMaterial_StoreSettingsAll()
    end
    SmokeMaterial_UpdateSettingsFromStorageAll()
end

---Provide a table to build a option menu for this module
---@return table
function SmokeMaterial_GetOptionsMenu()
    local materialMenus = {
        menu_title="Smoke Materials",
        sub_menus={}
    }
    for material, properties in pairs(_SmokeMaterialConfiguration) do
        local materialOptions = Generic_deepCopy(SmokeMaterial_Options)
        materialOptions["storage_prefix_key"] = material
        local buttons = {{
            text="Set default",
            callback=function()SmokeMaterial_DefaultSettings(material)end
        }}
        materialOptions["buttons"] = buttons
        materialOptions["update"] = function()SmokeMaterial_UpdateSettingsFromStorage(material)end
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
function SmokeMaterial_GetSettings(material)
    return _SmokeMaterialConfiguration[material]
end

---Configure the materials default settings.
---@param material string - the material
function SmokeMaterial_DefaultSettings(material)
    _SmokeMaterialConfiguration[material] = Generic_deepCopy(_SmokeMaterialDefaultConfiguration[material])
    SmokeMaterial_StoreSettings(material)
    SmokeMaterial_UpdateSettingsFromStorageAll()
end

---Store default settings for all materials
function SmokeMaterial_DefaultSettingsAll()
    for material, properties in pairs(_SmokeMaterialDefaultConfiguration) do
        _SmokeMaterialConfiguration[material] = Generic_deepCopy(properties)
        SmokeMaterial_StoreSettings(material)
	end
    SmokeMaterial_UpdateSettingsFromStorageAll()
end

--- Apply material configuration stored in storage to a specific material
---@param material string -- the material to store the data for
function SmokeMaterial_UpdateSettingsFromStorage(material)
    _SmokeMaterialConfiguration[material]["color"]["r"] = Storage_GetFloat("smoke_material", material .. ".color.r")
    _SmokeMaterialConfiguration[material]["color"]["g"] = Storage_GetFloat("smoke_material", material .. ".color.g")
    _SmokeMaterialConfiguration[material]["color"]["b"] = Storage_GetFloat("smoke_material", material .. ".color.b")
    _SmokeMaterialConfiguration[material]["color"]["a"] = Storage_GetFloat("smoke_material", material .. ".color.a")
    _SmokeMaterialConfiguration[material]["lifetime"] = Storage_GetFloat("smoke_material", material .. ".lifetime")
    _SmokeMaterialConfiguration[material]["size"] = Storage_GetFloat("smoke_material", material .. ".size")
    _SmokeMaterialConfiguration[material]["gravity"] = Storage_GetFloat("smoke_material", material .. ".gravity")
    _SmokeMaterialConfiguration[material]["speed"] = Storage_GetFloat("smoke_material", material .. ".speed")
    _SmokeMaterialConfiguration[material]["drag"] = Storage_GetFloat("smoke_material", material .. ".drag")
    _SmokeMaterialConfiguration[material]["variation"] = Storage_GetFloat("smoke_material", material .. ".variation")
end

--- Update the configuration for all materials from storage at once
function SmokeMaterial_UpdateSettingsFromStorageAll()
    for material, properties in pairs(_SmokeMaterialDefaultConfiguration) do
        SmokeMaterial_UpdateSettingsFromStorage(material)
	end
end

---Store configuration from materials configured during run time to storage
---@param material string - the material to store
function SmokeMaterial_StoreSettings(material)
    Storage_SetFloat("smoke_material", material .. ".color.r", _SmokeMaterialConfiguration[material]["color"]["r"])
    Storage_SetFloat("smoke_material", material .. ".color.g", _SmokeMaterialConfiguration[material]["color"]["g"])
    Storage_SetFloat("smoke_material", material .. ".color.b", _SmokeMaterialConfiguration[material]["color"]["b"])
    Storage_SetFloat("smoke_material", material .. ".color.a", _SmokeMaterialConfiguration[material]["color"]["a"])
    Storage_SetFloat("smoke_material", material .. ".lifetime", _SmokeMaterialConfiguration[material]["lifetime"])
    Storage_SetFloat("smoke_material", material .. ".size", _SmokeMaterialConfiguration[material]["size"])
    Storage_SetFloat("smoke_material", material .. ".gravity", _SmokeMaterialConfiguration[material]["gravity"])
    Storage_SetFloat("smoke_material", material .. ".speed", _SmokeMaterialConfiguration[material]["speed"])
    Storage_SetFloat("smoke_material", material .. ".drag", _SmokeMaterialConfiguration[material]["drag"])
    Storage_SetFloat("smoke_material", material .. ".variation", _SmokeMaterialConfiguration[material]["variation"])
end

--- Store configuration for all materials configured during run time at once
function SmokeMaterial_StoreSettingsAll()
    for material, properties in pairs(_SmokeMaterialConfiguration) do
        SmokeMaterial_StoreSettings(material)
	end
end

---Reetrieve specific material configuration as table.
---@param material string - the material to get the configuration for
---@return table - the table containing the materials configuration
function SmokeMaterial_GetInfo(material)
    return _SmokeMaterialConfiguration[material]
end