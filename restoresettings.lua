local storage_key = ""


local Restore_Mapping_V4={
    Settings  = {
        ActivePreset=false
    },
    GeneralOptions = {
        toggle_menu_key={"general.toggle_menu_key", "string"},
        ui_in_game={"general.ui_in_game", "string"},
        debug={"general.debug", "string"},
        enabled={"general.enabled", "string"},
    },
    FireDetector = {
        max_fire_spread_distance={"firedetector.max_fire_spread_distance", "int", {1, 20}},
        fire_reaction_time={"firedetector.fire_reaction_time", "int", {1, 100}},
        fire_update_time=false,
        min_fire_distance={"firedetector.min_fire_distance", "float", {0.1, 5}},
        max_group_fire_distance={"firedetector.max_group_fire_distance", "float", {0.5, 5}},
        max_fire={"firedetector.max_fire", "int", {1,1000}},
        fire_intensity={"firedetector.fire_intensity", "string"},
        fire_intensity_multiplier={"firedetector.fire_intensity_multiplier", "int", {1,100}},
        fire_intensity_minimum={"firedetector.fire_intensity_minimum", "int", {1,100}},
        visualize_fire_detection={"firedetector.visualize_fire_detection", "string"},
        fire_explosion={"firedetector.fire_explosion", "string"},
        fire_damage ={"firedetector.fire_damage", "string"},
        spawn_fire = {"firedetector.spawn_fire", "string"},
        fire_damage_soft = {"firedetector.fire_damage_soft", "float", {0.5, 50}},
        fire_damage_medium = {"firedetector.fire_damage_medium", "float", {0.3, 30}},
        fire_damage_hard = {"firedetector.fire_damage_hard", "float", {0.1, 10}},
        teardown_max_fires = {"firedetector.teardown_max_fires", "int", {1,10000}},
        teardown_fire_spread = {"firedetector.teardown_fire_spread", "int", {1,10}},
        material_allowed = false
    },
    ParticleSpawner={
        fire = {"particlespawner.fire", "string"},
        smoke = {"particlespawner.smoke", "string"},
        spawn_light = {"particlespawner.smoke", "string"},
        fire_to_smoke_ratio = false,
        dynamic_fps= {"particlespawner.dynamic_fps", "string"},
        dynamic_fps_target = {"particlespawner.dynamic_fps_target", "int", {35,60}},
        particle_refresh_max ={"particlespawner.particle_refresh_max", "int", {1,60}},
        particle_refresh_min = {"particlespawner.particle_refresh_min", "int", {1,60}},
        aggressivenes = {"particlespawner.aggressivenes", "float", {0.01,1}},
    },
    Particle = {
        intensity_mp = {"particle.intensity", "string"},
        drag_mp = {"particle.drag", "string"},
        gravity_mp = {"particle.gravity", "string"},
        lifetime_mp ={"particle.lifetime_mp", "string"},
        intensity_scale = {"particle.intensity_scale", "float", {1,10}},
        smoke_fadein = {"particle.smoke_fadein", "int", {0,100}},
        smoke_fadeout = {"particle.smoke_fadeout", "int", {0,100}},
        fire_fadein = {"particle.fire_fadein", "int", {0,100}},
        fire_fadeout = {"particle.fire_fadeout", "int", {0,100}},
        fire_emissive = {"particle.fire_emissive", "int", {1,10}},
        embers = false
    },
    FireMaterial = {
        wood={
            color={r=false,g=false,b=false,a={"fire_material.wood.color.a", "float",{0.0,1}}},
            lifetime={"fire_material.wood.lifetime", "float", {0.5, 30}},
            size={"fire_material.wood.size", "float", {0.1,4}},
            gravity={"fire_material.wood.gravity", "float", {-20,20}},
            speed={"fire_material.wood.speed", "float", {0.1,10}},
            drag={"fire_material.wood.drag", "float", {0.1,1}},
            variation={"fire_material.wood.variation", "float", {0.1,1}},
        },
        foliage={
            color={r=false,g=false,b=false,a={"fire_material.foliage.color.a", "float",{0.0,1}}},
            lifetime={"fire_material.foliage.lifetime", "float", {0.5, 30}},
            size={"fire_material.foliage.size", "float", {0.1,4}},
            gravity={"fire_material.foliage.gravity", "float", {-20,20}},
            speed={"fire_material.foliage.speed", "float", {0.1,10}},
            drag={"fire_material.foliage.drag", "float", {0.1,1}},
            variation={"fire_material.foliage.variation", "float", {0.1,1}},
        },
        plaster={
            color={r=false,g=false,b=false,a={"fire_material.plaster.color.a", "float",{0.0,1}}},
            lifetime={"fire_material.plaster.lifetime", "float", {0.5, 30}},
            size={"fire_material.plaster.size", "float", {0.1,4}},
            gravity={"fire_material.plaster.gravity", "float", {-20,20}},
            speed={"fire_material.plaster.speed", "float", {0.1,10}},
            drag={"fire_material.plaster.drag", "float", {0.1,1}},
            variation={"fire_material.plaster.variation", "float", {0.1,1}},
        },
        plastic={
            color={r=false,g=false,b=false,a={"fire_material.plastic.color.a", "float",{0.0,1}}},
            lifetime={"fire_material.plastic.lifetime", "float", {0.5, 30}},
            size={"fire_material.plastic.size", "float", {0.1,4}},
            gravity={"fire_material.plastic.gravity", "float", {-20,20}},
            speed={"fire_material.plastic.speed", "float", {0.1,10}},
            drag={"fire_material.plastic.drag", "float", {0.1,1}},
            variation={"fire_material.plastic.variation", "float", {0.1,1}},
        },
        masonery={
            color={r=false,g=false,b=false,a={"fire_material.masonery.color.a", "float",{0.0,1}}},
            lifetime={"fire_material.masonery.lifetime", "float", {0.5, 30}},
            size={"fire_material.masonery.size", "float", {0.1,4}},
            gravity={"fire_material.masonery.gravity", "float", {-20,20}},
            speed={"fire_material.masonery.speed", "float", {0.1,10}},
            drag={"fire_material.masonery.drag", "float", {0.1,1}},
            variation={"fire_material.masonery.variation", "float", {0.1,1}},
        }
    },
    SmokeMaterial = {
        wood={
            color={
                r={"smoke_material.wood.color.r", "float", {0.0,1}},
                g={"smoke_material.wood.color.g", "float", {0.0,1}},
                b={"smoke_material.wood.color.b", "float", {0.0,1}},
                a={"smoke_material.wood.color.a", "float", {0.0,1}}
            },
            lifetime={"smoke_material.wood.lifetime", "float", {0.5, 30}},
            size={"smoke_material.wood.size", "float", {0.1,4}},
            gravity={"smoke_material.wood.gravity", "float", {-20,20}},
            speed={"smoke_material.wood.speed", "float", {0.1,10}},
            drag={"smoke_material.wood.drag", "float", {0.1,1}},
            variation={"smoke_material.wood.variation", "float", {0.1,1}},
        },
        foliage={
            color={
                r={"smoke_material.wood.color.r", "float", {0.0,1}},
                g={"smoke_material.wood.color.g", "float", {0.0,1}},
                b={"smoke_material.wood.color.b", "float", {0.0,1}},
                a={"smoke_material.wood.color.a", "float", {0.0,1}}
            },
            lifetime={"smoke_material.wood.lifetime", "float", {0.5, 30}},
            size={"smoke_material.wood.size", "float", {0.1,4}},
            gravity={"smoke_material.wood.gravity", "float", {-20,20}},
            speed={"smoke_material.wood.speed", "float", {0.1,10}},
            drag={"smoke_material.wood.drag", "float", {0.1,1}},
            variation={"smoke_material.wood.variation", "float", {0.1,1}},
        },
        plaster={
            color={
                r={"smoke_material.wood.color.r", "float", {0.0,1}},
                g={"smoke_material.wood.color.g", "float", {0.0,1}},
                b={"smoke_material.wood.color.b", "float", {0.0,1}},
                a={"smoke_material.wood.color.a", "float", {0.0,1}}
            },
            lifetime={"smoke_material.wood.lifetime", "float", {0.5, 30}},
            size={"smoke_material.wood.size", "float", {0.1,4}},
            gravity={"smoke_material.wood.gravity", "float", {-20,20}},
            speed={"smoke_material.wood.speed", "float", {0.1,10}},
            drag={"smoke_material.wood.drag", "float", {0.1,1}},
            variation={"smoke_material.wood.variation", "float", {0.1,1}},
        },
        plastic={
            color={
                r={"smoke_material.wood.color.r", "float", {0.0,1}},
                g={"smoke_material.wood.color.g", "float", {0.0,1}},
                b={"smoke_material.wood.color.b", "float", {0.0,1}},
                a={"smoke_material.wood.color.a", "float", {0.0,1}}
            },
            lifetime={"smoke_material.wood.lifetime", "float", {0.5, 30}},
            size={"smoke_material.wood.size", "float", {0.1,4}},
            gravity={"smoke_material.wood.gravity", "float", {-20,20}},
            speed={"smoke_material.wood.speed", "float", {0.1,10}},
            drag={"smoke_material.wood.drag", "float", {0.1,1}},
            variation={"smoke_material.wood.variation", "float", {0.1,1}},
        },
        masonery={
            color={
                r={"smoke_material.wood.color.r", "float", {0.0,1}},
                g={"smoke_material.wood.color.g", "float", {0.0,1}},
                b={"smoke_material.wood.color.b", "float", {0.0,1}},
                a={"smoke_material.wood.color.a", "float", {0.0,1}}
            },
            lifetime={"smoke_material.wood.lifetime", "float", {0.5, 30}},
            size={"smoke_material.wood.size", "float", {0.1,4}},
            gravity={"smoke_material.wood.gravity", "float", {-20,20}},
            speed={"smoke_material.wood.speed", "float", {0.1,10}},
            drag={"smoke_material.wood.drag", "float", {0.1,1}},
            variation={"smoke_material.wood.variation", "float", {0.1,1}},
        },
    }
}

function RestoreSettings_Init(default, previous_version, previous_name)
    storage_key =  "savegame.mod." .. previous_name .. "." .. previous_version
    if default then
        local new_settings = Generic_deepCopy(Settings_Template)
        RestoreSettings_Restore(Restore_Mapping_V4, new_settings)
        new_settings["Settings"]["ActivePreset"] = "previous-version-settings"
        Settings_CreatePreset(new_settings)
    end
end

function RestoreSettings_Restore(mapping, new_settings)
    for property, value in pairs(new_settings) do
        if type(value) == "table" and mapping[property] ~= false then
            RestoreSettings_Restore(mapping[property], new_settings[property])
        else
            if mapping[property] ~= false then
                if mapping[property][2] == "float" then
                    local value =  GetFloat(storage_key .. "." .. mapping[property][1])
                    if value < mapping[property][3][1] then
                        value = mapping[property][3][1]
                    elseif value > mapping[property][3][2] then
                        value = mapping[property][3][2]
                    end
                    new_settings[property] = value
                elseif mapping[property][2] == "int" then
                    local value =  GetInt(storage_key .. "." .. mapping[property][1])
                    if value < mapping[property][3][1] then
                        value = mapping[property][3][1]
                    elseif value > mapping[property][3][2] then
                        value = mapping[property][3][2]
                    end
                    new_settings[property] = value
                elseif mapping[property][2] == "string" then
                    new_settings[property] = GetString(storage_key .. "." .. mapping[property][1])
                end
                -- DebugPrint("Mapping: " .. tostring(property) .. "(" .. storage_key .. "." .. mapping[property][1] .. ") value: " .. tostring(new_settings[property]))

            end
        end
    end

end