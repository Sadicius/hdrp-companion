-- ================================
-- EXPERIENCE AND PROGRESSION SYSTEM
-- XP requirements and progression settings
-- ================================

-- Config already initialized in shared/config.lua - DO NOT reinitialize

-- ================================
-- TRICK XP REQUIREMENTS
-- ================================

Config.TrickXp = {
    -- Animations
    Stay = 50,
    Lay = 105,
    Animations = 500,
    
    -- Games
    Bone = 50,
    Hunt = 150,
    BuriedBone = 100,
    digRandom = 150,
    TreasureHunt = 200,
    
    -- Combat/Tracking
    Track = 250,
    HuntAnimals = 100,
    Attack = 500,
    SearchData = 500
}

-- ================================
-- XP GAIN RATES
-- ================================

Config.Increase = {
    -- Stats increases
    Health = math.random(25, 50), -- amount increased when companion drinks
    Hunger = math.random(25, 50), -- amount increased when companion eats
    Thirst = math.random(25, 50), -- amount increased when companion drinks
    DegradeDirt = math.random(3, 5), -- amount decreased dirt
    Happiness = math.random(10, 25), -- amount increased happiness
    Brushdirt = math.random(25, 50), -- amount increased when brushed

    -- XP gains
    XpPerFeed = math.random(5, 10), -- The amount of XP every feed gives
    XpPerDrink = math.random(5, 10), -- The amount of XP every drink gives
    XpPerStimulant = math.random(5, 10), -- The amount of XP every stimulant gives
    XpPerClean = math.random(5, 10), -- The amount of XP every clean gives
    XpPerMove = math.random(1, 2), -- The amount of XP every move gives

    -- Activity XP
    XpPerBone = math.random(1, 5), -- The amount of XP every play gives
    XpPerFindBuried = math.random(1, 5), -- The amount of XP finding buried items gives
    XpPerDigRandom = math.random(5, 10), -- The amount of XP random digging gives
    XpPerTreasure = math.random(20, 50) -- The amount of XP treasure hunting gives
}