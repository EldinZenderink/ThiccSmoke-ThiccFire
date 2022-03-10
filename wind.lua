-- wind.lua
-- @date 2022-02-26
-- @author Eldin Zenderink
-- @brief Helper module for generating winds

Wind_WindEnabled = "ON"
Wind_WindStrength = 6
Wind_WindDirection = 360
Wind_WindStrengthRandom = 1

Wind_Enabled = false

function Wind_Init()
    Settings_RegisterUpdateSettingsCallback(Wind_UpdateSettingsFromSettings)
end

function Wind_UpdateSettingsFromSettings()

	Wind_WindEnabled = Settings_GetValue("Wind", "wind")
	Wind_WindDirection = Settings_GetValue("Wind", "winddirection")
	Wind_WindStrength = Settings_GetValue("Wind", "windstrength")
	Wind_WindStrenghtRandom = Settings_GetValue("Wind", "windstrengthrandom")
	if Wind_WindEnabled == nil or Wind_WindEnabled == "" then
		Wind_WindEnabled = "ON"
		Settings_SetValue("Wind", "wind", "ON")
	end
	if Wind_WindDirection == nil or Wind_WindDirection == 0 then
		Wind_WindDirection = 0
		Settings_SetValue("Wind", "winddirection", Wind_WindDirection)
	end
	if Wind_WindStrength == nil or Wind_WindStrength == 0 then
		Wind_WindStrength = 0
		Settings_SetValue("Wind", "windstrength", Wind_WindStrength)
	end
	if Wind_WindStrengthRandom == nil or Wind_WindStrengthRandom == 0 then
		Wind_WindStrengthRandom = 0
		Settings_SetValue("Wind", "windstrength", Wind_WindStrengthRandom)
	end
    Wind_LocalDirection = Wind_WindDirection
end


function Wind_ChangeWind(dt, refresh)

    if refresh then
		if Wind_WindEnabled == "YES" then
			local direction = Wind_WindDirection
			local radian = math.rad(direction)
			local vecdir = {math.cos(radian), 0,  math.sin(radian)}
			local strength = Generic_rndInt(Wind_WindStrength, Wind_WindStrength + Wind_WindStrengthRandom)
			local dir = VecScale(vecdir, strength)
			SetEnvironmentProperty("wind" , dir[1], dir[2], dir[3])
			Wind_Enabled = true
		else
			if Wind_Enabled then
				SetEnvironmentProperty("wind",0,0,0)
				Wind_Enabled = false
			end
		end
    end
end

