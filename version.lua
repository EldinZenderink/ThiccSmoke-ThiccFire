-- version.lua
-- @date 2021-09-06
-- @author Eldin Zenderink
-- @brief Store the current version and in case of changes try to move over older settings to the newer

local Version_Current = "v5.1"
local Version_Previous = "v4"
local Version_ModName = ""
local Version_PreviousModName = "ThiccFire"


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

function Version_GetStoredPrevious()
    local stored = GetString("savegame.mod." .. Version_PreviousModName .. ".version")
    return stored
end

function Version_Init(modname)
	Version_ModName = modname
	local storedVersion = Version_GetStored()
	SetString("level.mod." .. Version_GetName().. ".version", Version_GetCurrent())

	if storedVersion == "" or storedVersion == nil then
		if Version_GetStored() == Version_Previous or Version_GetStoredPrevious() == Version_Previous then
			SetString("savegame.mod." .. Version_GetName().. ".version", Version_GetCurrent())
			return "transfer_stored"
		end
		SetString("savegame.mod." .. Version_GetName().. ".version", Version_GetCurrent())
		storedVersion = Version_GetCurrent()
		return "store_default"
	end

	if storedVersion == Version_Current then
		return "current"
	elseif storedVersion ~= "" then
		if Version_GetStored() == Version_Previous or Version_GetStoredPrevious() == Version_Previous then
			SetString("savegame.mod." .. Version_GetName().. ".version", Version_GetCurrent())
			return "transfer_stored"
		end
		SetString("savegame.mod." .. Version_GetName().. ".version", Version_GetCurrent())
		return "store_default"
	else
		SetString("savegame.mod." .. Version_GetName().. ".version", Version_GetCurrent())
		return "store_default"
	end
end

