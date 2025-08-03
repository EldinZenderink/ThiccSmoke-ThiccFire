-- menuUI.lua
-- @date 2021-09-06
-- @author Eldin Zenderink
-- @brief Menu generator  {Module}_GetOptionsMenu()

#include "ui.lua"


MenuUI = {}

MenuUI.UIshown = false
MenuUI.List = {}
MenuUI.Active = 1
MenuUI.SubActive = 1
MenuUI.Initialized = false

function MenuUI.Init(argUI, argVersion, argGeneralOptions, argCompatibility, argSettings, argStorage, argGeneric, argDebug)
    MenuUI.Initialized = true
    MenuUI.UI = argUI
    MenuUI.Version = argVersion
    MenuUI.GeneralOptions = argGeneralOptions
    MenuUI.Compatibility = argCompatibility
    MenuUI.Settings = argSettings
    MenuUI.Storage = argStorage
    MenuUI.Generic = argGeneric
    MenuUI.Debug = argDebug
    MenuUI.UIshown = false
    MenuUI.Storage.SetBool("global", "keyselector.text_input_field_pending", false)
    MenuUI.Storage.SetBool("global", "keyselector.text_input_pending", false)
    DebugPrint("Menu loaded")
end

function MenuUI.AppendMenu(menu)
    table.insert(MenuUI.List, menu)
end

function MenuUI.GenerateSubMenuOptions(title, options, description, x, y)
    UiPush()
	    UiTranslate(x, y)
        UiFont("regular.ttf", 44)
        UiText(title)
        UiTranslate(0, 88)
        local offset_px = 55

        local menu_module = options["module"]
        local key_prefix = options["prefix_key"]
        local count = 1
        local update = false
        local offset = 0
        for o=1, #options["option_items"] do

            local option = options["option_items"][o]
            local menu_key = option["key"]
            if key_prefix ~= nil then
                menu_key = key_prefix .. "." .. menu_key
            end
            MenuUI.Debug.Printer("Generate option item: " .. option["option_type"])
            if option["option_type"] == "text" then
                update = MenuUI.UI.StringProperty(0 , offset + offset_px * (o - 1), option["option_text"], option["option_note"], option["options"], menu_module, menu_key)
            elseif option["option_type"] == "input_key" then
                update = MenuUI.UI.KeySelector(0 , offset + offset_px * (o - 1), option["option_text"], option["option_note"], menu_module, menu_key)
            elseif option["option_type"] == "text_input" then
                update = MenuUI.UI.TextInput(0 , offset + offset_px * (o - 1), option["option_text"], option["option_note"], option["options"], menu_module, menu_key)
            elseif option["option_type"] == "float" then
                update = MenuUI.UI.FloatProperty(0, offset + offset_px * (o - 1), option["option_text"], option["option_note"], option["min_max"], menu_module, menu_key)
            elseif option["option_type"] == "int" then
                update = MenuUI.UI.IntProperty(0, offset + offset_px * (o - 1), option["option_text"], option["option_note"], option["min_max"], menu_module, menu_key)
            elseif option["option_type"] == "toggle_button" then
                update = MenuUI.UI.ToggleButton(0, offset + offset_px * (o - 1), option["option_text"], option["option_note"], menu_module, menu_key)
            elseif option["option_type"] == "multi_select" then
                local temp_update = MenuUI.UI.MultiSelector(0, offset + offset_px * (o - 1), option["option_text"], option["option_note"], option["options"], menu_module, menu_key)
                update = temp_update[1]
                offset = offset + temp_update[2] + offset_px
            elseif option["option_type"] == "text_input_field" then
                local temp_update = MenuUI.UI.TextFieldInput(0, offset + offset_px * (o - 1), option["option_text"], option["option_note"], option["options"], menu_module, menu_key)
                offset = offset + temp_update[2]
            end
            count = o
            if update then
                MenuUI.Debug.Printer("Called update for sub menu " .. title )
                options["update"]()
            end
        end

        local offset_y = count * offset_px + offset
        UiTranslate(0, offset_y)

        local count_butt = 0
        for o=1, #options["buttons"] do
            local button = options["buttons"][o]
            if MenuUI.UI.Button(0, offset_px * o, button["text"]) then
                button["callback"]()
                MenuUI.Debug.Printer("Called setting to default for sub menu " .. title )
            end
            count_butt = count_butt + 1
        end
        offset_y = count_butt * offset_px
        if description ~= nil then
            UiTranslate(0, offset_y + 88)
            UiFont("bold.ttf", 28)
            UiText("Description")
            UiTranslate(0, 33)
            local lines = MenuUI.Generic.SplitString(description, "\n")
            for i=1, #lines do
                UiFont("regular.ttf", 16)
                UiText(lines[i])
                UiTranslate(0, 20)
            end
        end
    UiPop()
end

function MenuUI.GenerateSubMenu(title, submenus, x, y)

    local offset_px = 44
    UiPush()
	    UiTranslate(x, y)
        UiFont("regular.ttf", 44)
        UiText(title)
        UiTranslate(0, 88)
        -- Every menu item contains a list of different menus
        -- The menu will be broken in a left section, containing the top level menu buttons
        -- Then the following section will show whatever menu is clicked on in the first section, showing
        -- the list of all available sub menus, which can be clicked on the show the options in that menu
        -- on the most right side. If no subtitle is available, the second section will be used to show
        -- the same.

        local submenu = submenus[MenuUI.SubActive]
        for i=1, #submenus do
            submenu = submenus[i]
            if MenuUI.UI.ToggleButton(0, offset_px * (i - 1), submenu["sub_menu_title"], 2, i) then
                MenuUI.Debug.Printer("Generate option menu for " .. submenu["sub_menu_title"])
                MenuUI.SubActive = i
                -- break
            end
        end
        if MenuUI.Active > #submenus then
            MenuUI.Active = 1
        end
    UiPop()
	-- UiTranslate(-x, -y)
end

-- https://steamcommunity.com/sharedfiles/filedetails/?id=2622040244&searchtext=fire



function MenuUI.GenerateMenu()
    -- Setup UI

    local offset_px = 44

    UiAlign("left")

    UiColor(0.2, 0.2, 0.2, 0.8)
    UiRect(UiWidth(), UiHeight())
    UiColor(1, 1, 1)
    UiFont("regular.ttf", 44)
    UiTranslate(88, 100)
    UiText("ThiccSmoke & ThiccFire")
    UiFont("regular.ttf", 33)
    UiTranslate(0, 33)
    UiText("Active Preset: " .. tostring(MenuUI.Settings.GetValue("Settings", "ActivePreset")))
    UiTranslate(88, -33)
    UiFont("regular.ttf", 33)
    -- Every menu item contains a list of different menus
    -- The menu will be broken in a left section, containing the top level menu buttons
    -- Then the following section will show whatever menu is clicked on in the first section, showing
    -- the list of all available sub menus, which can be clicked on the show the options in that menu
    -- on the most right side. If no subtitle is available, the second section will be used to show
    -- the same.
    UiTranslate(0, 88)
    UiPush()
    for i=1, #MenuUI.List do
        local Menu_item = MenuUI.List[i]
        if MenuUI.UI.ToggleButton(0, offset_px * (i - 1), Menu_item["menu_title"], 1, i) then
            MenuUI.Active = i
            -- break
        end
    end
    UiPop()


    local menu = MenuUI.List[MenuUI.Active]
    if menu ~= nil then
        MenuUI.GenerateSubMenu(menu["menu_title"], menu["sub_menus"], 400, -88)
        local submenu = menu["sub_menus"][MenuUI.SubActive]
        -- if submenu ~= nil then
        MenuUI.GenerateSubMenuOptions(submenu["sub_menu_title"], submenu["options"], submenu["description"], 800, -88)
        -- end
    end

    UiTranslate(0, 600)
    for x=1, #MenuUI.Compatibility.CompatibilityIssues do
        local issue = MenuUI.Compatibility.CompatibilityIssues[x]
        if GetBool("mods.available.steam-" .. issue["steam_id"] .. ".active") then
            UiColor(1,0,0)
            UiFont("regular.ttf", 16)
            UiText("Detected Incompatible Mod: " .. issue["steam_name"])
            for y=1, #issue["note"] do
                UiTranslate(0, 22)
                UiText("    Note: " .. issue["note"][y])
            end
            UiTranslate(0, 22)
            UiColor(1,1,1)
        end
    end

    UiFont("regular.ttf", 16)
    UiTranslate(0, 44)
    UiText("Version: " .. MenuUI.Version.GetCurrentActual())
end


function MenuUI.GenerateGameMenuTick()

    if PauseMenuButton("ThiccSmoke & ThiccFire Settings") then
		MenuUI.UIshown = not MenuUI.UIshown
	end
end

function MenuUI.GenerateGameMenu()


    -- MenuUI.Debug.Printer("Toggle menu button: " .. MenuUI.GeneralOptions.GetToggleMenuKey())
    if MenuUI.Storage.GetBool("global", "keyselector.text_input_field_pending") == false and MenuUI.Storage.GetBool("global", "keyselector.text_input_pending") == false then
        if InputPressed(MenuUI.GeneralOptions.GetToggleMenuKey()) then
            MenuUI.UIshown = not MenuUI.UIshown
            MenuUI.Debug.ClearDebug()
        end
    end
    if MenuUI.UIshown then
        -- Make ui clickable.
        UiMakeInteractive()
        UiColor(0.2, 0.2, 0.2, 0.5)
        UiRect(UiWidth(), UiHeight())
        UiColor(1, 1, 1)

        UiTranslate(UiWidth() - 200, 88)
        UiTextShadow(0, 0, 0, 0.5, 0.5)
        UiFont("regular.ttf", 22)
        UiText("Press "  .. MenuUI.GeneralOptions.GetToggleMenuKey() .. " to hide!")
        UiTranslate(-UiWidth() + 200, -88)

        MenuUI.GenerateMenu()
    else
        if MenuUI.GeneralOptions.GetShowUiInGame() == "YES" then
            UiTranslate(UiWidth() - 300, 88)
            UiTextShadow(0, 0, 0, 0.5, 0.5)
            UiFont("regular.ttf", 22)
            UiText("Press "  .. MenuUI.GeneralOptions.GetToggleMenuKey() .. " to show menu!")
            UiTranslate(-UiWidth() + 300, -33)
        end
    end
end