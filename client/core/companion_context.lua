-- ================================
-- COMPANION CONTEXT ANALYZER v4.7.0
-- Advanced context awareness system for HDRP Companion AI
-- ================================

local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

-- PERFORMANCE MONITORING INTEGRATION
-- Wait for performance system to be available
local PerformanceMonitor = nil
CreateThread(function()
    while not _G.CompanionPerformanceMonitor do
        Wait(100)
    end
    PerformanceMonitor = _G.CompanionPerformanceMonitor
    if Config.Debug then
        print('[COMPANION-CONTEXT] Performance monitoring integrated')
    end
end)

-- Wait for CompanionState to be available
CreateThread(function()
    while not CompanionState do
        Wait(100)
    end
    if Config.Debug then
        print('[COMPANION-CONTEXT] CompanionState integration ready')
    end
end)

-- Helper function to track context analysis events
local function TrackContextEvent(eventType, success, executionTime, contextData)
    if PerformanceMonitor and PerformanceMonitor.running then
        PerformanceMonitor:TrackEvent(eventType, success, executionTime)
        
        -- Enhanced tracking with context data
        if executionTime > 25 then -- Context analysis should be <25ms
            print('[COMPANION-CONTEXT] Performance warning: ' .. eventType .. ' took ' .. executionTime .. 'ms')
        end
    end
end

-- Cache variables for performance optimization
local playerPed = 0
local playerCoords = vector3(0, 0, 0)
local vehicle = 0

-- Update cache when values change
lib.onCache('ped', function(ped)
    playerPed = ped
end)

lib.onCache('coords', function(coords)
    playerCoords = coords
end)

lib.onCache('vehicle', function(veh)
    vehicle = veh or 0
end)

-- ================================
-- CONTEXT ANALYZER CLASS
-- ================================

local ContextAnalyzer = {
    -- Configuration
    UPDATE_INTERVAL = 2000,        -- 2 seconds between full context updates
    QUICK_UPDATE_INTERVAL = 500,   -- 500ms for critical context updates
    PERFORMANCE_CHECK_INTERVAL = 10000, -- 10 seconds between performance checks
    
    -- State tracking
    lastFullUpdate = 0,
    lastQuickUpdate = 0,
    lastPerformanceCheck = 0,
    isAnalyzing = false,
    
    -- Context cache for performance
    cachedContext = {
        activity = 'idle',
        environment = 'wilderness',
        time_of_day = 'day',
        weather = 'clear',
        location_type = 'open_world',
        social_context = 'alone'
    }
}

-- ================================
-- ACTIVITY ANALYSIS
-- ================================

function ContextAnalyzer:AnalyzePlayerActivity()
    local startTime = GetGameTimer()
    local activity = 'idle'
    local success = false
    
    if not DoesEntityExist(playerPed) then
        TrackContextEvent('activity_analysis', false, GetGameTimer() - startTime)
        return activity
    end
    
    pcall(function()
        -- Check if player is in combat
        if GetPedCombatTarget(playerPed) and GetPedCombatTarget(playerPed) ~= 0 then
            activity = 'combat'
        
        -- Check if player is in vehicle
        elseif vehicle and vehicle ~= 0 and IsPedInVehicle(playerPed, vehicle, false) then
            local speed = GetEntitySpeed(vehicle)
            if speed > 5.0 then
                activity = 'traveling_fast'
            elseif speed > 1.0 then
                activity = 'traveling'
            else
                activity = 'in_vehicle'
            end
        
        -- Check if player is moving
        elseif IsPedRunning(playerPed) then
            activity = 'running'
        elseif IsPedWalking(playerPed) then
            activity = 'walking'
        
        -- Check if player is aiming or has weapon drawn
        elseif IsPedAimingFromCover(playerPed) or GetSelectedPedWeapon(playerPed) ~= joaat('WEAPON_UNARMED') then
            activity = 'armed'
        
        -- Check if player is crouching/sneaking
        elseif IsPedDucking(playerPed) then
            activity = 'sneaking'
        
        -- Check if player is interacting with something
        elseif IsPedUsingActionMode(playerPed) then
            activity = 'interacting'
        
        -- Default to idle
        else
            activity = 'idle'
        end
        
        success = true
    end)
    
    local executionTime = GetGameTimer() - startTime
    TrackContextEvent('activity_analysis', success, executionTime, { activity = activity })
    
    return activity
end

-- ================================
-- ENVIRONMENT ANALYSIS
-- ================================

function ContextAnalyzer:AnalyzeEnvironment()
    local startTime = GetGameTimer()
    local environment = 'wilderness'
    local success = false
    
    if not playerCoords or not DoesEntityExist(playerPed) then
        TrackContextEvent('environment_analysis', false, GetGameTimer() - startTime)
        return environment
    end
    
    pcall(function()
        local coords = playerCoords
        local zoneHash = GetHashOfMapAreaAtCoords(coords.x, coords.y, coords.z)
        local zoneName = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
        
        -- Analyze based on zone and surroundings
        if zoneName and string.find(string.lower(zoneName), 'saint denis') then
            environment = 'city'
        elseif zoneName and (string.find(string.lower(zoneName), 'valentine') or 
                           string.find(string.lower(zoneName), 'strawberry') or
                           string.find(string.lower(zoneName), 'rhodes')) then
            environment = 'town'
        elseif IsPositionOccupied(coords.x, coords.y, coords.z, 5.0, false, true, true, false, false, 0, false) then
            environment = 'populated'
        else
            -- Check terrain and vegetation
            local groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, false)
            local waterLevel = GetWaterHeight(coords.x, coords.y, coords.z)
            
            if waterLevel > groundZ - 1.0 then
                environment = 'water'
            elseif coords.z > 500.0 then
                environment = 'mountains'
            elseif GetNumberOfVegetationInArea(coords.x - 10, coords.y - 10, coords.x + 10, coords.y + 10) > 20 then
                environment = 'forest'
            else
                environment = 'wilderness'
            end
        end
        
        success = true
    end)
    
    local executionTime = GetGameTimer() - startTime
    TrackContextEvent('environment_analysis', success, executionTime, { environment = environment })
    
    return environment
end

-- ================================
-- TIME AND WEATHER ANALYSIS
-- ================================

function ContextAnalyzer:AnalyzeTimeOfDay()
    local startTime = GetGameTimer()
    local timeOfDay = 'day'
    local success = false
    
    pcall(function()
        local hour = GetClockHours()
        
        if hour >= 6 and hour < 12 then
            timeOfDay = 'morning'
        elseif hour >= 12 and hour < 18 then
            timeOfDay = 'afternoon'  
        elseif hour >= 18 and hour < 21 then
            timeOfDay = 'evening'
        elseif hour >= 21 or hour < 6 then
            timeOfDay = 'night'
        else
            timeOfDay = 'day'
        end
        
        success = true
    end)
    
    local executionTime = GetGameTimer() - startTime
    TrackContextEvent('time_analysis', success, executionTime, { time_of_day = timeOfDay })
    
    return timeOfDay
end

function ContextAnalyzer:AnalyzeWeather()
    local startTime = GetGameTimer()
    local weather = 'clear'
    local success = false
    
    pcall(function()
        local currentWeather = GetWeatherTypeTransition()
        local rainLevel = GetRainLevel()
        local windSpeed = GetWindSpeed()
        
        if rainLevel > 0.5 then
            weather = 'rainy'
        elseif rainLevel > 0.1 then
            weather = 'drizzle'
        elseif windSpeed > 15.0 then
            weather = 'windy'
        else
            weather = 'clear'
        end
        
        success = true
    end)
    
    local executionTime = GetGameTimer() - startTime
    TrackContextEvent('weather_analysis', success, executionTime, { weather = weather })
    
    return weather
end

-- ================================
-- SOCIAL CONTEXT ANALYSIS
-- ================================

function ContextAnalyzer:AnalyzeSocialContext()
    local startTime = GetGameTimer()
    local socialContext = 'alone'
    local success = false
    
    if not playerCoords or not DoesEntityExist(playerPed) then
        TrackContextEvent('social_analysis', false, GetGameTimer() - startTime)
        return socialContext
    end
    
    pcall(function()
        local nearbyPlayers = 0
        local nearbyNPCs = 0
        local searchRadius = 25.0
        
        -- Check for nearby players
        for _, playerId in ipairs(GetActivePlayers()) do
            local otherPed = GetPlayerPed(playerId)
            if otherPed ~= playerPed and DoesEntityExist(otherPed) then
                local distance = #(playerCoords - GetEntityCoords(otherPed))
                if distance < searchRadius then
                    nearbyPlayers = nearbyPlayers + 1
                end
            end
        end
        
        -- Check for nearby NPCs
        local nearbyPeds = GetGamePool('CPed')
        for _, ped in ipairs(nearbyPeds) do
            if ped ~= playerPed and DoesEntityExist(ped) and not IsPedAPlayer(ped) then
                local distance = #(playerCoords - GetEntityCoords(ped))
                if distance < searchRadius then
                    nearbyNPCs = nearbyNPCs + 1
                end
            end
        end
        
        -- Determine social context
        if nearbyPlayers > 0 and nearbyNPCs > 0 then
            socialContext = 'mixed_crowd'
        elseif nearbyPlayers > 2 then
            socialContext = 'player_group'
        elseif nearbyPlayers > 0 then
            socialContext = 'with_players'
        elseif nearbyNPCs > 5 then
            socialContext = 'crowded'
        elseif nearbyNPCs > 0 then
            socialContext = 'with_npcs'
        else
            socialContext = 'alone'
        end
        
        success = true
    end)
    
    local executionTime = GetGameTimer() - startTime
    TrackContextEvent('social_analysis', success, executionTime, { social_context = socialContext })
    
    return socialContext
end

-- ================================
-- LOCATION TYPE ANALYSIS
-- ================================

function ContextAnalyzer:AnalyzeLocationType()
    local startTime = GetGameTimer()
    local locationType = 'open_world'
    local success = false
    
    if not playerCoords or not DoesEntityExist(playerPed) then
        TrackContextEvent('location_analysis', false, GetGameTimer() - startTime)
        return locationType
    end
    
    pcall(function()
        -- Check if player is indoors
        if HasEntityClearLosToEntity(playerPed, playerPed, 17) then
            -- Check for building/interior
            local interiorId = GetInteriorFromEntity(playerPed)
            if interiorId and interiorId ~= 0 then
                locationType = 'interior'
            else
                -- Check proximity to buildings or structures
                local buildingHash = GetBuildingHashUnderCoords(playerCoords.x, playerCoords.y, playerCoords.z)
                if buildingHash and buildingHash ~= 0 then
                    locationType = 'near_building'
                else
                    locationType = 'open_world'
                end
            end
        else
            locationType = 'covered'
        end
        
        success = true
    end)
    
    local executionTime = GetGameTimer() - startTime
    TrackContextEvent('location_analysis', success, executionTime, { location_type = locationType })
    
    return locationType
end

-- ================================
-- MAIN CONTEXT UPDATE SYSTEM
-- ================================

function ContextAnalyzer:PerformFullContextUpdate()
    if self.isAnalyzing then return end
    
    self.isAnalyzing = true
    local fullStartTime = GetGameTimer()
    
    -- Analyze all context elements
    local newContext = {
        current_activity = self:AnalyzePlayerActivity(),
        environment = self:AnalyzeEnvironment(),
        time_of_day = self:AnalyzeTimeOfDay(),
        weather = self:AnalyzeWeather(),
        location_type = self:AnalyzeLocationType(),
        social_context = self:AnalyzeSocialContext()
    }
    
    -- Update CompanionState if context has changed
    local contextChanged = false
    for key, value in pairs(newContext) do
        if self.cachedContext[key] ~= value then
            contextChanged = true
            self.cachedContext[key] = value
            
            if CompanionState then
                CompanionState:UpdateContext(key, value)
            end
        end
    end
    
    -- Add memory event if significant context change
    if contextChanged and CompanionState then
        CompanionState:AddMemoryEvent('context_change', {
            old_context = self.cachedContext,
            new_context = newContext,
            timestamp = GetGameTimer()
        })
    end
    
    local totalExecutionTime = GetGameTimer() - fullStartTime
    TrackContextEvent('full_context_update', true, totalExecutionTime, newContext)
    
    self.lastFullUpdate = GetGameTimer()
    self.isAnalyzing = false
    
    -- Performance warning if full update takes too long
    if totalExecutionTime > 50 then
        print('[COMPANION-CONTEXT] Performance warning: Full context update took ' .. totalExecutionTime .. 'ms')
    end
end

function ContextAnalyzer:PerformQuickContextUpdate()
    -- Quick update only for critical/fast-changing elements
    local quickStartTime = GetGameTimer()
    
    local activity = self:AnalyzePlayerActivity()
    local timeOfDay = self:AnalyzeTimeOfDay()
    
    -- Update only if changed
    if self.cachedContext.current_activity ~= activity then
        self.cachedContext.current_activity = activity
        if CompanionState then
            CompanionState:SetActivity(activity)
        end
    end
    
    if self.cachedContext.time_of_day ~= timeOfDay then
        self.cachedContext.time_of_day = timeOfDay
        if CompanionState then
            CompanionState:SetTimeOfDay(timeOfDay)
        end
    end
    
    self.lastQuickUpdate = GetGameTimer()
    
    local executionTime = GetGameTimer() - quickStartTime
    TrackContextEvent('quick_context_update', true, executionTime)
end

-- ================================
-- CONTEXT ANALYSIS MAIN LOOP
-- ================================

CreateThread(function()
    while true do
        local sleep = 1000
        
        if LocalPlayer.state.isLoggedIn and CompanionState and CompanionState:IsActive() then
            local currentTime = GetGameTimer()
            
            -- Perform quick updates more frequently
            if currentTime - ContextAnalyzer.lastQuickUpdate >= ContextAnalyzer.QUICK_UPDATE_INTERVAL then
                ContextAnalyzer:PerformQuickContextUpdate()
                sleep = 100
            end
            
            -- Perform full context analysis less frequently
            if currentTime - ContextAnalyzer.lastFullUpdate >= ContextAnalyzer.UPDATE_INTERVAL then
                ContextAnalyzer:PerformFullContextUpdate()
                sleep = 100
            end
            
            -- Performance check
            if currentTime - ContextAnalyzer.lastPerformanceCheck >= ContextAnalyzer.PERFORMANCE_CHECK_INTERVAL then
                if CompanionState then
                    local aiStatus = CompanionState:GetAIHealthStatus()
                    if aiStatus.health == 'warning' or aiStatus.health == 'critical' then
                        print('[COMPANION-CONTEXT] AI Performance warning: ' .. aiStatus.health)
                    end
                end
                ContextAnalyzer.lastPerformanceCheck = currentTime
            end
        end
        
        Wait(sleep)
    end
end)

-- ================================
-- EVENT HANDLERS
-- ================================

-- Handle manual context updates
RegisterNetEvent('rsg-companions:client:updateContext', function(contextType, value)
    if ContextAnalyzer.cachedContext[contextType] ~= nil then
        ContextAnalyzer.cachedContext[contextType] = value
        if CompanionState then
            CompanionState:UpdateContext(contextType, value)
        end
    end
end)

-- Handle forced context refresh
RegisterNetEvent('rsg-companions:client:refreshContext', function()
    ContextAnalyzer:PerformFullContextUpdate()
end)

-- ================================
-- CLEANUP
-- ================================

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        ContextAnalyzer.isAnalyzing = false
        ContextAnalyzer.cachedContext = {}
    end
end)

-- ================================
-- EXPORTS
-- ================================

-- Export ContextAnalyzer for other modules
_G.ContextAnalyzer = ContextAnalyzer

exports('GetContextAnalyzer', function()
    return ContextAnalyzer
end)

exports('GetCurrentContext', function()
    return ContextAnalyzer.cachedContext
end)

exports('ForceContextUpdate', function()
    ContextAnalyzer:PerformFullContextUpdate()
end)