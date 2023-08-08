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

AddEventHandler("strin_characters:characterCreated", function(identifier, characterId)
    MySQL.insert.await("INSERT INTO character_accessories SET `identifier` = ?, `char_id` = ?", {
        identifier,
        characterId
    })
end)

AddEventHandler("strin_characters:characterDeleted", function(identifier, characterId)
    MySQL.query.await("DELETE FROM character_accessories WHERE `identifier` = ? AND `char_id` = ?", {
        identifier,
        characterId
    })
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
    MySQL.update.await(
        ("UPDATE character_accessories SET `%s` = ? WHERE `identifier` = ? AND `char_id` = ?"):format(
            GetAccessoryColumn(accessoryType)
        )
    , {
        json.encode(playerAccessories),
        xPlayer.identifier,
        xPlayer.get("char_id")
    })
    xPlayer.removeMoney(AccessoryPrice)
    xPlayer.showNotification("Zakoupil jste si nový doplněk!", {type = "success"})
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
    MySQL.update.await(
        ("UPDATE character_accessories SET `%s` = ? WHERE `identifier` = ? AND `char_id` = ?"):format(
            GetAccessoryColumn(accessoryType)
        )
    , {
        json.encode(newAccessories),
        xPlayer.identifier,
        xPlayer.get("char_id")
    })
    xPlayer.showNotification(("Odstranil jste doplněk - %s"):format(accessoryId), {type = "inform"})
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
        
    MySQL.update.await(
        ("UPDATE character_accessories SET `%s` = ? WHERE `identifier` = ? AND `char_id` = ?"):format(
            GetAccessoryColumn(accessoryType)
        )
    , {
        json.encode(newAccessories),
        xPlayer.identifier,
        xPlayer.get("char_id")
    })
    xPlayer.showNotification(("Přejmenoval jste doplněk - %s"):format(accessoryId), {type = "inform"})
end)

lib.callback.register("strin_accessories:getAccessories", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if(not xPlayer) then
        return {}
    end
    return GetCharacterAccessories(xPlayer.identifier, xPlayer.get("char_id"))
end)

function GetAccessoryTypes()
    local types = {}
    for accessory, _ in pairs(AccessoryShops) do
        types[#types + 1] = accessory:lower()
    end
    return types
end

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
    return json.decode(MySQL.scalar.await(
        ("SELECT `%s` FROM character_accessories WHERE `identifier` = ? AND `char_id` = ?"):format(
            GetAccessoryColumn(accessoryType)
        )
    , {
        identifier,
        characterId
    }) or "[]")
end

function GetCharacterAccessories(identifier, characterId)
    return MySQL.single.await(
        ("SELECT `masks`, `arms`, `glasses`, `helmets`, `bags`, `ears` FROM character_accessories WHERE `identifier` = ? AND `char_id` = ?")
    ,{
        identifier,
        characterId
    }) or {}
end

function GetAccessoryColumn(accessoryType)
    return (accessoryType:lower()):sub(-1) == "s" and accessoryType:lower() or accessoryType:lower().."s"
end