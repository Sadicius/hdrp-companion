-- ================================
-- CUSTOMIZATION SERVER MODULE
-- Handles server-side customization persistence and validation
-- ================================

local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

-- ================================
-- DATABASE SETUP
-- ================================

-- Create customization table if it doesn't exist
CreateThread(function()
    local success, result = pcall(MySQL.scalar.await, 'SELECT 1 FROM companion_customization LIMIT 1')
    if not success then
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS `companion_customization` (
                `id` int(11) NOT NULL AUTO_INCREMENT,
                `companionid` varchar(11) NOT NULL,
                `citizenid` varchar(50) NOT NULL,
                `customization_data` LONGTEXT DEFAULT '{}',
                `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
                `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                PRIMARY KEY (`id`),
                UNIQUE KEY `unique_companion` (`companionid`),
                KEY `idx_citizenid` (`citizenid`)
            )
        ]], function(result)
            print('[CUSTOMIZATION-SERVER] Customization table created successfully')
        end)
    end
end)

-- ================================
-- SAVE CUSTOMIZATION
-- ================================

RegisterServerEvent('rsg-companions:server:SaveCustomization')
AddEventHandler('rsg-companions:server:SaveCustomization', function(companionId, customizationData)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end

    local citizenId = Player.PlayerData.citizenid
    
    if not companionId or not customizationData then
        if Config.Debug then
            print('[CUSTOMIZATION-SERVER] Invalid data received for SaveCustomization')
        end
        return
    end

    -- Validate that the companion belongs to the player
    local companionExists = MySQL.scalar.await(
        'SELECT COUNT(*) FROM player_companions WHERE companionid = ? AND citizenid = ?',
        { companionId, citizenId }
    )

    if companionExists == 0 then
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('sv_error_invalid_companion'),
            description = locale('sv_error_not_your_companion'),
            type = 'error'
        })
        return
    end

    -- Save or update customization data
    local jsonData = json.encode(customizationData)
    
    MySQL.query(
        'INSERT INTO companion_customization (companionid, citizenid, customization_data) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE customization_data = VALUES(customization_data), updated_at = CURRENT_TIMESTAMP',
        { companionId, citizenId, jsonData },
        function(result)
            if result and result.affectedRows > 0 then
                TriggerClientEvent('ox_lib:notify', src, {
                    title = locale('sv_success_customization_saved'),
                    type = 'success'
                })
                
                if Config.Debug then
                    print('[CUSTOMIZATION-SERVER] Customization saved for companion:', companionId)
                end
            else
                TriggerClientEvent('ox_lib:notify', src, {
                    title = locale('sv_error_save_failed'),
                    type = 'error'
                })
            end
        end
    )
end)

-- ================================
-- LOAD CUSTOMIZATION
-- ================================

RSGCore.Functions.CreateCallback('rsg-companions:server:LoadCustomization', function(source, cb, companionId)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then 
        cb(nil)
        return 
    end

    local citizenId = Player.PlayerData.citizenid
    
    if not companionId then
        cb(nil)
        return
    end

    -- Get customization data
    MySQL.query.await(
        'SELECT customization_data FROM companion_customization WHERE companionid = ? AND citizenid = ?',
        { companionId, citizenId },
        function(result)
            if result and result[1] then
                local customizationData = json.decode(result[1].customization_data) or {}
                cb(customizationData)
                
                if Config.Debug then
                    print('[CUSTOMIZATION-SERVER] Customization loaded for companion:', companionId)
                end
            else
                cb({}) -- Return empty table if no customization found
            end
        end
    )
end)

-- ================================
-- PURCHASE COMPONENT
-- ================================

RegisterServerEvent('rsg-companions:server:PurchaseComponent')
AddEventHandler('rsg-companions:server:PurchaseComponent', function(category, componentId, price)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Validate inputs
    if not category or not componentId or not price then
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('sv_error_invalid_data'),
            type = 'error'
        })
        return
    end

    -- Check if player has enough money
    if Player.PlayerData.money.cash < price then
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('sv_error_no_cash'),
            type = 'error'
        })
        return
    end

    -- Remove money
    Player.Functions.RemoveMoney('cash', price, 'companion-customization-purchase')

    -- Notify success
    TriggerClientEvent('ox_lib:notify', src, {
        title = locale('sv_success_component_purchased'),
        description = locale('sv_component_price', price),
        type = 'success'
    })

    -- Apply component on client
    TriggerClientEvent('rsg-companions:client:ApplyPurchasedComponent', src, category, componentId)

    if Config.Debug then
        print('[CUSTOMIZATION-SERVER] Component purchased:', category, componentId, 'for $' .. price)
    end
end)

-- ================================
-- VALIDATE COMPONENT ACCESS
-- ================================

RSGCore.Functions.CreateCallback('rsg-companions:server:CanAccessComponent', function(source, cb, category, componentId)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then 
        cb(false)
        return 
    end

    -- For now, allow all components
    -- In the future, you could implement ownership checks here
    cb(true)
end)

-- ================================
-- GET COMPONENT PRICES
-- ================================

RSGCore.Functions.CreateCallback('rsg-companions:server:GetComponentPrices', function(source, cb)
    cb(Config.PriceComponent or {})
end)

-- ================================
-- RESET CUSTOMIZATION
-- ================================

RegisterServerEvent('rsg-companions:server:ResetCustomization')
AddEventHandler('rsg-companions:server:ResetCustomization', function(companionId)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end

    local citizenId = Player.PlayerData.citizenid
    
    if not companionId then return end

    -- Validate ownership
    local companionExists = MySQL.scalar.await(
        'SELECT COUNT(*) FROM player_companions WHERE companionid = ? AND citizenid = ?',
        { companionId, citizenId }
    )

    if companionExists == 0 then
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('sv_error_not_your_companion'),
            type = 'error'
        })
        return
    end

    -- Delete customization data
    MySQL.query(
        'DELETE FROM companion_customization WHERE companionid = ? AND citizenid = ?',
        { companionId, citizenId },
        function(result)
            if result and result.affectedRows > 0 then
                TriggerClientEvent('ox_lib:notify', src, {
                    title = locale('sv_success_customization_reset'),
                    type = 'success'
                })
                
                -- Notify client to reset visual customization
                TriggerClientEvent('rsg-companions:client:ResetCustomization', src, companionId)
                
                if Config.Debug then
                    print('[CUSTOMIZATION-SERVER] Customization reset for companion:', companionId)
                end
            end
        end
    )
end)

-- ================================
-- ADMIN COMMANDS
-- ================================

if Config.Debug then
    RSGCore.Commands.Add('resetcompanioncustomization', 'Reset companion customization (Admin Only)', {
        { name = 'companionid', help = 'Companion ID' }
    }, true, function(source, args)
        local src = source
        if not RSGCore.Functions.HasPermission(src, 'admin') then return end
        
        local companionId = args[1]
        if not companionId then
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Error',
                description = 'Please provide a companion ID',
                type = 'error'
            })
            return
        end

        MySQL.query('DELETE FROM companion_customization WHERE companionid = ?', { companionId }, function(result)
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Success',
                description = 'Customization reset for companion: ' .. companionId,
                type = 'success'
            })
        end)
    end, 'admin')
end

-- ================================
-- CLEANUP ON COMPANION DELETION
-- ================================

RegisterServerEvent('rsg-companions:server:DeleteCompanion')
AddEventHandler('rsg-companions:server:DeleteCompanion', function(companionId)
    if not companionId then return end
    
    -- Clean up customization data when companion is deleted
    MySQL.query('DELETE FROM companion_customization WHERE companionid = ?', { companionId }, function(result)
        if Config.Debug and result and result.affectedRows > 0 then
            print('[CUSTOMIZATION-SERVER] Customization data cleaned up for deleted companion:', companionId)
        end
    end)
end)

-- ================================
-- RESOURCE CLEANUP
-- ================================

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        if Config.Debug then
            print('[CUSTOMIZATION-SERVER] Customization server module stopped')
        end
    end
end)