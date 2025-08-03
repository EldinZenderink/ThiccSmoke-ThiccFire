-- main.lua
-- @date 2021-09-06
-- @author Eldin Zenderink
-- @brief Do only basic sewing of functions here, do the logic in the "sub" modules
-- @note (to self) I need to rewrite all of this again and use some proper "class" like functions ;p

-- #include "generic.lua"
-- #include "generaloptions.lua"
#include "debug.lua"
#include "ui.lua"
#include "generic.lua"
#include "storage.lua"
#include "version.lua"
#include "settings.lua"
-- #include "restoresettings.lua"
-- #include "settings.lua"
#include "smoke_material.lua"
#include "fire_material.lua"
#include "particle_spawner_new.lua"
-- #include "particle.lua"
-- #include "wind.lua"
#include "light_spawner\lightspawner.lua"
#include "firesim.lua"
-- #include "fireextinguishertool.lua"
-- #include "light.lua"
#include "generaloptions.lua"
#include "compatibility.lua"
#include "menu.lua"

function init()
--    Debug_ClearDebug.Printer()
   -- Determine version and if maybe the previous stored data should be transferred
	DebugPrint("Loading Mod 1")
   local version_state = Version.Init("ThiccSmokeThiccFire")
   local set_default = false
   if version_state == "store_default" then
        set_default = true
   elseif version_state == "transfer_stored" then
        set_default = true
   end

   Storage.Init(Version.GetName(), Version.GetCurrent())
   Debug.Init()
   Settings.Init(Generic, Storage, MenuUI, Debug, set_default)
   Settings.LoadMenu()
--    Particle_Init()
--    Wind_Init()
--    Light_Init()
--    FireExtinguisherTool_Init()
   FireMaterial.Init(Settings)
   SmokeMaterial.Init(Settings)
   GeneralOptions.Init(Settings)
   Compatibility.Init(GeneralOptions)
   UI.Init(Storage, Generic)
   MenuUI.Init(UI, Version, GeneralOptions, Compatibility, Settings, Storage, Generic, Debug)
   ParticleSpawner.Init(Generic, Settings, FireMaterial, SmokeMaterial)
   FireSim.Init(Generic, ParticleSpawner, Settings, GeneralOptions, Compatibility)
   Settings.UpdateAll()
end

function tick(dt)
    -- ParticleSpawner.Update(dt)
    -- LightSpawner_Update(dt)
    -- DebugWatch("tickdt", dt)
    FireSim.Update(dt)
end

function update(dt)
    -- FireExtinguisherTool_Update(dt)
    -- FireSim.SpawnFireOnButtonPress(dt)
    FireSim.ShowStatus()
    -- ParticleSpawner_ShowStatus()
    MenuUI.GenerateGameMenuTick()
    -- Wind_ChangeWind(dt, true)
    -- DebugWatch("updatedt", dt)
end

function draw()
    MenuUI.GenerateGameMenu()
end
