AddEventHandler("strin_characters:characterDeleted", function(identifier, characterId)
    MySQL.query.await("DELETE FROM character_outfits WHERE `identifier` = ? AND `char_id` = ?", {
        identifier,
        characterId
    })
end)

RegisterNetEvent("strin_clotheshop:buyOutfit", function(outfit)
    if(type(outfit) ~= "table") then
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

    if((xPlayer.getMoney() - OutfitPrice) < 0) then
        xPlayer.showNotification("Nemáte u sebe dostatek peněz!", { type = "error" })
        return
    end

    local cloakroom = GetNearestCloakroom(_source)
    if(not cloakroom or not cloakroom?.includeShop) then
        xPlayer.showNotification("Nejste poblíž žádnému obchodu!", { type = "error" })
        return
    end

    local isOutfitValid, validatedOutfit = ValidateOutfit(outfit)
    if(not isOutfitValid) then
        xPlayer.showNotification("Outfit je neplatný!", { type = "error" })
        return
    end
    MySQL.insert.await("INSERT INTO character_outfits SET `identifier` = ?, `char_id` = ?, `outfit` = ?", {
        xPlayer.identifier,
        xPlayer.get("char_id"),
        json.encode(validatedOutfit)
    })
    xPlayer.removeMoney(OutfitPrice)
    xPlayer.showNotification("Zakoupil/a jste si nový outfit!", { type = "success" })
end)

RegisterNetEvent("strin_clotheshop:deleteOutfit", function(outfitId)
    if(type(outfitId) ~= "number") then
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

    local cloakroom = GetNearestCloakroom(_source)
    if(not cloakroom) then
        local isNearAPropertyWardrobe = IsPlayerNearAPropertyWardrobe(_source)
        if(not isNearAPropertyWardrobe) then
            xPlayer.showNotification("Nejste poblíž žádnému obchodu!", { type = "error" })
            return
        end
        xPlayer.showNotification("Nejste poblíž žádnému obchodu!", { type = "error" })
        return
    end
    MySQL.query.await("DELETE FROM character_outfits WHERE `identifier` = ? AND `char_id` = ? AND `id` = ?", {
        xPlayer.identifier,
        xPlayer.get("char_id"),
        outfitId
    })
    xPlayer.showNotification(("Odstranil/a jste outfit ze své šatny."), { type = "inform" })
end)

RegisterNetEvent("strin_clotheshop:renameOutfit", function(outfitId, outfitLabel)
    if(type(outfitId) ~= "number" and type(outfitLabel) ~= "string") then
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

    local cloakroom = GetNearestCloakroom(_source)
    if(not cloakroom) then
        local isNearAPropertyWardrobe = IsPlayerNearAPropertyWardrobe(_source)
        if(not isNearAPropertyWardrobe) then
            xPlayer.showNotification("Nejste poblíž žádnému obchodu!", { type = "error" })
            return
        end
        xPlayer.showNotification("Nejste poblíž žádnému obchodu!", { type = "error" })
        return
    end

    MySQL.update.await("UPDATE character_outfits SET `label` = ? WHERE `identifier` = ? AND `char_id` = ? AND `id` = ?", {
        string.len(outfitLabel) <= 0 and nil or ESX.SanitizeString(outfitLabel),
        xPlayer.identifier,
        xPlayer.get("char_id"),
        outfitId
    })
    xPlayer.showNotification(("Přejmenoval/a jste outfit ze své šatny."), { type = "inform" })
end)

RegisterNetEvent("strin_clotheshop:wearOutfit", function(outfitId)
    if(type(outfitId) ~= "number") then
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

    local cloakroom = GetNearestCloakroom(_source)
    if(not cloakroom) then
        local isNearAPropertyWardrobe = IsPlayerNearAPropertyWardrobe(_source)
        if(not isNearAPropertyWardrobe) then
            xPlayer.showNotification("Nejste poblíž žádnému obchodu!", { type = "error" })
            return
        end
    end
    
    local skin = exports.skinchanger:GetSkin(_source)

    if(not skin or not next(skin)) then
        xPlayer.showNotification("Hráč nemá skin?", { type = "error" })
        return
    end

    local outfitData = GetCharacterOutfit(xPlayer.identifier, xPlayer.get("char_id"), outfitId)
    if(not outfitData or not next(outfitData)) then
        xPlayer.showNotification("Takový outfit nevlastníte!", { type = "error" })
        return
    end

    local outfit = json.decode(outfitData.outfit)
    for k,v in pairs(outfit) do
        skin[k] = v
    end

    TriggerClientEvent("skinchanger:loadSkin", _source, skin)

    MySQL.update.await("UPDATE users SET `skin` = ? WHERE `identifier` = ?", {
        json.encode(skin),
        xPlayer.identifier
    })
    xPlayer.showNotification("Převlékl/a jste se.", { type = "inform" })
end)

lib.callback.register("strin_clotheshop:getOutfits", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if(not xPlayer) then
        return {}
    end
    return GetCharacterOutfits(xPlayer.identifier, xPlayer.get("char_id"))
end)

function ValidateOutfit(outfit)
    if(not outfit or not next(outfit))then
        return
    end
    local isValid, validatedOutfit = true, {}
    for k,v in pairs(outfit) do
        if(not lib.table.contains(ClotheShopPieces, k) or not tonumber(v)) then
            isValid = false
            break
        end
        validatedOutfit[k] = tonumber(v)
    end

    if(next(validatedOutfit)) then
        for k,v in pairs(validatedOutfit) do
            if(k:find("_1") or k == "arms") then
                local clothePiece = k:find("_1") and k:gsub("_1", "") or "arms"
                if(not validatedOutfit[clothePiece.."_2"]) then
                    validatedOutfit[clothePiece.."_2"] = 0
                end
            end
        end
    end

    return isValid, validatedOutfit
end

function GetCharacterOutfit(identifier, characterId, outfitId)
    return MySQL.single.await(
        ("SELECT * FROM character_outfits WHERE `identifier` = ? AND `char_id` = ? AND `id` = ?")
    , {
        identifier,
        characterId,
        outfitId
    }) or {}
end

function GetCharacterOutfits(identifier, characterId)
    return MySQL.query.await(
        ("SELECT `id`, `outfit`, `label` FROM character_outfits WHERE `identifier` = ? AND `char_id` = ?")
    ,{
        identifier,
        characterId
    }) or {}
end

function GetNearestCloakroom(playerId)
    local ped = GetPlayerPed(playerId)
    local coords = GetEntityCoords(ped)
    local cloakroom = nil
    local distanceToCloakroom = 15000.0
    for _,v in pairs(Cloakrooms) do
        local distance = #(coords - v.coords)
        if(distance < distanceToCloakroom) then
            cloakroom = v
            distanceToCloakroom = distance
        end
    end
    return (distanceToCloakroom < 15) and cloakroom or nil 
end

function IsPlayerNearAPropertyWardrobe(playerId)
    local properties = exports.esx_property:GetOwnedProperties()
    local isNearAPropertyWardrobe = false
    if(next(properties)) then
        local ped = GetPlayerPed(playerId)
        local coords = GetEntityCoords(ped)
        for _,v in pairs(properties) do
            if(v.positions?.Wardrobe) then
                local wardrobeCoordsObject = v.positions?.Wardrobe
                local wardrobeCoordsVector = vector3(wardrobeCoordsObject.x, wardrobeCoordsObject.y, wardrobeCoordsObject.z)
                local distance = #(coords - wardrobeCoordsVector)
                if(distance < 5) then
                    isNearAPropertyWardrobe = true
                    break
                end
            end
        end
    end
    return isNearAPropertyWardrobe
end