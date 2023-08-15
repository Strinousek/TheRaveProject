Inventory = exports.ox_inventory
RestrainedPlayers = {}

AddEventHandler("esx:playerLoaded", function(playerId, xPlayer)
    local _source = playerId
    if(RestrainedPlayers[xPlayer.identifier]) then
        TriggerClientEvent("strin_actions:restrain", playerId)
    end
end)

lib.callback.register("strin_actions:restrain", function(...)
    return RestrainPlayer(...)
end)

lib.callback.register("strin_actions:unrestrain", function(...)
    return UnrestrainPlayer(...)
end)

AddEventHandler("strin_actions:restrain", function(identifier, itemName)
    if(RestrainedPlayers[identifier]) then
        return
    end
    local targetNetId = ESX.GetPlayerFromIdentifier(identifier)?.source
    if(not targetNetId) then
        return
    end
    RestrainedPlayers[identifier] = {
        type = itemName
    }
    TriggerClientEvent("strin_actions:restrain", targetNetId)
    TriggerEvent("strin_actions:playerRestrained", targetNetId, RestrainedPlayers[identifier], nil)
end)

AddEventHandler("strin_actions:unrestrain", function(identifier)
    if(not RestrainedPlayers[identifier]) then
        return
    end
    local targetNetId = ESX.GetPlayerFromIdentifier(identifier)?.source
    if(not targetNetId) then
        return
    end
    local restrainType = RestrainedPlayers[identifier].type
    RestrainedPlayers[identifier] = nil
    TriggerClientEvent("strin_actions:unrestrain", targetNetId)
    TriggerEvent("strin_actions:playerUnrestrained", targetNetId, {
        type = restrainType,
    }, nil)
end)

function RestrainPlayer(source, targetNetId, itemName, restrainType)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end
    if(restrainType ~= "default" and restrainType ~= "aggressive") then
        return false
    end
    if(itemName ~= "zipties" and itemName ~= "handcuffs") then
        TriggerClientEvent("esx:showNotification", _source, "Nevhodný předmět na omezení pohybu.", {type = "error"})
        return false
    end
    
    local targetPlayer = ESX.GetPlayerFromId(targetNetId)
    if(not targetPlayer) then
        TriggerClientEvent("esx:showNotification", _source, "Hráč není online / neexistuje.", {type = "error"})
        return false
    end

    local targetNetId = targetPlayer.source

    local entity = GetPlayerPed(targetNetId)
    if(not DoesEntityExist(entity)) then
        TriggerClientEvent("esx:showNotification", _source, "Cílová entita neexistuje.", {type = "error"})
        return false
    end

    if(GetEntityAttachedTo(entity) ~= 0) then
        TriggerClientEvent("esx:showNotification", _source, "Hráče již někdo táhne, a proto nemůžete ho osvobodit.", {type = "error"})
        return false
    end

    if(Inventory:GetItemCount(_source, itemName) <= 0) then
        TriggerClientEvent("esx:showNotification", _source, "Nemáte dostatečný počet předmětu.", {type = "error"})
        return false
    end

    if(not IsPlayerNearEntity(_source, entity, 10.0)) then
        TriggerClientEvent("esx:showNotification", _source, "Nejste dostatečně blízko hráči.", {type = "error"})
        return false
    end

    if(RestrainedPlayers[targetPlayer.identifier]) then
        TriggerClientEvent("esx:showNotification", _source, "Hráč již omezen je.", {type = "error"})
        return false
    end

    Inventory:RemoveItem(_source, itemName, 1)
    RestrainedPlayers[targetPlayer.identifier] = {
        type = itemName
    }

    TriggerEvent("strin_actions:playerRestrained", targetNetId, RestrainedPlayers[targetPlayer.identifier], _source)
    if(restrainType == "aggressive") then
        TriggerClientEvent("strin_actions:arrest", _source, "aggressive")
        TriggerClientEvent("strin_actions:getAggressivelyArrested", targetNetId, _source)
        TriggerClientEvent("strin_actions:restrain", targetNetId)
        return true, itemName
    end

    TriggerClientEvent("strin_actions:arrest", _source, "default")
    TriggerClientEvent("strin_actions:restrain", targetNetId)
    return true, itemName
end

function UnrestrainPlayer(source, targetNetId)
    local _source = source
    
    if(_source == targetNetId) then
        TriggerClientEvent("esx:showNotification", _source, "Nemůžete osvobodit sám sebe.", {type = "error"})
        return false
    end
    
    local targetPlayer = ESX.GetPlayerFromId(targetNetId)
    if(not targetPlayer) then
        TriggerClientEvent("esx:showNotification", _source, "Hráč není online / neexistuje.", {type = "error"})
        return false
    end

    local targetNetId = targetPlayer.source

    local entity = GetPlayerPed(targetNetId)
    if(not DoesEntityExist(entity)) then
        TriggerClientEvent("esx:showNotification", _source, "Cílová entita neexistuje.", {type = "error"})
        return false
    end

    if(not RestrainedPlayers[targetPlayer.identifier]) then
        TriggerClientEvent("esx:showNotification", _source, "Hráč není omezen.", {type = "error"})
        return false
    end

    if(not IsPlayerNearEntity(_source, entity, 10.0)) then
        TriggerClientEvent("esx:showNotification", _source, "Nejste dostatečně blízko hráči.", {type = "error"})
        return false
    end

    local restrainedPlayer = RestrainedPlayers[targetPlayer.identifier]
    if(restrainedPlayer.type == "handcuffs") then
        local xPlayer = ESX.GetPlayerFromId(_source)
        if(not xPlayer) then
            return false
        end
        if(xPlayer.getJob()?.name ~= "police") then
            TriggerClientEvent("esx:showNotification", _source, "K poutům nemáte klíče.", {type = "error"})
            return false
        end
        
        xPlayer.addInventoryItem(restrainedPlayer.type, 1)
        RestrainedPlayers[targetPlayer.identifier] = nil
        TriggerClientEvent("strin_actions:unrestrain", targetNetId)
        TriggerEvent("strin_actions:playerUnrestrained", targetNetId, {
            type = "handcuffs"
        }, _source)
        return true, "handcuffs"
    end
    RestrainedPlayers[targetPlayer.identifier] = nil
    TriggerEvent("strin_actions:playerUnrestrained", targetNetId, {
        type = "zipties"
    }, _source)
    TriggerClientEvent("strin_actions:unrestrain", targetNetId)
    return true, "zipties"
end