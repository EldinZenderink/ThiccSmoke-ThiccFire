-- moduleoptions.lua
-- @date 2021-09-06
-- @author Eldin Zenderink
-- @brief Contain a template for a module, which should allow for consistently building modules which can be configured in a menu.
-- @note Requires the following modules: 'generic.lua', 'debug.lua', 'storage.lua'
-- @note All keys in the tables within this template should be available in the actual module, no changing names!


-- Every module should contain a table with default properties.
local Module_Default = {
    string="a string",
    int=1,
    float=1.0,
    input_key="A"
}

-- Then a table with the properties which shall be used by the module
local Module_Properties = {
    string="a string",
    int=1,
    float=1.0,
    input_key="A"
}

-- To allow the properties to appear in a menu, the following table should be created
local Module_Options =
{
	storage_module="module",                                                                    -- The storage_module is used by the menu module to know to which module the property belongs
	storage_prefix_key=nil,                                                                     -- See the Module_GetOptionsMenu() function, multiple instances of this table can be created, for multiple sub menus with their own properties.
	default=function() Module_DefaultSettings() end,                                            -- Callback function to let the menu apply default settings if required
	update=function() Module_UpdateSettingsFromSettings() end,                                   -- Callback function to let the menu apply the settings. (from storage)
	option_items={                                                                              -- List with different kind of options to show with their own ui elements.
		{
			option_parent_text="",                                                                  -- Currently not used, might be used to add sub sections  for grouping options.
			option_text="A string option",                                                          -- The text to show for the options.
			option_note="Additional note with more information about the option",                   -- The note is shown above the text to give the end user more information for the option
			option_type="text",                                                                     -- Tells the menu generator to create a text selector (see options key)
			storage_key="string",                                                                   -- The key to store the value selected to.
			options={                                                                               -- The list whith options that can be switched between when clicked upon. This is also stored!
				"YES",
				"NO"
			}
        },
        {
			option_parent_text="",                                                                  -- Currently not used, might be used to add sub sections  for grouping options.
			option_text="A int option",                                                             -- The text to show for the options.
			option_note="Additional note with more information about the option",                   -- The note is shown above the text to give the end user more information for the option
			option_type="int",                                                                      -- Tells the menu generator to create a integer slider
			storage_key="int",                                                                      -- The key to store the value selected to.
			min_max={                                                                               -- The min and max values for the slider
				0,
				100
			}
        },
        {
			option_parent_text="",                                                                  -- Currently not used, might be used to add sub sections  for grouping options.
			option_text="A float option",                                                           -- The text to show for the options.
			option_note="Additional note with more information about the option",                   -- The note is shown above the text to give the end user more information for the option
			option_type="float",                                                                    -- Tells the menu generator to create a float slider
			storage_key="float",                                                                    -- The key to store the value selected to.
			min_max={                                                                               -- The min and max values for the slider
				0.1,
				1.0
			}
        },
		{
			option_parent_text="",                                                                  -- Currently not used, might be used to add sub sections  for grouping options.
			option_text="A input key option",                                                       -- The text to show for the options.
			option_note="Additional note with more information about the option",                   -- The note is shown above the text to give the end user more information for the option
			option_type="input_key",                                                                -- Tells the menu generator to create a input key option (click on the letter to configure a key, then press a key)
			storage_key="input_key",                                                                -- The key to store the value selected to.
		},
	}
}

-- The init is required to set the default values initially on mod load (determined outside the module), or load the stored configuration.
function Module_Init(default)
	if default then
		Module_DefaultSettings()
	else
		Module_UpdateSettingsFromSettings()
	end
end

-- To allow for generation of a menu for this module, the following function should be implemented:
function Module_GetOptionsMenu()
	return {
		menu_title = "Module Settings",                 -- Name of the title menu
		sub_menus={                                     -- List with submenus, can be multiple but keep in mind how default settings are stored/restored
			{
				sub_menu_title="Module Options",            -- The sub menu title
				options=Module_Options,                     -- The options inside the sub menu
			}
		}
	}
end

-- This functions is required to restore the default settings
function Module_DefaultSettings()
	Storage_SetString("module", "string", Module_Default["string"])
	Storage_SetInt("module", "int", Module_Default["int"])
	Storage_SetFloat("module", "float", Module_Default["float"])
	Storage_SetString("module", "input_key", Module_Default["input_key"])
    Module_UpdateSettingsFromSettings()
end

-- This function is required to apply the properites of the module from storage
function Module_UpdateSettingsFromSettings()
    DebugPrinter("Updating Module from storage")
	Module_Properties["string"] = Storage_GetString("module", "string")
	Module_Properties["int"] = Storage_GetInt("module", "int")
	Module_Properties["float"] = Storage_GetFloat("module", "float")
	Module_Properties["input_key"] = Storage_GetString("module", "input_key")
end