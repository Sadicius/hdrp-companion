-- ================================
-- COMPANION COORDINATION SYSTEM v4.7.0
-- Multi-companion coordination and group behavior management
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
        print('[COMPANION-COORDINATION] Performance monitoring integrated')
    end
end)

-- Wait for dependencies
CreateThread(function()
    while not CompanionState or not CompanionAI do
        Wait(100)
    end
    if Config.Debug then
        print('[COMPANION-COORDINATION] Dependencies loaded')
    end
end)

-- Track coordination events
local function TrackCoordinationEvent(eventType, success, executionTime, coordData)
    if PerformanceMonitor and PerformanceMonitor.running then
        PerformanceMonitor:TrackEvent(eventType, success, executionTime)
        
        if executionTime > 40 then -- Coordination should be <40ms
            print('[COMPANION-COORDINATION] Performance warning: ' .. eventType .. ' took ' .. executionTime .. 'ms')
        end
    end
end

-- ================================
-- COORDINATION MANAGER CLASS
-- ================================

local CoordinationManager = {
    -- Configuration
    MAX_COMPANIONS_PER_PLAYER = 3,    -- Server stability limit
    COORDINATION_RADIUS = 50.0,       -- Radius to detect other companions
    UPDATE_INTERVAL = 3000,           -- 3 seconds between coordination updates
    LEADERSHIP_ELECTION_INTERVAL = 10000, -- 10 seconds between leadership checks
    
    -- State tracking
    activeCompanions = {},            -- All active companions in area
    playerCompanions = {},            -- Companions belonging to current player
    nearbyPlayers = {},               -- Other players with companions
    lastUpdate = 0,
    lastLeadershipCheck = 0,
    
    -- Group behavior patterns
    groupBehaviors = {
        independent = 'each companion acts independently',
        follow_formation = 'companions maintain formation while following',
        pack_hunting = 'companions coordinate hunting activities',
        defensive_circle = 'companions form defensive positions',
        exploration_spread = 'companions spread out for exploration'
    }
}

-- ================================
-- COMPANION DETECTION AND TRACKING
-- ================================

function CoordinationManager:ScanForNearbyCompanions()
    local startTime = GetGameTimer()
    local success = false
    local foundCompanions = {}
    
    if not cache.ped then
        TrackCoordinationEvent('companion_scan', false, GetGameTimer() - startTime)
        return foundCompanions
    end
    
    pcall(function()
        local playerCoords = GetEntityCoords(cache.ped)
        local currentPlayerId = GetPlayerServerId(PlayerId())
        
        -- Scan for all peds in radius
        local nearbyPeds = GetGamePool('CPed')
        
        for _, ped in ipairs(nearbyPeds) do
            if DoesEntityExist(ped) and ped ~= cache.ped then
                local distance = #(playerCoords - GetEntityCoords(ped))
                
                if distance <= self.COORDINATION_RADIUS then
                    -- Check if this is a companion (has companion metadata)
                    local pedModel = GetEntityModel(ped)
                    
                    -- Check common companion models (expand as needed)
                    local companionModels = {
                        joaat('a_c_dog_australianshepherd_01'),
                        joaat('a_c_dog_bluetick_01'),
                        joaat('a_c_dog_hound_01'),
                        joaat('a_c_dog_street_01')
                    }
                    
                    for _, companionModel in ipairs(companionModels) do
                        if pedModel == companionModel then
                            -- Try to determine owner
                            local ownerId = self:GetCompanionOwner(ped)
                            
                            table.insert(foundCompanions, {
                                ped = ped,
                                model = pedModel,
                                coords = GetEntityCoords(ped),
                                distance = distance,
                                ownerId = ownerId,
                                isOwnCompanion = (ownerId == currentPlayerId)
                            })
                            break
                        end
                    end
                end
            end
        end
        
        success = true
    end)
    
    local executionTime = GetGameTimer() - startTime
    TrackCoordinationEvent('companion_scan', success, executionTime, { found_count = #foundCompanions })
    
    return foundCompanions
end

function CoordinationManager:GetCompanionOwner(companionPed)
    -- Try to determine companion owner by proximity to players
    local companionCoords = GetEntityCoords(companionPed)
    local closestDistance = math.huge
    local closestPlayerId = nil
    
    for _, playerId in ipairs(GetActivePlayers()) do
        local playerPed = GetPlayerPed(playerId)
        if DoesEntityExist(playerPed) then
            local distance = #(companionCoords - GetEntityCoords(playerPed))
            if distance < closestDistance and distance < 25.0 then -- Max ownership distance
                closestDistance = distance
                closestPlayerId = GetPlayerServerId(playerId)
            end
        end
    end
    
    return closestPlayerId
end

-- ================================
-- GROUP BEHAVIOR COORDINATION
-- ================================

function CoordinationManager:UpdateGroupBehavior()
    local startTime = GetGameTimer()
    local success = false
    
    if not CompanionState or not CompanionState:IsActive() then
        return
    end
    
    pcall(function()
        local playerCompanions = self:GetPlayerCompanions()
        local otherCompanions = self:GetOtherCompanions()
        
        if #playerCompanions == 0 then
            return
        end
        
        -- Update coordination data in CompanionState
        if CompanionState then
            CompanionState:UpdateNearbyCompanions(otherCompanions)
            
            -- Determine if current companion should be leader
            local shouldBeLeader = self:ShouldBeGroupLeader(playerCompanions, otherCompanions)
            CompanionState:SetGroupLeader(shouldBeLeader)
            
            -- Set group behavior based on context and companion count
            local groupBehavior = self:DetermineOptimalGroupBehavior(playerCompanions, otherCompanions)
            CompanionState.ai.coordination.group_behavior = groupBehavior
        end
        
        -- Apply group behavior to companions
        self:ApplyGroupBehavior(playerCompanions, groupBehavior)
        
        success = true
    end)
    
    local executionTime = GetGameTimer() - startTime
    TrackCoordinationEvent('group_behavior_update', success, executionTime)
end

function CoordinationManager:GetPlayerCompanions()
    local companions = {}
    local currentPlayerId = GetPlayerServerId(PlayerId())
    
    for _, companion in ipairs(self.activeCompanions) do
        if companion.isOwnCompanion or companion.ownerId == currentPlayerId then
            table.insert(companions, companion)
        end
    end
    
    return companions
end

function CoordinationManager:GetOtherCompanions()
    local companions = {}
    local currentPlayerId = GetPlayerServerId(PlayerId())
    
    for _, companion in ipairs(self.activeCompanions) do
        if not companion.isOwnCompanion and companion.ownerId ~= currentPlayerId then
            table.insert(companions, companion)
        end
    end
    
    return companions
end

function CoordinationManager:ShouldBeGroupLeader(playerCompanions, otherCompanions)
    -- Leadership criteria:
    -- 1. Have the highest bonding level
    -- 2. Have the most companions
    -- 3. Be the oldest companion in the area
    
    if not CompanionState then return false end
    
    local myBonding = CompanionState:GetBonding()
    local myCompanionCount = #playerCompanions
    
    -- Simple leadership: highest bonding level wins
    -- Note: In real implementation, we'd need server coordination to compare across players
    return myBonding >= 50 and myCompanionCount >= 1
end

function CoordinationManager:DetermineOptimalGroupBehavior(playerCompanions, otherCompanions)
    local totalCompanions = #playerCompanions + #otherCompanions
    local context = CompanionState and CompanionState:GetAIContext()
    
    if not context then
        return 'independent'
    end
    
    -- Behavior selection based on context and companion count
    if context.current_activity == 'combat' then
        if totalCompanions >= 3 then
            return 'defensive_circle'
        else
            return 'follow_formation'
        end
    elseif context.current_activity == 'hunting' then
        if totalCompanions >= 2 then
            return 'pack_hunting'
        else
            return 'independent'
        end
    elseif context.current_activity == 'walking' or context.current_activity == 'running' then
        if totalCompanions >= 2 then
            return 'exploration_spread'
        else
            return 'follow_formation'
        end
    else
        -- Idle or other activities
        if totalCompanions >= 4 then
            return 'defensive_circle'
        elseif totalCompanions >= 2 then
            return 'follow_formation'
        else
            return 'independent'
        end
    end
end

function CoordinationManager:ApplyGroupBehavior(companions, behaviorType)
    if #companions == 0 or not cache.ped then return end
    
    local playerCoords = GetEntityCoords(cache.ped)
    
    for i, companion in ipairs(companions) do
        if DoesEntityExist(companion.ped) then
            if behaviorType == 'follow_formation' then
                self:ApplyFormationBehavior(companion.ped, i, #companions, playerCoords)
                
            elseif behaviorType == 'defensive_circle' then
                self:ApplyDefensiveBehavior(companion.ped, i, #companions, playerCoords)
                
            elseif behaviorType == 'exploration_spread' then
                self:ApplyExplorationBehavior(companion.ped, i, #companions, playerCoords)
                
            elseif behaviorType == 'pack_hunting' then
                self:ApplyHuntingBehavior(companion.ped, i, #companions, playerCoords)
                
            else -- independent
                -- No special coordination, let AI handle individual behavior
            end
        end
    end
end

-- ================================
-- SPECIFIC BEHAVIOR IMPLEMENTATIONS
-- ================================

function CoordinationManager:ApplyFormationBehavior(companionPed, index, totalCompanions, playerCoords)
    -- Arrange companions in a line formation behind the player
    local formationDistance = 4.0
    local spacing = 2.0
    
    local offsetX = (index - 1) * spacing - ((totalCompanions - 1) * spacing / 2)
    local formationCoords = vector3(
        playerCoords.x + offsetX,
        playerCoords.y - formationDistance,
        playerCoords.z
    )
    
    -- Use TaskGoToCoordAnyMeans for formation positioning
    TaskGoToCoordAnyMeans(companionPed, formationCoords.x, formationCoords.y, formationCoords.z, 1.5, 0, false, 0, 0.0)
end

function CoordinationManager:ApplyDefensiveBehavior(companionPed, index, totalCompanions, playerCoords)
    -- Arrange companions in a defensive circle around the player
    local circleRadius = 5.0
    local angle = (index - 1) * (360 / totalCompanions)
    local radians = math.rad(angle)
    
    local defensiveCoords = vector3(
        playerCoords.x + math.cos(radians) * circleRadius,
        playerCoords.y + math.sin(radians) * circleRadius,
        playerCoords.z
    )
    
    TaskGoToCoordAnyMeans(companionPed, defensiveCoords.x, defensiveCoords.y, defensiveCoords.z, 2.0, 0, false, 0, 0.0)
    
    -- Set alert stance for defensive behavior
    SetPedAlertness(companionPed, 3)
end

function CoordinationManager:ApplyExplorationBehavior(companionPed, index, totalCompanions, playerCoords)
    -- Spread companions out for exploration
    local spreadRadius = 15.0
    local angle = (index - 1) * (360 / totalCompanions) + math.random(-30, 30) -- Add some randomness
    local radians = math.rad(angle)
    
    local exploreCoords = vector3(
        playerCoords.x + math.cos(radians) * spreadRadius,
        playerCoords.y + math.sin(radians) * spreadRadius,
        playerCoords.z
    )
    
    TaskGoToCoordAnyMeans(companionPed, exploreCoords.x, exploreCoords.y, exploreCoords.z, 1.0, 0, false, 0, 0.0)
    
    -- Return to formation after exploration
    SetTimeout(math.random(10000, 20000), function()
        if DoesEntityExist(companionPed) then
            self:ApplyFormationBehavior(companionPed, index, totalCompanions, GetEntityCoords(cache.ped))
        end
    end)
end

function CoordinationManager:ApplyHuntingBehavior(companionPed, index, totalCompanions, playerCoords)
    -- Coordinate hunting behavior with other companions
    -- For now, implement as enhanced defensive with hunting stance
    self:ApplyDefensiveBehavior(companionPed, index, totalCompanions, playerCoords)
    
    -- Set hunting stance
    SetPedCombatAttributes(companionPed, 13, true) -- AlwaysFight
end

-- ================================
-- COORDINATION MAIN LOOP
-- ================================

CreateThread(function()
    while true do
        local sleep = 5000 -- Default 5 second sleep
        
        if LocalPlayer.state.isLoggedIn then
            local currentTime = GetGameTimer()
            
            -- Regular coordination updates
            if currentTime - CoordinationManager.lastUpdate >= CoordinationManager.UPDATE_INTERVAL then
                CoordinationManager.activeCompanions = CoordinationManager:ScanForNearbyCompanions()
                CoordinationManager:UpdateGroupBehavior()
                CoordinationManager.lastUpdate = currentTime
                sleep = 1000
            end
            
            -- Leadership checks less frequently
            if currentTime - CoordinationManager.lastLeadershipCheck >= CoordinationManager.LEADERSHIP_ELECTION_INTERVAL then
                local playerCompanions = CoordinationManager:GetPlayerCompanions()
                local otherCompanions = CoordinationManager:GetOtherCompanions()
                
                if #playerCompanions > 0 and CompanionState then
                    local shouldBeLeader = CoordinationManager:ShouldBeGroupLeader(playerCompanions, otherCompanions)
                    CompanionState:SetGroupLeader(shouldBeLeader)
                end
                
                CoordinationManager.lastLeadershipCheck = currentTime
            end
        end
        
        Wait(sleep)
    end
end)

-- ================================
-- EVENT HANDLERS
-- ================================

-- Handle leadership changes
RegisterNetEvent('rsg-companions:client:leadershipChanged', function(isLeader)
    if Config.Debug then
        print('[COMPANION-COORDINATION] Leadership changed: ' .. tostring(isLeader))
    end
    
    if isLeader then
        -- Leader-specific behavior adjustments
        if CompanionState then
            local context = CompanionState:GetAIContext()
            CompanionState:AddMemoryEvent('leadership_gained', {
                context = context,
                timestamp = GetGameTimer()
            })
        end
    end
end)

-- Handle companion spawn/despawn events
RegisterNetEvent('rsg-companions:client:companionSpawned', function()
    -- Force immediate coordination update
    CoordinationManager.lastUpdate = 0
end)

RegisterNetEvent('rsg-companions:client:companionDespawned', function()
    -- Clean up coordination data
    CoordinationManager.activeCompanions = {}
    if CompanionState then
        CompanionState:UpdateNearbyCompanions({})
        CompanionState:SetGroupLeader(false)
    end
end)

-- Manual coordination refresh
RegisterNetEvent('rsg-companions:client:refreshCoordination', function()
    CoordinationManager.lastUpdate = 0
    CoordinationManager.lastLeadershipCheck = 0
end)

-- ================================
-- CLEANUP
-- ================================

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        CoordinationManager.activeCompanions = {}
        CoordinationManager.playerCompanions = {}
        CoordinationManager.nearbyPlayers = {}
    end
end)

-- ================================
-- EXPORTS
-- ================================

-- Export CoordinationManager for other modules
_G.CoordinationManager = CoordinationManager

exports('GetCoordinationManager', function()
    return CoordinationManager
end)

exports('GetNearbyCompanions', function()
    return CoordinationManager.activeCompanions
end)

exports('GetGroupBehavior', function()
    return CompanionState and CompanionState.ai.coordination.group_behavior or 'independent'
end)

exports('ForceCoordinationUpdate', function()
    CoordinationManager.lastUpdate = 0
end)