RegisterNetEvent("strin_base:tacklePlayer", function(playerId)
    if(type(playerId) ~= "number") then
        return
    end
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end
    
    local targetPlayer = ESX.GetPlayerFromId(playerId)
    if(not targetPlayer) then
        xPlayer.showNotification("Daný hráč neexistuje!", { type = "error" })
        return
    end

    local targetPed = GetPlayerPed(targetPlayer.source)
    local distance = #(GetEntityCoords(GetPlayerPed(xPlayer.source)) - GetEntityCoords(targetPed))
    if(distance > 10.0) then
        xPlayer.showNotification("Hráč není dostatečně blízko!", { type = "error" })
        return
    end

    if(GetEntityAttachedTo(targetPed) ~= 0) then
        xPlayer.showNotification("Tuhle osobu již někdo sráží k zemi!", { type = "error" })
        return
    end
    
    TriggerClientEvent("strin_base:tackle", _source)
    TriggerClientEvent("strin_base:getTackled", targetPlayer.source, _source)
end)