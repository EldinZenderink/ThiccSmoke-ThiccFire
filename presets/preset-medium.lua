-- preset-default.lua
-- @date 2021-10-30
-- @author Eldin Zenderink
-- @brief A preset for medium end systems that should provide even more fire enhanments (e.g more fires detected) with more smoke generation, but no damage and limited spreading.

Preset_Settings_Medium = {
    Settings  = {
        ActivePreset="medium",
        description="A preset for medium end systems that should provide even more fire enhancements \n (e.g more fires detected) with more smoke generation, \nbut no damage and limited spreading."
    },
    GeneralOptions = {
        toggle_menu_key="U",
        ui_in_game="NO",
        debug="NO",
        enabled="YES"
    },
    FireDetector = {
        max_fire_spread_distance=2,
        fire_reaction_time=6,
        fire_update_time=0.5,
        min_fire_distance=2,
        max_group_fire_distance=4,
        max_fire=150,
        fire_intensity="ON",
        fire_intensity_multiplier=1,
        fire_intensity_minimum=10,
        visualize_fire_detection="OFF",
        fire_explosion = "NO",
        fire_damage = "NO",
        spawn_fire = "YES",
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
        }
    },
    ParticleSpawner={
        fire = "YES",
        smoke = "YES",
        wind = "NO",
        spawn_light = "OFF",
        red_light_divider = 1,
        green_light_divider = 1.75,
        blue_light_divider = 4,
        light_flickering_intensity = 4,
        fire_to_smoke_ratio = "1:2",
        dynamic_fps = "ON",
        dynamic_fps_target = 35,
        particle_refresh_max = 48,
        particle_refresh_min = 12,
        aggressivenes = 1,
    },
    Particle = {
        intensity_mp = "Use Material Property",
        drag_mp = "Use Material Property",
        gravity_mp = "Use Material Property",
        lifetime_mp = "1x",
        intensity_scale = 1,
        duplicator = 1,
        smoke_fadein = 1,
        smoke_fadeout = 10,
        fire_fadein = 1,
        fire_fadeout = 10,
        fire_emissive = 4,
        embers = "LOW",
        windspawnrate = 10,
        windvisible = "OFF",
        windstrength = 35,
        winddirection = 360,
        windheight = 4,
        windwidth =  2,
        winddirrandom = 4,
        windstrengthrandom = 10,
        winddistancefrompoint = 10,
        windheightincrement = 10,
        windwidthincrement = 10,
    },
    FireMaterial = {
        wood={
            color={r=1.0, g=0.6, b=0.5, a=1},
            lifetime=1,
            size=0.7,
            gravity=2,
            speed=0.1,
            drag=0.2,
            variation=0.4,
        },
        foliage={
            color={r=1.0, g=0.6, b=0.5, a=1},
            lifetime=1,
            size=0.7,
            gravity=2,
            speed=0.1,
            drag=0.2,
            variation=0.4,
        },
        plaster={
            color={r=1.0, g=0.6, b=0.5, a=1},
            lifetime=1,
            size=0.7,
            gravity=2,
            speed=0.1,
            drag=0.2,
            variation=0.4,
        },
        plastic={
            color={r=1.0, g=0.6, b=0.5, a=1},
            lifetime=1,
            size=0.7,
            gravity=2,
            speed=0.1,
            drag=0.2,
            variation=0.4,
        },
        masonery={
            color={r=1.0, g=0.6, b=0.5, a=1},
            lifetime=1,
            size=0.7,
            gravity=2,
            speed=0.1,
            drag=0.2,
            variation=0.4,
        }
    },
    SmokeMaterial = {
        wood={
            color={r=0.15,g=0.15,b=0.15,a=0.2},
            lifetime=4,
            size=2,
            gravity=4,
            speed=2.5,
            drag=0.4,
            variation=1,
        },
        foliage={
            color={r=0.3,g=0.31,b=0.3,a=0.2},
            lifetime=4,
            size=2,
            gravity=3,
            speed=1.5,
            drag=0.7,
            variation=0.8,
        },
        plaster={
            color={r=0.2,g=0.2,b=0.22,a=0.2},
            lifetime=4,
            size=2,
            gravity=4,
            speed=1,
            drag=0.9,
            variation=0.4,
        },
        plastic={
            color={r=0.1,g=0.1,b=0.12,a=0.2},
            lifetime=4,
            size=2,
            gravity=3,
            speed=0.5,
            drag=1,
            variation=0.1,
        },
        masonery={
            color={r=0.4,g=0.4,b=0.4,a=0.2},
            lifetime=4,
            size=2,
            gravity=4,
            speed=2,
            drag=0.6,
            variation=0.3,
        },
    }
}