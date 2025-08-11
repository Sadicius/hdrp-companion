local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

-------------------
local statsCompanion = {}
local itemsprop = {}
local timeout = false
local companionSpawned = false
local CompanionCalled = false
local companionBlip = nil
local companiongender = nil
local closestStable = nil
local timeoutTimer = 30
local companionPed = 0
local companionxp = 0
local companionBonding = 0
local bondingLevel = 0
local companionLevel = 0
local companionStamina = 0

-------------------
local RetrievedEntities = {}
local HuntMode = false
local Retrieving = false
local Retrieved = true
local fetchedObj = nil

local recentlyCombat = 0
local gpsRoute = nil

-------------------
local CompanionPrompts
local CompanionFleePrompts
local CompanionActionsPrompts
local CompanionHuntPrompts
local SaddleBagPrompt

local TrackPrompts = {}
local AttackPrompts = {}
local HuntAnimalsPrompts = {}
local SearchDatabasePrompt = {}
local CompanionTrackPrompt = {}
local CompanionAttackPrompt = {}
local CompanionHuntAnimalsPrompt = {}

function isCompanionPedActive()
    return companionPed
end
-------------------
-- PROMPS
-------------------
local function RegisterCompanionPrompt(controlAction, localeKey, group)
    local txt = locale(localeKey)
    local prompt = PromptRegisterBegin()
    PromptSetControlAction(prompt, controlAction)
    PromptSetText(prompt, CreateVarString(10, 'LITERAL_STRING', txt))
    PromptSetEnabled(prompt, 1)
    PromptSetVisible(prompt, 1)
    PromptSetStandardMode(prompt, 1)
    PromptSetGroup(prompt, group)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, prompt, true)
    PromptRegisterEnd(prompt)
    return prompt
end

local function SetupEntityPrompt(entity, controlAction, localeKey, promptsTable)
    local group = Citizen.InvokeNative(0xB796970BD125FCE8, entity, Citizen.ResultAsLong())
    local prompt = RegisterCompanionPrompt(controlAction, localeKey, group)
    promptsTable[entity] = prompt
end

local function SetupCompanionPrompts()
    CompanionPrompts = PromptGetGroupIdForTargetEntity(companionPed)
    SaddleBagPrompt    = RegisterCompanionPrompt(Config.Prompt.CompanionSaddleBag, 'cl_action_saddlebag', CompanionPrompts)
    CompanionFleePrompts = RegisterCompanionPrompt(Config.Prompt.CompanionFlee, 'cl_action_flee', CompanionPrompts)
    CompanionActionsPrompts = RegisterCompanionPrompt(Config.Prompt.CompanionActions, 'cl_action_actions', CompanionPrompts)
    if companionxp >= Config.TrickXp.Hunt then CompanionHuntPrompts = RegisterCompanionPrompt(Config.Prompt.CompanionHunt, 'cl_action_hunt', CompanionPrompts) end
end

local function SetupCompanionTrackPrompts(entity) SetupEntityPrompt(entity, Config.Prompt.CompanionTrack, 'cl_action_track', TrackPrompts) end
local function SetupCompanionAttackPrompts(entity) SetupEntityPrompt(entity, Config.Prompt.CompanionAttack, 'cl_action_attack', AttackPrompts) end
local function SetupCompanionHuntAnimalsPrompts(entity) SetupEntityPrompt(entity, Config.Prompt.CompanionAttack, 'cl_action_attack', HuntAnimalsPrompts) end
local function SetupCompanionSearchDatabasePrompts(entity) SetupEntityPrompt(entity, Config.Prompt.CompanionSearch, 'cl_action_track', SearchDatabasePrompt) end

-------------------
-- LOCATION
-------------------
-- get closest stable to store companion
local function SetClosestStableCompanionLocation()
    local pos = GetEntityCoords(cache.ped, true)
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
    if current ~= closestStable then closestStable = current end
end

-- flee
local function Flee()
    TaskAnimalFlee(companionPed, cache.ped, -1)
    lib.notify({ title = locale('cl_success_flee'), type = 'success', duration = 7000 })
    Wait(10000)
    if Config.StoreFleedCompanion then
        SetClosestStableCompanionLocation()
        TriggerServerEvent('rsg-companions:server:fleeStoreCompanion', closestStable)
    end
    DeleteEntity(companionPed)
    companionPed = 0
    CompanionCalled = false
end

local function FleeSleep()
    TaskAnimalFlee(companionPed, cache.ped, -1)
    lib.notify({ title = locale('cl_success_flee'), type = 'success', duration = 7000 })
    SetClosestStableCompanionLocation()
    TriggerServerEvent('rsg-companions:server:fleeStoreCompanion', closestStable)
    DeleteEntity(companionPed)
    companionPed = 0
    CompanionCalled = false
end

---------------------
-- CreateThread ACTIVE PROMPTS COMPANION
---------------------
CreateThread(function()
    local sleep = 1000
    if not companionPed then return end
    while true do
        sleep = 0
        -- if Config.EnableTarget then return end
        if companionPed ~= 0 then
            if Citizen.InvokeNative(0xC92AC953F0A982AE, CompanionActionsPrompts) then
                TriggerEvent("rsg-companions:client:mypetsactions")
                sleep = 2000
            end
            if Citizen.InvokeNative(0xC92AC953F0A982AE, CompanionHuntPrompts) then
                if companionxp >= Config.TrickXp.Hunt then
                    if not IsEntityDead(companionPed) then
                        if not HuntMode then
                            lib.notify({ title = locale('cl_info_retrieve'), type = 'info', duration = 7000 })
                            HuntMode = true
                        else
                            HuntMode = false
                            lib.notify({ title = locale('cl_error_no_retrieve'), type = 'error', duration = 7000 })
                        end
                    else
                        lib.notify({title = locale('cl_error_pet_dead'), type = 'error', duration = 5000})
                    end
                    sleep = 2000
                end
            end
            if Citizen.InvokeNative(0xC92AC953F0A982AE, CompanionFleePrompts) then
                Flee()
                sleep = 2000
            end
            if Citizen.InvokeNative(0xC92AC953F0A982AE, SaddleBagPrompt) then
                TriggerEvent('rsg-companions:client:inventoryCompanion')
                sleep = 2000
            end
        end
        Wait(sleep)
    end
end)

------------------------------------
-- exports
------------------------------------
exports('CheckCompanionLevel', function() return companionLevel end)
exports('CheckCompanionBondingLevel', function() return bondingLevel end)
exports('CheckActiveCompanion', function() return companionPed end)
-- exports('CheckCompanionCustomize', function() return Customize end)
exports('AttackTarget', function(data) AttackTarget(data) end)
exports('TrackTarget', function(data) TrackTarget(data) end)
exports('HuntAnimals', function(data) HuntAnimals(data) end)
exports('TreasureHunt', function(data) startTreasureHunt(data) end)

------------------------------------
-- companion
------------------------------------
-- move companion to player
local function moveCompanionToPlayer(entity, player)
    FreezeEntityPosition(entity, false)
	ClearPedTasks(entity)
    TriggerServerEvent('rsg-companions:server:useitemspet', 'no-item')
    CreateThread(function()
        if not companionPed then return end
        local followDist  = Config.PetAttributes.FollowDistance or 3.0
        local followSpeed = Config.PetAttributes.FollowSpeed or 2.0
        local active      = true
        TaskFollowToOffsetOfEntity(entity, player, 0.0, 0.0, 0.0, followSpeed, -1, followDist, 0)
        while companionSpawned and active do
            if not DoesEntityExist(entity) or not DoesEntityExist(player) then active = false break end
            local pCoords = GetEntityCoords(player)
            local cCoords = GetEntityCoords(entity)
            local dist    = #(pCoords - cCoords)
            if dist <= followDist + 0.5 then
                ClearPedTasks(entity)
                active = false
                companionSpawned  = false
                CompanionCalled   = false
            end
            Wait(500)
        end
    end)
end

local function getControlOfEntity(entity)
    NetworkRequestControlOfEntity(entity)
    SetEntityAsMissionEntity(entity, true, true)
    local timeout = 2000
    while timeout > 0 and NetworkHasControlOfEntity(entity) == nil do Wait(100) timeout = timeout - 100 end
    return NetworkHasControlOfEntity(entity)
end

CreateThread(function()
    while true do
        if not companionPed then return end
        if (timeout) then
            if (timeoutTimer == 0) then timeout = false end
            timeoutTimer = timeoutTimer - 1
            Wait(1000)
        end
        Wait(0)
    end
end)

-- place on ground properly
local function PlacePedOnGroundProperly(entity)
    local howfar = math.random(15, 30)
    local x, y, z = table.unpack(GetEntityCoords(cache.ped))
    local found, groundz, normal = GetGroundZAndNormalFor_3dCoord(x - howfar, y, z)
    if found then SetEntityCoordsNoOffset(entity, x - howfar, y, groundz + normal.z, true) end
end

-- calculate companion bonding levels
local function BondingAply(entity, xp)
    local bond = Config.PetAttributes.Starting.MaxBonding
    local bond1 = bond * 0.25
    local bond2 = bond * 0.50
    local bond3 = bond * 0.75
    if xp <= bond * 0.25 then companionBonding = 1 end
    if xp > bond1 and xp <= bond2 then companionBonding = 817 end
    if xp > bond2 and xp <= bond3 then companionBonding = 1634 end
    if xp > bond3 then companionBonding = 2450 end
    Citizen.InvokeNative(0x09A59688C26D88DF, entity, 7, companionBonding) -- SetAttributePoints
end

local function BondingLevels()
    local maxBonding = GetMaxAttributePoints(companionPed, 7)
    local currentBonding = GetAttributePoints(companionPed, 7)
    local thirdBonding = maxBonding / 3
    if currentBonding >= maxBonding then bondingLevel = 4 end
    if currentBonding >= thirdBonding and thirdBonding * 2 > currentBonding then bondingLevel = 2 end
    if currentBonding >= thirdBonding * 2 and maxBonding > currentBonding then bondingLevel = 3 end
    if thirdBonding > currentBonding then bondingLevel = 1 end
end

local function IsPedReadyToRender(...)
    return Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, ...)
end

local function UpdatePedVariation(entity)
    Citizen.InvokeNative(0x704C908E9C405136, entity)
    Citizen.InvokeNative(0xCC8CA3E88256E58F, entity, false, true, true, true, false)
    while not IsPedReadyToRender(entity) do Wait(50) end
end

local function SetCompanionFlags(entity)
    local companionFlags = {
        [6] = true, -- No influye en tu nivel de búsqueda WantedLevel
        [217] = true, -- Evita "shock" por explosiones/disparos
        [136] = true, -- No se monta ni permite montarlo
        [412] = true, -- PCF_BlockHorsePromptsForTargetPed                
        [279] = true, -- Siempre te sigue sin perderte
        [154] = true, -- Reacciona a amenazas al seguirte
        [540] = true, -- Corre para subirse al coche contigo
        [269] = true, -- Se queda dentro si asaltan el vehículo
        [180] = true,   -- PCF_PreventDraggedOutOfCarThreatResponse
        [265] = false, -- No se ahoga ni muere en el agua
        [266] = false, -- PCF_DiesInstantlyWhenSwimming
        [267] = false, -- PCF_DrownsInSinkingVehicle
        [211] = true, -- Tareas ambientales y seguimiento de mirada
        [259] = true,   -- PCF_CanAmbientHeadtrack
        [157] = true, -- Desactiva arrastre forzado (si aplica)
        [313] = false,  -- Permite que busque transporte para seguirte
        [499] = false,  -- Silbido funciona correctamente
        [113] = false, -- PCF_DisableShockingEvents
        -- [297] = true, --  PCF_ForceInteractionLockonOnTargetPed
        -- [155] = true, --  PCF_EnableCompanionAIAnalysis
        -- [156] = true, --  PCF_EnableCompanionAISupport
        -- [125] = true, --  PCF_ForcePoseCharacterCloth
        -- [79] = true, --  PCF_ForcedToStayInCover
        -- [194] = true, --  PCF_ShouldPedFollowersIgnoreWaypointMBR
        -- [50]  = true,   -- PCF_WillFollowLeaderAnyMeans
        -- [208] = true,
        -- [209] = true,
        -- [277] = true,
        -- [300] = false, -- PCF_DisablePlayerHorseLeading
        -- [301] = false, -- PCF_DisableInteractionLockonOnTargetPed
        -- [312] = false, -- PCF_DisableHorseGunshotFleeResponse
        -- [319] = true, -- PCF_EnableAsVehicleTransitionDestination
        -- [419] = false, -- PCF_BlockMountHorsePromptç
        -- [438] = false,
        -- [439] = false,
        -- [440] = false,
        -- [561] = true
    }

    for flag, val in pairs(companionFlags) do Citizen.InvokeNative(0x1913FE4CBF41C463, entity, flag, val); end
    local companionTunings = { 24, 25, 48 }
    for _, flag in ipairs(companionTunings) do Citizen.InvokeNative(0x1913FE4CBF41C463, entity, flag, false); end
end

local function ApplyPersonality(entity, xp)
    for _, p in ipairs(Config.PetAttributes.personalities) do
        if xp >= p.xp then Citizen.InvokeNative(0xB8B6430EAD2D2437, entity, GetHashKey(p.hash)) break end
    end
end

-------------------
-- spawn companion
-------------------
function SpawnCompanion()
    RSGCore.Functions.TriggerCallback('rsg-companions:server:GetActiveCompanion', function(data)
        if not data then return end
        if (data) then
            local player = PlayerId()
            local companionsDada = json.decode(data.companiondata)
            local model = joaat(companionsDada.companion)
            local skin = tonumber(companionsDada.skin)
            local companionscale = 1.0
            local location = GetEntityCoords(cache.ped)
            local x, y, z = table.unpack(location)
            local _, nodePosition = GetClosestVehicleNode(x - 15, y, z, 0, 3.0, 0.0)
            local distance = math.floor(#(nodePosition - location))
            local onRoad = false
            if distance < 50 then onRoad = true end
            if Config.SpawnOnRoadOnly and not onRoad then lib.notify({ title = locale('cl_error_near_road'), type = 'error', duration = 7000 }) return end
            if (location) then
                while not HasModelLoaded(model) do RequestModel(model) Wait(10) end

                local heading = Config.PetAttributes.Starting.Health

                getControlOfEntity(companionPed)
                if companionBlip then RemoveBlip(companionBlip) end
                SetEntityAsMissionEntity(companionPed, true, true)
                DeleteEntity(companionPed)
                DeletePed(companionPed)
                SetEntityAsNoLongerNeeded(companionPed)
                companionPed = 0

                -- create new companion: start
                if onRoad then
                    companionPed = CreatePed(model, nodePosition, heading, true, true, 0, 0)
                    SetEntityCanBeDamaged(companionPed, false)
                    Citizen.InvokeNative(0x9587913B9E772D29, companionPed, false)
                    onRoad = false
                else
                    companionPed = CreatePed(model, location.x - 10, location.y, location.z, heading, true, true, 0, 0)
                    SetEntityCanBeDamaged(companionPed, false)
                    Citizen.InvokeNative(0x9587913B9E772D29, companionPed, false)
                    PlacePedOnGroundProperly(companionPed)
                end

                while not DoesEntityExist(companionPed) do Wait(10) end
                getControlOfEntity(companionPed)
                -- create new companion: end

                -- flag
                SetCompanionFlags(companionPed)

                -- create blip new companion
                companionBlip = Citizen.InvokeNative(0x23F74C2FDA6E7C61, -1749618580, companionPed) -- BlipAddForEntity

                Citizen.InvokeNative(0x662D364ABF16DE2F, companionBlip, Config.Blip.Color_modifier)
                Citizen.InvokeNative(0x9CB1A1623062F402, companionBlip, companionsDada.name)              -- SetBlipName
                Citizen.InvokeNative(0x283978A15512B2FE, companionPed, true)                    -- SetRandomOutfitVariation
                Citizen.InvokeNative(0xFE26E4609B1C3772, companionPed, "HorseCompanion", true) -- DecorSetBool
                Citizen.InvokeNative(0xA691C10054275290, cache.ped, companionPed, 0) -- unknown
                Citizen.InvokeNative(0x931B241409216C1F, cache.ped, companionPed, true)               -- SetPedOwnsAnimal
                Citizen.InvokeNative(0xED1C764997A86D5A, cache.ped, companionPed) -- unknown

                ApplyPersonality(companionPed, companionsDada.companionxp)

                Citizen.InvokeNative(0xDF93973251FB2CA5, player, true) -- SetPlayerMountStateActive
                -- Citizen.InvokeNative(0xe6d4e435b56d5bd0, player, companionPed) -- SetPlayerOwnsMount
                Citizen.InvokeNative(0xAEB97D84CDF3C00B, companionPed, false) -- SetAnimalIsWild
                Citizen.InvokeNative(0xA691C10054275290, companionPed, player, 431)
                Citizen.InvokeNative(0x6734F0A6A52C371C, player, 431)
                Citizen.InvokeNative(0x024EC9B649111915, companionPed, true)
                Citizen.InvokeNative(0xEB8886E1065654CD, companionPed, 10, "ALL", 0)

                -- apply skin
                Citizen.InvokeNative(0x77FF8D35EEC6BBC4, companionPed, skin, 0) -- SET_PED_OUTFIT_PRESET
                -- SET_BLIP_TYPE(companionPed)

                -- model and entity mission 
                SetModelAsNoLongerNeeded(model)
                SetEntityAsNoLongerNeeded(companionPed)
                SetEntityAsMissionEntity(companionPed, true)
                SetEntityCanBeDamaged(companionPed, true)
                SetPedNameDebug(companionPed, companionsDada.name)
                SetPedPromptName(companionPed, companionsDada.name)
                Citizen.InvokeNative(0xCC97B29285B1DC3B, companionPed, 1) -- SetAnimalMood
                Citizen.InvokeNative(0x5DA12E025D47D4E5, companionPed, 16, companionsDada.dirt) -- set horse dirt

                -- Apply custom items
                -- if Config.CustomCompanion then
                -- end
                -- end Apply custom items

                UpdatePedVariation(companionPed)

                -- set info companion xp, scale and gender
                companionxp = companionsDada.companionxp
                companiongender = companionsDada.gender
                companionscale = companionsDada.scale

                if Config.PetAttributes.RaiseAnimal then SetPedScale(companionPed, companionscale) end

                -- SetAttributePoints: start -- set companion health/stamina/ability/speed/acceleration (increased by companion training )
                local hValue = 0
                local overPower = false
                for i, level in ipairs(Config.PetAttributes.levelAttributes) do
                    if companionxp >= level.xpMin and companionxp <= level.xpMax then
                        hValue = level.xpMax + 1
                        companionLevel = i
                        if i == #Config.PetAttributes.levelAttributes then overPower = true end
                        break
                    end
                end

                -- apply correction hValue for others attributes
                local baseSTAMINA = hValue * 0.1
                local baseAGILITY = hValue * 0.1
                local baseCOURAGE = hValue * 0.1
                local baseSPEED = hValue * 0.05
                local baseACCELERATION = hValue * 0.05

                Citizen.InvokeNative(0x09A59688C26D88DF, companionPed, 0, hValue) -- HEALTH (0-2000) SetAttributePoints
                Citizen.InvokeNative(0x09A59688C26D88DF, companionPed, 1, baseSTAMINA) -- STAMINA (0-2000)
                -- Citizen.InvokeNative(0x09A59688C26D88DF, companionPed, 3, baseCOURAGE) -- COURAGE (0-2000) valentia
                Citizen.InvokeNative(0x09A59688C26D88DF, companionPed, 4, baseAGILITY) -- AGILITY (0-2000)
                Citizen.InvokeNative(0x09A59688C26D88DF, companionPed, 5, baseSPEED) -- SPEED (0-2000)
                Citizen.InvokeNative(0x09A59688C26D88DF, companionPed, 6, baseACCELERATION) -- ACCELERATION (0-2000)

                --[[ -- POSSIBLE ADD
                    if Config.Debug then print("Suciedad: " .. companionDirtPercent .. "%") end

                    -- | ADD_ATTRIBUTE_POINTS | --
                    AddAttributePoints(companionPed, 0, hValue ) -- Citizen.InvokeNative(0x75415EE0CB583760,
                    AddAttributePoints(companionPed, 1, baseSTAMINA )

                    -- | SET_ATTRIBUTE_BASE_RANK | --
                    local baserank = hValue * 0.01
                    Citizen.InvokeNative(0x5DA12E025D47D4E5, companionPed, 0, baserank )
                    Citizen.InvokeNative(0x5DA12E025D47D4E5, companionPed, 1, baserank )
                    Citizen.InvokeNative(0x5DA12E025D47D4E5, companionPed, 2, baserank )
                    -- | SET_ATTRIBUTE_BONUS_RANK | --
                    local bonusrank = hValue * 0.01
                    Citizen.InvokeNative(0x920F9488BD115EFB, companionPed, 0, bonusrank )
                    Citizen.InvokeNative(0x920F9488BD115EFB, companionPed, 1, bonusrank)
                ]]

                -- overpower settings
                if overPower then
                    EnableAttributeOverpower(companionPed, 0, 5000.0)                       -- health overpower
                    EnableAttributeOverpower(companionPed, 1, 5000.0)                       -- stamina overpower
                    local setoverpower = companionsDada.companionxp + .0                    -- convert overpower to float value
                    Citizen.InvokeNative(0xF6A7C08DF2E28B28, companionPed, 0, setoverpower) -- set health with overpower
                    Citizen.InvokeNative(0xF6A7C08DF2E28B28, companionPed, 1, setoverpower) -- set stamina with overpower
                end
                -- end of overpower settings

                if Config.PetAttributes.Invincible then SetEntityInvincible(companionPed, true) end

                -- companion bonding level: start
                BondingAply(companionPed, companionxp)
                BondingLevels()
                -- companion bonding level: end

                -- SetAttributePoints: end companion health/stamina/ability/speed/acceleration (increased by companion training)

                if Config.PetAttributes.NoFear then
					Citizen.InvokeNative(0x013A7BA5015C1372, companionPed, true)
					Citizen.InvokeNative(0x3B005FF0538ED2A9, companionPed)
				end

                table.insert(statsCompanion, {
                    ped = companionPed,
                    AGILITY = baseAGILITY,
                    SPEED = baseSPEED,
                    ACCELERATION = baseACCELERATION
                })

                -- Relationship groups: start -- can be pre-configured by game (default relationship groups) 
                -- Relationship groups: end

                -- PERSONALITY: start
                local faceFeature = 0.0
                if companiongender ~= 'male' then faceFeature = 1.0 end
                Citizen.InvokeNative(0x5653AB26C82938CF, companionPed, 41611, faceFeature) -- index https://pastebin.com/Ld76cAn7
                Citizen.InvokeNative(0xCC8CA3E88256E58F, companionPed, false, true, true, true, false)
                -- PERSONALITY: end

                -- if not Config.EnableTarget then
                if not Config.EnableTarget or Config.EnablePrompts then
                    -- PPROMPS BASE COMPANION: start
                        -- ModifyPlayerUiPromptForPed / Companion Target Prompts / (Block = 0, Hide = 1, Grey Out = 2)
                        if Config.Prompt.TargetInfo then Citizen.InvokeNative(0xA3DB37EDF9A74635, player, companionPed, 35, 1, true) end -- TARGET_INFO
                        Citizen.InvokeNative(0xA3DB37EDF9A74635, player, companionPed, 49, 1, true) -- HORSE_BRUSH
                        Citizen.InvokeNative(0xA3DB37EDF9A74635, player, companionPed, 50, 1, true) -- HORSE_FEED
                        CompanionPrompts = PromptGetGroupIdForTargetEntity(companionPed)
                        SetupCompanionPrompts()
                    -- PPROMPS BASE COMPANION: end
                elseif not Config.EnablePrompts then
                    local targetOptions = {
                        {   name = 'npc_mypets_saddlebag',
                            icon = 'fa-solid fa-book',
                            label = locale('cl_action_saddlebag'),
                            onSelect = function()
                                TriggerEvent('rsg-companions:client:inventoryCompanion')
                                Wait(2000)
                            end,
                            onExit = function()
                            end,
                            distance = 15.0
                        },
                        {   name = 'npc_mypets_actions',
                            icon = 'fa-solid fa-book',
                            label = locale('cl_action_actions'),
                            onSelect = function()
                                TriggerEvent("rsg-companions:client:mypetsactions")
                                Wait(2000)
                            end,
                            onExit = function()
                            end,
                            distance = 15.0
                        },
                        {   name = 'npc_mypets_flee',
                            icon = 'fa-solid fa-book',
                            label = locale('cl_action_flee'),
                            onSelect = function()
                                Flee()
                                Wait(2000)
                            end,
                            onExit = function()
                            end,
                            distance = 15.0
                        },
                    }
                    exports.ox_target:addLocalEntity(companionPed, targetOptions)
                end
                -- NOT SURE WHAT IS THIS
                local status = GetScriptTaskStatus(companionPed, 0x4924437d)  -- https://alloc8or.re/rdr3/doc/enums/eScriptTaskHash.txt
                while (status ~= 8) do Wait(1000) end
                moveCompanionToPlayer(companionPed, player)    -- FOLLOW PLAYER
                Wait(5000)
                -- CHECK ACTIVE
                companionSpawned = true
                CompanionCalled = true
                if companionsDada.dead == true and Config.PetAttributes.Invincible == false then
                    Wait(500)
                    SetEntityHealth(companionPed, 0)
                    lib.notify({title = locale('cl_error_pet_dead'), type = 'error', duration = 5000})
                end
            end
        end
    end)
end

----------------------------------------
-- save companion attributes DIRT
----------------------------------------
CreateThread(function()
    while true do
        if not companionPed then return end
        local sleep = 5000
        local companiondirt = Citizen.InvokeNative(0x147149F2E909323C, companionPed, 16, Citizen.ResultAsInteger())
        if companionPed ~= 0 then TriggerServerEvent('rsg-companions:server:setcompanionAttributes', companiondirt) end
        Wait(sleep)
    end
end)

--------------------------------------------
-- SPAWN VIA SERVER
--------------------------------------------
local CompanionId = nil
RegisterNetEvent('rsg-companions:client:SpawnCompanion', function(data)
    CompanionId = data.player.id
    TriggerServerEvent("rsg-companions:server:SetCompanionsActive", data.player.id)
    lib.notify({ title = locale('cl_success_title'), description = locale('cl_success_companion_active'), type = 'success', duration = 7000 })
end)

--------------------------------------------
-- EVENTS MENU
--------------------------------------------
-- trade companion
local function TradeCompanion()
    RSGCore.Functions.TriggerCallback('rsg-companions:server:GetActiveCompanion', function(data, newnames)
        if companionPed ~= 0 then
            local player, distance = RSGCore.Functions.GetClosestPlayer()
            if player ~= -1 and distance < 1.5 then
                local playerId = GetPlayerServerId(player)
                local companionId = data.companionid
                TriggerServerEvent('rsg-companions:server:TradeCompanion', playerId, companionId)
                lib.notify({ title = locale('cl_success_companion_traded'), type = 'success', duration = 7000 })
            else
                lib.notify({ title = locale('cl_error_no_nearby_player'), type = 'error', duration = 7000 })
            end
        end
    end)
end

AddEventHandler('rsg-companions:client:FleeCompanion', function()
    if companionPed ~= 0 then
        getControlOfEntity(companionPed)
        if companionBlip then RemoveBlip(companionBlip) end
        SetEntityAsMissionEntity(companionPed, true, true)
        DeleteEntity(companionPed)
        DeletePed(companionPed)
        SetEntityAsNoLongerNeeded(companionPed)
        companionPed = 0
        CompanionCalled = false
    else
        lib.notify({ title = locale('cl_error_no_companion_out'), type = 'error', duration = 7000 })
    end
end)

-- store
RegisterNetEvent('rsg-companions:client:storecompanion', function(data)
    if (companionPed ~= 0) then
        TriggerServerEvent('rsg-companions:server:SetCompanionsUnActive', CompanionId, data.stableid)
        lib.notify({ title = locale('cl_success_storing_companion'), type = 'success', duration = 7000 })
        Flee()
        CompanionCalled = false
    else
        lib.notify({ title = locale('cl_error_no_companion_out'), type = 'error', duration = 7000 })
    end
end)

-- trade
RegisterNetEvent("rsg-companions:client:tradecompanion", function(data)
    RSGCore.Functions.TriggerCallback('rsg-companions:server:GetActiveCompanion', function(data, newnames)
        if (companionPed ~= 0) then
            TradeCompanion()
            Flee()
            CompanionCalled = false
        else
            lib.notify({ title = locale('cl_error_no_companion_out'), type = 'error', duration = 7000 })
        end
    end)
end)

-- sell companion menu
RegisterNetEvent('rsg-companions:client:MenuDel', function(data)
    local companions = lib.callback.await('rsg-companions:server:GetCompanion', false, data.stableid)
    if #companions <= 0 then lib.notify({ title = locale('cl_error_no_companions'), type = 'error', duration = 7000 }) return end
    local options = {}
    for k, v in pairs(companions) do
        local AnimalData = json.decode(v.companiondata)
        options[#options + 1] = {
            title = AnimalData.name,
            description = locale('cl_menu_sell_your_companion'),
            icon = 'fa-solid fa-companion',
            serverEvent = 'rsg-companions:server:deletecompanion',
            args = { companionid = v.companionid },
            arrow = true
        }
    end
    lib.registerContext({
        id = 'sellcompanion_menu',
        title = locale('cl_menu_sell_companion_menu'),
        position = 'top-right',
        menu = 'stable_companions_menu',
        onBack = function() end,
        options = options
    })
    lib.showContext('sellcompanion_menu')
end)

-------------------------------------
-- call promp U companion
-------------------------------------
CreateThread(function()
    local sleep = 5000 -- valor por defecto, se ajusta dinámicamente
    while true do
        sleep = 0
        if Citizen.InvokeNative(0x91AEF906BCA88877, 0, Config.Prompt.CompanionCall) then
            local playerDead = IsEntityDead(cache.ped)
            RSGCore.Functions.GetPlayerData(function(PlayerData)
                if PlayerData.metadata["injail"] == 0 and not playerDead then
                    local playerCoords = GetEntityCoords(cache.ped)
                    local companionCoords = GetEntityCoords(companionPed)
                    local distance = #(playerCoords - companionCoords)
                    TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 10, 'CALLING_WHISTLE_01', 0.7)
                    if not CompanionCalled and distance > 100.0 then
                        lib.notify({ title = locale('cl_spawn'), type = 'info', duration = 7000 })
                        SpawnCompanion()
                    else
                        lib.notify({ title = locale('cl_no_spawn'), type = 'info', duration = 7000 })
                        moveCompanionToPlayer(companionPed, cache.ped)
                    end
                end
            end)
            sleep = 2000 -- Anti spam tras el prompt
        end
        Wait(sleep)
    end
end)

-------------------------------------
-- ATTACKER PROMPRS + DEFENDER AND RELATIONSHIP
-------------------------------------

-- RELATIONSHIP
-- - Initial threat detection can be added to make bodyguards aggressive and shoot anyone.
local function startThreatDetection()
    -- Citizen.CreateThread(function()
    --     while true do
            -- if companionPed ~= nil then
            --     Citizen.Wait(1000) -- Check for threats every second
            --     local playerCoords = GetEntityCoords(cache.ped)

            --     if Config.PetAttributes.ThreatDetection then
            --         local players = GetActivePlayers()
            --         for _, playerId in ipairs(players) do
            --             local targetPed = GetPlayerPed(playerId)
            --             if targetPed ~= cache.ped then
            --                 local targetCoords = GetEntityCoords(targetPed)
            --                 local distance = #(playerCoords - targetCoords)
            --                 if distance <= 20.0 then
            --                     lib.notify({ title = locale('cl_attack'), type = 'info', duration = 7000 })
            --                     AttackTarget(targetPed)
            --                 end
            --             end
            --         end
            --     end
            -- end
        -- end
    -- end)
end

local attackedGroup = nil

--[[ local function CanCompanionHunt()
    if companionPed then
        RSGCore.Functions.TriggerCallback('rsg-companions:server:GetActiveCompanion', function(result)
            if (result) then
                if result.active == 0 then
                    lib.notify({
                        title = locale('cl_error_cancompanion'),
                        description = locale('cl_error_cancompanion_des'),
                        type = 'error'
                    })
                    return false
                end

                local companionsData = json.decode(result.companiondata) or {}

                -- Validar experiencia
                if companionsData.companionxp < Config.TrickXp.Attack then
                    lib.notify({
                        title = locale('cl_error_cancompanion_xp'),
                        description = locale('cl_error_cancompanion_xp_des'),
                        type = 'error'
                    })
                    return false
                end

                -- Validar hambre, sed y felicidad
                if (companionsData.hunger < 10 or companionsData.thirst < 10) and companionsData.happiness < 25 then
                    lib.notify({
                        title = locale('cl_error_cancompanion_stats'),
                        description = locale('cl_error_cancompanion_stats__des'),
                        type = 'error'
                    })
                    return false
                end

                local accepted = math.random(0, 1) == 1
                if not accepted == 1 then
                    Wait(2000) -- Wait for animation before showing rejection notification
                    lib.notify({
                        title = locale('cl_error_cancompanion_int'),
                        description = locale('cl_error_cancompanion_int_des'),
                        type = 'error',
                        duration = 3000
                    })
                    return false
                end

                -- Si todas las condiciones son válidas
                return true
            end
        end)
    end
end ]]

function IsPedAnimal(entity)
    local pedType = GetPedType(entity)    -- Use GetPedType() to identify animal-like entities
    return pedType >= 28 and pedType <= 31    -- Animal types are typically different from human types
end

function AttackTarget(data)
    if companionPed then
        local target = data.entity
        if target and DoesEntityExist(target) and (IsPedHuman(target) or IsPedAnimal(target)) and not IsPedAPlayer(target) then
            if NetworkHasControlOfEntity(companionPed) then
                if not attackedGroup then
                    local retval, group = AddRelationshipGroup("attackedPeds")
                    attackedGroup = group
                end
                -- Set relationship configurations
                SetPedRelationshipGroupHash(target, attackedGroup)
                SetRelationshipBetweenGroups(5, GetPedRelationshipGroupHash(companionPed), GetPedRelationshipGroupHash(target))
                SetPedCombatAttributes(companionPed, 5, true)   -- Always fight
                SetPedCombatAttributes(companionPed, 46, true)  -- Unrestricted combat
                -- Predatory combat settings
                SetPedCombatMovement(companionPed, 2)           -- Aggressive movement
                SetPedCombatRange(companionPed, 2)              -- Maximum attack range
                SetPedFleeAttributes(companionPed, 0, false)
                lib.notify({ title = locale('cl_action_attack_target'), description = locale('cl_action_attack_target_des'), type = 'info', duration = 7000 })
                TaskCombatPed(companionPed, target, 0, 16)  -- Command companion to attack
            else
                lib.notify({ title = locale('cl_error_attack_target'), description = locale('cl_error_attack_target_des'), type = 'error' })
            end
        else
            lib.notify({ title = locale('cl_error_attack_inv_target'), description = locale('cl_error_attack_inv_target_des'), type = 'error' })
        end
    else
        lib.notify({ title = locale('cl_error_attack_tar'), description = locale('cl_error_attack_tar_des'), type = 'error' })
    end
end

function CleanUpRelationshipGroup()
    if attackedGroup then
        RemoveRelationshipGroup(attackedGroup)
        attackedGroup = nil  -- Limpiar la variable
        if Config.Debug then print(locale('cl_print_clean_relation')) end
    end
end

function TrackTarget(data)
    if not companionPed then return end
    if companionPed then
        local target = data.entity
        if target and DoesEntityExist(target) and (IsPedHuman(target) or IsPedAnimal(target)) and not IsPedAPlayer(target) then    -- Expand tracking to include both humans and animals
            if NetworkHasControlOfEntity(companionPed) then
                if gpsRoute ~= nil then ClearGpsMultiRoute() end
                StartGpsMultiRoute(GetHashKey("COLOR_BLUE"), true, true)    -- Start new GPS route to target
                local targetCoords = GetEntityCoords(target)    -- Get target coordinates
                AddPointToGpsMultiRoute(targetCoords.x, targetCoords.y, targetCoords.z)
                SetGpsMultiRouteRender(true)    -- Set the route to render on the map
                gpsRoute = true
                -- Track the target with specified offset and behavior
                TaskFollowToOffsetOfEntity( companionPed, target, 0.0,  -1.5, 0.0, 1.0, -1, Config.PetAttributes.TrackDistance * 100000000, 1, 1, 0, 0, 1)
                -- Create a tracking thread to monitor progress and clear GPS
                CreateThread(function()
                    local timeout = 0
                    while true do 
                        if not companionPed then return end
                        Citizen.Wait(1000)  -- Check every second
                        if not DoesEntityExist(target) then break end
                        -- Get current positions
                        local companionCoords = GetEntityCoords(companionPed)
                        local targetCoords = GetEntityCoords(target)
                        local distance = #(companionCoords - targetCoords)    -- Calculate distance
                        if distance > 10.0 then    -- If distance is too great, reapply follow task
                            TaskFollowToOffsetOfEntity( companionPed,  target, 0.0, -1.5,  0.0, 1.0, -1, Config.PetAttributes.TrackDistance * 100000000, 1, 1, 0, 0, 1 )
                        end
                        if distance <= 3.0 then    -- If close enough, clear GPS and stop tracking
                            ClearGpsMultiRoute()
                            gpsRoute = nil
                            -- Create a temporary blip
                            local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, targetCoords.x, targetCoords.y, targetCoords.z)
							Citizen.InvokeNative(0x662D364ABF16DE2F, blip, Config.Blip.Color_modifier)
                            SetBlipSprite(blip, Config.Blip.TrackSprite, true)
							SetBlipScale(blip, Config.Blip.TrackScale)
							Citizen.InvokeNative(0x45FF974EEA1DCE36, blip, true)
							Citizen.InvokeNative(0x9CB1A1623062F402, blip, Config.Blip.TrackName)
                            lib.notify({ title = locale('cl_track_target_complete'), description = locale('cl_track_target_complete_des'), type = 'success', duration = 5000 })
                            CreateThread(function()    -- Optional: Remove blip after some time
                                Wait(Config.Blip.TrackTime) -- Wait for 1 minute
                                if DoesBlipExist(blip) then RemoveBlip(blip) end
                            end)
                            break
                        end
                        timeout = timeout + 1
                        if timeout > 300 then break end
                    end
                end)
                lib.notify({ title = locale('cl_track_action'), description = locale('cl_track_action_des'), type = 'info', duration = 7000 })
                if Config.Debug then print(locale('cl_print_track_action')) end -- Debug print if enabled
            else
                lib.notify({ title = locale('cl_error_track_action'), description = locale('cl_error_track_action_des'), type = 'error'})
            end
        else
            lib.notify({ title = locale('cl_error_track_action_inv'),  description = locale('cl_error_track_action_inv_des'), type = 'error' })
        end
    else
        lib.notify({ title = locale('cl_error_track_action_ava'),  description = locale('cl_error_track_action_ava_des'), type = 'error' })
    end
end

function HuntAnimals(data)
    if companionPed then
        local target = data.entity
        if target and DoesEntityExist(target) and IsEntityAPed(target) and not IsEntityDead(target) and not IsPedAPlayer(target) then
            if NetworkHasControlOfEntity(companionPed) then
                TaskGoToEntity(companionPed, target, -1, 2.0, 1.0, 1073741824, 0)    -- Navigate to the animal
                CreateThread(function()  
                    if not companionPed then return end
                    local timeout = GetGameTimer() + 15000  -- 15-second timeout
                    local huntSuccessful = false
                    while not IsEntityDead(target) and GetGameTimer() < timeout do
                        Citizen.Wait(100)
                        local distance = #(GetEntityCoords(companionPed) - GetEntityCoords(target))    -- Check proximity
                        if distance <= 3.0 then
                            TaskCombatPed(companionPed, target, 0, 16)    -- More aggressive hunting behavior
                        end
                        if IsEntityDead(target) then huntSuccessful = true break end
                    end
                    if huntSuccessful then
                        TaskGoToEntity(companionPed, PlayerPedId(), -1, 2.0, 1.0, 1073741824, 0)    -- Return to player
                        TriggerServerEvent('rsg-companions:server:food')    -- Give raw meat item
                        Citizen.Wait(5000)    -- Wait for companion to reach player
                        lib.notify({ title = locale('cl_hunt_target_reward'), description = locale('cl_hunt_target_reward'), type = 'success', duration = 5000 })
                    end
                end)
                lib.notify({ title = locale('cl_hunt_target_action'), description = locale('cl_hunt_target_action_des'), type = 'info', duration = 5000 })
            else
                lib.notify({ title = locale('cl_error_hunt_action'), description = locale('cl_error_hunt_action_des'), type = 'error' })
            end
        else
            lib.notify({ title = locale('cl_error_hunt_action_inv'), description = locale('cl_error_hunt_action_inv_des'), type = 'error' })
        end
    else
        lib.notify({ title = locale('cl_error_hunt_action_ava'), description = locale('cl_error_hunt_action_ava_des'), type = 'error' })
    end
end

--[[ local function getJob()
    local PlayerData = RSGCore.Functions.GetPlayerData()
    if PlayerData and PlayerData.job then
        if Config.Debug then print("Player job: " .. tostring(PlayerData.job.type)) end
        return PlayerData.job.type
    end
    return nil
end

local function CanTrackDatabase()
    local job = getJob()
    return job == Config.TablesTrack.TrackingJob or ''
end ]]

RegisterNetEvent('rsg-companions:client:showTableSelectionMenu')
AddEventHandler('rsg-companions:client:showTableSelectionMenu', function()
    if not companionPed then lib.notify({ title = locale('cl_error_cancompanion'), description = locale('cl_error_cancompanion_des'), type = 'error', duration = 5000 }) return end
    -- if not CanTrackDatabase() then lib.notify({ title = locale('cl_error_jobsearch'), description = locale('cl_error_jobsearch_desc') .. Config.TablesTrack.TrackingJob .. locale('cl_error_jobsearch_descB'), type = 'error', duration = 5000 }) return end
    local options = {}
    options[#options + 1] = {
        title = locale('cl_track_search'),
        icon = 'fa-solid fa-users',
        onSelect = function()
            TriggerServerEvent('rsg-companions:server:getOnlinePlayers')
        end,
        arrow = true
    }
    for _, tableName in ipairs(Config.TablesTrack.AllowedSearchTables or {}) do
        options[#options + 1] = {
            title = tableName,
            icon = 'fa-solid fa-table',
            onSelect = function()
                local playerCoords = GetEntityCoords(PlayerPedId())
                TriggerServerEvent('rsg-companions:server:searchDatabase', playerCoords, tableName)
            end,
            arrow = true
        }
    end

	--[[
	options[#options + 1] = {
		title = 'Track Closest Animal',
		icon = 'fa-solid fa-paw',
		onSelect = function()
			TriggerEvent('tbrp_companions:client:trackClosestAnimal')
		end,
		arrow = true
	}
	--]]

    if #options == 0 then lib.notify({ title = locale('cl_error_config'), description = locale('cl_error_config_desc'), type = 'error', duration = 5000 }) return end
    lib.registerContext({
        id = 'search_table_menu',
        title = locale('cl_menu_search'),
        menu = 'show_mypetactions_menu',
        onBack = function() end,
        options = options
    })
    lib.showContext('search_table_menu')
end)

local isTracking = false

RegisterNetEvent('rsg-companions:client:trackDatabaseEntry')
AddEventHandler('rsg-companions:client:trackDatabaseEntry', function(coords, tableName, entry)
    if not companionPed then lib.notify({ title = locale('cl_error_cancompanion'), description = locale('cl_error_cancompanion_des'), type = 'error', duration = 5000 }) return end
    if Config.Debug then print("Tracking to coords: x=" .. coords.x .. ", y=" .. coords.y .. ", z=" .. coords.z) end
    isTracking = true
    TaskGoToCoordAnyMeans(companionPed, coords.x, coords.y, coords.z, 2.0, 0, 0, 786603, 0xbf800000)
    local entryInfo = ''
    for k, v in pairs(entry) do
        if k ~= 'parsed_coords' and k ~= 'has_coords' and type(v) ~= 'table' then
            entryInfo = entryInfo .. k .. ': ' .. tostring(v) .. ', '
        end
    end
    if entryInfo ~= '' then
    end
    CreateThread(function()
        local sleep = 5000
        while true do
            if not companionPed then return end
            local petCoords = GetEntityCoords(companionPed)
            local distance = #(vector3(petCoords.x, petCoords.y, petCoords.z) - vector3(coords.x, coords.y, coords.z))
            if Config.Debug then print("Distance to target: " .. distance) end
            sleep = 500
            if distance < 4.0 then
                if Config.Debug then print("Pet reached target location") end
                ClearPedTasksImmediately(companionPed)
                ClearPedSecondaryTask(companionPed)
                local waiting = 0
                local dict = 'amb_creature_mammal@world_dog_digging@base'
                RequestAnimDict(dict)
                while not HasAnimDictLoaded(dict) do
                    waiting = waiting + 100
                    Wait(100)
                    if waiting > 5000 then lib.notify({ title = locale('cl_error_companion_no'), type = 'error', duration = 7000 }) break end
                end
                TaskPlayAnim(companionPed, dict, 'base', 1.0, 1.0, -1, 1, 0, false, false, false)
                lib.notify({ title = locale('cl_found'), description = locale('cl_found_desc'), type = 'success', duration = 5000 })
                Wait(5000) -- 5000 milliseconds = 5 seconds
                ClearPedTasks(companionPed)
                moveCompanionToPlayer(companionPed, PlayerPedId())
                isTracking = false -- Reset tracking flag
                sleep = 1000
                if Config.Debug then print("Digging animation stopped, pet resuming follow mode") end
                break
            end
            if not isTracking then if Config.Debug then print("Tracking interrupted, resuming follow mode") end break end
            Wait(sleep)
        end
    end)
end)

RegisterNetEvent('rsg-companions:client:showOnlinePlayers')
AddEventHandler('rsg-companions:client:showOnlinePlayers', function(players)
    if not companionPed then lib.notify({ title = locale('cl_error_cancompanion'), description = locale('cl_error_cancompanion_des'), type = 'error', duration = 5000 }) return end
    local options = {}
    for _, player in ipairs(players) do
        options[#options + 1] = {
            title = player.name .. ' (' .. player.citizenid .. ')',
            icon = 'fa-solid fa-user',
            onSelect = function()
                local playerCoords = GetEntityCoords(PlayerPedId())
                TriggerServerEvent('rsg-companions:server:trackPlayerByCitizenID', playerCoords, player.citizenid)
            end,
            arrow = true
        }
    end
    if #options == 0 then lib.notify({ title = locale('cl_error_players'), description = locale('cl_error_players_desc'), type = 'error', duration = 5000 }) return end
    lib.registerContext({
        id = 'online_players_menu',
        title = locale('cl_menu_online_players'),
        menu = 'search_table_menu',
        options = options
    })
    lib.showContext('online_players_menu')
end)

-- promps
--[[ Citizen.CreateThread(function()
    while true do
        Wait(1)
        if companionPed ~= 0 then
            if not Config.EnableTarget then
                local id = PlayerId()
                if IsPlayerTargettingAnything(id) then
                    local result, entity = GetPlayerTargetEntity(id)
                    local sleep = 500
                    if companionPed ~= 0 then

                        if IsEntityDead(entity) then
                            CleanUpRelationshipGroup()
                            sleep = 1000
                        else

                            if Config.TablesTrack.SearchData then
                                if companionxp >= Config.TrickXp.SearchData and not IsEntityDead(entity) then
                                    SetupCompanionHuntAnimalsPrompts(entity)
                                    if Citizen.InvokeNative(0xC92AC953F0A982AE,  SearchDatabasePrompt[entity]) then
                                        if Config.Debug then print(locale('cl_print_track_target'), entity) end
                                        TriggerEvent('rsg-companions:client:showTableSelectionMenu')
                                        local playerCoords = GetEntityCoords(PlayerPedId())
                                        TriggerServerEvent('rsg-companions:server:searchDatabase', playerCoords, nil)
                                    end
                                    sleep = 2000
                                end
                            end
                        end
                    end
                    Wait(sleep)
                end
            else
                --     exports.ox_target:addGlobalPed({
                --         {
                --             label = locale('cl_globalped_hunt_target'),
                --             icon = 'fa-solid fa-paw',
                --             onSelect = HuntAnimals,
                --             canInteract = function(entity)
                --                 return IsEntityAPed(entity) and not IsEntityDead(entity) and not IsPedAPlayer(entity)
                --             end
                --         }
                --     })

                --     exports.ox_target:addGlobalPed({
                --         {
                --             label = locale('cl_globalped_attack_target'),
                --             icon = 'fa-solid fa-crosshairs',
                --             onSelect = AttackTarget,
                --             canInteract = function(entity)
                --                 return IsPedHuman(entity) and not IsPedAPlayer(entity)
                --             end
                --         }
                --     })

                --     exports.ox_target:addGlobalPed({
                --         {
                --             label = locale('cl_globalped_track_target'),
                --             icon = 'fa-solid fa-location-arrow',
                --             onSelect = TrackTarget,
                --             canInteract = function(entity)
                --                 return (IsPedHuman(entity) or IsPedAnimal(entity)) and not IsPedAPlayer(entity)
                --             end,
                --             distance = 25.0  -- Increases interaction range to 5 meters
                --         }
                --     })
            end
        end

    end
end) ]]

CreateThread(function()
    while true do
        local sleep = 1000
        if not companionPed then return end
        if companionPed ~= 0 and Config.EnablePrompts then
            local playerId = PlayerId()

            if IsPlayerTargettingAnything(playerId) then
                local _, entity = GetPlayerTargetEntity(playerId)

                if entity and entity ~= companionPed then
                    sleep = 200 -- activo, menor sleep

                    if IsEntityDead(entity) then
                        CleanUpRelationshipGroup()
                        sleep = 1000
                    else
                        -- SEARCH DATABASE
                        if Config.TablesTrack.SearchData and companionxp >= Config.TrickXp.SearchData then
                            SetupCompanionHuntAnimalsPrompts(entity)
                            if Citizen.InvokeNative(0xC92AC953F0A982AE, SearchDatabasePrompt[entity]) then
                                if Config.Debug then print(locale('cl_print_track_target'), entity) end
                                TriggerEvent('rsg-companions:client:showTableSelectionMenu')
                                local playerCoords = GetEntityCoords(PlayerPedId())
                                TriggerServerEvent('rsg-companions:server:searchDatabase', playerCoords, nil)
                                sleep = 2000
                            end
                        end

                        -- TRACK
                        if Config.TrackOnly.Active then
                            if not CompanionTrackPrompt[entity] then
                                local pedType = GetPedType(entity)
                                if (Config.TrackOnly.Animals and pedType == 28)
                                or (Config.TrackOnly.NPC and not IsPedAPlayer(entity))
                                or (Config.TrackOnly.Players and IsPedAPlayer(entity)) then
                                    SetupCompanionTrackPrompts(entity)
                                    CompanionTrackPrompt[entity] = true
                                    if Config.Debug then print(locale('cl_print_track_entity'), entity) end
                                    sleep = 2000
                                end
                            end

                            if companionxp >= Config.TrickXp.Track and Citizen.InvokeNative(0xC92AC953F0A982AE, TrackPrompts[entity]) then
                                if Config.Debug then print(locale('cl_print_track_target'), entity) end
                                TrackTarget(entity)
                                sleep = 2000
                            end
                        end

                        -- ATTACK
                        if Config.AttackOnly.Active then
                            if not CompanionAttackPrompt[entity] then
                                if (Config.AttackOnly.NPC and not IsPedAPlayer(entity)) or
                                   (Config.AttackOnly.Players and IsPedAPlayer(entity)) then
                                    SetupCompanionAttackPrompts(entity)
                                    CompanionAttackPrompt[entity] = true
                                    if Config.Debug then print(locale('cl_print_attack_entity'), entity) end
                                    sleep = 2000
                                end
                            end

                            if companionxp >= Config.TrickXp.Attack and Citizen.InvokeNative(0xC92AC953F0A982AE, AttackPrompts[entity]) then
                                if Config.Debug then print(locale('cl_print_attack_target'), entity) end
                                AttackTarget(entity)
                                sleep = 2000
                            end
                        end

                        -- HUNT
                        if Config.HuntAnimalsOnly.Active then
                            if not CompanionHuntAnimalsPrompt[entity] and GetPedType(entity) == 28 then
                                SetupCompanionHuntAnimalsPrompts(entity)
                                CompanionHuntAnimalsPrompt[entity] = true
                                if Config.Debug then print(locale('cl_print_huntanimal_npc'), entity) end
                                sleep = 2000
                            end

                            if companionxp >= Config.TrickXp.HuntAnimals and Citizen.InvokeNative(0xC92AC953F0A982AE, HuntAnimalsPrompts[entity]) then
                                if Config.Debug then print(locale('cl_print_huntanimal_target'), entity) end
                                HuntAnimals(entity)
                                sleep = 2000
                            end
                        end
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

--------------------------------------
-- companion inventory
--------------------------------------
RegisterNetEvent('rsg-companions:client:inventoryCompanion', function()
    RSGCore.Functions.TriggerCallback('rsg-companions:server:GetActiveCompanion', function(data)
        if companionPed == 0 then lib.notify({ title = locale('cl_error_no_pet_out'), type = 'error', duration = 7000 }) return end
        local function getLevelAttributes(xp)
            for _, level in ipairs(Config.PetAttributes.levelAttributes) do
                if xp >= level.xpMin and xp <= level.xpMax then
                    return level.invWeight, level.invSlots
                end
            end
            return 0, 0  -- Valor por defecto en caso de no encontrar nivel
        end
        local AnimalData = json.decode(data.companiondata)
        local companionstash = AnimalData.name .. ' ' .. data.companionid
        local invWeight, invSlots = getLevelAttributes(companionxp)
        TriggerServerEvent('rsg-companions:server:opencompanioninventory', companionstash, invWeight, invSlots)
    end)
end)

-----------------------------------------
-- ACTIONS FEED, ANIMATIONS
-----------------------------------------
local function crouchInspectAnim()
    local anim1 = `WORLD_HUMAN_CROUCH_INSPECT`
    if not IsPedMale(cache.ped) then anim1 = `WORLD_HUMAN_CROUCH_INSPECT` end
    SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
    FreezeEntityPosition(cache.ped, true)
    TaskStartScenarioInPlace(cache.ped, anim1, 3000, true, false, false, false)
    Wait(3000)
    ClearPedTasks(cache.ped)
    SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
    FreezeEntityPosition(cache.ped, false)
end

local function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(5)
    end
end

local function clearsyringeitem()
    for k, v in pairs(itemsprop) do
        if v.syringeitem and DoesEntityExist(v.syringeitem) then
            SetEntityAsNoLongerNeeded(v.syringeitem)
            DeleteEntity(v.syringeitem)
        end
        itemsprop[k] = nil
    end
end

local function syringePlayerAnim(coords, model)
    ClearPedTasks(cache.ped)
    FreezeEntityPosition(cache.ped, false)
    SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
    local boneIndex = GetEntityBoneIndexByName(cache.ped, "SKEL_L_Finger00")
    local syringeitem = CreateObject(GetHashKey(model), coords.x, coords.y, coords.z, true, true, true)
    AttachEntityToEntity(syringeitem, cache.ped, boneIndex, 0.06, -0.08, -0.03, -30.0, 0.0, 60.0, true, false, true, false, 0, true)
    table.insert(itemsprop, {syringeitem = syringeitem} )
    local p_coords = GetEntityCoords(companionPed)
    local hcoords = GetEntityCoords(cache.ped)
    local maxWaitTime = 10000 -- Tiempo máximo de espera (10 segundos)
    local startTime = GetGameTimer()
    local dist = #(hcoords - p_coords)
    TaskGoToCoordAnyMeans(cache.ped, p_coords.x, p_coords.y, p_coords.z, 1.0, 0, false, 786603, 0xbf800000)
    while dist > 1.1 do
        Citizen.Wait(100)
        hcoords = GetEntityCoords(cache.ped)
        dist = #(hcoords - p_coords)
        if GetGameTimer() - startTime > maxWaitTime then break end
    end
    TaskTurnPedToFaceEntity(cache.ped, companionPed, 2000)
    local healAnim1Dict1 = "mech_skin@sample@base"
    local healAnim1 = "sample_low"
    loadAnimDict(healAnim1Dict1)
    TaskPlayAnim(cache.ped, healAnim1Dict1, healAnim1, 1.0, 1.0, -1, 0, false, false, false)
    clearsyringeitem()
end

local function clearFoodBowl()
    for k, v in pairs(itemsprop) do
        if v.cookitem and DoesEntityExist(v.cookitem) then
            SetEntityAsNoLongerNeeded(v.cookitem)
            DeleteEntity(v.cookitem)
        end
        itemsprop[k] = nil
    end
end

local function DogEatAnimation()
	local waiting = 0
	local dict = "amb_creature_mammal@world_dog_eating_ground@base"
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		waiting = waiting + 100
		Wait(100)
		if waiting > 5000 then lib.notify({ title = locale('cl_error_no_pet_eat'), type = 'error', duration = 7000 }) break end
	end
	TaskPlayAnim(companionPed, dict, "base", 1.0, 8.0, -1, 1, 0, false, false, false)
end

local function DogSitAnimation()
	local waiting = 0
	local dict = "amb_creature_mammal@world_dog_sitting@base"
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		waiting = waiting + 100
		Wait(100)
		if waiting > 5000 then lib.notify({ title = locale('cl_error_no_pet_sit'), type = 'error', duration = 7000 }) break end
	end
	TaskPlayAnim(companionPed, dict, "base", 1.0, 8.0, -1, 1, 0, false, false, false)
end

local function petStay(entity)
	local coords = GetEntityCoords(entity)
	ClearPedTasks(entity)
	DogSitAnimation()
	FreezeEntityPosition(entity, true)
end

-- ambient dog resting
local companionbusy = false
local candoaction = false

CreateThread(function()
    while true do
        if not companionPed then return end
        local sleep = 5000
        local dist = #(GetEntityCoords(cache.ped) - GetEntityCoords(companionPed))
        local ZoneTypeId = 1
        local x, y, z = table.unpack(GetEntityCoords(cache.ped))
        local town = Citizen.InvokeNative(0x43AD8FC02B429D33, x, y, z, ZoneTypeId)
        if town == false then candoaction = true end
        if companionPed ~= 0 and companionbusy and dist < 12 then
            if Citizen.InvokeNative(0x57AB4A3080F85143, companionPed) then -- IsPedUsingAnyScenario
                ClearPedTasks(companionPed)
                companionbusy = false
            end
        end
        if companionPed ~= 0 and not companionbusy and dist > 12 and companionSpawned and candoaction then
            Citizen.InvokeNative(0x524B54361229154F, companionPed, joaat('WORLD_ANIMAL_DOG_RESTING'), -1, true, 0, GetEntityHeading(companionPed), false)       -- TaskStartScenarioInPlaceHash
            companionbusy = true
        end
        Wait(sleep)
    end
end)

-- player feed companion
RegisterNetEvent('rsg-companions:client:playerfeedcompanion')
AddEventHandler('rsg-companions:client:playerfeedcompanion', function(itemName)
    local pcoords = GetEntityCoords(cache.ped)
    local hcoords = GetEntityCoords(companionPed)
    SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
    ClearPedTasks(cache.ped)
    if Config.CompanionFeed[itemName] ~= nil then
        if Config.CompanionFeed[itemName]["ismedicine"] ~= nil then
            if Config.CompanionFeed[itemName]["ismedicine"] == true then
                -- is medicine
                if #(pcoords - hcoords) > 2.5 then lib.notify({ title = locale('cl_error_med_need_to_be_closer'), type = 'error', duration = 7000 }) return end
                local medicineModelHash = "p_cs_syringe01x" -- consumable_horse_stimulant    -- GetHashKey("Interaction_Injection_Quick") == -1355254781
                if Config.CompanionFeed[itemName]["medicineModelHash"] ~= nil then medicineModelHash = Config.CompanionFeed[itemName]["medicineModelHash"] end
                syringePlayerAnim(pcoords, medicineModelHash)
                local valueHealth = Citizen.InvokeNative(0x36731AC041289BB1, companionPed, 0)  -- GetAttributeCoreValue (Health)
                if not tonumber(valueHealth) then valueHealth = 0 end
                local newHealth = Config.CompanionFeed[itemName]["health"] -- + valueHealth
                if Config.Debug then print(valueHealth, newHealth) end
                Citizen.InvokeNative(0xC6258F41D86676E0, companionPed, 0, newHealth)  -- SetAttributeCoreValue (Health)
                local valueStamina = Citizen.InvokeNative(0x36731AC041289BB1, companionPed, 1) -- GetAttributeCoreValue (Stamina)
                if not tonumber(valueStamina) then valueStamina = 0 end
                -- local baseSTAMINA = valueStamina * 0.1
                local newStamina = Config.CompanionFeed[itemName]["stamina"] -- + baseSTAMINA
                if Config.Debug then print(valueStamina, newStamina) end
                Citizen.InvokeNative(0xC6258F41D86676E0, companionPed, 1, newStamina) -- SetAttributeCoreValue (Stamina)
                Citizen.Wait(3500)
                Citizen.InvokeNative(0x50C803A4CD5932C5, true) --core ShowPlayerCores
                Citizen.InvokeNative(0xD4EE21B7CC7FD350, true) --core ShowHorseCores
                TriggerServerEvent('rsg-companions:server:useitemspet', itemName)
                PlaySoundFrontend("Core_Fill_Up", "Consumption_Sounds", true, 0)
                ClearPedTasks(cache.ped)
                SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, false)

            elseif Config.CompanionFeed[itemName]["ismedicine"] == false then
                if #(pcoords - hcoords) > tonumber(Config.DistanceFeed) then lib.notify({ title = locale('cl_error_not_med_need_to_be_closer'), type = 'error', duration = 7000 }) return end
                local heading = GetEntityHeading(cache.ped)
                local distanceInFront = -1.00  -- Dist spawn  (0.5 unidades)
                local radians = math.rad(heading)
                local offsetX = -distanceInFront * math.sin(radians)
                local offsetY = distanceInFront * math.cos(radians)
                local objectX = pcoords.x - offsetX
                local objectY = pcoords.y - offsetY
                local objectZ = pcoords.z - 1.0
                TaskTurnPedToFaceEntity(cache.ped, companionPed, 5000)
                crouchInspectAnim()
                Wait(3000)
                local cookitem = nil
                if itemName == 'raw_meat' or itemName == 'water' then
                    cookitem = nil
                elseif itemName ~= 'raw_meat' and itemName ~= 'water' and Config.CompanionFeed[itemName]["ModelHash"] then
                    cookitem = CreateObject(Config.CompanionFeed[itemName]["ModelHash"], objectX, objectY, objectZ, true, true, true)
                else
                    cookitem = CreateObject(`s_dogbowl01x`, objectX, objectY, objectZ, true, true, true)
                end
                if cookitem ~= nil then table.insert(itemsprop, {cookitem = cookitem}) end
                ClearPedTasks(cache.ped)
                TaskTurnPedToFaceEntity(companionPed, cache.ped, 1000)
                ClearPedTasks(companionPed)
                FreezeEntityPosition(companionPed, false)

                local maxWaitTime = 10000 -- Tiempo máximo de espera (10 segundos)
                local startTime = GetGameTimer()
                if itemName == 'raw_meat' or itemName == 'water' then
                    local player_coords = GetEntityCoords(cache.ped)
                    local dist = #(hcoords - player_coords)
                    TaskGoToCoordAnyMeans(companionPed, player_coords.x, player_coords.y, player_coords.z, 1.0, 0, false, 786603, 0xbf800000)
                    while dist > 1.0 do
                        Citizen.Wait(100)
                        hcoords = GetEntityCoords(companionPed)
                        dist = #(hcoords - player_coords)
                        if GetGameTimer() - startTime > maxWaitTime then break end
                    end
                    TaskTurnPedToFaceEntity(companionPed, cache.ped, 2000)
                    Wait(500)
                else
                    local p_coords = GetEntityCoords(cookitem)
                    local dist = #(hcoords - p_coords)
                    TaskGoToCoordAnyMeans(companionPed, p_coords.x, p_coords.y, p_coords.z, 1.0, 0, false, 786603, 0xbf800000)
                    while dist > 1.0 do
                        Citizen.Wait(100)
                        hcoords = GetEntityCoords(companionPed)
                        dist = #(hcoords - p_coords)
                        if GetGameTimer() - startTime > maxWaitTime then break end
                    end
                    TaskTurnPedToFaceEntity(companionPed, cookitem, 2000)
                    Wait(500)
                end
                DogEatAnimation()
                PlaySoundFrontend("Core_Fill_Up", "Consumption_Sounds", true, 0)
                Wait(2000)
                SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, false)
                TriggerServerEvent('rsg-companions:server:useitemspet', itemName)
                local companionHealth = Citizen.InvokeNative(0x36731AC041289BB1, companionPed, 0)  -- GetAttributeCoreValue (Health)
                if not tonumber(companionHealth) then companionHealth = 0 end
                local newHealth = Config.CompanionFeed[itemName]["health"] + companionHealth
                Citizen.InvokeNative(0xC6258F41D86676E0, companionPed, 0, newHealth)  -- SetAttributeCoreValue (Health)
                Wait(8000)
                ClearPedTasks(companionPed)
                if cookitem ~= nil then clearFoodBowl() end
                Wait(2000)
                moveCompanionToPlayer(companionPed, cache.ped)
            else
                lib.notify({ title = locale('cl_error_feed')..' ' .. itemName .. ' '..locale('cl_error_feed_invalid'), type = 'error', duration = 7000 })
            end
        else
            lib.notify({ title = locale('cl_error_feed')..' ' .. itemName .. ' '..locale('cl_error_feed_no_med'), type = 'error', duration = 7000 })
        end
    end
end)

-- player brush companion
RegisterNetEvent('rsg-companions:client:playerbrushcompanion')
AddEventHandler('rsg-companions:client:playerbrushcompanion', function(itemName)
    local pcoords = GetEntityCoords(cache.ped)
    local hcoords = GetEntityCoords(companionPed)
    if #(pcoords - hcoords) > 2.0 then lib.notify({ title = locale('cl_error_brush_need_to_be_closer'), type = 'error', duration = 7000 }) return end
    local hasItem = RSGCore.Functions.HasItem(itemName)
    if not hasItem then lib.notify({ title = locale('cl_brush_need_item')..' '.. RSGCore.Shared.Items[tostring(itemName)].label, duration = 7000, type = 'error' }) return end
    if companionPed ~= 0 then
        SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
        ClearPedTasks(cache.ped)
        Wait(100)
        local boneIndex = GetEntityBoneIndexByName(cache.ped, "SKEL_R_Finger00")
        local brushitem = CreateObject(`p_brushHorse02x`, pcoords.x, pcoords.y, pcoords.z, true, true, true)
        table.insert(itemsprop, {brushitem = brushitem} )
        AttachEntityToEntity(brushitem, cache.ped, boneIndex, 0.06, -0.08, -0.03, -30.0, 0.0, 60.0, true, false, true, false, 0, true)
        Citizen.InvokeNative(0xCD181A959CFDD7F4, cache.ped, companionPed, `INTERACTION_DOG_PATTING`, 0, 0)
        Wait(8000)
        Citizen.InvokeNative(0xE3144B932DFDFF65, companionPed, 0.0, -1, 1, 1)
        ClearPedEnvDirt(companionPed)
        ClearPedDamageDecalByZone(companionPed, 10, "ALL")
        ClearPedBloodDamage(companionPed)
        Citizen.InvokeNative(0xD8544F6260F5F01E, companionPed, 10)
        for k, v in pairs(itemsprop) do
            if v.brushitem and DoesEntityExist(v.brushitem) then
                SetEntityAsNoLongerNeeded(v.brushitem)
                DeleteEntity(v.brushitem)
            end
            itemsprop[k] = nil
        end
        PlaySoundFrontend("Core_Fill_Up", "Consumption_Sounds", true, 0)
        Wait(100)
        ClearPedTasks(cache.ped)
        SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, false)
        local companiondirt = Citizen.InvokeNative(0x147149F2E909323C, companionPed, 16, Citizen.ResultAsInteger())
        local dirt = (companiondirt - Config.Increase.Brushdirt) or 0
        Citizen.InvokeNative(0xC6258F41D86676E0, companionPed, 16, dirt)  -- SetAttributeCoreValue (Health)
        TriggerServerEvent('rsg-companions:server:useitemspet', itemName)
    end
end)

----------------------------------------
-- REVIVE
----------------------------------------
-- check death companion attributes 
local companionDeadNotified = false -- Variable para evitar notificaciones duplicadas
local criticalStatsNotified = false -- Evitar notificaciones repetidas
local function blipfordead(entity)
    -- Create a temporary blip
    local targetCoords = GetEntityCoords(entity)    -- Get target coordinates
    local blipdead = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, targetCoords.x, targetCoords.y, targetCoords.z)
    Citizen.InvokeNative(0x662D364ABF16DE2F, blipdead, Config.Blip.Color_modifier)
    SetBlipSprite(blipdead, Config.Blip.DeadSprite, true)
    SetBlipScale(blipdead, Config.Blip.DeadScale)
    Citizen.InvokeNative(0x45FF974EEA1DCE36, blipdead, true)
    Citizen.InvokeNative(0x9CB1A1623062F402, blipdead, Config.Blip.DeadName)
    lib.notify({ title = locale('cl_error_pet_dead'), type = 'error', duration = 5000 })
    if DoesBlipExist(blipdead) then Wait(Config.Blip.DeadTime) RemoveBlip(blipdead) end
    if DoesEntityExist(entity) and Config.PetAttributes.AutoDeadSpawn.active then -- companion active
        Wait(Config.PetAttributes.AutoDeadSpawn.Time)
        DeletePed(entity)
        SetEntityAsNoLongerNeeded(entity)
        companionPed = 0
        CompanionCalled = false
    end
end

CreateThread(function()
    while true do
        local sleep = 5000
        local done = false
        if companionPed == 0 or not DoesEntityExist(companionPed) then
            sleep = 10000
            done = true
        else
            RSGCore.Functions.TriggerCallback('rsg-companions:server:GetActiveCompanion', function(data)
                if not data or data.active == 0 then done = true return end
                local s = json.decode(data.companiondata)
                local pedDead = s.dead or IsEntityDead(companionPed)
                local curHp = GetEntityHealth(companionPed)
                if pedDead then
                    if not companionDeadNotified then
                        companionDeadNotified = true
                        SetEntityHealth(companionPed, 0)
                        TriggerServerEvent('rsg-companions:server:companionDied')
                        blipfordead(companionPed)
                    end
                    sleep = 1000
                else
                    companionDeadNotified = false

                    if s.hunger == 0 or s.thirst == 0 or s.happiness < 10 then
                        if curHp > 0 then SetEntityHealth(companionPed, curHp - 5) end
                    elseif s.hunger < 10 or s.thirst < 10 or s.happiness < 25 then
                        if curHp > 0 then SetEntityHealth(companionPed, curHp - 1) end
                    end

                    if (s.hunger < 10 or s.thirst < 10 or s.happiness < 25) and not criticalStatsNotified then
                        criticalStatsNotified = true
                        local msg = ("%s: %d, %s: %d, %s: %d")
                            :format(locale('cl_pet_info_a'), s.hunger,
                                    locale('cl_pet_info_b'), s.thirst,
                                    locale('cl_pet_info_c'), s.happiness)
                        lib.notify({ title = msg, type = 'inform', duration = 7000 })
                        sleep = 10000
                    elseif s.hunger >= 10 and s.thirst >= 10 and s.happiness >= 25 then
                        criticalStatsNotified = false
                        sleep = 5000
                    end
                end
                done = true
            end)
        end
        while not done do Wait(50) end
        Wait(sleep)
    end
end)

local RequestControl = function(entity)
    local type = GetEntityType(entity)
    if type < 1 or type > 3 then return end
    NetworkRequestControlOfEntity(entity)
end

local function findFirstItem(list)
    for _, name in ipairs(list) do
        if RSGCore.Functions.HasItem(name) then
            return name
        end
    end
    return nil
end

-- Player revive companion
RegisterNetEvent("rsg-companions:client:revivecompanion")
AddEventHandler("rsg-companions:client:revivecompanion", function(data)
    if companionPed ~= 0 and not IsEntityDead(cache.ped) then
        local playercoords = GetEntityCoords(cache.ped)
        local companioncoords = GetEntityCoords(companionPed)
        local distance = #(playercoords - companioncoords)

        if IsEntityDead(companionPed) then
            if distance > 2.5 then lib.notify({ title = locale('cl_error_pet_too_far'), type = 'error', duration = 7000 }) return end
            local itemReviveList = {Config.AnimalRevive, 'horse_reviver'}
            local itemRevive = findFirstItem(itemReviveList)
            local hasItem = RSGCore.Functions.HasItem(itemRevive)
            if not hasItem then lib.notify({ title = locale('cl_revive_need_item')..' '.. RSGCore.Shared.Items[tostring(itemRevive)].label, duration = 7000, type = 'error' }) return end
            RequestControl(companionPed)
            local ModelHash = "p_cs_syringe01x" -- consumable_horse_stimulant
            syringePlayerAnim(playercoords, ModelHash)
            Wait(3000)
            ClearPedTasks(cache.ped)
            FreezeEntityPosition(cache.ped, false)
            TriggerServerEvent('rsg-companions:server:revivecompanion', itemRevive)
            for k, v in pairs(itemsprop) do
                if v.syringeitem and DoesEntityExist(v.syringeitem) then
                    SetEntityAsNoLongerNeeded(v.syringeitem)
                    DeleteEntity(v.syringeitem)
                end
                itemsprop[k] = nil
            end
            SpawnCompanion()
        else
            lib.notify({ title = locale('cl_error_pet_not_injured_dead'), type = 'error', duration = 7000 })
        end
    else
        lib.notify({ title = locale('cl_error_pet_out'), type = 'error', duration = 7000 })
    end
end)

----------------------------
-- hunt mode
----------------------------
-- target pet
local function ReturnKillToPlayer(fetchedKill, player)
    local coords = GetEntityCoords(player)
    TaskGoToCoordAnyMeans(companionPed, coords.x, coords.y, coords.z, 1.5, 0, 0, 786603, 0xbf800000)
    while true do
        Wait(2000)
        coords = GetEntityCoords(player)
        local coords2 = GetEntityCoords(companionPed)
        TaskGoToCoordAnyMeans(companionPed, coords.x, coords.y, coords.z, 1.5, 0, 0, 786603, 0xbf800000) --this might have been causing the pet to freeze up by calling it so much
        local dist = #(coords - coords2)
        if dist <= 2.0 then
            DetachEntity(fetchedObj)
            Wait(100)
            SetEntityAsMissionEntity(fetchedObj, true)
            PlaceObjectOnGroundProperly(fetchedObj)
            Wait(1000)
            FreezeEntityPosition(fetchedObj, true)
            SetModelAsNoLongerNeeded(fetchedObj)

            Retrieving = false
            moveCompanionToPlayer(companionPed, player)
            break
        end
    end
end

local function RetrieveKill(ClosestPed)
	fetchedObj = ClosestPed
	local TaskedToMove = false
	local coords = GetEntityCoords(fetchedObj)

    if not DoesEntityExist(companionPed) or IsEntityDead(companionPed) then lib.notify({ title = locale('cl_error_no_pet'), type = 'error', duration = 7000 }) return end
    RSGCore.Functions.TriggerCallback('rsg-companions:server:GetActiveCompanion', function(data)
        if data and data.active ~= 0 then
            local companionsDada = json.decode(data.companiondata) or {}

            if companionsDada.hunger < 10 or companionsDada.thirst < 10 then lib.notify({ title = locale('cl_error_retrieve'), type = 'error', duration = 7000 })return end
            if #(coords - GetEntityCoords(companionPed)) > Config.SearchRadius then lib.notify({ title = locale('cl_error_retrieve_distance'), type = 'error', duration = 7000 }) return end
            TaskGoToCoordAnyMeans(companionPed, coords.x, coords.y, coords.z, 2.0, 0, 0, 786603, 0xbf800000)
            Retrieving = true
            if Config.Debug then print(locale('cl_print_retrieve')) end
            while true do
                Wait(2000)
                local petCoords = GetEntityCoords(companionPed)
                coords = GetEntityCoords(fetchedObj)
                local dist = #(coords - petCoords)
                if dist <= 2.5 then
                    AttachEntityToEntity(fetchedObj, companionPed, GetPedBoneIndex(companionPed, 21030), 0.14, 0.14, 0.09798, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
                    RetrievedEntities[fetchedObj] = true
                    ReturnKillToPlayer(fetchedObj, cache.ped)
                    break
                else
                    local taskStatus = GetScriptTaskStatus(companionPed, 0x8AA1593C) -- TASK_GO_TO_COORD_ANY_MEANS
                    if taskStatus ~= 1 and taskStatus ~= 0 then
                        TaskGoToCoordAnyMeans(companionPed, coords.x, coords.y, coords.z, 2.0, 0, 0, 786603, 0xbf800000)
                    end
                end
            end
        else
            lib.notify({ title = locale('cl_error_retrieve_no_companions'), type = 'error', duration = 7000 })
        end
    end)
end

local function GetClosestAnimalPed(playerPed, radius)
	local playerCoords = GetEntityCoords(playerPed)
	local itemset = CreateItemset(true)
	local size = Citizen.InvokeNative(0x59B57C4B06531E1E, playerCoords, radius, itemset, 1, Citizen.ResultAsInteger())
	local closestPed
	local minDist = radius
	if size > 0 then
		for i = 0, size - 1 do
			local ped = GetIndexedItemInItemset(i, itemset)
			if playerPed ~= ped then
				local pedType = GetPedType(ped)
				local model = GetEntityModel(ped)
				if pedType == 28 and IsEntityDead(ped) and not RetrievedEntities[ped] and Config.Animals[model] then
					local pedCoords = GetEntityCoords(ped)
					local distance = #(playerCoords - pedCoords)
					if distance < minDist then
						closestPed = ped
						minDist = distance
					end
				end
			end
		end
	end
	if IsItemsetValid(itemset) then
		DestroyItemset(itemset)
	end
	return closestPed
end

local function GetClosestFightingPed(playerPed, radius)
	local playerCoords = GetEntityCoords(playerPed)
	local itemset = CreateItemset(true)
	local size = Citizen.InvokeNative(0x59B57C4B06531E1E, playerCoords, radius, itemset, 1, Citizen.ResultAsInteger())
	local closestPed
	local minDist = radius
	if size > 0 then
		for i = 0, size - 1 do
			local ped = GetIndexedItemInItemset(i, itemset)
			if playerPed ~= ped and playerPed ~= companionPed then
				local pedType = GetPedType(ped)
				local model = GetEntityModel(ped)
				local pedCoords = GetEntityCoords(ped)
				local distance = #(playerCoords - pedCoords)
				if IsPedInCombat(playerPed, ped) then
					closestPed = ped
					minDist = distance
				end
			end
		end
	end
	if IsItemsetValid(itemset) then
		DestroyItemset(itemset)
	end
	return closestPed
end

-- Main Thread - Checks if animal can hunt or is checks timers, etc. -- hungry, 
CreateThread(function()
	while true do
        local sleep = 5000
        if not companionPed then return end
        if companionPed ~= 0 then
            if not Config.PetAttributes.RaiseAnimal then
                if companionPed and not Retrieving and HuntMode then
                    local ClosestPed = GetClosestAnimalPed(cache.ped, Config.PetAttributes.SearchRadius)
                    local pedType = GetPedType(ClosestPed)
                    if pedType == 28 and IsEntityDead(ClosestPed) and not RetrievedEntities[ClosestPed] then
                        local whoKilledPed = GetPedSourceOfDeath(ClosestPed)
                        if cache.ped == whoKilledPed then -- Make sure the dead animal was killed by player or else it will try to steal other players hunts
                            local model = GetEntityModel(ClosestPed)
                            for k, v in pairs(Config.Animals) do
                                if model == k then
                                    RetrieveKill(ClosestPed)
                                end
                            end
                        else
                            RetrievedEntities[ClosestPed] = true --Even though it wasn't retrieved, I do this so it stops trying to check if it should retrieve this ped
                        end
                        sleep = 1000
                    end
                end
            else
                if companionPed and not Retrieving and companionxp >= Config.TrickXp.Hunt and HuntMode then
                    local ClosestPed = GetClosestAnimalPed(cache.ped, Config.PetAttributes.SearchRadius)
                    local pedType = GetPedType(ClosestPed)
                    if pedType == 28 and IsEntityDead(ClosestPed) and not RetrievedEntities[ClosestPed] then
                        local whoKilledPed = GetPedSourceOfDeath(ClosestPed)
                        if cache.ped == whoKilledPed then -- Make sure the dead animal was killed by player or else it will try to steal other players hunts
                            local model = GetEntityModel(ClosestPed)
                            for k, v in pairs(Config.Animals) do
                                if model == k then
                                    RetrieveKill(ClosestPed)
                                end
                            end
                        else
                            RetrievedEntities[ClosestPed] = true --Even though it wasn't retrieved, I do this so it stops trying to check if it should retrieve this ped
                        end
                        sleep = 1000
                    end
                end
            end
            if Config.PetAttributes.DefensiveMode and recentlyCombat <= 0 then
                local enemyPed = GetClosestFightingPed(cache.ped, 50.0)
                local playerCoords = GetEntityCoords(cache.ped)
                if enemyPed then
                    ClearPedTasks(companionPed)
                    local targetCoords = GetEntityCoords(enemyPed)
                    local distance = #(playerCoords - targetCoords)
                    if distance <= 20.0 then
                        lib.notify({ title = locale('cl_defensive_attack'), type = 'info', duration = 7000 })
                        AttackTarget(enemyPed)
                    end
                elseif not enemyPed then
                    startThreatDetection()

                    -- local players = GetActivePlayers()
                    -- for _, playerId in ipairs(players) do
                    --     local targetPed = GetPlayerPed(playerId)
                    --     if targetPed ~= cache.ped then
                    --         local targetCoords = GetEntityCoords(targetPed)
                    --         local distance = #(playerCoords - targetCoords)
                    --         if distance <= 20.0 then
                    --             lib.notify({ title = locale('cl_defensive_attack_player'), type = 'info', duration = 7000 })
                    --             AttackTarget(targetPed)
                    --         end
                    --     end
                    -- end
                end
                recentlyCombat = 15
                sleep = 1000
            end
            if recentlyCombat > 0 then
                recentlyCombat = recentlyCombat - 1
            end
        else
            sleep = 10000 -- If there is no active animal, wait longer before checking again
        end
        Wait(sleep)
	end
end)

----------------------------
-- GAMES FOR ADD XP
----------------------------
-- BRING BONE
local function CleanBoneAnimation(prop, player)
    local coords = GetEntityCoords(player)
    TaskGoToCoordAnyMeans(companionPed, coords.x, coords.y, coords.z, 1.5, 0, 0, 786603, 0xbf800000)
    while true do
        Wait(2000)
        coords = GetEntityCoords(player)
        local coords2 = GetEntityCoords(companionPed)
        local dist = #(coords - coords2)
        if dist <= 2.0 then
            DetachEntity(prop)
            Wait(100)
            ClearPedTasks(companionPed)
            SetEntityAsMissionEntity(prop, true)
            PlaceObjectOnGroundProperly(prop)
            Wait(1000)
            FreezeEntityPosition(prop, true)
            SetModelAsNoLongerNeeded(prop)
            Retrieving = false
            moveCompanionToPlayer(companionPed, player)
            break
        else
            local taskStatus = GetScriptTaskStatus(companionPed, 0x8AA1593C) -- TASK_GO_TO_COORD_ANY_MEANS
            if taskStatus ~= 1 and taskStatus ~= 0 then
                TaskGoToCoordAnyMeans(companionPed, coords.x, coords.y, coords.z, 1.5, 0, 0, 786603, 0xbf800000)
            end
        end
    end
    Wait(3000)
    -- if not Config.EnableTarget then
        local itemcoords = GetEntityCoords(prop)
        TaskTurnPedToFaceEntity(prop, cache.ped, 2000)
        Wait(500)
        TaskTurnPedToFaceEntity(cache.ped, prop, 5000)
        crouchInspectAnim()
        TriggerServerEvent('rsg-companions:server:addBone')
        for k, v in pairs(itemsprop) do
            if v.boneitem == prop and DoesEntityExist(v.boneitem) then
                SetEntityAsNoLongerNeeded(v.boneitem)
                DeleteEntity(v.boneitem)
            end
            itemsprop[k] = nil
        end
    -- end
    TriggerServerEvent('rsg-companions:server:useitemspet', Config.AnimalBone)
end

local function RetrieveBone(ClosestBone)
	local Obj = ClosestBone
	local TaskedToMove = false
	local coords = GetEntityCoords(Obj)

    if not DoesEntityExist(companionPed) or IsEntityDead(companionPed) then lib.notify({ title = locale('cl_error_no_retrieve_bone'), type = 'error', duration = 7000 }) return end
	FreezeEntityPosition(companionPed, false)
    ClearPedTasks(companionPed)

    RSGCore.Functions.TriggerCallback('rsg-companions:server:GetActiveCompanion', function(data)
        if data and data.active ~= 0 then
            local companionsDada = json.decode(data.companiondata) or {}
            if companionsDada.hunger < 20 or companionsDada.thirst < 20 then lib.notify({ title = locale('cl_error_retrieve_bone'), type = 'error', duration = 7000 }) return  end
            if #(coords - GetEntityCoords(companionPed)) > Config.Bone.MaxDist then lib.notify({ title = locale('cl_error_retrieve_bone_distance'), type = 'error', duration = 7000 }) return end

            TaskGoToCoordAnyMeans(companionPed, coords.x, coords.y, coords.z, 2.0, 0, 0, 786603, 0xbf800000)
            Retrieving = true

            if Config.Debug then print(locale('cl_print_retrieve_bone')) end
            while true do
                Wait(2000)
                local petCoords = GetEntityCoords(companionPed)
                coords = GetEntityCoords(Obj)
                local dist = #(coords - petCoords)
                if dist <= 2.5 then
                    if companionsDada.companionxp >= Config.TrickXp.Bone then
                        AttachEntityToEntity(Obj, companionPed, GetPedBoneIndex(companionPed, 21030), 0.14, 0.14, 0.09798, 90.0, 0.0, 0.0, true, true, false, true, 1, true)
                        RetrievedEntities[Obj] = true
                        CleanBoneAnimation(Obj, cache.ped)
                    else
                        local chance = math.random(1, 100)
                        if chance >= (100 - Config.Bone.LostTraining) then
                            Wait(5000)
                            ClearPedTasks(companionPed)
                            lib.notify({ title = locale('cl_error_lost_retrieve_bone'), type = 'error', duration = 7000 })
                            TriggerEvent('rsg-companions:client:companionactionslay', companionPed, 'amb_creature_mammal@world_dog_resting@stand_enter', 'enter_front')
                            Wait(5000)
                            ClearPedTasks(companionPed)

                            SetEntityAsNoLongerNeeded(Obj)
                            DeleteEntity(Obj)
                            RetrievedEntities[Obj] = false
                            Retrieving = false
                            moveCompanionToPlayer(companionPed, cache.ped)

                        else
                            AttachEntityToEntity(Obj, companionPed, GetPedBoneIndex(companionPed, 21030), 0.14, 0.14, 0.09798, 90.0, 0.0, 0.0, true, true, false, true, 1, true)
                            RetrievedEntities[Obj] = true
                            CleanBoneAnimation(Obj, cache.ped)
                        end
                    end
                    break
                else
                    local taskStatus = GetScriptTaskStatus(companionPed, 0x8AA1593C) -- TASK_GO_TO_COORD_ANY_MEANS
                    if taskStatus ~= 1 and taskStatus ~= 0 then
                        TaskGoToCoordAnyMeans(companionPed, coords.x, coords.y, coords.z, 2.0, 0, 0, 786603, 0xbf800000)
                    end
                end
            end
        else
            lib.notify({ title = locale('cl_error_no_pet_retrieve_bone'), type = 'error', duration = 7000 })
        end
    end)
end

local function PlayerBoneAnimation()

    SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
    ClearPedTasks(cache.ped)
    Wait(100)

    local pcoords = GetEntityCoords(cache.ped)
    local boneIndex = GetEntityBoneIndexByName(cache.ped, "SKEL_R_Finger00")

    local forwardVector = GetEntityForwardVector(cache.ped)
    local forceMultiplier = math.random(3, 6) -- Fuerza aleatoria para un lanzamiento más natural
    local forceX = forwardVector.x * forceMultiplier
    local forceY = forwardVector.y * forceMultiplier
    local forceZ = 2.0 -- Altura inicial del lanzamiento

    local boneitem = CreateObject(`p_humanskeleton02x_upperarmr`, pcoords.x, pcoords.y, pcoords.z, true, true, true)
    table.insert(itemsprop, {boneitem = boneitem} )
    AttachEntityToEntity(boneitem, cache.ped, boneIndex, 0.10, -0.04, -0.01, -15.0, 90.0, 180.0, true, false, true, false, 0, true)

    local dict = "mech_weapons_thrown@base"
    local waiting = 0
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        waiting = waiting + 100
        Wait(100)
        if waiting > 5000 then
            lib.notify({ title = locale('cl_error_no_pet_player_bone'), type = 'error', duration = 7000 })
            return -- Cambiar `break` por `return` para evitar que el código continúe en caso de error.
        end
    end

    local time = math.random(1000, 3600)
    local test = math.random(1, 8)
    TaskPlayAnim(cache.ped, dict, "throw_m_fb_stand", test or 8.0, test or -8.0, time or -1, 0, 0, false, false, false)
    Wait(300)

    local velocity = forwardVector * math.random(10, 20) -- Adjust velocity as needed
    DetachEntity(boneitem, true, true) -- Desvincular el objeto del jugador
    ApplyForceToEntity(boneitem, 1, forceX, forceY, forceZ, 0, 0, 0, boneIndex, false, false, false, true, true)
    SetEntityVelocity(boneitem, velocity.x, velocity.y, velocity.z)
    SetEntityRotation(boneitem, math.random(1, 360), math.random(1, 360), math.random(1, 360), 0, true)

    local timeout = GetGameTimer() + 10000
    while GetGameTimer() < timeout do
        Wait(100)
        if #(vector3(GetEntityVelocity(boneitem))) < 0.1 then
            break
        end
    end

    SetEntityAsNoLongerNeeded(boneitem)

    CreateThread(function()

        Wait(Config.Bone.AutoDelete) -- Tiempo antes de eliminar el hueso (60 segundos)
        if boneitem and DoesEntityExist(boneitem) then
            DeleteEntity(boneitem)    -- Eliminación del objeto
            for k, v in pairs(itemsprop) do    -- Limpieza de la tabla de objetos
                if v.boneitem == boneitem then
                    itemsprop[k] = nil
                end
                break
            end
            -- Notificar que el hueso fue eliminado (opcional)
            lib.notify({ title = locale('cl_lost_bone'), description = locale('cl_lost_bone_des'), type = 'info', duration = 7000  })
        end
    end)

    -- if Config.EnableTarget then
    --     local targetOptions = {
    --         {   name = 'prop_bone_actions',
    --             icon = 'fa-solid fa-book',
    --             label = locale('cl_take_bone'),
    --             onSelect = function()

    --                 TaskTurnPedToFaceEntity(cache.ped, boneitem, 5000)

    --                 crouchInspectAnim()

    --                 TriggerServerEvent("rsg-companions:server:addBone")
    --                 SetEntityAsNoLongerNeeded(boneitem)
    --                 DeleteEntity(boneitem)
    --                 for k, v in pairs(itemsprop) do
    --                     if v.boneitem == boneitem then
    --                         itemsprop[k] = nil
    --                     end
    --                 end
    --                 Wait(3000) -- Spam protect
    --             end,
    --             onExit = function()
    --             end,
    --             distance = 2.0
    --         },
    --     }
    --     exports.ox_target:addLocalEntity(boneitem, targetOptions)
    -- end

    RetrieveBone(boneitem)
end

local function StartBone()
    TriggerServerEvent("rsg-companions:server:removeBone")
    PlayerBoneAnimation()
    Wait(1000)
    ClearPedTasks(cache.ped)
end

RegisterNetEvent('rsg-companions:client:playerbonecompanion')
AddEventHandler('rsg-companions:client:playerbonecompanion', function()
    StartBone()
end)

-- HIDE & SEARCH BONE
local buriedBoneCoords = nil

RegisterNetEvent("rsg-companions:client:buryBone", function()
    if not companionPed or IsEntityDead(cache.ped) then return end
    lib.notify({ title = locale('cl_buried'), description = locale('cl_buried_des'), type = 'info' })
    petStay(companionPed)
    SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
    ClearPedTasks(cache.ped)
    lib.notify({ title = locale('cl_buried_time'), description = locale('cl_buried_time_des'), type = 'info' })
    Wait(Config.buriedBone.time)
    if Config.buriedBone.DoMiniGame then
        local success = lib.skillCheck({{areaSize = 50, speedMultiplier = 0.5}}, {'w', 'a', 's', 'd'})
        if not success then
            local numberGenerator = math.random(1, 100)
            if numberGenerator <= tonumber(Config.buriedBone.lostBone) then
                TriggerServerEvent("rsg-companions:server:removeBone")
                buriedBoneCoords = nil
            end
            SetPedToRagdoll(cache.ped, 1000, 1000, 0, 0, 0, 0)
            Wait(1000)
            ClearPedTasks(cache.ped)
            return
        end
    end

    local coords = GetEntityCoords(cache.ped)
    crouchInspectAnim()
    TriggerServerEvent("rsg-companions:server:removeBone")
    lib.notify({ title = locale('cl_buried_player'), description = locale('cl_buried_player_des'), type = 'info' })
    Wait(5000)
    buriedBoneCoords = coords
    lib.notify({ title = locale('cl_buried_hide'), description = locale('cl_buried_hide_des'), type = 'success' })
end)

RegisterNetEvent("rsg-companions:client:findBuriedBone", function()
    if not buriedBoneCoords or not companionPed or IsEntityDead(cache.ped) then lib.notify({ title = locale('cl_error_buried_hide'), description = locale('cl_error_buried_hide_des'), type = 'error' }) return end

    ClearPedTasks(companionPed)
    FreezeEntityPosition(companionPed, false)
    Wait(100)
    TaskGoStraightToCoord(companionPed, buriedBoneCoords.x, buriedBoneCoords.y, buriedBoneCoords.z, 2.0, 8000, 0.0, 0.0)
    lib.notify({ title = locale('cl_buried_find'), description = locale('cl_buried_find_des'), type = 'info' })
    Wait(15000)
    TaskPlayAnim(companionPed, 'amb_creature_mammal@world_dog_digging@base', 'base', 1.0, 1.0, -1, 1, 0, false, false, false)
    Wait(4000)
    ClearPedTasksImmediately(companionPed)

    local roll = math.random(1, 100)
    if roll <= (Config.buriedBone.findespecial + (companionLevel * 2)) then
        -- Encontró algo útil
        TriggerServerEvent('rsg-companions:server:addxp', 'find_buried')
        TriggerEvent("rsg-companions:client:digRandomItem")
        lib.notify({ title = locale('cl_buried_digrandom'), description = locale('cl_buried_digrandom_des'), type = 'success' })
    elseif roll <= (Config.buriedBone.findburied + companionLevel) then
        -- Encontró basura
        TriggerServerEvent('rsg-companions:server:addxp', 'find_buried')
        TriggerServerEvent("rsg-companions:server:giveItem", Config.AnimalBone) -- Asegurate que tu server.lua tenga esta función
        lib.notify({ title = locale('cl_buried_give'), description = locale('cl_buried_give_des'), type = 'warning' })
    else
        -- No encontró nada
        lib.notify({ title = locale('cl_buried_fail'), description = locale('cl_buried_fail_des'), type = 'error' })
    end
    Wait(1000)
    moveCompanionToPlayer(companionPed, cache.ped)

    lib.notify({ title = locale('cl_buried_loc'), description = locale('cl_buried_loc_des'), type = 'success' })
    buriedBoneCoords = nil
end)

RegisterNetEvent("rsg-companions:client:digRandomItem", function()
    if not companionPed or IsEntityDead(cache.ped) then return end
    ClearPedTasks(companionPed)
    Wait(100)

    local coords = GetEntityCoords(companionPed)
    local randomOffset = vector3(math.random(Config.digrandom.min, Config.digrandom.max), math.random(Config.digrandom.min, Config.digrandom.max), 0.0)
    local digSpot = coords + randomOffset

    TaskGoStraightToCoord(companionPed, digSpot.x, digSpot.y, digSpot.z, 2.0, 8000, 0.0, 0.0)
    lib.notify({ title = locale('cl_digrandom'), description = locale('cl_digrandom_des'), type = 'info' })
    Wait(7000)
    TaskPlayAnim(companionPed, 'amb_creature_mammal@world_dog_digging@base', 'base', 1.0, 1.0, -1, 1, 0, false, false, false)
    Wait(4000)
    ClearPedTasksImmediately(companionPed)
    Wait(1000)
    moveCompanionToPlayer(companionPed, cache.ped)

    local roll = math.random(1, 100)
    if roll <= (Config.digrandom.lostreward + (companionLevel * 2)) then
        crouchInspectAnim()
        TriggerServerEvent('rsg-companions:server:addxp', 'dig_random')
        TriggerServerEvent("rsg-companions:server:giveRandomItem")
        lib.notify({ title = locale('cl_digrandom_give'), description = locale('cl_digrandom_give_des'), type = 'success' })
    else
        lib.notify({ title = locale('cl_digrandom_fail'), description = locale('cl_digrandom_fail_des'), type = 'error' })
    end
end)

-- SEARCH TREASURE
local currentHuntStep = 0
local totalHuntSteps = 0
local treasurePoints = {}
local treasureInProgress = false
local headingToTarget = false
local waitingForPlayer = false
local isTreasure = false

local function checkProximityToTreasure(coords)
    for _, prop in ipairs(itemsprop) do
        if prop.treasure then
            local treasureCoords = GetEntityCoords(prop.treasure, true)
            local distance = #(coords - treasureCoords)
            if distance <= Config.TreasureHunt.HoleDistance then
                Wait(500)
                lib.notify({ title = locale('cl_lang_1'), type = 'info', duration = 7000 })
                return true
            end
        end
    end
    return false
end

local function loadTreasureModelAndAnim(treasureModel)
    RequestModel(treasureModel)
    while not HasModelLoaded(treasureModel) do Wait(50) end
    RequestAnimDict("amb_work@world_human_gravedig@working@male_b@base")
    while not HasAnimDictLoaded("amb_work@world_human_gravedig@working@male_b@base") do
        Wait(100)
    end
end

local function handleTreasureFound()
    local chance = math.random(100)
    if chance <= Config.TreasureHunt.lostTreasure then
        crouchInspectAnim()
        TriggerServerEvent('rsg-companions:server:addxp', 'treasure')
        TriggerServerEvent("rsg-companions:server:giveTreasureItem")
        lib.notify({ title = locale('cl_treasurehunt_give'), description = locale('cl_treasurehunt_give_des'), type = 'success' })
    else
        lib.notify({ title = locale('cl_treasurehunt_empty'), type = 'info' })
    end
end

local function createShovelAndAttach()
    local playerCoords = GetEntityCoords(cache.ped)
    local boneIndex = GetEntityBoneIndexByName(cache.ped, "SKEL_R_Hand")
    local shovelObject = CreateObject(`p_shovel02x`, playerCoords, true, true, true)
    table.insert(itemsprop, { shovel = shovelObject })
    SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
    AttachEntityToEntity(shovelObject, cache.ped, boneIndex, 0.0, -0.19, -0.089, 274.1899, 483.89, 378.40, true, true, false, true, 1, true)
    return shovelObject
end

local function cleanUpTreasure(treasureObject)
    SetEntityAsNoLongerNeeded(treasureObject)
    CreateThread(function()
        Wait(Config.TreasureHunt.AutoDelete)
        if treasureObject and DoesEntityExist(treasureObject) then
            DeleteObject(treasureObject)
            for i = #itemsprop, 1, -1 do
                if itemsprop[i].treasure == treasureObject then
                    table.remove(itemsprop, i)
                end
                break
            end
        end
    end)
end

local function showSkillCheckShovel(entity)
    local coords = GetEntityCoords(entity, true)

    if checkProximityToTreasure(coords) then return end
    if isTreasure then return end

    isTreasure = true
    local waitrand = math.random(10000, 25000)
    local treasureModel = 'mp005_p_dirtpile_tall_unburied'
    loadTreasureModelAndAnim(treasureModel)
    local shovelObject = createShovelAndAttach()

    FreezeEntityPosition(cache.ped, true)
    TaskPlayAnim(cache.ped, "amb_work@world_human_gravedig@working@male_b@base", "base", 3.0, 3.0, -1, 1, 0, false, false, false)
    Wait(waitrand)

    local playerCoords = GetEntityCoords(cache.ped)
    local playerForwardVector = GetEntityForwardVector(cache.ped)
    local offsetX = 0.6
    local objectX = playerCoords.x + playerForwardVector.x * offsetX
    local objectY = playerCoords.y + playerForwardVector.y * offsetX
    local objectZ = playerCoords.z - 1

    local treasureObject = CreateObject(treasureModel, objectX, objectY, objectZ, true, true, false)
    table.insert(itemsprop, { treasure = treasureObject })
    handleTreasureFound()

    FreezeEntityPosition(cache.ped, false)
    ClearPedTasks(cache.ped)
    DeleteObject(shovelObject)
    isTreasure = false

    cleanUpTreasure(treasureObject)
    treasureInProgress = false
    treasurePoints = {}
    currentHuntStep = 0
    totalHuntSteps = 0
end

local function finishTreasureHunt(entity)
    lib.notify({ title = locale('cl_treasurehunt'), description = locale('cl_treasurehunt_des'), type = 'success' })
    -- local finalPos = treasurePoints[#treasurePoints]
    TaskPlayAnim(entity, 'amb_creature_mammal@world_dog_digging@base', 'base', 1.0, 1.0, -1, 1, 0, false, false, false)
    Wait(Config.TreasureHunt.digAnimTime)
    ClearPedTasksImmediately(entity)

    if Config.TreasureHunt.DoMiniGame then
        if Config.TreasureHunt.MiniGameShovel then
            showSkillCheckShovel(entity)
            return
        else
            local success = lib.skillCheck({{areaSize = 50, speedMultiplier = 0.5}}, {'w', 'a', 's', 'd'})
            if not success then
                local numberGenerator = math.random(1, 100)
                if numberGenerator <= tonumber(Config.TreasureHunt.lostTreasure) then
                    treasureInProgress = false
                    treasurePoints = {}
                    currentHuntStep = 0
                    totalHuntSteps = 0
                end
                SetPedToRagdoll(cache.ped, 1000, 1000, 0, 0, 0, 0)
                Wait(1000)
                ClearPedTasks(cache.ped)
                return
            end
        end
    end

    handleTreasureFound()

    treasureInProgress = false
    treasurePoints = {}
    currentHuntStep = 0
    totalHuntSteps = 0
end

local function moveToClue(index, entity)
    if not entity or not DoesEntityExist(entity) then return end
    if not treasurePoints[index] then return end
    local target = treasurePoints[index]
    local targetCoords = vector3(target.x, target.y, target.z)    -- Get target coordinates

    if Config.TreasureHunt.blipClue then
        if gpsRoute ~= nil then ClearGpsMultiRoute() end
        StartGpsMultiRoute(GetHashKey("COLOR_BLUE"), true, true)    -- Start new GPS route to target
        AddPointToGpsMultiRoute(targetCoords.x, targetCoords.y, targetCoords.z)
        SetGpsMultiRouteRender(true)    -- Set the route to render on the map
        gpsRoute = true
    end

    headingToTarget = true
    waitingForPlayer = false
    TaskGoToCoordAnyMeans(entity, target.x, target.y, target.z, 2.0, 0, 0, 786603, 0)

    lib.notify({title = locale('cl_treasurehunt_follow'),description = string.format(locale('cl_treasurehunt_follow_des')..' %d '..locale('cl_treasurehunt_follow_desc')..' %d', index, totalHuntSteps), type = 'info'})
    ClearPedTasksImmediately(entity)
    TaskPlayAnim(entity, 'amb_creature_mammal@world_dog_howling_sitting@base', 'base', 1.0, 1.0, -1, 1, 0, false, false, false)
    Wait(Config.TreasureHunt.sniAnimTime)
    ClearPedTasksImmediately(entity)

    if Config.Debug then print(locale('cl_print_treasurehunt_move')..' ' .. index) end

    CreateThread(function()
        local step = index
        local lastReissueTime = GetGameTimer()
        local clueStartTime = GetGameTimer()
        local clueTimeout = 1200000  -- 60 segundos por pista

        while treasureInProgress and currentHuntStep == step do
            if not companionPed then return end
            Wait(1000)

            local dogPos = GetEntityCoords(entity)
            local playerPos = GetEntityCoords(cache.ped)
            local distToTarget = #(dogPos - target)
            local distToPlayer = #(dogPos - playerPos)

            if GetGameTimer() - lastReissueTime > 10000 and headingToTarget then
                if Config.Debug then print(locale('cl_print_treasurehunt_move_b')) end
                TaskGoToCoordAnyMeans(entity, targetCoords.x, targetCoords.y, targetCoords.z, 2.0, 0, 0, 786603, 0)
                lastReissueTime = GetGameTimer()
            end

            if GetGameTimer() - clueStartTime > clueTimeout and headingToTarget then
                lib.notify({ title = locale('cl_treasurehunt_fail'), description = locale('cl_treasurehunt_fail_des'), type = 'warning' })
                ClearPedTasksImmediately(entity)
                TaskPlayAnim(entity, 'amb_creature_mammal@world_dog_sniffing_ground@base', 'base', 1.0, 1.0, -1, 1, 0, false, false, false)
                Wait(Config.TreasureHunt.sniAnimTime)
                ClearPedTasksImmediately(entity)
                TaskGoToCoordAnyMeans(entity, targetCoords.x, targetCoords.y, targetCoords.z, 2.0, 0, 0, 786603, 0)
                clueStartTime = GetGameTimer()
                lastReissueTime = GetGameTimer()
            end

            if headingToTarget and distToPlayer > Config.TreasureHunt.maxdistToPlayer then
                ClearPedTasksImmediately(entity)
                TaskGoToEntity(entity, cache.ped, -1, 2.0, 2.0, 0, 0)
                lib.notify({ title = locale('cl_treasurehunt_check'), description = locale('cl_treasurehunt_check_des'), type = 'warning' })
                headingToTarget = false
                waitingForPlayer = true

            elseif waitingForPlayer and distToPlayer <= Config.TreasureHunt.mindistToPlayer then
                ClearPedTasksImmediately(entity)
                TaskPlayAnim(entity, 'amb_creature_mammal@world_dog_guard_growl@base', 'base', 1.0, 1.0, -1, 1, 0, false, false, false)
                Wait(Config.TreasureHunt.sniAnimTime)
                ClearPedTasksImmediately(entity)
                lib.notify({ title = locale('cl_treasurehunt_check_player'), description = locale('cl_treasurehunt_check_player_des'), type = 'info' })
                TaskGoToCoordAnyMeans(entity, target.x, target.y, target.z, 2.0, 0, 0, 786603, 0)
                headingToTarget = true
                waitingForPlayer = false
                lastReissueTime = GetGameTimer()
            end

            if distToTarget < Config.TreasureHunt.distToTarget then
                ClearPedTasksImmediately(entity)
                local roll = math.random(1, 100)
                if roll <= 25 then
	                TaskPlayAnim(entity, 'amb_creature_mammal@world_dog_howling_sitting@base', 'base', 1.0, 1.0, -1, 1, 0, false, false, false)
                    Wait(Config.TreasureHunt.anim.howAnimTime)
                elseif roll <= 50 then
                    TaskPlayAnim(entity, 'amb_creature_mammal@world_dog_sniffing_ground@base', 'base', 1.0, 1.0, -1, 1, 0, false, false, false)
                    Wait(Config.TreasureHunt.anim.clueWaitTime)
                elseif roll <= 75 then
                    TaskPlayAnim(entity, 'amb_creature_mammal@world_dog_guard_growl@base', 'base', 1.0, 1.0, -1, 1, 0, false, false, false)
                    Wait(Config.TreasureHunt.anim.guaAnimTime)
                else
                    TaskPlayAnim(entity, 'amb_creature_mammal@world_dog_digging@base', 'base', 1.0, 1.0, -1, 1, 0, false, false, false)
                    Wait(Config.TreasureHunt.anim.clueWaitTime)
                end

                ClearPedTasksImmediately(entity)

                if Config.TreasureHunt.blipClue then
                    ClearGpsMultiRoute()
                    gpsRoute = nil
                    -- Create a temporary blip
                    local blipClue = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, targetCoords.x, targetCoords.y, targetCoords.z)
                    Citizen.InvokeNative(0x662D364ABF16DE2F, blipClue, Config.Blip.Color_modifier)
                    SetBlipSprite(blipClue, Config.Blip.ClueSprite, true)
                    SetBlipScale(blipClue, Config.Blip.ClueScale)
                    Citizen.InvokeNative(0x45FF974EEA1DCE36, blipClue, true)
                    Citizen.InvokeNative(0x9CB1A1623062F402, blipClue, Config.Blip.ClueName)

                    lib.notify({ title = locale('cl_treasurehunt_find'), description = locale('cl_treasurehunt_find_des'), type = 'success', duration = 5000 })
                    CreateThread(function() Wait(Config.Blip.ClueTime) if blipClue and DoesBlipExist(blipClue) then RemoveBlip(blipClue) end end)
                end

                currentHuntStep = currentHuntStep + 1

                if currentHuntStep > totalHuntSteps then
                    finishTreasureHunt(entity)
                else
                    Wait(500)
                    moveToClue(currentHuntStep, entity)
                end
                break
            end
        end
    end)
end

local function isWaterAtCoords(coords)
    local waterType = Citizen.InvokeNative(0x5BA7A68A346A5A91, coords.x, coords.y, coords.z)
    for k,v in pairs(Config.WaterTypes) do 
        if waterType == Config.WaterTypes[k]["waterhash"] then
            return true
        end
    end
    return false
end

local function generateRandomTreasureRoute(startPos, steps)
    local route = {}
    local lastPos = startPos
    local attempts = 0

    for i = 1, steps do
        
        local validPoint = false
        local newPoint
        while not validPoint and attempts < 100 do
            local dist = math.random(Config.TreasureHunt.minDistance, Config.TreasureHunt.maxDistance)
            local angle = math.rad(math.random(0, 360))
            local offsetX = math.cos(angle) * dist
            local offsetY = math.sin(angle) * dist
            local newX = lastPos.x + offsetX
            local newY = lastPos.y + offsetY
            local foundGround, groundZ = GetGroundZFor_3dCoord(newX, newY, lastPos.z + 100.0, 0)
            local newZ = foundGround and groundZ or lastPos.z
            newPoint = vector3(newX, newY, newZ)
            if not isWaterAtCoords(newPoint) then
                validPoint = true
            end
            attempts = attempts + 1
        end
        if newPoint then
            table.insert(route, newPoint)
            lastPos = newPoint
        else
            if Config.Debug then print("No se pudo encontrar una coordenada válida que no esté en agua.") end
            break
        end
    end

    if Config.Debug then print(locale('cl_print_treasurehunt_route'), tostring(#route) .. locale('cl_print_treasurehunt_route_b')) end
    return route
end

function startTreasureHunt(entity)
    if treasureInProgress then lib.notify({ title = locale('cl_treasurehunt_inProgress'), type = 'error' }) return end
    if not entity or not DoesEntityExist(entity) or IsEntityDead(cache.ped) then lib.notify({ title = locale('cl_error_treasurehunt'), description = locale('cl_error_treasurehunt_des'), type = 'error' }) return end

    treasureInProgress = true
    currentHuntStep = 1
    totalHuntSteps = math.random(Config.TreasureHunt.minSteps, Config.TreasureHunt.maxSteps)

    local playerCoords = GetEntityCoords(cache.ped)
    treasurePoints = generateRandomTreasureRoute(playerCoords, totalHuntSteps)
    moveToClue(currentHuntStep, entity)
end

----------------------------------------
-- get location STABLE INFO
------------------------------------------
RegisterNetEvent('rsg-companions:client:getcompanionlocation', function()
    RSGCore.Functions.TriggerCallback('rsg-companions:server:GetAllCompanions', function(results)
        if results ~= nil then
            local options = {}
            for i = 1, #results do
                local result = results[i]
                local AnimalData = json.decode(results[i].companiondata) or {}
                options[#options + 1] = {
                    title = locale('cl_companion')..': '..AnimalData.name,
                    description = locale('cl_companion_is_stabled')..' '..result.stable..' '..locale('cl_companion_active')..': '..result.active,
                    icon = 'fa-solid fa-book-atlas',
                }
            end
            lib.registerContext({
                id = 'showcompanion_menu',
                title = locale('cl_companion_find'),
                position = 'top-right',
                options = options
            })
            lib.showContext('showcompanion_menu')
        else
            lib.notify({ title = locale('cl_error_companion_no'), type = 'error', duration = 7000 })
        end
    end)
end)

-- STABLE MENU OX_LIB
RegisterNetEvent('rsg-companions:client:stablemenu', function(stableid)
    if not stableid then return end
    lib.registerContext({
        id = 'stable_companions_menu',
        title = locale('cl_menu_stable'),
        options = {
            {
                title = locale('cl_menu_companion_view_companions'),
                description = locale('cl_menu_companion_view_companions_sub'),
                icon = 'fa-solid fa-eye',
                event = 'rsg-companions:client:menu',
                args = { stableid = stableid },
                arrow = true,
                metadata = { {label = locale('cl_menu_companion_view_companions'), value = locale('txt_menuinfo')} },
            },
            {
                title = locale('cl_menu_companion_sell'),
                description = locale('cl_menu_companion_sell_sub'),
                icon = 'fa-solid fa-coins',
                event = 'rsg-companions:client:MenuDel',
                args = { stableid = stableid },
                arrow = true,
                metadata = { {label = locale('cl_menu_companion_sell'), value = locale('txt_MenuDel')} },
            },
            {
                title = locale('cl_menu_companion_trade'),
                description = locale('cl_menu_companion_trade_sub'),
                icon = 'fa-solid fa-handshake',
                event = 'rsg-companions:client:tradecompanion',
                arrow = true,
                metadata = {  {label = locale('cl_menu_companion_trade'), value = locale('txt_tradepet')} },
            },
            {
                title = locale('cl_menu_companion_shop'),
                description = locale('cl_menu_companion_shop_sub'),
                serverEvent = 'rsg-companions:server:openShop',
                icon = 'fa-solid fa-shop',
                arrow = true,
                metadata = { {label = locale('cl_menu_companion_shop'), value = locale('txt_OpenPetShop')} },
            },
            {
                title = locale('cl_menu_companion_store_companion'),
                description = locale('cl_menu_companion_store_companion_sub'),
                icon = 'fa-solid fa-warehouse',
                event = 'rsg-companions:client:storecompanion',
                args = { stableid = stableid },
                arrow = true,
                metadata = { {label = locale('cl_menu_companion_store_companion'), value = locale('txt_storepet')} },
            },
        }
    })
    lib.showContext("stable_companions_menu")
end)

local function CompanionOptions(data)
    local menu = {
        {
            title = locale('cl_menu_companion_ride'),
            description = locale('cl_menu_companion_ride_sub'),
            icon = 'fa-solid fa-right-from-bracket',
            event = 'rsg-companions:client:SpawnCompanion',
            args = { player = data },
            arrow = true,
            metadata = { {label = locale('cl_menu_companion_ride'), value = locale('txt_storepet')} },
        },
        {
            title = locale('cl_menu_companion_rideoff'),
            description = locale('cl_menu_companion_rideoff_sub'),
            icon = 'fa-solid fa-door-open',
            onSelect = function()
                if not companionPed then return lib.notify({ title = locale('cl_error_companion_no'), type = 'error', duration = 7000 }) end
                SetClosestStableCompanionLocation()
                TriggerServerEvent('rsg-companions:server:fleeStoreCompanion', closestStable)
            end,
            arrow = true,
            metadata = { {label = locale('cl_menu_companion_rideoff'), value = locale('txt_storepet')} },
        },
        -- {
        --     title = locale('cl_menu_companion_customize'),
        --     description = locale('cl_menu_companion_customize_sub'),
        --     icon = 'fa-solid fa-screwdriver-wrench',
        --     event = 'rsg-companions:client:custShop',
        --     args = { player = data },
        --     arrow = true
        -- }
    }

    lib.registerContext({
        id = 'companions_options',
        title = locale('cl_menu_companion_view_companions'),
        position = 'top-right',
        menu = 'companions_view',
        onBack = function() end,
        options = menu
    })
    lib.showContext('companions_options')
end

-- companion menu active
RegisterNetEvent('rsg-companions:client:menu', function(data)
    local companions = lib.callback.await('rsg-companions:server:GetCompanion', false, data.stableid)
    if #companions <= 0 then lib.notify({ title = locale('cl_error_menu_no_companions'), type = 'error', duration = 7000 }) return end
    local options = {}

    for k, v in pairs(companions) do
        local AnimalData = json.decode(v.companiondata)
        options[#options + 1] = {
            title = AnimalData.name,
            description = locale('cl_menu_my_companion_gender') .. AnimalData.gender .. locale('cl_menu_my_companion_xp') .. AnimalData.companionxp .. locale('cl_menu_my_companion_active') .. v.active,
            icon = 'fa-solid fa-dog',
            arrow = true,
            onSelect = function()
                CompanionOptions(v)
            end
        }
    end

    lib.registerContext({
        id = 'companions_view',
        title = locale('cl_menu_my_companions'),
        position = 'top-right',
        menu = 'stable_companions_menu',
        onBack = function() end,
        options = options
    })
    lib.showContext('companions_view')
end)

--------------------------
-- Mypets
--------------------------
RegisterNetEvent('rsg-companions:client:mypetsactions', function()
    RSGCore.Functions.TriggerCallback('rsg-companions:server:GetActiveCompanion', function(data)
        if companionPed == 0 or IsEntityDead(cache.ped) then lib.notify({ title = locale('cl_error_menu_no_companions'), type = 'error', duration = 7000 }) return end
        if (data) then
            local companionsDada = json.decode(data.companiondata)
            Wait(100)
            local hunger = math.floor(companionsDada.hunger) or 0
            local thirst = math.floor(companionsDada.thirst) or 0
            local companionDirt = math.floor(companionsDada.dirt) or 0
            local happiness = math.floor(companionsDada.happiness) or 0
            local age = math.floor(companionsDada.age) or 0
            local xp = math.floor(companionsDada.companionxp) or 0
            local maxLifeDays = Config.CompanionDieAge or 0
            local lifeProgress = ( age / maxLifeDays ) * 100

            local companionHealth = GetEntityHealth(companionPed) or 0
            local companionMHealth = GetEntityMaxHealth(companionPed) or 0
            local companionMaxHealth = (companionHealth / companionMHealth) * 100
            local compStamina = GetPedStamina(companionPed) or 0
            local companionMStamina = GetPedMaxStamina(companionPed) or 0
            local companionMaxStamina = (compStamina / companionMStamina) * 100
            Wait(50)
            local itemReviveList = {Config.AnimalRevive, 'horse_reviver'}
            local itemrevivesend = findFirstItem(itemReviveList)
            local hasItem = RSGCore.Functions.HasItem(itemrevivesend)

            local options = {}
            for _, v in ipairs(statsCompanion) do
                if v.ped == companionPed then
                    local companionAgility = v.AGILITY or 0
                    local companionSpeed = v.SPEED or 0
                    local companionAcceleration = v.ACCELERATION or 0
                    local statsmetadata = {}
                    if not IsEntityDead(companionPed) then
                        statsmetadata = {
                            { label = locale('cl_stable_id'), value = data.stable}, -- Stable
                            { label = locale('cl_owner'), value = data.citizenid}, -- owner
                            { label = locale('cl_id_time'), value = age .. locale('cl_id_days'), progress = lifeProgress, colorScheme = '#99460e' },
                            { label = locale('cl_id_xp'), value = xp, progress = xp, colorScheme = '#e8a93f' },

                            { label = locale('cl_txtStats'), value = companionHealth, progress = companionMaxHealth, colorScheme = '#359d93'},-- compHealth
                            { label = locale('cl_happiness'), value = happiness, progress = happiness, colorScheme = '#eebd6b' },
                            { label = locale('cl_hunger'), value = hunger, progress = hunger, colorScheme = '#bfe6ef' },
                            { label = locale('cl_thirst'), value = thirst, progress = thirst, colorScheme = '#447695' },
                            { label = locale('cl_dirt'), value = companionDirt, progress = companionDirt, colorScheme = '#04082e' },

                            { label = locale('cl_txtStatsA'), value = compStamina, progress = companionMaxStamina, colorScheme = ''},
                            { label = locale('cl_txtStatsB'), value = companionAgility},
                            { label = locale('cl_txtStatsC'), value = companionSpeed },
                            { label = locale('cl_txtStatsD'), value = companionAcceleration },

                        }
                    else
                        statsmetadata = {
                            { label = locale('cl_stable_id'), value = data.stable}, -- Stable
                            { label = locale('cl_owner'), value = data.citizenid}, -- owner
                            { label = locale('cl_id_time'), value = age .. locale('cl_id_days'), progress = lifeProgress, colorScheme = '#99460e' },
                            { label = locale('cl_id_xp'), value = xp, progress = xp, colorScheme = '#e8a93f' },

                            { label = locale('cl_txtStats'), value = companionHealth, progress = companionMaxHealth, colorScheme = '#359d93'},
                        }
                    end

                    if Config.Debug then print(companionHealth, compStamina, companionAgility, companionSpeed, companionAcceleration, companionDirt) end

                    options[#options +1] = {
                        title = locale('cl_pet')..': '..companionsDada.name,
                        icon = 'fa-solid fa-circle-info',
                        event = 'rsg-companions:client:mypets',
                        progress = companionMaxHealth,
                        colorScheme = '#359d93',
                        metadata = statsmetadata,
                        arrow = true
                    }

                    statsmetadata = {}
                end
            end

            options[#options +1] = {
                disabled = true
            }

            if not IsEntityDead(companionPed) then
                options[#options +1] = {
                    title = locale('cl_storage_no_sleep'),
                    icon = 'fa-solid fa-moon',
                    onSelect = function()
                        Flee()
                    end,
                    arrow = true
                }
                options[#options +1] = {
                    title = locale('cl_follow'),
                    icon = 'fa-solid fa-person',
                    onSelect = function()
                        moveCompanionToPlayer(companionPed, cache.ped)
                    end,
                    arrow = true
                }
                options[#options + 1] = {
                    title = locale('cl_games'),
                    icon = 'fa-solid fa-bone',
                    event = 'rsg-companions:client:mypetsgames',
                    metadata = {{label = locale('txt_games'), value = locale('txt_gamescompanion')}},
                    arrow = true
                }
                if xp >= Config.TrickXp.Stay then
                    options[#options +1] = {
                        title = locale('cl_stay'),
                        icon = 'fa-solid fa-location-dot',
                        onSelect = function()
                            petStay(companionPed)
                        end,
                        arrow = true
                    }
                end
                if xp >= Config.TrickXp.Lay then
                    options[#options +1] = {
                        title = locale('cl_action_lay'),
                        icon = 'fa-solid fa-bed',
                        onSelect = function()
                            TriggerEvent('rsg-companions:client:companionactionslay', companionPed, 'amb_creature_mammal@world_dog_resting@stand_enter', 'enter_front')
                        end,
                        arrow = true
                    }
                end
                if xp >= Config.TrickXp.Hunt then
                    options[#options +1] = {
                        title = locale('cl_action_hunt'),
                        icon = 'fa-solid fa-paw',
                        onSelect = function()
                            if not HuntMode then
                                lib.notify({ title = locale('cl_info_retrieve'), type = 'info', duration = 7000 })
                                HuntMode = true
                            else
                                HuntMode = false
                                lib.notify({ title = locale('cl_error_no_retrieve'), type = 'error', duration = 7000 })
                            end
                        end,
                        -- metadata = {},
                        arrow = true
                    }
                end

                if xp >= Config.TrickXp.Animations then
                    options[#options +1] ={
                        title = locale('cl_anim'),
                        icon = 'fa-solid fa-share',
                        onSelect = function()
                            TriggerEvent('rsg-companions:client:mypetsanimations', companionPed)
                            end,
                        -- metadata = {},
                        arrow = true
                    }
                end
                if xp >= Config.TrickXp.SearchData then
                    options[#options +1] = {
                        title = locale('cl_tablesearch'),
                        icon = 'fa-solid fa-share',
                        onSelect = function()
                            TriggerEvent('rsg-companions:client:showTableSelectionMenu')
                            local playerCoords = GetEntityCoords(PlayerPedId())
                            TriggerServerEvent('rsg-companions:server:searchDatabase', playerCoords, nil)
                        end,
                        arrow = true
                    }
                end
            else
                options[#options +1] = {
                    title = locale('cl_storage'),
                    icon = 'fa-solid fa-warehouse',
                    onSelect = function()
                        FleeSleep()
                    end,
                    arrow = true
                }

                if hasItem then
                    options[#options + 1] = {
                        title = locale('cl_revive'),
                        icon = 'fa-solid fa-syringe',
                        onSelect = function()
                            TriggerEvent('rsg-companions:client:revivecompanion', itemrevivesend, data)
                        end,
                        metadata = {{label = locale('txt_revive'), value = locale('txt_revive_companion')}},
                        arrow = true
                    }
                end

                --[[ options[#options +1] = {
                    title = locale('cl_snoulder'),
                    icon = 'fa-solid fa-share',
                    onSelect = function()
                    end,
                    arrow = true
                } ]]
            end

            lib.registerContext({
                id = 'show_mypetactions_menu',
                title = locale('cl_menu_action'),
                position = 'top-right',
                options = options
            })
            lib.showContext('show_mypetactions_menu')
        end
    end)
end)

RegisterNetEvent('rsg-companions:client:mypets', function()
    RSGCore.Functions.TriggerCallback('rsg-companions:server:GetActiveCompanion', function(data)

        if companionPed == 0 or IsEntityDead(cache.ped) then
            lib.notify({ title = locale('cl_error_no_companion_out'), type = 'error', duration = 7000 })
            return
        end
        if (data) then
            local options = {}
            local companionsDada = json.decode(data.companiondata) or {}

            local maxLifeDays = Config.CompanionDieAge
            local companionage = companionsDada.age or 0
            local lifeProgress = ( companionsDada.age / maxLifeDays ) * 100
            local companionDirt = companionsDada.dirt or 0
            local companionHealth = GetEntityHealth(companionPed) or 0
            local companionMHealth = GetEntityMaxHealth(companionPed) or 0
            local companionMaxHealth = (companionHealth / companionMHealth) * 100
            local compStamina = GetPedStamina(companionPed) or 0
            local companionMStamina = GetPedMaxStamina(companionPed) or 0

            if data.active ~= 0 then
                options[#options + 1] = {
                    title = locale('cl_id_time')..': '.. companionage .. ' '..locale('cl_id_days'),
                    progress = lifeProgress,
                    colorScheme = '#99460e',
                    icon = 'fa-solid fa-arrow-up-right-dots',
                    metadata = {{label = locale('cl_id_time'), value = locale('txt_companionage')}}
                }

                options[#options + 1] = {
                    title = locale('cl_id_xp')..': '..companionsDada.companionxp,
                    progress = companionsDada.companionxp,
                    colorScheme = '#e8a93f',
                    icon = 'fa-solid fa-arrow-up-right-dots',
                    metadata = {{label = locale('cl_id_xp'), value = locale('txt_companionxp')}}
                }

                options[#options +1] = {
                    title = locale('cl_trade'),
                    icon = 'fa-solid fa-dog',
                    event = 'rsg-companions:client:tradecompanion',
                    arrow = true
                }

                options[#options +1] = {
                    title = locale('cl_storage'),
                    icon = 'fa-solid fa-warehouse',
                    onSelect = function()
                        FleeSleep()
                    end,
                    arrow = true
                }

                options[#options +1] = {
                    disabled = true
                }

                options[#options + 1] = {
                    title = locale('cl_txtStats')..': '..companionHealth,
                    progress = companionMaxHealth,
                    colorScheme = '#359d93',
                    icon = 'fa-solid fa-arrow-up-right-dots',
                    onSelect = function()
                        local itemReviveList = { Config.AnimalStimulant, 'apple' }
                        local foundItem = findFirstItem(itemReviveList)
                        TriggerEvent('rsg-companions:client:playerfeedcompanion', foundItem)
                    end,
                    arrow = true
                }

                if not IsEntityDead(companionPed) then

                    options[#options + 1] = {
                        title = locale('cl_happiness')..': '..companionsDada.happiness,
                        progress = companionsDada.happiness,
                        colorScheme = '#eebd6b',
                        icon = 'fa-solid fa-face-grin-hearts',
                        onSelect = function()
                            local itemReviveList = { Config.AnimalHappy, 'sugarcube' }
                            local foundItem = findFirstItem(itemReviveList)
                            TriggerEvent('rsg-companions:client:playerfeedcompanion', foundItem)
                        end,
                        metadata = {{label = locale('cl_happiness'), value = locale('txt_companionhappiness')}},
                        arrow = true
                    }
                    options[#options + 1] = {
                        title =locale('cl_hunger')..': '..companionsDada.hunger,
                        progress = companionsDada.hunger,
                        colorScheme = '#bfe6ef',
                        icon = 'fa-solid fa-drumstick-bite',
                        onSelect = function()
                            local itemReviveList = { Config.AnimalFood, 'raw_meat' }
                            local foundItem = findFirstItem(itemReviveList)
                            TriggerEvent('rsg-companions:client:playerfeedcompanion', foundItem)
                        end,
                        metadata = {{label = locale('cl_hunger'), value = locale('txt_companionhunger')}},
                        arrow = true
                    }
                    options[#options + 1] = {
                        title = locale('cl_thirst')..': '..companionsDada.thirst,
                        progress = companionsDada.thirst,
                        colorScheme = '#447695',
                        icon = 'fa-solid fa-droplet',
                        onSelect = function()
                            local itemReviveList = { Config.AnimalDrink, 'water' }
                            local foundItem = findFirstItem(itemReviveList)
                            TriggerEvent('rsg-companions:client:playerfeedcompanion', foundItem)
                        end,
                        metadata = {{label = locale('cl_thirst'), value = locale('txt_companionthirst')}},
                        arrow = true
                    }
                    options[#options + 1] = {
                        title = locale('cl_dirt')..': '..companionDirt,
                        progress = companionDirt,
                        colorScheme = '#04082e',
                        icon = 'fa-solid fa-shower',
                        onSelect = function()
                            TriggerEvent('rsg-companions:client:playerbrushcompanion', Config.AnimalBrush)
                        end,
                        metadata = {{label = locale('cl_dirt'), value = locale('txt_companionbrush')}},
                        arrow = true
                    }
                end

            end

            lib.registerContext({
                id = 'show_mypet_menu',
                title = locale('cl_menu_info'),
                position = 'top-right',
                menu = 'show_mypetactions_menu',
                onBack = function() end,
                options = options
            })
            lib.showContext('show_mypet_menu')
        end
    end)
end)

RegisterNetEvent('rsg-companions:client:mypetsgames', function()
    RSGCore.Functions.TriggerCallback('rsg-companions:server:GetActiveCompanion', function(data)

        if companionPed == 0 or IsEntityDead(cache.ped) then
            lib.notify({ title = locale('cl_error_menu_no_companions'), type = 'error', duration = 7000 })
            return
        end
        if (data) then
            local options = {}
            local companionsDada = json.decode(data.companiondata) or {}
            local xp = math.floor(companionsDada.companionxp) or 0
            local hasItem = RSGCore.Functions.HasItem(Config.AnimalBone)
            local hasItemTreasure = RSGCore.Functions.HasItem(Config.AnimalTreasure)

            if data.active ~= 0 then
                if not IsEntityDead(companionPed) then
                    if xp >= Config.TrickXp.Bone then
                        options[#options + 1] = {
                            title = locale('cl_bone'),
                            icon = 'fa-solid fa-bone',
                            onSelect = function()
                                if not hasItem then lib.notify({ title = locale('cl_bone_need_item')..' '.. RSGCore.Shared.Items[tostring(Config.AnimalBone)].label, duration = 7000, type = 'error' }) return end
                                StartBone()
                            end,
                            metadata = {{label = locale('cl_bone'), value = locale('txt_companionbone')}},
                            arrow = true
                        }
                    end
                    if xp >= Config.TrickXp.BuriedBone and not buriedBoneCoords then
                        options[#options + 1] = {
                            title = locale('cl_buriedbone'),
                            icon = 'fa-solid fa-exclamation',
                            onSelect = function()
                                if not hasItem then lib.notify({ title = locale('cl_bone_need_item')..' '.. RSGCore.Shared.Items[tostring(Config.AnimalBone)].label, duration = 7000, type = 'error' }) return end
                                TriggerEvent("rsg-companions:client:buryBone")
                            end,
                            metadata = {{label = locale('cl_buriedbone'), value = locale('txt_companionburiedbone')}},
                            arrow = true
                        }
                    end
                    if xp >= Config.TrickXp.BuriedBone and buriedBoneCoords then
                        options[#options + 1] = {
                            title = locale('cl_findburied'),
                            icon = 'fa-solid fa-bell',
                            onSelect = function()
                                TriggerEvent("rsg-companions:client:findBuriedBone")
                            end,
                            metadata = {{label = locale('cl_findburied'), value = locale('txt_companionfindburied')}},
                            arrow = true
                        }
                    end
                    if xp >= Config.TrickXp.digRandom then
                        options[#options + 1] = {
                            title = locale('cl_dig_random'),
                            icon = 'fa-solid fa-shapes',
                            event = 'rsg-companions:client:digRandomItem',
                            metadata = {{label = locale('cl_dig_random'), value = locale('txt_companiondig_random')}},
                            arrow = true
                        }
                    end
                    if xp >= Config.TrickXp.TreasureHunt then
                        options[#options + 1] = {
                            title = locale('cl_treasure_hunt'),
                            icon = 'fa-solid fa-gift',
                            onSelect = function()
                                if not hasItemTreasure then lib.notify({ title = locale('cl_treasurehunt_requeriment'), type = 'error' }) return end
                                startTreasureHunt(companionPed)
                            end,
                            metadata = {{label = locale('cl_treasure_hunt'), value = locale('txt_companiontreasure_hunt')}},
                            arrow = true
                        }
                    end
                end
            end

            lib.registerContext({
                id = 'show_mypet_games',
                title = locale('cl_menu_games'),
                position = 'top-right',
                menu = 'show_mypetactions_menu',
                onBack = function() end,
                options = options
            })
            lib.showContext('show_mypet_games')
        end
    end)
end)

--------------------------------------------
-- COMMAND
--------------------------------------------

RegisterCommand("pet_call", function()
    RSGCore.Functions.GetPlayerData(function(PlayerData)
        if PlayerData.metadata["injail"] == 0 and not IsEntityDead(cache.ped) then
            local coords = GetEntityCoords(cache.ped)
            local companionCoords = GetEntityCoords(companionPed)
            local distance = #(coords - companionCoords)

            TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 10, 'CALLING_WHISTLE_01', 1)

            if not CompanionCalled and (distance > 100.0) then

                lib.notify({ title = locale('cl_spawn'), type = 'info', duration = 7000 })
                SpawnCompanion()
                Wait(3000) -- Spam protect
            else
                lib.notify({ title = locale('cl_no_spawn'), type = 'info', duration = 7000 })
                moveCompanionToPlayer(companionPed, cache.ped)
            end
        end
    end)
end, false)

RegisterCommand('pet_flee', function()
    Flee()
    Wait(3000)
end, false)

RegisterCommand('pet_sleep', function()
    FleeSleep()
    Wait(3000)
end, false)

RegisterCommand('pet_name', function()
    if not IsEntityDead(cache.ped) and not IsEntityDead(companionPed) then
        local input = lib.inputDialog(locale('cl_input_companion_rename'), {
            {
                type = 'input',
                isRequired = true,
                label = locale('cl_input_companion_setname'),
                icon = 'fas fa-companion-head'
            },
        })

        if not input then return end
        TriggerServerEvent('rsg-companions:renameCompanion', input[1])
    end
end, false)

-- COMMAND GAMES
RegisterCommand('pet_hunt', function()
    RSGCore.Functions.GetPlayerData(function(PlayerData)
        if PlayerData.metadata["injail"] == 0 and not IsEntityDead(cache.ped) and not IsEntityDead(companionPed) then
            if not HuntMode then
                lib.notify({ title = locale('cl_info_retrieve'), type = 'info', duration = 7000 })
                HuntMode = true
            else
                HuntMode = false
                lib.notify({ title = locale('cl_error_no_retrieve'), type = 'error', duration = 7000 })
            end
        else
            lib.notify({title = locale('cl_error_pet_dead'), type = 'error', duration = 5000})
        end
    end)
end, false)

RegisterCommand('pet_bone', function()
    local hasItem = RSGCore.Functions.HasItem(Config.AnimalBone)
    if not hasItem then lib.notify({ title = locale('cl_bone_need_item')..' '.. RSGCore.Shared.Items[tostring(Config.AnimalBone)].label, duration = 7000, type = 'error' }) return end
    if not IsEntityDead(cache.ped) and not IsEntityDead(companionPed) then
        StartBone()
        Wait(3000)
    end
end, false)

RegisterCommand('pet_buried', function()
    local hasItem = RSGCore.Functions.HasItem(Config.AnimalBone)
    if not hasItem then lib.notify({ title = locale('cl_bone_need_item')..' '.. RSGCore.Shared.Items[tostring(Config.AnimalBone)].label, duration = 7000, type = 'error' }) return end

    if not IsEntityDead(cache.ped) and not IsEntityDead(companionPed) then
        if buriedBoneCoords then
            lib.notify({ title = locale('cl_error_buriedbone'), description = locale('cl_error_buriedbone_des'), type = 'warning' })
            return
        end

        TriggerEvent("rsg-companions:client:buryBone")
        Wait(3000)
    end
end, false)

RegisterCommand('pet_findburied', function()
    if not IsEntityDead(cache.ped) or not IsEntityDead(companionPed) then
        if not buriedBoneCoords then
            lib.notify({ title = locale('cl_error_findburied'), description = locale('cl_error_findburied_des'), type = 'warning' })
            return
        end

        TriggerEvent("rsg-companions:client:findBuriedBone")

        Wait(3000)
    end
end, false)

RegisterCommand("pet_treasure", function()
    local hasItemTreasure = RSGCore.Functions.HasItem(Config.AnimalTreasure)
    if not hasItemTreasure then lib.notify({ title = locale('cl_treasurehunt_requeriment'), type = 'error' }) return end

    RSGCore.Functions.GetPlayerData(function(PlayerData)
        if PlayerData.metadata["injail"] == 0 and not IsEntityDead(cache.ped) and not IsEntityDead(companionPed) then
            startTreasureHunt(companionPed)
            Wait(3000)
        end
    end)
end, false)

RegisterCommand("pet_clean", function(source, args, rawCommand)
    for k, v in pairs(itemsprop) do -- prop feed active
        if v.cookitem and DoesEntityExist(v.cookitem) then
            SetEntityAsNoLongerNeeded(v.cookitem)
            DeleteEntity(v.cookitem)
            itemsprop[k]= nil
        end
        if v.brushitem and DoesEntityExist(v.brushitem) then
            SetEntityAsNoLongerNeeded(v.brushitem)
            DeleteEntity(v.brushitem)
            itemsprop[k]= nil
        end
        if v.treasure and DoesEntityExist(v.treasure) then
            SetEntityAsNoLongerNeeded(v.treasure)
            DeleteEntity(v.syringeitem)
            itemsprop[k] = nil
        end
        if v.shovel and DoesEntityExist(v.shovel) then
            SetEntityAsNoLongerNeeded(v.shovel)
            DeleteObject(v.shovel)
            itemsprop[k] = nil
        end
        if v.boneitem and DoesEntityExist(v.boneitem) then
            exports.ox_target:removeLocalEntity(v.boneitem, 'prop_bone_actions')
            SetEntityAsNoLongerNeeded(v.boneitem)
            DeleteEntity(v.boneitem)
            itemsprop[k]= nil
        end
    end
    -- findBuriedBone
    buriedBoneCoords = nil
    ClearGpsMultiRoute()
    gpsRoute = nil

    -- startTreasureHunt(companionPed)
    FreezeEntityPosition(cache.ped, false)
    ClearPedTasks(cache.ped)
    isTreasure = false

    treasureInProgress = false
    treasurePoints = {}
    currentHuntStep = 0
    totalHuntSteps = 0
	Wait(3000)
end, false)

--------------------------------------------
-- STOP RESOURCE
--------------------------------------------
AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() ~= resource then return end
    for k, v in pairs(itemsprop) do -- prop feed active
        if v.cookitem and DoesEntityExist(v.cookitem) then
            SetEntityAsNoLongerNeeded(v.cookitem)
            DeleteEntity(v.cookitem)
            itemsprop[k]= nil
        end
        if v.brushitem and DoesEntityExist(v.brushitem) then
            SetEntityAsNoLongerNeeded(v.brushitem)
            DeleteEntity(v.brushitem)
            itemsprop[k]= nil
        end
        if v.boneitem and DoesEntityExist(v.boneitem) then
            exports.ox_target:removeLocalEntity(v.boneitem, 'prop_bone_actions')
            SetEntityAsNoLongerNeeded(v.boneitem)
            DeleteEntity(v.boneitem)
            itemsprop[k]= nil
        end
        if v.syringeitem and DoesEntityExist(v.syringeitem) then
            SetEntityAsNoLongerNeeded(v.syringeitem)
            DeleteEntity(v.syringeitem)
            itemsprop[k] = nil
        end
        if v.treasure and DoesEntityExist(v.treasure) then
            SetEntityAsNoLongerNeeded(v.treasure)
            DeleteEntity(v.syringeitem)
            itemsprop[k] = nil
        end
        if v.shovel and DoesEntityExist(v.shovel) then
            SetEntityAsNoLongerNeeded(v.shovel)
            DeleteObject(v.shovel)
            itemsprop[k] = nil
        end
    end

    itemsprop ={}
    RetrievedEntities = {}

    statsCompanion = {}
    attackedGroup = nil

    ClearGpsMultiRoute()
    gpsRoute = nil
    buriedBoneCoords = nil

    FreezeEntityPosition(cache.ped, false)
    ClearPedTasks(cache.ped)
    isTreasure = false

    treasureInProgress = false
    treasurePoints = {}
    currentHuntStep = 0
    totalHuntSteps = 0

    if (companionPed ~= 0) then -- companion active
        DeletePed(companionPed)
        SetEntityAsNoLongerNeeded(companionPed)
    end

end)