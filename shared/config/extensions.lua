-- ================================
-- EXTENSIONS FRAMEWORK CONFIGURATION
-- Sistema de extensiones independientes para HDRP-Companion
-- ================================

Config = Config or {}

-- ================================
-- EXTENSIONS CORE CONFIGURATION
-- ================================

Config.Extensions = {
    -- Framework settings
    Enabled = true,                    -- Master enable/disable
    LoadOrder = 'dependency',          -- 'dependency', 'alphabetical', 'manual'
    HotReload = false,                 -- Enable hot reload in development
    SafeMode = true,                   -- Fail-safe loading
    
    -- Performance settings
    Performance = {
        LazyLoading = true,            -- Load extensions on demand
        MaxConcurrent = 3,             -- Max concurrent extension loads
        TimeoutMs = 5000,              -- Extension load timeout
        MemoryLimit = 10               -- MB per extension limit
    },
    
    -- Validation settings
    Validation = {
        CheckDependencies = true,      -- Validate extension dependencies
        CheckConflicts = true,         -- Check for conflicts
        RequireManifest = true,        -- Require extension manifest
        ValidateConfig = true          -- Validate extension config
    }
}

-- ================================
-- AVAILABLE EXTENSIONS
-- ================================

Config.Extensions.Available = {
    -- Core extensions (always loaded first)
    ['core_ai_enhancement'] = {
        enabled = true,
        priority = 1,
        dependencies = {},
        config = {
            advanced_behavior = true,
            learning_enabled = true,
            context_awareness = true
        }
    },
    
    ['performance_monitor'] = {
        enabled = true,
        priority = 2,
        dependencies = {},
        config = {
            real_time_tracking = true,
            auto_optimization = false,
            reporting = true
        }
    },
    
    -- Feature extensions
    ['multi_companion_system'] = {
        enabled = false,               -- Disabled by default
        priority = 10,
        dependencies = {'core_ai_enhancement'},
        config = {
            max_companions = 3,
            coordination_enabled = true,
            leadership_election = true
        }
    },
    
    ['advanced_customization'] = {
        enabled = false,
        priority = 15,
        dependencies = {},
        config = {
            appearance_system = true,
            behavior_profiles = true,
            custom_animations = false
        }
    },
    
    ['economy_integration'] = {
        enabled = false,
        priority = 20,
        dependencies = {},
        config = {
            dynamic_pricing = true,
            market_system = false,
            trading_enabled = false
        }
    },
    
    -- Specialized extensions
    ['hunting_companion'] = {
        enabled = false,
        priority = 25,
        dependencies = {'core_ai_enhancement'},
        config = {
            tracking_skills = true,
            prey_detection = true,
            retrieve_system = true
        }
    },
    
    ['combat_companion'] = {
        enabled = false,
        priority = 30,
        dependencies = {'core_ai_enhancement'},
        config = {
            tactical_behavior = true,
            formation_system = false,
            advanced_combat = false
        }
    },
    
    -- Integration extensions
    ['rsgcore_integration'] = {
        enabled = true,
        priority = 5,
        dependencies = {},
        config = {
            job_system = true,
            gang_system = false,
            event_integration = true
        }
    },
    
    ['third_party_compatibility'] = {
        enabled = false,
        priority = 50,
        dependencies = {},
        config = {
            qbcore_compat = false,
            esx_compat = false,
            standalone = false
        }
    }
}

-- ================================
-- EXTENSION LOADING CONFIGURATION
-- ================================

Config.Extensions.LoadPaths = {
    client = 'client/extensions/',
    server = 'server/extensions/',
    shared = 'shared/extensions/',
    config = 'shared/config/extensions/'
}

Config.Extensions.FilePatterns = {
    client = '*_client.lua',
    server = '*_server.lua',
    shared = '*_shared.lua',
    config = '*_config.lua'
}

-- ================================
-- DEPENDENCY MANAGEMENT
-- ================================

Config.Extensions.Dependencies = {
    -- Define dependency relationships
    chains = {
        ['advanced_ai'] = {'core_ai_enhancement', 'performance_monitor'},
        ['full_companion'] = {'multi_companion_system', 'advanced_customization'},
        ['hunter_pack'] = {'hunting_companion', 'advanced_ai'},
        ['combat_pack'] = {'combat_companion', 'advanced_ai'}
    },
    
    -- Conflict detection
    conflicts = {
        ['hunting_companion'] = {'combat_companion'},  -- Mutual exclusive for now
        -- Add more conflicts as needed
    },
    
    -- Optional dependencies (nice to have)
    optional = {
        ['hunting_companion'] = {'economy_integration'},
        ['combat_companion'] = {'multi_companion_system'}
    }
}

-- ================================
-- RUNTIME CONFIGURATION
-- ================================

Config.Extensions.Runtime = {
    -- Events
    Events = {
        OnExtensionLoad = 'hdrp:extension:loaded',
        OnExtensionUnload = 'hdrp:extension:unloaded',
        OnExtensionError = 'hdrp:extension:error',
        OnExtensionReload = 'hdrp:extension:reloaded'
    },
    
    -- State management
    State = {
        PersistentStorage = true,      -- Save extension state
        RuntimeModification = false,   -- Allow runtime enable/disable
        StateValidation = true         -- Validate state on load
    },
    
    -- Error handling
    ErrorHandling = {
        ContinueOnError = true,        -- Continue loading other extensions
        RetryAttempts = 3,             -- Retry failed extensions
        FallbackMode = true,           -- Fall back to minimal functionality
        LogErrors = true               -- Log extension errors
    }
}

-- ================================
-- DEVELOPMENT CONFIGURATION
-- ================================

Config.Extensions.Development = {
    -- Debug settings
    Debug = {
        Enabled = false,               -- Enable debug mode
        VerboseLogging = false,        -- Detailed logs
        LoadTiming = false,            -- Time extension loading
        MemoryTracking = false         -- Track extension memory usage
    },
    
    -- Hot reload settings
    HotReload = {
        Enabled = false,               -- Enable hot reload
        WatchPaths = true,             -- Watch extension files
        AutoReload = false,            -- Auto reload on file change
        ReloadDelay = 1000             -- Delay before reload (ms)
    },
    
    -- Testing
    Testing = {
        MockMode = false,              -- Enable mock mode for testing
        ExtensionTests = false,        -- Run extension tests
        ValidateManifests = true       -- Validate extension manifests
    }
}

-- ================================
-- HELPER FUNCTIONS
-- ================================

-- Get extension configuration
function Config.Extensions:GetExtensionConfig(extensionName)
    return self.Available[extensionName] and self.Available[extensionName].config or {}
end

-- Check if extension is enabled
function Config.Extensions:IsExtensionEnabled(extensionName)
    local ext = self.Available[extensionName]
    return ext and ext.enabled == true
end

-- Get extension load order
function Config.Extensions:GetLoadOrder()
    local extensions = {}
    for name, config in pairs(self.Available) do
        if config.enabled then
            table.insert(extensions, {
                name = name,
                priority = config.priority or 999,
                dependencies = config.dependencies or {}
            })
        end
    end
    
    -- Sort by priority
    table.sort(extensions, function(a, b)
        return a.priority < b.priority
    end)
    
    return extensions
end

-- Validate extension dependencies
function Config.Extensions:ValidateDependencies(extensionName)
    local ext = self.Available[extensionName]
    if not ext or not ext.dependencies then return true end
    
    for _, dep in ipairs(ext.dependencies) do
        if not self:IsExtensionEnabled(dep) then
            return false, "Missing dependency: " .. dep
        end
    end
    
    return true
end

-- Check for conflicts
function Config.Extensions:CheckConflicts(extensionName)
    local conflicts = self.Dependencies.conflicts[extensionName]
    if not conflicts then return true end
    
    for _, conflict in ipairs(conflicts) do
        if self:IsExtensionEnabled(conflict) then
            return false, "Conflict with: " .. conflict
        end
    end
    
    return true
end

-- ================================
-- VALIDATION
-- ================================

CreateThread(function()
    Wait(500)
    
    if Config.Extensions.Enabled then
        print('[EXTENSIONS] Extension framework enabled')
        
        -- Validate configurations
        local loadOrder = Config.Extensions:GetLoadOrder()
        print('[EXTENSIONS] Extensions to load:', #loadOrder)
        
        for _, ext in ipairs(loadOrder) do
            local valid, error = Config.Extensions:ValidateDependencies(ext.name)
            if not valid then
                print('[EXTENSIONS] Warning: ' .. ext.name .. ' - ' .. error)
            end
            
            local noConflict, conflictError = Config.Extensions:CheckConflicts(ext.name)
            if not noConflict then
                print('[EXTENSIONS] Warning: ' .. ext.name .. ' - ' .. conflictError)
            end
        end
    else
        print('[EXTENSIONS] Extension framework disabled')
    end
end)