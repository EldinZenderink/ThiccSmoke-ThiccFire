-- wind.lua
-- @date 2022-02-26
-- @author Eldin Zenderink
-- @brief Helper module for generating winds

#include "compatibility.lua"
#include "debug.lua"

Wind_WindEnabled = "ON"
Wind_WindStrength = 6
Wind_WindDirection = 360
Wind_WindDirectionRandom = 20
Wind_WindStrengthRandom = 1
Wind_WindTargetStrength = 1
Wind_WindTargetDir = 0
Wind_WindCurrentStrength = 0
Wind_WindCurrentStrengthRate = 1
Wind_WindCurrentDir= 0
Wind_WindCurrentDirRate = 1

Wind_Enabled = false

function Wind_Init()
    Settings_RegisterUpdateSettingsCallback(Wind_UpdateSettingsFromSettings)
end

function Wind_UpdateSettingsFromSettings()

	Wind_WindEnabled = Settings_GetValue("Wind", "wind")
	Wind_WindDirection = Settings_GetValue("Wind", "winddirection")
	Wind_WindStrength = Settings_GetValue("Wind", "windstrength")
	Wind_WindStrenghtRandom = Settings_GetValue("Wind", "windstrengthrandom")
	Wind_WindCurrentStrengthRate = Settings_GetValue("Wind", "windstrengthrandomrate")
	Wind_WindDirectionRandom = Settings_GetValue("Wind", "winddirectionrandom")
	Wind_WindCurrentDirRate = Settings_GetValue("Wind", "winddirectionrandomrate")
	if Wind_WindEnabled == nil or Wind_WindEnabled == "" then
		Wind_WindEnabled = "ON"
		Settings_SetValue("Wind", "wind", "ON")
	end

	if Wind_WindDirection == nil or Wind_WindDirection == 0 then
		Wind_WindDirection = 0
		Settings_SetValue("Wind", "winddirection", Wind_WindDirection)
	end

	if Wind_WindDirectionRandom == nil or Wind_WindDirectionRandom == 0 then
		Wind_WindDirectionRandom = 0
		Settings_SetValue("Wind", "winddirectionrandom", Wind_WindDirectionRandom)
	end

	if Wind_WindCurrentDirRate == nil or Wind_WindCurrentDirRate == 0 then
		Wind_WindCurrentDirRate = 1
		Settings_SetValue("Wind", "winddirectionrandomrate", Wind_WindCurrentDirRate)
	end

	if Wind_WindStrength == nil or Wind_WindStrength == 0 then
		Wind_WindStrength = 0
		Settings_SetValue("Wind", "windstrength", Wind_WindStrength)
	end
	if Wind_WindCurrentStrengthRate == nil or Wind_WindCurrentStrengthRate == 0 then
		Wind_WindCurrentStrengthRate = 1
		Settings_SetValue("Wind", "windstrengthrandomrate", Wind_WindCurrentStrengthRate)
	end
	if Wind_WindStrengthRandom == nil or Wind_WindStrengthRandom == 0 then
		Wind_WindStrengthRandom = 0
		Settings_SetValue("Wind", "windstrengthrandom", Wind_WindStrengthRandom)
	end

    Wind_LocalDirection = Wind_WindDirection

    if Compatibility_IsSettingCompatible("wind") == false then
		Wind_Enabled = false
		Wind_WindEnabled = "NO"
	end
	Wind_WindCurrentDir = Wind_WindDirection
	Wind_WindCurrentStrength = Wind_WindStrength
	Wind_WindCurrentStrengthRate = Wind_WindCurrentStrengthRate * 0.01
	Wind_WindCurrentDirRate = Wind_WindCurrentDirRate * 0.01
end


WindChangeDirStrenght = "up"
WindChangeDir = "up"

function Wind_ChangeWind(dt, refresh)

	if Wind_WindCurrentStrength >= Wind_WindTargetStrength and WindChangeDirStrenght == "up" then
		Wind_WindTargetStrength = Wind_WindStrength + Generic_rnd(-Wind_WindStrengthRandom, Wind_WindStrengthRandom)
	elseif Wind_WindCurrentStrength <= Wind_WindTargetStrength and WindChangeDirStrenght == "down" then
		Wind_WindTargetStrength = Wind_WindStrength + Generic_rnd(-Wind_WindStrengthRandom, Wind_WindStrengthRandom)
	end

	if Wind_WindCurrentStrength > Wind_WindTargetStrength then
		WindChangeDirStrenght = "down"
		Wind_WindCurrentStrength = Wind_WindCurrentStrength - Wind_WindCurrentStrengthRate
	elseif Wind_WindCurrentStrength < Wind_WindTargetStrength then
		WindChangeDirStrenght = "up"
		Wind_WindCurrentStrength = Wind_WindCurrentStrength + Wind_WindCurrentStrengthRate
	end


	if Wind_WindCurrentDir >= Wind_WindTargetDir and WindChangeDir == "up" then
		Wind_WindTargetDir = Wind_WindDirection + Generic_rnd(-Wind_WindDirectionRandom, Wind_WindDirectionRandom)
	elseif Wind_WindCurrentDir <= Wind_WindTargetDir and WindChangeDir == "down" then
		Wind_WindTargetDir = Wind_WindDirection + Generic_rnd(-Wind_WindDirectionRandom, Wind_WindDirectionRandom)
	end

	if Wind_WindCurrentDir > Wind_WindTargetDir then
		WindChangeDir = "down"
		Wind_WindCurrentDir = Wind_WindCurrentDir - Wind_WindCurrentDirRate
	elseif Wind_WindCurrentDir < Wind_WindTargetDir then
		WindChangeDir = "up"
		Wind_WindCurrentDir = Wind_WindCurrentDir + Wind_WindCurrentDirRate
	end


    if refresh then
		if Wind_WindEnabled == "YES" then
			local radian = math.rad(Wind_WindCurrentDir)
			local vecdir = {math.cos(radian), 0,  math.sin(radian)}
			local dir = VecScale(vecdir, Wind_WindCurrentStrength)
			SetEnvironmentProperty("wind" , dir[1], dir[2], dir[3])
			Wind_Enabled = true
		else
			if Wind_Enabled then
				SetEnvironmentProperty("wind",0,0,0)
				Wind_Enabled = false
			end
		end
    end


    if GeneralOptions_GetShowUiInGame() == "YES" then
		DebugWatch("Wind, strength", Wind_WindCurrentStrength)
		DebugWatch("Wind, targetstrength", Wind_WindTargetStrength)
		DebugWatch("Wind, strength change rate", Wind_WindCurrentStrengthRate)
		DebugWatch("Wind, direction", Wind_WindCurrentDir)
		DebugWatch("Wind, targetdirection", Wind_WindTargetDir)
		DebugWatch("Wind, direction change rate", Wind_WindCurrentDirRate)
    end
end

