Config = {}
lib.locale()

Config = {
    companionsShopItems = {
        { name = 'horse_brush', amount = 50, price = 5.0 },
        { name = 'companion_feed',amount = 50, price = 10.0 },
        { name = 'companion_drink',amount = 50, price = 5.0 },
        { name = 'companion_sugar',amount = 50, price = 10.0 },
        { name = 'companion_stimulant',amount = 50, price = 5.0 },
        { name = 'companion_reviver',amount = 50, price = 5.0 },
        { name = 'companion_bone',amount = 50, price = 5.0 },
    },
    PersistStock = false, --should stock save in database and load it after restart, to 'remember' stock value before restart
}

---------------------------------
-- general settings
---------------------------------
Config.Debug = false

Config.EnableTarget = true
Config.EnablePrompts = true
Config.KeyBind                = 'J'
Config.SpawnOnRoadOnly        = false -- always spawn on road
Config.AnimalCronJob          = '*/2 * * * *' -- https://crontab.guru/#*/15_*_*_*_*
Config.CompanionDieAge        = 45 -- companion age in days till it dies (days)
Config.StarterCompanionDieAge = 7 -- starter horse age in days till it dies (days)
Config.StoreFleedCompanion    = false -- store companion if flee is used
Config.EnableServerNotify     = false
Config.priceRevive            = 20.0
Config.pricedepreciation      = 0.5 -- Pric sell 0 - 1 (1 = 100%)

Config.TrickXp = { -- requeriment XP
    -- animations
    Stay = 50,
    Lay = 105,
    Animations = 500,
    -- games
    Bone = 50,
    Hunt = 150,
    BuriedBone = 100,
    digRandom = 150,
    TreasureHunt = 200,
    -- attacker
    Track = 250,
    HuntAnimals = 100,
    Attack = 500,
    SearchData = 500

}

Config.Increase = {
    Health      = math.random(25, 50), -- amount increased when drink_dog
    Hunger      = math.random(25, 50), -- amount increased when drink_dog
    Thirst      = math.random(25, 50), -- amount increased when feed_dog
    DegradeDirt = math.random(3, 5),   -- amount decreased dirt
    Happiness   = math.random(10, 25),   -- amount increased Happiness
    Brushdirt   = math.random(25, 50), -- amount increased when 

    XpPerFeed      = math.random(5, 10), -- The amount of XP every feed gives
    XpPerDrink     = math.random(5, 10), -- The amount of XP every drink gives
    XpPerStimulant = math.random(5, 10), -- The amount of XP every stimulant gives
    XpPerClean     = math.random(5, 10),  -- The amount of XP every clean gives
    XpPerMove      = math.random(1, 2),  -- The amount of XP every movep to layer gives

    XpPerBone       = math.random(1, 5), -- The amount of XP every play gives
    XpPerFindBuried = math.random(1, 5),  -- The amount of XP every movep to layer gives
    XpPerDigRandom  = math.random(5, 10),  -- The amount of XP every movep to layer gives
    XpPerTreasure   = math.random(20, 50)  -- The amount of XP every movep to layer gives
}

---------------------------------
-- player companion settings
---------------------------------
Config.PetAttributes = {
    RaiseAnimal     = true, -- If this is enabled, you will have to feed your animal for it to gain XP and grow. Only full grown pets can use commands (halfway you get the Stay command)
    NoFear          = false, -- Set this to true if you are using Bears/Wolves as pets so that your horses won't be in constant fear and wont get stuck on the eating dead body animation.
    Invincible      = false,
    DefensiveMode   = true, --If set to true, pets will become hostile to anything you are in combat with
    -- ThreatDetection = true, -- detection players mod defensive

    FollowDistance  = 3, -- player
    FollowSpeed = 1, -- pet
    TrackDistance   = 2, -- target
    SearchRadius    = 50.0, -- How far the pet will search for a hunted animal. Always a float value i.e 50.0

    Starting = { -- start atributes hunger, dirt or happy
        Health   = 300,
        Hunger   = 75.0,
        Thirst   = 75.0,
        Happines = 75.0,

        MaxBonding  = 5000
    },

    AutoDeadSpawn = {
        active = true,
        Time = 5 * 60 * 1000 -- 1 min
    },

    -- companion health/stamina/ability/speed/acceleration levels
    -- companion inventory weight by level
    levelAttributes = {
        {xpMin = 0, xpMax = 99, invWeight = 2000, invSlots = 2},
        {xpMin = 100, xpMax = 199, invWeight = 4000, invSlots = 4},
        {xpMin = 200, xpMax = 299, invWeight = 6000, invSlots = 6},
        {xpMin = 300, xpMax = 399, invWeight = 8000, invSlots = 8},
        {xpMin = 400, xpMax = 499, invWeight = 10000, invSlots = 10},
        {xpMin = 500, xpMax = 999, invWeight = 12000, invSlots = 12},
        {xpMin = 1000, xpMax = 1999, invWeight = 14000, invSlots = 14},
        {xpMin = 2000, xpMax = 2999, invWeight = 16000, invSlots = 16},
        {xpMin = 3000, xpMax = 3999, invWeight = 18000, invSlots = 18},
        {xpMin = 4000, xpMax = math.huge, invWeight = 20000, invSlots = 20}
    },

    -- Hashes: AGGRESSIVE, STANDARD_PED_AGRO_GUARD, PLAYER_HORSE, LAW_POLICE, WITNESS, WILDANIMAL
    -- Hashes: BOUNTY_HUNTER, SCRIPTEDOUTLAW, SCRIPTEDAGGRESSIVEROB,  SCRIPTEDAVOIDROB,  SCRIPTEDGALA,  SCRIPTEDINTIMIDATION,  SCRIPTEDTIMIDROB,  SCRIPTEDOUTLAW,
    -- Hashes Dog: GUARD_DOG, ATTACK_DOG, ATTACK_SHOP_DOG, TIMIDGUARDDOG, AVOID_DOG
    personalities = {
        {xp = 1000, hash = 'TIMIDGUARDDOG'},
        {xp = 2000, hash = 'GUARD_DOG'},
        {xp = 0, hash = 'AVOID_DOG'} -- Valor por defecto si no alcanza ningún umbral
    }
}

-- items
Config.AnimalBrush       = 'horse_brush'
Config.AnimalFood        = 'companion_feed'
Config.AnimalDrink       = 'companion_drink'
Config.AnimalHappy       = 'companion_sugar'
Config.AnimalStimulant   = 'companion_stimulant'
Config.AnimalRevive      = 'companion_reviver'

Config.DistanceFeed      = 10.0

Config.CompanionFeed = {
    -- medicineHash is optional. If u do not set, the default value wil be: consumable_companion_stimulant
    ['companion_feed']        = { health = 20,  stamina = 10, hunger = 50, thirst = 0,  happiness = 10,  ismedicine = false, ModelHash = `p_cs_meatbowl01x` },
    ['companion_drink']       = { health = 20,  stamina = 15, hunger = 0,  thirst = 50, happiness = 10,  ismedicine = false, ModelHash = 's_dogbowl01x' },
    ['companion_sugar']       = { health = 25,  stamina = 25, hunger = 0,  thirst = 0,  happiness = 25, ismedicine = false, ModelHash = 'p_ambforage03x' },

    ['raw_meat']              = { health = 20,  stamina = 10, hunger = 50, thirst = 0,  happiness = 10,  ismedicine = false },
    ['water']                 = { health = 20,  stamina = 15, hunger = 0,  thirst = 50, happiness = 10,  ismedicine = false },
    ['sugarcube']             = { health = 20,  stamina = 25, hunger = 0,  thirst = 0,  happiness = 25, ismedicine = false },

    ['companion_stimulant']   = { health = 100, stamina = 100, ismedicine = true, medicineModelHash = 'p_cs_syringe01x' },
    ['apple']                 = { health = 50, stamina = 50, ismedicine = true, medicineModelHash = 'p_apple01x' },
}

---------------------------------
-- games settings
---------------------------------
 -- BRING BONE
Config.AnimalBone     = 'companion_bone'
Config.Bone = {
    AutoDelete =  1 * 60 * 1000, -- 1 min for clean prop bone
    MaxDist      = 50.0, -- max dist 
    LostTraining = 40 -- 1 - 100 %
}

-- HIDE & SEARCH BONE
Config.buriedBone = {
    time = 10 * 1000, -- waiting time until the bone is hidden
    DoMiniGame = false, -- active o no skills for % lostBone 
    lostBone = 80, -- 1-100 % lost bone for no skills in buried bone
    -- Odds of finding the buried bone 1-100 divided into three sections: none, common, special
    findburied = 65, -- base to find something special (rare)
    findespecial = 10 -- trash finder (common)
}

Config.digrandom = {
    min = -20, -- The companion goes to a nearby random coordinate
    max = 20, -- The companion goes to a nearby random coordinate
    lostreward = 80, -- 80% win, 100 -1 % Found something useful
    rewards = {
        { chance = 20, items = {"raw_meat"} },
        { chance = 30, items = {"bread", "water"} },
        { chance = 50, items = {} }
    }
}

-- SEARCH TREASURE
Config.AnimalTreasure    = 'shovel' -- requeriment for searc
Config.TreasureHunt = {
    blipClue = false,

    DoMiniGame = true, -- active o no skills for search treasure
    MiniGameShovel = true, -- active o no shovel actions for find treasure  / in false active skills press W S A D
    HoleDistance = 1.5, -- dist for search with shovel
    AutoDelete = 10 * 60 * 1000, -- time for clean prop digging
    lostTreasure = 80, -- 1-100 % lost bone for no skills in buried bone

    minSteps = 2, -- min clue
    maxSteps = 6, -- max clue
    minDistance = 50.0, -- min dist point clue
    maxDistance = 100.0, -- max dist new point clue

    mindistToPlayer = 10.0, -- min separation between player and pet
    maxdistToPlayer = 30.0, -- max separation between player and pet
    distToTarget = 3.0, -- distance to the runway coordinates

    rewards = {
        { chance = 20, items = {"raw_meat"} },
        { chance = 30, items = {"bread", "water"} }
    },

    anim = {
        clueWaitTime = 2000, -- ms entre pistas
        digAnimTime = 5000, -- WORLD_DOG_DIGGING
        sniAnimTime = 5000, -- WORLD_DOG_SNIFFING_GROUND_WANDER
        guaAnimTime = 5000, -- WORLD_DOG_GUARD_GROWL
        howAnimTime= 5000, -- WORLD_DOG_HOWLING
    }
}

---------------------------------
-- Blip settings
---------------------------------
Config.Blip = {
    -- shop stable
    blipName = locale('cf_menu_companion_blip_name'), -- Config.Blip.blipName
    blipSprite = 'blip_shop', -- Config.Blip.blipSprite
    blipScale = 0.1, -- Config.Blip.blipScale
    -- color
    Color_modifier = `BLIP_MODIFIER_MP_COLOR_1`, -- select for all blips and gps
    -- games
    -- if in treasure need blipClue = true
    ClueName = locale('cl_blip_treasurehunt'), -- Config.Blip.blipName
    ClueSprite = `blip_ambient_eyewitness`, -- Config.Blip.blipSprite
    ClueScale = 0.2, -- Config.Blip.blipScale
    ClueTime = 1 * 60 * 1000, -- 1 min delete blip
    -- track
    TrackName = locale('cl_blip_track_target'), -- Config.Blip.blipName
    TrackSprite = `blip_code_waypoint`, -- Config.Blip.blipSprite
    TrackScale = 0.2, -- Config.Blip.blipScale
    TrackTime = 1 * 60 * 1000, -- 1 min delete blip
    -- dead
    DeadName = locale('cl_blip_dead'), -- Config.Blip.blipName
    DeadSprite = `BLIP_AMBIENT_DEATH`, -- Config.Blip.blipSprite
    DeadScale = 0.2, -- Config.Blip.blipScale
    DeadTime = 5 * 60 * 1000 -- 1 min delete blip
}

---------------------------------
-- stable settings
---------------------------------
Config.DistanceSpawn = 20.0
Config.FadeIn = true

Config.StableSettings = {

    {   -- valentine
        stableid = 'valentine',
        coords = vector3(-283.79, 659.05, 113.38),
        npcmodel = `mbh_rhodesrancher_females_01`,
        npccoords = vector4(-283.79, 659.05, 113.38, 84.08),
        npcpetmodel = `a_c_dogHound_01`,
        npcpetcoords = vector4(-284.50, 658.01, 113.31, 17.89),

        companioncustom = vec4(-280.55, 648.30, 114.37, 141.69),
    },

    {   -- blackwater
        stableid = 'blackwater',
        coords = vector3(-939.59, -1238.36, 52.07),
        npcmodel = `u_m_m_bwmstablehand_01`,
        npccoords = vector4(-939.59, -1238.36, 52.07, 238.11),
        npcpetmodel = `a_c_dogAustralianSheperd_01`,
        npcpetcoords = vector4(-937.47, -1235.65, 52.09, 208.05),

        companioncustom = vec4(-865.1928, -1366.3270, 43.5440, 86.8795),
    },

    {   -- tumbleweed
        stableid = 'tumbleweed',
        coords = vector3(-5584.34, -3065.37, 2.39),
        npcmodel = `u_m_m_bwmstablehand_01`,
        npccoords = vector4(-5584.34, -3065.37, 2.39, 2.41),
        npcpetmodel = `a_c_dogAustralianSheperd_01`,
        npcpetcoords = vector4(-5582.91, -3064.95, 2.36, 79.49),

        companioncustom = vec4(-5526.3452, -3030.7842, -2.0329, 105.3392),
    },

    {   -- wapiti
        stableid = 'wapiti',
        coords = vector3(-5584.34, -3065.37, 2.39),
        npcmodel = `u_m_m_bwmstablehand_01`,
        npccoords = vector4(453.09, 2209.89, 246.07, 299.49),
        npcpetmodel = `a_c_dogAustralianSheperd_01`,
        npcpetcoords = vector4(454.38, 2212.16, 246.10, 311.39),

        companioncustom = vec4(485.41, 2221.24, 247.11, 57.77),
    },
}

---------------------------------
-- companion action
---------------------------------
Config.Ambient = {
    ObjectAction = true,
    BoostAction = {
        Health = math.random(3, 9),
        Stamina = math.random(3, 9),

        -- Hunger = math.random(3, 9),
        -- Thirst = math.random(3, 9),
        -- Happiness = math.random(3, 9)
    },
    ObjectActionList = {
        [1] = {`p_watertrough02x`, 'drink'},
        [2] = {`p_watertrough01x`, 'drink'},
        [3] = {`p_haypile01x`, 'feed'},
    },
    Anim = {
        Drink  = { dict = 'amb_creature_mammal@world_dog_drink_ground@base', anim = 'base',   duration = 20 }, --duration in seconds
        Drink2 = { dict = 'mb_creature_mammal@world_dog_drink_ground@idle', anim = 'idle_a', duration = 20 },
        Graze  = { dict = 'amb_creature_mammal@world_dog_eating_ground@idle_a', anim = 'idle_a', duration = 15 }
    }
}

Config.PetSearchDatabase = true

Config.TablesTrack = {
    SearchData = false, -- If promp track target coords
    TrackingJob = {
        'leo',
        'medic',
        'bountyhuntress',
        'govenor',
        'horsetrainer'
    }, -- job type for tracking players
    AllowedSearchTables = {
        'rex_farming',
        'rex_camping',
        'rex_market',
        'rex_mining',
        'bangdai_posters',
        'rex_trapfishing',
        'criminal_activities',
        'phil_wanted_players',

        -- 'player_horses',
        -- 'rex_huntingwagon',
        -- 'rex_houses',
        -- 'player_ranch',
        -- 'player_pig_locations',
        -- 'player_horse_locations',
        -- 'player_safes',
        -- 'player_gangplace' ,
        -- 'player_bulletpress',
        -- 'player_oilwell',
        -- 'indian_plants'
    },
    coordsColumns = {
        "coords",
        "coordinates",
        "location",
        "position",
        "xyz",
        "pos",
        "properties",
        "propdata",
        "plate"
    }
}

Config.AttackOnly = {   -- <<Only have one of these 3 be true or all 3 false if you want the attack prompt on all targets -->>
    Active   = false,    -- Set true to be able to send your pet to attack a target you are locked on (holding right-click on them)
    Players = false,    -- The attack command works on only player peds
    NPC     = false,    -- If this is enabled, you can attack NPC peds and animals but not people
}

Config.TrackOnly = {   -- <<Only have one of these 3 be true or all 3 false if you want the track prompt on all targets -->>
    Active   = false,   -- If this is enabled, you can send pets to track a target you are locked on
    Players  = false,   -- The track command works on only player peds
    Animals  = false,   -- The track command works on animal types, not players/peds
    NPC      = false,   -- If this is enabled, you can track NPC peds and animals but not people
}

Config.HuntAnimalsOnly = {
    Active   = false,    -- Set true to be able to send your pet to attack a target you are locked on (holding right-click on them)
    Animals = false,    -- The attack command works on animal types, not players/peds
}

Config.Prompt = {
    TargetInfo      = true, -- show info animals Hide

    CompanionCall = 0xD8F73058, -- U INPUT_AIM_IN_AIR   -- CallPet
    -- CompanionRotate = { 0x7065027D, 0xB4E465B4 }, -- Left Right custom
    CompanionFlee       = 0x4216AF06, -- F INPUT_HORSE_COMMAND_FLEE (when horse menu is active)
    CompanionSaddleBag  = 0xC7B5340A, -- ENTER INPUT_FRONTEND_ACCEPT
    CompanionBrush      = 0x63A38F2C, -- B INPUT_INTERACT_HORSE_BRUSH

    CompanionHunt       = 0x71F89BBC, -- R INPUT_INTERACT_LOCKON_CALL_ANIMAL -- HUNTER
    CompanionActions    = 0xF3830D8E, -- J INPUT_OPEN_JOURNAL 
    CompanionAttack     = 0x620A6C5E, -- V INPUT_CINEMATIC_CAM    -- PetAttack
    CompanionTrack      = 0xD8CF0C95, -- C INPUT_CREATOR_RS    -- PetTrack
    CompanionHuntAnimals = 0x620A6C5E, -- V INPUT_CINEMATIC_CAM    -- PetAttack
    CompanionSearch = 0xD8CF0C95, -- C INPUT_CREATOR_RS    -- PetTrack

    CompanionDrink = 0xD8CF0C95, -- C INPUT_CREATOR_RS
    CompanionEat = 0xD8CF0C95 -- C INPUT_CREATOR_RS // 0x620A6C5E, -- V INPUT_CINEMATIC_CAM

}

---------------------------------
-- Pets carry animals
--------------------
Config.Animals = { --These are the animals the dogs will retrieve	 --Hash ID must be the ID of the table
	[-1003616053]   = {['name'] = 'Duck', },
    [1459778951]    = {['name'] = 'Eagle', },
	[-164963696]    = {['name'] = 'Herring Seagull',},
	[-1104697660]   = {['name'] = 'Vulture',},
	[-466054788]    = {['name'] = 'Wild Turkey',},
    [-2011226991]   = {['name'] = 'Wild Turkey',},
    [-166054593]    = {['name'] = 'Wild Turkey',},
	[-1076508705]   = {['name'] = 'Roseate Spoonbill',},
	[-466687768]    = {['name'] = 'Red-Footed Booby',},
	[-575340245]    = {['name'] = 'Wester Raven',},
	[1416324601]    = {['name'] = 'Ring-Necked Pheasant',},
	[1265966684]    = {['name'] = 'American White Pelican',},
	[-1797450568]   = {['name'] = 'Blue And Yellow Macaw',},
	[-2073130256]   = {['name'] = 'Double-Crested Cormorant',},
	[-564099192]    = {['name'] = 'Whooping Crane',},
	[723190474]     = {['name'] = 'Canada Goose',},
	[-2145890973]   = {['name'] = 'Ferruinous Hawk',},
	[1095117488]    = {['name'] = 'Great Blue Heron',},
	[386506078]     = {['name'] = 'Common Loon',},
	[-861544272]    = {['name'] = 'Great Horned Owl',},
}

Config.WaterTypes = {
    [1] =  {['name'] = 'San Luis River',       ['waterhash'] = -1504425495, ['watertype'] = 'river'},
    [2] =  {['name'] = 'Upper Montana River',  ['waterhash'] = -1781130443, ['watertype'] = 'river'},
    [3] =  {['name'] = 'Owanjila',             ['waterhash'] = -1300497193, ['watertype'] = 'river'},
    [4] =  {['name'] = 'HawkEye Creek',        ['waterhash'] = -1276586360, ['watertype'] = 'river'},
    [5] =  {['name'] = 'Little Creek River',   ['waterhash'] = -1410384421, ['watertype'] = 'river'},
    [6] =  {['name'] = 'Dakota River',         ['waterhash'] = 370072007,   ['watertype'] = 'river'},
    [7] =  {['name'] = 'Beartooth Beck',       ['waterhash'] = 650214731,   ['watertype'] = 'river'},
    [8] =  {['name'] = 'Deadboot Creek',       ['waterhash'] = 1245451421,  ['watertype'] = 'river'},
    [9] =  {['name'] = 'Spider Gorge',         ['waterhash'] = -218679770,  ['watertype'] = 'river'},
    [10] =  {['name'] = 'Roanoke Valley',      ['waterhash'] = -1229593481, ['watertype'] = 'river'},
    [11] =  {['name'] = 'Lannahechee River',   ['waterhash'] = -2040708515, ['watertype'] = 'river'},
    [12] =  {['name'] = 'Random1',             ['waterhash'] = 231313522,   ['watertype'] = 'river'},
    [13] =  {['name'] = 'Random2',             ['waterhash'] = 2005774838,  ['watertype'] = 'river'},
    [14] =  {['name'] = 'Random3',             ['waterhash'] = -1287619521, ['watertype'] = 'river'},
    [15] =  {['name'] = 'Random4',             ['waterhash'] = -1308233316, ['watertype'] = 'river'},
    [16] =  {['name'] = 'Random5',             ['waterhash'] = -196675805,  ['watertype'] = 'river'},
    [17] =  {['name'] = 'Arroyo De La Vibora', ['waterhash'] = -49694339,   ['watertype'] = 'river'},
}

-------------------------
-- EXTRA Skills Fight
-----------------------
Config.Skills  = true -- 'true' / 'false'
Config.SkillXP = math.random(1, 3) -- XP Training

-------------------------
-- EXTRA Webhooks / RANKING
-----------------------

Config.WebhookName = 'petinfo'
Config.WebhookTitle = 'Companions'
Config.WebhookColour = 'default'

-- Add in log
--    ['petinfo'] = 'https://discord.com/api/webhooks/1263651756626415646/XtPT_a4HIhgEuwtmaRvYvapJXW8zNAkgnn3cShzjOr-649MLLQLFRwy6vd67M_MpqCtS',


-------------------------
-- CUSTOM SETTINGS
-------------------------
-- Config.CustomCompanion = true
-- Config.Camera ={ -- Distance camera custom
--     Dog = true, -- animals dogs
--     DistY = 2.0,
--     DistZ = 0.5
-- }

-- Config.ComponentHash = {
--     -- Saddlebags = 0x80451C25,
--     Toys = "toys",
--     Horns = "horns",
--     Neck =  "neck",
--     Medal = "medal",
--     Masks =  "masks",
--     Cigar = "cigar"
-- }

-- Config.PriceComponent = {
--     -- Saddlebags = 3,
--     Toys = 1,
--     Horns = 1,
--     Neck =  1,
--     Medal = 1,
--     Masks =  1,
--     Cigar = 1
-- }
