-- ui.lua
-- @date 2021-09-06
-- @author Eldin Zenderink
-- @brief All the ui helper functions reside here

_UI_Toggle_Buttons = {}

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
		if min_max_steps[4] ~= nil then
			for i=1, #min_max_steps[4] do
				local relatedvalue = Storage_GetFloat(module,  min_max_steps[4][i]["related"])
				if min_max_steps[4][i]["type"] == ">" then
					if value < relatedvalue then
						Storage_SetFloat(module,  min_max_steps[4][i]["related"], value - min_max_steps[3])
					end
				else
					if value > relatedvalue then
						Storage_SetFloat(module,  min_max_steps[4][i]["related"], value + min_max_steps[3])
					end
				end
			end
		end
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
	UiPush()
	UiTranslate(x, y)
	if clicked then
		UiFont("bold.ttf", 22)
	else
		UiFont("regular.ttf", 22)
	end
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


function UI_TextInput(x, y,  name, notes, options, module, key)
	-- Create a button

    local current_string = Storage_GetString(module, key .. ".buffer")
	local awaiting_key_press = Storage_GetBool("ui", "keyselector." .. key .. ".awaiting_key_press")
	local last_pressed = InputLastPressedKey()

	if InputPressed("esc") then
		awaiting_key_press = false
		Storage_SetBool("ui", "keyselector." .. key .. ".awaiting_key_press", awaiting_key_press)
		Storage_SetString(module, key, current_string)
		return true
	end

	if (InputPressed("lmb") or InputPressed("return") or InputPressed(options["key_press"])) and awaiting_key_press then
		awaiting_key_press = false
		Storage_SetBool("ui", "keyselector." .. key .. ".awaiting_key_press", awaiting_key_press)
		Storage_SetString(module, key, current_string)
		Storage_SetString(module, key .. ".buffer", "Please enter a text.")
		options["action"]()
		return true
	end

	Storage_SetBool("global", "keyselector.text_input_pending", awaiting_key_press)

	if last_pressed == "space" then
		last_pressed = " "
	end

	if  last_pressed == "backspace" or last_pressed == "delete" then
		current_string = current_string:sub(1, -2)
		last_pressed = ""
	end

	local ignore_inputs = {
		" ",
		",",
		"tab",
		"rmb",
		"mmb",
		"uparrow",
		"downarrow",
		"leftarrow",
		"rightarrow",
		"f1",
		"backspace",
		"alt",
		"delete",
		"home",
		"end",
		"pgup",
		"pgdown",
		"insert",
		"shift",
		"ctrl"
	}

	if Generic_TableContains(ignore_inputs, last_pressed) then
		last_pressed = ""
	end

	if awaiting_key_press then
		last_pressed = last_pressed:lower()
		Storage_SetString(module, key .. ".buffer", current_string .. last_pressed)
		current_string = current_string .. last_pressed
	end

    UiPush()
		UiTranslate(x, y)
        UiFont("bold.ttf", 11)
        UiText("Click to edit, edit while bold, press return to store. (" .. notes .. ")")
        UiTranslate(0, 22)
        UiFont("regular.ttf", 22)
        UiText(name)
        UiTranslate(400, 0)
		if not awaiting_key_press then
			UiFont("regular.ttf", 22)
		else
			UiFont("bold.ttf", 22)
		end
		if current_string == "" then
			current_string = "Please enter a text."
		end
        if UiTextButton(current_string) then
			if not awaiting_key_press then
				Storage_SetBool("global", "keyselector.text_input_pending", true)
				Storage_SetBool("ui", "keyselector." .. key .. ".awaiting_key_press", true)
			end
			Storage_SetString(module, key .. ".buffer", "")
        end
    UiPop()
    return false
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

function Ui_MultiSelector(x, y, name, notes, list, module, key)
    local update = false

	if list["module"] ~= nil and list["key"] ~= nil then
		local csv = Storage_GetString(list["module"], list["key"])
		list = Generic_SplitString(csv, ',')
	end
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
		for i = 1, #list do
			local value = list[i]
			UiTranslate(0, 24)
			if value ~= current then
				UiFont("regular.ttf", 22)
			else
				UiFont("bold.ttf", 22)
			end
			if UiTextButton(value) then
				Storage_SetString(module, key, value)
				update = true
			end
			y = y + 24
		end
    UiPop()
    return {update, y}
end

function UI_TextFieldInput(x, y, name, notes, options, module, key)
	-- Create a button

    local current_string = Storage_GetString(module, key .. ".buffer")
	local awaiting_key_press = Storage_GetBool("ui", "keyselector." .. key .. ".awaiting_key_press")
	local last_pressed = InputLastPressedKey()

	if InputPressed("esc") then
		awaiting_key_press = false
		Storage_SetBool("ui", "keyselector." .. key .. ".awaiting_key_press", awaiting_key_press)
		Storage_SetString(module, key, current_string)
		local offset  = Storage_GetInt("ui", "keyselector." .. key .. ".offset")
		Storage_SetInt("ui", "keyselector." .. key .. ".offset", 0)
		Storage_SetString(module, key .. ".buffer", "")
		return {true, offset}
	end

	if (InputPressed("lmb") or InputPressed(options["key_press"])) and awaiting_key_press then
		awaiting_key_press = false
		Storage_SetBool("ui", "keyselector." .. key .. ".awaiting_key_press", awaiting_key_press)
		Storage_SetString(module, key, current_string)
		options["action"]()
		local offset  = Storage_GetInt("ui", "keyselector." .. key .. ".offset")
		Storage_SetInt("ui", "keyselector." .. key .. ".offset", 0)
		Storage_SetString(module, key .. ".buffer", "")
		return {true, offset}
	end

	if InputReleased("return") then
		if Storage_GetBool("global", "return_pressed") then
			Storage_SetBool("global", "return_pressed", false)
			awaiting_key_press = false
			Storage_SetBool("ui", "keyselector." .. key .. ".awaiting_key_press", awaiting_key_press)
			Storage_SetString(module, key, current_string)
			options["action"]()
			local offset  = Storage_GetInt("ui", "keyselector." .. key .. ".offset")
			Storage_SetInt("ui", "keyselector." .. key .. ".offset", 0)
			Storage_SetString(module, key .. ".buffer", "")
			return {true, offset}
		end
		Storage_SetBool("global", "return_pressed", true)
	end


	if InputPressed("return") then
		last_pressed = "\n"
	end
	if InputPressed("return") == false and last_pressed ~= "" then
		Storage_SetBool("global", "return_pressed", false)
	end

	Storage_SetBool("global", "keyselector.text_input_field_pending", awaiting_key_press)

	if last_pressed == "space" then
		last_pressed = " "
	end

	if  last_pressed == "backspace" or last_pressed == "delete" then
		current_string = current_string:sub(1, -2)
	end

	local ignore_inputs = {
		",",
		"tab",
		"rmb",
		"mmb",
		"uparrow",
		"downarrow",
		"leftarrow",
		"rightarrow",
		"f1",
		"backspace",
		"alt",
		"delete",
		"home",
		"end",
		"pgup",
		"pgdown",
		"insert",
		"shift",
		"ctrl"
	}

	if Generic_TableContains(ignore_inputs, last_pressed) then
		last_pressed = ""
	end

	if awaiting_key_press then
		last_pressed = last_pressed:lower()
		Storage_SetString(module, key .. ".buffer", current_string .. last_pressed)
		current_string = current_string .. last_pressed
	end

    UiPush()
		UiTranslate(x, y)
        UiFont("bold.ttf", 11)
        UiText("Click textfield to edit, edit when bold, save by pressing return twice. (" .. notes .. ")")
        UiTranslate(0, 22)
        UiFont("regular.ttf", 22)
        UiText(name)
        UiTranslate(400, 0)
		if not awaiting_key_press then
			UiFont("regular.ttf", 16)
		else
			UiFont("bold.ttf", 16)
		end
		if current_string == "" then
			if Storage_GetString(module, key) == "" then
				current_string = "Please enter a text."
			else
				current_string = Storage_GetString(module, key)
			end
		end

		local lines = Generic_SplitString(current_string, "\n")
		Storage_SetInt("ui", "keyselector." .. key .. ".offset", 0)
		for i=1, #lines do
			if UiTextButton(lines[i]) then
				if not awaiting_key_press then
					Storage_SetBool("global", "keyselector.text_input_field_pending", true)
					Storage_SetBool("ui", "keyselector." .. key .. ".awaiting_key_press", true)
				end
				Storage_SetString(module, key .. ".buffer", "")
			end
			UiTranslate(0, 20)
			Storage_SetInt("ui", "keyselector." .. key .. ".offset", Storage_GetInt("ui", "keyselector." .. key .. ".offset") + 20)
		end
        UiTranslate(0, 33)
    UiPop()
    return {false, Storage_GetInt("ui", "keyselector." .. key .. ".offset")}
end