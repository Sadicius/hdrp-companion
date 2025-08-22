-------------------------
-- LOCATIONS PETS FOR BUY
-------------------------
local CompanionSettings = {
    -- valentine
    {
        companioncoords = vector4(-290.62, 657.11, 113.57, 122.57),
        companionmodel = 'a_c_doghusky_01',
        companionprice = 200,
        companionname = 'Husky',
        stableid = 'valentine',
    },
    {
        companioncoords = vector4(-289.32, 653.85, 113.44, 297.49),
        companionmodel = 'a_c_dogcatahoulacur_01',
        companionprice = 50,
        companionname = 'Mutt',
        stableid = 'valentine'
    },
    {
        companioncoords = vector4(-283.77, 653.09, 113.22, 124.67),
        companionmodel = 'a_c_doglab_01',
        companionprice = 100,
        companionname = 'Labrador Retriever',
        stableid = 'valentine'
    },
    {
        companioncoords = vector4(-286.63, 649.03, 113.24, 295.18),
        companionmodel = 'a_c_doglab_01', -- 'a_c_dogrufus_01',
        companionprice = 100,
        companionname = 'Rufus',
        stableid = 'valentine'
    },
    {
        companioncoords = vector4(-285.48, 654.38, 113.10, 120.20),
        companionmodel = 'a_c_dogbluetickcoonhound_01',
        companionprice = 150,
        companionname = 'Coon Hound',
        stableid = 'valentine'
    },
    -- blackwater
    {
        companioncoords = vector4(-935.24, -1241.28, 51.55, 58.12),
        companionmodel = 'a_c_doghound_01',
        companionprice = 200,
        companionname = 'Hound',
        stableid = 'blackwater'
    },
    {
        companioncoords = vector4(-933.99, -1240.08, 51.49, 48.18),
        companionmodel = 'a_c_dogcollie_01',
        companionprice = 500,
        companionname = 'Collie',
        stableid = 'blackwater'
    },
    {
        companioncoords = vector4(-936.63, -1242.85, 51.62, 15.40),
        companionmodel = 'a_c_dogpoodle_01',
        companionprice = 120,
        companionname = 'Poodle',
        stableid = 'blackwater'
    },
    {
        companioncoords = vector4(-932.13, -1237.06, 51.33, 53.85),
        companionmodel = 'a_c_dogamericanfoxhound_01',
        companionprice = 225,
        companionname = 'Fox hound',
        stableid = 'blackwater'
    },
    {
        companioncoords = vector4(-933.00, -1238.60, 51.41, 59.48),
        companionmodel = 'a_c_dogaustraliansheperd_01',
        companionprice = 350,
        companionname = 'Australian Sheperd',
        stableid = 'blackwater'
    },
    -- tumbleweed
        -- cats
    {
        companioncoords = vector4(-5591.42, -3072.23, 2.45, 319.26),
        companionmodel = 'a_c_cat_01',
        companionprice = 500,
        companionname = 'Cat',
        stableid = 'tumbleweed',
    },
    -- wilds
    {
        companioncoords = vector4(-5583.70, -3048.80, 1.09, 325.51),
        companionmodel = 'a_c_doghound_01',
        companionprice = 200,
        companionname = 'Hound',
        stableid = 'tumbleweed',
    },
    {
        companioncoords = vector4(-5576.90, -3058.34, 2.10, 158.43),
        companionmodel = 'a_c_doghusky_01',
        companionprice = 200,
        companionname = 'Husky',
        stableid = 'tumbleweed',
    },
    {
        companioncoords = vector4(-5580.11, -3053.68, 1.36, 168.49),
        companionmodel = 'a_c_dogcatahoulacur_01',
        companionprice = 50,
        companionname = 'Mutt',
        stableid = 'tumbleweed',
    },
    {
        companioncoords = vector4(-5574.61, -3049.03, 0.68, 326.73),
        companionmodel = 'a_c_dogbluetickcoonhound_01',
        companionprice = 150,
        companionname = 'Coon Hound',
        stableid = 'tumbleweed',
    },
    {
        companioncoords = vector4(-5576.43, -3046.67, 0.65, 286.39),
        companionmodel = 'a_c_doglab_01',
        companionprice = 100,
        companionname = 'Labrador Retriever',
        stableid = 'tumbleweed',
    },
    -- tumbleweed
    -- wilds
    {
        companioncoords = vector4(-2891.4070, -3972.5532, -15.1823, 109.7351),
        companionmodel = 'a_c_dogbluetickcoonhound_01', -- 'a_c_bear_01',
        companionprice = 600,
        companionname = 'Medved',
        stableid = 'wapiti',
    },
    {
        companioncoords = vector4(-2892.9104, -3969.1328, -15.1855, 121.9486),
        companionmodel = 'a_c_doglab_01', -- 'a_c_wolf',
        companionprice = 400,
        companionname = 'Wolf',
        stableid = 'wapiti',
    },
}

-- More Information for others animals companions
--[[ 
-- Animal no use WIP
-- wilds
    -- {
    --     companionmodel = 'a_c_panther_01',
    --     companionprice = 500,
    --     companionname = 'Phanter',
    -- },
    -- {
    --     companionmodel = 'a_c_lionmangy_01', -- A_C_Panther_01  A_C_Cougar_01  A_C_Cat_01
    --     companionprice = 500,
    --     companionname = 'Lion Mangy',
    -- },
    -- {
    --     companionmodel = 'a_c_cougar_01',
    --     companionprice = 500,
    --     companionname = 'Cougar',
    -- },
    -- {
    --     companionmodel = 'a_c_wolf',
    --     companionprice = 350,
    --     companionname = 'Wolf',
    -- },
    -- {
    --     companionmodel = 'a_c_bear_01',
    --     companionprice = 120,
    --     companionname = 'Bear',
    -- },

-- reptile
    -- {
    --     companioncoords = vector4(-5572.65, -3062.22, 2.30, 118.12),
    --     companionmodel = 'a_c_iguana_01', -- A_C_IguanaDesert_01  A_C_Squirrel_01  A_C_Snake_01
    --     companionprice = 200,
    --     companionname = 'Iguana',
    --     stableid = 'tumbleweed',
    -- },
    -- {
    --     companioncoords = vector4(-5574.81, -3063.08, 2.65, 260.43),
    --     companionmodel = 'a_c_iguanadesert_01',
    --     companionprice = 200,
    --     companionname = 'Iguana desert',
    --     stableid = 'tumbleweed',
    -- },
    -- {
    --     companioncoords = vector4(-5574.49, -3061.38, 3.40, 217.51),
    --     companionmodel = 'a_c_snake_01',
    --     companionprice = 200,
    --     companionname = 'Snake',
    --     stableid = 'tumbleweed',
    -- },

-- birds
    -- {
    --     companioncoords = vector4(-5588.38671875, -3071.296875, 3.48518502712249, 53.85),
    --     companionmodel = 'a_c_eagle_01', -- A_C_Owl_01  A_C_Hawk_01  A_C_Parrot_01  A_C_Woodpecker_01  A_C_SongBird_01  A_C_Cardinal_01  A_C_Bat_01
    --     companionprice = 225,
    --     companionname = 'Eagle',
    --     stableid = 'tumbleweed',
    -- },
    -- {
    --     companioncoords = vector4(-5588.7841796875, -3071.784423828125, 3.49062204360961, 53.85),
    --     companionmodel = 'a_c_owl_01',
    --     companionprice = 225,
    --     companionname = 'Owl',
    --     stableid = 'tumbleweed',
    -- },
    -- {
    --     companioncoords = vector4(-5589.1376953125, -3072.22119140625, 3.49324095249176, 53.85),
    --     companionmodel = 'a_c_hawk_01',
    --     companionprice = 225,
    --     companionname = 'Hawk',
    --     stableid = 'tumbleweed',
    -- },
    -- {
    --     companioncoords = vector4(-5589.57080078125, -3072.650146484375, 3.49686598777771, 53.85),
    --     companionmodel = 'a_c_parrot_01',
    --     companionprice = 225,
    --     companionname = 'Parrot',
    --     stableid = 'tumbleweed',
    -- },
]]

return CompanionSettings