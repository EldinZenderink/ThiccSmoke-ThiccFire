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
--      speed=[int],                                        <= The speed it goes up initially (unlimited, recommended 1 .. 5)
--      drag=[float],                                       <= How much the particle affects other particle movements (0 .. 1)
--      transparancy_variation=[float],                     <= How much variation in transparancy there can be (0 .. 1)

local _FireMaterialConfiguration = {
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

function FireMaterial_Init()
    Settings_RegisterUpdateSettingsCallback(FireMaterial_UpdateSettingsFromSettings)
end

--- Apply material configuration stored in storage to a specific material
---@param material string -- the material to store the data for
function FireMaterial_UpdateSettingsFromSettingsMaterial(material)
    _FireMaterialConfiguration[material]["color"]["r"] = Settings_GetValue("FireMaterial", material .. ".color.r")
    _FireMaterialConfiguration[material]["color"]["g"] = Settings_GetValue("FireMaterial", material .. ".color.g")
    _FireMaterialConfiguration[material]["color"]["b"] = Settings_GetValue("FireMaterial", material .. ".color.b")
    _FireMaterialConfiguration[material]["color"]["a"] = Settings_GetValue("FireMaterial", material .. ".color.a")
    _FireMaterialConfiguration[material]["lifetime"] = Settings_GetValue("FireMaterial", material .. ".lifetime")
    _FireMaterialConfiguration[material]["size"] = Settings_GetValue("FireMaterial", material .. ".size")
    _FireMaterialConfiguration[material]["gravity"] = Settings_GetValue("FireMaterial", material .. ".gravity")
    _FireMaterialConfiguration[material]["speed"] = Settings_GetValue("FireMaterial", material .. ".speed")
    _FireMaterialConfiguration[material]["drag"] = Settings_GetValue("FireMaterial", material .. ".drag")
    _FireMaterialConfiguration[material]["variation"] = Settings_GetValue("FireMaterial", material .. ".variation")
end

--- Update the configuration for all materials from storage at once
function FireMaterial_UpdateSettingsFromSettings()
    for material, properties in pairs(_FireMaterialConfiguration) do
        FireMaterial_UpdateSettingsFromSettingsMaterial(material)
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
function FireMaterial_GetInfo(material)
    return _FireMaterialConfiguration[material]
end