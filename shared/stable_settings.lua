-------------------------
-- LOCATIONS PETS FOR BUY
-- CRITICAL: Assigns directly to Config.StableSettings (no require() pattern)
-------------------------

-- Ensure Config is initialized (should be done in shared/config.lua first)
Config = Config or {}

Config.StableSettings = {
    -- valentine
    {
        companion_coords = vector4(-290.62, 657.11, 113.57, 122.57),
        companion_model = 'a_c_doghusky_01',
        companion_price = 200,
        companion_name = 'Husky',
        stableid = 'valentine',
    },
    {
        companion_coords = vector4(-289.32, 653.85, 113.44, 297.49),
        companion_model = 'a_c_dogcatahoulacur_01',
        companion_price = 50,
        companion_name = 'Mutt',
        stableid = 'valentine'
    },
    {
        companion_coords = vector4(-283.77, 653.09, 113.22, 124.67),
        companion_model = 'a_c_doglab_01',
        companion_price = 100,
        companion_name = 'Labrador Retriever',
        stableid = 'valentine'
    },
    {
        companion_coords = vector4(-286.63, 649.03, 113.24, 295.18),
        companion_model = 'a_c_doglab_01', -- 'a_c_dogrufus_01',
        companion_price = 100,
        companion_name = 'Rufus',
        stableid = 'valentine'
    },
    {
        companion_coords = vector4(-285.48, 654.38, 113.10, 120.20),
        companion_model = 'a_c_dogbluetickcoonhound_01',
        companion_price = 150,
        companion_name = 'Coon Hound',
        stableid = 'valentine'
    },
    -- blackwater
    {
        companion_coords = vector4(-935.24, -1241.28, 51.55, 58.12),
        companion_model = 'a_c_doghound_01',
        companion_price = 200,
        companion_name = 'Hound',
        stableid = 'blackwater'
    },
    {
        companion_coords = vector4(-933.99, -1240.08, 51.49, 48.18),
        companion_model = 'a_c_dogcollie_01',
        companion_price = 500,
        companion_name = 'Collie',
        stableid = 'blackwater'
    },
    {
        companion_coords = vector4(-936.63, -1242.85, 51.62, 15.40),
        companion_model = 'a_c_dogpoodle_01',
        companion_price = 120,
        companion_name = 'Poodle',
        stableid = 'blackwater'
    },
    {
        companion_coords = vector4(-932.13, -1237.06, 51.33, 53.85),
        companion_model = 'a_c_dogamericanfoxhound_01',
        companion_price = 225,
        companion_name = 'Fox hound',
        stableid = 'blackwater'
    },
    {
        companion_coords = vector4(-933.00, -1238.60, 51.41, 59.48),
        companion_model = 'a_c_dogaustraliansheperd_01',
        companion_price = 350,
        companion_name = 'Australian Sheperd',
        stableid = 'blackwater'
    },
    -- tumbleweed
        -- cats
    {
        companion_coords = vector4(-5591.42, -3072.23, 2.45, 319.26),
        companion_model = 'a_c_cat_01',
        companion_price = 500,
        companion_name = 'Cat',
        stableid = 'tumbleweed',
    },
    -- wilds
    {
        companion_coords = vector4(-5583.70, -3048.80, 1.09, 325.51),
        companion_model = 'a_c_doghound_01',
        companion_price = 200,
        companion_name = 'Hound',
        stableid = 'tumbleweed',
    },
    {
        companion_coords = vector4(-5576.90, -3058.34, 2.10, 158.43),
        companion_model = 'a_c_doghusky_01',
        companion_price = 200,
        companion_name = 'Husky',
        stableid = 'tumbleweed',
    },
    {
        companion_coords = vector4(-5580.11, -3053.68, 1.36, 168.49),
        companion_model = 'a_c_dogcatahoulacur_01',
        companion_price = 50,
        companion_name = 'Mutt',
        stableid = 'tumbleweed',
    },
    {
        companion_coords = vector4(-5574.61, -3049.03, 0.68, 326.73),
        companion_model = 'a_c_dogbluetickcoonhound_01',
        companion_price = 150,
        companion_name = 'Coon Hound',
        stableid = 'tumbleweed',
    },
    {
        companion_coords = vector4(-5576.43, -3046.67, 0.65, 286.39),
        companion_model = 'a_c_doglab_01',
        companion_price = 100,
        companion_name = 'Labrador Retriever',
        stableid = 'tumbleweed',
    },
    -- tumbleweed
    -- wilds
    {
        companion_coords = vector4(-2891.4070, -3972.5532, -15.1823, 109.7351),
        companion_model = 'a_c_dogbluetickcoonhound_01', -- 'a_c_bear_01',
        companion_price = 600,
        companion_name = 'Medved',
        stableid = 'wapiti',
    },
    {
        companion_coords = vector4(-2892.9104, -3969.1328, -15.1855, 121.9486),
        companion_model = 'a_c_doglab_01', -- 'a_c_wolf',
        companion_price = 400,
        companion_name = 'Wolf',
        stableid = 'wapiti',
    },
}

-- More Information for others animals companions
--[[ 
-- Animal no use WIP
-- wilds
    -- {
    --     companion_model = 'a_c_panther_01',
    --     companion_price = 500,
    --     companion_name = 'Phanter',
    -- },
    -- {
    --     companion_model = 'a_c_lionmangy_01', -- A_C_Panther_01  A_C_Cougar_01  A_C_Cat_01
    --     companion_price = 500,
    --     companion_name = 'Lion Mangy',
    -- },
    -- {
    --     companion_model = 'a_c_cougar_01',
    --     companion_price = 500,
    --     companion_name = 'Cougar',
    -- },
    -- {
    --     companion_model = 'a_c_wolf',
    --     companion_price = 350,
    --     companion_name = 'Wolf',
    -- },
    -- {
    --     companion_model = 'a_c_bear_01',
    --     companion_price = 120,
    --     companion_name = 'Bear',
    -- },

-- reptile
    -- {
    --     companion_coords = vector4(-5572.65, -3062.22, 2.30, 118.12),
    --     companion_model = 'a_c_iguana_01', -- A_C_IguanaDesert_01  A_C_Squirrel_01  A_C_Snake_01
    --     companion_price = 200,
    --     companion_name = 'Iguana',
    --     stableid = 'tumbleweed',
    -- },
    -- {
    --     companion_coords = vector4(-5574.81, -3063.08, 2.65, 260.43),
    --     companion_model = 'a_c_iguanadesert_01',
    --     companion_price = 200,
    --     companion_name = 'Iguana desert',
    --     stableid = 'tumbleweed',
    -- },
    -- {
    --     companion_coords = vector4(-5574.49, -3061.38, 3.40, 217.51),
    --     companion_model = 'a_c_snake_01',
    --     companion_price = 200,
    --     companion_name = 'Snake',
    --     stableid = 'tumbleweed',
    -- },

-- birds
    -- {
    --     companion_coords = vector4(-5588.38671875, -3071.296875, 3.48518502712249, 53.85),
    --     companion_model = 'a_c_eagle_01', -- A_C_Owl_01  A_C_Hawk_01  A_C_Parrot_01  A_C_Woodpecker_01  A_C_SongBird_01  A_C_Cardinal_01  A_C_Bat_01
    --     companion_price = 225,
    --     companion_name = 'Eagle',
    --     stableid = 'tumbleweed',
    -- },
    -- {
    --     companion_coords = vector4(-5588.7841796875, -3071.784423828125, 3.49062204360961, 53.85),
    --     companion_model = 'a_c_owl_01',
    --     companion_price = 225,
    --     companion_name = 'Owl',
    --     stableid = 'tumbleweed',
    -- },
    -- {
    --     companion_coords = vector4(-5589.1376953125, -3072.22119140625, 3.49324095249176, 53.85),
    --     companion_model = 'a_c_hawk_01',
    --     companion_price = 225,
    --     companion_name = 'Hawk',
    --     stableid = 'tumbleweed',
    -- },
    -- {
    --     companion_coords = vector4(-5589.57080078125, -3072.650146484375, 3.49686598777771, 53.85),
    --     companion_model = 'a_c_parrot_01',
    --     companion_price = 225,
    --     companion_name = 'Parrot',
    --     stableid = 'tumbleweed',
    -- },
]]

-- No return needed - Config.StableSettings is assigned directly above