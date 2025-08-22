-- ================================
-- COMPANION ENVIRONMENTAL ACTIONS
-- Handles companion interactions with environment (drinking, eating)
-- ================================

local RSGCore = exports['rsg-core']:GetCoreObject()
local objectInteract = false

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

local ActionCompanionDrink
local DrinkPrompt = GetRandomIntInRange(0, 0xffffff)

local ActionCompanionEat
local EatPrompt = GetRandomIntInRange(0, 0xffffff)

local function TaskStopLeadingHorse(ped)
    return Citizen.InvokeNative(0xED27560703F37258, ped)
end

local function GetLedHorseFromPed(ped)
    return Citizen.InvokeNative(0xED1F514AF4732258, ped) -- 
end

local function IsPedLeadingHorse(ped)
    return Citizen.InvokeNative(0xEFC4303DDC6E60D3, ped)
end

local function SetupActionPrompt()
    -- Validate Config.Prompt exists
    if not Config.Prompt or not Config.Prompt.CompanionDrink or not Config.Prompt.CompanionEat then
        print('^1[ERROR] Config.Prompt.CompanionDrink/CompanionEat not defined! Action prompts will not work.^0')
        return false
    end

    local str1 = locale('cl_action_drink')
    ActionCompanionDrink = PromptRegisterBegin()
    PromptSetControlAction(ActionCompanionDrink, Config.Prompt.CompanionDrink)
    str1 = CreateVarString(10, 'LITERAL_STRING', str1)
    PromptSetText(ActionCompanionDrink, str1)
    PromptSetEnabled(ActionCompanionDrink, 1)
    PromptSetVisible(ActionCompanionDrink, 1)
    PromptSetStandardMode(ActionCompanionDrink,1)
    PromptSetGroup(ActionCompanionDrink, DrinkPrompt)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C,ActionCompanionDrink,true)
    PromptRegisterEnd(ActionCompanionDrink)

    local str2 = locale('cl_action_eat')
    ActionCompanionEat = PromptRegisterBegin()
    PromptSetControlAction(ActionCompanionEat, Config.Prompt.CompanionEat)
    str2 = CreateVarString(10, 'LITERAL_STRING', str2)
    PromptSetText(ActionCompanionEat, str2)
    PromptSetEnabled(ActionCompanionEat, 1)
    PromptSetVisible(ActionCompanionEat, 1)
    PromptSetStandardMode(ActionCompanionEat,1)
    PromptSetGroup(ActionCompanionEat, EatPrompt)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C,ActionCompanionEat,true)
    PromptRegisterEnd(ActionCompanionEat)
end

local function GetNearestInteractableObject(forward)
    -- Usar playerCoords cached en lugar de GetEntityCoords repetitivo
    for _, v in pairs(Config.Ambient.ObjectActionList) do
        local obj = GetClosestObjectOfType(forward.x, forward.y, forward.z, 0.9, v[1], 0, 1, 1)
        if obj ~= 0 then
            return obj, v[2]
        end
    end
    return nil, nil
end

local function PerformCompanionAction(entity, anim, obj, forward)
    objectInteract = true
    TaskStopLeadingHorse(playerPed)
    Wait(500)

    if obj then
        TaskGoStraightToCoord(entity, forward.x, forward.y, forward.z, 1.0, -1, -1, 0)
        Wait(1000)
        TaskTurnPedToFaceEntity(entity, obj, 1000)
        Wait(1000)
    end

    RequestAnimDict(anim.dict)
    while not HasAnimDictLoaded(anim.dict) do Wait(1) end

    local timer = anim.duration * 1000
    TaskPlayAnim(entity, anim.dict, anim.anim, 1.0, 1.0, timer, 1, 0, 1, 0, 0, 0, 0)
    Wait(timer)

    if obj then ClearPedTasks(entity) end

    local companionHealth = Citizen.InvokeNative(0x36731AC041289BB1, entity, 0)
    -- local companionStamina = Citizen.InvokeNative(0x36731AC041289BB1, entity, 1)

    Citizen.InvokeNative(0xC6258F41D86676E0, entity, 0, companionHealth + Config.Ambient.BoostAction.Health)
    -- Citizen.InvokeNative(0xC6258F41D86676E0, entity, 1, companionStamina + Config.Ambient.BoostAction.Stamina)

    objectInteract = false
end

function HandleWaterInteraction(entity)
    if not IsPedStill(entity) or IsPedSwimming(entity) then return end

    DisableControlAction(0, 0x7914A3DD, true)
    local label = CreateVarString(10, 'LITERAL_STRING', locale('cl_action_companions'))
    PromptSetActiveGroupThisFrame(DrinkPrompt, label)

    if Citizen.InvokeNative(0xC92AC953F0A982AE, ActionCompanionDrink) then
        PerformCompanionAction(entity, Config.Ambient.Anim.Drink)
    end
end

function HandleObjectInteractio(entity)
    local forward = GetOffsetFromEntityInWorldCoords(entity, 0.0, 0.8, -0.5)
    local obj, type = GetNearestInteractableObject(forward)

    if obj == nil then return end

    local promptGroup, action, anim
    if type == "drink" then
        promptGroup, action = DrinkPrompt, ActionCompanionDrink
        anim = Config.Ambient.Anim.Drink2
    elseif type == "feed" then
        promptGroup, action = EatPrompt, ActionCompanionEat
        anim = Config.Ambient.Anim.Eat
    else
        return
    end

    local label = CreateVarString(10, 'LITERAL_STRING', locale('cl_action_companions'))
    PromptSetActiveGroupThisFrame(promptGroup, label)

    if Citizen.InvokeNative(0xC92AC953F0A982AE, action) then
        PerformCompanionAction(entity, anim, obj, forward)
    end
end

CreateThread(function()
    SetupActionPrompt()
    repeat Wait(1000) until LocalPlayer.state.isLoggedIn
    
    while true do
        local sleep = 1000 -- Base sleep optimizado
        
        -- Solo procesar cuando el jugador está logueado
        if LocalPlayer.state.isLoggedIn and playerPed > 0 then
            local tcompanion = isCompanionPedActive()
            
            if tcompanion and not objectInteract and IsPedLeadingHorse(playerPed) then
                sleep = 100 -- Más frecuente cuando hay compañero activo
                
                if IsEntityInWater(tcompanion) then
                    HandleWaterInteraction(tcompanion)
                elseif Config.Ambient.ObjectAction then
                    HandleObjectInteractio(tcompanion)
                end
            end
        end
        
        Wait(sleep)
    end
end)

---------------------------
-- ANIMATION LAY
---------------------------
RegisterNetEvent('rsg-companions:client:companionactionslay', function(entity, dict, anim)
    if not entity then return end
    if not IsEntityPlayingAnim(entity, dict, anim, 3) then
        if not HasAnimDictLoaded(dict) then
            RequestAnimDict(dict)
        end
        if not HasAnimDictLoaded("amb_creature_mammal@world_dog_resting@stand_enter") then
            local dictz = "amb_creature_mammal@world_dog_resting@stand_enter"
            RequestAnimDict(dictz)
        end
        TaskPlayAnim(entity, "amb_creature_mammal@world_dog_resting@stand_enter", "enter_front", 1.0, 1.0, -1, 2, 0.0, false, false, false, '', false)
        Citizen.Wait(3000)
        TaskPlayAnim(entity, dict, anim, 1.0, 1.0, -1, 2, 0.0, false, false, false, '', false)
    else
        if not HasAnimDictLoaded("amb_creature_mammal@world_dog_resting@walk_exit") then
            local dictx = "amb_creature_mammal@world_dog_resting@walk_exit"
            RequestAnimDict(dictx)
        end
        TaskPlayAnim(entity, "amb_creature_mammal@world_dog_resting@walk_exit", "exit_front", 1.0, 1.0, -1, 2, 0.0, false, false, false, '', false)
        Citizen.Wait(3000)
        ClearPedTasks(entity)
    end
end)

---------------------------
-- ANIMATIONS MENU
---------------------------
local playanim = false
local petanimdict = nil
local petanimdictname = nil
local petanimname = nil

local function StopAnimation(entity, animdict, animdictname)
	if Config.Debug then print(animdict) print(animdictname) end
	TaskPlayAnim(entity, animdict, animdictname, 1.0, 1.0, -1, 0, 1.0, false, false, false)
	FreezeEntityPosition(entity, false)
end

local function AnimationPet(entity, dict, name)
	local waiting = 0
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		waiting = waiting + 100
		Wait(100)
		if waiting > 5000 then
            lib.notify({ title = locale('cl_error_anim_no'), type = 'error', duration = 7000 })
            break
		end
	end
	TaskPlayAnim(entity, dict, name, 1.0, 1.0, -1, 1, 0, false, false, false)
    playanim = true
end

local function petAnimation(entity, dict, dictname)
	local coords = GetEntityCoords(entity)
	ClearPedTasks(entity)
	ClearPedSecondaryTask(entity)
	AnimationPet(entity, dict, dictname)
	FreezeEntityPosition(entity, true)
end

RegisterNetEvent('rsg-companions:client:mypetsanimations', function(dogPedmenu)
    if not DoesEntityExist(dogPedmenu) then return end
	-- Cargamos la lista de animaciones (ya disponible inmediatamente)
    local Animations = lib.load('shared.animations_settings')

    -- Ahora pedimos al servidor la data de la mascota activa
    RSGCore.Functions.TriggerCallback('rsg-companions:server:GetActiveCompanion', function(result)
        local options = {}

        -- Opción para parar la animación actual
        options[#options+1] = {
            title = locale('cl_action_stop'),
            icon  = 'fa-solid fa-pause',
            onSelect = function()
                StopAnimation(dogPedmenu, petanimdict, petanimdictname)
                petanimdict     = nil
                petanimdictname = nil
                petanimname     = nil
                lib.showContext('show_mypetanimation_menu')
            end,
        }

        -- Si hay mascota activa y está en buen estado
        if result and result.active ~= 0 then
            local companionsData = json.decode(result.companiondata) or {}
            if companionsData.hunger < 10 or companionsData.thirst < 10 or companionsData.happiness < 15 then
                lib.notify({ title = locale('cl_error_action_condition'), description = locale('cl_error_action_condition'), type = 'error' })
                return
            end

            -- Añadimos cada animación disponible al menú
            for _, v in ipairs(Animations) do
                options[#options+1] = {
                    title = v.animname,
                    icon  = v.icon or 'fa-solid fa-box',
                    onSelect = function()
                        petAnimation(dogPedmenu, v.dict, v.dictname)
                        petanimdict     = v.dict
                        petanimdictname = v.dictname
                        petanimname     = v.animname
                        lib.showContext('show_mypetanimation_menu')
                    end,
                }
            end
        end

        -- Finalmente registramos y mostramos el menú YA con todas las opciones
        lib.registerContext({
            id       = 'show_mypetanimation_menu',
            title    = locale('cl_action_anim'),
            menu     = 'show_mypetactions_menu',
            position = 'top-right',
            options  = options
        })
        lib.showContext('show_mypetanimation_menu')
    end)
end)