-- material.lua
-- @date 2021-09-06
-- @author Eldin Zenderink
-- @brief Configure material types

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

local _MaterialDefaultConfiguration = {
    wood={
        color={r=0.15,g=0.15,b=0.15,a=0.7},
        lifetime=15,
        size=1,
        gravity=1,
        speed=1,
        drag=0.9,
        variation=0.4,
    },
    foliage={
        color={r=0.3,g=0.31,b=0.3,a=0.7},
        lifetime=15,
        size=1,
        gravity=1,
        speed=1,
        drag=0.9,
        variation=0.4,
    },
    plaster={
        color={r=0.2,g=0.2,b=0.22,a=0.8},
        lifetime=20,
        size=0.9,
        gravity=1,
        speed=2,
        drag=0.9,
        variation=0.5,
    },
    plastic={
        color={r=0.1,g=0.1,b=0.12,a=0.9},
        lifetime=20,
        size=0.9,
        gravity=1,
        speed=2,
        drag=0.9,
        variation=0.1,
    },
    masonery={
        color={r=0.4,g=0.4,b=0.4,a=0.7},
        lifetime=15,
        size=0.8,
        gravity=1,
        speed=2,
        drag=0.9,
        variation=0.1,
    },
    metal={
        color={r=0.3,g=0.3,b=0.3,a=0.7},
        lifetime=10,
        size=0.8,
        gravity=1,
        speed=2,
        drag=0.9,
        variation=0.1,
    },
}

-- Material settings menu
local Material_Options =
{
    storage_module="material",
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
            min_max={0.0, 1.0}
        },
        {
            option_parent_text="Particle Color",
            option_text="Green",
            option_note="Configure how green the smoke is.",
            option_type="float",
            storage_key="color.g",
            min_max={0.0, 1.0}
        },
        {
            option_parent_text="Particle Color",
            option_text="Blue",
            option_note="Configure how blue the smoke is.",
            option_type="float",
            storage_key="color.b",
            min_max={0.0, 1.0}
        },
        {
            option_parent_text="Particle Color",
            option_text="Transparancy",
            option_note="Configure how transparent the smoke is.",
            option_type="float",
            storage_key="color.a",
            min_max={0.0, 1.0}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Life Time",
            option_note="Configure how long a single smoke particle exists.",
            option_type="int",
            storage_key="lifetime",
            min_max={0, 100}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Size",
            option_note="Configure how big a single smoke particle is.",
            option_type="float",
            storage_key="size",
            min_max={0.0, 5.0}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Gravity",
            option_note="Configure how gravity affects the smoke particles.",
            option_type="int",
            storage_key="gravity",
            min_max={-20, 20}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Speed",
            option_note="Configure the speed at which the smoke particle shoots away.",
            option_type="int",
            storage_key="speed",
            min_max={0, 100}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Drag",
            option_note="Configure drag it has on other smoke particles.",
            option_type="float",
            storage_key="drag",
            min_max={0.0, 1.0}
        },
        {
            option_parent_text="Particle Behavior",
            option_text="Transparancy Variation",
            option_note="Configure transparancy variation between smoke particles",
            option_type="float",
            storage_key="variation",
            min_max={0.0, 1.0}
        }
    }
}
-- To be filled in the Material_Init function
local _MaterialConfiguration = {}

-- Init function
-- @param default = when set to true set the default values and store them.
function Material_Init(default)
    if default then
        Material_DefaultSettingsAll()
        Material_StoreSettingsAll()
    else
        Material_DefaultSettingsAll()
        Material_UpdateSettingsFromStorageAll()
    end
end

---Provide a table to build a option menu for this module
---@return table
function Material_GetOptionsMenu()
    local materialMenus = {
        menu_title="Materials",
        sub_menus={}
    }
    for material, properties in pairs(_MaterialConfiguration) do
        local materialOptions = Generic_deepCopy(Material_Options)
        materialOptions["storage_prefix_key"] = material
        materialOptions["default"] = function()Material_DefaultSettings(material)end
        materialOptions["update"] = function()Material_UpdateSettingsFromStorage(material)end
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
function Material_GetSettings(material)
    return _MaterialConfiguration[material]
end

---Configure the materials default settings.
---@param material string - the material
function Material_DefaultSettings(material)
    _MaterialConfiguration[material] = _MaterialDefaultConfiguration[material]
    Material_StoreSettingsAll()
end

---Store default settings for all materials
function Material_DefaultSettingsAll()
    for material, properties in pairs(_MaterialDefaultConfiguration) do
        _MaterialConfiguration[material] = properties
	end
    Material_StoreSettingsAll()
end

--- Apply material configuration stored in storage to a specific material
---@param material string -- the material to store the data for
function Material_UpdateSettingsFromStorage(material)
    _MaterialConfiguration[material]["color"]["r"] = Storage_GetFloat("material", material .. ".color.r")
    _MaterialConfiguration[material]["color"]["g"] = Storage_GetFloat("material", material .. ".color.g")
    _MaterialConfiguration[material]["color"]["b"] = Storage_GetFloat("material", material .. ".color.b")
    _MaterialConfiguration[material]["color"]["a"] = Storage_GetFloat("material", material .. ".color.a")
    _MaterialConfiguration[material]["lifetime"] = Storage_GetInt("material", material .. ".lifetime")
    _MaterialConfiguration[material]["size"] = Storage_GetFloat("material", material .. ".size")
    _MaterialConfiguration[material]["gravity"] = Storage_GetInt("material", material .. ".gravity")
    _MaterialConfiguration[material]["speed"] = Storage_GetInt("material", material .. ".speed")
    _MaterialConfiguration[material]["drag"] = Storage_GetFloat("material", material .. ".drag")
    _MaterialConfiguration[material]["variation"] = Storage_GetFloat("material", material .. ".variation")
end

--- Update the configuration for all materials from storage at once
function Material_UpdateSettingsFromStorageAll()
    for material, properties in pairs(_MaterialDefaultConfiguration) do
        Material_UpdateSettingsFromStorage(material)
	end
end

---Store configuration from materials configured during run time to storage
---@param material string - the material to store
function Material_StoreSettings(material)
    Storage_SetFloat("material", material .. ".color.r", _MaterialConfiguration[material]["color"]["r"])
    Storage_SetFloat("material", material .. ".color.g", _MaterialConfiguration[material]["color"]["g"])
    Storage_SetFloat("material", material .. ".color.b", _MaterialConfiguration[material]["color"]["b"])
    Storage_SetFloat("material", material .. ".color.a", _MaterialConfiguration[material]["color"]["a"])
    Storage_SetInt("material", material .. ".lifetime", _MaterialConfiguration[material]["lifetime"])
    Storage_SetFloat("material", material .. ".size", _MaterialConfiguration[material]["size"])
    Storage_SetInt("material", material .. ".gravity", _MaterialConfiguration[material]["gravity"])
    Storage_SetInt("material", material .. ".speed", _MaterialConfiguration[material]["speed"])
    Storage_SetFloat("material", material .. ".drag", _MaterialConfiguration[material]["drag"])
    Storage_SetFloat("material", material .. ".variation", _MaterialConfiguration[material]["variation"])
end

--- Store configuration for all materials configured during run time at once
function Material_StoreSettingsAll()
    for material, properties in pairs(_MaterialDefaultConfiguration) do
        Material_StoreSettings(material)
	end
end

---Reetrieve specific material configuration as table.
---@param material string - the material to get the configuration for
---@return table - the table containing the materials configuration
function Material_GetInfo(material)
    return _MaterialConfiguration[material]
end