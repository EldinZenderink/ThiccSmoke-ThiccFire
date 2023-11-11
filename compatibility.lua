-- compatibility.lua
-- @date 2022-08-28
-- @author Eldin Zenderink
-- @brief Detects incompatibility with mods


#include "generic.lua"

CompatibilityIssues = {
    {
        steam_id= "2621950566",
        steam_name = "No Fire Limit",
        note={
            "Value configured for 'Fire Settings->Fire Spread->Teardown Max Fires' will not be applied!",
        },
        settings={"teardown_max_fires", "internal_fire_sim"}
    },
    {        
        steam_id= "2665410612",
        steam_name = "Simple Wind",
        note={"Values configured for all 'Wind Settings->General' options will not be applied!"},
        settings={
            "wind",
            "winddirection",
            "windstrength",
            "windstrengthrandom"
        }
    },
    {        
        steam_id= "2622040244",
        steam_name = "Adjustable Fire",
        note={"Value configured for 'Fire Settings->Fire Spread->Teardown Max Fires' will not be applied!",
              "Value configured for 'Fire Settings->Fire Spread->Teardown Fire Spread' will not be applied!"},
        settings={"teardown_max_fires", "teardown_fire_spread"}
    },
    {        
        steam_id= "2616643931",
        steam_name = "Dennis fire",
        note={"Value configured for 'Fire Settings->Fire Spread->Teardown Max Fires' will not be applied!",
              "Value configured for 'Fire Settings->Fire Spread->Teardown Fire Spread' will not be applied!"},
        settings={"teardown_max_fires", "teardown_fire_spread"}
    },
    {        
        steam_id= "2632228837",
        steam_name = "Dynamic Fire Spread",
        note={"Value configured for 'Fire Settings->Fire Spread->Teardown Max Fires' will not be applied!",
              "Value configured for 'Fire Settings->Fire Spread->Teardown Fire Spread' will not be applied!"},
        settings={"teardown_max_fires", "teardown_fire_spread"}
    }
}


function Compatibility_Init()
    for x=1, #CompatibilityIssues do
        local issue = CompatibilityIssues[x] 
        if GetBool("mods.available.steam-" .. issue["steam_id"] .. ".active") then
            DebugPrint("ThiccSmoke & ThiccFire: INCOMPATIBLE MODS DETECTED!")
            DebugPrint("ThiccSmoke & ThiccFire: OPEN SETTINGS WITH '" .. GeneralOptions_GetToggleMenuKey() .. "' KEY")
            DebugPrint("ThiccSmoke & ThiccFire: TO SEE WHICH MODS ARE CONFLICTING AND WHICH ACTIONS ARE TAKEN BY THE MOD")
            DebugPrint("ThiccSmoke & ThiccFire: THIS MESSAGE WILL BE CLEARED WHEN OPENING THE SETTINGS MENU!")
            break
        end
    end

end

function Compatibility_IsSettingCompatible(setting)
    for x=1, #CompatibilityIssues do
        local issue = CompatibilityIssues[x] 
        if GetBool("mods.available.steam-" .. issue["steam_id"] .. ".active") then
            for y=1, #issue["settings"] do
                -- DebugPrint(setting .. " == " .. issue["settings"][y])
                if issue["settings"][y] == setting then
                    return false
                end
            end
        end
    end
    return true
end


--https://steamcommunity.com/sharedfiles/filedetails/?id=2632228837&searchtext=fire
--https://steamcommunity.com/sharedfiles/filedetails/?id=2616643931&searchtext=fire