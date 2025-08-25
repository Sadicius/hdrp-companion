-- ================================
-- CUSTOMIZATION SYSTEM MODULE
-- Handles companion visual customization, props, and components
-- ================================

local RSGCore = exports['rsg-core']:GetCoreObject()

-- Load shared components using correct path resolution with error handling
local ComponentsProps = nil
local Components = nil

-- Safe loading with error handling
pcall(function()
    ComponentsProps = lib.load('@hdrp-companion/shared/companion_props')
    Components = lib.load('@hdrp-companion/shared/companion_comp')
end)

-- Validation checks
if not ComponentsProps then
    print('[HDRP-COMPANION ERROR] Failed to load companion_props module')
end

if not Components then
    print('[HDRP-COMPANION ERROR] Failed to load companion_comp module')
end

-- Initialize with fallbacks if needed
ComponentsProps = ComponentsProps or {}
Components = Components or {}

local CustomizationSystem = {}

-- Module state
CustomizationSystem.attachedProps = {}
CustomizationSystem.appliedComponents = {}
CustomizationSystem.isInitialized = false

-- ================================
-- INITIALIZATION
-- ================================

function CustomizationSystem:Initialize()
    if self.isInitialized then return end

    if Config.Debug then
        print('[CUSTOMIZATION] Initializing customization system module')
    end

    self.isInitialized = true
end

-- ================================
-- PROP ATTACHMENT SYSTEM
-- ================================

function CustomizationSystem:AttachProp(companionPed, category, propId)
    if not DoesEntityExist(companionPed) then 
        if Config.Debug then print('[CUSTOMIZATION] Invalid companion entity') end
        return false
    end

    -- Get prop data
    local propData = self:GetPropData(category, propId)
    if not propData then
        if Config.Debug then print('[CUSTOMIZATION] Prop data not found:', category, propId) end
        return false
    end

    -- Remove existing prop in same category
    self:RemovePropByCategory(companionPed, category)

    -- Request model with validation
    local modelHash = joaat(propData.model)
    lib.requestModel(modelHash, 10000)
    
    -- Verify model loaded successfully
    if not HasModelLoaded(modelHash) then
        if Config.Debug then print('[CUSTOMIZATION] ERROR: Failed to load model:', propData.model) end
        return false
    end

    -- Create prop object
    local propCoords = GetEntityCoords(companionPed)
    local propObject = CreateObject(modelHash, propCoords.x, propCoords.y, propCoords.z, true, true, false, false, true)

    if not DoesEntityExist(propObject) then
        if Config.Debug then print('[CUSTOMIZATION] Failed to create prop object:', propData.model) end
        SetModelAsNoLongerNeeded(modelHash) -- Cleanup model
        return false
    end

    -- Get bone index with fallback system
    local boneIndex = GetEntityBoneIndexByName(companionPed, propData.bone)
    if boneIndex == -1 then
        if Config.Debug then print('[CUSTOMIZATION] Primary bone not found, trying fallbacks:', propData.bone) end
        
        -- Try alternative bones if main bone fails
        local alternativeBones = {'head', 'neck', 'spine1', 'spine0'}
        for _, altBone in ipairs(alternativeBones) do
            boneIndex = GetEntityBoneIndexByName(companionPed, altBone)
            if boneIndex ~= -1 then 
                if Config.Debug then print('[CUSTOMIZATION] Using fallback bone:', altBone) end
                break 
            end
        end
        
        -- If no bones work, fail safely
        if boneIndex == -1 then
            if Config.Debug then print('[CUSTOMIZATION] ERROR: No valid bones found for attachment') end
            DeleteObject(propObject)
            return false
        end
    end

    -- Attach prop to bone
    AttachEntityToEntity(
        propObject,
        companionPed,
        boneIndex,
        propData.offset.x,
        propData.offset.y,
        propData.offset.z,
        propData.offset.pitch,
        propData.offset.roll,
        propData.offset.yaw,
        false, false, false, false, 2, true
    )

    -- Cleanup model after successful attachment
    SetModelAsNoLongerNeeded(modelHash)

    -- Store attached prop
    local companionId = self:GetCompanionId(companionPed)
    if not self.attachedProps[companionId] then 
        self.attachedProps[companionId] = {} 
    end

    self.attachedProps[companionId][category] = {
        object = propObject,
        propId = propId,
        propData = propData
    }

    if Config.Debug then
        print('[CUSTOMIZATION] Prop attached successfully:', category, propId)
    end

    return true
end

function CustomizationSystem:RemoveProp(companionPed, category, propId)
    local companionId = self:GetCompanionId(companionPed)
    local attachedProp = self.attachedProps[companionId] and self.attachedProps[companionId][category]

    if not attachedProp then return false end

    if DoesEntityExist(attachedProp.object) then
        DeleteObject(attachedProp.object)
    end

    self.attachedProps[companionId][category] = nil

    if Config.Debug then
        print('[CUSTOMIZATION] Prop removed:', category, propId)
    end

    return true
end

function CustomizationSystem:RemovePropByCategory(companionPed, category)
    local companionId = self:GetCompanionId(companionPed)
    local attachedProp = self.attachedProps[companionId] and self.attachedProps[companionId][category]

    if attachedProp then
        if DoesEntityExist(attachedProp.object) then
            DeleteObject(attachedProp.object)
        end
        self.attachedProps[companionId][category] = nil
    end
end

-- ================================
-- COMPONENT SYSTEM
-- ================================

function CustomizationSystem:ApplyComponent(companionPed, category, componentId)
    if not DoesEntityExist(companionPed) then return false end

    -- Get component data
    local componentData = self:GetComponentData(category, componentId)
    if not componentData then return false end

    -- Apply component using native functions
    Citizen.InvokeNative(0xD3A7B003ED343FD9, companionPed, componentData.hash, true, true, true)

    -- Store applied component
    local companionId = self:GetCompanionId(companionPed)
    if not self.appliedComponents[companionId] then
        self.appliedComponents[companionId] = {}
    end

    self.appliedComponents[companionId][category] = {
        componentId = componentId,
        componentData = componentData
    }

    if Config.Debug then
        print('[CUSTOMIZATION] Component applied:', category, componentId)
    end

    return true
end

function CustomizationSystem:RemoveComponent(companionPed, category)
    if not DoesEntityExist(companionPed) then return false end

    local companionId = self:GetCompanionId(companionPed)
    local appliedComponent = self.appliedComponents[companionId] and self.appliedComponents[companionId][category]

    if not appliedComponent then return false end

    -- Remove component using native functions
    Citizen.InvokeNative(0xD710A5007C2AC539, companionPed, appliedComponent.componentData.category_hash, 0)

    self.appliedComponents[companionId][category] = nil

    if Config.Debug then
        print('[CUSTOMIZATION] Component removed:', category)
    end

    return true
end

-- ================================
-- DATA RETRIEVAL
-- ================================

function CustomizationSystem:GetPropData(category, propId)
    if not ComponentsProps[category] then return nil end

    for _, prop in ipairs(ComponentsProps[category]) do
        if prop and prop.hashid == propId then
            return prop
        end
    end

    return nil
end

function CustomizationSystem:GetComponentData(category, componentId)
    if not Components[category] then return nil end

    for _, component in ipairs(Components[category]) do
        if component and component.hashid == componentId then
            return component
        end
    end

    return nil
end

function CustomizationSystem:GetAvailableProps(category)
    if not ComponentsProps[category] then return {} end

    local available = {}
    for _, prop in ipairs(ComponentsProps[category]) do
        if prop then
            table.insert(available, {
                id = prop.hashid,
                category = prop.category,
                model = prop.model,
                bone = prop.bone
            })
        end
    end

    return available
end

function CustomizationSystem:GetAvailableComponents(category)
    if not Components[category] then return {} end

    local available = {}
    for _, component in ipairs(Components[category]) do
        if component then
            table.insert(available, {
                id = component.hashid,
                category = component.category,
                hash = component.hash
            })
        end
    end

    return available
end

-- ================================
-- CUSTOMIZATION MENU
-- ================================

function CustomizationSystem:OpenCustomizationMenu(companionPed)
    if not DoesEntityExist(companionPed) then return end

    local menuOptions = {}

    -- Add prop categories
    for category, props in pairs(ComponentsProps) do
        if props and #props > 0 then
            table.insert(menuOptions, {
                title = self:GetCategoryDisplayName(category),
                description = locale('cl_customization_category_desc', category),
                onSelect = function()
                    self:OpenPropCategoryMenu(companionPed, category)
                end
            })
        end
    end

    -- Add component categories
    for category, components in pairs(Components) do
        if components and #components > 0 then
            table.insert(menuOptions, {
                title = self:GetCategoryDisplayName(category) .. ' (Components)',
                description = locale('cl_customization_component_desc', category),
                onSelect = function()
                    self:OpenComponentCategoryMenu(companionPed, category)
                end
            })
        end
    end

    -- Show main menu
    lib.registerContext({
        id = 'companion_customization_main',
        title = locale('cl_customization_main_title'),
        options = menuOptions
    })

    lib.showContext('companion_customization_main')
end

function CustomizationSystem:OpenPropCategoryMenu(companionPed, category)
    if not ComponentsProps[category] then return end

    local menuOptions = {}

    -- Add remove option
    table.insert(menuOptions, {
        title = locale('cl_customization_remove'),
        description = locale('cl_customization_remove_desc'),
        onSelect = function()
            self:RemovePropByCategory(companionPed, category)
            lib.notify({
                title = locale('cl_customization_removed'),
                type = 'success'
            })
        end
    })

    -- Add props
    for _, prop in ipairs(ComponentsProps[category]) do
        if prop then
            table.insert(menuOptions, {
                title = prop.hashid,
                description = locale('cl_customization_prop_desc', prop.model),
                onSelect = function()
                    if self:AttachProp(companionPed, category, prop.hashid) then
                        lib.notify({
                            title = locale('cl_customization_applied'),
                            type = 'success'
                        })
                    else
                        lib.notify({
                            title = locale('cl_customization_failed'),
                            type = 'error'
                        })
                    end
                end
            })
        end
    end

    lib.registerContext({
        id = 'companion_prop_' .. category,
        title = self:GetCategoryDisplayName(category),
        menu = 'companion_customization_main',
        options = menuOptions
    })

    lib.showContext('companion_prop_' .. category)
end

-- ================================
-- UTILITY FUNCTIONS
-- ================================

function CustomizationSystem:GetCompanionId(companionPed)
    -- This should be implemented based on how you track companion IDs
    -- For now, using entity handle as temporary ID
    return tostring(companionPed)
end

function CustomizationSystem:GetCategoryDisplayName(category)
    local displayNames = {
        Toys = locale('cl_category_toys'),
        Horns = locale('cl_category_horns'),
        Neck = locale('cl_category_neck'),
        Medal = locale('cl_category_medal'),
        Masks = locale('cl_category_masks'),
        Cigar = locale('cl_category_cigar')
    }

    return displayNames[category] or category
end

-- ================================
-- PERSISTENCE
-- ================================

function CustomizationSystem:SaveCustomization(companionId, customizationData)
    TriggerServerEvent('rsg-companions:server:SaveCustomization', companionId, customizationData)
end

function CustomizationSystem:LoadCustomization(companionPed, customizationData)
    if not customizationData then return end

    -- Apply saved props
    if customizationData.props then
        for category, propData in pairs(customizationData.props) do
            if propData.propId then
                self:AttachProp(companionPed, category, propData.propId)
            end
        end
    end

    -- Apply saved components
    if customizationData.components then
        for category, componentData in pairs(customizationData.components) do
            if componentData.componentId then
                self:ApplyComponent(companionPed, category, componentData.componentId)
            end
        end
    end
end

-- ================================
-- CLEANUP
-- ================================

function CustomizationSystem:CleanupCompanion(companionId)
    -- Remove all attached props
    if self.attachedProps[companionId] then
        for category, propData in pairs(self.attachedProps[companionId]) do
            if DoesEntityExist(propData.object) then
                DeleteObject(propData.object)
            end
        end
        self.attachedProps[companionId] = nil
    end

    -- Clear applied components
    if self.appliedComponents[companionId] then
        self.appliedComponents[companionId] = nil
    end
end

function CustomizationSystem:Cleanup()
    -- Clean up all props and components
    for companionId, _ in pairs(self.attachedProps) do
        self:CleanupCompanion(companionId)
    end

    self.attachedProps = {}
    self.appliedComponents = {}
    self.isInitialized = false

    if Config.Debug then
        print('[CUSTOMIZATION] Module cleaned up')
    end
end

-- ================================
-- REATTACHMENT SYSTEM
-- ================================

function CustomizationSystem:ReattachStoredProps(companionPed)
    if not DoesEntityExist(companionPed) then return end
    
    local companionId = self:GetCompanionId(companionPed)
    local storedProps = self.attachedProps[companionId]
    
    if not storedProps then 
        if Config.Debug then print('[CUSTOMIZATION] No stored props to reattach for companion:', companionId) end
        return 
    end

    if Config.Debug then print('[CUSTOMIZATION] Reattaching stored props for companion:', companionId) end

    -- Clear current attachments (objects may be invalid after respawn)
    self.attachedProps[companionId] = nil

    -- Reattach each stored prop
    for category, propInfo in pairs(storedProps) do
        if propInfo.propId and propInfo.propData then
            self:AttachProp(companionPed, category, propInfo.propId)
        end
    end
end

-- ================================
-- EVENT HANDLERS
-- ================================

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        CustomizationSystem:Cleanup()
    end
end)

-- Listen for companion spawn events to reattach props
AddEventHandler('rsg-companions:client:companionSpawned', function(companionPed)
    CreateThread(function()
        Wait(1000) -- Wait for companion to be fully spawned
        CustomizationSystem:ReattachStoredProps(companionPed)
    end)
end)

-- ================================
-- EXPORTS
-- ================================

-- Export global para acceso desde otros archivos
CustomizationSystem = CustomizationSystem

exports('GetCustomizationSystem', function()
    return CustomizationSystem
end)