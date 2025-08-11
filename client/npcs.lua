local RSGCore = exports['rsg-core']:GetCoreObject()
local spawnedPeds = {}
lib.locale()

CreateThread(function()
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
        Wait(500)
        for k,v in pairs(Config.StableSettings) do
            local playerCoords = GetEntityCoords(PlayerPedId())
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