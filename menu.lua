-- menu.lua
-- @date 2021-09-06
-- @author Eldin Zenderink
-- @brief Menu generator  {Module}_GetOptionsMenu()

#include "ui.lua"

_Menu_UI = false
_Menu_List = {}
_Menu_MenuActive = 1
_Menu_SubMenuActive = 1

function Menu_Init()
    _Menu_UI = false
    Storage_SetBool("global", "keyselector.text_input_field_pending", false)
    Storage_SetBool("global", "keyselector.text_input_pending", false)
end

function Menu_AppendMenu(menu)
    table.insert(_Menu_List, menu)
end

function Menu_GenerateSubMenuOptions(title, options, description, x, y)
    UiPush()
	    UiTranslate(x, y)
        UiFont("regular.ttf", 44)
        UiText(title)
        UiTranslate(0, 88)
        local offset_px = 55

        local module = options["storage_module"]
        local key_prefix = options["storage_prefix_key"]
        -- DebugPrinter("Generate option menu for sub menu " .. title .. " or module " .. module .. " with prefix key " .. key_prefix)
        local count = 1
        local update = false
        local offset = 0
        for o=1, #options["option_items"] do
            local option = options["option_items"][o]
            local key = option["storage_key"]
            if key_prefix ~= nil then
                key = key_prefix .. "." .. key
            end
            -- DebugPrinter("Generate option item: " .. option["option_type"])
            if option["option_type"] == "text" then
                update = Ui_StringProperty(0 , offset + offset_px * (o - 1), option["option_text"], option["option_note"], option["options"], module, key)
            elseif option["option_type"] == "input_key" then
                update = Ui_KeySelector(0 , offset + offset_px * (o - 1), option["option_text"], option["option_note"], module, key)
            elseif option["option_type"] == "text_input" then
                update = UI_TextInput(0 , offset + offset_px * (o - 1), option["option_text"], option["option_note"], option["options"], module, key)
            elseif option["option_type"] == "float" then
                update = Ui_FloatProperty(0, offset + offset_px * (o - 1), option["option_text"], option["option_note"], option["min_max"], module, key)
            elseif option["option_type"] == "int" then
                update = Ui_IntProperty(0, offset + offset_px * (o - 1), option["option_text"], option["option_note"], option["min_max"], module, key)
            elseif option["option_type"] == "toggle_button" then
                update = UI_ToggleButton(0, offset + offset_px * (o - 1), option["option_text"], option["option_note"], module, key)
            elseif option["option_type"] == "multi_select" then
                local temp_update = Ui_MultiSelector(0, offset + offset_px * (o - 1), option["option_text"], option["option_note"], option["options"], module, key)
                update = temp_update[1]
                offset = offset + temp_update[2] + offset_px
            elseif option["option_type"] == "text_input_field" then
                local temp_update = UI_TextFieldInput(0, offset + offset_px * (o - 1), option["option_text"], option["option_note"], option["options"], module, key)
                offset = offset + temp_update[2]
            end
            count = o
            if update then
                DebugPrinter("Called update for sub menu " .. title )
                options["update"]()
            end
        end

        local offset_y = count * offset_px + offset
        UiTranslate(0, offset_y)

        local count_butt = 0
        for o=1, #options["buttons"] do
            local button = options["buttons"][o]
            if UI_Button(0, offset_px * o, button["text"]) then
                button["callback"]()
                DebugPrinter("Called setting to default for sub menu " .. title )
            end
            count_butt = count_butt + 1
        end
        offset_y = count_butt * offset_px
        if description ~= nil then
            UiTranslate(0, offset_y + 88)
            UiFont("bold.ttf", 28)
            UiText("Description")
            UiTranslate(0, 33)
            local lines = Generic_SplitString(description, "\n")
            for i=1, #lines do
                UiFont("regular.ttf", 16)
                UiText(lines[i])
                UiTranslate(0, 20)
            end
        end
    UiPop()
end

function Menu_GenerateSubMenu(title, submenus, x, y)
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
        -- on the most right side. If no sub_menu_title is available, the second section will be used to show
        -- the same.

        local submenu = submenus[_Menu_SubMenuActive]
        for i=1, #submenus do
            submenu = submenus[i]
            if UI_ToggleButton(0, offset_px * (i - 1), submenu["sub_menu_title"], 2, i) then
                -- DebugPrinter("Generate option menu for " .. submenu["sub_menu_title"])
                _Menu_SubMenuActive = i
                -- break
            end
        end
        if _Menu_MenuActive > #submenus then
            _Menu_MenuActive = 1
        end
    UiPop()
	-- UiTranslate(-x, -y)
end

function Menu_GenerateMenu()
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
    UiText("Active Preset: " .. tostring(Settings_GetValue("Settings", "ActivePreset")))
    UiTranslate(88, -33)
    UiFont("regular.ttf", 33)
    -- Every menu item contains a list of different menus
    -- The menu will be broken in a left section, containing the top level menu buttons
    -- Then the following section will show whatever menu is clicked on in the first section, showing
    -- the list of all available sub menus, which can be clicked on the show the options in that menu
    -- on the most right side. If no sub_menu_title is available, the second section will be used to show
    -- the same.
    UiTranslate(0, 88)
    UiPush()
    for i=1, #_Menu_List do
        local menu_item = _Menu_List[i]
        if UI_ToggleButton(0, offset_px * (i - 1), menu_item["menu_title"], 1, i) then
            -- DebugPrinter("Generate submenu  for " .. menu_item["menu_title"])
            _Menu_MenuActive = i
            -- break
        end
    end
    UiPop()

    local menu = _Menu_List[_Menu_MenuActive]
    if menu ~= nil then
        Menu_GenerateSubMenu(menu["menu_title"], menu["sub_menus"], 400, -88)
        local submenu = menu["sub_menus"][_Menu_SubMenuActive]
        if menu ~= nil and submenu ~= nil then
            Menu_GenerateSubMenuOptions(submenu["sub_menu_title"], submenu["options"], submenu["description"], 800, -88)
        end
    end

    UiFont("regular.ttf", 16)
    UiTranslate(0, 800)
    UiText("Version: " .. Version_GetCurrentActual())
end


function Menu_GenerateGameMenuTick()
    if PauseMenuButton("ThiccSmoke & ThiccFire Settings") then
		_Menu_UI = not _Menu_UI
	end
end

function Menu_GenerateGameMenu()

    -- DebugPrinter("Toggle menu button: " .. GeneralOptions_GetToggleMenuKey())
    if Storage_GetBool("global", "keyselector.text_input_field_pending") == false and Storage_GetBool("global", "keyselector.text_input_pending") == false then
        if InputPressed(GeneralOptions_GetToggleMenuKey()) then
            _Menu_UI = not _Menu_UI
            -- Debug_ClearDebugPrinter()
            DebugPrinter("Toggle menu button clicked")
        end
    end
    if _Menu_UI then
        -- Make ui clickable.
        UiMakeInteractive()
        UiColor(0.2, 0.2, 0.2, 0.5)
        UiRect(UiWidth(), UiHeight())
        UiColor(1, 1, 1)

        UiTranslate(UiWidth() - 200, 88)
        UiTextShadow(0, 0, 0, 0.5, 0.5)
        UiFont("regular.ttf", 22)
        UiText("Press "  .. GeneralOptions_GetToggleMenuKey() .. " to hide!")
        UiTranslate(-UiWidth() + 200, -88)

        Menu_GenerateMenu()
    else
        if GeneralOptions_GetShowUiInGame() == "YES" then
            UiTranslate(UiWidth() - 300, 88)
            UiTextShadow(0, 0, 0, 0.5, 0.5)
            UiFont("regular.ttf", 22)
            UiText("Press "  .. GeneralOptions_GetToggleMenuKey() .. " to show menu!")
            UiTranslate(-UiWidth() + 300, -33)
        end
    end
end