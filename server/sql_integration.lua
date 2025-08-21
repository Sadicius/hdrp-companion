-- =====================================================
-- HDRP Companion - SQL Integration with RSGCore
-- Secure database operations for companion persistence
-- =====================================================

local RSGCore = exports['rsg-core']:GetCoreObject()

-- =====================================================
-- DATABASE SCHEMA SETUP
-- =====================================================

-- Create companions table if not exists
MySQL.ready(function()
    -- Main companions table
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `hdrp_companions` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `citizenid` varchar(50) NOT NULL,
            `companion_name` varchar(100) NOT NULL DEFAULT 'Companion',
            `companion_type` varchar(50) NOT NULL DEFAULT 'dog',
            `health` int(3) NOT NULL DEFAULT '100',
            `happiness` int(3) NOT NULL DEFAULT '100',
            `hunger` int(3) NOT NULL DEFAULT '100',
            `training_level` int(2) NOT NULL DEFAULT '1',
            `skills` longtext DEFAULT '{}',
            `customization` longtext DEFAULT '{}',
            `is_active` tinyint(1) NOT NULL DEFAULT '1',
            `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
            `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            UNIQUE KEY `unique_active_companion` (`citizenid`, `is_active`),
            INDEX `idx_citizenid` (`citizenid`),
            INDEX `idx_active` (`is_active`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    -- Companion training history
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `hdrp_companion_training` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `companion_id` int(11) NOT NULL,
            `skill_type` varchar(50) NOT NULL,
            `training_session` int(11) NOT NULL DEFAULT '1',
            `success_rate` decimal(5,2) NOT NULL DEFAULT '0.00',
            `experience_gained` int(11) NOT NULL DEFAULT '0',
            `trained_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            FOREIGN KEY (`companion_id`) REFERENCES `hdrp_companions`(`id`) ON DELETE CASCADE,
            INDEX `idx_companion_training` (`companion_id`, `skill_type`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    -- Companion interactions log
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `hdrp_companion_interactions` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `companion_id` int(11) NOT NULL,
            `interaction_type` varchar(50) NOT NULL,
            `interaction_data` longtext DEFAULT '{}',
            `mood_change` int(3) NOT NULL DEFAULT '0',
            `interaction_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            FOREIGN KEY (`companion_id`) REFERENCES `hdrp_companions`(`id`) ON DELETE CASCADE,
            INDEX `idx_companion_interactions` (`companion_id`, `interaction_time`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    print("^2[HDRP-Companion]^7 Database tables initialized successfully")
end)

-- =====================================================
-- COMPANION DATA MANAGEMENT
-- =====================================================

CompanionDB = {}

-- Create new companion for player
function CompanionDB.CreateCompanion(citizenid, companionData)
    local success = false
    local companionId = nil
    
    -- Validate required data
    if not citizenid or not companionData then
        print("^1[HDRP-Companion]^7 ERROR: Missing required data for companion creation")
        return false, nil
    end
    
    -- Default companion data
    local defaultData = {
        companion_name = companionData.name or 'Faithful Companion',
        companion_type = companionData.type or 'dog',
        health = companionData.health or 100,
        happiness = companionData.happiness or 100,
        hunger = companionData.hunger or 100,
        training_level = companionData.training_level or 1,
        skills = json.encode(companionData.skills or {}),
        customization = json.encode(companionData.customization or {})
    }
    
    -- Insert companion with prepared statement
    local result = MySQL.insert.await([[
        INSERT INTO hdrp_companions 
        (citizenid, companion_name, companion_type, health, happiness, hunger, training_level, skills, customization)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]], {
        citizenid,
        defaultData.companion_name,
        defaultData.companion_type,
        defaultData.health,
        defaultData.happiness,
        defaultData.hunger,
        defaultData.training_level,
        defaultData.skills,
        defaultData.customization
    })
    
    if result then
        success = true
        companionId = result
        print("^2[HDRP-Companion]^7 Companion created for player: " .. citizenid .. " (ID: " .. companionId .. ")")
        
        -- Log initial interaction
        CompanionDB.LogInteraction(companionId, 'companion_created', {
            initial_setup = true,
            companion_type = defaultData.companion_type
        }, 10)
    else
        print("^1[HDRP-Companion]^7 ERROR: Failed to create companion for player: " .. citizenid)
    end
    
    return success, companionId
end

-- Get player's active companion
function CompanionDB.GetPlayerCompanion(citizenid)
    if not citizenid then
        return nil
    end
    
    local result = MySQL.single.await([[
        SELECT id, companion_name, companion_type, health, happiness, hunger, 
               training_level, skills, customization, created_at, updated_at
        FROM hdrp_companions 
        WHERE citizenid = ? AND is_active = 1
        LIMIT 1
    ]], { citizenid })
    
    if result then
        -- Parse JSON fields
        result.skills = json.decode(result.skills) or {}
        result.customization = json.decode(result.customization) or {}
        
        return result
    end
    
    return nil
end

-- Update companion data
function CompanionDB.UpdateCompanion(companionId, updateData)
    if not companionId or not updateData then
        return false
    end
    
    -- Build dynamic update query
    local setClause = {}
    local params = {}
    
    -- Allowed fields for update
    local allowedFields = {
        'companion_name', 'health', 'happiness', 'hunger', 'training_level'
    }
    
    for _, field in ipairs(allowedFields) do
        if updateData[field] ~= nil then
            table.insert(setClause, field .. ' = ?')
            table.insert(params, updateData[field])
        end
    end
    
    -- Handle JSON fields separately
    if updateData.skills then
        table.insert(setClause, 'skills = ?')
        table.insert(params, json.encode(updateData.skills))
    end
    
    if updateData.customization then
        table.insert(setClause, 'customization = ?')
        table.insert(params, json.encode(updateData.customization))
    end
    
    if #setClause == 0 then
        return false -- No fields to update
    end
    
    -- Add companion ID to params
    table.insert(params, companionId)
    
    -- Execute update
    local query = "UPDATE hdrp_companions SET " .. table.concat(setClause, ', ') .. " WHERE id = ?"
    local result = MySQL.update.await(query, params)
    
    if result > 0 then
        print("^2[HDRP-Companion]^7 Companion updated: " .. companionId)
        return true
    else
        print("^1[HDRP-Companion]^7 ERROR: Failed to update companion: " .. companionId)
        return false
    end
end

-- Record companion training session
function CompanionDB.RecordTraining(companionId, skillType, sessionData)
    if not companionId or not skillType then
        return false
    end
    
    local success_rate = sessionData.success_rate or 0.0
    local experience_gained = sessionData.experience_gained or 0
    local training_session = sessionData.session_number or 1
    
    local result = MySQL.insert.await([[
        INSERT INTO hdrp_companion_training 
        (companion_id, skill_type, training_session, success_rate, experience_gained)
        VALUES (?, ?, ?, ?, ?)
    ]], {
        companionId,
        skillType,
        training_session,
        success_rate,
        experience_gained
    })
    
    if result then
        print("^2[HDRP-Companion]^7 Training recorded for companion: " .. companionId .. " (" .. skillType .. ")")
        return true
    else
        print("^1[HDRP-Companion]^7 ERROR: Failed to record training for companion: " .. companionId)
        return false
    end
end

-- Log companion interaction
function CompanionDB.LogInteraction(companionId, interactionType, interactionData, moodChange)
    if not companionId or not interactionType then
        return false
    end
    
    moodChange = moodChange or 0
    interactionData = interactionData or {}
    
    local result = MySQL.insert.await([[
        INSERT INTO hdrp_companion_interactions 
        (companion_id, interaction_type, interaction_data, mood_change)
        VALUES (?, ?, ?, ?)
    ]], {
        companionId,
        interactionType,
        json.encode(interactionData),
        moodChange
    })
    
    if result then
        return true
    else
        print("^1[HDRP-Companion]^7 ERROR: Failed to log interaction for companion: " .. companionId)
        return false
    end
end

-- Get companion training history
function CompanionDB.GetTrainingHistory(companionId, skillType, limit)
    if not companionId then
        return {}
    end
    
    limit = limit or 10
    local query
    local params
    
    if skillType then
        query = [[
            SELECT skill_type, training_session, success_rate, experience_gained, trained_at
            FROM hdrp_companion_training 
            WHERE companion_id = ? AND skill_type = ?
            ORDER BY trained_at DESC
            LIMIT ?
        ]]
        params = { companionId, skillType, limit }
    else
        query = [[
            SELECT skill_type, training_session, success_rate, experience_gained, trained_at
            FROM hdrp_companion_training 
            WHERE companion_id = ?
            ORDER BY trained_at DESC
            LIMIT ?
        ]]
        params = { companionId, limit }
    end
    
    local result = MySQL.query.await(query, params)
    return result or {}
end

-- Deactivate companion (soft delete)
function CompanionDB.DeactivateCompanion(companionId)
    if not companionId then
        return false
    end
    
    local result = MySQL.update.await([[
        UPDATE hdrp_companions 
        SET is_active = 0 
        WHERE id = ?
    ]], { companionId })
    
    if result > 0 then
        print("^2[HDRP-Companion]^7 Companion deactivated: " .. companionId)
        return true
    else
        print("^1[HDRP-Companion]^7 ERROR: Failed to deactivate companion: " .. companionId)
        return false
    end
end

-- Clean up old interaction logs (run periodically)
function CompanionDB.CleanupOldLogs(daysToKeep)
    daysToKeep = daysToKeep or 30
    
    local result = MySQL.query.await([[
        DELETE FROM hdrp_companion_interactions 
        WHERE interaction_time < DATE_SUB(NOW(), INTERVAL ? DAY)
    ]], { daysToKeep })
    
    if result then
        print("^2[HDRP-Companion]^7 Cleaned up interaction logs older than " .. daysToKeep .. " days")
    end
end

-- =====================================================
-- RSGCore INTEGRATION CALLBACKS
-- =====================================================

-- Server callback to get companion data
RSGCore.Functions.CreateCallback('hdrp-companion:server:getCompanionData', function(source, cb)
    local Player = RSGCore.Functions.GetPlayer(source)
    if not Player then
        cb(nil)
        return
    end
    
    local companion = CompanionDB.GetPlayerCompanion(Player.PlayerData.citizenid)
    cb(companion)
end)

-- Server callback to create new companion
RSGCore.Functions.CreateCallback('hdrp-companion:server:createCompanion', function(source, cb, companionData)
    local Player = RSGCore.Functions.GetPlayer(source)
    if not Player then
        cb({ success = false, message = "Player not found" })
        return
    end
    
    -- Check if player already has an active companion
    local existingCompanion = CompanionDB.GetPlayerCompanion(Player.PlayerData.citizenid)
    if existingCompanion then
        cb({ success = false, message = "You already have an active companion" })
        return
    end
    
    local success, companionId = CompanionDB.CreateCompanion(Player.PlayerData.citizenid, companionData)
    
    if success then
        cb({ 
            success = true, 
            companionId = companionId,
            message = "Companion created successfully" 
        })
    else
        cb({ success = false, message = "Failed to create companion" })
    end
end)

-- Server callback to update companion
RSGCore.Functions.CreateCallback('hdrp-companion:server:updateCompanion', function(source, cb, companionId, updateData)
    local Player = RSGCore.Functions.GetPlayer(source)
    if not Player then
        cb({ success = false, message = "Player not found" })
        return
    end
    
    -- Verify companion ownership
    local companion = CompanionDB.GetPlayerCompanion(Player.PlayerData.citizenid)
    if not companion or companion.id ~= companionId then
        cb({ success = false, message = "Companion not found or not owned by player" })
        return
    end
    
    local success = CompanionDB.UpdateCompanion(companionId, updateData)
    
    if success then
        cb({ success = true, message = "Companion updated successfully" })
    else
        cb({ success = false, message = "Failed to update companion" })
    end
end)

-- =====================================================
-- NETWORK EVENTS
-- =====================================================

-- Handle companion interaction
RegisterNetEvent('hdrp-companion:server:recordInteraction', function(interactionType, interactionData, moodChange)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    
    if not Player then
        return
    end
    
    local companion = CompanionDB.GetPlayerCompanion(Player.PlayerData.citizenid)
    if not companion then
        return
    end
    
    -- Log the interaction
    CompanionDB.LogInteraction(companion.id, interactionType, interactionData, moodChange)
    
    -- Update companion mood if necessary
    if moodChange and moodChange ~= 0 then
        local newHappiness = math.max(0, math.min(100, companion.happiness + moodChange))
        CompanionDB.UpdateCompanion(companion.id, { happiness = newHappiness })
    end
end)

-- Handle training session
RegisterNetEvent('hdrp-companion:server:recordTraining', function(skillType, sessionData)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    
    if not Player then
        return
    end
    
    local companion = CompanionDB.GetPlayerCompanion(Player.PlayerData.citizenid)
    if not companion then
        return
    end
    
    -- Record training session
    local success = CompanionDB.RecordTraining(companion.id, skillType, sessionData)
    
    if success and sessionData.level_up then
        -- Update companion training level
        CompanionDB.UpdateCompanion(companion.id, { 
            training_level = companion.training_level + 1 
        })
        
        -- Notify player
        TriggerClientEvent('rsg-core:Notify', src, 
            'Your companion leveled up!', 'success', 5000)
    end
end)

-- =====================================================
-- MAINTENANCE FUNCTIONS
-- =====================================================

-- Periodic cleanup (run every hour)
Citizen.CreateThread(function()
    while true do
        Wait(3600000) -- 1 hour
        CompanionDB.CleanupOldLogs(30) -- Keep 30 days of logs
    end
end)

-- Export functions for other resources
exports('GetPlayerCompanion', function(citizenid)
    return CompanionDB.GetPlayerCompanion(citizenid)
end)

exports('UpdateCompanion', function(companionId, updateData)
    return CompanionDB.UpdateCompanion(companionId, updateData)
end)

exports('RecordInteraction', function(companionId, interactionType, interactionData, moodChange)
    return CompanionDB.LogInteraction(companionId, interactionType, interactionData, moodChange)
end)

print("^2[HDRP-Companion]^7 SQL Integration loaded successfully")