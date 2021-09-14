-- ui.lua
-- @date 2021-09-06
-- @author Eldin Zenderink
-- @brief All the ui helper functions reside here

local _UI_Toggle_Buttons = {}

-- @note original from smokegun mod from teardown!
function Ui_StringProperty(x, y, name, notes, list, module, key)
    local update = false
    local current = Storage_GetString(module, key)
    if current == "" then
        current = list[1]
    end
    UiPush()
		UiTranslate(x, y)
        UiFont("bold.ttf", 11)
        UiText(notes)
        UiTranslate(0, 22)
        UiFont("regular.ttf", 22)
        UiText(name)
        UiTranslate(400, 0)
        UiFont("bold.ttf", 22)
        if UiTextButton(current) then
            local new = nil
            for i=1, #list-1 do
                if list[i] == current then
                    new = list[i+1]
                end
            end
            if new then
                Storage_SetString(module, key, new)
				if new ~= current then
                	update = true
				end
            else
                Storage_SetString(module, key, list[1])
				if list[1] ~= current then
                	update = true
				end
            end
        end
    UiPop()
    return update
end


function Ui_KeySelector(x, y, name, notes, module, key)

    local update = false
    local current_key = Storage_GetString(module, key)
	local awaiting_key_press = Storage_GetBool("ui", "keyselector." .. key .. ".awaiting_key_press")
	local last_pressed_stored = Storage_GetString("ui", "keyselector." .. key .. ".last_pressed")
	local last_pressed = InputLastPressedKey()

	if awaiting_key_press and last_pressed ~= last_pressed_stored then
		Storage_SetBool("ui", "keyselector." .. key .. ".awaiting_key_press", false)
		Storage_SetString(module, key, last_pressed)
		update = true
	end

    UiPush()
		UiTranslate(x, y)
        UiFont("bold.ttf", 11)
        UiText(notes)
        UiTranslate(0, 22)
        UiFont("regular.ttf", 22)
        UiText(name)
        UiTranslate(400, 0)
        UiFont("bold.ttf", 22)
        if UiTextButton(current_key) then
			if not awaiting_key_press then
				Storage_SetBool("ui", "keyselector." .. key .. ".awaiting_key_press", true)
			end
			Storage_SetString("ui", "keyselector." .. key .. ".last_pressed", last_pressed)
        end
    UiPop()
    return update
end

function Ui_FloatProperty(x, y, name, notes, min_max_steps, module, key)
	local steps = min_max_steps[3]
	local current = Storage_GetFloat(module, key)
	if current == nil then
		current = 0
	end
	local value = (current - min_max_steps[1]) / (min_max_steps[2] - min_max_steps[1]);
	local width = 300;
	UiPush()
	UiTranslate(x, y)
	UiFont("bold.ttf", 11)
	UiText(notes)
	UiTranslate(0, 22)
	UiFont("regular.ttf", 22)
	UiText(name)
	UiTranslate(400, 0)
	UiTranslate(6, -6)
	UiRect(width, 4)
	UiTranslate(-6, -6)
	value = UiSlider("ui/common/dot.png", "x", value*width, 0, width)/width;
	value = math.floor((value*(min_max_steps[2] - min_max_steps[1])+min_max_steps[1])/steps+0.5)*steps;
	UiTranslate(width + 24, 14)
	UiText(tostring(value))
	UiPop()
	if current ~= value then
		Storage_SetFloat(module, key, value);
		return true
	end
	return false
end

function Ui_IntProperty(x, y, name, notes, min_max, module, key)
	local steps = 1
	local current = Storage_GetInt(module, key)
	if current == nil then
		current = 0
	end
	local value = (current - min_max[1]) / (min_max[2] - min_max[1]);
	local width = 300;
	UiPush()
	UiTranslate(x, y)
	UiFont("bold.ttf", 11)
	UiText(notes)
	UiTranslate(0, 22)
	UiFont("regular.ttf", 22)
	UiText(name)
	UiTranslate(400, 0)
	UiTranslate(6, -6)
	UiRect(width, 4)
	UiTranslate(- 6, -6)
	value = UiSlider("ui/common/dot.png", "x", value*width, 0, width)/width;
	value = math.floor((value*(min_max[2] - min_max[1])+min_max[1])/steps+0.5)*steps;
	UiTranslate(width + 24, 14)
	UiFont("regular.ttf", 16)
	UiText(tostring(value))
	UiPop()
	if current ~= value then
		Storage_SetInt(module, key, value);
		return true
	end
	return false
end

function UI_ToggleButton(x, y, text, group, id)
	-- Create a button
	if _UI_Toggle_Buttons[group] == nil then
		_UI_Toggle_Buttons[group] = {}
		_UI_Toggle_Buttons[group][id] = false
	end

	local clicked = _UI_Toggle_Buttons[group][id]
	if clicked then
		UiFont("bold.ttf", 22)
	else
		UiFont("regular.ttf", 22)
	end
	UiPush()
		UiTranslate(x, y)
		if UiTextButton(text) then
			clicked = not clicked
		end
	UiPop()
	for k, v in pairs(_UI_Toggle_Buttons[group]) do
		if k ~= id and clicked then
			_UI_Toggle_Buttons[group][k] = false
		end
	end
	_UI_Toggle_Buttons[group][id] = clicked
	return clicked
end


function UI_Button(x, y, text)
	-- Create a button
	UiPush()
		UiTranslate(x, y)
		UiFont("bold.ttf", 22)
		if UiTextButton(text) then
			UiPop()
			return true
		end
	UiPop()
	return false
end