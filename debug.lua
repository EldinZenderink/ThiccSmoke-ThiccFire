-- debug.lua
-- @date 2021-09-06
-- @author Eldin Zenderink
-- @brief Helper module debug printer

Debug = {}

Debug.DebugPrevious = ""

function Debug.Init()
end

-- Debug helper functions
function Debug.ClearDebug()
	-- for i = 0, 20 do
	-- 	DebugPrint("")
	-- end
end


function Debug.Printer(line)
	local enabled = false
	-- if  GeneralOptions_GetDebug() == "YES" then
	-- 	enabled = true
	-- end
	if enabled == nil then
		enabled = false
	end
	if enabled then
		if line == Debug.DebugPrevious then
			return false
		end
		DebugPrint(line)
		Debug.DebugPrevious = line
	end
	return true
end