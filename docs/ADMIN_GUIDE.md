# 🛠️ HDRP-Companion Administration Guide

Complete configuration and management guide for server administrators.

## 🚀 Initial Setup

### Prerequisites Check
Before installation, ensure your server has:
```bash
# Required resources
ensure rsg-core      # RSGCore framework
ensure ox_lib        # Overextended library
ensure ox_target     # Targeting system
ensure oxmysql       # Database connector
```

### Installation Process
1. **Download and Extract**: Place in your `resources` folder
2. **Database Setup**: Tables auto-create on first start
3. **Server Configuration**: Add to `server.cfg`
4. **Restart Server**: Full restart required for initialization

### Verify Installation
```bash
# Check console for these messages:
[COMPANION] Database tables created successfully
[COMPANION] Performance monitor initialized
[COMPANION] Companion system loaded
```

## ⚙️ Core Configuration

### Main Configuration File: `shared/config.lua`

```lua
Config = {
    Debug = false,                    -- Enable debug mode for troubleshooting
    MaxCompanions = 3,               -- Max companions per player
    AutoSave = true,                 -- Automatic saving of companion data
    SaveInterval = 300000,           -- Auto-save interval (5 minutes)
    
    -- Performance Settings
    Performance = {
        Mode = 'balanced',           -- 'performance', 'balanced', 'quality'
        MaxActiveCompanions = 20,    -- Max active companions on server
        AIUpdateInterval = 2000,     -- AI update frequency (ms)
        CleanupInterval = 600000,    -- Cleanup inactive companions (10 min)
    },
    
    -- Economic Settings
    Economy = {
        EnablePurchasing = true,     -- Allow buying companions
        BasePrices = {
            dog = 150,               -- Base price for dogs
            cat = 100,               -- Base price for cats
            wolf = 500,              -- Base price for wolves (if enabled)
        },
        FeedingCosts = {
            raw_meat = 5,            -- Cost per feeding
            cooked_meat = 8,
            dog_biscuit = 3,
        }
    }
}
```

### Advanced Performance Configuration: `shared/config/performance.lua`

```lua
Config.EnhancedAI = {
    -- AI Performance Modes
    PerformanceMode = 'balanced',    -- 'performance', 'balanced', 'quality'
    
    -- Memory Management
    MaxMemoryEntries = 20,           -- AI memory limit per companion
    MemoryCleanupInterval = 300,     -- Cleanup old memories (seconds)
    
    -- Decision Making
    DecisionTimeout = 50,            -- Max AI decision time (ms)
    ContextUpdateRate = 2000,        -- Context analysis frequency (ms)
    
    -- Server Resource Limits
    MaxConcurrentAI = 25,            -- Max AI companions processing simultaneously
    ThreadPriority = 'normal',       -- 'low', 'normal', 'high'
}
```

## 🎯 Performance Optimization

### Performance Modes Explained

**🚀 Performance Mode** (Recommended for high-pop servers):
```lua
Config.EnhancedAI.PerformanceMode = 'performance'
```
- Reduced AI complexity for better FPS
- Faster response times
- Lower memory usage
- Best for 50+ player servers

**⚖️ Balanced Mode** (Default - Recommended for most servers):
```lua
Config.EnhancedAI.PerformanceMode = 'balanced'
```
- Optimal balance of features and performance
- Good AI behavior without heavy resource usage
- Suitable for 20-50 player servers

**✨ Quality Mode** (Recommended for RP-focused servers):
```lua
Config.EnhancedAI.PerformanceMode = 'quality'
```
- Full AI features and advanced behaviors
- Best companion intelligence and immersion
- Best for smaller servers (under 32 players)

### Server Resource Monitoring

Check companion system impact:
```bash
# Monitor resource usage
monitor resource_name

# Check active companions
/pet_admin stats

# View performance metrics
/pet_admin performance
```

### Optimization Tips

**For High-Population Servers**:
```lua
Config.Performance.MaxActiveCompanions = 15    -- Reduce from default 20
Config.Performance.AIUpdateInterval = 3000     -- Increase from 2000ms
Config.MaxCompanions = 2                       -- Reduce from 3 per player
```

**For Low-Population Servers**:
```lua
Config.Performance.MaxActiveCompanions = 30    -- Increase for more companions
Config.Performance.AIUpdateInterval = 1500     -- Faster AI updates
Config.MaxCompanions = 5                       -- Allow more per player
```

## 🏪 Economic Configuration

### Pricing Strategy
```lua
Config.Economy.BasePrices = {
    dog = 150,              -- Starter companion, affordable
    cat = 100,              -- Cheapest option for new players
    wolf = 500,             -- Premium companion, rare
    bear = 1000,            -- Elite companion (if enabled)
}
```

### Shop Integration
```lua
Config.Shops = {
    EnableNPCShops = true,           -- Enable NPC companion vendors
    EnablePlayerShops = false,       -- Allow player-to-player sales
    
    ShopLocations = {
        valentine = {
            coords = vector3(-378.89, 786.52, 116.18),
            npc = 'a_m_m_farmer_01',
            blip = true
        },
        blackwater = {
            coords = vector3(-875.42, -1230.52, 53.84),
            npc = 'a_m_m_farmer_01',
            blip = true
        }
    }
}
```

### Currency Configuration
```lua
Config.Currency = {
    Type = 'cash',                   -- 'cash', 'bank', 'custom'
    CustomCurrency = 'companion_tokens', -- If using custom currency
    EnableMultipleCurrencies = false -- Allow different payment methods
}
```

## 🔒 Security and Anti-Cheat

### Player Limitations
```lua
Config.Security = {
    MaxCompanionsPerPlayer = 3,      -- Hard limit per player
    CooldownBetweenPurchases = 3600, -- 1 hour cooldown (seconds)
    RequireMinLevel = 5,             -- Min player level to buy companions
    
    -- Spawning Restrictions
    AntiSpamDelay = 5000,            -- 5 second delay between spawns
    MaxSpawnDistance = 50.0,         -- Max distance from player to spawn
    SafeZoneOnly = false,            -- Only allow spawning in safe zones
}
```

### Admin Commands
```bash
# Admin companion management
/pet_admin give [player_id] [type]     # Give companion to player
/pet_admin remove [player_id] [comp_id] # Remove specific companion
/pet_admin reset [player_id]           # Reset all player companions
/pet_admin stats                       # View server companion statistics
/pet_admin cleanup                     # Force cleanup inactive companions
```

### Database Management
```lua
Config.Database = {
    AutoCleanup = true,              -- Enable automatic cleanup
    CleanupInterval = 86400,         -- Daily cleanup (seconds)
    KeepInactiveFor = 2592000,       -- Keep inactive companions for 30 days
    BackupBeforeCleanup = true,      -- Create backup before cleanup
}
```

## 🐕 Companion Type Configuration

### Available Companion Types
```lua
Config.CompanionTypes = {
    dog = {
        enabled = true,
        models = {'a_c_dog_shepherd', 'a_c_dog_husky', 'a_c_dog_retriever'},
        basePrice = 150,
        maxLevel = 10,
        specialAbilities = {'hunt', 'guard', 'fetch'}
    },
    cat = {
        enabled = true,
        models = {'a_c_cat_01'},
        basePrice = 100,
        maxLevel = 8,
        specialAbilities = {'stealth', 'small_game_hunt'}
    },
    wolf = {
        enabled = false,             -- Disabled by default
        models = {'a_c_wolf', 'a_c_wolf_medium'},
        basePrice = 500,
        maxLevel = 12,
        specialAbilities = {'pack_hunt', 'intimidate', 'track'},
        requiresPermission = true    -- Admin permission required
    }
}
```

### Companion Abilities Configuration
```lua
Config.Abilities = {
    hunt = {
        enabled = true,
        cooldown = 300,              -- 5 minute cooldown
        successRate = 0.7,           -- 70% base success rate
        experienceGain = 25
    },
    guard = {
        enabled = true,
        alertRadius = 15.0,          -- Alert player within 15 units
        threatDetection = true,
        alertSound = true
    },
    fetch = {
        enabled = true,
        maxDistance = 100.0,         -- Max fetch distance
        itemTypes = {'all'},         -- Items that can be fetched
        cooldown = 10
    }
}
```

## 🎮 Mini-Games Configuration

### Enable/Disable Mini-Games
```lua
Config.MiniGames = {
    treasureHunt = {
        enabled = true,
        cooldown = 1800,             -- 30 minute cooldown
        maxRewards = 3,              -- Max rewards per hunt
        difficultyLevels = {'easy', 'medium', 'hard'}
    },
    fetchGame = {
        enabled = true,
        cooldown = 60,               -- 1 minute cooldown
        maxDistance = 50.0,
        experienceGain = 10
    },
    agility = {
        enabled = true,
        requiresSetup = true,        -- Admin must place agility courses
        timeLimit = 120,             -- 2 minute time limit
        experienceGain = 15
    }
}
```

### Reward Configuration
```lua
Config.Rewards = {
    treasureHunt = {
        common = {'cash', 5, 25},    -- Type, min, max
        uncommon = {'item', 'gold_nugget', 1},
        rare = {'item', 'jewelry_emerald_ring', 1}
    },
    training = {
        experienceMultiplier = 1.5,  -- 1.5x XP for training
        bondingBonus = 0.1,          -- 10% bonding bonus
        cooldownReduction = 0.9      -- 10% cooldown reduction
    }
}
```

## 🔧 Troubleshooting Guide

### Common Issues and Solutions

**Issue: Companions not spawning**
```bash
# Check dependencies
ensure ox_lib
ensure ox_target
ensure rsg-core

# Verify database connection
/check mysql

# Check console for errors
[ERROR] [oxmysql] Connection failed
```

**Issue: Poor performance with many companions**
```lua
-- Reduce AI complexity
Config.EnhancedAI.PerformanceMode = 'performance'
Config.Performance.MaxActiveCompanions = 10
Config.Performance.AIUpdateInterval = 4000
```

**Issue: Database errors**
```sql
-- Check table structure
DESCRIBE player_companions;
DESCRIBE companion_memory;
DESCRIBE companion_coordination;

-- Fix corrupted data
DELETE FROM player_companions WHERE companiondata = '{}';
```

### Debug Mode
Enable debug mode for detailed logging:
```lua
Config.Debug = true
```

Debug commands:
```bash
/pet_debug ai [companion_id]      # Debug AI behavior
/pet_debug performance             # Show performance metrics
/pet_debug database               # Check database connectivity
/pet_debug memory [player_id]     # Show memory usage
```

### Performance Monitoring
```lua
Config.Monitoring = {
    EnableMetrics = true,           -- Enable performance tracking
    LogPerformance = false,         -- Log to file
    AlertThreshold = 100,           -- Alert if response time > 100ms
    AutoOptimize = true             -- Automatic performance adjustments
}
```

## 📊 Server Statistics and Analytics

### Built-in Analytics
```bash
# View server companion statistics
/pet_admin analytics

# Export data for analysis
/pet_admin export [timeframe]

# Performance reports
/pet_admin performance report
```

### Custom Events for Integration
```lua
-- Server events you can hook into
RegisterServerEvent('hdrp-companions:server:companionSpawned')
RegisterServerEvent('hdrp-companions:server:companionDismissed')
RegisterServerEvent('hdrp-companions:server:companionLevelUp')
RegisterServerEvent('hdrp-companions:server:companionDied')

-- Client events
RegisterNetEvent('hdrp-companions:client:updateCompanionData')
RegisterNetEvent('hdrp-companions:client:playAnimation')
RegisterNetEvent('hdrp-companions:client:showNotification')
```

## 🔄 Backup and Maintenance

### Automated Backups
```lua
Config.Backup = {
    AutoBackup = true,              -- Enable automatic backups
    BackupInterval = 3600,          -- Hourly backups (seconds)
    BackupLocation = 'backups/',    -- Backup directory
    KeepBackups = 7,                -- Keep last 7 backups
    CompressBackups = true          -- Compress backup files
}
```

### Maintenance Schedule
```bash
# Weekly maintenance commands
/pet_admin cleanup                 # Remove inactive companions
/pet_admin optimize               # Optimize database tables
/pet_admin backup                 # Manual backup
/pet_admin validate               # Validate data integrity
```

### Update Procedures
1. **Before updating**: Always backup your database
2. **During update**: Server restart usually required
3. **After update**: Run validation script
4. **Monitor**: Check logs for any migration issues

## 💡 Best Practices

### Server Configuration Tips
1. **Start Conservative**: Begin with performance mode, upgrade as needed
2. **Monitor Resource Usage**: Watch for memory leaks or high CPU usage
3. **Regular Backups**: Automated daily backups prevent data loss
4. **Gradual Rollouts**: Test new features with admin accounts first
5. **Player Feedback**: Listen to player reports about companion behavior

### Security Recommendations
1. **Regular Updates**: Keep the resource updated to latest version
2. **Access Control**: Limit admin commands to trusted staff
3. **Database Security**: Use strong passwords and secure connections
4. **Monitoring**: Set up alerts for unusual companion activity
5. **Audit Logs**: Keep logs of admin actions and player activities

---

*For additional support, check the validation script in `scripts/validate_fixes.lua` or consult the troubleshooting section.*