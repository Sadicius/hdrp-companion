-- ================================
-- COMPANION MANAGER MODULE
-- Handles companion spawning, following, and basic behaviors
-- ================================

local RSGCore = exports['rsg-core']:GetCoreObject()
local CompanionManager = {}

-- Acceso al estado centralizado (integración con companion_state.lua)
-- CRITICAL: companion_state.lua debe cargar PRIMERO en fxmanifest.lua
local function GetCompanionState()
    return CompanionState or error("CompanionState no inicializado. Verificar orden de carga en fxmanifest.lua")
end

-- Module state
CompanionManager.activeCompanions = {}
CompanionManager.playerCompanions = {}
CompanionManager.isInitialized = false

-- ================================
-- INITIALIZATION
-- ================================

function CompanionManager:Initialize()
    if self.isInitialized then return end

    if Config.Debug then
        print('[COMPANION-MANAGER] Initializing companion manager module')
    end

    self.isInitialized = true
end

-- ================================
-- COMPANION SPAWNING
-- ================================

function CompanionManager:SpawnCompanion(companionData)
    if not companionData then return false end

    local companionid = companionData.companionid
    if self:IsCompanionActive(companionid) then
        if Config.Debug then
            print('[COMPANION-MANAGER] Companion already active:', companionid)
        end
        return false
    end

    -- Integración COMPLETA con estado centralizado
    local state = GetCompanionState()
    if state:IsActive() then
        if Config.Debug then
            print('[COMPANION-MANAGER] Ya hay un companion activo en el estado central')
        end
        return false
    end

    -- Request model
    local modelHash = joaat(companionData.model)
    lib.requestModel(modelHash, 10000)

    -- Get spawn position
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local spawnCoords = self:GetSpawnPosition(playerCoords)

    -- Create companion entity
    local companionPed = CreatePed(
        modelHash,
        spawnCoords.x,
        spawnCoords.y,
        spawnCoords.z,
        GetEntityHeading(playerPed),
        false, false, 0, 0
    )

    if not DoesEntityExist(companionPed) then
        print('[COMPANION-MANAGER] Failed to spawn companion:', companionid)
        return false
    end

    -- Configure companion
    self:ConfigureCompanion(companionPed, companionData)

    -- CRITICAL: Actualizar estado centralizado
    state:SetPed(companionPed)
    state:SetData(companionData)

    -- Store active companion (mantener para compatibilidad)
    self.activeCompanions[companionid] = {
        ped = companionPed,
        data = companionData,
        spawnTime = GetGameTimer()
    }

    -- Trigger events del sistema integrado
    TriggerEvent('rsg-companions:client:spawned', companionid, companionPed)
    
    -- Inicializar AI system si está disponible
    if CompanionAI then
        CompanionAI:Initialize(companionPed, state:GetStats())
    end

    if Config.Debug then
        print('[COMPANION-MANAGER] Companion spawned successfully:', companionid)
        print('[COMPANION-MANAGER] Estado centralizado actualizado - Spawned:', state:IsActive())
    end

    return companionPed
end

function CompanionManager:ConfigureCompanion(companionPed, companionData)
    if not DoesEntityExist(companionPed) then return end

    -- Basic configuration
    SetEntityInvincible(companionPed, Config.PetAttributes.Invincible)
    SetEntityCanBeDamaged(companionPed, not Config.PetAttributes.Invincible)
    SetBlockingOfNonTemporaryEvents(companionPed, true)

    -- Set personality if configured
    if Config.PetAttributes.personalities then
        local personality = self:GetPersonalityForXP(companionData.xp or 0)
        if personality then
            Citizen.InvokeNative(0x8B3B71C80A29A4BB, companionPed, joaat(personality))
        end
    end

    -- Set random outfit variation
    SetRandomOutfitVariation(companionPed, true)

    -- Configure health and stats based on level
    local level = self:GetLevelFromXP(companionData.xp or 0)
    self:ApplyLevelStats(companionPed, level)
end

-- ================================
-- COMPANION MANAGEMENT
-- ================================

function CompanionManager:DespawnCompanion(companionid)
    local companion = self.activeCompanions[companionid]
    if not companion then return false end

    -- Integración completa con estado centralizado
    local state = GetCompanionState()
    
    -- Cleanup AI system si está activo
    if CompanionAI and state:IsActive() then
        CompanionAI:Cleanup()
    end

    -- Trigger events del sistema
    TriggerEvent('rsg-companions:client:despawning', companionid, companion.ped)

    if DoesEntityExist(companion.ped) then
        DeleteEntity(companion.ped)
    end

    -- CRITICAL: Reset estado centralizado
    state:Reset()

    self.activeCompanions[companionid] = nil

    if Config.Debug then
        print('[COMPANION-MANAGER] Companion despawned:', companionid)
        print('[COMPANION-MANAGER] Estado centralizado reseteado - Active:', state:IsActive())
    end

    return true
end

function CompanionManager:GetActiveCompanion(companionid)
    return self.activeCompanions[companionid]
end

function CompanionManager:IsCompanionActive(companionid)
    local companion = self.activeCompanions[companionid]
    return companion and DoesEntityExist(companion.ped)
end

function CompanionManager:GetAllActiveCompanions()
    local active = {}
    for id, companion in pairs(self.activeCompanions) do
        if DoesEntityExist(companion.ped) then
            active[id] = companion
        else
            -- Clean up invalid companions
            self.activeCompanions[id] = nil
        end
    end
    return active
end

-- ================================
-- UTILITY FUNCTIONS
-- ================================

function CompanionManager:GetSpawnPosition(playerCoords)
    local spawnDistance = Config.DistanceSpawn or 5.0
    local playerHeading = GetEntityHeading(PlayerPedId())

    -- Calculate spawn position behind player
    local spawnX = playerCoords.x - (math.sin(math.rad(playerHeading)) * spawnDistance)
    local spawnY = playerCoords.y + (math.cos(math.rad(playerHeading)) * spawnDistance)
    local groundZ = GetGroundZFor3dCoord(spawnX, spawnY, playerCoords.z + 10.0, false)

    return vector3(spawnX, spawnY, groundZ)
end

function CompanionManager:GetPersonalityForXP(xp)
    if not Config.PetAttributes.personalities then return nil end

    -- Sort personalities by XP requirement (highest first)
    local sortedPersonalities = {}
    for _, personality in ipairs(Config.PetAttributes.personalities) do
        table.insert(sortedPersonalities, personality)
    end

    table.sort(sortedPersonalities, function(a, b)
        return a.xp > b.xp
    end)

    -- Find appropriate personality
    for _, personality in ipairs(sortedPersonalities) do
        if xp >= personality.xp then
            return personality.hash
        end
    end

    return nil
end

function CompanionManager:GetLevelFromXP(xp)
    if not Config.PetAttributes.levelAttributes then return 1 end

    for i, levelData in ipairs(Config.PetAttributes.levelAttributes) do
        if xp >= levelData.xpMin and xp <= levelData.xpMax then
            return i
        end
    end

    return 1
end

function CompanionManager:ApplyLevelStats(companionPed, level)
    if not DoesEntityExist(companionPed) then return end

    local levelData = Config.PetAttributes.levelAttributes[level]
    if not levelData then return end

    -- Set health based on level (example implementation)
    local baseHealth = Config.PetAttributes.Starting.Health or 300
    local healthMultiplier = 1 + (level * 0.1) -- 10% increase per level
    local newHealth = math.floor(baseHealth * healthMultiplier)

    SetEntityMaxHealth(companionPed, newHealth)
    SetEntityHealth(companionPed, newHealth)
end

-- ================================
-- CLEANUP
-- ================================

function CompanionManager:Cleanup()
    for companionid, _ in pairs(self.activeCompanions) do
        self:DespawnCompanion(companionid)
    end

    self.activeCompanions = {}
    self.playerCompanions = {}
    self.isInitialized = false

    if Config.Debug then
        print('[COMPANION-MANAGER] Module cleaned up')
    end
end

-- ================================
-- EVENT HANDLERS
-- ================================

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        CompanionManager:Cleanup()
    end
end)

-- ================================
-- EXPORTS
-- ================================

return CompanionManager