-- COMPANION AI SYSTEM
local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

-- PERFORMANCE MONITORING INTEGRATION
-- Esperar a que el sistema de performance esté disponible
local PerformanceMonitor = nil
CreateThread(function()
    while not _G.CompanionPerformanceMonitor do
        Wait(100)
    end
    PerformanceMonitor = _G.CompanionPerformanceMonitor
    if Config.Debug then
        print('[COMPANION-AI] Performance monitoring integrated')
    end
end)

-- Enhanced helper para trackear eventos de IA con context data
local function TrackAIEvent(eventType, success, executionTime, contextData)
    if PerformanceMonitor and PerformanceMonitor.running then
        PerformanceMonitor:TrackEvent(eventType, success, executionTime)
        
        -- Enhanced tracking with context data v4.7.0
        if executionTime > 50 then
            print('[COMPANION-AI] Performance warning: ' .. eventType .. ' took ' .. executionTime .. 'ms')
        end
        
        -- Track decision patterns for optimization
        if eventType == 'ai_decision' and contextData and CompanionState then
            CompanionState:AddDecisionToHistory(eventType, contextData, executionTime)
        end
    end
end

-- Cache variables optimizadas
local playerPed = 0
local playerCoords = vector3(0, 0, 0)
local vehicle = 0

-- Esperar a que CompanionState esté disponible
CreateThread(function()
    while not CompanionState do
        Wait(100)
    end

    -- Integración con sistema de prompts
    while not PromptManager do
        Wait(100)
    end
    
    -- Wait for ContextAnalyzer (v4.7.0)
    while not ContextAnalyzer do
        Wait(100)
    end

    if Config.Debug then
        print('[COMPANION-AI] CompanionState, PromptManager, and ContextAnalyzer integrated')
    end
end)

-- SISTEMA DE CACHE OPTIMIZADO
-- Actualizar playerPed cuando cambie
lib.onCache('ped', function(ped)
    playerPed = ped
end)

-- Actualizar coordenadas cuando cambien
lib.onCache('coords', function(coords)
    playerCoords = coords
end)

-- Actualizar vehículo cuando cambie
lib.onCache('vehicle', function(veh)
    vehicle = veh or 0
end)

local CompanionAI = {}


-- CONFIGURACIÓN DE IA
CompanionAI.taskQueue = {}
CompanionAI.currentTask = nil
CompanionAI.lastPlayerPosition = vector3(0, 0, 0)
CompanionAI.followDistance = Config.PetAttributes.FollowDistance or 3.0
CompanionAI.followSpeed = Config.PetAttributes.FollowSpeed or 1.0
CompanionAI.isProcessing = false

-- Personalidades disponibles en RedM
CompanionAI.personalities = {
    ['AGGRESSIVE'] = joaat('AGGRESSIVE'),
    ['STANDARD_PED_AGRO_GUARD'] = joaat('STANDARD_PED_AGRO_GUARD'),
    ['WILDANIMAL'] = joaat('WILDANIMAL'),
    ['GUARD_DOG'] = joaat('GUARD_DOG'),
    ['ATTACK_DOG'] = joaat('ATTACK_DOG'),
    ['ATTACK_SHOP_DOG'] = joaat('ATTACK_SHOP_DOG'),
    ['TIMIDGUARDDOG'] = joaat('TIMIDGUARDDOG'),
    ['AVOID_DOG'] = joaat('AVOID_DOG')
}

-- Estados de comportamiento
CompanionAI.behaviorStates = {
    IDLE = 'idle',
    FOLLOWING = 'following',
    HUNTING = 'hunting',
    ATTACKING = 'attacking',
    TRACKING = 'tracking',
    RETRIEVING = 'retrieving',
    PLAYING = 'playing',
    RESTING = 'resting',
    FLEEING = 'fleeing'
}

CompanionAI.currentBehavior = CompanionAI.behaviorStates.IDLE

-- ================================
-- ENHANCED AI DECISION ENGINE v4.7.0
-- ================================

-- Decision weights based on context
CompanionAI.contextWeights = {
    combat = {
        activity = 0.6,    -- Combat activity heavily influences decisions
        environment = 0.2, -- Environment less important in combat
        bonding = 0.1,     -- Bonding affects willingness to help
        stats = 0.1        -- Stats affect capability
    },
    exploration = {
        activity = 0.3,
        environment = 0.4,  -- Environment very important for exploration
        bonding = 0.2,
        stats = 0.1
    },
    social = {
        activity = 0.2,
        environment = 0.3,
        bonding = 0.4,      -- Bonding very important for social behavior
        stats = 0.1
    },
    default = {
        activity = 0.4,
        environment = 0.3,
        bonding = 0.2,
        stats = 0.1
    }
}

-- Enhanced AI Decision Engine
function CompanionAI:MakeContextAwareDecision(decisionType, options)
    local startTime = GetGameTimer()
    local success = false
    local selectedOption = nil
    
    -- Check if we can make decisions
    if not CompanionState or not CompanionState:CanMakeAIDecision() then
        TrackAIEvent('ai_decision', false, GetGameTimer() - startTime)
        return nil
    end
    
    pcall(function()
        -- Get current context
        local context = CompanionState:GetAIContext()
        local bonding = CompanionState:GetBonding()
        local stats = CompanionState:GetStats()
        
        -- Determine context category for weights
        local contextCategory = 'default'
        if context.current_activity == 'combat' then
            contextCategory = 'combat'
        elseif context.current_activity == 'walking' or context.current_activity == 'running' then
            contextCategory = 'exploration'
        elseif context.social_context ~= 'alone' then
            contextCategory = 'social'
        end
        
        local weights = self.contextWeights[contextCategory] or self.contextWeights.default
        
        -- Score each option based on context
        local bestScore = -1
        for _, option in ipairs(options) do
            local score = self:ScoreDecisionOption(option, context, bonding, stats, weights)
            
            if score > bestScore then
                bestScore = score
                selectedOption = option
            end
        end
        
        -- Update decision tracking
        if CompanionState then
            CompanionState.ai.decision_tree.last_decision = GetGameTimer()
        end
        
        success = true
    end)
    
    local executionTime = GetGameTimer() - startTime
    TrackAIEvent('ai_decision', success, executionTime, {
        decision_type = decisionType,
        selected_option = selectedOption,
        context = CompanionState and CompanionState:GetAIContext() or nil
    })
    
    return selectedOption
end

function CompanionAI:ScoreDecisionOption(option, context, bonding, stats, weights)
    local score = 0
    
    -- Activity-based scoring
    if option.activity_match then
        for activity, bonus in pairs(option.activity_match) do
            if context.current_activity == activity then
                score = score + (bonus * weights.activity)
            end
        end
    end
    
    -- Environment-based scoring
    if option.environment_match then
        for environment, bonus in pairs(option.environment_match) do
            if context.environment == environment then
                score = score + (bonus * weights.environment)
            end
        end
    end
    
    -- Bonding-based scoring
    if option.bonding_requirement then
        if bonding >= option.bonding_requirement then
            score = score + (option.bonding_bonus or 0.5) * weights.bonding
        else
            score = score - 0.3 * weights.bonding
        end
    end
    
    -- Stats-based scoring
    if option.stat_requirements then
        for stat, requirement in pairs(option.stat_requirements) do
            if stats[stat] and stats[stat] >= requirement then
                score = score + 0.2 * weights.stats
            else
                score = score - 0.1 * weights.stats
            end
        end
    end
    
    -- Time-based modifiers
    if option.time_preferences then
        for timeOfDay, bonus in pairs(option.time_preferences) do
            if context.time_of_day == timeOfDay then
                score = score + bonus * 0.1
            end
        end
    end
    
    -- Weather-based modifiers
    if option.weather_preferences then
        for weather, bonus in pairs(option.weather_preferences) do
            if context.weather == weather then
                score = score + bonus * 0.1
            end
        end
    end
    
    return math.max(0, score) -- Ensure non-negative score
end

-- Context-aware behavior decision
function CompanionAI:DecideIdleBehavior()
    local options = {
        {
            name = 'follow_close',
            activity_match = { combat = 0.8, armed = 0.6 },
            environment_match = { city = 0.3, town = 0.5 },
            bonding_requirement = 20,
            bonding_bonus = 0.4
        },
        {
            name = 'explore_area',
            activity_match = { idle = 0.6, walking = 0.4 },
            environment_match = { wilderness = 0.8, forest = 0.7 },
            stat_requirements = { stamina = 50 },
            time_preferences = { morning = 0.3, afternoon = 0.3 }
        },
        {
            name = 'rest',
            activity_match = { idle = 0.5 },
            stat_requirements = { stamina = 30, happiness = 40 },
            time_preferences = { evening = 0.4, night = 0.6 },
            weather_preferences = { rainy = 0.3 }
        },
        {
            name = 'play',
            activity_match = { idle = 0.7 },
            environment_match = { wilderness = 0.6, open_world = 0.5 },
            bonding_requirement = 50,
            bonding_bonus = 0.6,
            stat_requirements = { happiness = 60 }
        }
    }
    
    return self:MakeContextAwareDecision('idle_behavior', options)
end

-- Enhanced combat decision making
function CompanionAI:DecideCombatBehavior(threatEntity)
    local options = {
        {
            name = 'aggressive_attack',
            activity_match = { combat = 1.0 },
            bonding_requirement = 70,
            stat_requirements = { health = 60, stamina = 50 }
        },
        {
            name = 'defensive_support',
            activity_match = { combat = 0.6 },
            bonding_requirement = 40,
            stat_requirements = { health = 40 }
        },
        {
            name = 'retreat_and_regroup',
            activity_match = { combat = 0.3 },
            stat_requirements = { health = 20 },
            environment_match = { open_world = 0.7 }
        }
    }
    
    return self:MakeContextAwareDecision('combat_behavior', options)
end

-- ================================
-- ENHANCED AI HELPER FUNCTIONS v4.7.0
-- ================================

-- Get random coordinates near a position
function GetRandomCoordNearPosition(position, radius)
    local angle = math.random() * 2 * math.pi
    local distance = math.random() * radius
    
    return vector3(
        position.x + math.cos(angle) * distance,
        position.y + math.sin(angle) * distance,
        position.z
    )
end

-- Get position by relative heading
function GetPositionByRelativeHeading(position, heading, distance)
    local radians = math.rad(heading)
    
    return vector3(
        position.x + math.cos(radians) * distance,
        position.y + math.sin(radians) * distance,
        position.z
    )
end

-- Event handler for context changes
RegisterNetEvent('rsg-companions:client:contextChanged', function(contextType, value)
    if Config.Debug then
        print('[COMPANION-AI] Context changed: ' .. contextType .. ' = ' .. tostring(value))
    end
    
    -- React to specific context changes
    if contextType == 'current_activity' and value == 'combat' then
        -- Prepare for combat if companion is active
        local companionPed = CompanionState and CompanionState:GetPed()
        if companionPed and DoesEntityExist(companionPed) then
            -- Set alert stance
            SetPedAlertness(companionPed, 3) -- High alertness
        end
    elseif contextType == 'weather' and value == 'rainy' then
        -- Seek shelter behavior could be implemented here
        if CompanionState then
            CompanionState:AddMemoryEvent('weather_change', { new_weather = value })
        end
    end
end)


-- SISTEMA DE PERSONALIDAD
function CompanionAI:SetPersonality(companionPed, personalityType)
    local startTime = GetGameTimer()
    local success = false

    -- Validaciones iniciales
    if not DoesEntityExist(companionPed) then 
        TrackAIEvent('personalitySet', false, GetGameTimer() - startTime)
        return false 
    end

    local personalityHash = self.personalities[personalityType]
    if not personalityHash then
        if Config.Debug then
            print('[COMPANION-AI] Unknown personality type:', personalityType)
        end
        TrackAIEvent('personalitySet', false, GetGameTimer() - startTime)
        return false
    end

    -- Aplicar personalidad usando native RedM con error handling
    local applySuccess = pcall(function()
        SetPedPersonality(companionPed, personalityHash)
    end)

    if not applySuccess then
        if Config.Debug then
            print('[COMPANION-AI] Failed to apply personality:', personalityType)
        end
        TrackAIEvent('personalitySet', false, GetGameTimer() - startTime)
        return false
    end

    -- Configurar comportamientos específicos según personalidad
    local behaviorSuccess = pcall(function()
        self:ConfigurePersonalityBehavior(companionPed, personalityType)
    end)

    success = applySuccess and behaviorSuccess

    if success and Config.Debug then
        print('[COMPANION-AI] Applied personality:', personalityType)
    end

    -- Track performance metrics
    TrackAIEvent('personalitySet', success, GetGameTimer() - startTime)

    return success
end

function CompanionAI:ConfigurePersonalityBehavior(companionPed, personalityType)
    if not DoesEntityExist(companionPed) then return end

    -- Configurar según el tipo de personalidad
    if personalityType == 'AGGRESSIVE' or personalityType == 'ATTACK_DOG' then
        -- Más agresivo, responde rápido a amenazas
        SetPedCombatAttributes(companionPed, 1, true) -- BF_CanUseCover
        SetPedCombatAttributes(companionPed, 2, true) -- BF_CanUseVehicles
        SetPedCombatAttributes(companionPed, 3, true) -- BF_CanDoDrivebys
        SetPedFleeAttributes(companionPed, 0, false) -- Don't flee

    elseif personalityType == 'GUARD_DOG' or personalityType == 'TIMIDGUARDDOG' then
        -- Defensivo, protege al jugador
        SetPedCombatAttributes(companionPed, 0, true) -- BF_CanUseWeapons
        SetPedRelationshipGroupHash(companionPed, joaat('PLAYER'))

    elseif personalityType == 'AVOID_DOG' then
        -- Más tímido, evita conflictos
        SetPedFleeAttributes(companionPed, 0, true) -- Will flee from combat
        SetPedCombatAttributes(companionPed, 17, true) -- BF_AlwaysFlee
    end

    -- Configuración común para todos los perros
    SetBlockingOfNonTemporaryEvents(companionPed, true)
    SetPedCanBeTargetted(companionPed, true)
    SetEntityCanBeDamaged(companionPed, not Config.PetAttributes.Invincible)
    SetEntityInvincible(companionPed, Config.PetAttributes.Invincible)
end


-- SISTEMA DE SEGUIMIENTO


function CompanionAI:StartFollowing(companionPed, targetEntity)
    if not DoesEntityExist(companionPed) or not DoesEntityExist(targetEntity) then return end

    self.currentBehavior = self.behaviorStates.FOLLOWING

    -- Usar native RedM para seguimiento optimizado
    TaskFollowToOffsetOfEntity(
        companionPed,
        targetEntity,
        -self.followDistance, -- offsetX (detrás del jugador)
        0.0, -- offsetY
        0.0, -- offsetZ
        self.followSpeed, -- movementSpeed
        -1, -- timeout (-1 = infinito)
        2.0, -- stoppingRange
        true, -- persistFollowing
        false, -- p9
        false, -- walkOnly
        false, -- p11
        false, -- p12
        false -- p13
    )

    if Config.Debug then
        print('[COMPANION-AI] Started following target')
    end
end

function CompanionAI:StopFollowing(companionPed)
    if not DoesEntityExist(companionPed) then return end

    ClearPedTasks(companionPed)
    self.currentBehavior = self.behaviorStates.IDLE

    if Config.Debug then
        print('[COMPANION-AI] Stopped following')
    end
end


-- SISTEMA DE COMBATE


function CompanionAI:AttackTarget(companionPed, targetEntity)
    if not DoesEntityExist(companionPed) or not DoesEntityExist(targetEntity) then return end

    -- Verificar que puede atacar
    local canAttack, reason = CompanionState:CanPerformAction(Config.TrickXp.Attack, true)
    if not canAttack then
        lib.notify({
            title = locale('cl_error_cancompanion'),
            description = reason,
            type = 'error'
        })
        return
    end

    self.currentBehavior = self.behaviorStates.ATTACKING

    -- Configurar para combate
    SetPedCombatAttributes(companionPed, 5, true) -- BF_CanFightArmedPedsWhenNotArmed
    SetPedCombatAttributes(companionPed, 13, true) -- BF_AlwaysFight

    -- Atacar objetivo usando native RedM
    TaskCombatPed(companionPed, targetEntity, 0, 16)

    -- Agregar XP por atacar
    CompanionState:AddXP(Config.Increase.XpPerMove or 2)

    -- Notificar al jugador
    lib.notify({
        title = locale('cl_action_attack_target'),
        description = locale('cl_action_attack_target_des'),
        type = 'success'
    })

    if Config.Debug then
        print('[COMPANION-AI] Attacking target:', targetEntity)
    end
end

function CompanionAI:DefendPlayer(companionPed, threatEntity)
    if not DoesEntityExist(companionPed) or not DoesEntityExist(threatEntity) then return end

    -- Solo si el modo defensivo está activado
    if not Config.PetAttributes.DefensiveMode then return end

    -- Verificar si el jugador está en combate  
    if GetPedCombatTarget(playerPed) == threatEntity then
        self:AttackTarget(companionPed, threatEntity)
        CompanionState:SetRecentCombat()
    end
end


-- SISTEMA DE RASTREO
function CompanionAI:TrackTarget(companionPed, targetEntity)
    if not DoesEntityExist(companionPed) or not DoesEntityExist(targetEntity) then return end

    -- Verificar que puede rastrear
    local canTrack, reason = CompanionState:CanPerformAction(Config.TrickXp.Track, true)
    if not canTrack then
        lib.notify({
            title = locale('cl_error_track_action'),
            description = reason,
            type = 'error'
        })
        return
    end

    self.currentBehavior = self.behaviorStates.TRACKING

    -- Ir hacia el objetivo
    local targetCoords = GetEntityCoords(targetEntity)
    TaskGoToCoordAnyMeans(companionPed, targetCoords.x, targetCoords.y, targetCoords.z, 2.0, 0, false, 0, 0.0)

    -- Crear blip en el objetivo
    local blip = AddBlipForEntity(targetEntity)
    SetBlipSprite(blip, Config.Blip.TrackSprite or joaat('blip_code_waypoint'))
    SetBlipScale(blip, Config.Blip.TrackScale or 0.2)
    BlipAddModifier(blip, Config.Blip.Color_modifier or joaat('BLIP_MODIFIER_MP_COLOR_1'))
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Config.Blip.TrackName or locale('cl_blip_track_target'))
    EndTextCommandSetBlipName(blip)

    -- Auto-eliminar blip después de tiempo configurado
    SetTimeout(Config.Blip.TrackTime or 60000, function()
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end)

    -- Agregar XP
    CompanionState:AddXP(Config.Increase.XpPerMove or 2)

    lib.notify({
        title = locale('cl_track_action'),
        description = locale('cl_track_action_des'),
        type = 'success'
    })
    
    if Config.Debug then
        print('[COMPANION-AI] Tracking target:', targetEntity)
    end
end


-- SISTEMA DE CAZA


function CompanionAI:HuntAnimal(companionPed, animalEntity)
    if not DoesEntityExist(companionPed) or not DoesEntityExist(animalEntity) then return end

    -- Verificar que puede cazar
    local canHunt, reason = CompanionState:CanPerformAction(Config.TrickXp.HuntAnimals, true)
    if not canHunt then
        lib.notify({
            title = locale('cl_error_hunt_action'),
            description = reason,
            type = 'error'
        })
        return
    end

    self.currentBehavior = self.behaviorStates.HUNTING

    -- Activar modo caza
    CompanionState:SetHuntMode(true)

    -- Atacar el animal
    TaskCombatPed(companionPed, animalEntity, 0, 16)

    -- Cuando el animal muera, recogerlo
    self:AddTaskToQueue('hunt_retrieve', {
        target = animalEntity,
        companionPed = companionPed
    })

    -- Agregar XP
    CompanionState:AddXP(Config.Increase.XpPerMove or 2)

    lib.notify({
        title = locale('cl_hunt_target_action'),
        description = locale('cl_hunt_target_action_des'),
        type = 'success'
    })

    if Config.Debug then
        print('[COMPANION-AI] Hunting animal:', animalEntity)
    end
end


-- SISTEMA DE RECUPERACIÓN


function CompanionAI:RetrieveDeadAnimal(companionPed, deadAnimalEntity)
    if not DoesEntityExist(companionPed) or not DoesEntityExist(deadAnimalEntity) then return end

    self.currentBehavior = self.behaviorStates.RETRIEVING
    CompanionState:SetRetrieving(true)

    -- Ir hacia el animal muerto
    local animalCoords = GetEntityCoords(deadAnimalEntity)
    TaskGoToCoordAnyMeans(companionPed, animalCoords.x, animalCoords.y, animalCoords.z, 2.0, 0, false, 0, 0.0)

    -- Cuando llegue, "recoger" el animal
    self:AddTaskToQueue('pickup_animal', {
        target = deadAnimalEntity,
        companionPed = companionPed
    })

    if Config.Debug then
        print('[COMPANION-AI] Retrieving dead animal:', deadAnimalEntity)
    end
end


-- SISTEMA DE ANIMACIONES


function CompanionAI:PlayAnimation(companionPed, animDict, animName, duration)
    if not DoesEntityExist(companionPed) then return end

    lib.requestAnimDict(animDict, 1000)

    TaskPlayAnim(
        companionPed,
        animDict,
        animName,
        8.0, -- blendInSpeed
        -8.0, -- blendOutSpeed
        duration or -1, -- duration
        49, -- flag
        0, -- playbackRate
        false, -- lockX
        false, -- lockY
        false -- lockZ
    )

    if Config.Debug then
        print('[COMPANION-AI] Playing animation:', animDict, animName)
    end
end

function CompanionAI:PlayIdleAnimation(companionPed)
    local animations = {
        { dict = 'amb_creature_mammal@world_dog_barking@idle_a', anim = 'idle_a' },
        { dict = 'amb_creature_mammal@world_dog_sitting@base', anim = 'base' },
        { dict = 'amb_creature_mammal@world_dog_panting@idle_a', anim = 'idle_a' }
    }

    local randomAnim = animations[math.random(#animations)]
    self:PlayAnimation(companionPed, randomAnim.dict, randomAnim.anim, 10000)
end


-- SISTEMA DE TAREAS


function CompanionAI:AddTaskToQueue(taskType, taskData)
    table.insert(self.taskQueue, {
        type = taskType,
        data = taskData,
        timestamp = GetGameTimer()
    })
end

function CompanionAI:ProcessTaskQueue()
    if self.isProcessing or #self.taskQueue == 0 then return end

    self.isProcessing = true
    local task = table.remove(self.taskQueue, 1)

    if task.type == 'hunt_retrieve' then
        self:ProcessHuntRetrieve(task.data)
    elseif task.type == 'pickup_animal' then
        self:ProcessPickupAnimal(task.data)
    elseif task.type == 'return_to_player' then
        self:ProcessReturnToPlayer(task.data)
    end

    self.isProcessing = false
end

function CompanionAI:ProcessHuntRetrieve(data)
    local animalEntity = data.target
    local companionPed = data.companionPed

    -- Esperar a que el animal muera
    CreateThread(function()
        local timeout = GetGameTimer() + 30000 -- 30 seconds timeout

        while GetGameTimer() < timeout do
            if DoesEntityExist(animalEntity) and IsEntityDead(animalEntity) then
                self:RetrieveDeadAnimal(companionPed, animalEntity)
                break
            end
            Wait(500)
        end
    end)
end

function CompanionAI:ProcessPickupAnimal(data)
    local animalEntity = data.target
    local companionPed = data.companionPed

    CreateThread(function()
        local playerPed = cache.ped or PlayerPedId()
        local animalCoords = GetEntityCoords(animalEntity)
        local companionCoords = GetEntityCoords(companionPed)

        -- Esperar a que el compañero llegue al animal
        while #(companionCoords - animalCoords) > 3.0 do
            companionCoords = GetEntityCoords(companionPed)
            Wait(500)
        end

        -- Simular recoger el animal
        self:PlayAnimation(companionPed, 'amb_creature_mammal@world_dog_eating_ground@idle_a', 'idle_a', 3000)

        Wait(3000)

        -- Dar carne al jugador
        TriggerServerEvent('rsg-companions:server:food')

        -- Volver al jugador
        self:AddTaskToQueue('return_to_player', { companionPed = companionPed })

        -- Eliminar el animal
        if DoesEntityExist(animalEntity) then
            DeleteEntity(animalEntity)
        end

        CompanionState:SetRetrieving(false)
        self.currentBehavior = self.behaviorStates.FOLLOWING

        lib.notify({
            title = locale('cl_hunt_target_reward'),
            description = locale('cl_hunt_target_reward_des'),
            type = 'success'
        })
    end)
end

function CompanionAI:ProcessReturnToPlayer(data)
    local companionPed = data.companionPed

    self:StartFollowing(companionPed, playerPed)
end


-- ENHANCED MAIN AI LOOP v4.7.0
CreateThread(function()
    while true do
        local sleep = 1000

        if LocalPlayer.state.isLoggedIn and CompanionState:IsActive() then
            sleep = 500

            local companionPed = CompanionState:GetPed()

            if DoesEntityExist(companionPed) and DoesEntityExist(playerPed) then
                -- Procesar cola de tareas
                CompanionAI:ProcessTaskQueue()

                -- Enhanced context-aware behavior v4.7.0
                local context = CompanionState:GetAIContext()
                
                -- Enhanced defensive behavior with context awareness
                if Config.PetAttributes.DefensiveMode then
                    local playerCombatTarget = GetPedCombatTarget(playerPed)
                    if playerCombatTarget and playerCombatTarget ~= 0 then
                        -- Use context-aware combat decision
                        local combatDecision = CompanionAI:DecideCombatBehavior(playerCombatTarget)
                        
                        if combatDecision then
                            if combatDecision.name == 'aggressive_attack' then
                                CompanionAI:AttackTarget(companionPed, playerCombatTarget)
                            elseif combatDecision.name == 'defensive_support' then
                                CompanionAI:DefendPlayer(companionPed, playerCombatTarget)
                            elseif combatDecision.name == 'retreat_and_regroup' then
                                -- Implement retreat behavior
                                local safeDistance = CompanionAI.followDistance * 3
                                local retreatCoords = GetPositionByRelativeHeading(playerCoords, 180, safeDistance)
                                TaskGoToCoordAnyMeans(companionPed, retreatCoords.x, retreatCoords.y, retreatCoords.z, 3.0, 0, false, 0, 0.0)
                            end
                        else
                            -- Fallback to original behavior
                            CompanionAI:DefendPlayer(companionPed, playerCombatTarget)
                        end
                    end
                end

                -- Enhanced idle behavior with context awareness
                if CompanionAI.currentBehavior == CompanionAI.behaviorStates.IDLE then
                    local currentCoords = playerCoords or GetEntityCoords(playerPed)
                    local companionCoords = GetEntityCoords(companionPed)
                    local distance = #(currentCoords - companionCoords)
                    
                    -- Context-aware idle decision every 5 seconds
                    if math.random(100) < 5 then
                        local idleDecision = CompanionAI:DecideIdleBehavior()
                        
                        if idleDecision then
                            if idleDecision.name == 'follow_close' then
                                if distance > CompanionAI.followDistance * 1.5 then
                                    CompanionAI:StartFollowing(companionPed, playerPed)
                                end
                            elseif idleDecision.name == 'explore_area' then
                                -- Implement exploration behavior
                                local exploreRadius = 15.0
                                local exploreCoords = GetRandomCoordNearPosition(currentCoords, exploreRadius)
                                TaskGoToCoordAnyMeans(companionPed, exploreCoords.x, exploreCoords.y, exploreCoords.z, 1.5, 0, false, 0, 0.0)
                                
                                -- Return to player after exploration
                                SetTimeout(math.random(8000, 15000), function()
                                    if CompanionAI.currentBehavior == CompanionAI.behaviorStates.IDLE then
                                        CompanionAI:StartFollowing(companionPed, playerPed)
                                    end
                                end)
                                
                            elseif idleDecision.name == 'rest' then
                                -- Rest animation for longer duration
                                CompanionAI:PlayAnimation(companionPed, 'amb_creature_mammal@world_dog_sitting@base', 'base', math.random(10000, 20000))
                                
                            elseif idleDecision.name == 'play' then
                                -- Play behavior - more animated actions
                                local playAnimations = {
                                    { dict = 'amb_creature_mammal@world_dog_barking@idle_a', anim = 'idle_a' },
                                    { dict = 'amb_creature_mammal@world_dog_panting@idle_a', anim = 'idle_a' }
                                }
                                local playAnim = playAnimations[math.random(#playAnimations)]
                                CompanionAI:PlayAnimation(companionPed, playAnim.dict, playAnim.anim, math.random(5000, 10000))
                                
                                -- Add bonding bonus for play
                                if CompanionState then
                                    CompanionState:UpdateStat('happiness', CompanionState:GetStats().happiness + 1)
                                end
                            end
                        end
                    end
                    
                    -- Fallback to original follow behavior if too far
                    if distance > CompanionAI.followDistance * 2 then
                        CompanionAI:StartFollowing(companionPed, playerPed)
                    end
                end

                -- Context-aware idle animations (less frequent due to enhanced decisions)
                if math.random(100) < 1 and CompanionAI.currentBehavior == CompanionAI.behaviorStates.IDLE then
                    CompanionAI:PlayIdleAnimation(companionPed)
                end
                
                -- Add memory tracking for significant events
                if CompanionState and math.random(100) < 2 then
                    CompanionState:AddMemoryEvent('ai_loop_update', {
                        behavior = CompanionAI.currentBehavior,
                        context = context,
                        distance_to_player = distance or 0
                    })
                end

                sleep = 100
            end
        end

        Wait(sleep)
    end
end)


-- EVENT HANDLERS
RegisterNetEvent('rsg-companions:client:attackTarget', function(targetEntity)
    local companionPed = CompanionState:GetPed()
    if DoesEntityExist(companionPed) then
        CompanionAI:AttackTarget(companionPed, targetEntity)
    end
end)

RegisterNetEvent('rsg-companions:client:trackTarget', function(targetEntity)
    local companionPed = CompanionState:GetPed()
    if DoesEntityExist(companionPed) then
        CompanionAI:TrackTarget(companionPed, targetEntity)
    end
end)

RegisterNetEvent('rsg-companions:client:huntTarget', function(targetEntity)
    local companionPed = CompanionState:GetPed()
    if DoesEntityExist(companionPed) then
        CompanionAI:HuntAnimal(companionPed, targetEntity)
    end
end)

RegisterNetEvent('rsg-companions:client:stopAllTasks', function()
    local companionPed = CompanionState:GetPed()
    if DoesEntityExist(companionPed) then
        CompanionAI:StopFollowing(companionPed)
        CompanionAI.taskQueue = {}
        CompanionAI.currentBehavior = CompanionAI.behaviorStates.IDLE
    end
end)


-- CLEANUP
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        CompanionAI.taskQueue = {}
        CompanionAI.currentTask = nil
        CompanionAI.isProcessing = false
    end
end)


-- EXPORTS
-- Export global para acceso desde otros archivos
CompanionAI = CompanionAI

exports('GetCompanionAI', function()
    return CompanionAI
end)

-- Exports para compatibilidad
function AttackTarget(data)
    if data.entity then
        TriggerEvent('rsg-companions:client:attackTarget', data.entity)
    end
end

function TrackTarget(data)
    if data.entity then
        TriggerEvent('rsg-companions:client:trackTarget', data.entity)
    end
end

function HuntAnimals(data)
    if data.entity then
        TriggerEvent('rsg-companions:client:huntTarget', data.entity)
    end
end