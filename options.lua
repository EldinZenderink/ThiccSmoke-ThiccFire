-- options.lua
-- @date 2021-09-06
-- @author Eldin Zenderink
-- @brief Do only basic sewing of functions here, do the logic in the "sub" modules
-- @note (to self) I need to rewrite all of this again and use some proper "class" like functions ;p

#include "generic.lua"
#include "generaloptions.lua"
#include "debug.lua"
#include "compatibility.lua"
#include "storage.lua"
#include "restoresettings.lua"
#include "settings.lua"
#include "version.lua"
#include "menu.lua"
#include "smoke_material.lua"
#include "fire_material.lua"
#include "particle_spawner.lua"
#include "particle.lua"
#include "wind.lua"
#include "light.lua"
#include "firedetector.lua"
#include "light_spawner\lightspawner.lua"
#include "presets\preset-low.lua"
#include "presets\preset-medium.lua"
#include "presets\preset-high.lua"
#include "presets\preset-ultra.lua"
#include "presets\preset-slipperygypsy.lua"


function init()
    Debug_ClearDebugPrinter()
    -- Determine version and if maybe the previous stored data should be transferred
    local version_state = Version_Init("ThiccSmokeThiccFire")
    local set_default = false
    local restore = false
    if version_state == "store_default" then
         set_default = true
    elseif version_state == "transfer_stored" then
         set_default = true
         restore = true
    end
    Storage_Init(Version_GetName(), Version_GetCurrent())
    Settings_Init(set_default)
    GeneralOptions_Init()
    Debug_Init()
    FireDetector_Init()
    ParticleSpawner_Init()
    Particle_Init()
    Wind_Init()
    Light_Init()
    FireMaterial_Init()
    SmokeMaterial_Init()
    Menu_Init()
    -- RestoreSettings_Init(restore, Version_GetPrevious(), "ThiccFire")
    Settings_LoadMenu()
    DebugPrinter("version state: " .. version_state)
end

function draw()
    Menu_GenerateMenu()
end
