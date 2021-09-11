-- version.lua
-- @date 2021-09-06
-- @author Eldin Zenderink
-- @brief Store the current version and in case of changes try to move over older settings to the newer

local Version_Current = "v2"
local Version_Previous = ""
local Version_ModName = ""


function Version_GetName()
    return Version_ModName
end

function Version_GetCurrent()
    return Version_Current
end

function Version_GetPrevious()
    return Version_Previous
end

function Version_GetStored()
    local stored = GetString("savegame.mod." .. Version_GetName().. ".version")
    return stored
end

function Version_Init(modname)
	Version_ModName = modname
	local storedVersion = Version_GetStored()
	DebugPrinter("Stored version: " .. tostring(storedVersion))
	DebugPrinter("Current version: " .. tostring(Version_Current))

	if storedVersion == "" then
		SetString("savegame.mod." .. Version_GetName().. ".version", Version_GetCurrent())
		storedVersion = Version_GetCurrent()
	end

	if storedVersion == Version_Current then
		DebugPrinter("Current version: " .. storedVersion .. ", update: no.")
		return "current"
	elseif storedVersion ~= "" then
		SetString("savegame.mod." .. Version_GetName().. ".version", Version_GetCurrent())
		if storedVersion == Version_Previous then
			DebugPrinter("Current version: " .. Version_Current .. ", Previous Version: " .. storedVersion .. ", update: yes")
			return "transfer_stored"
		end
		return "store_default"
	else
		SetString("savegame.mod." .. Version_GetName().. ".version", Version_GetCurrent())
		DebugPrinter("Current version: " .. Version_Current .. ", Previous Version: " .. storedVersion .. ", update: no, previous to old.")
		return "store_default"
	end
end

