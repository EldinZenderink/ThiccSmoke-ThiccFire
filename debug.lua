-- debug.lua
-- @date 2021-09-06
-- @author Eldin Zenderink
-- @brief Helper module debug printer

_DebugPrevious = ""

function Debug_Init()
end

-- Debug helper functions
function Debug_ClearDebugPrinter()
	for i = 0, 20 do
		DebugPrint("")
	end
end


function DebugPrinter(line)
	local enabled = false
	-- if  GeneralOptions_GetDebug() == "YES" then
	-- 	enabled = true
	-- end
	if enabled == nil then
		enabled = false
	end
	if enabled then
		if line == _DebugPrevious then
			return false
		end
		DebugPrint(line)
		_DebugPrevious = line
	end
end