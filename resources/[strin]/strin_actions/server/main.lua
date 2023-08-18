Inventory = exports.ox_inventory

/*RegisterNetEvent("strin_actions:search", function(targetNetId, isTargetSurrending)
    local _source = source

    local targetPed = GetPlayerPed(targetNetId)
    if(not DoesEntityExist(targetPed)) then
        TriggerClientEvent("esx:showNotification", _source, "Cílová entita neexistuje.")
        return
    end

    local playerName = GetPlayerName(targetNetId)
    if(not playerName) then
        TriggerClientEvent("esx:showNotification", _source, "Hráč není online / neexistuje.", {type = "error"})
        return
    end

    if(not RestrainedPlayers[targetNetId] and not IsEntityDead(entity) and not isTargetSurrending) then
        TriggerClientEvent("esx:showNotification", _source, "Hráč nesplňuje požadavky pro prohledání.")
        return
    end

    if(not IsPlayerNearEntity(_source, targetPed, 10)) then
        TriggerClientEvent("esx:showNotification", _source, "Nejste dostatečně blízko hráči.", {type = "error"})
        return
    end

    Inventory:forceOpenInventory(_source, "player", targetNetId)
end)*/

RegisterNetEvent("strin_actions:drag", function(targetNetId)
    local _source = source

    local targetPlayer = ESX.GetPlayerFromId(targetNetId)

    if(not targetPlayer) then
        TriggerClientEvent("esx:showNotification", _source, "Hráč není online / neexistuje.", {type = "error"})
        return
    end

    local targetPed = GetPlayerPed(targetPlayer.source)
    if(not DoesEntityExist(targetPed)) then
        TriggerClientEvent("esx:showNotification", _source, "Cílová entita neexistuje.")
        return
    end

    if(not RestrainedPlayers[targetPlayer.identifier]) then
        TriggerClientEvent("esx:showNotification", _source, "Hráč nesplňuje požadavky pro táhnutí.")
        return
    end

    if(not IsPlayerNearEntity(_source, targetPed, 10)) then
        TriggerClientEvent("esx:showNotification", _source, "Nejste dostatečně blízko hráči.", {type = "error"})
        return
    end
    
    TriggerClientEvent("strin_base:executeCommand", _source, "me", "bere osobu za rameno a vede ji")
    TriggerClientEvent("strin_actions:drag", targetPlayer.source, _source)
end)

RegisterNetEvent("strin_actions:putInVehicle", function(targetNetId)
    local _source = source

    local targetPlayer = ESX.GetPlayerFromId(targetNetId)

    if(not targetPlayer) then
        TriggerClientEvent("esx:showNotification", _source, "Hráč není online / neexistuje.", {type = "error"})
        return
    end

    local targetPed = GetPlayerPed(targetPlayer.source)
    if(not DoesEntityExist(targetPed)) then
        TriggerClientEvent("esx:showNotification", _source, "Cílová entita neexistuje.")
        return
    end

    if(not RestrainedPlayers[targetPlayer.identifier]) then
        TriggerClientEvent("esx:showNotification", _source, "Hráč nesplňuje požadavky pro vložení do auta.")
        return
    end

    if(not IsPlayerNearEntity(_source, targetPed, 15)) then
        TriggerClientEvent("esx:showNotification", _source, "Nejste dostatečně blízko hráči.", {type = "error"})
        return
    end

    TriggerClientEvent("strin_base:executeCommand", _source, "me", "dává osobu do vozidla")

    TriggerClientEvent("strin_actions:putInVehicle", targetPlayer.source)
end)

RegisterNetEvent("strin_actions:putOutOfVehicle", function(targetNetId)
    local _source = source

    local targetPlayer = ESX.GetPlayerFromId(targetNetId)

    if(not targetPlayer) then
        TriggerClientEvent("esx:showNotification", _source, "Hráč není online / neexistuje.", {type = "error"})
        return
    end

    local targetPed = GetPlayerPed(targetPlayer.source)
    if(not DoesEntityExist(targetPed)) then
        TriggerClientEvent("esx:showNotification", _source, "Cílová entita neexistuje.")
        return
    end

    if(not RestrainedPlayers[targetPlayer.identifier]) then
        TriggerClientEvent("esx:showNotification", _source, "Hráč nesplňuje požadavky pro vyložení z auta.")
        return
    end

    if(not IsPlayerNearEntity(_source, targetPed, 15)) then
        TriggerClientEvent("esx:showNotification", _source, "Nejste dostatečně blízko hráči.", {type = "error"})
        return
    end

    TriggerClientEvent("strin_base:executeCommand", _source, "me", "vytahuje osobu z vozidla")
    TriggerClientEvent("strin_actions:putOutOfVehicle", targetPlayer.source)
end)

function IsPlayerNearEntity(playerId, entity, requiredDistance)
    local playerPed = GetPlayerPed(playerId)
    local playerCoords = GetEntityCoords(playerPed)
    local targetCoords = GetEntityCoords(entity)
    local distance = #(playerCoords - targetCoords)
    return distance <= requiredDistance
end