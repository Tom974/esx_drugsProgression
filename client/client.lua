ESX = nil
local blip = nil
local inStep = false
local infoArray = nil
local isNearbyNPC = false
local isAlreadyNearNPC = false

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

CreateThread(function()
    for k, v in pairs(Config.npcs) do
        addNPC(v.x, v.y, v.z, v.h, v.modelHash, v.pedModel, v.pedAnimation)
    end
end)

-- Indien player ingeladen word
RegisterNetEvent('esx:playerLoaded')
AddEventHandler("esx:playerLoaded", function()
    Citizen.Wait(100)
    ESX.TriggerServerCallback('esx_drugsProgression:getAlreadyLearned', function(identifier, results)
        if results ~= nil then
            infoArray = results
        end
    end)
end)

-- Tijdelijk ivm development en restarten van plugin/script
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return -- Als de resource niet gelijk is aan de resource die je hier hebt, doe niks
    end

    TriggerServerEvent("esx_drugsProgression:insertIfNotExists")
    ESX.TriggerServerCallback('esx_drugsProgression:getAlreadyLearned', function(identifier, results)
        if results ~= nil then
            infoArray = results
        end
    end)
end)

-- Detect keypress
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
        -- print(isNearbyNPC, currentNPC, inStep)
		if isNearbyNPC ~= false and currentNPC ~= nil then
            if inStep == false then
                local price = Config.drugsPrices[currentNPC.pedInfo]
                local drugConfig = infoArray[currentNPC.pedInfo]

                if currentNPC.stepNumber == 1 then
                    showInfobar('Druk op ~INPUT_PICKUP~ om '..currentNPC.pedInfo..' te leren (€'..price..')')
                    if IsControlJustReleased(0, 38) and IsPedInAnyVehicle(PlayerPedId(), true) == false then -- (38 = E)
                        stepOne(currentNPC.pedInfo, drugConfig, price)
                    end
                elseif currentNPC.stepNumber == 2 then
                    if DoesBlipExist(blip) then
                        RemoveBlip(blip)
                    end
                    showInfobar('Druk op ~INPUT_PICKUP~ om te praten met Mike')
                    if IsControlJustReleased(0, 38) and IsPedInAnyVehicle(PlayerPedId(), true) == false then -- (38 = E)
                        if drugConfig.stepTwo == 0 and drugConfig.stepOne == 1 then
                            stepTwo(currentNPC.pedInfo, drugConfig)
                        else 
                            ESX.ShowNotification(_U('npcName')..'Ga eerst naar Trevor om te betalen!')
                        end
                    end
                elseif currentNPC.stepNumber == 3 then
                    showInfobar('Druk op ~INPUT_PICKUP~ om een '.._U(currentNPC.pedInfo..'_translation')..' formule te craften')
                    if IsControlJustReleased(0, 38) and IsPedInAnyVehicle(PlayerPedId(), true) == false then -- (38 = E)
                        craftFormula(currentNPC.pedInfo, drugConfig)
                    end
                end
            end
		else
			Citizen.Wait(1500)
		end
	end
end)

function stepOne(drug_type, drugConfig, price)
    inStep = true
    if drugConfig.learned == 1 then
        ESX.ShowNotification(_U('npcName')..'Je hebt dit al geleerd!')
    elseif drugConfig.learned == 0 then
        if drugConfig.stepOne == 0 then
            if price ~= nil then
                ESX.TriggerServerCallback('esx_drugsProgression:removeAccountMoney', function(result)
                    if result == true then
                        ESX.ShowNotification(_U('npcName')..'Ga naar de locatie op je gps! Zorg dat je een pot en schep bij je hebt!')
                        SetWaypoint(currentNPC.waypointX, currentNPC.waypointY, currentNPC.waypointZ, drug_type)
                        -- Hier zorgen dat de database ook geupdate word met done_step_1
                        TriggerServerEvent('esx_drugsProgression:doneStep', drug_type, 'stepOne')
                        infoArray[drug_type].stepOne = 1
                    elseif result == false then
                        ESX.ShowNotification(_U('npcName')..'Je hebt niet genoeg geld op zak!')
                    end
                end, price)
            end
        else 
            ESX.ShowNotification(_U('npcName').._U(drug_type..'already_paid'))
        end
    end
    inStep = false
end

function stepTwo(drugType, drugConfig) -- Animatie basically
    ESX.TriggerServerCallback('esx_drugsProgression:getDrugsPercentage', function(percentage)
        if drugType == 'coke' then
            if percentage < Config.cokePercentage then
                ESX.ShowNotification(_U('npcName')..'je hebt niet genoeg drugs % om dit te leren!')
                return
            end
        elseif drugType == 'meth' then
            if percentage < Config.methPercentage then
                ESX.ShowNotification(_U('npcName')..'je hebt niet genoeg drugs % om dit te leren!')
                return
            end
        end
    end)
    
    inStep = true
    ESX.TriggerServerCallback('esx_drugsProgression:playerHasItems', function(hasItems)
        for k,v in pairs(hasItems) do
            if v.hasItem == false then
                ESX.ShowNotification(_U('npcName').._U('missingItems'))
                return
            end
        end

        DisableControlAction(0, 73) -- Zorgen dat je geen "X" kunt drukken
        ESX.ShowNotification(_U('npcName').._U('foundIngredients'))
        Citizen.Wait(1500)
        
        ESX.ShowNotification(_U('npcName')..'Hier, neem een schep en begin met het wiet plantje uit de grond te halen.')
        local animation = Config.animations[drugType]
        TaskStartScenarioInPlace(PlayerPedId(), animation, 0, false)
        Citizen.SetTimeout(10000, function()
            ClearPedTasks(PlayerPedId())
            ESX.ShowNotification(_U('npcName').._U('doneStepTwo'))
            Citizen.Wait(1500)
            TriggerServerEvent('esx_drugsProgression:give_formula', drugType)
            TriggerServerEvent('esx_drugsProgression:finishSteps', drugType)
            infoArray[drugType].stepOne = 0
            infoArray[drugType].stepTwo = 0
            infoArray[drugType].learned = 0
            EnableControlAction(0, 73)
            ESX.ShowNotification(_U('npcName')..'Hier, neem deze formule en craft deze om bij Michael in de buurt van Paleto Bay')
            Citizen.Wait(1500)
        end)
    end, Config.itemsToHave[drugType])
    inStep = false
end

function craftFormula(drugType, drugConfig)
    ESX.TriggerServerCallback('esx_drugsProgression:playerHasItems', function(hasItems)
        for k,v in pairs(hasItems) do
            if v.hasItem == false then
                ESX.ShowNotification(_U('npcName')..'Je hebt de formule niet bij je!')
                return
            end
        end

        ESX.ShowNotification(_U('npcName')..'Dankjewel! Je gaat nu de formule craften..')
        isDeliveringFormula = true
        TaskStartScenarioInPlace(PlayerPedId(), 'PROP_HUMAN_BUM_BIN', 0, false)
        DisableControlAction(0, 73) -- Zorgen dat je geen "X" kunt drukken
        Citizen.SetTimeout(10000, function()
            EnableControlAction(0, 73)
            ClearPedTasksImmediately(PlayerPedId())
            TriggerServerEvent('esx_drugsProgression:removeFormula', drugType)
            ESX.ShowNotification(_U('npcName')..'Je hebt de formule geleerd, gefeliciteerd!')
            isDeliveringFormula = false
        end)
    end, {{item=drugType..'_formula', amount=1}})
end

-- Display text near npc
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
        local isNearby = false
        local minDistance = 1000 

        for k, v in pairs(Config.npcs) do
            local distance = #(GetEntityCoords(PlayerPedId()) - vec3(v.x, v.y, v.z))
            if(distance < Config.displayDistance) then
                isNearby = true
            end

            if isNearby and not isAlreadyNearNPC then
                -- Update de current container waar je staat
                isAlreadyNearNPC = true
                isNearbyNPC = true
                currentNPC = v
            end

            minDistance = math.min(distance, minDistance)
        end

        if minDistance > Config.displayDistance then
            Citizen.Wait(10 * minDistance)
        end

        if not isNearby and isAlreadyNearNPC then
            isAlreadyNearNPC = false
            isNearbyNPC = false
        end
	end
end)

-- Functie om text linksboven weer te geven
function showInfobar(msg)
	CurrentActionMsg  = msg
	SetTextComponentFormat('STRING')
	AddTextComponentString(CurrentActionMsg)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

-- Nummer formatteren
function formatNumber(number)
    return tostring(math.floor(number)):reverse():gsub("(%d%d%d)","%1,"):gsub(".(%-?)$","%1"):reverse()
end

-- NPC Toevoegen
function addNPC(x, y, z, heading, hash, model, animatie)
    RequestModel(GetHashKey(model))
    RequestAnimDict(animatie)
    ped = CreatePed(4, hash, x, y, z - 1, 3374176, false, true)
    SetEntityHeading(ped, heading)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskPlayAnim(ped, animatie, "base", 8.0, 0.0, -1, 1, 0, 0, 0, 0)
end

-- Waypoint maken function
function SetWaypoint(x, y, z, drug_type)
    local lang = Config.lang.drug_type[drug_type]
    if DoesBlipExist(blip) then
        RemoveBlip(blip)
    end
    blip = AddBlipForCoord(x, y, z)
	SetBlipRoute(blip, true)
    AddTextEntry("BLIP_LOCATIE_DRUGS_LEREN", lang .. " Leren")
	BeginTextCommandSetBlipName("BLIP_LOCATIE_DRUGS_LEREN")
	EndTextCommandSetBlipName(blip)
    SetBlipRoute(blip, true)
end