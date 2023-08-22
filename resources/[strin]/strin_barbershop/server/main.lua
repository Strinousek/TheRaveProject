local SkinChanger = exports.skinchanger
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

lib.callback.register("strin_barbershop:buyHaircut", function(source, haircut)
    if(type(haircut) ~= "table") then
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

    local barberShop = GetNearestBarberShop(_source)
    if(not barberShop) then
        xPlayer.showNotification("Nejste poblíž žádného kadeřnictví!", { type = "error" })
        return
    end

    local money = xPlayer.getMoney()
    if((money - BarberShopPrice) < 0) then
        xPlayer.showNotification("Nemáte dostatek peněz!", { type = "error" })
        return
    end

    local isValid, validatedHaircut = ValidateHaircut(haircut)
    if(not isValid) then
        xPlayer.showNotification("Sestřih není platný!", { type = "error" })
        return
    end

    local haircut = validatedHaircut

    if(not IsHaircutFull(haircut)) then
        local defaultHaircut = GetDefaultHaircut(_source)
        haircut = MergeHaircutValues(haircut, defaultHaircut)
    end

    local savedSkin = json.decode(MySQL.scalar.await("SELECT `skin` FROM `users` WHERE `identifier` = ?", { xPlayer.identifier }) or "{}")
    local mergedSkin = MergeSkinAndHaircut(savedSkin, haircut)
    MySQL.update.await("UPDATE `users` SET `skin` = ? WHERE `identifier` = ?", {
        json.encode(mergedSkin),
        xPlayer.identifier
    })
    TriggerClientEvent("skinchanger:loadSkin", _source, mergedSkin)
    xPlayer.removeMoney(BarberShopPrice)
    xPlayer.showNotification("Zakoupil/a jste si nový sestřih.")
    return true
end)

function ValidateHaircut(haircut)
    if(not haircut or not next(haircut))then
        return
    end
    local isValid, validatedHaircut = true, {}
    for k,v in pairs(haircut) do
        if(not lib.table.contains(BarberShopPieces, k) or not tonumber(v)) then
            isValid = false
            break
        end
        validatedHaircut[k] = tonumber(v)
    end

    return isValid, validatedHaircut
end

/*
function GetHaircutFromSkin(skin, playerId)
    local haircut = {}
    for k,v in pairs(skin) do
        if(lib.table.contains(BarberShopPieces, k)) then
            haircut[k] = tonumber(v)
        end
    end
    return haircut
end
*/

function IsHaircutFull(haircut)
    local isHaircutFull = true
    for k,v in pairs(BarberShopPieces) do
        if(not haircut[k]) then
            isHaircutFull = false
            break
        end
    end
    return isHaircutFull
end

function GetDefaultHaircut(playerId)
    local components = SkinChanger:GetComponents(playerId)
    local defaultHaircut = {}
    for i=1, #components do
        local component = components[i]
        if(lib.table.contains(BarberShopPieces, component.name)) then
            defaultHaircut[component.name] = tonumber(component.value)
        end
    end
    return defaultHaircut
end

function MergeHaircutValues(validatedHaircut, defaultHaircut)
    local validatedHaircut = validatedHaircut
    for k,v in pairs(defaultHaircut) do
        if(not validatedHaircut[k]) then
            validatedHaircut[k] = tonumber(v)
        end
    end
    return validatedHaircut
end

function MergeSkinAndHaircut(skin, haircut)
    local skin = skin
    for k,v in pairs(haircut) do
        skin[k] = v
    end
    return skin
end

function GetNearestBarberShop(playerId)
    local ped = GetPlayerPed(playerId)
    local coords = GetEntityCoords(ped)
    local barberShop = nil
    local distanceToBarberShop = 15000.0
    for i=1, #BarberShops do
        local distance = #(coords - BarberShops[i])
        if(distance < distanceToBarberShop) then
            barberShop = i
            distanceToBarberShop = distance
        end
    end
    return (distanceToBarberShop < 15) and barberShop or nil
end