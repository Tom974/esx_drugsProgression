ESX = nil
local array = {}
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- SERVER CALLBACKS
ESX.RegisterServerCallback("drugs_progression:getAlreadyLearned", function(source, cb, type_drug)
    local identifier = GetPlayerIdentifiers(source)[1]
    MySQL.scalar('SELECT `'..type_drug..'` from `drugs_progression` WHERE `identifier` = ?', {identifier}, function(result)
        if result ~= nil then
            result = json.decode(result)
            cb(identifier, result.learned, result.done_step_1, result.done_step_2)
        end
    end)
end)

ESX.RegisterServerCallback("drugs_progression:hasFormulaInInventory", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    print(xPlayer.getInventoryItem('weed_formula').count)
    if xPlayer.getInventoryItem('weed_formula').count > 0 then
        cb('weed')
    elseif xPlayer.getInventoryItem('coke_formula').count > 0 then
        cb('coke')
    elseif xPlayer.getInventoryItem('meth_formula').count > 0 then
        cb('meth')
    else 
        cb(false)
    end
end)


ESX.RegisterServerCallback("drugs_progression:getDrugsPercentage", function(source, cb)
    local identifier = GetPlayerIdentifiers(source)[1]
    MySQL.query('SELECT `drugs` FROM `stadus_skills` WHERE `identifier` = ?', {identifier}, function(skillInfo)
        cb(skillInfo[1].drugs)
    end)
end)

ESX.RegisterServerCallback("drugs_progression:removeAccountMoney", function(source, cb, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    print(xPlayer.getMoney())
    if tonumber(xPlayer.getMoney()) >= tonumber(amount) then
        xPlayer.removeMoney(tonumber(amount))
        cb(true)
    else 
        cb(false)
    end
end)

-- SERVER EVENTS
RegisterServerEvent("drugs_progression:done_step")
AddEventHandler("drugs_progression:done_step", function(type_drugs, step)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = GetPlayerIdentifiers(source)[1]

    MySQL.scalar('SELECT '..type_drugs..' FROM drugs_progression WHERE identifier = ?', {identifier}, function(result)
        if result ~= nil then
            result = json.decode(result)
            result['done_step_'..step] = 1
            MySQL.update('UPDATE `drugs_progression` SET `'..type_drugs..'` = ? WHERE `identifier` = ?', {json.encode(result), identifier})
        end
    end)
end)

RegisterServerEvent("drugs_progression:give_formula")
AddEventHandler("drugs_progression:give_formula", function(drug_type)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addInventoryItem(drug_type..'_formula', 1)
end)

RegisterServerEvent("drugs_progression:remove_formula")
AddEventHandler("drugs_progression:remove_formula", function(drug_type)
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

RegisterServerEvent("drugs_progression:insert_if_not_exists")
AddEventHandler("drugs_progression:insert_if_not_exists", function()
    local identifier = GetPlayerIdentifiers(source)[1]
    MySQL.scalar('SELECT `identifier` FROM `drugs_progression` WHERE `identifier` = ?', {identifier}, function(account)
        if account == nil then
            array['done_step_1'] = 0
            array['done_step_2'] = 0
            array['learned'] = 0
            MySQL.Async.execute('INSERT INTO `drugs_progression` (`identifier`, `weed`, `coke`, `meth`) VALUES (?,?,?,?)', 
                {
                    identifier, 
                    json.encode(array),
                    json.encode(array),
                    json.encode(array)
                }
            )
        end
    end)
end)