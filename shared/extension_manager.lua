-- ================================
-- EXTENSION MANAGER
-- Independent extension management system
-- ================================

local RSGCore = exports['rsg-core']:GetCoreObject()

-- ================================
-- EXTENSION MANAGER CLASS
-- ================================

ExtensionManager = {
    -- State
    loadedExtensions = {},
    failedExtensions = {},
    extensionConfigs = {},
    isInitialized = false,
    
    -- Runtime data
    loadStartTime = 0,
    totalLoadTime = 0,
    loadStats = {}
}

-- ================================
-- INITIALIZATION
-- ================================

function ExtensionManager:Initialize()
    if self.isInitialized then 
        return true, "Already initialized" 
    end
    
    if not Config.Extensions or not Config.Extensions.Enabled then
        print('[EXTENSION-MANAGER] Extension system disabled')
        return false, "Extensions disabled in config"
    end
    
    print('[EXTENSION-MANAGER] Initializing extension system...')
    self.loadStartTime = GetGameTimer()
    
    -- Load extensions in order
    local success = self:LoadExtensions()
    
    self.totalLoadTime = GetGameTimer() - self.loadStartTime
    self.isInitialized = success
    
    if success then
        print(string.format('[EXTENSION-MANAGER] ✅ Extension system initialized (%dms)', self.totalLoadTime))
        self:PrintLoadStats()
    else
        print('[EXTENSION-MANAGER] ❌ Extension system failed to initialize')
    end
    
    return success
end

-- ================================
-- EXTENSION LOADING
-- ================================

function ExtensionManager:LoadExtensions()
    local loadOrder = Config.Extensions:GetLoadOrder()
    local loadedCount = 0
    local failedCount = 0
    
    print(string.format('[EXTENSION-MANAGER] Loading %d extensions...', #loadOrder))
    
    for _, extensionInfo in ipairs(loadOrder) do
        local startTime = GetGameTimer()
        local success, error = self:LoadExtension(extensionInfo.name)
        local loadTime = GetGameTimer() - startTime
        
        -- Store load stats
        self.loadStats[extensionInfo.name] = {
            success = success,
            loadTime = loadTime,
            error = error
        }
        
        if success then
            loadedCount = loadedCount + 1
            print(string.format('[EXTENSION-MANAGER] ✅ %s loaded (%dms)', extensionInfo.name, loadTime))
        else
            failedCount = failedCount + 1
            print(string.format('[EXTENSION-MANAGER] ❌ %s failed: %s', extensionInfo.name, error or 'Unknown error'))
            
            if not Config.Extensions.Runtime.ErrorHandling.ContinueOnError then
                return false
            end
        end
    end
    
    print(string.format('[EXTENSION-MANAGER] Load complete: %d successful, %d failed', loadedCount, failedCount))
    return failedCount == 0 or Config.Extensions.Runtime.ErrorHandling.ContinueOnError
end

function ExtensionManager:LoadExtension(extensionName)
    if self.loadedExtensions[extensionName] then
        return false, "Already loaded"
    end
    
    -- Get extension config
    local extensionConfig = Config.Extensions.Available[extensionName]
    if not extensionConfig then
        return false, "Extension not found in config"
    end
    
    -- Validate dependencies
    local valid, error = Config.Extensions:ValidateDependencies(extensionName)
    if not valid then
        return false, error
    end
    
    -- Check conflicts
    local noConflict, conflictError = Config.Extensions:CheckConflicts(extensionName)
    if not noConflict then
        return false, conflictError
    end
    
    -- Try to load extension files
    local success = self:LoadExtensionFiles(extensionName, extensionConfig)
    if not success then
        return false, "Failed to load extension files"
    end
    
    -- Initialize extension
    success = self:InitializeExtension(extensionName, extensionConfig)
    if not success then
        return false, "Failed to initialize extension"
    end
    
    -- Mark as loaded
    self.loadedExtensions[extensionName] = {
        config = extensionConfig,
        loadTime = GetGameTimer()
    }
    
    -- Store extension config for runtime access
    self.extensionConfigs[extensionName] = extensionConfig.config or {}
    
    -- Trigger load event
    TriggerEvent(Config.Extensions.Runtime.Events.OnExtensionLoad, extensionName, extensionConfig)
    
    return true
end

function ExtensionManager:LoadExtensionFiles(extensionName, extensionConfig)
    -- This is a placeholder for file loading logic
    -- In a real implementation, this would:
    -- 1. Check if extension files exist
    -- 2. Load Lua files based on client/server context
    -- 3. Validate file syntax
    -- 4. Handle any file-specific configuration
    
    if Config.Extensions.Development.Debug.Enabled then
        print(string.format('[EXTENSION-MANAGER] Loading files for %s', extensionName))
    end
    
    -- For now, we'll simulate successful file loading
    -- Real implementation would load actual files from extension directories
    return true
end

function ExtensionManager:InitializeExtension(extensionName, extensionConfig)
    -- This is where individual extensions would be initialized
    -- Each extension should provide an Initialize function
    
    -- Try to call extension-specific initialization
    local extensionInitFunction = _G[extensionName .. '_Initialize']
    if extensionInitFunction and type(extensionInitFunction) == 'function' then
        local success, error = pcall(extensionInitFunction, extensionConfig.config or {})
        if not success then
            return false, error
        end
    end
    
    return true
end

-- ================================
-- EXTENSION MANAGEMENT
-- ================================

function ExtensionManager:IsExtensionLoaded(extensionName)
    return self.loadedExtensions[extensionName] ~= nil
end

function ExtensionManager:GetExtensionConfig(extensionName)
    return self.extensionConfigs[extensionName] or {}
end

function ExtensionManager:GetLoadedExtensions()
    local extensions = {}
    for name, _ in pairs(self.loadedExtensions) do
        table.insert(extensions, name)
    end
    return extensions
end

function ExtensionManager:UnloadExtension(extensionName)
    if not self.loadedExtensions[extensionName] then
        return false, "Extension not loaded"
    end
    
    -- Try to call extension-specific cleanup
    local extensionCleanupFunction = _G[extensionName .. '_Cleanup']
    if extensionCleanupFunction and type(extensionCleanupFunction) == 'function' then
        pcall(extensionCleanupFunction)
    end
    
    -- Remove from loaded extensions
    self.loadedExtensions[extensionName] = nil
    self.extensionConfigs[extensionName] = nil
    
    -- Trigger unload event
    TriggerEvent(Config.Extensions.Runtime.Events.OnExtensionUnload, extensionName)
    
    return true
end

function ExtensionManager:ReloadExtension(extensionName)
    if self.loadedExtensions[extensionName] then
        self:UnloadExtension(extensionName)
    end
    
    local success, error = self:LoadExtension(extensionName)
    
    if success then
        TriggerEvent(Config.Extensions.Runtime.Events.OnExtensionReload, extensionName)
    end
    
    return success, error
end

-- ================================
-- UTILITY FUNCTIONS
-- ================================

function ExtensionManager:PrintLoadStats()
    if not Config.Extensions.Development.Debug.LoadTiming then return end
    
    print('[EXTENSION-MANAGER] Load Statistics:')
    print('=====================================')
    
    for extensionName, stats in pairs(self.loadStats) do
        local status = stats.success and "✅" or "❌"
        local timeInfo = stats.success and string.format("(%dms)", stats.loadTime) or ""
        local errorInfo = stats.error and string.format(" - %s", stats.error) or ""
        
        print(string.format("%s %s %s%s", status, extensionName, timeInfo, errorInfo))
    end
    
    print('=====================================')
    print(string.format('Total load time: %dms', self.totalLoadTime))
end

function ExtensionManager:GetExtensionInfo(extensionName)
    local loaded = self.loadedExtensions[extensionName]
    if not loaded then return nil end
    
    return {
        name = extensionName,
        loaded = true,
        loadTime = loaded.loadTime,
        config = loaded.config,
        stats = self.loadStats[extensionName]
    }
end

function ExtensionManager:ValidateAllExtensions()
    local results = {}
    
    for extensionName, _ in pairs(Config.Extensions.Available) do
        local valid, error = Config.Extensions:ValidateDependencies(extensionName)
        local noConflict, conflictError = Config.Extensions:CheckConflicts(extensionName)
        
        results[extensionName] = {
            dependenciesValid = valid,
            dependencyError = error,
            noConflicts = noConflict,
            conflictError = conflictError,
            overall = valid and noConflict
        }
    end
    
    return results
end

-- ================================
-- EXPORTS FOR EXTERNAL ACCESS
-- ================================

-- Export key functions for other scripts to use
exports('GetExtensionManager', function()
    return ExtensionManager
end)

exports('IsExtensionLoaded', function(extensionName)
    return ExtensionManager:IsExtensionLoaded(extensionName)
end)

exports('GetExtensionConfig', function(extensionName)
    return ExtensionManager:GetExtensionConfig(extensionName)
end)

-- ================================
-- EVENTS
-- ================================

-- Handle extension-related events
RegisterNetEvent('hdrp:extension:reload', function(extensionName)
    if not extensionName then return end
    
    local success, error = ExtensionManager:ReloadExtension(extensionName)
    if success then
        print(string.format('[EXTENSION-MANAGER] Extension %s reloaded successfully', extensionName))
    else
        print(string.format('[EXTENSION-MANAGER] Failed to reload %s: %s', extensionName, error or 'Unknown error'))
    end
end)

RegisterNetEvent('hdrp:extension:status', function()
    local loaded = ExtensionManager:GetLoadedExtensions()
    print('[EXTENSION-MANAGER] Loaded extensions:')
    for _, name in ipairs(loaded) do
        local info = ExtensionManager:GetExtensionInfo(name)
        print(string.format('  - %s (loaded at %d)', name, info.loadTime))
    end
end)

-- ================================
-- AUTO-INITIALIZATION
-- ================================

-- Initialize extension manager when config is loaded
CreateThread(function()
    -- Wait for config to be fully loaded
    Wait(1000)
    
    if Config and Config.Extensions then
        ExtensionManager:Initialize()
    else
        print('[EXTENSION-MANAGER] Config not available, extension system disabled')
    end
end)