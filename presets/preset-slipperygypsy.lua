-- preset-default.lua
-- @date 2021-10-30
-- @author Eldin Zenderink
-- @brief Would you like a powerpoint presentation?
Preset_Settings_SlipperyGypsy = {
    Settings        = {
        ActivePreset = "SlipperyGypsy",
        description = "Preset made for SlipperyGypsy, ultra preset on steroids",
        version = "v5.4",
        type = "default"
    },
    GeneralOptions  = {
        toggle_menu_key = "U",
        ui_in_game = "NO",
        debug = "NO",
        enabled = "YES"
    },
    Wind            = {
        wind = "YES",
        winddirection = 360,
        winddirectionrandom = 10,
        winddirectionrandomrate = 10,
        windstrength = 1,
        windstrengthrandom = 0,
        windstrengthrandomrate = 1
    },
    FireDetector    = {
        map_size = "LARGE",
        max_fire_spread_distance = 12,
        fire_reaction_time = 5,
        fire_update_time = 0.25,
        min_fire_distance = 0.1,
        max_group_fire_distance = 4,
        max_fire = 200,
        fire_intensity = "ON",
        fire_intensity_multiplier = 3,
        fire_intensity_minimum = 10,
        visualize_fire_detection = "OFF",
        fire_explosion = "NO",
        fire_damage = "YES",
        spawn_fire = "YES",
        detect_inside = "YES",
        soot_sim = "YES",
        soot_max_size = 2.5,
        soot_min_size = 0.1,
        soot_dithering_max = 1,
        soot_dithering_min = 0.5,
        fire_damage_soft = 0.1,
        fire_damage_medium = 0.05,
        fire_damage_hard = 0.01,
        teardown_max_fires = 1000,
        teardown_fire_spread = 3,
        material_allowed = {
            wood = true,
            foliage = true,
            plaster = true,
            plastic = true,
            masonery = true,
        },
        despawn_td_fire = "YES"
    },
    ParticleSpawner = {
        fire = "YES",
        smoke = "YES",
        ash = "YES",
        fire_to_smoke_ratio = "1:1",
        ash_to_smoke_ratio = "1:4",
        dynamic_fps = "OFF",
        dynamic_fps_target = 35,
        particle_refresh_max = 48,
        particle_refresh_min = 24,
        aggressivenes = 1,
    },
    Light           = {
        spawn_light = "ON",
        legacy = "NO",
        red_light_offset = 0,
        green_light_offset = -0.1,
        blue_light_offset = -0.1,
        light_intensity = 0.2,
        light_flickering_intensity = 3,
    },
    Particle        = {
        intensity_mp = "Use Material Property",
        drag_mp = "Use Material Property",
        gravity_mp = "Use Material Property",
        visualize_spawn_locations = "NO",
        min_particle_dist = 0.1,
        lifetime_mp = "1x",
        intensity_scale = 1,
        randomness = 0.2,
        location_randomness = 0.5,
        duplicator = 1,
        smoke_fadein = 15,
        smoke_fadeout = 5,
        fire_fadein = 0,
        fire_fadeout = 15,
        fire_emissive = 5,
        embers = "HIGH",
        ash_gravity_min = -16,
        ash_gravity_max = -40,
        ash_rot_max = 2,
        ash_rot_min = 1,
        ash_sticky_max = 0.9,
        ash_sticky_min = 0.7,
        ash_drag_max = 0.2,
        ash_drag_min = 0.1,
        ash_size_max = 0.04,
        ash_size_min = 0.01,
        ash_life = 8
    },
    FireMaterial    = {
        wood = {
            color = { r = 0.93, g = 0.25, b = 0.10, a = 1 },
            lifetime = 1.25,
            size = 0.9,
            gravity = 2,
            rotation = 0.5,
            speed = 1,
            drag = 0.2,
            variation = 0.1,
        },
        foliage = {
            color = { r = 0.86, g = 0.23, b = 0.09, a = 1 },
            lifetime = 1.25,
            size = 0.9,
            gravity = 2,
            rotation = 0.5,
            speed = 1,
            drag = 0.2,
            variation = 0.1,
        },
        plaster = {
            color = { r = 0.7, g = 0.13, b = 0.13, a = 1 },
            lifetime = 1.25,
            size = 0.9,
            gravity = 2,
            rotation = 0.5,
            speed = 1,
            drag = 0.2,
            variation = 0.1,
        },
        plastic = {
            color = { r = 0.86, g = 0.23, b = 0.09, a = 1 },
            lifetime = 1.25,
            size = 0.9,
            gravity = 2,
            rotation = 0.5,
            speed = 1,
            drag = 0.2,
            variation = 0.1,
        },
        masonery = {
            color = { r = 0.38, g = 0.11, b = 0.03, a = 1 },
            lifetime = 1.25,
            size = 0.9,
            gravity = 2,
            rotation = 0.5,
            speed = 1,
            drag = 0.2,
            variation = 0.1,
        }
    },
    SmokeMaterial   = {
        wood = {
            color = { r = 0.16, g = 0.16, b = 0.16, a = 1 },
            lifetime = 16,
            size = 1,
            gravity = 8,
            rotation = 0.5,
            speed = 0.5,
            drag = 0.3,
            variation = 0.1,
        },
        foliage = {
            color = { r = 0.2, g = 0.2, b = 0.15, a = 1 },
            lifetime = 16,
            size = 1,
            gravity = 8,
            rotation = 0.5,
            speed = 0.5,
            drag = 0.2,
            variation = 0.1,
        },
        plaster = {
            color = { r = 0.27, g = 0.27, b = 0.27, a = 1 },
            lifetime = 16,
            size = 1,
            gravity = 8,
            rotation = 0.5,
            speed = 0.6,
            drag = 0.1,
            variation = 0.2,
        },
        plastic = {
            color = { r = 0.25, g = 0.25, b = 0.27, a = 1 },
            lifetime = 16,
            size = 1,
            gravity = 8,
            rotation = 0.5,
            speed = 0.15,
            drag = 1,
            variation = 0.1,
        },
        masonery = {
            color = { r = 0.21, g = 0.2, b = 0.2, a = 1 },
            lifetime = 16,
            size = 1,
            gravity = 8,
            rotation = 0.5,
            speed = 1,
            drag = 0.2,
            variation = 0.3,
        },
    }
}