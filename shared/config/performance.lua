-- ================================
-- PERFORMANCE MONITORING CONFIGURATION
-- Settings for companion performance tracking and optimization
-- ================================

-- Config already initialized in shared/config.lua - DO NOT reinitialize

-- ================================
-- PERFORMANCE SETTINGS
-- ================================

Config.Performance = {
    -- Enable/disable performance monitoring
    Enabled = false, -- Set to true to enable performance tracking
    
    -- Monitoring intervals
    SampleInterval = 1000,   -- ms between performance samples
    ReportInterval = 60000,  -- ms between automated reports
    
    -- Alert thresholds
    Thresholds = {
        FPSImpact = 0.5,      -- % FPS impact before alert (0.5 = 0.5%)
        MemoryUsage = 5.0,    -- MB memory usage before alert
        ErrorRate = 0.01,     -- Error rate before alert (0.01 = 1%)
        TaskTime = 50.0       -- ms average task time before alert
    },
    
    -- Reporting settings
    Reports = {
        Console = true,       -- Print reports to console
        File = false,         -- Save reports to file (future feature)
        Notifications = true, -- Show in-game notifications for alerts
        WebHook = false       -- Send to Discord webhook (future feature)
    },
    
    -- Advanced settings
    Advanced = {
        SampleSize = 30,      -- Number of FPS samples to keep
        MemoryClearing = true, -- Auto garbage collection on high memory
        TaskProfiling = true,  -- Profile individual tasks
        EventTracking = true   -- Track AI events and state changes
    }
}

-- ================================
-- PERFORMANCE OPTIMIZATION SETTINGS
-- ================================

Config.Optimization = {
    -- Cache optimization
    Cache = {
        PlayerUpdate = 500,   -- ms between player cache updates
        CoordUpdate = 250,    -- ms between coordinate updates
        VehicleUpdate = 1000  -- ms between vehicle updates
    },
    
    -- Task queue optimization
    TaskQueue = {
        MaxConcurrent = 3,    -- Max concurrent tasks
        TimeSlicing = true,   -- Use time slicing for long tasks
        PriorityQueue = true  -- Use priority-based task queue
    },
    
    -- Memory management
    Memory = {
        AutoCleanup = true,   -- Auto cleanup unused objects
        CleanupInterval = 30000, -- ms between cleanup cycles
        MaxEntities = 10,     -- Max companion entities per player
        PoolSize = 20         -- Entity pool size for reuse
    },
    
    -- Network optimization
    Network = {
        BatchUpdates = true,  -- Batch network updates
        UpdateRate = 100,     -- ms between network updates
        Compression = false   -- Compress network data (future feature)
    }
}

-- ================================
-- DEBUG AND DEVELOPMENT
-- ================================

Config.Debug = {
    -- Debug levels
    Level = 0,            -- 0=None, 1=Basic, 2=Verbose, 3=Full
    
    -- Debug categories
    Categories = {
        Performance = true,  -- Performance monitoring debug
        AI = true,          -- AI system debug
        State = false,      -- State management debug
        Events = false,     -- Event system debug
        Memory = false      -- Memory usage debug
    },
    
    -- Development tools
    DevTools = {
        Enabled = false,    -- Enable development tools
        HotReload = false,  -- Hot reload configuration changes
        Profiler = false,   -- Enable built-in profiler
        Inspector = false   -- Enable runtime inspector
    }
}

-- ================================
-- AUTOMATIC CONFIGURATION
-- ================================

-- Auto-enable performance monitoring in development
if Config.Debug and Config.Debug.Level > 0 then
    Config.Performance.Enabled = true
    Config.Performance.Reports.Console = true
end

-- Performance mode presets
Config.PerformancePresets = {
    ['disabled'] = {
        Performance = { Enabled = false },
        Optimization = { TaskQueue = { MaxConcurrent = 1 } }
    },
    
    ['basic'] = {
        Performance = { 
            Enabled = true,
            SampleInterval = 2000,
            ReportInterval = 120000
        }
    },
    
    ['full'] = {
        Performance = { 
            Enabled = true,
            SampleInterval = 500,
            ReportInterval = 30000,
            Advanced = { 
                TaskProfiling = true,
                EventTracking = true
            }
        }
    },
    
    ['server'] = {
        Performance = { 
            Enabled = true,
            Reports = { Console = false, Notifications = false }
        },
        Optimization = {
            Memory = { AutoCleanup = true, CleanupInterval = 15000 },
            Network = { BatchUpdates = true, UpdateRate = 200 }
        }
    }
}

-- ================================
-- ENHANCED AI CONFIGURATION v4.7.0
-- ================================

Config.EnhancedAI = {
    -- Core AI settings
    Enabled = true,                          -- Enable enhanced AI features
    PerformanceMode = 'balanced',            -- 'performance', 'balanced', 'quality'
    ResponseTimeLimit = 50,                  -- Maximum AI response time in ms
    
    -- Context Analysis settings
    ContextAnalysis = {
        Enabled = true,
        UpdateInterval = 2000,               -- Full context update interval (ms)
        QuickUpdateInterval = 500,           -- Quick context update interval (ms)
        PerformanceCheckInterval = 10000     -- Performance monitoring interval (ms)
    },
    
    -- Memory System settings
    MemorySystem = {
        Enabled = true,
        MaxRecentEvents = 20,                -- Maximum recent events stored
        MaxLocationMemories = 50,            -- Maximum location familiarity entries
        MaxPreferenceEntries = 30,           -- Maximum player preference entries
        CleanupInterval = 300000,            -- Memory cleanup interval (5 minutes)
        SaveInterval = 60000                 -- Memory save interval (1 minute)
    },
    
    -- Decision Engine settings
    DecisionEngine = {
        Enabled = true,
        MinDecisionInterval = 100,           -- Minimum time between decisions (ms)
        ContextWeightAdjustment = true,      -- Allow dynamic weight adjustment
        LearningEnabled = true               -- Enable decision learning from outcomes
    },
    
    -- Multi-Companion Coordination settings
    Coordination = {
        Enabled = true,
        MaxCompanionsPerPlayer = 3,          -- Server stability limit
        CoordinationRadius = 50.0,           -- Radius to detect other companions
        UpdateInterval = 3000,               -- Coordination update interval (ms)
        LeadershipElectionInterval = 10000   -- Leadership check interval (ms)
    },
    
    -- Performance Monitoring for AI
    AIPerformance = {
        TrackDecisions = true,               -- Track AI decision performance
        TrackMemoryOps = true,               -- Track memory operation performance
        TrackCoordination = true,            -- Track coordination performance
        AlertThresholds = {
            DecisionTime = 50,               -- Alert if decisions take >50ms
            MemoryOpTime = 30,               -- Alert if memory ops take >30ms
            CoordinationTime = 40            -- Alert if coordination takes >40ms
        }
    }
}

-- Performance mode configurations
Config.EnhancedAI.PerformanceModes = {
    ['performance'] = {
        ContextAnalysis = {
            UpdateInterval = 4000,
            QuickUpdateInterval = 1000
        },
        MemorySystem = {
            MaxRecentEvents = 10,
            CleanupInterval = 180000,
            SaveInterval = 120000
        },
        Coordination = {
            UpdateInterval = 5000,
            LeadershipElectionInterval = 15000
        }
    },
    
    ['balanced'] = {
        -- Use default settings (already configured above)
    },
    
    ['quality'] = {
        ContextAnalysis = {
            UpdateInterval = 1000,
            QuickUpdateInterval = 250
        },
        MemorySystem = {
            MaxRecentEvents = 30,
            MaxLocationMemories = 100,
            CleanupInterval = 600000,
            SaveInterval = 30000
        },
        Coordination = {
            UpdateInterval = 2000,
            LeadershipElectionInterval = 8000
        }
    }
}

-- Apply preset if specified
local function ApplyPreset(presetName)
    local preset = Config.PerformancePresets[presetName]
    if preset then
        for category, settings in pairs(preset) do
            if Config[category] then
                for key, value in pairs(settings) do
                    if type(value) == 'table' then
                        Config[category][key] = Config[category][key] or {}
                        for subKey, subValue in pairs(value) do
                            Config[category][key][subKey] = subValue
                        end
                    else
                        Config[category][key] = value
                    end
                end
            end
        end
    end
end

-- Apply AI performance mode
local function ApplyAIPerformanceMode(mode)
    local modeConfig = Config.EnhancedAI.PerformanceModes[mode]
    if modeConfig then
        for category, settings in pairs(modeConfig) do
            if Config.EnhancedAI[category] then
                for key, value in pairs(settings) do
                    Config.EnhancedAI[category][key] = value
                end
            end
        end
    end
end

-- You can set a preset here:
ApplyPreset('basic')  -- Enabled basic performance monitoring
ApplyAIPerformanceMode(Config.EnhancedAI.PerformanceMode)  -- Apply AI performance mode

-- ================================
-- VALIDATION
-- ================================

-- Validate configuration values
CreateThread(function()
    Wait(1000)
    
    -- Validate performance thresholds
    if Config.Performance.Thresholds.FPSImpact < 0 or Config.Performance.Thresholds.FPSImpact > 100 then
        print('[COMPANION-PERF] Warning: Invalid FPS impact threshold, using default')
        Config.Performance.Thresholds.FPSImpact = 0.5
    end
    
    if Config.Performance.Thresholds.MemoryUsage < 0 then
        print('[COMPANION-PERF] Warning: Invalid memory threshold, using default')
        Config.Performance.Thresholds.MemoryUsage = 5.0
    end
    
    -- Validate intervals
    if Config.Performance.SampleInterval < 100 then
        print('[COMPANION-PERF] Warning: Sample interval too low, using minimum 100ms')
        Config.Performance.SampleInterval = 100
    end
    
    if Config.Performance.ReportInterval < 10000 then
        print('[COMPANION-PERF] Warning: Report interval too low, using minimum 10s')
        Config.Performance.ReportInterval = 10000
    end
    
    -- ================================
    -- ENHANCED AI VALIDATION v4.7.0
    -- ================================
    
    if Config.EnhancedAI then
        -- Validate AI response time limit
        if Config.EnhancedAI.ResponseTimeLimit < 10 or Config.EnhancedAI.ResponseTimeLimit > 200 then
            print('[COMPANION-AI] Warning: Invalid response time limit, using default 50ms')
            Config.EnhancedAI.ResponseTimeLimit = 50
        end
        
        -- Validate context analysis intervals
        if Config.EnhancedAI.ContextAnalysis.UpdateInterval < 500 then
            print('[COMPANION-AI] Warning: Context update interval too low, using minimum 500ms')
            Config.EnhancedAI.ContextAnalysis.UpdateInterval = 500
        end
        
        if Config.EnhancedAI.ContextAnalysis.QuickUpdateInterval < 100 then
            print('[COMPANION-AI] Warning: Quick context update interval too low, using minimum 100ms')
            Config.EnhancedAI.ContextAnalysis.QuickUpdateInterval = 100
        end
        
        -- Validate memory system limits
        if Config.EnhancedAI.MemorySystem.MaxRecentEvents < 5 or Config.EnhancedAI.MemorySystem.MaxRecentEvents > 100 then
            print('[COMPANION-AI] Warning: Invalid max recent events, using default 20')
            Config.EnhancedAI.MemorySystem.MaxRecentEvents = 20
        end
        
        if Config.EnhancedAI.MemorySystem.MaxLocationMemories < 10 or Config.EnhancedAI.MemorySystem.MaxLocationMemories > 200 then
            print('[COMPANION-AI] Warning: Invalid max location memories, using default 50')
            Config.EnhancedAI.MemorySystem.MaxLocationMemories = 50
        end
        
        -- Validate coordination settings
        if Config.EnhancedAI.Coordination.MaxCompanionsPerPlayer < 1 or Config.EnhancedAI.Coordination.MaxCompanionsPerPlayer > 5 then
            print('[COMPANION-AI] Warning: Invalid max companions per player, using default 3')
            Config.EnhancedAI.Coordination.MaxCompanionsPerPlayer = 3
        end
        
        if Config.EnhancedAI.Coordination.CoordinationRadius < 10.0 or Config.EnhancedAI.Coordination.CoordinationRadius > 100.0 then
            print('[COMPANION-AI] Warning: Invalid coordination radius, using default 50.0')
            Config.EnhancedAI.Coordination.CoordinationRadius = 50.0
        end
        
        -- Validate decision engine settings
        if Config.EnhancedAI.DecisionEngine.MinDecisionInterval < 50 then
            print('[COMPANION-AI] Warning: Decision interval too low, using minimum 50ms')
            Config.EnhancedAI.DecisionEngine.MinDecisionInterval = 50
        end
        
        print('[COMPANION-AI] Enhanced AI configuration validated successfully')
        print('[COMPANION-AI] Performance Mode: ' .. Config.EnhancedAI.PerformanceMode)
        print('[COMPANION-AI] Response Time Limit: ' .. Config.EnhancedAI.ResponseTimeLimit .. 'ms')
        print('[COMPANION-AI] Max Companions Per Player: ' .. Config.EnhancedAI.Coordination.MaxCompanionsPerPlayer)
    end
end)

if Config.Debug and Config.Debug.Level > 0 then
    print('[COMPANION-PERF] Performance configuration loaded')
end