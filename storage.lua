-- storage.lua
-- @date 2021-09-06
-- @author Eldin Zenderink
-- @brief Group all storage related stuff per module here

_StorageKey = ""

function Storage_Init(modname, version)
    _StorageKey = "savegame.mod." .. modname .. "." .. version
end

function Storage_GetString(module, key)
    local val = GetString(_StorageKey .. "." .. module .. "." .. key)
    --DebugPrinter("Get value " .. tostring(val) .. " from " .. _StorageKey .. "." .. module .. "." .. key)
    return val
end

function Storage_SetString(module, key, val)
    DebugPrinter("Store value " .. tostring(val) .. " to " .. _StorageKey .. "." .. module .. "." .. key)
    SetString(_StorageKey .. "." .. module .. "." .. key, val)
end

function Storage_GetFloat(module, key)
    local val = GetFloat(_StorageKey .. "." .. module .. "." .. key)
    -- DebugPrinter("Get value " .. tostring(val) .. " from " .. _StorageKey .. "." .. module .. "." .. key)
    return val
end

function Storage_SetFloat(module, key, val)
    -- DebugPrinter("Store value " .. tostring(val) .. " to " .. _StorageKey .. "." .. module .. "." .. key)
    SetFloat(_StorageKey .. "." .. module .. "." .. key, val)
end

function Storage_GetInt(module, key)
    local val = GetInt(_StorageKey .. "." .. module .. "." .. key)
    -- DebugPrinter("Get value " .. tostring(val) .. " from " .. _StorageKey .. "." .. module .. "." .. key)
    return val
end

function Storage_SetInt(module, key, val)
    -- DebugPrinter("Store value " .. tostring(val) .. " to " .. _StorageKey .. "." .. module .. "." .. key)
    SetInt(_StorageKey .. "." .. module .. "." .. key, val)
end

function Storage_GetBool(module, key)
    local val = GetBool(_StorageKey .. "." .. module .. "." .. key)
    -- DebugPrinter("Get value " .. tostring(val) .. " from " .. _StorageKey .. "." .. module .. "." .. key)
    return val
end

function Storage_SetBool(module, key, val)
    -- DebugPrinter("Store value " .. tostring(val) .. " to " .. _StorageKey .. "." .. module .. "." .. key)
    SetBool(_StorageKey .. "." .. module .. "." .. key, val)
end