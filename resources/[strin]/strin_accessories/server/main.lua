/*
    Citizen.CreateThread(function()
        local result = MySQL.query.await("SELECT * FROM characters")
        for _,v in pairs(result) do
            MySQL.insert.await("INSERT INTO character_accessories SET `identifier` = ?, `char_id` = ?", {
                v.identifier,
                v.char_id
            })
        end
    end)
*/

Citizen.CreateThread(function()
    local columnsTable = {}
    for k,v in pairs(AccessoryShops) do
        local column = k
        if(column:sub(-1) ~= "s") then
            column = column.."s" 
        end
        table.insert(columnsTable, ("`%s` LONGTEXT DEFAULT NULL"):format(column:lower()))
    end
    local alterColumnsTable = {}
    for i=1, #columnsTable do
        alterColumnsTable[i] = "ADD IF NOT EXISTS "..columnsTable[i]
    end
    MySQL.query.await(([[
        CREATE TABLE IF NOT EXISTS `character_accessories` (
            `identifier` VARCHAR(255) DEFAULT NULL,
            `char_id` INT(11) DEFAULT NULL,
            %s
        );
    ]]):format(table.concat(columnsTable, ",\n")))
    MySQL.query.await(([[
        ALTER TABLE `character_accessories`
            ADD IF NOT EXISTS `identifier` VARCHAR(255) DEFAULT NULL,
            ADD IF NOT EXISTS `char_id` INT(11) DEFAULT NULL,
            %s;
    ]]):format(table.concat(alterColumnsTable, ",\n")))
end)

AddEventHandler("strin_characters:characterCreated", function(identifier, characterId)
    MySQL.prepare("INSERT INTO character_accessories SET `identifier` = ?, `char_id` = ?", {
        identifier,
        characterId
    }, function () end)
end)

AddEventHandler("strin_characters:characterDeleted", function(identifier, characterId)
    MySQL.prepare("DELETE FROM character_accessories WHERE `identifier` = ? AND `char_id` = ?", {
        identifier,
        characterId
    }, function() end)
end)

RegisterNetEvent("strin_accessories:buyAccessory", function(changes)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end
    
    local charType = xPlayer.get("char_type")
    if(charType ~= 1) then
        xPlayer.showNotification("Tento typ postavy není podporován!", { type = "error" })
        return
    end

    local accessoryType, accessory = GetAccessoryFromChanges(changes)
    if(not accessoryType or not accessory) then
        xPlayer.showNotification("Neplatný doplněk!", {type = "error"})
        return
    end

    if((xPlayer.getMoney() - AccessoryPrice) < 0) then
        xPlayer.showNotification("Nemáte u sebe tolik peněz!", {type = "error"})
        return
    end
    local playerAccessories = GetCharacterAccessory(xPlayer.identifier, xPlayer.get("char_id"), accessoryType)
    table.insert(playerAccessories, accessory)
    MySQL.prepare(
        ("UPDATE character_accessories SET `%s` = ? WHERE `identifier` = ? AND `char_id` = ?"):format(
            GetAccessoryColumn(accessoryType)
        )
    , {
        json.encode(playerAccessories),
        xPlayer.identifier,
        xPlayer.get("char_id")
    }, function()
        xPlayer.removeMoney(AccessoryPrice)
        xPlayer.showNotification("Zakoupil jste si nový doplněk!", {type = "success"})
    end)
end)

RegisterNetEvent("strin_accessories:deleteAccessory", function(accessoryType, accessoryId)
    if(not lib.table.contains(GetAccessoryTypes(), accessoryType) or not tonumber(accessoryId)) then
        return
    end
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end    
    
    local charType = xPlayer.get("char_type")
    if(charType ~= 1) then
        xPlayer.showNotification("Tento typ postavy není podporován!", { type = "error" })
        return
    end

    local playerAccessories = GetCharacterAccessory(xPlayer.identifier, xPlayer.get("char_id"), accessoryType)
    if(not playerAccessories[tonumber(accessoryId)]) then
        xPlayer.showNotification("Takový doplněk nevlastníte!", {type = "error"})
        return
    end
    local newAccessories = {}
    for id,accessory in pairs(playerAccessories) do
        if(id ~= accessoryId) then
            table.insert(newAccessories, accessory)
        end
    end
    MySQL.prepare(
        ("UPDATE character_accessories SET `%s` = ? WHERE `identifier` = ? AND `char_id` = ?"):format(
            GetAccessoryColumn(accessoryType)
        )
    , {
        json.encode(newAccessories),
        xPlayer.identifier,
        xPlayer.get("char_id")
    }, function()
        xPlayer.showNotification(("Odstranil jste doplněk - %s"):format(accessoryId), {type = "inform"})
    end)
end)

RegisterNetEvent("strin_accessories:renameAccessory", function(accessoryType, accessoryId, accessoryLabel)
    if(
        not lib.table.contains(GetAccessoryTypes(), accessoryType) or
        not tonumber(accessoryId) or
        not accessoryLabel or 
        not (type(accessoryLabel) == "string")
    ) then
        return
    end
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end  
    
    local charType = xPlayer.get("char_type")
    if(charType ~= 1) then
        xPlayer.showNotification("Tento typ postavy není podporován!", { type = "error" })
        return
    end
      
    local playerAccessories = GetCharacterAccessory(xPlayer.identifier, xPlayer.get("char_id"), accessoryType)
    if(not playerAccessories[tonumber(accessoryId)]) then
        xPlayer.showNotification("Takový doplněk nevlastníte!", {type = "error"})
        return
    end
    local newAccessories = {}
    if(string.len(accessoryLabel) == 0 and playerAccessories[tonumber(accessoryId)].label) then
        for k,v in pairs(playerAccessories) do
            if(k == tonumber(accessoryId)) then
                newAccessories[k] = {
                    variation = v.variation,
                    texture = v.texture
                }
            else
                newAccessories[k] = v
            end
        end
    elseif(string.len(accessoryLabel) > 0) then
        playerAccessories[tonumber(accessoryId)].label = ESX.SanitizeString(accessoryLabel)
        newAccessories = playerAccessories
    end
        
    MySQL.prepare(
        ("UPDATE character_accessories SET `%s` = ? WHERE `identifier` = ? AND `char_id` = ?"):format(
            GetAccessoryColumn(accessoryType)
        )
    , {
        json.encode(newAccessories),
        xPlayer.identifier,
        xPlayer.get("char_id")
    }, function()
        xPlayer.showNotification(("Přejmenoval jste doplněk - %s"):format(accessoryId), {type = "inform"})
    end)
end)

RegisterNetEvent("strin_accessories:wearAccessory", function(accessoryType, accessoryId)
    if(
        not lib.table.contains(GetAccessoryTypes(), accessoryType) or
        type(accessoryId) ~= "number"
    ) then
        return
    end
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end  
    
    local charType = xPlayer.get("char_type")
    if(charType ~= 1) then
        xPlayer.showNotification("Tento typ postavy není podporován!", { type = "error" })
        return
    end
      
    local playerAccessories = GetCharacterAccessory(xPlayer.identifier, xPlayer.get("char_id"), accessoryType)
    local accessory = playerAccessories?[accessoryId]
    if(not accessory) then
        xPlayer.showNotification("Takový doplněk nevlastníte!", {type = "error"})
        return
    end

    local skin = json.decode(MySQL.prepare.await("SELECT `skin` FROM `users` WHERE `identifier` = ?", { xPlayer.identifier }) or "{}")

    if(not skin or not next(skin)) then
        xPlayer.showNotification("Nepodařilo se načíst skin!", {type = "error"})
        return
    end

    local variationComponentName = accessoryType == "arms" and accessoryType or accessoryType.."_1"
    local textureComponentName = accessoryType.."_2"
    local changeType = "TAKE_ON"
    if(skin[variationComponentName] == accessory.variation and skin[textureComponentName] == accessory.texture) then
        local components = exports.skinchanger:GetComponents(_source)
        local variationComponentValue = nil
        local textureComponentValue = nil
        for i=1, #components do
            if(components[i].name == variationComponentName) then
                variationComponentValue = components[i].value
            elseif(components[i].name == textureComponentName) then
                textureComponentValue = components[i].value
            end
            if(variationComponentValue and textureComponentName) then
                break
            end
        end
        skin[variationComponentName] = variationComponentValue
        skin[textureComponentName] = textureComponentValue
        changeType = "TAKE_OFF"
    else
        skin[variationComponentName] = accessory.variation
        skin[textureComponentName] = accessory.texture 
    end

    TriggerClientEvent("skinchanger:loadSkin", _source, skin)   
    MySQL.prepare("UPDATE `users` SET `skin` = ? WHERE `identifier` = ?", {
        json.encode(skin),
        xPlayer.identifier,
    }, function()
        local message = changeType == "TAKE_ON" and "Nasadil jste si doplněk - #%s" or "Sundal jste si doplněk - #%s"
        xPlayer.showNotification(message:format(accessoryId))
    end)
end)

lib.callback.register("strin_accessories:getAccessories", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if(not xPlayer) then
        return {}
    end
    return GetCharacterAccessories(xPlayer.identifier, xPlayer.get("char_id"))
end)

function AddCharacterAccessory(identifier, characterId, accessoryType, variation, texture)
    local column = GetAccessoryColumn(accessoryType)
    local accessories = GetCharacterAccessory(identifier, characterId, accessoryType)
    table.insert(accessories, {
        variation = variation,
        texture = texture,
    })
    MySQL.prepare(("UPDATE `character_accessories` SET `%s` = ? WHERE `identifier` = ? AND `char_id` = ?"):format(
        column
    ), {
        json.encode(accessories),
        identifier,
        characterId
    }, function() end)
end

exports("AddCharacterAccessory", AddCharacterAccessory)

function GetAccessoryTypes()
    local types = {}
    for accessory, _ in pairs(AccessoryShops) do
        types[#types + 1] = accessory:lower()
    end
    return types
end

exports("GetAccessoryTypes", GetAccessoryTypes)

function GetAccessoryFromChanges(changes)
    if(not next(changes)) then
        return nil
    end
    local allTypes = GetAccessoryTypes()
    local accessoryName, accessory = nil, {}
    for k,v in pairs(changes) do
        if(not v) then
            return nil
        end
        if(k:find("_1") or k == "arms") then
            accessoryName = k:gsub("_1", "")
            accessory.variation = tonumber(v)
        end
        if(k:find("_2")) then
            accessory.texture = tonumber(v)
        end
    end
    if(not accessory.texture) then
        accessory.texture = 0
    end
    if(
        not lib.table.contains(allTypes, accessoryName) or
        not accessoryName or
        not accessory.variation or
        not accessory.texture
    ) then
        return nil
    end
    return table.unpack({accessoryName:lower(), accessory})
end

function GetCharacterAccessory(identifier, characterId, accessoryType)
    return json.decode(MySQL.prepare.await(
        ("SELECT `%s` FROM character_accessories WHERE `identifier` = ? AND `char_id` = ?"):format(
            GetAccessoryColumn(accessoryType)
        )
    , {
        identifier,
        characterId
    }) or "{}")
end

function GetAccessoryColumn(accessoryType)
    return (accessoryType:lower()):sub(-1) == "s" and accessoryType:lower() or accessoryType:lower().."s"
end

exports("GetAccessoryColumn", GetAccessoryColumn)

local AccessoryColumns = {}
do
    for k,v in pairs(AccessoryShops) do
        table.insert(AccessoryColumns, "`"..GetAccessoryColumn(k).."`")
    end
end

function GetCharacterAccessories(identifier, characterId)
    return MySQL.prepare.await(
        ("SELECT %s FROM character_accessories WHERE `identifier` = ? AND `char_id` = ?"):format(table.concat(AccessoryColumns, ", "))
    ,{
        identifier,
        characterId
    }) or {}
end

exports("GetCharacterAccessories", GetCharacterAccessories)