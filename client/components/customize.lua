
-------------------
-- Custom AND MENU
-------------------

-------------------
-- start varialbes custom
-- local ComponentsProps = lib.load('client.components.companion_props')
-- local Components = lib.load('client.components.companion_comp')

-- local entities = {} -- custom npc
-- local companionComps = {}
-- local initialCompanionComps = {}
-- local attachedItems = {}
-- local hashToConfig = {}
-- local Customize = false
-- local CurrentPrice = 0

-- local RotatePrompt
-- local CustomizePrompt = GetRandomIntInRange(0, 0xffffff) --[[]]
-- Export for active companionPed

-- exports('CheckCompanionCustomize', function()
--    return Customize
-- end)

------------------------------------
-- custshop load table compoments
------------------------------------
-- local function getComponentHash(category, index)
--     if ComponentsProps[category] then    -- Comprobamos si la categoría existe en ComponentsProps
--         local item = ComponentsProps[category][index]
--         if item then
--             return item.hashid  -- Retorna el hashid del objeto encontrado
--         end
--     end
--     return nil  -- Si no se encuentra el componente, se retorna nil
-- end

-- start custom
-- local DisableCamera = function()
--     RenderScriptCams(false, true, 1000, 1, 0)
--     DestroyCam(Camera, false)
--     DestroyAllCams(true)
--     DisplayHud(true)
--     DisplayRadar(true)
--     Citizen.InvokeNative(0x4D51E59243281D80, PlayerId(), true, 0, false) -- ENABLE PLAYER CONTROLS
--     Customize = false
--     for k, v in pairs(entities) do

--         TriggerServerEvent('rsg-companions:server:SetPlayerBucket', false, v.compped)

--         if v.compped and DoesEntityExist(v.compped) then
--             DeleteEntity(v.compped)
--         end
--         entities[k] = nil
--     end
-- end

-- rotate custom
-- local function PromptCustom()
--     local str8 = locale('cl_custom_rotate_companion')
--     str8 = VarString(10, 'LITERAL_STRING', str8)
--     RotatePrompt = PromptRegisterBegin()
--     PromptSetControlAction(RotatePrompt, Config.Prompt.CompanionRotate[1])
--     PromptSetControlAction(RotatePrompt, Config.Prompt.CompanionRotate[2])
--     PromptSetText(RotatePrompt, str8)
--     PromptSetEnabled(RotatePrompt, true)
--     PromptSetVisible(RotatePrompt, true)
--     PromptSetStandardMode(RotatePrompt, 1)
--     PromptSetGroup(RotatePrompt, CustomizePrompt)
--     PromptRegisterEnd(RotatePrompt)
-- end

-- local function CameraPromptCompanion(entity)
--     local promptLabel = locale('cl_custom_price') .. ': $'
--     local lightRange, lightIntensity = 15.0, 50.0
--     local rotateLeft, rotateRight = Config.Prompt.CompanionRotate[1], Config.Prompt.CompanionRotate[2]

--     CreateThread(function()
--         if not Config.CustomCompanion then return end
--         PromptCustom()
--         while Customize do

--             Wait(1)
--             local crds = GetEntityCoords(entity)
--             DrawLightWithRange(crds.x - 5.0, crds.y - 5.0, crds.z + 1.00, 255, 255, 255, lightRange, lightIntensity)

--             local label = VarString(10, 'LITERAL_STRING', promptLabel .. CurrentPrice)
--             PromptSetActiveGroupThisFrame(CustomizePrompt, label)

--             local heading = GetEntityHeading(entity)
--             if IsControlPressed(2, rotateLeft) then
--                 SetEntityHeading(entity, heading - 1)
--             elseif IsControlPressed(2, rotateRight) then
--                 SetEntityHeading(entity, heading + 1)
--             end
--         end
--         Wait(100)
--     end)
-- end

-- local function createCamera(entity, companionsdata)
--     local Coords
--     local adjust_z
--     if Config.Camera.Dog == true then
--         Coords = GetOffsetFromEntityInWorldCoords(entity, 0, Config.Camera.DistY, 0)
--         adjust_z = tonumber(Config.Camera.DistZ)
--     else
--         Coords = GetOffsetFromEntityInWorldCoords(entity, 0, 3.5, 0)
--         adjust_z = 1.5
--     end

--     RenderScriptCams(false, false, 0, 1, 0)
--     DestroyCam(Camera, false)
--     if not DoesCamExist(Camera) then
--         Camera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
--         SetCamActive(Camera, true)
--         RenderScriptCams(true, false, 3000, true, true)
--         SetCamCoord(Camera, Coords.x, Coords.y, Coords.z + adjust_z)
--         SetCamRot(Camera, -15.0, 0.0, GetEntityHeading(entity) + 180)
--         Customize = true
--         CameraPromptCompanion(entity)
--         MainMenu(entity, companionsdata)
--         Citizen.InvokeNative(0x4D51E59243281D80, PlayerId(), false, 0, true) -- DISABLE PLAYER CONTROLS
--         DisplayHud(false)
--         DisplayRadar(false)
--     end
-- end

-- -- attachements
-- local function ClearAttachedItems()
--     for _, entry in pairs(attachedItems) do
--         if DoesEntityExist(entry.object) then
--             DeleteEntity(entry.object)
--         end
--         attachedItems[entry] = nil
--     end
--     attachedItems = {}
-- end

-- local function InitializeLookupTables()
--     for categoryName, categoryItems in pairs(ComponentsProps) do
--         for _, item in ipairs(categoryItems) do
--             if item then
--                 hashToConfig[item.hashid] = {
--                     hashid = item.hashid,
--                     category = item.category,
--                     model = item.model,
--                     bone = item.bone,
--                     offset = item.offset,
--                     alwaysAttached = item.alwaysAttached
--                 }
--             end
--         end
--     end
-- end

-- function AttachObjectToPet(entity, data)
--     if not entity and not DoesEntityExist(entity) then
--         print(locale('cl_print_error_custom'))
--         return
--     end

--     for _, entry in pairs(attachedItems) do
--         if entry.hashid == data.hashid then
--             -- Si el accesorio ya está adjunto, lo ignoramos
--             return
--         end
--     end

--     local config = hashToConfig[data.hashid] or {}
--     if not config.model then
--         print(locale('cl_print_error_custom_model'), data.hashid, config.model)
--         return
--     end

--     local modelHash = GetHashKey(data.model)
--     RequestModel(modelHash)
--     while not HasModelLoaded(modelHash) do
--         Wait(10)
--     end

--     local coords = GetEntityCoords(entity) -- GetPedBoneIndex(entity, 21030)
--     local boneIndex =  GetEntityBoneIndexByName(entity, data.bone)
--     -- if boneIndex == -1 then
--     --     print(locale('cl_print_error_custom_bone'))
--     --     return
--     -- end
--     local object = CreateObject(modelHash, coords.x, coords.y, coords.z, true, true, false)
--     AttachEntityToEntity(
--         object,
--         entity,
--         boneIndex,
--         data.offset.x, data.offset.y, data.offset.z,
--         data.offset.pitch, data.offset.roll, data.offset.yaw,
--         true, true, false, true, 1, true
--     )

--     -- Agregar a la lista de objetos adjuntos
--     table.insert(attachedItems, {object = object})
--     SetModelAsNoLongerNeeded(modelHash)
-- end

-- local function AttachConfiguredItemsToPet(entity, itemHashes)
--     ClearAttachedItems()
--     for _, hash in ipairs(itemHashes) do
--         -- Obtén la configuración utilizando el hash
--         local config = hashToConfig[hash]
--         -- Verificamos si la configuración existe
--         if config then
--             AttachObjectToPet(entity, config)  -- Adjuntamos el objeto usando la configuración
--         else
--             print(locale('cl_print_error_custom_config'), hash)  -- Si no existe, mostramos un error
--         end
--     end
-- end

-- local function AttachAlwaysAttachedItems(entity)
--     for hash, config in pairs(hashToConfig) do
--         -- Si el componente tiene alwaysAttached en true, lo adjuntamos
--         if config.alwaysAttached then
--             AttachObjectToPet(entity, config)
--         end
--     end
-- end

-- RegisterNetEvent('rsg-companions:client:UpdateAttachment')
-- AddEventHandler('rsg-companions:client:UpdateAttachment', function(netId, hash, sourcePlayer)
--     -- Only process if it's meant for another player
--     if sourcePlayer ~= GetPlayerIdentifier() then
--         if NetworkDoesNetworkIdExist(netId) then
--             local entity = NetworkGetEntityFromNetworkId(netId)
--             if entity and DoesEntityExist(entity) then
--                 local config = hashToConfig[hash]
--                 if config then
--                     if attachedItems[hash] then
--                         DeleteObject(attachedItems[hash])
--                         attachedItems[hash] = nil
--                     else
--                         -- Si no está adjunto, lo adjuntamos
--                         AttachObjectToPet(entity, config)
--                         attachedItems[hash] = entity
--                     end
--                 end
--             end
--         end
--     end
-- end)

-- RegisterNetEvent('rsg-companions:client:RemoveAttachment')
-- AddEventHandler('rsg-companions:client:RemoveAttachment', function(netId, hash)
--     if NetworkDoesNetworkIdExist(netId) then
--         local entity = NetworkGetEntityFromNetworkId(netId)
--         if DoesEntityExist(entity) then
--             DeleteObject(entity)
--             if attachedItems[hash] == entity then
--                 attachedItems[hash] = nil
--             end
--         end
--     end
-- end)

-- CreateThread(function()
--     if GetCurrentResourceName() ~= 'hdrp-companion' then
--         return
--     end

--     InitializeLookupTables()
--     if Config.Debug then print(locale('cl_load_custom_config')) end
--     if companionPed and DoesEntityExist(companionPed) then    -- Prueba: Adjuntar un objeto
--         local itemHashes = {}
--         for _, categoryItems in pairs(ComponentsProps) do
--             for _, item in ipairs(categoryItems) do
--                 table.insert(itemHashes, item.hashid)
--             end
--         end
--         TriggerServerEvent('rsg-companions:server:AttachItem', companionPed, itemHashes)

--         AttachConfiguredItemsToPet(companionPed, itemHashes)
--         AttachAlwaysAttachedItems(companionPed)
--     end
-- end)

-- custom pet event
-- RegisterNetEvent('rsg-companions:client:custShop', function(data)
--     local companionsdata = data.player
--     local AnimalData = json.decode(companionsdata.companiondata)
--     local comp_ped = AnimalData.companion
--     for k, v in pairs(Config.StableSettings) do
--         if companionsdata.stable == v.stableid then
--             DoScreenFadeOut(0)
--             repeat Wait(0) until IsScreenFadedOut()
--             local coords = vector3(v.companioncustom.x, v.companioncustom.y, v.companioncustom.x)
--             local heading = v.companioncustom.w
--             local compped = SpawnCompanions(comp_ped, coords, heading)
--             TriggerServerEvent('rsg-companions:server:SetPlayerBucket', true, compped)
--             createCamera(compped, companionsdata)
--             DoScreenFadeIn(1000)
--             repeat Wait(0) until IsScreenFadedIn()
--             entities[k] = { compped = compped }
--         end
--     end
-- end)

-- MenuData = {}
-- TriggerEvent('rsg-menubase:getData', function(call)
--     MenuData = call
-- end)

-- local function CalculatePrice(comp, initial)
--     local price = 0
--     for category, value in pairs(comp) do
--         if Config.PriceComponent[category] and value > 0 and (not initial or initial[category] ~= value) then
--             price = price + Config.PriceComponent[category]
--         end
--     end
--     return price
-- end

-- local function CustomCompanion(companions, datas)
--     MenuData.CloseAll()
--     CurrentPrice = 0
--     local companionid = datas.companionid
--     local elements = {}    -- Crear elementos para el menú

--     for category, categoryItems in pairs(ComponentsProps) do    -- Iterar sobre los componentes configurados en ComponentsProps (por ejemplo, accesorios)
--         local categoryHashes = {}
--         for i, item in ipairs(categoryItems) do
--             categoryHashes[i] = item.hashid  -- Usar hashid de ComponentsProps
--         end

--         elements[#elements + 1] = {
--             label = category,  -- Mostrar la categoría de accesorios (toys, etc.)
--             value = companionComps[companionid][category] or 0,
--             type = 'slider',
--             min = 0,
--             max = #categoryItems,
--             category = category,
--             hashes = categoryHashes,
--         }
--     end

--     -- Abre el menú con los elementos generados
--     MenuData.Open('default', GetCurrentResourceName(), 'companion_menu', {
--         title    = locale('cl_menu_companion_customization'),
--         subtext  = '',
--         align    = 'top-left',
--         elements = elements,
--     }, function(data, _)
--         -- Lógica para manejar la selección del usuario
--         if companionComps[companionid][data.current.category] ~= data.current.value then

--             -- companionComps[companionid][selectedCategory] = selectedValue
--             local currentHash = data.current.hashes[data.current.value]
--             if data.current.value > 0 then
--                 local config = hashToConfig[currentHash]
--                 if config then
--                     -- Adjuntar el objeto al pet
--                     AttachObjectToPet(companions, config)
--                     -- Añadir el objeto a la lista de items adjuntos
--                     table.insert(attachedItems, { hashid = currentHash, category = data.current.category, ped = companionid })
--                     UpdatePedVariation(companions)
--                 end
--             else
--                 for index, attachedItem in pairs(attachedItems) do
--                     if attachedItem.hashid == currentHash then
--                         -- Eliminar el objeto adjunto si existe
--                         local config = hashToConfig[currentHash]
--                         if config then
--                             DeleteObject(currentHash)
--                             if DoesEntityExist(attachedItem.object) then
--                                 DeleteEntity(attachedItem.object)
--                             end
--                         end
--                         -- Eliminar de la lista de items adjuntos
--                         table.remove(attachedItems, index)
--                         UpdatePedVariation(companions)
--                         break
--                     end
--                 end
--             end

--             -- Calcular el precio basado en los cambios
--             local newPrice = CalculatePrice(companionComps[companionid], initialCompanionComps)
--             if CurrentPrice ~= newPrice then
--                 CurrentPrice = newPrice
--             end

--             companionComps[companionid][data.current.category] = data.current.value
--         end
--     end, function(_, menu)
--         -- Cerrar el menú y regresar al menú principal
--         MainMenu(companions, datas)
--     end)
-- end

-- function MainMenu(companions, companiondata)
--     MenuData.CloseAll()

--     local companionid = companiondata.companionid

--     if not companionComps[companionid] then
--         companionComps[companionid] = {}
--         if companiondata.components and companiondata.components ~= "" then
--             local success, result = pcall(json.decode, companiondata.components)
--             if success then
--                 companionComps[companionid] = result
--             else
--                 print(locale('cl_print_error_custom_decode') .. result)
--             end
--         end
--     end

--     initialCompanionComps = table.copy(companionComps[companionid])  -- Crear una copia de seguridad para la comparación posterior

--     -- Aplicar componentes al ped (mascota)
--     for category, value in pairs(companionComps[companionid]) do
--         local hash = getComponentHash(category, value)
--         if hash ~= 0 then
--             local config = hashToConfig[hash]
--             if config then
--                 AttachObjectToPet(companions, config)  -- Pasamos la entidad y la configuración del componente
--             else
--                 print(locale('cl_print_error_custom_aply'), category, value, hash)
--             end
--         end
--     end

--     local elements = {
--         { label = locale('cl_menu_custom_component'), value = 'component' },
--         { label = locale('cl_menu_custom_buy'), value = 'buy' },
--     }

--     -- Abrir el menú principal
--     MenuData.Open('default', GetCurrentResourceName(), 'main_character_creator_menu', {
--         title = locale('cl_menu_companion_customization'),
--         subtext  = '',
--         align    = 'top-left',
--         elements = elements,
--         itemHeight = "4vh"
--     }, function(data, menu)
--         if data.current.value == 'component' then
--             CustomCompanion(companions, companiondata)  -- Llamar a la función de personalización de mascota
--         elseif data.current.value == 'buy' then
--             -- Guardar componentes seleccionados y el precio
--             TriggerServerEvent('rsg-companions:server:SaveComponent', companionComps[companiondata.companionid], companiondata, CurrentPrice)
--             DisableCamera()
--             CurrentPrice = 0  -- Resetear el precio
--             initialCompanionComps = {}  -- Limpiar los valores iniciales de componentes
--             menu.close()
--         end
--     end, function(_, menu)
--         DisableCamera()
--         CurrentPrice = 0  -- Resetear el precio
--         initialCompanionComps = {}  -- Limpiar los valores iniciales de componentes
--         menu.close()
--     end)
-- end

-- Helper function to create a deep copy of a table
-- function table.copy(t)
--     local u = {}
--     for k, v in pairs(t) do
--         u[k] = type(v) == "table" and table.copy(v) or v
--     end
--     return setmetatable(u, getmetatable(t))
-- end

-- end custom

--------------------------------------------
-- STOP RESOURCE
--------------------------------------------
-- AddEventHandler('onResourceStop', function(resource)
--     if GetCurrentResourceName() ~= resource then return end

    -- DestroyAllCams(true)
    -- DisableCamera()
    -- MenuData.CloseAll()
    -- for index, attachedItem in pairs(attachedItems) do
    --     if attachedItem.category then
    --         if attachedItem.object and DoesEntityExist(attachedItem.object) then
    --             DeleteEntity(attachedItem.object)
    --         end
    --         attachedItems[index] = nil
    --     end
    -- end
    -- attachedItems = {}

    -- exports.ox_target:removeGlobalPed('attack_entity')
    -- stop custom
    --[[
        for k, v in pairs(entities) do -- companion in custom
            if v.compped and DoesEntityExist(v.compped) then
                DeleteEntity(v.compped)
            end
            entities[k] = nil
        end 
    ]]
-- end)