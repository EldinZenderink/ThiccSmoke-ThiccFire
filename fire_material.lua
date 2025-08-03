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

_FireMaterialConfiguration = {
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

FireMaterial = {}

function FireMaterial.Init(argSettings)
    FireMaterial.Settings = argSettings
    FireMaterial.Settings.RegisterUpdateSettingsCallback(FireMaterial.UpdateSettingsFromSettings)
end

--- Apply material configuration stored in storage to a specific material
---@param material string -- the material to store the data for
function FireMaterial.UpdateSettingsFromSettingsMaterial(material)
    _FireMaterialConfiguration[material]["color"]["r"] = FireMaterial.Settings.GetValue("FireMaterial", material .. ".color.r")
    _FireMaterialConfiguration[material]["color"]["g"] = FireMaterial.Settings.GetValue("FireMaterial", material .. ".color.g")
    _FireMaterialConfiguration[material]["color"]["b"] = FireMaterial.Settings.GetValue("FireMaterial", material .. ".color.b")
    _FireMaterialConfiguration[material]["color"]["a"] = FireMaterial.Settings.GetValue("FireMaterial", material .. ".color.a")
    _FireMaterialConfiguration[material]["lifetime"] = FireMaterial.Settings.GetValue("FireMaterial", material .. ".lifetime")
    _FireMaterialConfiguration[material]["size"] = FireMaterial.Settings.GetValue("FireMaterial", material .. ".size")
    _FireMaterialConfiguration[material]["gravity"] = FireMaterial.Settings.GetValue("FireMaterial", material .. ".gravity")
    _FireMaterialConfiguration[material]["speed"] = FireMaterial.Settings.GetValue("FireMaterial", material .. ".speed")
    _FireMaterialConfiguration[material]["drag"] = FireMaterial.Settings.GetValue("FireMaterial", material .. ".drag")
    _FireMaterialConfiguration[material]["variation"] = FireMaterial.Settings.GetValue("FireMaterial", material .. ".variation")
    if  FireMaterial.Settings.GetValue("FireMaterial", material .. ".rotation") == 0 or FireMaterial.Settings.GetValue("FireMaterial", material .. ".rotation") == nil then
        FireMaterial.Settings.SetValue("FireMaterial", material .. ".rotation", 0.5)
    end
    _FireMaterialConfiguration[material]["rotation"] = FireMaterial.Settings.GetValue("FireMaterial", material .. ".rotation")
end

--- Update the configuration for all materials from storage at once
function FireMaterial.UpdateSettingsFromSettings()
    for material, properties in pairs(_FireMaterialConfiguration) do
        FireMaterial.UpdateSettingsFromSettingsMaterial(material)
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
function FireMaterial.GetInfo(material)
    return _FireMaterialConfiguration[material]
end