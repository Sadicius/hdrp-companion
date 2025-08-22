-- ================================
-- COMPANION PROMPTS MANAGER
-- Gestión optimizada de prompts siguiendo mejores prácticas RedM
-- ================================

local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

-- Cache variables optimizadas
local playerPed = 0
local playerCoords = vector3(0, 0, 0)

-- Esperar a que CompanionState esté disponible
CreateThread(function()
    while not CompanionState do
        Wait(100)
    end
end)

-- ================================
-- SISTEMA DE CACHE OPTIMIZADO
-- ================================

-- Actualizar playerPed cuando cambie
lib.onCache('ped', function(ped)
    playerPed = ped
end)

-- Actualizar coordenadas cuando cambien
lib.onCache('coords', function(coords)
    playerCoords = coords
end)

local PromptManager = {}

-- ================================
-- CONFIGURACIÓN DE PROMPTS
-- ================================

PromptManager.prompts = {}
PromptManager.promptGroups = {}
PromptManager.activePrompts = {}

-- ================================
-- CORE PROMPT FUNCTIONS
-- ================================

function PromptManager:CreatePrompt(key, controlHash, text, holdMode)
    if self.prompts[key] then
        self:DeletePrompt(key)
    end

    local prompt = PromptRegisterBegin()
    PromptSetControlAction(prompt, controlHash)

    local str = CreateVarString(10, 'LITERAL_STRING', text)
    PromptSetText(prompt, str)
    PromptSetEnabled(prompt, true)
    PromptSetVisible(prompt, true)

    if holdMode then
        PromptSetHoldMode(prompt, true)
    else
        PromptSetStandardMode(prompt, true)
    end

    PromptRegisterEnd(prompt)

    self.prompts[key] = {
        prompt = prompt,
        text = text,
        controlHash = controlHash,
        enabled = true
    }

    if Config.Debug then
        print('[PROMPTS] Created prompt:', key)
    end

    return prompt
end

function PromptManager:CreatePromptGroup(groupKey, prompts)
    if not groupKey or not prompts or type(prompts) ~= 'table' then
        print('^1[ERROR] Invalid parameters for CreatePromptGroup^0')
        return nil
    end

    local group = GetRandomIntInRange(0, 0xffffff)

    for _, promptData in ipairs(prompts) do
        if not promptData.key or not promptData.control or not promptData.text then
            print(string.format('^1[ERROR] Invalid prompt data in group %s^0', groupKey))
            goto continue
        end

        local success, prompt = pcall(function()
            return self:CreatePrompt(promptData.key, promptData.control, promptData.text, promptData.holdMode)
        end)

        if success and prompt then
            PromptSetGroup(prompt, group)
            Citizen.InvokeNative(0xC5F428EE08FA7F2C, prompt, true)
        else
            print(string.format('^1[ERROR] Failed to create prompt %s in group %s^0', promptData.key, groupKey))
        end

        ::continue::
    end

    self.promptGroups[groupKey] = {
        group = group,
        prompts = prompts
    }

    return group
end

function PromptManager:ShowPromptGroup(groupKey, label)
    local groupData = self.promptGroups[groupKey]
    if not groupData then return end

    local labelString = CreateVarString(10, 'LITERAL_STRING', label or groupKey)
    PromptSetActiveGroupThisFrame(groupData.group, labelString)
end

function PromptManager:DeletePrompt(key)
    local promptData = self.prompts[key]
    if promptData then
        PromptDelete(promptData.prompt)
        self.prompts[key] = nil

        if Config.Debug then
            print('[PROMPTS] Deleted prompt:', key)
        end
    end
end

function PromptManager:DeletePromptGroup(groupKey)
    local groupData = self.promptGroups[groupKey]
    if not groupData then return end

    for _, promptData in ipairs(groupData.prompts) do
        self:DeletePrompt(promptData.key)
    end
    
    self.promptGroups[groupKey] = nil
end

function PromptManager:IsPromptPressed(key)
    local promptData = self.prompts[key]
    if not promptData or not promptData.enabled then return false end

    return PromptHasStandardModeCompleted(promptData.prompt)
end

function PromptManager:IsPromptHeld(key)
    local promptData = self.prompts[key]
    if not promptData or not promptData.enabled then return false end

    return PromptHasHoldModeCompleted(promptData.prompt)
end

function PromptManager:EnablePrompt(key, enabled)
    local promptData = self.prompts[key]
    if promptData then
        promptData.enabled = enabled
        PromptSetEnabled(promptData.prompt, enabled)
        PromptSetVisible(promptData.prompt, enabled)
    end
end

-- ================================
-- COMPANION SPECIFIC PROMPTS
-- ================================

function PromptManager:InitializeCompanionPrompts()
    if Config.Debug then
        print('[PROMPTS] Initializing companion prompts')
    end

    -- Validate Config.Prompt exists
    if not Config.Prompt then
        print('^1[ERROR] Config.Prompt not found! Companion prompts will not work.^0')
        return false
    end

    -- Validate required prompt controls exist
    local requiredPrompts = {
        'CompanionCall', 'CompanionFlee', 'CompanionActions', 'CompanionSaddleBag',
        'CompanionBrush', 'CompanionAttack', 'CompanionTrack', 'CompanionHunt',
        'CompanionDrink', 'CompanionEat'
    }

    for _, promptKey in ipairs(requiredPrompts) do
        if not Config.Prompt[promptKey] then
            print(string.format('^1[ERROR] Missing Config.Prompt.%s definition!^0', promptKey))
            return false
        end
    end

    -- Main companion prompts
    self:CreatePromptGroup('companion_main', {
        {
            key = 'companion_call',
            control = Config.Prompt.CompanionCall,
            text = locale('cl_spawn'),
            holdMode = false
        },
        {
            key = 'companion_flee',
            control = Config.Prompt.CompanionFlee,
            text = locale('cl_action_flee'),
            holdMode = false
        },
        {
            key = 'companion_actions',
            control = Config.Prompt.CompanionActions,
            text = locale('cl_action_actions'),
            holdMode = false
        }
    })

    -- Companion interaction prompts
    self:CreatePromptGroup('companion_interaction', {
        {
            key = 'companion_saddlebag',
            control = Config.Prompt.CompanionSaddleBag,
            text = locale('cl_action_saddlebag'),
            holdMode = false
        },
        {
            key = 'companion_brush',
            control = Config.Prompt.CompanionBrush,
            text = locale('cl_brush_need_item'),
            holdMode = true
        }
    })

    -- Combat prompts
    if Config.EnablePrompts then
        self:CreatePromptGroup('companion_combat', {
            {
                key = 'companion_attack',
                control = Config.Prompt.CompanionAttack,
                text = locale('cl_action_attack_target'),
                holdMode = false
            },
            {
                key = 'companion_track',
                control = Config.Prompt.CompanionTrack,
                text = locale('cl_track_action'),
                holdMode = false
            },
            {
                key = 'companion_hunt',
                control = Config.Prompt.CompanionHunt,
                text = locale('cl_hunt_target_action'),
                holdMode = false
            }
        })
    end

    -- Environmental prompts
    self:CreatePromptGroup('companion_environment', {
        {
            key = 'companion_drink',
            control = Config.Prompt.CompanionDrink,
            text = locale('cl_action_drink'),
            holdMode = false
        },
        {
            key = 'companion_eat',
            control = Config.Prompt.CompanionEat,
            text = locale('cl_action_eat'),
            holdMode = false
        }
    })
end

-- ================================
-- PROMPT HANDLERS
-- ================================

function PromptManager:HandleMainPrompts()
    local companionActive = CompanionState:IsActive()

    -- Show appropriate prompts based on companion state
    if companionActive then
        self:ShowPromptGroup('companion_main', locale('cl_action_companions'))
        self:ShowPromptGroup('companion_interaction', locale('cl_action_companions'))

        -- Handle prompt presses
        if self:IsPromptPressed('companion_flee') then
            TriggerEvent('rsg-companions:client:fleeCompanion')
        end

        if self:IsPromptPressed('companion_actions') then
            TriggerEvent('rsg-companions:client:openActionsMenu')
        end

        if self:IsPromptPressed('companion_saddlebag') then
            TriggerEvent('rsg-companions:client:openSaddlebag')
        end

        if self:IsPromptHeld('companion_brush') then
            TriggerEvent('rsg-companions:client:brushCompanion')
        end
    else
        -- Show call prompt if no companion active
        if self:IsPromptPressed('companion_call') then
            TriggerEvent('rsg-companions:client:callCompanion')
        end
    end
end

function PromptManager:HandleCombatPrompts(targetEntity)
    if not Config.EnablePrompts or not targetEntity then return end

    local companionActive = CompanionState:IsActive()
    if not companionActive then return end

    local targetCoords = GetEntityCoords(targetEntity)
    local currentCoords = playerCoords or GetEntityCoords(playerPed)
    local distance = #(targetCoords - currentCoords)

    -- Only show prompts within reasonable distance
    if distance > 15.0 then return end

    self:ShowPromptGroup('companion_combat', locale('cl_action_companions'))

    -- Handle combat prompts
    if self:IsPromptPressed('companion_attack') then
        TriggerEvent('rsg-companions:client:attackTarget', targetEntity)
    end

    if self:IsPromptPressed('companion_track') then
        TriggerEvent('rsg-companions:client:trackTarget', targetEntity)
    end

    if self:IsPromptPressed('companion_hunt') then
        TriggerEvent('rsg-companions:client:huntTarget', targetEntity)
    end
end

function PromptManager:HandleEnvironmentPrompts()
    local companionActive = CompanionState:IsActive()
    if not companionActive then return end

    local companionPed = CompanionState:GetPed()

    if not DoesEntityExist(companionPed) then return end

    -- Check for environmental interactions
    local companionCoords = GetEntityCoords(companionPed)
    local nearbyObjects = self:GetNearbyInteractableObjects(companionCoords)

    if #nearbyObjects > 0 then
        self:ShowPromptGroup('companion_environment', locale('cl_action_companions'))

        if self:IsPromptPressed('companion_drink') then
            TriggerEvent('rsg-companions:client:companionDrink', nearbyObjects)
        end

        if self:IsPromptPressed('companion_eat') then
            TriggerEvent('rsg-companions:client:companionEat', nearbyObjects)
        end
    end
end

-- ================================
-- UTILITY FUNCTIONS
-- ================================

function PromptManager:GetNearbyInteractableObjects(coords)
    local objects = {}

    if not Config.Ambient.ObjectActionList then return objects end

    for _, objectData in ipairs(Config.Ambient.ObjectActionList) do
        local modelHash = objectData[1]
        local actionType = objectData[2]

        -- Find objects of this type nearby
        local nearbyObjects = GetGamePool('CObject')
        for _, obj in ipairs(nearbyObjects) do
            if DoesEntityExist(obj) then
                local objModel = GetEntityModel(obj)
                if objModel == modelHash then
                    local objCoords = GetEntityCoords(obj)
                    local distance = #(coords - objCoords)

                    if distance <= 3.0 then
                        table.insert(objects, {
                            entity = obj,
                            type = actionType,
                            coords = objCoords,
                            distance = distance
                        })
                    end
                end
            end
        end
    end

    return objects
end

-- ================================
-- CLEANUP
-- ================================

function PromptManager:Cleanup()
    -- Delete all prompts
    for key, _ in pairs(self.prompts) do
        self:DeletePrompt(key)
    end

    -- Clear prompt groups
    for groupKey, _ in pairs(self.promptGroups) do
        self:DeletePromptGroup(groupKey)
    end

    self.prompts = {}
    self.promptGroups = {}
    self.activePrompts = {}

    if Config.Debug then
        print('[PROMPTS] Cleanup completed')
    end
end

-- ================================
-- INITIALIZATION
-- ================================

CreateThread(function()
    -- Wait for game to be ready
    while not LocalPlayer.state.isLoggedIn do
        Wait(1000)
    end

    -- Initialize prompts
    PromptManager:InitializeCompanionPrompts()

    if Config.Debug then
        print('[PROMPTS] Prompt manager initialized')
    end
end)

-- Main prompt handling loop
CreateThread(function()
    while true do
        local sleep = 1000

        -- Only process prompts when player is loaded
        if LocalPlayer.state.isLoggedIn then
            sleep = 100

            PromptManager:HandleMainPrompts()
            PromptManager:HandleEnvironmentPrompts()

            -- Handle target-based prompts
            local targetEntity = GetPlayerTargetEntity(playerPed)
            if targetEntity and targetEntity ~= 0 then
                PromptManager:HandleCombatPrompts(targetEntity)
                sleep = 0  -- More responsive when targeting
            end
        end

        Wait(sleep)
    end
end)

-- ================================
-- EVENT HANDLERS
-- ================================

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        PromptManager:Cleanup()
    end
end)

RegisterNetEvent('RSGCore:Client:OnPlayerUnload', function()
    PromptManager:Cleanup()
end)

-- ================================
-- EXPORTS
-- ================================

-- Hacer PromptManager global para acceso desde otros archivos
_G.PromptManager = PromptManager

exports('GetPromptManager', function()
    return PromptManager
end)