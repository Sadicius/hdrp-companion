local RSGCore = exports['rsg-core']:GetCoreObject()
-- CompanionSettings now available as Config.StableSettings (loaded via shared_scripts)
lib.locale()

-----------------
-- SQL
-----------------
local successStart, resultStart = pcall(MySQL.scalar.await, 'SELECT 1 FROM player_companions')
if not successStart then
    MySQL.query([[CREATE TABLE IF NOT EXISTS `player_companions` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `stable` varchar(50) NOT NULL,
        `citizenid` varchar(50) NOT NULL,
        `companionid` varchar(11) NOT NULL,
        `companiondata` LONGTEXT NOT NULL DEFAULT '{}',
        `components` LONGTEXT NOT NULL DEFAULT '{}',
        `wild` varchar(11) DEFAULT NULL,
        `active` tinyint(4) DEFAULT 0,
        `breedable` VARCHAR(50) DEFAULT NULL,
        `inBreed` VARCHAR(50) DEFAULT NULL,
        PRIMARY KEY (`id`)
    )]])
    if Config.Debug then print(locale('sv_print_1')) end
end

-- ================================
-- ENHANCED AI MEMORY DATABASE v4.7.0
-- ================================

-- Create companion memory table for persistent AI learning
local successMemoryStart, resultMemoryStart = pcall(MySQL.scalar.await, 'SELECT 1 FROM companion_memory')
if not successMemoryStart then
    MySQL.query([[CREATE TABLE IF NOT EXISTS `companion_memory` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `citizenid` varchar(50) NOT NULL,
        `companionid` varchar(11) NOT NULL,
        `memory_type` varchar(50) NOT NULL,
        `memory_data` LONGTEXT NOT NULL DEFAULT '{}',
        `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
        `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (`id`),
        INDEX `citizen_companion` (`citizenid`, `companionid`),
        INDEX `memory_type` (`memory_type`)
    )]])
    if Config.Debug then print('[COMPANION-AI] Memory database table created') end
end

-- Create companion coordination table for multi-companion management
local successCoordStart, resultCoordStart = pcall(MySQL.scalar.await, 'SELECT 1 FROM companion_coordination')
if not successCoordStart then
    MySQL.query([[CREATE TABLE IF NOT EXISTS `companion_coordination` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `citizenid` varchar(50) NOT NULL,
        `companion_count` int(11) DEFAULT 0,
        `group_behavior` varchar(50) DEFAULT 'independent',
        `leadership_data` LONGTEXT DEFAULT '{}',
        `coordination_settings` LONGTEXT DEFAULT '{}',
        `last_updated` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (`id`),
        UNIQUE KEY `unique_citizen` (`citizenid`)
    )]])
    if Config.Debug then print('[COMPANION-AI] Coordination database table created') end
end

RegisterServerEvent('rsg-companions:server:food')
AddEventHandler('rsg-companions:server:food', function()
	local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
	Player.Functions.AddItem('raw_meat', 1)
    TriggerClientEvent('rNotify:ShowAdvancedRightNotification', src, "1 x "..RSGCore.Shared.Items['raw_meat'].label, "generic_textures" , "tick" , "COLOR_PURE_WHITE", 4000)
end)

----------------------------------
-- command
----------------------------------
RSGCore.Commands.Add('pet_find', 'Find where your companions are stored', {}, false, function(source)
    TriggerClientEvent('rsg-companions:client:getcompanionlocation', source)
end)

RSGCore.Commands.Add('pet_menu', 'Access the main pet menu', {}, false, function(source)
    TriggerClientEvent('rsg-companions:client:mypetsactions', source) -- main menu
end)

RSGCore.Commands.Add('pet_stats', 'Access the pet status menu', {}, false, function(source)
    TriggerClientEvent('rsg-companions:client:mypets', source) -- menu stats
end)

RSGCore.Commands.Add('pet_games', 'Access the pet games menu', {}, false, function(source)
    TriggerClientEvent('rsg-companions:client:mypetsgames', source) -- menu games
end)

RSGCore.Commands.Add('pet_customize', 'Open companion customization menu', {}, false, function(source)
    TriggerClientEvent('rsg-companions:client:openCustomizationMenu', source) -- customization menu
end)

----------------------------------
-- Buy & active
----------------------------------
-- Get All Companions
RSGCore.Functions.CreateCallback('rsg-companions:server:GetAllCompanions', function(source, cb)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local success, companions = pcall(MySQL.query.await, 'SELECT * FROM player_companions WHERE citizenid = @citizenid', { ['@citizenid'] = Player.PlayerData.citizenid })
    if success and companions and companions[1] then
        cb(companions)
    else
        cb(nil)
    end
end)

-- get cash
RSGCore.Functions.CreateCallback('rsg-companions:server:getmoney', function(source, cb)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local cash = Player.PlayerData.money['cash']
    cb(cash)
end)

-- generate companionid
local function GenerateCompanionid()
    local UniqueFound = false
    local companionid = nil
    while not UniqueFound do
        companionid = (RSGCore.Shared.RandomStr(3) .. RSGCore.Shared.RandomInt(3)):upper()
        local success, result = pcall(MySQL.prepare.await, 'SELECT COUNT(*) AS count FROM player_companions WHERE companionid = ?', { companionid })
        if success and result and tonumber(result) == 0 then
            UniqueFound = true
        else
            if not success then break end
        end
    end
    return companionid
end

-- BUY
RegisterServerEvent('rsg-companions:server:BuyCompanion', function(price, model, stable, companionname, gender)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    if (Player.PlayerData.money.cash < price) then TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_error_no_cash'), type = 'error', duration = 5000 }) return end

    local companionid = GenerateCompanionid()
    local skin = math.floor(math.random(0, 2))
    local breedable = {"Yes", "No"}
    local randomIndex1 = math.random(1, #breedable)

    local datacomp = {
        -- information
        id = companionid,
        name = companionname or nil,
        companion = model or nil,
        skin = skin or 0,
        gender = gender,
        -- atributes
        hunger = Config.PetAttributes.Starting.Hunger or 100,
        thirst = Config.PetAttributes.Starting.Thirst or 100,
        happiness = Config.PetAttributes.Starting.Happines or 100,
        dirt = 100.0,
        age = 1.0,
        scale = 0.5,
        companionxp = 0.0,
        dead = false,
        born = os.time()
    }

    local animaldata = json.encode(datacomp)
    local success, result = pcall(MySQL.insert, 'INSERT INTO player_companions(stable, citizenid, companionid, companiondata, active, breedable, inBreed) VALUES(@stable, @citizenid, @companionid, @companiondata, @active, @breedable, @inBreed)', {
        ['@stable'] = stable,
        ['@citizenid'] = Player.PlayerData.citizenid,
        ['@companionid'] = companionid,
        ['@companiondata'] = animaldata,
        ['@active'] = false,
        ['@breedable'] = breedable[randomIndex1],
        ['@inBreed'] = "No"
    })
    if not success then return end

    Player.Functions.RemoveMoney('cash', price)

    local discordMessage = string.format(
        locale('sv_log_c')..":** %s \n**"
        ..locale('sv_log_d')..":** %d \n**"
        ..locale('sv_log_e')..":** %s %s \n**"
        ..locale('sv_log_f')..":** %s \n**"
        ..locale('sv_log_g')..":** %s \n**"
        ..locale('sv_log_h')..":** %s \n**"
        ..locale('sv_log_i')..":** %.2f**",
        Player.PlayerData.citizenid,
        Player.PlayerData.cid,
        Player.PlayerData.charinfo.firstname,
        Player.PlayerData.charinfo.lastname,
        companionid,
        companionname,
        model,
        price
    )
    TriggerEvent('rsg-log:server:CreateLog', Config.WebhookName, Config.WebhookTitle, Config.WebhookColour, discordMessage, false)
    TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_success_companion_owned'), type = 'success', duration = 5000 })
end)

-- active
RegisterServerEvent('rsg-companions:server:SetCompanionsActive', function(id)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    local breedcompanion = MySQL.scalar.await('SELECT id FROM player_companions WHERE citizenid = ? AND inBreed = ?', {Player.PlayerData.citizenid, true})
    if breedcompanion then TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_error_companion_in_breed'), type = 'success', duration = 5000 }) return end
    local activecompanion = MySQL.scalar.await('SELECT id FROM player_companions WHERE citizenid = ? AND active = ?', {Player.PlayerData.citizenid, true})
    MySQL.update('UPDATE player_companions SET active = ? WHERE id = ? AND citizenid = ?', { false, activecompanion, Player.PlayerData.citizenid })
    MySQL.update('UPDATE player_companions SET active = ? WHERE id = ? AND citizenid = ?', { true, id, Player.PlayerData.citizenid })
end)

-- UNactive
RegisterServerEvent('rsg-companions:server:SetCompanionsUnActive', function(id, stableid)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- FIX: Buscar mascota activa correctamente (active = true)
    local activecompanion = MySQL.scalar.await('SELECT id FROM player_companions WHERE citizenid = ? AND active = ?', {Player.PlayerData.citizenid, true})
    
    -- Desactivar mascota activa actual si existe
    if activecompanion then
        MySQL.update('UPDATE player_companions SET active = ? WHERE id = ? AND citizenid = ?', { false, activecompanion, Player.PlayerData.citizenid })
    end
    
    -- Desactivar la mascota específica y asignar al establo
    MySQL.update('UPDATE player_companions SET active = ?, stable = ? WHERE id = ? AND citizenid = ?', { false, stableid, id, Player.PlayerData.citizenid })
end)

-- store companion when flee is used
RegisterServerEvent('rsg-companions:server:fleeStoreCompanion', function(stableid)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    local activecompanion = MySQL.scalar.await('SELECT id FROM player_companions WHERE citizenid = ? AND active = ?', {Player.PlayerData.citizenid, 1})
    MySQL.update('UPDATE player_companions SET active = ? WHERE id = ? AND citizenid = ?', { false, activecompanion, Player.PlayerData.citizenid })
    MySQL.update('UPDATE player_companions SET stable = ? WHERE id = ? AND citizenid = ?', { stableid, activecompanion, Player.PlayerData.citizenid })
end)

----------------------------------
-- sell companion
----------------------------------
RegisterServerEvent('rsg-companions:server:deletecompanion', function(data)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    local modelCompanion = nil
    local companionname = nil
    local companionid = data.companionid
    local sellprice = 0.0

    for k, v in pairs(CompanionSettings) do
        if v.companionmodel == modelCompanion then
            sellprice = v.companionprice * Config.pricedepreciation
        end
    end

    local success, player_companions = pcall(MySQL.query.await, 'SELECT * FROM player_companions WHERE companionid = ? AND citizenid = ?', { companionid, Player.PlayerData.citizenid })
    if not success or not player_companions or not player_companions[1] then player_companions = nil  end

    if player_companions then
        for i = 1, #player_companions do
            local row = player_companions[i]
            if tonumber(row.companionid) == tonumber(companionid) then
                local companionData = json.decode(row.companiondata)
                companionname = companionData.name
                modelCompanion = companionData.companion
                local successDelete, result = pcall(MySQL.update, 'DELETE FROM player_companions WHERE companionid = ? AND citizenid = ?', { row.companionid, Player.PlayerData.citizenid })
                if not successDelete then return end
            end
        end
    end

    Player.Functions.AddMoney('cash', sellprice)
    TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_success_companion_sold_for')..sellprice, type = 'success', duration = 5000 })

    local discordMessage = string.format(
        locale('sv_log_c')..":** %s \n**"
        ..locale('sv_log_d')..":** %d \n**"
        ..locale('sv_log_e')..":** %s %s \n**"
        ..locale('sv_log_f')..":** %s \n**"
        ..locale('sv_log_g')..":** %s \n**"
        ..locale('sv_log_h')..":** %s \n**"
        ..locale('sv_log_k')..":** %.2f**",
        Player.PlayerData.citizenid,
        Player.PlayerData.cid,
        Player.PlayerData.charinfo.firstname,
        Player.PlayerData.charinfo.lastname,
        companionid,
        companionname,
        modelCompanion,
        sellprice
    )
    TriggerEvent('rsg-log:server:CreateLog', Config.WebhookName, Config.WebhookTitle, Config.WebhookColour, discordMessage, false)
end)

lib.callback.register('rsg-companions:server:GetCompanion', function(source, stable)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end

    local companions = {}
    local success, Result = pcall(MySQL.query.await, 'SELECT * FROM player_companions WHERE citizenid=@citizenid AND stable=@stable AND inBreed=@inBreed', { ['@citizenid'] = Player.PlayerData.citizenid, ['@stable'] = stable, ['@inBreed'] = "No" })
    if not success or not Result or #Result == 0 then return companions end

    for i = 1, #Result do
        companions[#companions + 1] = Result[i]
    end

    return companions
end)

RSGCore.Functions.CreateCallback('rsg-companions:server:GetActiveCompanion', function(source, cb)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then cb(nil) return end
    local success, result = pcall(MySQL.query.await, 'SELECT * FROM player_companions WHERE citizenid=@citizenid AND active=@active', { ['@citizenid'] = Player.PlayerData.citizenid, ['@active'] = 1 })
    if not success or not result or #result == 0 then cb(nil) return end
    cb(result[1])
end)

RegisterNetEvent('rsg-companions:server:TradeCompanion', function(playerId, companionId, source)
    local src = source
    local Player2 = RSGCore.Functions.GetPlayer(playerId)
    local Playercid2 = Player2.PlayerData.citizenid

    local success, result = pcall(MySQL.update, 'UPDATE player_companions SET citizenid = ? WHERE companionid = ? AND active = ?', {Playercid2, companionId, 1})
    if not success then return end
    local successB, resultB = pcall(MySQL.update, 'UPDATE player_companions SET active = ? WHERE citizenid = ? AND active = ?', {0, Playercid2, 1})
    if not successB then return end

    TriggerClientEvent('ox_lib:notify', playerId, {title = locale('sv_success_companion_owned'), type = 'success', duration = 5000 })

    local discordMessage = string.format(
        locale('sv_log_c')..":** %s \n**"
        ..locale('sv_log_d')..":** %d \n**"
        ..locale('sv_log_e')..":** %s %s \n**"
        ..locale('sv_log_n')..":** %s \n**"
        ..locale('sv_log_f')..":** %s **",
        Player2.PlayerData.citizenid,
        Player2.PlayerData.cid,
        Player2.PlayerData.charinfo.firstname,
        Player2.PlayerData.charinfo.lastname,
        playerId,
        companionId
    )
    TriggerEvent('rsg-log:server:CreateLog', Config.WebhookName, Config.WebhookTitle, Config.WebhookColour, discordMessage, false)
end)

-- ================================
-- ENHANCED AI SERVER EVENTS v4.7.0
-- ================================

-- Memory Management Server Events
RegisterNetEvent('rsg-companions:server:saveMemory', function(memoryData)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player or not memoryData then return end
    
    local citizenid = Player.PlayerData.citizenid
    
    -- Get active companion
    local activeCompanion = MySQL.query.await('SELECT companionid FROM player_companions WHERE citizenid = ? AND active = 1', { citizenid })
    if not activeCompanion or not activeCompanion[1] then return end
    
    local companionid = activeCompanion[1].companionid
    
    -- Save different types of memory data
    local memoryTypes = {
        { type = 'player_preferences', data = memoryData.player_preferences },
        { type = 'location_familiarity', data = memoryData.location_familiarity },
        { type = 'long_term_associations', data = memoryData.long_term_associations }
    }
    
    for _, memory in ipairs(memoryTypes) do
        if memory.data then
            local jsonData = json.encode(memory.data)
            
            -- Use INSERT ... ON DUPLICATE KEY UPDATE pattern
            MySQL.insert('INSERT INTO companion_memory (citizenid, companionid, memory_type, memory_data) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE memory_data = VALUES(memory_data), updated_at = CURRENT_TIMESTAMP', {
                citizenid,
                companionid,
                memory.type,
                jsonData
            })
        end
    end
    
    if Config.Debug then
        print('[COMPANION-AI] Memory saved for companion: ' .. companionid)
    end
end)

RegisterNetEvent('rsg-companions:server:requestMemory', function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local citizenid = Player.PlayerData.citizenid
    
    -- Get active companion
    local activeCompanion = MySQL.query.await('SELECT companionid FROM player_companions WHERE citizenid = ? AND active = 1', { citizenid })
    if not activeCompanion or not activeCompanion[1] then return end
    
    local companionid = activeCompanion[1].companionid
    
    -- Retrieve memory data
    local memoryResult = MySQL.query.await('SELECT memory_type, memory_data FROM companion_memory WHERE citizenid = ? AND companionid = ?', { citizenid, companionid })
    
    local memoryData = {}
    if memoryResult then
        for _, row in ipairs(memoryResult) do
            local success, decodedData = pcall(json.decode, row.memory_data)
            if success and decodedData then
                memoryData[row.memory_type] = decodedData
            end
        end
    end
    
    TriggerClientEvent('rsg-companions:client:receiveMemory', src, memoryData)
    
    if Config.Debug then
        print('[COMPANION-AI] Memory sent for companion: ' .. companionid)
    end
end)

-- Coordination Management Server Events
RegisterNetEvent('rsg-companions:server:updateCoordination', function(coordinationData)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player or not coordinationData then return end
    
    local citizenid = Player.PlayerData.citizenid
    
    -- Count active companions
    local companionCount = MySQL.scalar.await('SELECT COUNT(*) FROM player_companions WHERE citizenid = ? AND active = 1', { citizenid }) or 0
    
    local groupBehavior = coordinationData.group_behavior or 'independent'
    local leadershipData = json.encode(coordinationData.leadership_data or {})
    local coordinationSettings = json.encode(coordinationData.coordination_settings or {})
    
    -- Update or insert coordination data
    MySQL.insert('INSERT INTO companion_coordination (citizenid, companion_count, group_behavior, leadership_data, coordination_settings) VALUES (?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE companion_count = VALUES(companion_count), group_behavior = VALUES(group_behavior), leadership_data = VALUES(leadership_data), coordination_settings = VALUES(coordination_settings), last_updated = CURRENT_TIMESTAMP', {
        citizenid,
        companionCount,
        groupBehavior,
        leadershipData,
        coordinationSettings
    })
    
    if Config.Debug then
        print('[COMPANION-AI] Coordination updated for citizen: ' .. citizenid .. ' with ' .. companionCount .. ' companions')
    end
end)

RSGCore.Functions.CreateCallback('rsg-companions:server:getCoordination', function(source, cb)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then cb(nil) return end
    
    local citizenid = Player.PlayerData.citizenid
    
    local result = MySQL.query.await('SELECT * FROM companion_coordination WHERE citizenid = ?', { citizenid })
    if result and result[1] then
        local data = result[1]
        -- Decode JSON fields
        local success1, leadershipData = pcall(json.decode, data.leadership_data or '{}')
        local success2, coordinationSettings = pcall(json.decode, data.coordination_settings or '{}')
        
        cb({
            companion_count = data.companion_count,
            group_behavior = data.group_behavior,
            leadership_data = success1 and leadershipData or {},
            coordination_settings = success2 and coordinationSettings or {},
            last_updated = data.last_updated
        })
    else
        cb(nil)
    end
end)

-- Enhanced companion spawning with AI initialization
RegisterNetEvent('rsg-companions:server:companionSpawned', function(companionData)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local citizenid = Player.PlayerData.citizenid
    
    -- Initialize AI memory for new companions
    if companionData and companionData.companionid then
        -- Check if memory already exists
        local existingMemory = MySQL.scalar.await('SELECT COUNT(*) FROM companion_memory WHERE citizenid = ? AND companionid = ?', { citizenid, companionData.companionid })
        
        if not existingMemory or existingMemory == 0 then
            -- Initialize default memory structure
            local defaultMemory = {
                player_preferences = {},
                location_familiarity = {},
                long_term_associations = {}
            }
            
            for memoryType, data in pairs(defaultMemory) do
                MySQL.insert('INSERT INTO companion_memory (citizenid, companionid, memory_type, memory_data) VALUES (?, ?, ?, ?)', {
                    citizenid,
                    companionData.companionid,
                    memoryType,
                    json.encode(data)
                })
            end
            
            if Config.Debug then
                print('[COMPANION-AI] Initialized memory for new companion: ' .. companionData.companionid)
            end
        end
    end
    
    -- Update coordination data
    TriggerEvent('rsg-companions:server:updateCoordination', {
        group_behavior = 'independent',
        leadership_data = {},
        coordination_settings = {}
    })
end)

-- Performance monitoring callback
RSGCore.Functions.CreateCallback('rsg-companions:server:getAIPerformance', function(source, cb)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then cb(nil) return end
    
    local citizenid = Player.PlayerData.citizenid
    
    -- Get companion count and memory usage statistics
    local companionCount = MySQL.scalar.await('SELECT COUNT(*) FROM player_companions WHERE citizenid = ? AND active = 1', { citizenid }) or 0
    local memoryCount = MySQL.scalar.await('SELECT COUNT(*) FROM companion_memory WHERE citizenid = ?', { citizenid }) or 0
    
    cb({
        active_companions = companionCount,
        memory_entries = memoryCount,
        ai_version = '4.7.0',
        features = {
            context_analysis = true,
            enhanced_memory = true,
            multi_companion_coordination = true,
            decision_engine = true
        }
    })
end)

----------------------------------
-- search data tables
----------------------------------
-- function DetectCoordinates(entry)
--     local coordsColumns = {
--         "coords", "coordinates", "location", "position", "xyz", "pos", "properties", "propdata", "plate"
--     }

--     -- Revisar las columnas y mostrar el valor
--     for _, colName in ipairs(coordsColumns) do
--         if entry[colName] then
--             print(string.format("Found %s: %s", colName, tostring(entry[colName]))) -- Debugging line
--             local value = entry[colName]

--             -- Si el valor es una cadena JSON, intentar decodificarlo
--             if type(value) == "string" then
--                 local success, decodedValue = pcall(json.decode, value)
--                 if success and decodedValue then
--                     if decodedValue.x and decodedValue.y and decodedValue.z then
--                         return { x = tonumber(decodedValue.x), y = tonumber(decodedValue.y), z = tonumber(decodedValue.z) }
--                     elseif decodedValue.coords and decodedValue.coords.x and decodedValue.coords.y and decodedValue.coords.z then
--                         return { x = tonumber(decodedValue.coords.x), y = tonumber(decodedValue.coords.y), z = tonumber(decodedValue.coords.z) }
--                     end
--                 end
--             -- Si el valor no es un string pero parece un array de coordenadas (x, y, z)
--             elseif type(value) == "table" and #value >= 3 then
--                 return { x = tonumber(value[1]), y = tonumber(value[2]), z = tonumber(value[3]) }
--             elseif value.x and value.y and value.z then
--                 return { x = tonumber(value.x), y = tonumber(value.y), z = tonumber(value.z) }
--             end
--         end
--     end

--     if entry.position then
--         if type(entry.position) == "string" then
--             local success, decodedValue = pcall(json.decode, entry.position)
--             if success and decodedValue then
--                 if decodedValue.x and decodedValue.y and decodedValue.z then
--                     return { x = tonumber(decodedValue.x), y = tonumber(decodedValue.y), z = tonumber(decodedValue.z) }
--                 elseif type(decodedValue) == "table" and #decodedValue >= 3 then
--                     return { x = tonumber(decodedValue[1]), y = tonumber(decodedValue[2]), z = tonumber(decodedValue[3]) }
--                 elseif decodedValue.coords and decodedValue.coords.x and decodedValue.coords.y and decodedValue.coords.z then
--                     return { x = tonumber(decodedValue.coords.x), y = tonumber(decodedValue.coords.y), z = tonumber(decodedValue.coords.z) }
--                 end
--             end
--             -- Log for debugging
--             print(string.format("Failed to parse position for citizenid %s: %s", entry.citizenid or "unknown", tostring(entry.position)))
--         else
--             print(string.format("Position is not a string for citizenid %s: %s", entry.citizenid or "unknown", tostring(entry.position)))
--         end
--     end

--     -- Revisar si las coordenadas están en los campos directos (x, y, z)
--     if entry.x and entry.y and entry.z then
--         return { x = tonumber(entry.x), y = tonumber(entry.y), z = tonumber(entry.z) }
--     end

--     -- Check for JSON in other columns
--     for colName, value in pairs(entry) do
--         if type(value) == "string" and string.match(value, "[%{%[].-[%}%]]") then
--             local success, decodedValue = pcall(json.decode, value)
--             if success and decodedValue then
--                 if decodedValue.x and decodedValue.y and decodedValue.z then
--                     return { x = tonumber(decodedValue.x), y = tonumber(decodedValue.y), z = tonumber(decodedValue.z) }
--                 elseif type(decodedValue) == "table" and #decodedValue >= 3 then
--                     return { x = tonumber(decodedValue[1]), y = tonumber(decodedValue[2]), z = tonumber(decodedValue[3]) }
--                 end
--             end
--         end
--     end

--     return nil
-- end

local function parseJSONCoords(value)
    local ok, v = pcall(json.decode, value) -- Intenta descodificar un string JSON de varias formas
    if not ok or type(v) ~= "table" then return nil end

    if v.x and v.y and v.z then    -- Caso 1: { x=…, y=…, z=… }
        return { x = tonumber(v.x), y = tonumber(v.y), z = tonumber(v.z) }
    end

    if v.coords and v.coords.x and v.coords.y and v.coords.z then    -- Caso 2: { coords = { x=…, y=…, z=… } }
        return { x = tonumber(v.coords.x), y = tonumber(v.coords.y), z = tonumber(v.coords.z) }
    end

    if #v >= 3 then    -- Caso 3: [x, y, z]
        return { x = tonumber(v[1]), y = tonumber(v[2]), z = tonumber(v[3]) }
    end

    return nil
end

function DetectCoordinates(entry)

    for _, field in ipairs(Config.TablesTrack.coordsColumns) do
        local v = entry[field]
        if v then
            if type(v) == "table" then
                if v.x and v.y and v.z then
                    return { x=v.x, y=v.y, z=v.z }
                elseif #v>=3 then
                    return { x=v[1], y=v[2], z=v[3] }
                end
            elseif type(v)=="string" then
                local parsed = parseJSONCoords(v)
                if parsed then return parsed end
            end
        end
    end

    -- 2) Campos directos
    if entry.x and entry.y and entry.z then
        return { x=tonumber(entry.x), y=tonumber(entry.y), z=tonumber(entry.z) }
    end

    -- 3) Cualquier string JSON en otros campos
    for k, v in pairs(entry) do
        if type(v)=="string" and v:match("^%s*%[") or v:match("^%s*%{") then
            local parsed = parseJSONCoords(v)
            if parsed then return parsed end
        end
    end

    return nil
end

RegisterServerEvent('rsg-companions:server:searchDatabase')
AddEventHandler('rsg-companions:server:searchDatabase', function(playerCoords, tableName)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)

    -- Check job permission
    -- local foundJob = nil
    -- for _, job in ipairs(Config.TablesTrack.TrackingJob) do
    --     foundJob = job
    --     break
    -- end

    -- if not Player or Player.PlayerData.job.type ~= foundJob then TriggerClientEvent('ox_lib:notify', src, { title = 'Access Denied', description = 'Only ' .. foundJob .. ' can use the tracking feature.', type = 'error', duration = 5000 }) return end

    MySQL.Async.fetchAll("SELECT * FROM player_companions WHERE citizenid = ? AND active = ?",
        {Player.PlayerData.citizenid, true},
        function(result)
            if not result[1] then TriggerClientEvent('ox_lib:notify', src, { title = locale('cl_error_cancompanion'), description = locale('cl_error_cancompanion_des'), type = 'error', duration = 5000 }) return end

            if not tableName or type(tableName) ~= 'string' then return end

            local isValidTable = false
            for _, allowedTable in ipairs(Config.TablesTrack.AllowedSearchTables or {}) do
                if allowedTable == tableName then
                    isValidTable = true
                    break
                end
            end

            if not isValidTable then return end

            local validEntries = {}
            local function processTableResults(results, tblName)
                if not results then TriggerClientEvent('ox_lib:notify', src, { title = locale('sv_error_db'), description = locale('sv_error_db_des') .. tblName, type = 'error', duration = 5000 }) return end
                for _, entry in ipairs(results) do
                    local coordsData = DetectCoordinates(entry)
                    if coordsData and coordsData.x and coordsData.y and coordsData.z then
                        if coordsData.x ~= 0 and coordsData.y ~= 0 and coordsData.z ~= 0 then
                            print("Type of 'table' before insert: " .. type(table))  -- Esto debería devolver "table"

                            table.insert(validEntries, {
                                coords = coordsData,
                                entry = entry,
                                tableName = tblName
                            })
                        end
                    else
                        print("Invalid coordinates for entry: " .. tostring(entry)) -- Debugging
                    end
                end
            end

            MySQL.Async.fetchAll("SELECT * FROM " .. tableName .. " LIMIT 100", {}, function(results)
                processTableResults(results or {}, tableName)
                if #validEntries == 0 then
                    TriggerClientEvent('ox_lib:notify', src, { title = locale('sv_error_coords'), description = locale('sv_error_coords_des') .. tableName .. locale('sv_error_coords_desB'), type = 'error', duration = 7000 })
                    return
                end

                local closestEntry = nil
                local minDistance = math.huge
                for _, entry in ipairs(validEntries) do
                    local distance = #(vector3(playerCoords.x, playerCoords.y, playerCoords.z) - vector3(entry.coords.x, entry.coords.y, entry.coords.z))
                    if distance < minDistance then
                        minDistance = distance
                        closestEntry = entry
                    end
                end

                if closestEntry then
                    TriggerClientEvent('rsg-companions:client:trackDatabaseEntry', src, closestEntry.coords, closestEntry.tableName, closestEntry.entry)
                    TriggerClientEvent('ox_lib:notify', src, { title = locale('sv_search'), description = locale('sv_search_desc'), type = 'success', duration = 5000 })
                else
                    TriggerClientEvent('ox_lib:notify', src, { title = locale('sv_error_db_e'), description = locale('sv_error_desc_coords'), type = 'error', duration = 5000 })
                end
            end)
        end)
end)

RegisterServerEvent('rsg-companions:server:getOnlinePlayers')
AddEventHandler('rsg-companions:server:getOnlinePlayers', function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)

    -- Check job permission
    -- local foundJob = nil
    -- for _, job in ipairs(Config.TablesTrack.TrackingJob) do
    --     foundJob = job
    --     break
    -- end

    -- if not Player or Player.PlayerData.job.type ~= foundJob then TriggerClientEvent('ox_lib:notify', src, { title = locale('cl_error_jobsearch'), description = locale('cl_error_jobsearch_desc') .. foundJob .. locale('cl_error_jobsearch_descB'), type = 'error', duration = 5000 }) return end

    -- Check if player has an active pet
    MySQL.Async.fetchAll("SELECT * FROM player_companions WHERE citizenid = ? AND active = ?",
        { Player.PlayerData.citizenid, true},
        function(result)
            if not result[1] then TriggerClientEvent('ox_lib:notify', src, { title = locale('cl_error_cancompanion'), description = locale('cl_error_cancompanion_des'), type = 'error', duration = 5000 }) return end

            -- Get all online players
            local players = RSGCore.Functions.GetPlayers()
            local playerData = {}
            for _, playerId in ipairs(players) do
                local targetPlayer = RSGCore.Functions.GetPlayer(playerId)
                if targetPlayer then
                    table.insert(playerData, {
                        citizenid = targetPlayer.PlayerData.citizenid,
                        name = targetPlayer.PlayerData.name
                    })
                end
            end

            -- Send the list to the client
            TriggerClientEvent('rsg-companions:client:showOnlinePlayers', src, playerData)
        end)
end)

RegisterServerEvent('rsg-companions:sever:trackPlayerByCitizenID')
AddEventHandler('rsg-companions:server:trackPlayerByCitizenID', function(playerCoords, citizenid)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)

    -- Check job permission
    -- local foundJob = nil
    -- for _, job in ipairs(Config.TablesTrack.TrackingJob) do
    --     foundJob = job
    --     break
    -- end

    -- if not Player or Player.PlayerData.job.type ~= foundJob then TriggerClientEvent('ox_lib:notify', src, { title = locale('cl_error_jobsearch'), description = locale('cl_error_jobsearch_desc') .. foundJob .. locale('cl_error_jobsearch_descB'), type = 'error', duration = 5000 }) return end


    -- Check if player has an active pet
    MySQL.Async.fetchAll("SELECT * FROM player_companions WHERE citizenid = ? AND active = ?",
    {Player.PlayerData.citizenid, true},
        function(result)
            if not result[1] then
                TriggerClientEvent('ox_lib:notify', src, {
                    title = 'No Pet',
                    description = 'You need an active pet to use this feature',
                    type = 'error',
                    duration = 5000
                })
                return
            end

            -- Query the players table for the citizenid
            MySQL.Async.fetchAll("SELECT * FROM players WHERE citizenid = @citizenid",
                {['citizenid'] = citizenid},
                function(results)
                    if not results or #results == 0 then
                        TriggerClientEvent('ox_lib:notify', src, {
                            title = 'Player Not Found',
                            description = 'No player found with CitizenID: ' .. citizenid,
                            type = 'error',
                            duration = 5000
                        })
                        return
                    end

                    local entry = results[1]
                    local coordsData = DetectCoordinates(entry)
                    if not coordsData or type(coordsData) ~= 'table' or not coordsData.x or not coordsData.y or not coordsData.z then
                        local position = entry.position or "nil"
                        local coordsStr = coordsData and string.format("x=%s, y=%s, z=%s", tostring(coordsData.x or "nil"), tostring(coordsData.y or "nil"), tostring(coordsData.z or "nil")) or "nil"
                        TriggerClientEvent('ox_lib:notify', src, {
                            title = 'Invalid Coordinates',
                            description = string.format('No valid coordinates for CitizenID: %s. Position: %s, Parsed: %s', citizenid, tostring(position), coordsStr),
                            type = 'error',
                            duration = 7000
                        })
                        return
                    end

                    -- Ensure coordinates are numeric
                    if type(coordsData.x) ~= "number" or type(coordsData.y) ~= "number" or type(coordsData.z) ~= "number" then
                        TriggerClientEvent('ox_lib:notify', src, {
                            title = 'Invalid Coordinates',
                            description = string.format('Coordinates are not numeric for CitizenID: %s. Parsed: x=%s, y=%s, z=%s', citizenid, tostring(coordsData.x), tostring(coordsData.y), tostring(coordsData.z)),
                            type = 'error',
                            duration = 7000
                        })
                        return
                    end

                    -- Check if target is within maximum tracking range
                    local maxTrackingRange = 2000.0 -- Maximum distance for dog to initiate tracking (in game units)
                    local distance = #(vector3(playerCoords.x, playerCoords.y, playerCoords.z) - vector3(coordsData.x, coordsData.y, coordsData.z))
                    if distance > maxTrackingRange then
                        TriggerClientEvent('ox_lib:notify', src, {
                            title = 'Target Too Far',
                            description = string.format('Player with CitizenID: %s is too far away (%.2f units). Max range: %.2f units.', citizenid, distance, maxTrackingRange),
                            type = 'error',
                            duration = 7000
                        })
                        return
                    end

                    -- Trigger client-side tracking
                    TriggerClientEvent('rsg-companions:client:trackDatabaseEntry', src, coordsData, 'players', entry)
                    TriggerClientEvent('ox_lib:notify', src, {
                        title = 'Pet Tracking',
                        description = 'Your pet is tracking the last known location of CitizenID: ' .. citizenid,
                        type = 'success',
                        duration = 5000
                    })
                end)
        end)
end)

----------------------------------
-- add bone
----------------------------------
RSGCore.Functions.CreateUseableItem(Config.AnimalBone, function(source)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    local success, result = pcall(MySQL.query.await, 'SELECT * FROM player_companions WHERE citizenid=@citizenid AND active=@active', { ['@citizenid'] = Player.PlayerData.citizenid, ['@active'] = 1 })
    if not success or not result or not result[1] then TriggerClientEvent('ox_lib:notify', src, { title = locale('sv_error_no_active'), type = 'error', duration = 5000 }) return end
    TriggerClientEvent('rsg-companions:client:playerbonecompanion', src)
end)

RegisterServerEvent('rsg-companions:server:removeBone', function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.RemoveItem(Config.AnimalBone, 1)
    TriggerClientEvent('rsg-inventory:client:ItemBox', source, RSGCore.Shared.Items[Config.AnimalBone], 'remove', 1)
end)

RegisterServerEvent('rsg-companions:server:addBone', function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.AddItem(Config.AnimalBone, 1)
    TriggerClientEvent('rNotify:ShowAdvancedRightNotification', src, "1 x "..RSGCore.Shared.Items[Config.AnimalBone].label, "generic_textures" , "tick" , "COLOR_PURE_WHITE", 4000)
end)

local function getRandomReward()
    local roll = math.random(1, 100)
    local acc = 0
    for _, reward in ipairs(Config.digrandom.rewards) do
        acc = acc + reward.chance
        if roll <= acc then
            return reward
        end
    end
end

RegisterServerEvent('rsg-companions:server:giveRandomItem', function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    local success, hasActive = pcall(MySQL.scalar.await, [[ SELECT COUNT(*) FROM player_companions WHERE citizenid = ? AND active = 1 ]], { Player.PlayerData.citizenid })
    if not success or hasActive == 0 then
        TriggerClientEvent('ox_lib:notify', src, {  title = locale('sv_error_no_active'), type = 'error', duration = 5000 })
        return
    end
    local reward = getRandomReward()
    if reward and #reward.items > 0 then
        for _, item in ipairs(reward.items) do
            Player.Functions.AddItem(item, 1)
            TriggerClientEvent('rNotify:ShowAdvancedRightNotification', src, "1 x "..RSGCore.Shared.Items[item].label, "generic_textures" , "tick" , "COLOR_PURE_WHITE", 4000)
        end
    end
    local rewardStr = "Ninguna"
    if reward then
        local items = table.concat(reward.items or {}, ", ")
        rewardStr = string.format("Chance: %s | Items: [%s]", reward.chance, items)
    end
    local discordMessage = string.format(
        locale('sv_log_c')..":** %s \n**"
        ..locale('sv_log_d')..":** %d \n**"
        ..locale('sv_log_e')..":** %s %s \n**"
        ..locale('sv_log_j')..":** %s \n**",
        Player.PlayerData.citizenid,
        Player.PlayerData.cid,
        Player.PlayerData.charinfo.firstname,
        Player.PlayerData.charinfo.lastname,
        rewardStr
    )
    TriggerEvent('rsg-log:server:CreateLog', Config.WebhookName, Config.WebhookTitle, Config.WebhookColour, discordMessage, false)
end)

local function getTreasureReward()
    local roll = math.random(1, 100)
    local acc = 0
    for _, reward in ipairs(Config.TreasureHunt.rewards) do
        acc = acc + reward.chance
        if roll <= acc then
            return reward
        end
    end
end

RegisterServerEvent('rsg-companions:server:giveTreasureItem', function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    local rewards = getTreasureReward()
    if rewards and type(rewards.items) == "table" and #rewards.items > 0 then
        local item = rewards.items[math.random(#rewards.items)]
        Player.Functions.AddItem(item, 1)
        TriggerClientEvent('rNotify:ShowAdvancedRightNotification', src, "1 x "..RSGCore.Shared.Items[item].label, "generic_textures" , "tick" , "COLOR_PURE_WHITE", 4000)
    end
    local rewardStr = "Ninguna"
    if rewards then
        local items = table.concat(rewards.items or {}, ", ")
        rewardStr = string.format("Chance: %s | Items: [%s]", rewards.chance, items)
    end
    local discordMessage = string.format(
        locale('sv_log_c')..":** %s \n**"
        ..locale('sv_log_d')..":** %d \n**"
        ..locale('sv_log_e')..":** %s %s \n**"
        ..locale('sv_log_j')..":** %s \n**",
        Player.PlayerData.citizenid,
        Player.PlayerData.cid,
        Player.PlayerData.charinfo.firstname,
        Player.PlayerData.charinfo.lastname,
        rewardStr
    )
    TriggerEvent('rsg-log:server:CreateLog', Config.WebhookName, Config.WebhookTitle, Config.WebhookColour, discordMessage, false)
end)

----------------------------------
-- others & Items
----------------------------------
-- companion stimulant
RSGCore.Functions.CreateUseableItem(Config.AnimalStimulant, function(source, item)
    TriggerClientEvent('rsg-companions:client:playerfeedcompanion', source, item.name)
end)

-- feed companion
RSGCore.Functions.CreateUseableItem(Config.AnimalFood, function(source, item)
    TriggerClientEvent('rsg-companions:client:playerfeedcompanion', source, item.name)
end)

-- drink companion
RSGCore.Functions.CreateUseableItem(Config.AnimalDrink, function(source, item)
    TriggerClientEvent('rsg-companions:client:playerfeedcompanion', source, item.name)
end)

-- feed companion
RSGCore.Functions.CreateUseableItem(Config.AnimalHappy, function(source, item)
    TriggerClientEvent('rsg-companions:client:playerfeedcompanion', source, item.name)
end)

RegisterServerEvent('rsg-companions:server:useitemspet', function(item)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local success, player_companions = pcall(MySQL.query.await, 'SELECT companiondata FROM player_companions WHERE citizenid = ? AND active = ?', {Player.PlayerData.citizenid, 1})
    if not success or not player_companions or #player_companions == 0 then TriggerClientEvent('ox_lib:notify', src, { title = locale('sv_error_no_active'), type = 'error', duration = 5000 }) return end
    local companionData = json.decode(player_companions[1].companiondata)
    if Player.Functions.GetItemByName(item) or item == Config.AnimalBone or item == 'no-item' then
        if item == Config.AnimalDrink then
			Player.Functions.RemoveItem(Config.AnimalDrink, 1)
			TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[Config.AnimalDrink], "remove", 1)
            local thirst = math.min(100, (companionData.thirst or 0) + Config.Increase.Thirst)
            local happiness = math.min(100, (companionData.happiness or 0) + Config.Increase.Happiness)
            local companionxp = (companionData.companionxp or 0) + Config.Increase.XpPerDrink
            -- Incrementar thirst y happiness
            companionData.thirst = thirst
            companionData.happiness = happiness
            companionData.companionxp = companionxp

        elseif item == Config.AnimalFood then
			Player.Functions.RemoveItem(Config.AnimalFood, 1)
			TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[Config.AnimalFood], "remove", 1)
            local hunger = math.min(100, (companionData.hunger or 0) + Config.Increase.Hunger)
            local happiness = math.min(100, (companionData.happiness or 0) + Config.Increase.Happiness)
            local companionxp = (companionData.companionxp or 0) + Config.Increase.XpPerFeed
            -- Incrementar thirst y happiness
            companionData.hunger = hunger
            companionData.happiness = happiness
            companionData.companionxp = companionxp

        elseif item == Config.AnimalHappy then
			Player.Functions.RemoveItem(Config.AnimalHappy, 1)
			TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[Config.AnimalHappy], "remove", 1)
            local thirst = math.min(100, (companionData.thirst or 0) + Config.Increase.Thirst)
            local hunger = math.min(100, (companionData.hunger or 0) + Config.Increase.Hunger)
            local happiness = math.min(100, (companionData.happiness or 0) + Config.Increase.Happiness)
            local companionxp = (companionData.companionxp or 0) + Config.Increase.XpPerDrink
            -- Incrementar thirst y happiness
            companionData.thirst = thirst
            companionData.hunger = hunger
            companionData.happiness = happiness
            companionData.companionxp = companionxp

            if not Config.Skills then
            else
                local random = Config.SkillXP
                TriggerEvent('j-reputations:server:addrep', 'medicine', random) -- adding a reputation
            end
        elseif item == Config.AnimalStimulant then
            Player.Functions.RemoveItem(Config.AnimalStimulant, 1)
			TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[Config.AnimalStimulant], "remove", 1)
            local companionxp = (companionData.companionxp or 0) + Config.Increase.XpPerStimulant
            companionData.companionxp = companionxp

            if not Config.Skills then
            else
                local random = Config.SkillXP
                TriggerEvent('j-reputations:server:addrep', 'medicine', random) -- adding a reputation
            end

        elseif item == 'water' then
			Player.Functions.RemoveItem("water", 1)
			TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items["water"], "remove", 1)
            local thirst = math.min(100, (companionData.thirst or 0) + Config.Increase.Thirst)
            local happiness = math.min(100, (companionData.happiness or 0) + Config.Increase.Happiness)
            local companionxp = (companionData.companionxp or 0) + Config.Increase.XpPerDrink
            -- Incrementar thirst y happiness
            companionData.thirst = thirst
            companionData.happiness = happiness
            companionData.companionxp = companionxp

        elseif item == 'raw_meat' then
			Player.Functions.RemoveItem('raw_meat', 1)
			TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items['raw_meat'], "remove", 1)
            local hunger = math.min(100, (companionData.hunger or 0) + Config.Increase.Hunger)
            local happiness = math.min(100, (companionData.happiness or 0) + Config.Increase.Happiness)
            local companionxp = (companionData.companionxp or 0) + Config.Increase.XpPerFeed
            -- Incrementar thirst y happiness
            companionData.hunger = hunger
            companionData.happiness = happiness
            companionData.companionxp = companionxp

        elseif item == 'sugarcube' then
			Player.Functions.RemoveItem('sugarcube', 1)
			TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items['sugarcube'], "remove", 1)
            local thirst = math.min(100, (companionData.thirst or 0) + Config.Increase.Thirst)
            local hunger = math.min(100, (companionData.hunger or 0) + Config.Increase.Hunger)
            local happiness = math.min(100, (companionData.happiness or 0) + Config.Increase.Happiness)
            local companionxp = (companionData.companionxp or 0) + Config.Increase.XpPerDrink
            -- Incrementar thirst y happiness
            companionData.thirst = thirst
            companionData.hunger = hunger
            companionData.happiness = happiness
            companionData.companionxp = companionxp

            if not Config.Skills then
            else
                local random = Config.SkillXP
                TriggerEvent('j-reputations:server:addrep', 'medicine', random) -- adding a reputation
            end
        elseif item == 'appel' then
            Player.Functions.RemoveItem('appel', 1)
			TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items['appel'], "remove", 1)
            local companionxp = (companionData.companionxp or 0) + Config.Increase.XpPerStimulant
            companionData.companionxp = companionxp

            if not Config.Skills then
            else
                local random = Config.SkillXP
                TriggerEvent('j-reputations:server:addrep', 'medicine', random) -- adding a reputation
            end
        elseif item == Config.AnimalBrush then
            local happiness = math.min(100, (companionData.happiness or 0) + Config.Increase.Happiness)
            local companionxp = (companionData.companionxp or 0) + Config.Increase.XpPerClean
            companionData.happiness = happiness
            companionData.dirt = 0.0
            companionData.companionxp = companionxp
		elseif item == Config.AnimalBone then
            local happiness = math.min(100, (companionData.happiness or 0) + Config.Increase.Happiness)
            local companionxp = (companionData.companionxp or 0) + Config.Increase.XpPerBone
            companionData.happiness = happiness
            companionData.companionxp = companionxp
		elseif item == 'no-item' then
            local companionxp = (companionData.companionxp or 0) + Config.Increase.XpPerMove
            companionData.companionxp = companionxp
		end
        local updatedData = json.encode(companionData)
        local successB, resultB = pcall(MySQL.update, "UPDATE player_companions SET companiondata = ? WHERE citizenid = ? AND active = ?", {updatedData, Player.PlayerData.citizenid, 1})
        if not successB then return end

        if Config.Skills and not item == 'no-item' then
            local random = Config.SkillXP
            TriggerEvent('j-reputations:server:addrep' , 'training', random) -- adding a reputation
        end
    else
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_error_brush')..' '..RSGCore.Shared.Items[tostring(item)].label, type = 'error', duration = 5000 })
    end
end)

RegisterServerEvent('rsg-companions:server:addxp', function(type)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    local success, player_companions = pcall(MySQL.query.await, 'SELECT companiondata FROM player_companions WHERE citizenid = ? AND active = ?', {Player.PlayerData.citizenid, 1})
    if not success or not player_companions or #player_companions == 0 then TriggerClientEvent('ox_lib:notify', src, { title = locale('sv_error_no_active'), type = 'error', duration = 5000 }) return end
    local companionData = json.decode(player_companions[1].companiondata)
    local xpGained = 0
    local happinessGained = 0

    -- Tipos válidos: 'find_buried', 'dig_random', 'treasure'
    if type == "find_buried" then
        xpGained = Config.Increase.XpPerFindBuried
        happinessGained = Config.Increase.Happiness
    elseif type == "dig_random" then
        xpGained = Config.Increase.XpPerDigRandom
        happinessGained = Config.Increase.Happiness
    elseif type == "treasure" then
        xpGained = Config.Increase.XpPerTreasure
        happinessGained = Config.Increase.Happiness
    else
        return -- Tipo desconocido, no hacer nada
    end

    companionData.companionxp = (companionData.companionxp or 0) + xpGained
    companionData.happiness = math.min(100, (companionData.happiness or 0) + happinessGained)
    local updatedData = json.encode(companionData)
    local successB, resultB = pcall(MySQL.update, "UPDATE player_companions SET companiondata = ? WHERE citizenid = ? AND active = ?", { updatedData, Player.PlayerData.citizenid, 1 })
    if not successB then return end

    if Config.Skills then
        local random = Config.SkillXP
        TriggerEvent('j-reputations:server:addrep', 'training', random)
    end
end)

-- companion attributes to database DIRT
RegisterServerEvent('rsg-companions:server:setcompanionAttributes', function(dirt)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    local success, player_companions = pcall(MySQL.query.await, 'SELECT companiondata FROM player_companions WHERE citizenid = ? AND active = ?', {Player.PlayerData.citizenid, 1})
    if not success or not player_companions or #player_companions == 0 then TriggerClientEvent('ox_lib:notify', src, { title = locale('sv_error_no_active'), type = 'error', duration = 5000 }) return end
    local companionData = json.decode(player_companions[1].companiondata)
    companionData.dirt = dirt
    local updatedData = json.encode(companionData)
    local successB, resultB = pcall(MySQL.update, 'UPDATE player_companions SET companiondata = ? WHERE citizenid = ? AND active = ?', {updatedData, Player.PlayerData.citizenid, 1})
    if not successB then return end
end)

RegisterServerEvent('rsg-companions:renameCompanion', function(name)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    local success, player_companions = pcall(MySQL.query.await, 'SELECT companiondata FROM player_companions WHERE citizenid = ? AND active = ?', {Player.PlayerData.citizenid, 1})
    if not success or not player_companions or #player_companions == 0 then TriggerClientEvent('ox_lib:notify', src, { title = locale('sv_error_no_active'), type = 'error', duration = 5000}) return end
    local currentData = json.decode(player_companions[1].companiondata)
    currentData.name = name
    local updatedData = json.encode(currentData)
    local successB, resultB = pcall(MySQL.update, 'UPDATE player_companions SET companiondata = ? WHERE citizenid = ? AND active = ?', {updatedData, Player.PlayerData.citizenid, 1})
    if not successB then TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_error_name_change_failed'), type = 'error', duration = 5000 }) return end
    TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_success_name_change') .. ' \'' .. name .. '\' ' .. locale('sv_successfully'), type = 'success', duration = 5000 })
    local discordMessage = string.format(
        locale('sv_log_c')..":** %s \n**"
        ..locale('sv_log_d')..":** %d \n**"
        ..locale('sv_log_e')..":** %s %s \n**"
        ..locale('sv_success_name_change')..":** %s \n**",
        Player.PlayerData.citizenid,
        Player.PlayerData.cid,
        Player.PlayerData.charinfo.firstname,
        Player.PlayerData.charinfo.lastname,
        name
    )
    TriggerEvent('rsg-log:server:CreateLog', Config.WebhookName, Config.WebhookTitle, Config.WebhookColour, discordMessage, false)
end)

---------------------------------
-- companion inventory
---------------------------------
RegisterNetEvent('rsg-companions:server:opencompanioninventory', function(companionstash, invWeight, invSlots)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    local data = {
        label = locale('sv_companion_inventory'),
        maxweight = invWeight,
        slots = invSlots
    }
    local stashName = companionstash
    exports['rsg-inventory']:OpenInventory(src, stashName, data)
end)

----------------------------------
-- companion check dead system
----------------------------------
-- companion reviver
RSGCore.Functions.CreateUseableItem(Config.AnimalRevive, function(source)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    local success, result = pcall(MySQL.query.await, 'SELECT * FROM player_companions WHERE citizenid = @citizenid AND active = @active', { ['@citizenid'] = Player.PlayerData.citizenid, ['@active'] = 1 })
    if not success then TriggerClientEvent('ox_lib:notify', src, { title = locale('sv_error_db'), type = 'error', duration = 5000 }) return end
    if not result or #result == 0 then TriggerClientEvent('ox_lib:notify', src, { title = locale('sv_error_no_active'), type = 'error', duration = 5000 }) return end
    TriggerClientEvent('rsg-companions:client:revivecompanion', src, result[1])
end)

RSGCore.Commands.Add('petsrevive', 'Revive your companions', {}, false, function(source)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    local success, result = pcall(MySQL.query.await, 'SELECT * FROM player_companions WHERE citizenid = @citizenid AND active = @active', { ['@citizenid'] = Player.PlayerData.citizenid, ['@active'] = 1 })
    if not success then TriggerClientEvent('ox_lib:notify', src, { title = locale('sv_error_db'), type = 'error', duration = 5000 }) return end
    if not result or #result == 0 then TriggerClientEvent('ox_lib:notify', src, { title = locale('sv_error_no_active'), type = 'error', duration = 5000 }) return end
    TriggerClientEvent('rsg-companions:client:revivecompanion', src, result[1])
end)

-- Revive
RegisterServerEvent('rsg-companions:server:revivecompanion', function(item)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.RemoveItem(item, 1)
    TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[item], 'remove', 1)
    local success, result = pcall(MySQL.query.await, 'SELECT * FROM player_companions WHERE citizenid=@citizenid AND active=@active', { ['@citizenid'] = Player.PlayerData.citizenid, ['@active'] = 1 })
    if not success then TriggerClientEvent('ox_lib:notify', src, { title = 'Database error', type = 'error', duration = 5000 }) return end
    if result[1] then
        local updatedData = json.decode(result[1].companiondata)

        updatedData.hunger = 75
        updatedData.thirst = 75
        updatedData.happiness = 75
        updatedData.dirt = 50
        updatedData.dead = false

        local successUpdate, resultB = pcall(MySQL.update, 'UPDATE player_companions SET companiondata = ? WHERE citizenid = ? AND active= ?', {json.encode(updatedData), Player.PlayerData.citizenid, 1})
        if not successUpdate then return end

        if not Config.Skills then
        else
            local random = Config.SkillXP
            TriggerEvent('j-reputations:server:addrep', 'medicine', random) -- adding a reputation
        end

    end
    local discordMessage = string.format(
        locale('sv_log_c')..":** %s \n**"
        ..locale('sv_log_d')..":** %d \n**"
        ..locale('sv_log_e')..":** %s %s \n**"
        ..locale('sv_log_m').."**",
        Player.PlayerData.citizenid,
        Player.PlayerData.cid,
        Player.PlayerData.charinfo.firstname,
        Player.PlayerData.charinfo.lastname
    )
    TriggerEvent('rsg-log:server:CreateLog', Config.WebhookName, Config.WebhookTitle, Config.WebhookColour, discordMessage, false)
end)

RegisterNetEvent('rsg-companions:server:companionDied')
AddEventHandler('rsg-companions:server:companionDied', function() -- healt
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    local success, companionData = pcall(MySQL.query.await, 'SELECT * FROM player_companions WHERE citizenid = ? AND active = ?', {Player.PlayerData.citizenid, 1})
    if not success or not companionData or not companionData[1] then return end
    local updatedData = json.decode(companionData[1].companiondata)
    local companionDataID = companionData[1].companionid

    updatedData.dead = true

    local successC, resultC = pcall(MySQL.update, 'UPDATE player_companions SET companiondata = ? WHERE citizenid = ? and companionid = ?', {json.encode(updatedData), Player.PlayerData.citizenid, companionDataID})
    if not successC then return end
    Wait(1000)

    if updatedData.dead == true then
        updatedData.hunger = 0
        updatedData.thirst = 0
        updatedData.happiness = 0
        updatedData.dirt = 100
    end

    local successB, resultB = pcall(MySQL.update, 'UPDATE player_companions SET companiondata = ? WHERE citizenid = ? and companionid = ?', {json.encode(updatedData), Player.PlayerData.citizenid, companionDataID})
    if not successB then return end
    local discordMessage = string.format(
        locale('sv_log_c')..":** %s \n**"
        ..locale('sv_log_d')..":** %d \n**"
        ..locale('sv_log_e')..":** %s %s \n**"
        ..locale('sv_log_o').."**",
        Player.PlayerData.citizenid,
        Player.PlayerData.cid,
        Player.PlayerData.charinfo.firstname,
        Player.PlayerData.charinfo.lastname
    )
    TriggerEvent('rsg-log:server:CreateLog', Config.WebhookName, Config.WebhookTitle, Config.WebhookColour, discordMessage, false)
end)

----------------------------------
-- companion check system
----------------------------------
local Limit = {
    HungerThresholds = {75, 25},
    DirtThresholds = {50, 75}
}

local function adjustWithinBounds(value, minValue, maxValue)
    return math.min(math.max(value, minValue), maxValue)
end

local function updateHappiness(happiness, hunger, thirst, dirt)
    local hungerPenalty = hunger < Limit.HungerThresholds[1] and 1 or 0
    local thirstPenalty = thirst < Limit.HungerThresholds[1] and 1 or 0
    happiness = happiness - (hungerPenalty + thirstPenalty)

    for _, threshold in ipairs(Limit.DirtThresholds) do
        if dirt > threshold then
            happiness = happiness - 1
        end
    end

    return adjustWithinBounds(happiness, 0, 100)
end

local function updatePetStats(hunger, thirst, happiness, dirt)
    local orig = {hunger, thirst, happiness, dirt}

    -- Disminuimos sed y hambre y verificamos si puede crecer
    thirst = adjustWithinBounds(thirst - 1, 0, 100)
    hunger = adjustWithinBounds(hunger - 1, 0, 100)
    happiness = updateHappiness(happiness, hunger, thirst, dirt)

    -- Disminuir felicidad si uno de los niveles críticos llega a 0
    if hunger == 0 or thirst == 0 then
        happiness = happiness - 1
    end
    if hunger == 0 and thirst == 0 then
        happiness = happiness - 1
    end
    happiness = adjustWithinBounds(happiness, 0, 100)
    dirt = adjustWithinBounds(dirt, 0, 100)
    happiness = math.max(happiness, 0)
    local updated = (hunger ~= orig[1] or thirst ~= orig[2] or happiness ~= orig[3] or dirt ~= orig[4])

    return hunger, thirst, happiness, dirt, updated
end

--[[ lib.cron.new(Config.AnimalCronJob, function()
    local success, result = pcall(MySQL.query.await, 'SELECT * FROM player_companions')
    if not success or not result then
        print('[hdrp-companion] CRON: Could not fetch companions from database.')
        return
    end

    for i = 1, #result do
        local id = result[i].id
        local ownercid = result[i].citizenid
        local companionData = json.decode(result[i].companiondata)

        if not companionData or type(companionData.hunger) ~= "number" then
            print('[hdrp-companion] CRON WARN: Skipping companion with invalid data. ID: ' .. tostring(id))
            goto continue_loop -- Salta a la siguiente iteración
        end

        -- >> CORRECCIÓN PRINCIPAL: El nombre se obtiene del JSON decodificado
        local companionname = companionData.name
        local id_comp = companionData.id
        local companiontype = companionData.companion
        local bornTime = companionData.born

        if not companionname then companionname = "Sin Nombre" end
        if not id_comp then id_comp = "ID Desconocido" end

        local days = math.floor((os.time() - (bornTime or os.time())) / (24 * 60 * 60))
        if days > Config.CompanionDieAge or (companiontype == 'a_c_dogrufus_01' and days >= Config.StarterCompanionDieAge) then
            local deleteSuccess, _ = pcall(MySQL.update.await, 'DELETE FROM player_companions WHERE id = ?', { id })

            if deleteSuccess then
                TriggerEvent('rsg-companions:server:updateanimals')

                local discordMessage = string.format(
                    locale('sv_log_c') .. ":** %s \n**" ..
                    locale('sv_log_p') .. ':** %s \n**' ..
                    locale('sv_log_companion_belong') .. ":** %s \n**" ..
                    locale('sv_log_companion_dead') .. "**",
                    ownercid, id_comp, companionname
                )
                TriggerEvent('rsg-log:server:CreateLog', Config.WebhookName, Config.WebhookTitle, Config.WebhookColour, discordMessage, false)

                pcall(MySQL.insert.await, 'INSERT INTO telegrams (citizenid, recipient, sender, sendername, subject, sentDate, message) VALUES (?, ?, ?, ?, ?, ?, ?)', {
                    ownercid, locale('sv_telegram_owner'), '22222222', locale('sv_telegram_stables'),
                    companionname .. ' ' .. locale('sv_telegram_away'), os.date('%x'),
                    locale('sv_telegram_inform') .. ' ' .. companionname .. ' ' .. locale('sv_telegram_has_passed'),
                })
            end

            goto continue_loop -- >> CORRECCIÓN LÓGICA: Continúa con el siguiente animal
        end

        local updateNeeded = false
        if companionData.age < days then
            companionData.age = companionData.age + 1
            updateNeeded = true
        end

        companionData.scale = math.min(1.0, 0.5 + 0.1 * companionData.age)

        if result[i].active then
            local hunger, thirst, happiness, dirt, petStatsChanged = updatePetStats(companionData.hunger, companionData.thirst, companionData.happiness, companionData.dirt)
            if petStatsChanged then
                companionData.hunger, companionData.thirst, companionData.happiness, companionData.dirt = hunger, thirst, happiness, dirt
                updateNeeded = true
            end
        end

        if updateNeeded then
            local updatedData = json.encode(companionData)
            local updateSuccess, _ = pcall(MySQL.update.await, 'UPDATE player_companions SET companiondata = ? WHERE id = ?', { updatedData, id })
            if updateSuccess then
                TriggerEvent('rsg-companions:server:updateanimals')
            end
        end

        ::continue_loop::
    end

    if Config.EnableServerNotify then
        print(locale('sv_print'))
    end
end) ]]
lib.cron.new(Config.AnimalCronJob, function()
    local success, result = pcall(MySQL.query.await, 'SELECT * FROM player_companions')
    if not success or not result then
        print('[hdrp-companion] CRON: Could not fetch companions from database.')
        return
    end

    for i = 1, #result do
        local id = result[i].id
        local ownercid = result[i].citizenid
        local companionData = json.decode(result[i].companiondata)

        if not companionData or type(companionData.hunger) ~= "number" then
            print('[hdrp-companion] CRON WARN: Skipping companion with invalid data. ID: ' .. tostring(id))
            goto continue_loop -- Salta a la siguiente iteración
        end

        local companionname = companionData.name or "Unnamed"
        local id_comp = companionData.id or "Unknown ID"
        local companiontype = companionData.companion
        local bornTime = companionData.born or os.time()

        local days = math.floor((os.time() - bornTime) / (24 * 60 * 60))
        if days > Config.CompanionDieAge or (companiontype == 'a_c_dogrufus_01' and days >= Config.StarterCompanionDieAge) then
            local deleteSuccess, _ = pcall(MySQL.update.await, 'DELETE FROM player_companions WHERE id = ?', { id })

            if deleteSuccess then
                TriggerEvent('rsg-companions:server:updateanimals')

                -- >> SOLUCIÓN: Usar textos por defecto si la traducción no existe
                local log_c = locale('sv_log_c') or "CitizenID"
                local log_p = locale('sv_log_p') or "Companion ID"
                local log_belong = locale('sv_log_companion_belong') or "Companion Name"
                local log_dead = locale('sv_log_companion_dead') or "has died of old age."

                local discordMessage = string.format(
                    "%s:** %s \n**%s:** %s \n**%s:** %s \n**%s",
                    log_c, ownercid, log_p, id_comp, log_belong, companionname, log_dead
                )
                TriggerEvent('rsg-log:server:CreateLog', Config.WebhookName, Config.WebhookTitle, Config.WebhookColour, discordMessage, false)

                -- >> SOLUCIÓN: Usar textos por defecto para el telegrama también
                local telegram_owner = locale('sv_telegram_owner') or "Estate"
                local telegram_stables = locale('sv_telegram_stables') or "Stables"
                local telegram_away = locale('sv_telegram_away') or "has passed away"
                local telegram_inform = locale('sv_telegram_inform') or "We regret to inform you that"
                local telegram_passed = locale('sv_telegram_has_passed') or "is no longer with us due to old age."

                pcall(MySQL.insert.await, 'INSERT INTO telegrams (citizenid, recipient, sender, sendername, subject, sentDate, message) VALUES (?, ?, ?, ?, ?, ?, ?)', {
                    ownercid,
                    telegram_owner,
                    '22222222',
                    telegram_stables,
                    companionname .. ' ' .. telegram_away,
                    os.date('%x'),
                    telegram_inform .. ' ' .. companionname .. ' ' .. telegram_passed,
                })
            end

            goto continue_loop
        end

        local updateNeeded = false
        if companionData.age < days then
            companionData.age = (companionData.age or 0) + 1
            updateNeeded = true
        end

        companionData.scale = math.min(1.0, 0.5 + 0.1 * (companionData.age or 1))

        if result[i].active then
            local hunger, thirst, happiness, dirt, petStatsChanged = updatePetStats(companionData.hunger, companionData.thirst, companionData.happiness, companionData.dirt)
            if petStatsChanged then
                companionData.hunger, companionData.thirst, companionData.happiness, companionData.dirt = hunger, thirst, happiness, dirt
                updateNeeded = true
            end
        end

        if updateNeeded then
            local updatedData = json.encode(companionData)
            local updateSuccess, _ = pcall(MySQL.update.await, 'UPDATE player_companions SET companiondata = ? WHERE id = ?', { updatedData, id })
            if updateSuccess then
                TriggerEvent('rsg-companions:server:updateanimals')
            end
        end

        ::continue_loop::
    end

    if Config.EnableServerNotify then
        print(locale('sv_print') or "[Companions] Cron job executed.")
    end
end)
--------------------------------------
-- register shop
--------------------------------------
CreateThread(function()
    exports['rsg-inventory']:CreateShop({
        name = 'companion',
        label = locale('cl_companion_shop'),
        slots = #Config.companionsShopItems,
        items = Config.companionsShopItems,
        persistentStock = Config.PersistStock,
    })
end)

--------------------------------------
-- open shop
--------------------------------------
RegisterNetEvent('rsg-companions:server:openShop', function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    exports['rsg-inventory']:OpenShop(src, 'companion')
end)

-----------------------------------
-- Companion Customization
----------------------------------
--[[ RSGCore.Commands.Add('loadpet', locale('sv_command_load'), {}, false, function(source, args)
end)

local activeAttachments = {}
RegisterNetEvent('rsg-companions:server:AttachItem')
AddEventHandler('rsg-companions:server:AttachItem', function(netId, itemHashes)
    for _, hash in ipairs(itemHashes) do
        TriggerClientEvent('rsg-companions:client:UpdateAttachment', -1, netId, hash, source)
    end
end)

RegisterServerEvent('rsg-companions:server:RequestAttachments')
AddEventHandler('rsg-companions:server:RequestAttachments', function()
    local src = source
    for netId, data in pairs(activeAttachments) do
        if netId then
            TriggerClientEvent('rsg-companions:client:UpdateAttachment', src, netId, data.hash, data.source)
        else
            activeAttachments[netId] = nil
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    activeAttachments = {}
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    for netId, data in pairs(activeAttachments) do
        if data.source == src then
            activeAttachments[netId] = nil
            TriggerClientEvent('rsg-companions::client:RemoveAttachment', -1, netId, data.hash)
        end
    end
end) 

---
RegisterServerEvent('rsg-companions:server:SetPlayerBucket', function(random, ped)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    if random then
        local BucketID = RSGCore.Shared.RandomInt(1000, 9999)
        SetRoutingBucketPopulationEnabled(BucketID, false)
        SetPlayerRoutingBucket(src, BucketID)
        SetPlayerRoutingBucket(ped, BucketID)
    else
        SetPlayerRoutingBucket(src, 0)
        SetPlayerRoutingBucket(ped, 0)
    end
end)

-- get active companion components callback
RSGCore.Functions.CreateCallback('rsg-companions:server:CheckComponents', function(source, cb)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    local Playercid = Player.PlayerData.citizenid
    local success, result = pcall(MySQL.query.await, 'SELECT * FROM player_companions WHERE citizenid=@citizenid AND active=@active', { ['@citizenid'] = Playercid, ['@active'] = 1})
    if not success then cb(nil) return end
    if result and result[1] then
        cb(result[1])
    else
        cb(nil)
    end
end)

-- save saddle
RegisterNetEvent('rsg-companions:server:SaveComponent', function(component, companiondata, price)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    local companionid = companiondata.companionid
    if (Player.PlayerData.money.cash < price) then TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_error_no_cash'), type = 'error', duration = 5000 }) return end
    if component then
        local success, result = pcall(MySQL.update, 'UPDATE player_companions SET components = ? WHERE citizenid = ? AND companionid = ?', {json.encode(component), citizenid, companionid})
        if not success then return end
        Player.Functions.RemoveMoney('cash', price)
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_success_component_saved') .. price, type = 'success', duration = 5000 })
    end
end)
]]