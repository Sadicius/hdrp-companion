-- ================================
-- GENERAL SETTINGS
-- Basic configuration for hdrp-companion
-- ================================

-- Config already initialized in shared/config.lua - DO NOT reinitialize

-- ================================
-- CORE SETTINGS
-- ================================

Config.Debug = false

-- UI and Controls
Config.EnableTarget = true
Config.EnablePrompts = true
Config.KeyBind = 'J'

-- Companion General Settings
Config.SpawnOnRoadOnly = false -- always spawn on road
Config.StoreFleedCompanion = false -- store companion if flee is used
Config.EnableServerNotify = false

-- Lifespan Settings
Config.CompanionDieAge = 45 -- companion age in days till it dies (days)
Config.StarterCompanionDieAge = 7 -- starter horse age in days till it dies (days)

-- Economic Settings
Config.priceRevive = 20.0
Config.pricedepreciation = 0.5 -- Price sell 0 - 1 (1 = 100%)

-- Cron Job for Animal Management
Config.AnimalCronJob = '*/2 * * * *' -- https://crontab.guru/#*/15_*_*_*_*

-- ================================
-- PROMPT SYSTEM CONTROLS
-- ================================

Config.Prompt = {
    -- Core companion controls
    CompanionCall = 0x760A9C6F,      -- [G] key - Call companion
    CompanionFlee = 0x8FFC75D6,      -- [H] key - Flee companion
    CompanionActions = 0xCEFD9220,   -- [E] key - Actions menu
    
    -- Inventory and care
    CompanionSaddleBag = 0x07B8BEAF, -- [F] key - Saddle bag access
    CompanionBrush = 0xA1ABB953,     -- [B] key - Brush companion
    
    -- Combat and activities
    CompanionAttack = 0x9959A6F0,    -- [R] key - Attack target
    CompanionTrack = 0x8AAA0AD4,     -- [T] key - Track target
    CompanionHunt = 0x6319DB71,      -- [U] key - Hunt animals
    
    -- Basic needs
    CompanionDrink = 0xD9D0E1C0,     -- [ENTER] key - Drink water
    CompanionEat = 0x07CE1E61        -- [SPACE] key - Eat food
}

-- ================================
-- GRID SYSTEM CONFIGURATION
-- ================================

-- Grid System Configuration for ox_lib operations
Config.GridSettings = {
    radius = 50.0,          -- Search radius for grid operations
    grid_size = 10.0,       -- Grid cell size
    update_frequency = 500, -- Grid update frequency (ms)
    max_entities = 100      -- Maximum entities to track in grid
}