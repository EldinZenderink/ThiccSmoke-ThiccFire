#include "generic.lua"

known_tools = {
    "extinguisher",
    "mycresta-firefighter"
}

known_tools_index = {
    extinguisher={
        name="extinguisher",
        effective_range=0.25,
        extinguish_rate=0.25
    },
    firefighter={
        name="mycresta-firefighter",
        effective_range=2,
        extinguish_rate=5
    },
}

FireExtinguisherTool_UpdateRate = 0.25
FireExtinguisherTool_Timer = 0
FireExtinguisherTool_Active = false
FireExtinguisherTool_ActiveTool = nil
FireExtinguisherTool_LocationHit = nil

function FireExtinguisherTool_Update(dt)
    FireExtinguisherTool_Active = false
    if FireExtinguisherTool_Timer > FireExtinguisherTool_UpdateRate then
        local selected_tool = GetString("game.player.tool")
        DebugWatch("tool",  selected_tool)
        local selected_tool_info = nil
        for index, value in pairs(known_tools_index) do
            if selected_tool == value["name"] then
                selected_tool_info = value
                break
            end
        end

        if selected_tool_info ~= nil then
            if InputDown("lmb") then
                FireExtinguisherTool_Active = true
                FireExtinguisherTool_ActiveTool = selected_tool_info
                local ct = GetCameraTransform();
                local pos = ct.pos
                local dir = TransformToParentVec(ct, Vec(0, 0, -1))
                --

                DebugCross(newpoint,  1, 0, 0)
                local hit, dist = QueryRaycast(pos, dir, 100)
                Generic_DrawLine(newpoint, pos, 1.0,0.0,0.0, true)

                if hit then
                    local hitPoint = VecAdd(pos, VecScale(dir, dist))
                    FireExtinguisherTool_LocationHit = hitPoint
                end
            end
        end
        FireExtinguisherTool_Timer = 0
    end
    FireExtinguisherTool_Timer = FireExtinguisherTool_Timer + dt
end

--- Callback to be called by fire to check if it needs to be extinguished
---@param fire table with fire info such as location and intensity
function FireExtinguisherTool_CheckFireCallback(hash, fire)
    if FireExtinguisherTool_Active then
        if Generic_VecDistance(fire["original"][3], FireExtinguisherTool_LocationHit) <= (fire["original"][4] * 2 ) + FireExtinguisherTool_ActiveTool["effective_range"] then
            DebugPrint("Extinguishing fire, intensity: " .. tostring(fire["fire_intensity"]) .. " canspawnfire(nil if not): " .. tostring(fire["spawnnew"]))
            DebugCross(fire["original"][3],  1, 1, 0)
            fire["fire_intensity"] = fire["fire_intensity"] - FireExtinguisherTool_ActiveTool["extinguish_rate"]
            fire["spawnnew"] = nil
        end
    end
end

function FireExtinguisherTool_Active()
    return FireExtinguisherTool_Active
end