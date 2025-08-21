-- ================================
-- COMPANION SHOP SPAWNING
-- Manages companion spawning and purchase in shops
-- ================================

local spawnedCompanions = {}
local CompanionSettings = lib.load('shared.stable_settings')

lib.locale()

function SpawnCompanions(companionmodel, companioncoords, heading)

    local spawnedCompanion = CreatePed(companionmodel, companioncoords.x, companioncoords.y, companioncoords.z - 1.0, heading, false, false, 0, 0)
    SetEntityAlpha(spawnedCompanion, 0, false)
    SetRandomOutfitVariation(spawnedCompanion, true)
    SetEntityCanBeDamaged(spawnedCompanion, false)
    SetEntityInvincible(spawnedCompanion, true)
    FreezeEntityPosition(spawnedCompanion, true)
    SetBlockingOfNonTemporaryEvents(spawnedCompanion, true)
    SetPedCanBeTargetted(spawnedCompanion, false)

    if Config.FadeIn then
        for i = 0, 255, 51 do
            Wait(50)
            SetEntityAlpha(spawnedCompanion, i, false)
        end
    end

    return spawnedCompanion
end

CreateThread(function()
    for key, value in pairs(CompanionSettings) do
        local coords = value.companioncoords
        local newpoint = lib.points.new({
            coords = coords,
            distance = Config.DistanceSpawn,
            model = joaat(value.companionmodel),
            ped = nil,
            price = value.companionprice,
            heading = coords.w,
            companionname = value.companionname
        })

        newpoint.onEnter = function(self)
            if not self.ped then
                lib.requestModel(self.model, 10000)
                self.ped = SpawnCompanions(self.model, self.coords, self.heading) -- spawn companion
                pcall(function ()
                    exports.ox_target:addLocalEntity(self.ped, {
                        {   name = 'companion_input_buy',
                            icon = "fas fa-companion-head",
                            label = self.companionname..' $'..self.price,
                            targeticon = "fas fa-eye",
                            onSelect = function()
                                local dialog = lib.inputDialog(locale('cl_input_setup'), {
                                    { type = 'input', label = locale('cl_input_setup_name'), required = true },
                                    {
                                        type = 'select',
                                        label = locale('cl_input_setup_gender'),
                                        options = {
                                            { value = 'male',   label = locale('cl_input_setup_gender_a') },
                                            { value = 'female', label = locale('cl_input_setup_gender_b') }
                                        }
                                    }
                                })

                                if not dialog then return end

                                local setCompanionName = dialog[1]
                                local setCompanionGender
                                if not dialog[2] then
                                    local genderNo = math.random(2)
                                    if genderNo == 1 then
                                        setCompanionGender = 'male'
                                    elseif genderNo == 2 then
                                        setCompanionGender = 'female'
                                    end
                                else
                                    setCompanionGender = dialog[2]
                                end

                                if setCompanionName and setCompanionGender then
                                    TriggerServerEvent('rsg-companions:server:BuyCompanion', self.price, self.model, value.stableid, setCompanionName, setCompanionGender)
                                else
                                    return
                                end
                            end,
                            canInteract = function(_, distance)
                                return distance < 2.0
                            end
                        }
                    })
                end)
            end
        end

        newpoint.onExit = function(self)
            exports.ox_target:removeLocalEntity(self.ped, 'companion_input_buy')
            if self.ped and DoesEntityExist(self.ped) then
                if Config.FadeIn then
                    for i = 255, 0, -51 do
                        Wait(50)
                        SetEntityAlpha(self.ped, i, false)
                    end
                end
                DeleteEntity(self.ped)
                self.ped = nil
            end
        end

        spawnedCompanions[key] = newpoint
    end
end)

-- cleanup
AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for k, v in pairs(spawnedCompanions) do
        exports.ox_target:removeLocalEntity(v.ped, 'companion_input_buy')
        if v.ped and DoesEntityExist(v.ped) then
            DeleteEntity(v.ped)
        end
        spawnedCompanions[k] = nil
    end
    spawnedCompanions = {}
end)