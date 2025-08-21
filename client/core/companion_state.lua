-- ================================
-- COMPANION STATE MANAGER
-- Gestión centralizada del estado siguiendo principios RSGCore
-- ================================

local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

-- ================================
-- ESTADO CENTRALIZADO
-- ================================

local CompanionState = {
    -- Estado del compañero
    spawned = false,
    called = false,
    ped = 0,
    data = {},

    -- Estadísticas
    stats = {
        xp = 0,
        bonding = 0,
        level = 0,
        stamina = 0,
        health = 0,
        hunger = 0,
        thirst = 0,
        happiness = 0
    },

    -- Modo de comportamiento
    behavior = {
        huntMode = false,
        retrieving = false,
        retrieved = true,
        recentCombat = 0
    },

    -- UI y navegación
    ui = {
        blip = nil,
        gpsRoute = nil,
        timeout = false,
        timeoutTimer = 30
    },

    -- Objetos y entidades
    objects = {
        retrievedEntities = {},
        fetchedObj = nil,
        itemProps = {}
    },

    -- Prompts del sistema
    prompts = {
        main = nil,
        flee = nil,
        actions = nil,
        hunt = nil,
        saddleBag = nil,
        track = {},
        attack = {},
        huntAnimals = {},
        searchDatabase = {}
    },

    -- Estado del establo
    stable = {
        closest = nil,
        gender = nil
    },

    -- ================================
    -- ENHANCED AI SYSTEM v4.7.0
    -- ================================
    
    -- Context awareness system
    ai = {
        -- Context awareness
        context = {
            current_activity = 'idle',        -- player's current activity
            environment = 'wilderness',       -- current environment type
            time_of_day = 'day',              -- day/night/dawn/dusk
            weather = 'clear',                -- weather conditions
            location_type = 'open_world',     -- town/wilderness/building/etc
            social_context = 'alone',         -- alone/with_players/with_npcs
            last_update = 0                   -- performance tracking
        },
        
        -- Decision making system
        decision_tree = {
            last_decision = 0,
            decision_history = {},             -- track recent decisions (max 10)
            context_weights = {               -- how much each context affects decisions
                activity = 0.4,
                environment = 0.3,
                bonding = 0.2,
                stats = 0.1
            },
            performance = {
                decision_count = 0,
                avg_response_time = 0,
                last_performance_check = 0
            }
        },
        
        -- Enhanced memory system
        memory = {
            player_preferences = {},          -- learned player behavior patterns
            location_familiarity = {},        -- familiarity with different areas
            recent_events = {},               -- short-term memory (max 20 events)
            long_term_associations = {},      -- long-term learned associations
            session_start = 0                 -- track session for memory persistence
        },
        
        -- Multi-companion coordination
        coordination = {
            nearby_companions = {},           -- other active companions in area
            group_behavior = 'independent',   -- group behavior mode
            leader_companion = false,         -- is this the lead companion
            coordination_state = 'idle',      -- current coordination activity
            last_coordination_update = 0     -- performance tracking
        }
    }
}

-- ================================
-- GETTERS PÚBLICOS
-- ================================

function CompanionState:IsActive()
    return self.spawned and DoesEntityExist(self.ped)
end

function CompanionState:GetPed()
    return self.ped
end

function CompanionState:GetData()
    return self.data
end

function CompanionState:GetStats()
    return self.stats
end

function CompanionState:GetLevel()
    return self.level or 1
end

function CompanionState:GetXP()
    return self.stats.xp or 0
end

function CompanionState:GetBonding()
    return self.stats.bonding or 0
end

-- ================================
-- ENHANCED AI GETTERS v4.7.0
-- ================================

function CompanionState:GetAIContext()
    return self.ai.context
end

function CompanionState:GetAIDecisionTree()
    return self.ai.decision_tree
end

function CompanionState:GetAIMemory()
    return self.ai.memory
end

function CompanionState:GetAICoordination()
    return self.ai.coordination
end

function CompanionState:GetCurrentActivity()
    return self.ai.context.current_activity or 'idle'
end

function CompanionState:GetEnvironment()
    return self.ai.context.environment or 'wilderness'
end

function CompanionState:GetTimeOfDay()
    return self.ai.context.time_of_day or 'day'
end

function CompanionState:IsGroupLeader()
    return self.ai.coordination.leader_companion
end

-- ================================
-- SETTERS PÚBLICOS
-- ================================

function CompanionState:SetPed(ped)
    self.ped = ped or 0
    self.spawned = DoesEntityExist(ped)
end

function CompanionState:SetData(data)
    if not data then return end

    self.data = data

    -- Actualizar stats desde data
    if data.companiondata then
        local companionData = json.decode(data.companiondata) or {}

        self.stats.xp = companionData.xp or 0
        self.stats.bonding = companionData.bonding or 0
        self.stats.health = companionData.health or Config.PetAttributes.Starting.Health
        self.stats.hunger = companionData.hunger or Config.PetAttributes.Starting.Hunger
        self.stats.thirst = companionData.thirst or Config.PetAttributes.Starting.Thirst
        self.stats.happiness = companionData.happines or Config.PetAttributes.Starting.Happines

        -- Calcular nivel basado en XP
        self:CalculateLevel()
    end
end

function CompanionState:UpdateStat(stat, value)
    if self.stats[stat] ~= nil then
        self.stats[stat] = math.max(0, math.min(100, value))

        -- Trigger update event
        TriggerEvent('rsg-companions:client:statsUpdated', stat, self.stats[stat])
    end
end

function CompanionState:AddXP(amount)
    local oldLevel = self:GetLevel()
    self.stats.xp = (self.stats.xp or 0) + amount

    self:CalculateLevel()

    -- Check level up
    if self:GetLevel() > oldLevel then
        TriggerEvent('rsg-companions:client:levelUp', oldLevel, self:GetLevel())
    end
end

-- ================================
-- ENHANCED AI SETTERS v4.7.0
-- ================================

function CompanionState:UpdateContext(contextType, value)
    if self.ai.context[contextType] ~= nil then
        self.ai.context[contextType] = value
        self.ai.context.last_update = GetGameTimer()
        
        -- Trigger context change event for AI decision making
        TriggerEvent('rsg-companions:client:contextChanged', contextType, value)
    end
end

function CompanionState:SetActivity(activity)
    self:UpdateContext('current_activity', activity)
end

function CompanionState:SetEnvironment(environment)
    self:UpdateContext('environment', environment)
end

function CompanionState:SetTimeOfDay(timeOfDay)
    self:UpdateContext('time_of_day', timeOfDay)
end

function CompanionState:SetWeather(weather)
    self:UpdateContext('weather', weather)
end

function CompanionState:SetSocialContext(socialContext)
    self:UpdateContext('social_context', socialContext)
end

function CompanionState:AddDecisionToHistory(decisionType, context, executionTime)
    -- Maintain max 10 decisions in history for performance
    if #self.ai.decision_tree.decision_history >= 10 then
        table.remove(self.ai.decision_tree.decision_history, 1)
    end
    
    table.insert(self.ai.decision_tree.decision_history, {
        type = decisionType,
        context = context,
        timestamp = GetGameTimer(),
        execution_time = executionTime
    })
    
    -- Update performance metrics
    self.ai.decision_tree.performance.decision_count = self.ai.decision_tree.performance.decision_count + 1
    local currentAvg = self.ai.decision_tree.performance.avg_response_time
    local newAvg = ((currentAvg * (self.ai.decision_tree.performance.decision_count - 1)) + executionTime) / self.ai.decision_tree.performance.decision_count
    self.ai.decision_tree.performance.avg_response_time = newAvg
end

function CompanionState:AddMemoryEvent(eventType, eventData)
    -- Maintain max 20 recent events for performance
    if #self.ai.memory.recent_events >= 20 then
        table.remove(self.ai.memory.recent_events, 1)
    end
    
    table.insert(self.ai.memory.recent_events, {
        type = eventType,
        data = eventData,
        timestamp = GetGameTimer()
    })
end

function CompanionState:SetGroupLeader(isLeader)
    self.ai.coordination.leader_companion = isLeader
    TriggerEvent('rsg-companions:client:leadershipChanged', isLeader)
end

function CompanionState:UpdateNearbyCompanions(companions)
    self.ai.coordination.nearby_companions = companions or {}
    self.ai.coordination.last_coordination_update = GetGameTimer()
end

-- ================================
-- CÁLCULOS INTERNOS
-- ================================

function CompanionState:CalculateLevel()
    local xp = self.stats.xp or 0

    if not Config.PetAttributes.levelAttributes then
        self.stats.level = 1
        return
    end

    for i, levelData in ipairs(Config.PetAttributes.levelAttributes) do
        if xp >= levelData.xpMin and xp <= levelData.xpMax then
            self.stats.level = i
            return
        end
    end

    self.stats.level = 1
end

function CompanionState:GetInventoryCapacity()
    local level = self:GetLevel()
    local levelData = Config.PetAttributes.levelAttributes[level]

    if levelData then
        return {
            weight = levelData.invWeight or 2000,
            slots = levelData.invSlots or 2
        }
    end

    return { weight = 2000, slots = 2 }
end

-- ================================
-- GESTIÓN DE COMPORTAMIENTO
-- ================================

function CompanionState:SetHuntMode(enabled)
    self.behavior.huntMode = enabled
    TriggerEvent('rsg-companions:client:huntModeChanged', enabled)
end

function CompanionState:IsHuntMode()
    return self.behavior.huntMode
end

function CompanionState:SetRetrieving(state)
    self.behavior.retrieving = state
    self.behavior.retrieved = not state
end

function CompanionState:IsRetrieving()
    return self.behavior.retrieving
end

function CompanionState:SetRecentCombat(timestamp)
    self.behavior.recentCombat = timestamp or GetGameTimer()
end

function CompanionState:IsInRecentCombat(threshold)
    threshold = threshold or 10000 -- 10 seconds default
    return (GetGameTimer() - self.behavior.recentCombat) < threshold
end

-- ================================
-- GESTIÓN DE UI
-- ================================

function CompanionState:SetBlip(blip)
    if self.ui.blip and DoesBlipExist(self.ui.blip) then
        RemoveBlip(self.ui.blip)
    end
    self.ui.blip = blip
end

function CompanionState:GetBlip()
    return self.ui.blip
end

function CompanionState:SetTimeout(enabled, timer)
    self.ui.timeout = enabled
    if timer then
        self.ui.timeoutTimer = timer
    end
end

function CompanionState:IsTimeout()
    return self.ui.timeout
end

-- ================================
-- GESTIÓN DE OBJETOS
-- ================================

function CompanionState:AddRetrievedEntity(entity)
    if not entity or not DoesEntityExist(entity) then return end

    table.insert(self.objects.retrievedEntities, entity)
end

function CompanionState:RemoveRetrievedEntity(entity)
    for i, retrievedEntity in ipairs(self.objects.retrievedEntities) do
        if retrievedEntity == entity then
            table.remove(self.objects.retrievedEntities, i)
            break
        end
    end
end

function CompanionState:GetRetrievedEntities()
    -- Clean up non-existent entities
    local validEntities = {}
    for _, entity in ipairs(self.objects.retrievedEntities) do
        if DoesEntityExist(entity) then
            table.insert(validEntities, entity)
        end
    end
    self.objects.retrievedEntities = validEntities
    return validEntities
end

-- ================================
-- CLEANUP
-- ================================

function CompanionState:Reset()
    -- Cleanup entities
    if DoesEntityExist(self.ped) then
        DeleteEntity(self.ped)
    end

    -- Cleanup blips
    if self.ui.blip and DoesBlipExist(self.ui.blip) then
        RemoveBlip(self.ui.blip)
    end

    -- Cleanup retrieved entities
    for _, entity in ipairs(self.objects.retrievedEntities) do
        if DoesEntityExist(entity) then
            DeleteEntity(entity)
        end
    end

    -- Reset state
    self.spawned = false
    self.called = false
    self.ped = 0
    self.data = {}
    self.stats = {
        xp = 0,
        bonding = 0,
        level = 0,
        stamina = 0,
        health = 0,
        hunger = 0,
        thirst = 0,
        happiness = 0
    }
    self.behavior = {
        huntMode = false,
        retrieving = false,
        retrieved = true,
        recentCombat = 0
    }
    self.ui = {
        blip = nil,
        gpsRoute = nil,
        timeout = false,
        timeoutTimer = 30
    }
    self.objects = {
        retrievedEntities = {},
        fetchedObj = nil,
        itemProps = {}
    }
    self.stable = {
        closest = nil,
        gender = nil
    }
    
    -- ================================
    -- RESET ENHANCED AI SYSTEM v4.7.0
    -- ================================
    
    -- Reset AI context (preserve some session data)
    self.ai.context = {
        current_activity = 'idle',
        environment = 'wilderness',
        time_of_day = 'day',
        weather = 'clear',
        location_type = 'open_world',
        social_context = 'alone',
        last_update = GetGameTimer()
    }
    
    -- Reset decision tree (preserve weights)
    self.ai.decision_tree.last_decision = GetGameTimer()
    self.ai.decision_tree.decision_history = {}
    self.ai.decision_tree.performance = {
        decision_count = 0,
        avg_response_time = 0,
        last_performance_check = GetGameTimer()
    }
    
    -- Reset memory (preserve long-term associations for learning)
    self.ai.memory.recent_events = {}
    -- NOTE: player_preferences and long_term_associations preserved for learning continuity
    
    -- Reset coordination
    self.ai.coordination = {
        nearby_companions = {},
        group_behavior = 'independent',
        leader_companion = false,
        coordination_state = 'idle',
        last_coordination_update = GetGameTimer()
    }
end

-- ================================
-- VALIDACIONES
-- ================================

function CompanionState:CanPerformAction(requiredXP, checkStats)
    -- Check if companion is active
    if not self:IsActive() then
        return false, locale('cl_error_no_companion_out')
    end

    -- Check XP requirement
    if requiredXP and self:GetXP() < requiredXP then
        return false, locale('cl_error_cancompanion_xp_des')
    end

    -- Check stats if required
    if checkStats then
        local stats = self:GetStats()
        if stats.hunger < 25 or stats.thirst < 25 or stats.happiness < 25 then
            return false, locale('cl_error_cancompanion_stats_des')
        end
    end

    return true
end

-- ================================
-- ENHANCED AI VALIDATIONS v4.7.0
-- ================================

function CompanionState:CanMakeAIDecision()
    -- Check if companion is active and AI system is ready
    if not self:IsActive() then
        return false, 'companion_not_active'
    end
    
    -- Check if enough time has passed since last decision (performance throttling)
    local currentTime = GetGameTimer()
    local timeSinceLastDecision = currentTime - (self.ai.decision_tree.last_decision or 0)
    
    if timeSinceLastDecision < 100 then -- Minimum 100ms between decisions
        return false, 'decision_throttle'
    end
    
    return true, 'ready'
end

function CompanionState:ValidateAIPerformance()
    local avgResponseTime = self.ai.decision_tree.performance.avg_response_time
    
    -- Check if average response time is within acceptable limits (<50ms)
    if avgResponseTime > 50 then
        return false, 'performance_warning', avgResponseTime
    end
    
    return true, 'performance_good', avgResponseTime
end

function CompanionState:GetAIHealthStatus()
    local status = {
        active = self:IsActive(),
        context_updated = (GetGameTimer() - (self.ai.context.last_update or 0)) < 30000, -- Context updated in last 30s
        decision_count = self.ai.decision_tree.performance.decision_count,
        avg_response = self.ai.decision_tree.performance.avg_response_time,
        memory_events = #self.ai.memory.recent_events,
        nearby_companions = #self.ai.coordination.nearby_companions
    }
    
    -- Determine overall health
    if status.active and status.context_updated and status.avg_response < 50 then
        status.health = 'excellent'
    elseif status.active and status.avg_response < 75 then
        status.health = 'good'
    elseif status.active then
        status.health = 'warning'
    else
        status.health = 'critical'
    end
    
    return status
end

-- ================================
-- EVENTS
-- ================================

RegisterNetEvent('RSGCore:Client:OnPlayerLoaded', function()
    CompanionState:Reset()
end)

RegisterNetEvent('RSGCore:Client:OnPlayerUnload', function()
    CompanionState:Reset()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        CompanionState:Reset()
    end
end)

-- ================================
-- EXPORTS
-- ================================

-- Export para compatibilidad con sistema existente
function CheckActiveCompanion()
    return CompanionState:GetPed()
end

function CheckCompanionLevel()
    return CompanionState:GetLevel()
end

function CheckCompanionBondingLevel()
    return CompanionState:GetBonding()
end

-- Hacer CompanionState global para acceso desde otros archivos
_G.CompanionState = CompanionState

exports('GetCompanionState', function()
    return CompanionState
end)