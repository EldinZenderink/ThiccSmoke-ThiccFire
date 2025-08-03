-- generaloptions.lua
-- @date 2021-09-06
-- @author Eldin Zenderink
-- @brief Contains configuration for the mod
GeneralOptions = {}

GeneralOptions.Settings = nil
GeneralOptions.Properties = {
    toggle_menu_key="U",
    ui_in_game="NO",
    debug="NO",
    enabled="YES"
}

function GeneralOptions.Init(settings)
    GeneralOptions.Settings = settings
    GeneralOptions.Settings.RegisterUpdateSettingsCallback(GeneralOptions.UpdateSettingsFromSettings)
end

function GeneralOptions.GetToggleMenuKey()
    return GeneralOptions.Properties["toggle_menu_key"]
end

function GeneralOptions.GetDebug()
    DebugPrint("Get debug")
    return GeneralOptions.Properties["debug"]
end

function GeneralOptions.GetShowUiInGame()
    return GeneralOptions.Properties["ui_in_game"]
end

function GeneralOptions.UpdateSettingsFromSettings()
	GeneralOptions.Properties["toggle_menu_key"] = GeneralOptions.Settings.GetValue("GeneralOptions", "toggle_menu_key")
	GeneralOptions.Properties["debug"] = GeneralOptions.Settings.GetValue("GeneralOptions", "debug")
	GeneralOptions.Properties["ui_in_game"] = GeneralOptions.Settings.GetValue("GeneralOptions", "ui_in_game")
end

