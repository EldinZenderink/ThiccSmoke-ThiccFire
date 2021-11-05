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

---Reetrieve specific material configuration as table.
---@param material string - the material to get the configuration for
---@return table - the table containing the materials configuration
function FireMaterial_GetInfo(material)
    return Settings_GetValue("FireMaterial", material)
end