-- version.lua
-- @date 2021-09-06
-- @author Eldin Zenderink
-- @brief Store the current version and in case of changes try to move over older settings to the newer


#include "storage.lua"

Version = {}

Version.Current = "v5.4"
Version.CurrentActual = "v9"
Version.Previous = "v4"
Version.ModName = ""
Version.PreviousModName = "ThiccFire"

function Version.GetName()
    return Version.ModName
end

function Version.GetCurrentActual()
    return Version.CurrentActual
end

function Version.GetCurrent()
    return Version.Current
end

function Version.GetPrevious()
    return Version.Previous
end

function Version.GetStored()
    local stored = GetString("savegame.mod." .. Version.GetName().. ".version")
    return stored
end

function Version.GetStoredPrevious()
    local stored = GetString("savegame.mod." .. Version.PreviousModName .. ".version")
    return stored
end

function Version.Init(modname)
	Version.ModName = modname
	DebugPrint("Loaded: " .. Version.ModName)
	local storedVersion = Version.GetStored()
	Storage.SetString("level.mod." .. Version.GetName().. ".version", Version.GetCurrent())

	if storedVersion == "" or storedVersion == nil then
		if Version.GetStored() == Version.Previous or Version.GetStoredPrevious() == Version.Previous then
			Storage.SetString("savegame.mod." .. Version.GetName().. ".version", Version.GetCurrent())
			return "transfer_stored"
		end
		Storage.SetString("savegame.mod." .. Version.GetName().. ".version", Version.GetCurrent())
		storedVersion = Version.GetCurrent()
		return "store_default"
	end

	if storedVersion == Version.Current then
		return "current"
	elseif storedVersion ~= "" then
		if Version.GetStored() == Version.Previous or Version.GetStoredPrevious() == Version.Previous then
			Storage.SetString("savegame.mod." .. Version.GetName().. ".version", Version.GetCurrent())
			return "transfer_stored"
		end
		Storage.SetString("savegame.mod." .. Version.GetName().. ".version", Version.GetCurrent())
		return "store_default"
	else
		Storage.SetString("savegame.mod." .. Version.GetName().. ".version", Version.GetCurrent())
		return "store_default"
	end

end

