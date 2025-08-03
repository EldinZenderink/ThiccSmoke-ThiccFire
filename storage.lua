-- storage.lua
-- @date 2021-09-06
-- @author Eldin Zenderink
-- @brief Group all storage related stuff per module here

_StorageKey = ""

Storage = {}

function Storage.Init(modname, version)
    _StorageKey = "savegame.mod." .. modname .. "." .. version
end

function Storage.GetString(module, key)
    local val = GetString(_StorageKey .. "." .. module .. "." .. key)
    return val
end

function Storage.SetString(module, key, val)
    SetString(_StorageKey .. "." .. module .. "." .. key, val)
end

function Storage.GetFloat(module, key)
    local val = GetFloat(_StorageKey .. "." .. module .. "." .. key)
    return val
end

function Storage.SetFloat(module, key, val)
    SetFloat(_StorageKey .. "." .. module .. "." .. key, val)
end

function Storage.GetInt(module, key)
    local val = GetInt(_StorageKey .. "." .. module .. "." .. key)
    return val
end

function Storage.SetInt(module, key, val)
    SetInt(_StorageKey .. "." .. module .. "." .. key, val)
end

function Storage.GetBool(module, key)
    local val = GetBool(_StorageKey .. "." .. module .. "." .. key)
    return val
end

function Storage.SetBool(module, key, val)
    SetBool(_StorageKey .. "." .. module .. "." .. key, val)
end