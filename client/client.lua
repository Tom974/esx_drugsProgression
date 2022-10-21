-- ESX.TriggerServerCallback('drugs_progression:getDrugsPercentage', function(percentage)
--     print('percentage: ' .. percentage)
-- end) -- Voor later nog misschien nodig

ESX = nil
local blip = nil
local step_1_weed = nil
local step_2_weed = nil
local isDeliveringFormula = false
local weed_learned = nil
local coke_learned = nil
local meth_learned = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

CreateThread(function()
    for _, v in pairs(Config.npcs) do
        addNPC(v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8])
    end
end)

-- Tijdelijk ivm development en restarten van plugin/script
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return -- Als de resource niet gelijk is aan de resource die je hier hebt, doe niks
    end


    TriggerServerEvent("drugs_progression:insert_if_not_exists")
    Citizen.Wait(100)
    ESX.TriggerServerCallback('drugs_progression:getAlreadyLearned', function(identifier, value, done_step_1, done_step_2)
        step_1_weed = done_step_1
        step_2_weed = done_step_2
        weed_learned = value
        if step_1_weed == 1 and step_2_weed == 0 then
            ESX.ShowNotification(_U('npcName')..' ~s~Ga naar de locatie op je gps!')
            SetWaypoint(487.55, 5589.09, 794.05, 'weed')
        end
    end, 'weed')
end)

-- Indien player ingeladen word
RegisterNetEvent('esx:playerLoaded')
AddEventHandler("esx:playerLoaded", function(xPlayer)
    ESX.PlayerData = xPlayer
    TriggerServerEvent("drugs_progression:insert_if_not_exists")
    Citizen.Wait(100)
    ESX.TriggerServerCallback('drugs_progression:getAlreadyLearned', function(identifier, value, done_step_1, done_step_2)
        step_1_weed = done_step_1
        step_2_weed = done_step_2
        weed_learned = value
        if step_1_weed == 1 and step_2_weed == 0 then
            ESX.ShowNotification(_U('npcName')..' ~s~Ga naar de locatie op je gps!')
            SetWaypoint(487.55, 5589.09, 794.05, 'weed')
        end
    end, 'weed')
end)

-- While loop waar ik zelf niet zo erg van hou, maar kan blijkbaar niet anders
CreateThread(function()
    while true do  
        for _, v in pairs(Config.npcs) do
            local distance = #(GetEntityCoords(PlayerPedId()) - vec3(v[1], v[2], v[3]))
            if (distance < 2.0) then -- indien je dichtbij de npc bent
                if v[7] == "learning_weed_1" then
                    if tonumber(step_1_weed) == 0 then
                        local price = Config.drugsPrices['weed']
                        showInfobar('Druk op ~INPUT_PICKUP~ om wiet te leren (€'..formatNumber(price)..')')
                        if IsControlJustReleased(0, 38) and IsPedInAnyVehicle(PlayerPedId(), true) == false then
                            if weed_learned == 1 then
                                ESX.ShowNotification(_U('npcName')..' ~s~Je hebt wiet al geleerd!')
                            elseif weed_learned == 0 then
                                if price ~= nil then
                                    ESX.TriggerServerCallback('drugs_progression:removeAccountMoney', function(result)
                                        if result == true then
                                            ESX.ShowNotification(_U('npcName')..' ~s~Ga naar de locatie op je gps!')
                                            SetWaypoint(487.55, 5589.09, 794.05, 'weed')
                                            -- Hier zorgen dat de database ook geupdate word met done_step_1
                                            TriggerServerEvent('drugs_progression:done_step', 'weed', '1')
                                            step_1_weed = 1
                                        elseif result == false then
                                            ESX.ShowNotification(_U('npcName')..' ~s~Je hebt niet genoeg geld op zak!')
                                        end
                                    end, price)
                                end
                            end
                        end
                    else
                        if IsControlJustReleased(0, 38) and IsPedInAnyVehicle(PlayerPedId(), true) == false then
                            ESX.ShowNotification(_U('npcName')..' ~s~Je hebt mij al betaald voor wiet, maak eerst het leerproces af!')
                        end
                    end
                elseif v[7] == "learning_weed_2" then
                    showInfobar(_U('npcName').."Druk ~c~[~g~E~c~]~s~")
                    if step_2_weed == 0 and step_1_weed == 1 then
                        if DoesBlipExist(blip) then
                            RemoveBlip(blip)
                        end
                        if IsControlJustReleased(0, 38) and IsPedInAnyVehicle(PlayerPedId(), true) == false then
                            ESX.ShowNotification(_U('npcName')..' ~s~Ik ga je leren hoe je moet plukken.')
                            local amount = 100
                            local keep_going = true
                            for i=1, amount do
                                if IsControlJustReleased(0, 73) then
                                    ESX.ShowNotification(_U('npcName')..' ~s~Oke als je niet verder wilt gaan dan niet..')
                                    -- Kan hier ook gewoon DisableControlAction(0, <keynumber>) doen om te zorgen dat je geen X kunt drukken
                                    keep_going = false
                                    break
                                end
                                Citizen.Wait(1)
                            end
                            
                            if keep_going == true then
                                ESX.ShowNotification(_U('npcName')..' ~s~Hier, neem een schep en begin met het wiet plantje uit de grond te halen.')
                                TaskStartScenarioInPlace(PlayerPedId(), 'world_human_gardener_plant', 0, false)
                                local amount = 2000
                                local keep_going = true
                                for i=1, amount do
                                    if IsControlJustReleased(0, 73) then
                                        ESX.ShowNotification(_U('npcName')..' ~s~Oke als je niet verder wilt gaan dan niet..')
                                        -- Kan hier ook gewoon DisableControlAction(0, <keynumber>) doen om te zorgen dat je geen X kunt drukken
                                        keep_going = false
                                        break
                                    end
                                    Citizen.Wait(1)
                                end
                                if keep_going == true then
                                    ClearPedTasks(PlayerPedId())
                                    ESX.ShowNotification(_U('npcName')..' ~s~Goed zo, dat was het! Nu weet je hoe je wiet moet plukken!')
                                    -- give weed formula item to user
                                    -- TriggerServerEvent('drugs_progression:done_step', 'weed', '2')
                                    TriggerServerEvent('drugs_progression:give_formula', 'weed')
                                    TriggerServerEvent('drugs_progression:clearDrugType', 'weed')
                                    weed_learned = 0
                                    step_2_weed = 0
                                    step_1_weed = 0
                                end
                            end
                        end
                    elseif step_1_weed == 0 then
                        if IsControlJustReleased(0, 38) and IsPedInAnyVehicle(PlayerPedId(), true) == false then
                            ESX.ShowNotification(_U('npcName')..' ~s~Ga eerst naar Trevor om te betalen!')
                        end
                    end
                elseif v[7] == 'deliver_formula' then -- id buurt van aflevering npc
                    if isDeliveringFormula == false then -- Check of je al een formule aan het leveren/craften bent
                        ESX.showInfobar("Druk ~c~[~g~E~c~]~s~ om een formule in te leveren")
                        if IsControlJustReleased(0, 38) and IsPedInAnyVehicle(PlayerPedId(), true) == false then
                            ESX.TriggerServerCallback('drugs_progression:hasFormulaInInventory', function(formula)
                                if formula ~= false then
                                    ESX.ShowNotification(_U('npcName')..' ~s~Dankjewel! Je gaat nu de formule craften..')
                                    -- TODO: verstuur deepweb bericht, eventueel kansberekening eromheen
                                    -- TriggerServerEvent('drugs_progression:deepweb_message', formula)
                                    -- TODO: Verstuur bericht naar politie, eventueel kansberekening eromheen
                                    isDeliveringFormula = true
                                    TaskStartScenarioInPlace(PlayerPedId(), 'PROP_HUMAN_BUM_BIN', 0, false)
                                    FreezeEntityPosition(PlayerPedId(), true)
                                    amount = 1500
                                    local keep_going = true
                                    for i=1, amount do
                                        if IsControlJustReleased(0, 73) then
                                            ESX.ShowNotification(_U('npcName')..' ~s~oke dan.. dan stop ik wel')
                                            -- Kan hier ook gewoon DisableControlAction(0, <keynumber>) doen om te zorgen dat je geen X kunt drukken
                                            ClearPedTasksImmediately(PlayerPedId())
                                            FreezeEntityPosition(PlayerPedId(), false)
                                            keep_going = false
                                            isDeliveringFormula = false
                                        end
                                        if keep_going == true then
                                            if i % 500 == 0 then
                                                ESX.ShowNotification("Craften van formule: " .. i .. "/" .. amount)
                                            end
                                        else 
                                            break -- ga uit de functie als je op x hebt gedrukt, we hoeven de loop dan niet af te maken
                                        end
                                        Citizen.Wait(1)
                                    end
                                    if keep_going == true then
                                        ClearPedTasksImmediately(PlayerPedId())
                                        FreezeEntityPosition(PlayerPedId(), false)
                                        TriggerServerEvent('drugs_progression:remove_formula', formula)
                                        TriggerServerEvent('clearDrugType', formula)
                                        ESX.ShowNotification(_U('npcName')..' ~s~Je hebt de formule geleerd, success ermee')
                                        -- TriggerServerEvent("drugs_progression:drugsLearned", 'weed') -- Dit zorgt ervoor dat je het hele proces maar 1x kan doen.
                                        isDeliveringFormula = false
                                        if formula == 'weed' then
                                            weed_step_1 = 0
                                            weed_step_2 = 0
                                            weed_learned = 0
                                        end -- later nog coke en meth toevoegen, maar zit nu een beetje met die variabelen hoe ik dit het beste dynamisch kan maken
                                    end
                                else
                                    ESX.ShowNotification(_U('npcName')..' ~s~Je hebt geen formule bij je!')
                                end
                            end)

                        end                       
                    end
                end
            end
        end
        Wait(1) -- Infinite supoer loop lag voorkomen
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
function addNPC(x, y, z, heading, hash, model, npc_type, animatie)
    RequestModel(GetHashKey(model))
    while not HasModelLoaded(GetHashKey(model)) do
        Wait(15)
    end
    RequestAnimDict(animatie)
    while not HasAnimDictLoaded(animatie) do
        Wait(15)
    end
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
    AddTextEntry("BLIP_LOCATIE_DRUGS_LEREN_WEED", lang .. " Leren")
	BeginTextCommandSetBlipName("BLIP_LOCATIE_DRUGS_LEREN_WEED")
	EndTextCommandSetBlipName(blip)
    SetBlipRoute(blip, true)
end