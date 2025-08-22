-- ================================
-- COMPANION OPTIMIZED CLIENT
-- Versión optimizada del cliente principal siguiendo mejores prácticas RedM
-- ================================

local RSGCore = exports['rsg-core']:GetCoreObject()

-- Cache variables optimizadas
local playerPed = 0
local playerCoords = vector3(0, 0, 0)
local vehicle = 0

lib.locale()

-- ================================  
-- SISTEMA DE CACHE OPTIMIZADO
-- ================================

-- Actualizar playerPed cuando cambie
lib.onCache('ped', function(ped)
    playerPed = ped
    if Config.Debug then
        print('[COMPANION-CLIENT] Player ped updated:', ped)
    end
end)

-- Actualizar coordenadas cuando cambien
lib.onCache('coords', function(coords)
    playerCoords = coords
end)

-- Actualizar vehículo cuando cambie
lib.onCache('vehicle', function(veh)
    vehicle = veh or 0
end)

-- ================================
-- INICIALIZACIÓN OPTIMIZADA
-- ================================

local CompanionClient = {}
CompanionClient.isInitialized = false

function CompanionClient:Initialize()
    if self.isInitialized then return end

    -- Esperar a que el jugador esté completamente cargado
    while not LocalPlayer.state.isLoggedIn do
        Wait(1000)
    end

    -- CompanionState ya está disponible globalmente desde companion_state.lua
    
    -- Verificar que los exports estén disponibles (opcional, para módulos avanzados)
    local attempts = 0
    while attempts < 50 do -- Máximo 5 segundos de espera
        -- Aquí podrías verificar exports específicos si existen
        -- Por ahora continuamos con la inicialización básica
        attempts = attempts + 1
        Wait(100)
    end

    -- Inicializar sistemas básicos
    if CompanionState and CompanionState.Initialize then
        CompanionState:Initialize()
    end

    -- Cargar datos del jugador
    local playerData = RSGCore.Functions.GetPlayerData()
    if playerData then
        self:LoadPlayerCompanions(playerData.citizenid)
    end

    self.isInitialized = true

    if Config.Debug then
        print('[COMPANION-CLIENT] Sistema inicializado correctamente')
    end
end

-- ================================
-- UTILIDADES MIGRADAS DEL SISTEMA ORIGINAL
-- ================================

-- Obtener establo más cercano para almacenar compañero
local function GetClosestStableLocation()
    local pos = playerCoords or GetEntityCoords(playerPed)
    local current = nil
    local dist = nil
    
    for k, v in pairs(Config.StableSettings) do
        local dest = vector3(v.coords.x, v.coords.y, v.coords.z)
        local dist2 = #(pos - dest)
        if current then
            if dist2 < dist then
                current = v.stableid
                dist = dist2
            end
        else
            dist = dist2
            current = v.stableid
        end
    end
    
    return current
end

-- Mover compañero hacia el jugador
local function MoveCompanionToPlayer(entity, player)
    if not DoesEntityExist(entity) or not DoesEntityExist(player) then return end
    
    FreezeEntityPosition(entity, false)
    ClearPedTasks(entity)
    
    CreateThread(function()
        local followDist = Config.PetAttributes.FollowDistance or 3.0
        local followSpeed = Config.PetAttributes.FollowSpeed or 2.0
        local active = true
        
        TaskFollowToOffsetOfEntity(entity, player, 0.0, 0.0, 0.0, followSpeed, -1, followDist, 0)
        
        while CompanionState:IsActive() and active do
            if not DoesEntityExist(entity) or not DoesEntityExist(player) then 
                active = false 
                break 
            end
            
            local pCoords = GetEntityCoords(player)
            local cCoords = GetEntityCoords(entity)
            local dist = #(pCoords - cCoords)
            
            if dist <= followDist + 0.5 then
                ClearPedTasks(entity)
                active = false
            end
            
            Wait(500)
        end
    end)
end

-- Obtener control de entidad
local function GetControlOfEntity(entity)
    if not DoesEntityExist(entity) then return false end
    
    NetworkRequestControlOfEntity(entity)
    SetEntityAsMissionEntity(entity, true, true)
    
    local timeout = 2000
    while timeout > 0 and not NetworkHasControlOfEntity(entity) do 
        Wait(100) 
        timeout = timeout - 100 
    end
    
    return NetworkHasControlOfEntity(entity)
end

-- Colocar ped correctamente en el suelo
local function PlacePedOnGroundProperly(entity)
    if not DoesEntityExist(entity) then return end
    
    local howfar = math.random(15, 30)
    local x, y, z = table.unpack(GetEntityCoords(playerPed))
    local found, groundz, normal = GetGroundZAndNormalFor_3dCoord(x - howfar, y, z)
    
    if found then 
        SetEntityCoordsNoOffset(entity, x - howfar, y, groundz + normal.z, true) 
    end
end

-- ================================
-- GESTIÓN DE SPAWNING OPTIMIZADA
-- ================================

function CompanionClient:SpawnCompanion(companionData)
    if not companionData then return false end

    -- Verificar que no hay otro compañero activo
    if CompanionState:IsActive() then
        lib.notify({
            title = locale('cl_error_companion_active'),
            type = 'error'
        })
        return false
    end

    -- Usar cache optimizado
    local currentCoords = playerCoords or GetEntityCoords(playerPed)

    -- Verificar restricciones de spawn
    if Config.SpawnOnRoadOnly and not self:IsNearRoad(currentCoords) then
        lib.notify({
            title = locale('cl_error_near_road'),
            type = 'error'
        })
        return false
    end

    -- Determinar posición de spawn optimizada
    local spawnCoords = self:GetOptimalSpawnPosition(currentCoords)
    if not spawnCoords then
        lib.notify({
            title = locale('cl_error_spawn_position'),
            type = 'error'
        })
        return false
    end

    -- Spawn del compañero usando datos de la base de datos
    local companionModel = companionData.model or 'a_c_dogHusky_01'
    local modelHash = joaat(companionModel)

    -- Request model de forma asíncrona
    lib.requestModel(modelHash, 10000)

    -- Crear entidad con configuración optimizada
    local companionPed = CreatePed(
        modelHash,
        spawnCoords.x,
        spawnCoords.y,
        spawnCoords.z,
        math.random(0, 360), -- Heading aleatorio
        false, -- isNetwork
        false, -- bScriptHostPed
        0, -- p7
        0  -- p8
    )

    if not DoesEntityExist(companionPed) then
        lib.notify({
            title = locale('cl_error_spawn_failed'),
            type = 'error'
        })
        return false
    end

    -- Configurar el compañero spawneado
    self:ConfigureSpawnedCompanion(companionPed, companionData)

    -- Actualizar estado
    CompanionState:SetPed(companionPed)
    CompanionState:SetData(companionData)

    -- Cargar customización si existe
    if Config.CustomCompanion then
        RSGCore.Functions.TriggerCallback('rsg-companions:server:LoadCustomization', function(customizationData)
            if customizationData then
                -- CustomizationSystem será implementado después
                -- CustomizationSystem:LoadCustomization(companionPed, customizationData)
            end
        end, companionData.companionid)
    end

    -- Iniciar comportamiento de seguimiento usando función migrada
    MoveCompanionToPlayer(companionPed, playerPed)

    -- Crear blip si está configurado
    self:CreateCompanionBlip(companionPed)

    -- Notificación de éxito
    lib.notify({
        title = locale('cl_success_companion_active'),
        type = 'success',
        duration = 5000
    })

    -- Reproducir sonido de silbato si está disponible
    if GetResourceState('interact-sound') == 'started' then
        exports['interact-sound']:PlayOnOne('whistle', 0.5)
    end

    if Config.Debug then
        print('[COMPANION-CLIENT] Compañero spawneado exitosamente:', companionData.companionid)
    end

    return true
end

function CompanionClient:ConfigureSpawnedCompanion(companionPed, companionData)
    if not DoesEntityExist(companionPed) then return end

    -- Configuración básica de entidad
    SetEntityInvincible(companionPed, Config.PetAttributes.Invincible or false)
    SetEntityCanBeDamaged(companionPed, not Config.PetAttributes.Invincible)
    SetBlockingOfNonTemporaryEvents(companionPed, true)
    SetPedCanBeTargetted(companionPed, true)
    
    -- Aplicar variación aleatoria de outfit
    SetRandomOutfitVariation(companionPed, true)
    
    -- Configurar atributos basados en nivel
    local companionDataParsed = json.decode(companionData.companiondata) or {}
    local xp = companionDataParsed.xp or 0
    local level = self:CalculateLevel(xp)
    
    -- Aplicar estadísticas del nivel
    self:ApplyLevelStats(companionPed, level)
    
    -- Configurar personalidad basada en XP
    local personality = self:GetPersonalityForXP(xp)
    if personality then
        -- Configurar personalidad directamente
        SetPedPersonality(companionPed, joaat(personality))
    end
    
    -- Configurar grupos de relación
    SetPedRelationshipGroupHash(companionPed, joaat('PLAYER'))
    
    -- Configurar detección de amenazas si está habilitado
    if Config.PetAttributes.DefensiveMode then
        SetPedHearingRange(companionPed, 50.0)
        SetPedSeeingRange(companionPed, 40.0)
        SetPedAlertness(companionPed, 3)
    end
end

-- ================================
-- GESTIÓN DE DESPAWN OPTIMIZADA
-- ================================

function CompanionClient:DespawnCompanion(saveData)
    local companionPed = CompanionState:GetPed()
    
    if not DoesEntityExist(companionPed) then
        CompanionState:Reset()
        return true
    end
    
    -- Guardar datos si es necesario
    if saveData then
        local companionData = CompanionState:GetData()
        if companionData and companionData.companionid then
            self:SaveCompanionData(companionData.companionid)
        end
        
        -- Si está configurado para guardar cuando huye
        if Config.StoreFleedCompanion then
            local closestStable = GetClosestStableLocation()
            TriggerServerEvent('rsg-companions:server:fleeStoreCompanion', closestStable)
        end
    end
    
    -- Parar todas las tareas
    ClearPedTasks(companionPed)
    
    -- Eliminar entidad con fade out
    if Config.FadeIn then
        for i = 255, 0, -51 do
            Wait(50)
            SetEntityAlpha(companionPed, i, false)
        end
    end
    
    DeleteEntity(companionPed)
    
    -- Reset del estado
    CompanionState:Reset()
    
    lib.notify({
        title = locale('cl_success_storing_companion'),
        type = 'success'
    })
    
    if Config.Debug then
        print('[COMPANION-CLIENT] Compañero despawneado correctamente')
    end
    
    return true
end

-- ================================
-- UTILIDADES OPTIMIZADAS
-- ================================

function CompanionClient:GetOptimalSpawnPosition(playerCoords)
    local attempts = 0
    local maxAttempts = 10
    
    while attempts < maxAttempts do
        -- Generar posición aleatoria alrededor del jugador
        local angle = math.random() * 2 * math.pi
        local distance = math.random(3, 8) -- Entre 3 y 8 metros
        
        local x = playerCoords.x + math.cos(angle) * distance
        local y = playerCoords.y + math.sin(angle) * distance
        local z = playerCoords.z
        
        -- Obtener altura del suelo
        local groundZ = GetGroundZFor3dCoord(x, y, z + 10.0, false)
        
        if groundZ and groundZ > 0 then
            local spawnCoords = vector3(x, y, groundZ)
            
            -- Verificar que la posición es válida
            if self:IsValidSpawnPosition(spawnCoords) then
                return spawnCoords
            end
        end
        
        attempts = attempts + 1
    end
    
    -- Si no se encuentra posición óptima, usar posición del jugador
    return vector3(playerCoords.x, playerCoords.y - 2.0, playerCoords.z)
end

function CompanionClient:IsValidSpawnPosition(coords)
    -- Verificar que no hay obstáculos
    local hit, _, _, _, _ = GetShapeTestResult(
        StartShapeTestCapsule(
            coords.x, coords.y, coords.z + 2.0,
            coords.x, coords.y, coords.z - 1.0,
            1.0, 1, 0, 7
        )
    )
    
    return hit ~= 1 -- No hay colisión
end

function CompanionClient:IsNearRoad(coords)
    local roadNode = GetClosestVehicleNode(coords.x, coords.y, coords.z, 1, 3.0, 0)
    return roadNode ~= nil
end

function CompanionClient:CalculateLevel(xp)
    if not Config.PetAttributes.levelAttributes then return 1 end
    
    for i, levelData in ipairs(Config.PetAttributes.levelAttributes) do
        if xp >= levelData.xpMin and xp <= levelData.xpMax then
            return i
        end
    end
    
    return 1
end

function CompanionClient:GetPersonalityForXP(xp)
    if not Config.PetAttributes.personalities then return nil end
    
    -- Ordenar personalidades por XP requerido (mayor a menor)
    local sortedPersonalities = {}
    for _, personality in ipairs(Config.PetAttributes.personalities) do
        table.insert(sortedPersonalities, personality)
    end
    
    table.sort(sortedPersonalities, function(a, b)
        return a.xp > b.xp
    end)
    
    -- Encontrar personalidad apropiada
    for _, personality in ipairs(sortedPersonalities) do
        if xp >= personality.xp then
            return personality.hash
        end
    end
    
    return 'AVOID_DOG' -- Personalidad por defecto
end

function CompanionClient:ApplyLevelStats(companionPed, level)
    if not DoesEntityExist(companionPed) then return end
    
    local levelData = Config.PetAttributes.levelAttributes[level]
    if not levelData then return end
    
    -- Aplicar estadísticas escaladas por nivel
    local baseHealth = Config.PetAttributes.Starting.Health or 300
    local healthMultiplier = 1 + (level * 0.1) -- 10% aumento por nivel
    local newHealth = math.floor(baseHealth * healthMultiplier)
    
    SetEntityMaxHealth(companionPed, newHealth)
    SetEntityHealth(companionPed, newHealth)
    
    if Config.Debug then
        print(string.format('[COMPANION-CLIENT] Applied level %d stats: Health=%d', level, newHealth))
    end
end

-- ================================
-- GESTIÓN DE BLIPS
-- ================================

function CompanionClient:CreateCompanionBlip(companionPed)
    if not DoesEntityExist(companionPed) then return end
    
    local blip = AddBlipForEntity(companionPed)
    SetBlipSprite(blip, joaat('blip_shop'))
    SetBlipScale(blip, 0.1)
    BlipAddModifier(blip, Config.Blip.Color_modifier or joaat('BLIP_MODIFIER_MP_COLOR_1'))
    
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(locale('cl_companion'))
    EndTextCommandSetBlipName(blip)
    
    CompanionState:SetBlip(blip)
    
    return blip
end

-- ================================
-- CALLBACKS OPTIMIZADOS
-- ================================

function CompanionClient:LoadPlayerCompanions(citizenId)
    RSGCore.Functions.TriggerCallback('rsg-companions:server:GetAllCompanions', function(companions)
        if companions then
            -- Guardar companions del jugador en estado local
            for _, companion in ipairs(companions) do
                if companion.active == 1 then
                    -- Auto-spawn del compañero activo si está configurado
                    self:SpawnCompanion(companion)
                    break
                end
            end
        end
    end)
end

function CompanionClient:SaveCompanionData(companionId)
    if not companionId then return end
    
    local stats = CompanionState:GetStats()
    local companionData = {
        xp = stats.xp,
        bonding = stats.bonding,
        health = stats.health,
        hunger = stats.hunger,
        thirst = stats.thirst,
        happines = stats.happiness,
        updated_at = os.time()
    }
    
    TriggerServerEvent('rsg-companions:server:UpdateCompanionData', companionId, companionData)
end

-- ================================
-- EVENT HANDLERS OPTIMIZADOS
-- ================================

-- Inicialización cuando el jugador se conecta
RegisterNetEvent('RSGCore:Client:OnPlayerLoaded', function()
    CompanionClient:Initialize()
end)

-- Limpieza cuando el jugador se desconecta
RegisterNetEvent('RSGCore:Client:OnPlayerUnload', function()
    CompanionClient:DespawnCompanion(true)
    CompanionState:Reset()
end)

-- Llamar compañero
RegisterNetEvent('rsg-companions:client:callCompanion', function()
    if CompanionState:IsActive() then
        lib.notify({
            title = locale('cl_error_companion_active'),
            type = 'error'
        })
        return
    end
    
    -- Mostrar menú de selección de compañeros
    TriggerEvent('rsg-companions:client:showCompanionMenu')
end)

-- Huir compañero con lógica migrada
RegisterNetEvent('rsg-companions:client:fleeCompanion', function()
    if not CompanionState:IsActive() then
        lib.notify({
            title = locale('cl_error_no_companion_out'),
            type = 'error'
        })
        return
    end
    
    local companionPed = CompanionState:GetPed()
    
    -- Usar función nativa de huida
    TaskAnimalFlee(companionPed, playerPed, -1)
    
    lib.notify({ 
        title = locale('cl_success_flee'), 
        type = 'success', 
        duration = 7000 
    })
    
    Wait(10000)
    
    -- Despawn con guardado si está configurado
    CompanionClient:DespawnCompanion(Config.StoreFleedCompanion)
end)

-- Abrir menú de acciones
RegisterNetEvent('rsg-companions:client:openActionsMenu', function()
    if not CompanionState:IsActive() then
        lib.notify({
            title = locale('cl_error_no_companion_out'),
            type = 'error'
        })
        return
    end
    
    TriggerEvent('rsg-companions:client:mypetsactions')
end)

-- Abrir alforjas
RegisterNetEvent('rsg-companions:client:openSaddlebag', function()
    if not CompanionState:IsActive() then return end
    
    local companionData = CompanionState:GetData()
    if companionData and companionData.companionid then
        TriggerServerEvent('rsg-inventory:server:OpenInventory', 'stash', 'companion_' .. companionData.companionid)
    end
end)

-- Cepillar compañero
RegisterNetEvent('rsg-companions:client:brushCompanion', function()
    if not CompanionState:IsActive() then return end
    
    local hasItem = RSGCore.Functions.HasItem(Config.AnimalBrush)
    if not hasItem then
        lib.notify({
            title = locale('cl_brush_need_item'),
            description = Config.AnimalBrush,
            type = 'error'
        })
        return
    end
    
    -- Mejorar stats del compañero
    CompanionState:UpdateStat('happiness', CompanionState:GetStats().happiness + Config.Increase.Happiness)
    CompanionState:AddXP(Config.Increase.XpPerClean)
    
    lib.notify({
        title = locale('cl_success_title'),
        description = locale('cl_success_companion_brushed'),
        type = 'success'
    })
end)

-- ================================
-- CLEANUP
-- ================================

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        CompanionClient:DespawnCompanion(true)
        CompanionState:Reset()
        
        if Config.Debug then
            print('[COMPANION-CLIENT] Resource stopped, cleanup completed')
        end
    end
end)

-- ================================
-- EXPORTS PARA COMPATIBILIDAD
-- ================================

-- Exports existentes para mantener compatibilidad
exports('CheckCompanionLevel', function()
    return CompanionState:GetLevel()
end)

exports('CheckCompanionBondingLevel', function()
    return CompanionState:GetBonding()
end)

exports('CheckActiveCompanion', function()
    return CompanionState:GetPed()
end)

exports('AttackTarget', function(data)
    -- AttackTarget será implementado después
    print('[COMPANION-CLIENT] AttackTarget called:', data)
end)

exports('TrackTarget', function(data)
    -- TrackTarget será implementado después
    print('[COMPANION-CLIENT] TrackTarget called:', data)
end)

exports('HuntAnimals', function(data)
    -- HuntAnimals será implementado después
    print('[COMPANION-CLIENT] HuntAnimals called:', data)
end)

-- Nuevo export para acceso al cliente optimizado
exports('GetCompanionClient', function()
    return CompanionClient
end)

return CompanionClient