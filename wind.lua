-- wind.lua
-- @date 2022-02-26
-- @author Eldin Zenderink
-- @brief Helper module for generating winds

Wind_WindEnabled = "ON"
Wind_WindStrength = 6
Wind_WindDirection = 360
Wind_WindStrenghtRandom = 1

Wind_LocalDirection = 0
Wind_LocaDirAdd = true

function Wind_Init()
    Settings_RegisterUpdateSettingsCallback(Wind_UpdateSettingsFromSettings)
end

function Wind_UpdateSettingsFromSettings()

	Wind_WindEnabled = Settings_GetValue("Wind", "wind")
	Wind_WindDirection = Settings_GetValue("Wind", "winddirection")
	Wind_WindDirectionRandom = Settings_GetValue("Wind", "winddirectionrandom")
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

	if Wind_WindStrenghtRandom == nil or Wind_WindStrenghtRandom == 0 then
		Wind_WindStrenghtRandom = 0
		Settings_SetValue("Wind", "windstrengthrandom", Wind_WindStrenghtRandom)
	end
	if Wind_WindDirectionRandom == nil or Wind_WindDirectionRandom == 0 then
		Wind_WindDirectionRandom = 0
		Settings_SetValue("Wind", "winddirectionrandom", Wind_WindDirectionRandom)
	end
    Wind_LocalDirection = Wind_WindDirection
end


function Wind_ChangeWind(dt, refresh)

    if Wind_LocalDirection < (Wind_WindDirection - Wind_WindDirectionRandom) and Wind_LocaDirAdd == false then
        Wind_LocaDirAdd = true
    end

    if Wind_LocalDirection > (Wind_WindDirection + Wind_WindDirectionRandom) and Wind_LocaDirAdd == true then
        Wind_LocaDirAdd = false
    end

    if Wind_LocaDirAdd then
        Wind_LocalDirection = Wind_LocalDirection + dt
    else
        Wind_LocalDirection = Wind_LocalDirection - dt
    end

    if refresh then
        local direction = Wind_LocalDirection
        local radian = math.rad(direction)
        local vecdir = {math.cos(radian), 0,  math.sin(radian)}
        local strength = Generic_rndInt(Wind_WindStrength - Wind_WindStrenghtRandom, Wind_WindStrength + Wind_WindStrenghtRandom)
        local dir = VecScale(vecdir, strength)
        SetEnvironmentProperty("wind" , dir[1], dir[2], dir[3])
        Wind_WindDirectionOld = Wind_WindDirection
        Wind_WindStrengthOld = Wind_WindStrength
    end
end

