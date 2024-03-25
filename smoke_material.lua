-- smoke_material.lua
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
--      rotation=0.5,
--      speed=[int],                                        <= The speed it goes up initially (unlimited, recommended 1 .. 5)
--      drag=[float],                                       <= How much the particle affects other particle movements (0 .. 1)
--      transparancy_variation=[float],                     <= How much variation in transparancy there can be (0 .. 1)

_SmokeMaterialConfiguration = {
    wood = {
        color = { r = 0.15, g = 0.15, b = 0.15, a = 0.8 },
        lifetime = 8,
        size = 1,
        gravity = 3,
        rotation = 0.5,
        speed = 2.5,
        drag = 0.4,
        variation = 1,
    },
    foliage = {
        color = { r = 0.3, g = 0.31, b = 0.3, a = 0.8 },
        lifetime = 8,
        size = 1,
        gravity = 1.5,
        rotation = 0.5,
        speed = 1.5,
        drag = 0.7,
        variation = 0.8,
    },
    plaster = {
        color = { r = 0.2, g = 0.2, b = 0.22, a = 0.8 },
        lifetime = 8,
        size = 1,
        gravity = 1.5,
        rotation = 0.5,
        speed = 1,
        drag = 0.9,
        variation = 0.4,
    },
    plastic = {
        color = { r = 0.1, g = 0.1, b = 0.12, a = 0.8 },
        lifetime = 8,
        size = 1,
        gravity = 1.5,
        rotation = 0.5,
        speed = 0.5,
        drag = 1,
        variation = 0.1,
    }
}


function SmokeMaterial_Init()
    Settings_RegisterUpdateSettingsCallback(SmokeMaterial_UpdateSettingsFromSettings)
end

--- Apply material configuration stored in storage to a specific material
---@param material string -- the material to store the data for
function SmokeMaterial_UpdateSettingsFromSettingsMaterial(material)
    _SmokeMaterialConfiguration[material]["color"]["r"] = Settings_GetValue("SmokeMaterial", material .. ".color.r")
    _SmokeMaterialConfiguration[material]["color"]["g"] = Settings_GetValue("SmokeMaterial", material .. ".color.g")
    _SmokeMaterialConfiguration[material]["color"]["b"] = Settings_GetValue("SmokeMaterial", material .. ".color.b")
    _SmokeMaterialConfiguration[material]["color"]["a"] = Settings_GetValue("SmokeMaterial", material .. ".color.a")
    _SmokeMaterialConfiguration[material]["lifetime"] = Settings_GetValue("SmokeMaterial", material .. ".lifetime")
    _SmokeMaterialConfiguration[material]["size"] = Settings_GetValue("SmokeMaterial", material .. ".size")
    _SmokeMaterialConfiguration[material]["gravity"] = Settings_GetValue("SmokeMaterial", material .. ".gravity")
    _SmokeMaterialConfiguration[material]["speed"] = Settings_GetValue("SmokeMaterial", material .. ".speed")
    _SmokeMaterialConfiguration[material]["drag"] = Settings_GetValue("SmokeMaterial", material .. ".drag")
    _SmokeMaterialConfiguration[material]["variation"] = Settings_GetValue("SmokeMaterial", material .. ".variation")

    -- Update old presets if it does not contain this property
    if  Settings_GetValue("SmokeMaterial", material .. ".rotation") == 0 or Settings_GetValue("SmokeMaterial", material .. ".rotation") == nil then
        Settings_SetValue("SmokeMaterial", material .. ".rotation", 0.5)
    end
    _SmokeMaterialConfiguration[material]["rotation"] = Settings_GetValue("SmokeMaterial", material .. ".rotation")

end

--- Update the configuration for all materials from storage at once
function SmokeMaterial_UpdateSettingsFromSettings()
    for material, properties in pairs(_SmokeMaterialConfiguration) do
        SmokeMaterial_UpdateSettingsFromSettingsMaterial(material)
	end
end

---Store configuration
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
function SmokeMaterial_GetInfo(material)
    return _SmokeMaterialConfiguration[material]
end