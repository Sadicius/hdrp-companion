-- ================================
-- COMPANION MEMORY SYSTEM v4.7.0
-- Enhanced memory management for persistent learning and adaptation
-- ================================

local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

-- PERFORMANCE MONITORING INTEGRATION
local PerformanceMonitor = nil
CreateThread(function()
    while not _G.CompanionPerformanceMonitor do
        Wait(100)
    end
    PerformanceMonitor = _G.CompanionPerformanceMonitor
    if Config.Debug then
        print('[COMPANION-MEMORY] Performance monitoring integrated')
    end
end)

-- Wait for dependencies
CreateThread(function()
    while not CompanionState do
        Wait(100)
    end
    if Config.Debug then
        print('[COMPANION-MEMORY] CompanionState integration ready')
    end
end)

-- Track memory events
local function TrackMemoryEvent(eventType, success, executionTime, memoryData)
    if PerformanceMonitor and PerformanceMonitor.running then
        PerformanceMonitor:TrackEvent(eventType, success, executionTime)
        
        if executionTime > 30 then -- Memory operations should be <30ms
            print('[COMPANION-MEMORY] Performance warning: ' .. eventType .. ' took ' .. executionTime .. 'ms')
        end
    end
end

-- ================================
-- MEMORY MANAGER CLASS
-- ================================

local MemoryManager = {
    -- Configuration
    MAX_RECENT_EVENTS = 20,           -- Maximum recent events to store
    MAX_LOCATION_MEMORIES = 50,       -- Maximum location familiarity entries
    MAX_PREFERENCE_ENTRIES = 30,      -- Maximum player preference entries
    MEMORY_CLEANUP_INTERVAL = 300000, -- 5 minutes between memory cleanup
    SAVE_INTERVAL = 60000,            -- 1 minute between memory saves
    
    -- Memory categories
    categories = {
        PLAYER_INTERACTION = 'player_interaction',
        LOCATION_EXPERIENCE = 'location_experience',
        COMBAT_EXPERIENCE = 'combat_experience',
        SOCIAL_INTERACTION = 'social_interaction',
        ENVIRONMENTAL_EVENT = 'environmental_event',
        BEHAVIOR_REWARD = 'behavior_reward'
    },
    
    -- State tracking
    lastCleanup = 0,
    lastSave = 0,
    memoryChangesPending = false,
    
    -- Learning patterns
    learningPatterns = {
        location_positive = { -- Player frequents certain locations
            pattern = 'location_visit',
            threshold = 3,
            weight = 0.3
        },
        behavior_reward = { -- Player rewards certain behaviors
            pattern = 'positive_interaction',
            threshold = 5,
            weight = 0.4
        },
        time_preference = { -- Player active at certain times
            pattern = 'time_activity',
            threshold = 4,
            weight = 0.2
        },
        weather_activity = { -- Player behavior in different weather
            pattern = 'weather_context',
            threshold = 3,
            weight = 0.2
        }
    }
}

-- ================================
-- MEMORY OPERATIONS
-- ================================

function MemoryManager:AddMemory(category, data, importance)
    local startTime = GetGameTimer()
    local success = false
    
    if not CompanionState then
        TrackMemoryEvent('add_memory', false, GetGameTimer() - startTime)
        return false
    end
    
    pcall(function()
        importance = importance or 1.0
        local timestamp = GetGameTimer()
        
        local memoryEntry = {
            category = category,
            data = data,
            importance = importance,
            timestamp = timestamp,
            context = CompanionState:GetAIContext(),
            id = self:GenerateMemoryId()
        }
        
        -- Add to recent events (with size limit)
        local recentEvents = CompanionState.ai.memory.recent_events
        if #recentEvents >= self.MAX_RECENT_EVENTS then
            table.remove(recentEvents, 1) -- Remove oldest
        end
        table.insert(recentEvents, memoryEntry)
        
        -- Process for long-term associations
        self:ProcessForLongTermMemory(memoryEntry)
        
        -- Update player preferences if applicable
        if category == self.categories.PLAYER_INTERACTION or category == self.categories.BEHAVIOR_REWARD then
            self:UpdatePlayerPreferences(memoryEntry)
        end
        
        -- Update location familiarity if applicable
        if category == self.categories.LOCATION_EXPERIENCE then
            self:UpdateLocationFamiliarity(memoryEntry)
        end
        
        self.memoryChangesPending = true
        success = true
    end)
    
    local executionTime = GetGameTimer() - startTime
    TrackMemoryEvent('add_memory', success, executionTime, { category = category })
    
    return success
end

function MemoryManager:GenerateMemoryId()
    return tostring(GetGameTimer()) .. '_' .. tostring(math.random(1000, 9999))
end

function MemoryManager:ProcessForLongTermMemory(memoryEntry)
    if not CompanionState then return end
    
    local longTermMemory = CompanionState.ai.memory.long_term_associations
    local category = memoryEntry.category
    local importance = memoryEntry.importance
    
    -- Only promote to long-term if importance is high enough
    if importance >= 0.7 then
        local associationKey = category .. '_' .. (memoryEntry.context.current_activity or 'unknown')
        
        if not longTermMemory[associationKey] then
            longTermMemory[associationKey] = {
                count = 0,
                total_importance = 0,
                average_importance = 0,
                first_occurrence = memoryEntry.timestamp,
                last_occurrence = memoryEntry.timestamp,
                contexts = {}
            }
        end
        
        local association = longTermMemory[associationKey]
        association.count = association.count + 1
        association.total_importance = association.total_importance + importance
        association.average_importance = association.total_importance / association.count
        association.last_occurrence = memoryEntry.timestamp
        
        -- Store context data for pattern recognition
        local contextKey = memoryEntry.context.environment .. '_' .. memoryEntry.context.time_of_day
        association.contexts[contextKey] = (association.contexts[contextKey] or 0) + 1
    end
end

function MemoryManager:UpdatePlayerPreferences(memoryEntry)
    if not CompanionState then return end
    
    local preferences = CompanionState.ai.memory.player_preferences
    local data = memoryEntry.data
    
    -- Track player activity preferences
    if data.player_activity then
        local activity = data.player_activity
        if not preferences.activities then preferences.activities = {} end
        
        preferences.activities[activity] = (preferences.activities[activity] or 0) + memoryEntry.importance
    end
    
    -- Track preferred companion behaviors
    if data.companion_behavior then
        local behavior = data.companion_behavior
        if not preferences.behaviors then preferences.behaviors = {} end
        
        preferences.behaviors[behavior] = (preferences.behaviors[behavior] or 0) + memoryEntry.importance
    end
    
    -- Track time preferences
    if memoryEntry.context.time_of_day then
        local timeOfDay = memoryEntry.context.time_of_day
        if not preferences.time_preferences then preferences.time_preferences = {} end
        
        preferences.time_preferences[timeOfDay] = (preferences.time_preferences[timeOfDay] or 0) + memoryEntry.importance
    end
    
    -- Track environmental preferences
    if memoryEntry.context.environment then
        local environment = memoryEntry.context.environment
        if not preferences.environments then preferences.environments = {} end
        
        preferences.environments[environment] = (preferences.environments[environment] or 0) + memoryEntry.importance
    end
    
    -- Cleanup preferences if too many entries
    self:CleanupPreferences()
end

function MemoryManager:UpdateLocationFamiliarity(memoryEntry)
    if not CompanionState then return end
    
    local locationMemory = CompanionState.ai.memory.location_familiarity
    local data = memoryEntry.data
    
    if data.location then
        local location = data.location
        local familiarityKey = tostring(math.floor(location.x / 100)) .. '_' .. tostring(math.floor(location.y / 100))
        
        if not locationMemory[familiarityKey] then
            locationMemory[familiarityKey] = {
                visit_count = 0,
                total_time = 0,
                positive_experiences = 0,
                negative_experiences = 0,
                first_visit = memoryEntry.timestamp,
                last_visit = memoryEntry.timestamp,
                familiarity_score = 0
            }
        end
        
        local memory = locationMemory[familiarityKey]
        memory.visit_count = memory.visit_count + 1
        memory.last_visit = memoryEntry.timestamp
        
        -- Update experience based on importance
        if memoryEntry.importance > 0.6 then
            memory.positive_experiences = memory.positive_experiences + 1
        elseif memoryEntry.importance < 0.3 then
            memory.negative_experiences = memory.negative_experiences + 1
        end
        
        -- Calculate familiarity score (0-1)
        local visitWeight = math.min(memory.visit_count / 10, 1.0)
        local experienceWeight = (memory.positive_experiences - memory.negative_experiences) / 
                                math.max(memory.positive_experiences + memory.negative_experiences, 1)
        memory.familiarity_score = (visitWeight * 0.7) + (experienceWeight * 0.3)
        
        -- Cleanup if too many location entries
        if self:CountTableEntries(locationMemory) > self.MAX_LOCATION_MEMORIES then
            self:CleanupLocationMemories()
        end
    end
end

-- ================================
-- MEMORY RETRIEVAL AND ANALYSIS
-- ================================

function MemoryManager:GetRelevantMemories(category, contextFilter, limit)
    local startTime = GetGameTimer()
    local success = false
    local relevantMemories = {}
    
    if not CompanionState then
        TrackMemoryEvent('retrieve_memories', false, GetGameTimer() - startTime)
        return relevantMemories
    end
    
    pcall(function()
        limit = limit or 10
        local recentEvents = CompanionState.ai.memory.recent_events
        
        for _, memory in ipairs(recentEvents) do
            local isRelevant = true
            
            -- Filter by category
            if category and memory.category ~= category then
                isRelevant = false
            end
            
            -- Filter by context if provided
            if contextFilter and isRelevant then
                for key, value in pairs(contextFilter) do
                    if memory.context[key] ~= value then
                        isRelevant = false
                        break
                    end
                end
            end
            
            if isRelevant then
                table.insert(relevantMemories, memory)
            end
            
            -- Respect limit
            if #relevantMemories >= limit then
                break
            end
        end
        
        -- Sort by importance and recency
        table.sort(relevantMemories, function(a, b)
            local aScore = a.importance + (a.timestamp / 1000000) -- Weight recent memories slightly
            local bScore = b.importance + (b.timestamp / 1000000)
            return aScore > bScore
        end)
        
        success = true
    end)
    
    local executionTime = GetGameTimer() - startTime
    TrackMemoryEvent('retrieve_memories', success, executionTime, { 
        category = category, 
        found_count = #relevantMemories 
    })
    
    return relevantMemories
end

function MemoryManager:GetLocationFamiliarity(location)
    if not CompanionState or not location then return 0 end
    
    local locationMemory = CompanionState.ai.memory.location_familiarity
    local familiarityKey = tostring(math.floor(location.x / 100)) .. '_' .. tostring(math.floor(location.y / 100))
    
    local memory = locationMemory[familiarityKey]
    return memory and memory.familiarity_score or 0
end

function MemoryManager:GetPlayerPreference(preferenceType, key)
    if not CompanionState then return 0 end
    
    local preferences = CompanionState.ai.memory.player_preferences
    if not preferences[preferenceType] then return 0 end
    
    return preferences[preferenceType][key] or 0
end

function MemoryManager:AnalyzeMemoryPatterns()
    local startTime = GetGameTimer()
    local success = false
    local patterns = {}
    
    if not CompanionState then
        TrackMemoryEvent('analyze_patterns', false, GetGameTimer() - startTime)
        return patterns
    end
    
    pcall(function()
        -- Analyze player behavior patterns
        local preferences = CompanionState.ai.memory.player_preferences
        
        -- Find most preferred activities
        if preferences.activities then
            local topActivity = nil
            local topScore = 0
            for activity, score in pairs(preferences.activities) do
                if score > topScore then
                    topScore = score
                    topActivity = activity
                end
            end
            if topActivity then
                patterns.preferred_activity = { activity = topActivity, score = topScore }
            end
        end
        
        -- Find most preferred time of day
        if preferences.time_preferences then
            local topTime = nil
            local topScore = 0
            for time, score in pairs(preferences.time_preferences) do
                if score > topScore then
                    topScore = score
                    topTime = time
                end
            end
            if topTime then
                patterns.preferred_time = { time = topTime, score = topScore }
            end
        end
        
        -- Find most familiar location type
        if preferences.environments then
            local topEnv = nil
            local topScore = 0
            for env, score in pairs(preferences.environments) do
                if score > topScore then
                    topScore = score
                    topEnv = env
                end
            end
            if topEnv then
                patterns.preferred_environment = { environment = topEnv, score = topScore }
            end
        end
        
        success = true
    end)
    
    local executionTime = GetGameTimer() - startTime
    TrackMemoryEvent('analyze_patterns', success, executionTime)
    
    return patterns
end

-- ================================
-- MEMORY CLEANUP AND MAINTENANCE
-- ================================

function MemoryManager:CleanupMemory()
    local startTime = GetGameTimer()
    local success = false
    
    if not CompanionState then
        TrackMemoryEvent('cleanup_memory', false, GetGameTimer() - startTime)
        return
    end
    
    pcall(function()
        -- Clean up old recent events (keep only last 24 hours worth)
        local currentTime = GetGameTimer()
        local oneDayAgo = currentTime - (24 * 60 * 60 * 1000)
        
        local recentEvents = CompanionState.ai.memory.recent_events
        local filteredEvents = {}
        
        for _, event in ipairs(recentEvents) do
            if event.timestamp > oneDayAgo then
                table.insert(filteredEvents, event)
            end
        end
        
        CompanionState.ai.memory.recent_events = filteredEvents
        
        -- Clean up low-importance long-term associations
        self:CleanupLongTermMemory()
        
        success = true
    end)
    
    local executionTime = GetGameTimer() - startTime
    TrackMemoryEvent('cleanup_memory', success, executionTime)
    
    self.lastCleanup = GetGameTimer()
end

function MemoryManager:CleanupLongTermMemory()
    if not CompanionState then return end
    
    local longTermMemory = CompanionState.ai.memory.long_term_associations
    local keysToRemove = {}
    
    for key, association in pairs(longTermMemory) do
        -- Remove associations with very low importance or very old
        if association.average_importance < 0.3 or association.count < 2 then
            table.insert(keysToRemove, key)
        end
    end
    
    for _, key in ipairs(keysToRemove) do
        longTermMemory[key] = nil
    end
end

function MemoryManager:CleanupPreferences()
    if not CompanionState then return end
    
    local preferences = CompanionState.ai.memory.player_preferences
    
    -- Keep only top entries in each category
    for category, entries in pairs(preferences) do
        if self:CountTableEntries(entries) > self.MAX_PREFERENCE_ENTRIES then
            -- Convert to array and sort by value
            local sortedEntries = {}
            for key, value in pairs(entries) do
                table.insert(sortedEntries, { key = key, value = value })
            end
            
            table.sort(sortedEntries, function(a, b) return a.value > b.value end)
            
            -- Keep only top entries
            local newEntries = {}
            for i = 1, math.min(#sortedEntries, self.MAX_PREFERENCE_ENTRIES) do
                newEntries[sortedEntries[i].key] = sortedEntries[i].value
            end
            
            preferences[category] = newEntries
        end
    end
end

function MemoryManager:CleanupLocationMemories()
    if not CompanionState then return end
    
    local locationMemory = CompanionState.ai.memory.location_familiarity
    local locations = {}
    
    -- Convert to array for sorting
    for key, memory in pairs(locationMemory) do
        table.insert(locations, { key = key, memory = memory })
    end
    
    -- Sort by familiarity score and visit count
    table.sort(locations, function(a, b)
        local aScore = a.memory.familiarity_score + (a.memory.visit_count / 100)
        local bScore = b.memory.familiarity_score + (b.memory.visit_count / 100)
        return aScore > bScore
    end)
    
    -- Keep only top locations
    local newLocationMemory = {}
    for i = 1, math.min(#locations, self.MAX_LOCATION_MEMORIES) do
        newLocationMemory[locations[i].key] = locations[i].memory
    end
    
    CompanionState.ai.memory.location_familiarity = newLocationMemory
end

function MemoryManager:CountTableEntries(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

-- ================================
-- MEMORY PERSISTENCE (SERVER INTEGRATION)
-- ================================

function MemoryManager:SaveMemoryToServer()
    if not self.memoryChangesPending or not CompanionState then return end
    
    local memoryData = {
        player_preferences = CompanionState.ai.memory.player_preferences,
        location_familiarity = CompanionState.ai.memory.location_familiarity,
        long_term_associations = CompanionState.ai.memory.long_term_associations
    }
    
    -- Trigger server event to save memory
    TriggerServerEvent('rsg-companions:server:saveMemory', memoryData)
    
    self.memoryChangesPending = false
    self.lastSave = GetGameTimer()
end

function MemoryManager:LoadMemoryFromServer()
    -- Request memory data from server
    TriggerServerEvent('rsg-companions:server:requestMemory')
end

-- ================================
-- MEMORY MAIN LOOP
-- ================================

CreateThread(function()
    while true do
        local sleep = 30000 -- 30 seconds default
        
        if LocalPlayer.state.isLoggedIn and CompanionState then
            local currentTime = GetGameTimer()
            
            -- Memory cleanup
            if currentTime - MemoryManager.lastCleanup >= MemoryManager.MEMORY_CLEANUP_INTERVAL then
                MemoryManager:CleanupMemory()
                sleep = 5000
            end
            
            -- Memory saving
            if currentTime - MemoryManager.lastSave >= MemoryManager.SAVE_INTERVAL then
                MemoryManager:SaveMemoryToServer()
                sleep = 5000
            end
        end
        
        Wait(sleep)
    end
end)

-- ================================
-- EVENT HANDLERS
-- ================================

-- Handle memory loading from server
RegisterNetEvent('rsg-companions:client:receiveMemory', function(memoryData)
    if not CompanionState or not memoryData then return end
    
    CompanionState.ai.memory.player_preferences = memoryData.player_preferences or {}
    CompanionState.ai.memory.location_familiarity = memoryData.location_familiarity or {}
    CompanionState.ai.memory.long_term_associations = memoryData.long_term_associations or {}
    
    if Config.Debug then
        print('[COMPANION-MEMORY] Memory data loaded from server')
    end
end)

-- Handle companion spawn - load memory
RegisterNetEvent('rsg-companions:client:companionSpawned', function()
    MemoryManager:LoadMemoryFromServer()
end)

-- Handle companion despawn - save memory
RegisterNetEvent('rsg-companions:client:companionDespawned', function()
    MemoryManager:SaveMemoryToServer()
end)

-- Auto-add memory for various events
RegisterNetEvent('rsg-companions:client:statsUpdated', function(stat, value)
    if value > 80 then -- High stat values indicate positive experiences
        MemoryManager:AddMemory(MemoryManager.categories.BEHAVIOR_REWARD, {
            stat_type = stat,
            stat_value = value,
            companion_behavior = CompanionAI and CompanionAI.currentBehavior or 'unknown'
        }, 0.7)
    end
end)

RegisterNetEvent('rsg-companions:client:levelUp', function(oldLevel, newLevel)
    MemoryManager:AddMemory(MemoryManager.categories.BEHAVIOR_REWARD, {
        event_type = 'level_up',
        old_level = oldLevel,
        new_level = newLevel
    }, 0.9) -- Level ups are very important
end)

-- ================================
-- CLEANUP
-- ================================

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        MemoryManager:SaveMemoryToServer()
    end
end)

-- ================================
-- EXPORTS
-- ================================

-- Export MemoryManager for other modules
_G.MemoryManager = MemoryManager

exports('GetMemoryManager', function()
    return MemoryManager
end)

exports('AddMemory', function(category, data, importance)
    return MemoryManager:AddMemory(category, data, importance)
end)

exports('GetRelevantMemories', function(category, contextFilter, limit)
    return MemoryManager:GetRelevantMemories(category, contextFilter, limit)
end)

exports('GetMemoryPatterns', function()
    return MemoryManager:AnalyzeMemoryPatterns()
end)