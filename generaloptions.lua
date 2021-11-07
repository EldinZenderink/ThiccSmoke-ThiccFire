-- generaloptions.lua
-- @date 2021-09-06
-- @author Eldin Zenderink
-- @brief Contains configuration for the mod
local GeneralOptions = {
    toggle_menu_key="U",
    ui_in_game="NO",
    debug="NO",
    enabled="YES"
}

function GeneralOptions_Init()
    Settings_RegisterUpdateSettingsCallback(GeneralOptions_UpdateSettingsFromSettings)
end

function GeneralOptions_GetToggleMenuKey()
    return GeneralOptions["toggle_menu_key"]
end

function GeneralOptions_GetDebug()
    return GeneralOptions["debug"]
end

function GeneralOptions_GetShowUiInGame()
    return GeneralOptions["ui_in_game"]
end

function GeneralOptions_UpdateSettingsFromSettings()
	GeneralOptions["toggle_menu_key"] = Settings_GetValue("GeneralOptions", "toggle_menu_key")
	GeneralOptions["debug"] = Settings_GetValue("GeneralOptions", "debug")
	GeneralOptions["ui_in_game"] = Settings_GetValue("GeneralOptions", "ui_in_game")
end

