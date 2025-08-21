-- ================================
-- GENERAL SETTINGS
-- Basic configuration for hdrp-companion
-- ================================

Config = Config or {}

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