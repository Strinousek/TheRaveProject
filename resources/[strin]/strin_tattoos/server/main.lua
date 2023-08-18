/*Citizen.CreateThread(function()
    for k,v in pairs(TattooList) do
        MySQL.query(([[
            ALTER TABLE `character_tattoos` ADD COLUMN `%s` LONGTEXT NULL
        ]]):format(
            k
        )
    )
    end

    local result = MySQL.query.await("SELECT `identifier`, `char_id` FROM characters")
    for _,v in pairs(result) do
        MySQL.insert.await("INSERT INTO character_tattoos SET `identifier` = ?, `char_id` = ?", {
            v.identifier,
            v.char_id
        })
    end
end)*/

/*ESX.RegisterCommand("tattoos", "user", function(xPlayer)
    TriggerClientEvent("strin_tattoos:updateTattoos", xPlayer.source,
    GetCharacterTattoos(xPlayer.identifier,
    xPlayer.get("char_id")))
end)*/

AddEventHandler("strin_characters:characterCreated", function(identifier, characterId)
    MySQL.prepare.await("INSERT INTO character_tattoos SET `identifier` = ?, `char_id` = ?", {
        identifier,
        characterId
    })
end)

AddEventHandler("strin_characters:characterDeleted", function(identifier, characterId)
    MySQL.prepare.await("DELETE FROM character_tattoos WHERE `identifier` = ? AND `char_id` = ?", {
        identifier,
        characterId
    })
end)

RegisterNetEvent("strin_tattoos:removeTattoos", function()
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

    local tattooShop = GetNearestTattooShop(_source)
    if(not tattooShop) then
        xPlayer.showNotification("Nejste poblíž žádného tatérství!", { type = "error" })
        return
    end

    local money = xPlayer.getMoney()
    if((money - TattoosRemovalPrice) < 0) then
        xPlayer.showNotification("Nemáte tolik peněz u sebe!", { type = "error" })
        return
    end
    MySQL.query.await(("UPDATE `character_tattoos` SET %s WHERE `identifier` = ? AND `char_id` = ?"):format(
        GenerateColumnsForTattooRemoval()
    ), {
        xPlayer.identifier,
        xPlayer.get("char_id")
    })
    xPlayer.removeMoney(TattoosRemovalPrice)
    xPlayer.showNotification("Odstranil/a jste si všechny tetování.")
    TriggerClientEvent("strin_tattoos:updateTattoos", _source)
end)

RegisterNetEvent("strin_tattoos:buyTattoos", function(tattoos)
    if(type(tattoos) ~= "table") then
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

    local tattooShop = GetNearestTattooShop(_source)
    if(not tattooShop) then
        xPlayer.showNotification("Nejste poblíž žádného tatérství!", { type = "error" })
        return
    end
    
    local validatedTattoos = ValidateTattoos(tattoos)
    if(not validatedTattoos) then
        xPlayer.showNotification("Neplatné tetování!", { type = "error" })
        return
    end
    local price = CalculatePriceFromTattoos(validatedTattoos)
    local money = xPlayer.getMoney()
    if((money - price) < 0) then
        xPlayer.showNotification("Nemáte tolik peněz u sebe!", { type = "error" })
        return
    end
    for k,v in pairs(validatedTattoos) do
        MySQL.update.await(("UPDATE character_tattoos SET `%s` = ? WHERE `identifier` = ? AND `char_id` = ?"):format(k), {
            json.encode(v),
            xPlayer.identifier,
            xPlayer.get("char_id")
        })
    end
    xPlayer.removeMoney(price)
    xPlayer.showNotification("Zakoupil/a jste si nové tetování.")
    TriggerClientEvent("strin_tattoos:updateTattoos", _source, validatedTattoos)
end)

lib.callback.register("strin_tattoos:getTattoos", function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return nil
    end
    return GetCharacterTattoos(xPlayer.identifier, xPlayer.get("char_id"))
end)

function GenerateColumnsForTattooSelect()
    local columns = {}
    for k,v in pairs(TattooList) do
        columns[#columns + 1] = "`"..k.."`"
    end
    return table.concat(columns, ",")
end

function GenerateColumnsForTattooRemoval()
    local columns = {}
    for k,v in pairs(TattooList) do
        columns[#columns + 1] = "`"..k.."` = NULL"
    end
    return table.concat(columns, ",")
end

function ValidateTattoos(tattoos)
    if(not tattoos or not next(tattoos)) then
        return nil
    end
    local validatedTattoos = {}
    for k,v in pairs(tattoos) do
        if(not TattooList[k]) then
            return nil
        end
        if(v and type(v) == "table" and next(v)) then
            local cleanTattoos = {}
            for i=1, #v do
                if(v[i]) then
                    if(type(v[i]) ~= "string") then
                        return nil
                    end
                    if(not IsTattooNameValid(k, v[i])) then
                        return nil
                    end
                    table.insert(cleanTattoos, v[i])
                end
            end
            validatedTattoos[k] = cleanTattoos
        end
    end
    return (next(validatedTattoos)) and validatedTattoos or nil
end

function IsTattooNameValid(category, name)
    local tattoos = TattooList[category]
    local isValid = false
    for i=1, #tattoos do
        if(tattoos[i].name == name) then
            isValid = true
            break
        end
    end
    return isValid
end

function CalculatePriceFromTattoos(tattoos)
    local count = 0
    for k,v in pairs(tattoos) do
        count += #v
    end
    local price = count * TattooPrice
    return price
end

function GetNearestTattooShop(playerId)
    local ped = GetPlayerPed(playerId)
    local coords = GetEntityCoords(ped)
    local tattooShop = nil
    local distanceToTattooShop = 15000.0
    for i=1, #TattooShops do
        local distance = #(coords - TattooShops[i])
        if(distance < distanceToTattooShop) then
            tattooShop = i
            distanceToTattooShop = distance
        end
    end
    return (distanceToTattooShop < 15) and tattooShop or nil
end

function GetCharacterTattoos(identifier, characterId)
    return MySQL.single.await(("SELECT %s FROM `character_tattoos` WHERE `identifier` = ? AND `char_id` = ?"):format(
        GenerateColumnsForTattooSelect()
    ), {
        identifier,
        characterId
    })
end