-- ================================
-- COMPANION ATTRIBUTES AND BEHAVIOR
-- Pet attributes, AI behavior, and personality settings
-- ================================

Config = Config or {}

-- ================================
-- PET ATTRIBUTES
-- ================================

Config.PetAttributes = {
    -- Core Settings
    RaiseAnimal = true, -- If enabled, you will have to feed your animal for it to gain XP and grow
    NoFear = false, -- Set to true for Bears/Wolves so horses won't be in constant fear
    Invincible = false,
    DefensiveMode = true, -- If true, pets become hostile to anything you are in combat with

    -- Movement and Detection
    FollowDistance = 3, -- Distance companion follows player
    FollowSpeed = 1, -- Speed at which companion follows
    TrackDistance = 2, -- Distance for tracking targets
    SearchRadius = 50.0, -- How far the pet will search for hunted animals

    -- Starting Attributes
    Starting = {
        Health = 300,
        Hunger = 75.0,
        Thirst = 75.0,
        Happiness = 75.0,
        MaxBonding = 5000
    },

    -- Auto-spawn settings when companion dies
    AutoDeadSpawn = {
        active = true,
        Time = 5 * 60 * 1000 -- 5 minutes
    },

    -- Level-based attributes (companion health/stamina/ability/speed/acceleration)
    -- Companion inventory weight and slots by level
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

    -- AI Personalities based on XP
    -- Available hashes: AGGRESSIVE, GUARD_DOG, ATTACK_DOG, ATTACK_SHOP_DOG, TIMIDGUARDDOG, AVOID_DOG
    personalities = {
        {xp = 1000, hash = 'TIMIDGUARDDOG'},
        {xp = 2000, hash = 'GUARD_DOG'},
        {xp = 0, hash = 'AVOID_DOG'} -- Default value if no threshold is reached
    }
}