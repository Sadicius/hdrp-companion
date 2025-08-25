-- ================================
-- NPC STABLE MANAGEMENT
-- Handles NPC spawning and interaction for stable locations
-- ================================

local RSGCore = exports['rsg-core']:GetCoreObject()
local spawnedPeds = {}

-- Cache variables optimizadas
local playerPed = 0
local playerCoords = vector3(0, 0, 0)

lib.locale()

-- ================================
-- SISTEMA DE CACHE OPTIMIZADO
-- ================================

-- Actualizar cache automáticamente
lib.onCache('ped', function(ped)
    playerPed = ped
end)

lib.onCache('coords', function(coords)
    playerCoords = coords
end)

CreateThread(function()
    -- Validation: Ensure Config.StableSettings is loaded and valid
    if not Config.StableSettings or type(Config.StableSettings) ~= "table" then
        print('[HDRP-COMPANION ERROR] Config.StableSettings not loaded or invalid')
        return
    end
    
    if Config.Debug then
        print('[HDRP-COMPANION] Processing ' .. #Config.StableSettings .. ' stable settings')
    end
    
    for k,v in pairs(Config.StableSettings) do
        if not Config.EnableTarget then
            exports['rsg-core']:createPrompt(v.stableid, v.coords, RSGCore.Shared.Keybinds[Config.KeyBind], locale('cl_promp_menu'), {
                type = 'client',
                event = 'rsg-companions:client:stablemenu',
                args = {v.stableid}
            })
        end
        if v.showblip == true then
            local StablesBlip = BlipAddForCoords(1664425300, v.coords)
            SetBlipSprite(StablesBlip, joaat(Config.Blip.blipSprite), true)
            SetBlipScale(StablesBlip, Config.Blip.blipScale)
            SetBlipName(StablesBlip, Config.Blip.blipName)
        end
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000 -- Base sleep optimizado
        
        -- Solo procesar si el jugador está logueado
        if LocalPlayer.state.isLoggedIn and playerPed > 0 then
            sleep = 500 -- Más frecuente cuando activo
            
            for k,v in pairs(Config.StableSettings) do
                    -- Usar coordenadas cached en lugar de native
                    local distance = #(playerCoords - v.npccoords.xyz)

                if distance < Config.DistanceSpawn and not spawnedPeds[k] then
                    local spawnedPed = NearPed(v.npcmodel, v.npccoords, v.stableid)
                    spawnedPeds[k] = { spawnedPed = spawnedPed }
                end

                if distance >= Config.DistanceSpawn and spawnedPeds[k] then
                    if Config.FadeIn then
                        for i = 255, 0, -51 do
                            Wait(50)
                            SetEntityAlpha(spawnedPeds[k].spawnedPed, i, false)
                        end
                    end
                    DeletePed(spawnedPeds[k].spawnedPed)
                    spawnedPeds[k] = nil
                end
            end
        end
        
        Wait(sleep)
    end
end)

function NearPed(npcmodel, npccoords, stableid)
    RequestModel(npcmodel)
    while not HasModelLoaded(npcmodel) do
        Wait(50)
    end
    spawnedPed = CreatePed(npcmodel, npccoords.x, npccoords.y, npccoords.z - 1.0, npccoords.w, false, false, 0, 0)
    SetEntityAlpha(spawnedPed, 0, false)
    SetRandomOutfitVariation(spawnedPed, true)
    SetEntityCanBeDamaged(spawnedPed, false)
    SetEntityInvincible(spawnedPed, true)
    FreezeEntityPosition(spawnedPed, true)
    SetBlockingOfNonTemporaryEvents(spawnedPed, true)
    SetPedCanBeTargetted(spawnedPed, false)

    if Config.FadeIn then
        for i = 0, 255, 51 do
            Wait(50)
            SetEntityAlpha(spawnedPed, i, false)
        end
    end

    if Config.EnableTarget then
        exports.ox_target:addLocalEntity(spawnedPed, {
            {
                name = 'npc_companions',
                icon = 'far fa-eye',
                label = locale('cl_promp_menu'),
                onSelect = function()
                    TriggerEvent('rsg-companions:client:stablemenu', stableid)
                end,
                distance = 3.0
            }
        })
    end
    return spawnedPed
end

-- cleanup
AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for k,v in pairs(spawnedPeds) do
        DeletePed(spawnedPeds[k].spawnedPed)
        spawnedPeds[k] = nil
    end
end)