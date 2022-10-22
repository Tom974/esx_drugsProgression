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


TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end) -- help mij in deze despressie

-- ESX CALLBACKS

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

ESX.RegisterServerCallback("esx_drugsProgression:playerHasItems", function(source, cb, itemsToCheck)
    local checkedItems = {}
    if itemsToCheck ~= nil then
        for _, v in pairs(itemsToCheck) do
            if ESX.Player.getInventoryItem(v.item).count > 0 then
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
    MySQL.scalar('SELECT `drugs` FROM `stadus_skills` WHERE `identifier` = ?', {identifier}, function(skillInfo)
        cb(skillInfo.drugs)
    end)
end)

ESX.RegisterServerCallback("esx_drugsProgression:removeAccountMoney", function(source, cb, amount)
    if tonumber(ESX.Player.getMoney()) >= tonumber(amount) then
        ESX.Player.removeMoney(tonumber(amount))
        cb(true)
    else 
        cb(false)
    end
end)

-- SERVER EVENTS

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

RegisterServerEvent("esx_drugsProgression:doneStep")
AddEventHandler("esx_drugsProgression:doneStep", function(drugType, step)
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

RegisterServerEvent("esx_drugsProgression:removeFormula")
AddEventHandler("esx_drugsProgression:removeFormula", function(drug_type)
    ESX.Player.removeInventoryItem(drug_type..'_formula', 1)
end)