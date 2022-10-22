ESX = nil
local array = {}
local standardArray = {
    weed = {
        stepOne = 0,
        stepTwo = 0,
        learned = 0
    },
    coke = {
        stepOne = 0,
        stepTwo = 0,
        learned = 0
    },
    meth = {
        stepOne = 0,
        stepTwo = 0,
        learned = 0
    }
}


TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- SERVER CALLBACKS
ESX.RegisterServerCallback("esx_drugsProgression:getAlreadyLearned", function(source, cb)
    local identifier = GetPlayerIdentifiers(source)[1]
    MySQL.single('SELECT * FROM `esx_drugsProgression` WHERE `identifier` = ?', {identifier}, function(result)
        if result ~= nil then
            cb(identifier, json.decode(result.info))
        else 
            cb(identifier, nil)
        end
    end)
end)

RegisterServerEvent("esx_drugsProgression:insertIfNotExists")
AddEventHandler("esx_drugsProgression:insertIfNotExists", function()
    local identifier = GetPlayerIdentifiers(source)[1]
    MySQL.scalar('SELECT `identifier` FROM `esx_drugsProgression` WHERE `identifier` = ?', {identifier}, function(account)
        if account == nil then
            MySQL.insert('INSERT INTO `esx_drugsProgression` (`identifier`, `info`) VALUES (?,?)', 
                {
                    identifier,
                    json.encode(standardArray)
                }
            )
        end
    end)
end)

ESX.RegisterServerCallback("esx_drugsProgression:playerHasItems", function(source, cb, itemsToCheck)
    local xPlayer = ESX.GetPlayerFromId(source)
    -- print(xPlayer.getInventoryItem('weed_formula').count)
    local checkedItems = {}
    if itemsToCheck ~= nil then
        for _, v in pairs(itemsToCheck) do
            if xPlayer.getInventoryItem(v.item).count > 0 then
                table.insert(checkedItems, {item=v.item, hasItem=true})
            else
                table.insert(checkedItems, {item=v.item, hasItem=false})
            end
        end

    end

    cb(checkedItems)
end)

ESX.RegisterServerCallback("esx_drugsProgression:getDrugsPercentage", function(source, cb)
    local identifier = GetPlayerIdentifiers(source)[1]
    MySQL.query('SELECT `drugs` FROM `stadus_skills` WHERE `identifier` = ?', {identifier}, function(skillInfo)
        cb(skillInfo[1].drugs)
    end)
end)

ESX.RegisterServerCallback("esx_drugsProgression:removeAccountMoney", function(source, cb, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if tonumber(xPlayer.getMoney()) >= tonumber(amount) then
        xPlayer.removeMoney(tonumber(amount))
        cb(true)
    else 
        cb(false)
    end
end)

-- SERVER EVENTS
RegisterServerEvent("esx_drugsProgression:doneStep")
AddEventHandler("esx_drugsProgression:doneStep", function(drugType, step)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = GetPlayerIdentifiers(source)[1]

    MySQL.scalar('SELECT `info` FROM `esx_drugsProgression` WHERE `identifier` = ?', {identifier}, function(result)
        if result ~= nil then
            result = json.decode(result)
            result[drugType][step] = 1
            MySQL.update('UPDATE `esx_drugsProgression` SET `info` = ? WHERE `identifier` = ?', {json.encode(result), identifier})
        end
    end)
end)


RegisterServerEvent("esx_drugsProgression:finishSteps")
AddEventHandler("esx_drugsProgression:finishSteps", function(drugType, step)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = GetPlayerIdentifiers(source)[1]

    MySQL.scalar('SELECT `info` FROM `esx_drugsProgression` WHERE `identifier` = ?', {identifier}, function(result)
        if result ~= nil then
            result = json.decode(result)
            result[drugType].stepOne = 0
            result[drugType].stepTwo = 0
            MySQL.update('UPDATE `esx_drugsProgression` SET `info` = ? WHERE `identifier` = ?', {json.encode(result), identifier})
        end
    end)
end)


RegisterServerEvent("drugs_progression:give_formula")
AddEventHandler("drugs_progression:give_formula", function(drug_type)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addInventoryItem(drug_type..'_formula', 1)
end)

RegisterServerEvent("esx_drugsProgression:removeFormula")
AddEventHandler("esx_drugsProgression:removeFormula", function(drug_type)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeInventoryItem(drug_type..'_formula', 1)
end)

RegisterServerEvent("drugs_progression:drugsLearned")
AddEventHandler("drugs_progression:drugsLearned", function(type_drugs)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = GetPlayerIdentifiers(source)[1]

    MySQL.scalar('SELECT `identifier` FROM `drugs_progression` WHERE `identifier` = ?', {identifier}, function(accounts)
        if accounts == nil then
            array['done_step_1'] = 0
            array['done_step_2'] = 0
            array['learned'] = 1
            MySQL.insert('INSERT INTO `drugs_progression` (`identifier`, `'..type_drugs..'`) VALUES (?, ?)', {identifier, json.encode(array)})
        else
            MySQL.update('UPDATE `drugs_progression` SET `'..type_drugs..'` = ? WHERE `identifier` = ?', {json.encode(array), identifier})
        end
    end)
end)

RegisterServerEvent("drugs_progression:clearDrugType")
AddEventHandler("drugs_progression:clearDrugType", function(type_drugs)
    print('clearing drug type')
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = GetPlayerIdentifiers(source)[1]
    local update_array = {}
    update_array['done_step_1'] = 0
    update_array['done_step_2'] = 0
    update_array['learned'] = 0
    MySQL.update('UPDATE `drugs_progression` SET `'..type_drugs..'` = ? WHERE `identifier` = ?', {json.encode(update_array), identifier})
end)

-- RegisterServerEvent("drugs_progression:insert_if_not_exists")
-- AddEventHandler("drugs_progression:insert_if_not_exists", function()
--     local identifier = GetPlayerIdentifiers(source)[1]
--     MySQL.scalar('SELECT `identifier` FROM `drugs_progression` WHERE `identifier` = ?', {identifier}, function(account)
--         if account == nil then
--             array['done_step_1'] = 0
--             array['done_step_2'] = 0
--             array['learned'] = 0
--             MySQL.Async.execute('INSERT INTO `drugs_progression` (`identifier`, `weed`, `coke`, `meth`) VALUES (?,?,?,?)', 
--                 {
--                     identifier, 
--                     json.encode(array),
--                     json.encode(array),
--                     json.encode(array)
--                 }
--             )
--         end
--     end)
-- end)