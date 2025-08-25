-- ================================
-- SHOP CONFIGURATION
-- Items available in companion shops
-- ================================

-- Config already initialized in shared/config.lua - DO NOT reinitialize

-- ================================
-- SHOP ITEMS
-- ================================

Config.companionsShopItems = {
    { name = 'horse_brush', amount = 50, price = 5.0 },
    { name = 'companion_feed', amount = 50, price = 10.0 },
    { name = 'companion_drink', amount = 50, price = 5.0 },
    { name = 'companion_sugar', amount = 50, price = 10.0 },
    { name = 'companion_stimulant', amount = 50, price = 5.0 },
    { name = 'companion_reviver', amount = 50, price = 5.0 },
    { name = 'companion_bone', amount = 50, price = 5.0 },
}

-- Should stock save in database and load it after restart, to 'remember' stock value before restart
Config.PersistStock = false