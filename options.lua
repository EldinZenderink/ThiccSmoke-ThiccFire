#include "generic.lua"
#include "generaloptions.lua"
#include "debug.lua"
#include "storage.lua"
#include "version.lua"
#include "menu.lua"
#include "material.lua"
#include "particle_spawner.lua"
#include "particle.lua"
#include "firedetector.lua"

function init()
    Debug_ClearDebugPrinter()
    -- Determine version and if maybe the previous stored data should be transferred
    local version_state = Version_Init("ThiccSmoke")
    local set_default = false
    if version_state == "store_default" or version_state == "transfer_stored" then
        set_default = true
    end
    Storage_Init(Version_GetName(), Version_GetCurrent())
    GeneralOptions_Init(set_default)
    Debug_Init()
    FireDetector_Init(set_default)
    ParticleSpawner_Init(set_default)
    Particle_Init(set_default)
    Material_Init(set_default)
    Menu_Init(set_default)
    Menu_AppendMenu(GeneralOptions_GetOptionsMenu())
    Menu_AppendMenu(FireDetector_GetOptionsMenu())
    Menu_AppendMenu(ParticleSpawner_GetOptionsMenu())
    Menu_AppendMenu(Particle_GetOptionsMenu())
    Menu_AppendMenu(Material_GetOptionsMenu())
    DebugPrinter("version state: " .. version_state)
end

function draw()
    Menu_GenerateMenu()
end
