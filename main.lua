-- main.lua
-- @date 2021-09-06
-- @author Eldin Zenderink
-- @brief Do only basic sewing of functions here, do the logic in the "sub" modules
-- @note (to self) I need to rewrite all of this again and use some proper "class" like functions ;p

#include "generic.lua"
#include "generaloptions.lua"
#include "debug.lua"
#include "storage.lua"
#include "version.lua"
#include "menu.lua"
#include "material.lua"
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
   Particle_Init(set_default)
   Material_Init(set_default)
   Menu_Init(set_default)
   Menu_AppendMenu(GeneralOptions_GetOptionsMenu())
   Menu_AppendMenu(FireDetector_GetOptionsMenu())
   Menu_AppendMenu(Particle_GetOptionsMenu())
   Menu_AppendMenu(Material_GetOptionsMenu())
   DebugPrinter("version state: " .. version_state)
end

local Main_TimerTick = 0
local Main_BrokenBodies = nil

function tick(dt)
    if Main_BrokenBodies and Main_BrokenBodies[1] then
        local count = 0
        for body, info in pairs(Main_BrokenBodies[1]) do
            DebugPrinter(Main_TimerTick .. " - BODY[" .. body .. "] MATERIAL[" .. tostring(info["material"]) .. "] TIME [" .. info["timestamp"] .. "]" .. " FIRE [" .. info["fire_on_body"] .. "]")
            Particle_EmitParticle(Material_GetInfo(info["material"]), info["location"], "smoke", info["fire_on_body"])
            count = count + 1
        end
    end
    Main_TimerTick = Main_TimerTick + dt
    GeneralOptions_CheckEnabled()
end

function update(dt)
    Main_BrokenBodies = FireDetector_FindFireLocations(dt)
end

function draw()
    FireDetector_ShowStatus()
    Menu_GenerateGameMenu()
end
