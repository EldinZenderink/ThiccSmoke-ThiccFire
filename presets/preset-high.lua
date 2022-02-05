-- preset-high.lua
-- @date 2021-10-30
-- @author Eldin Zenderink
-- @brief This preset will be a step up from medium being basically the same except nwo lights are spawned generating a more life like fire and some basic spreading and a bit of damage.

Preset_Settings_High = {
    Settings  = {
        ActivePreset="high",
        description="This preset will be a step up from medium being basically the same except now\n lights are spawned generating a more life like fire \nand some basic spreading and a bit of damage.",
        version="v5.4"
    },
    GeneralOptions = {
        toggle_menu_key="U",
        ui_in_game="NO",
        debug="NO",
        enabled="YES"
    },
    FireDetector = {
        map_size = "LARGE",
        max_fire_spread_distance=12,
        fire_reaction_time=20,
        fire_update_time=0.25,
        min_fire_distance=1,
        max_group_fire_distance=4,
        max_fire=200,
        fire_intensity="ON",
        fire_intensity_multiplier=2,
        fire_intensity_minimum=10,
        visualize_fire_detection="OFF",
        fire_explosion = "NO",
        fire_damage = "YES",
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
        spawn_light = "ON",
        red_light_divider = 1,
        green_light_divider = 1.75,
        blue_light_divider = 4,
        light_intensity = 0.5,
        light_flickering_intensity = 3,
        fire_to_smoke_ratio = "1:2",
        dynamic_fps = "ON",
        dynamic_fps_target = 35,
        particle_refresh_max = 48,
        particle_refresh_min = 24,
        aggressivenes = 1,
    },
    Particle = {
        intensity_mp = "Use Material Property",
        drag_mp = "Use Material Property",
        gravity_mp = "Use Material Property",
        lifetime_mp = "1x",
        intensity_scale = 1.5,
        randomness = 0.85,
        duplicator = 1,
        smoke_fadein = 0,
        smoke_fadeout = 1,
        fire_fadein = 0,
        fire_fadeout = 4,
        fire_emissive = 4,
        embers = "LOW",
        windspawnrate = 10,
        windvisible = "OFF",
        windstrength = 35,
        winddirection = 360,
        windheightstart = 5,
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
            color={r=0.93,g=0.25,b=0.10,a=1},
            lifetime=1,
            size=0.9,
            gravity=2,
            speed=0.1,
            drag=0.2,
            variation=0.1,
        },
        foliage={
            color={r=0.86,g=0.23,b=0.09,a=1},
            lifetime=1,
            size=0.9,
            gravity=2,
            speed=0.1,
            drag=0.2,
            variation=0.1,
        },
        plaster={
            color={r=1.0, g=0.3, b=0.3, a=0.5},
            lifetime=1,
            size=0.9,
            gravity=2,
            speed=0.1,
            drag=0.2,
            variation=0.1,
        },
        plastic={
            color={r=0.86,g=0.23,b=0.09,a=1},
            lifetime=1,
            size=0.9,
            gravity=2,
            speed=0.1,
            drag=0.2,
            variation=0.1,
        },
        masonery={
            color={r=0.38,g=0.11,b=0.03,a=1},
            lifetime=1,
            size=0.9,
            gravity=2,
            speed=0.1,
            drag=0.2,
            variation=0.1,
        }
    },
    SmokeMaterial = {
        wood={
            color={r=0.16,g=0.16,b=0.16,a=1},
            lifetime=8,
            size=1,
            gravity=4,
            speed=0.5,
            drag=0.3,
            variation=0.1,
        },
        foliage={
            color={r=0.2,g=0.2,b=0.15,a=1},
            lifetime=8,
            size=1,
            gravity=3,
            speed=0.5,
            drag=0.2,
            variation=0.1,
        },
        plaster={
            color={r=0.27,g=0.27,b=0.27,a=1},
            lifetime=8,
            size=1,
            gravity=4,
            speed=0.6,
            drag=0.1,
            variation=0.1,
        },
        plastic={
            color={r=0.25,g=0.25,b=0.27,a=1},
            lifetime=8,
            size=1,
            gravity=3,
            speed=0.15,
            drag=1,
            variation=0.1,
        },
        masonery={
            color={r=0.21,g=0.2,b=0.2,a=1},
            lifetime=8,
            size=1,
            gravity=4,
            speed=1,
            drag=0.2,
            variation=0.1,
        },
    }
}