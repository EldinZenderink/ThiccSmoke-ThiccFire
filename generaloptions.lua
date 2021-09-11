-- generaloptions.lua
-- @date 2021-09-06
-- @author Eldin Zenderink
-- @brief Contains configuration for the mod

local GeneralOptions_Default = {
    toggle_menu_key="U",
    toggle_mod_key="Y",
    ui_in_game="NO",
    debug="NO",
    enabled="YES"
}

local GeneralOptions = {
    toggle_menu_key="U",
    toggle_mod_key="Y",
    ui_in_game="NO",
    debug="NO",
    enabled="YES"
}

local GeneralOptions_Options =
{
	storage_module="general",
	storage_prefix_key=nil,
	default=function() GeneralOptions_DefaultSettings() end,
	update=function() GeneralOptions_UpdateSettingsFromStorage() end,
	option_items={
		{
			option_parent_text="",
			option_text="Show or Hide Menu Key",
			option_note="Set key to show or hide the menu while in game. Click on the letter and press key to change.",
			option_type="input_key",
			storage_key="toggle_menu_key",
		},
		{
			option_parent_text="",
			option_text="Enable or Disable Key",
			option_note="Set key to enable or disable the mod while in game. Click on the letter and press key to change.",
			option_type="input_key",
			storage_key="toggle_mod_key",
		},
		{
			option_parent_text="",
			option_text="Show UI In Game",
			option_note="Shows mod status and key bind text in game.",
			option_type="text",
			storage_key="ui_in_game",
			options={
				"YES",
				"NO"
			}
		},
		{
			option_parent_text="",
			option_text="Enable Debug",
			option_note="Enable debug prints to screen (warning: spam).",
			option_type="text",
			storage_key="debug",
			options={
				"YES",
				"NO"
			}
		},
		{
			option_parent_text="",
			option_text="Mod Enabled",
			option_note="Disables the mod, if you dont want it active all the time.",
			option_type="text",
			storage_key="enabled",
			options={
				"YES",
				"NO"
			}
		},
	}
}


function GeneralOptions_GetEnabled()
    return GeneralOptions["enabled"]
end

function GeneralOptions_GetToggleMenuKey()
    return GeneralOptions["toggle_menu_key"]
end

function GeneralOptions_GetToggleModKey()
    return GeneralOptions["toggle_mod_key"]
end

function GeneralOptions_GetDebug()
    return GeneralOptions["debug"]
end

function GeneralOptions_GetShowUiInGame()
    return GeneralOptions["ui_in_game"]
end


function GeneralOptions_Init(default)
	if default then
		GeneralOptions_DefaultSettings()
	else
		GeneralOptions_UpdateSettingsFromStorage()
	end
end

function GeneralOptions_GetOptionsMenu()
	return {
		menu_title = "General Settings",
		sub_menus={
			{
				sub_menu_title="General Options",
				options=GeneralOptions_Options,
			}
		}
	}
end

function GeneralOptions_DefaultSettings()
	Storage_SetString("general", "toggle_menu_key", GeneralOptions_Default["toggle_menu_key"])
	Storage_SetString("general", "toggle_mod_key", GeneralOptions_Default["toggle_mod_key"])
	Storage_SetString("general", "debug", GeneralOptions_Default["debug"])
	Storage_SetString("general", "ui_in_game", GeneralOptions_Default["ui_in_game"])
	Storage_SetString("general", "enabled", GeneralOptions_Default["enabled"])
	GeneralOptions_UpdateSettingsFromStorage()
end

function GeneralOptions_UpdateSettingsFromStorage()
    DebugPrinter("Updating GeneralOptions from storage")
	GeneralOptions["toggle_menu_key"] = Storage_GetString("general", "toggle_menu_key")
	GeneralOptions["toggle_mod_key"] = Storage_GetString("general", "toggle_mod_key")
	GeneralOptions["debug"] = Storage_GetString("general", "debug")
	GeneralOptions["ui_in_game"] = Storage_GetString("general", "ui_in_game")
	GeneralOptions["enabled"] = Storage_GetString("general", "enabled")
end


function GeneralOptions_CheckEnabled()
	if InputPressed(GeneralOptions_GetToggleModKey()) then
		if GeneralOptions["enabled"] == "YES" then
			GeneralOptions["enabled"] = "NO"
		else
			GeneralOptions["enabled"] = "YES"
		end
		Storage_SetString("general", "enabled", GeneralOptions["enabled"])
	end
end