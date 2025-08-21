-- ================================
-- ITEMS AND FEEDING CONFIGURATION
-- Item definitions and feeding mechanics
-- ================================

Config = Config or {}

-- ================================
-- ITEM DEFINITIONS
-- ================================

-- Core companion items
Config.AnimalBrush = 'horse_brush'
Config.AnimalFood = 'companion_feed'
Config.AnimalDrink = 'companion_drink'
Config.AnimalHappy = 'companion_sugar'
Config.AnimalStimulant = 'companion_stimulant'
Config.AnimalRevive = 'companion_reviver'
Config.AnimalBone = 'companion_bone'

-- Distance for feeding interactions
Config.DistanceFeed = 10.0

-- ================================
-- COMPANION FEEDING EFFECTS
-- ================================

Config.CompanionFeed = {
    -- Companion-specific items
    ['companion_feed'] = { 
        health = 20, stamina = 10, hunger = 50, thirst = 0, happiness = 10,
        ismedicine = false, ModelHash = `p_cs_meatbowl01x`
    },
    ['companion_drink'] = { 
        health = 20, stamina = 15, hunger = 0, thirst = 50, happiness = 10,
        ismedicine = false, ModelHash = 's_dogbowl01x'
    },
    ['companion_sugar'] = { 
        health = 25, stamina = 25, hunger = 0, thirst = 0, happiness = 25,
        ismedicine = false, ModelHash = 'p_ambforage03x'
    },

    -- Generic items
    ['raw_meat'] = { 
        health = 20, stamina = 10, hunger = 50, thirst = 0, happiness = 10,
        ismedicine = false
    },
    ['water'] = { 
        health = 20, stamina = 15, hunger = 0, thirst = 50, happiness = 10,
        ismedicine = false
    },
    ['sugarcube'] = { 
        health = 20, stamina = 25, hunger = 0, thirst = 0, happiness = 25,
        ismedicine = false
    },

    -- Medicine items
    ['companion_stimulant'] = { 
        health = 100, stamina = 100,
        ismedicine = true, medicineModelHash = 'p_cs_syringe01x'
    },
    ['apple'] = { 
        health = 50, stamina = 50,
        ismedicine = true, medicineModelHash = 'p_apple01x'
    },

    -- Training items
    ['companion_bone'] = { 
        health = 5, stamina = 5, hunger = 0, thirst = 0, happiness = 15,
        ismedicine = false, ModelHash = 'p_cs_bone01x'
    },
}