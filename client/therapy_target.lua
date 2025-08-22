-- ================================
-- COMPANION THERAPY SYSTEM
-- Handles stress relief and therapeutic interactions with companions
-- ================================

local STRESS_RELIEF_AMOUNT = 25 -- 100
local PET_DISTANCE = 2.0

local function SetPetAttributes(entity)
    Citizen.InvokeNative(0x09A59688C26D88DF, entity, 0, 1100)
    Citizen.InvokeNative(0x09A59688C26D88DF, entity, 1, 1100)
    Citizen.InvokeNative(0x09A59688C26D88DF, entity, 2, 1100)
    Citizen.InvokeNative(0x75415EE0CB583760, entity, 0, 1100)
    Citizen.InvokeNative(0x75415EE0CB583760, entity, 1, 1100)
    Citizen.InvokeNative(0x5DA12E025D47D4E5, entity, 0, 10)
    Citizen.InvokeNative(0x5DA12E025D47D4E5, entity, 1, 10)
    Citizen.InvokeNative(0x5DA12E025D47D4E5, entity, 2, 10)
    Citizen.InvokeNative(0x920F9488BD115EFB, entity, 0, 10)
    Citizen.InvokeNative(0x920F9488BD115EFB, entity, 1, 10)
    Citizen.InvokeNative(0x920F9488BD115EFB, entity, 2, 10)
    Citizen.InvokeNative(0xF6A7C08DF2E28B28, entity, 0, 5000.0, false)
    Citizen.InvokeNative(0xF6A7C08DF2E28B28, entity, 1, 5000.0, false)
    Citizen.InvokeNative(0xF6A7C08DF2E28B28, entity, 2, 5000.0, false)
end

local function AnimationPet(entity, dict, name)
    local waiting = 0
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        waiting = waiting + 100
        Wait(100)
        if waiting > 5000 then
            lib.notify({ title = 'Error', description = 'Failed to load pet animation.', type = 'error', duration = 7000 })
            break
        end
    end
    TaskPlayAnim(entity, dict, name, 1.0, 1.0, -1, 1, 0, false, false, false)
end

local function StopAnimation(entity, animdict, animdictname)
    TaskPlayAnim(entity, animdict, animdictname, 1.0, 1.0, -1, 0, 1.0, false, false, false)
    FreezeEntityPosition(entity, false)
end

CreateThread(function()
    local animalModels = {
        -- Dog models
        GetHashKey("A_C_DogAmericanFoxhound_01"),
        GetHashKey("A_C_DogAustralianShepherd_01"),
        GetHashKey("A_C_DogBluetickCoonhound_01"),
        GetHashKey("A_C_DogCatahoulaCur_01"),
        GetHashKey("A_C_DogChesBayRetriever_01"),
        GetHashKey("A_C_DogHound_01"),
        GetHashKey("A_C_DogLab_01"),
        GetHashKey("A_C_DogRufus_01"),
        GetHashKey("A_C_DogStreet_01"),
        -- Horse models
        GetHashKey("A_C_Horse_AmericanPaint_Overo"),
        GetHashKey("A_C_Horse_AmericanPaint_Tobiano"),
        GetHashKey("A_C_Horse_AmericanPaint_SplashedWhite"),
        GetHashKey("A_C_Horse_AmericanPaint_Greyovero"),
        GetHashKey("A_C_Horse_AmericanStandardbred_Black"),
        GetHashKey("A_C_Horse_AmericanStandardbred_Buckskin"),
        GetHashKey("A_C_Horse_AmericanStandardbred_PalominoDapple"),
        GetHashKey("A_C_Horse_AmericanStandardbred_SilverTailBuckskin"),
        GetHashKey("A_C_Horse_Andalusian_DarkBay"),
        GetHashKey("A_C_Horse_Andalusian_RoseGray"),
        GetHashKey("A_C_Horse_Andalusian_Perlino"),
        GetHashKey("A_C_Horse_Appaloosa_Blanket"),
        GetHashKey("A_C_Horse_Appaloosa_Leopard"),
        GetHashKey("A_C_Horse_Appaloosa_FewSpot"),
        GetHashKey("A_C_Horse_Appaloosa_LeopardSpotted"),
        GetHashKey("A_C_Horse_Arabian_Black"),
        GetHashKey("A_C_Horse_Arabian_RoseGrayBay"),
        GetHashKey("A_C_Horse_Arabian_WarpedBrindle"),
        GetHashKey("A_C_Horse_Arabian_White"),
        GetHashKey("A_C_Horse_Arabian_RedChestnut"),
        GetHashKey("A_C_Horse_Arabian_Grey"),
        GetHashKey("A_C_Horse_Ardennes_BayRoan"),
        GetHashKey("A_C_Horse_Ardennes_StrawberryRoan"),
        GetHashKey("A_C_Horse_Ardennes_IronGreyRoan"),
        GetHashKey("A_C_Horse_Belgian_BlondChestnut"),
        GetHashKey("A_C_Horse_Belgian_MealyChestnut"),
        GetHashKey("A_C_Horse_DutchWarmblood_ChocolateRoan"),
        GetHashKey("A_C_Horse_DutchWarmblood_SealBrown"),
        GetHashKey("A_C_Horse_DutchWarmblood_SootyBuckskin"),
        GetHashKey("A_C_Horse_HungarianHalfbred_FlaxenChestnut"),
        GetHashKey("A_C_Horse_HungarianHalfbred_PiebaldTobiano"),
        GetHashKey("A_C_Horse_HungarianHalfbred_DarkDappleGrey"),
        GetHashKey("A_C_Horse_KentuckySaddle_Black"),
        GetHashKey("A_C_Horse_KentuckySaddle_ChestnutPinto"),
        GetHashKey("A_C_Horse_KentuckySaddle_SilverBay"),
        GetHashKey("A_C_Horse_KentuckySaddle_ButterMilkBuckskin"),
        GetHashKey("A_C_Horse_MissouriFoxTrotter_AmberChampagne"),
        GetHashKey("A_C_Horse_MissouriFoxTrotter_SilverDapplePinto"),
        GetHashKey("A_C_Horse_Morgan_Bay"),
        GetHashKey("A_C_Horse_Morgan_BayRoan"),
        GetHashKey("A_C_Horse_Morgan_FlaxenChestnut"),
        GetHashKey("A_C_Horse_Morgan_LiverChestnut"),
        GetHashKey("A_C_Horse_Morgan_Palomino"),
        GetHashKey("A_C_Horse_Mustang_GrulloDun"),
        GetHashKey("A_C_Horse_Mustang_WildBay"),
        GetHashKey("A_C_Horse_Mustang_TigerStripedBay"),
        GetHashKey("A_C_Horse_Nokota_BlueRoan"),
        GetHashKey("A_C_Horse_Nokota_WhiteRoan"),
        GetHashKey("A_C_Horse_Nokota_ReverseDappleRoan"),
        GetHashKey("A_C_Horse_Shire_DarkBay"),
        GetHashKey("A_C_Horse_Shire_LightGrey"),
        GetHashKey("A_C_Horse_Shire_RavenBlack"),
        GetHashKey("A_C_Horse_SuffolkPunch_Sorrel"),
        GetHashKey("A_C_Horse_SuffolkPunch_RedChestnut"),
        GetHashKey("A_C_Horse_TennesseeWalker_BlackRabicano"),
        GetHashKey("A_C_Horse_TennesseeWalker_Chestnut"),
        GetHashKey("A_C_Horse_TennesseeWalker_DappleBay"),
        GetHashKey("A_C_Horse_TennesseeWalker_RedRoan"),
        GetHashKey("A_C_Horse_TennesseeWalker_FlaxenRoan"),
        GetHashKey("A_C_Horse_Thoroughbred_BloodBay"),
        GetHashKey("A_C_Horse_Thoroughbred_DappleGrey"),
        GetHashKey("A_C_Horse_Thoroughbred_Brindle"),
        GetHashKey("A_C_Horse_Thoroughbred_BlackChestnut"),
        GetHashKey("A_C_Horse_Thoroughbred_ReverseDappleBlack"),
        GetHashKey("A_C_Horse_Turkoman_DarkBay"),
        GetHashKey("A_C_Horse_Turkoman_Gold"),
        GetHashKey("A_C_Horse_Turkoman_Silver")
    }

    local dogModels = {
        GetHashKey("A_C_DogAmericanFoxhound_01"),
        GetHashKey("A_C_DogAustralianShepherd_01"),
        GetHashKey("A_C_DogBluetickCoonhound_01"),
        GetHashKey("A_C_DogCatahoulaCur_01"),
        GetHashKey("A_C_DogChesBayRetriever_01"),
        GetHashKey("A_C_DogHound_01"),
        GetHashKey("A_C_DogLab_01"),
        GetHashKey("A_C_DogRufus_01"),
        GetHashKey("A_C_DogStreet_01")
    }

    exports.ox_target:addModel(animalModels, {
        {
            name = 'pet_animal',
            label = 'Pet Animal',
            icon = 'fas fa-paw',
            onSelect = function(data)
                local playerPed = PlayerPedId()
                local animal = data.entity

                SetPetAttributes(animal)

                LocalPlayer.state:set('inv_busy', true, true)

                TaskTurnPedToFaceEntity(playerPed, animal, 3000)
                TaskTurnPedToFaceEntity(animal, playerPed, 3000)

                local scenario = "WORLD_HUMAN_CROUCH_INSPECT"
                TaskStartScenarioInPlace(playerPed, GetHashKey(scenario), -1, true, false, false, false)

                local entityModel = GetEntityModel(animal)
                local isDog = false
                for _, dogModel in ipairs(dogModels) do
                    if entityModel == dogModel then
                        isDog = true
                        break
                    end
                end

                if isDog then
                    ClearPedTasks(animal)
                    ClearPedSecondaryTask(animal)
                    AnimationPet(animal, "amb_creature_mammal@world_dog_begging@idle", "idle_a")
                end

                Wait(3000)
                ClearPedTasks(playerPed)
                if isDog then
                    StopAnimation(animal, "amb_creature_mammal@world_dog_begging@idle", "idle_a")
                end

                LocalPlayer.state:set('inv_busy', false, true)

                TriggerServerEvent('hud:server:RelieveStress', STRESS_RELIEF_AMOUNT)

                lib.notify({
                    title = 'Animal Therapy',
                    description = 'Petting the ' .. (isDog and 'dog' or 'horse') .. ' has helped you relax and feel better!',
                    type = 'success',
                    duration = 5000
                })
            end,
            distance = PET_DISTANCE,
        }
    })
end)