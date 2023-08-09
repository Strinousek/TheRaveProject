ESX.RegisterCommand("vtlacitkufr", "user", function(xPlayer)
	TriggerClientEvent('strin_base:forceTrunk', xPlayer.source)
end)

ESX.RegisterCommand("kufr", "user", function(xPlayer)
	TriggerClientEvent('strin_base:forceTrunkSelf', xPlayer.source)
end)

RegisterNetEvent('strin_base:requestForceTrunk', function(targetId)
    if(type(targetId) ~= "number" or not GetPlayerName(targetId)) then
        return
    end
    local _source = source
    local sourcePed = GetPlayerPed(_source)
    local sourceCoords = GetEntityCoords(sourcePed)
    local targetPed = GetPlayerPed(targetId)
    local targetCoords = GetEntityCoords(targetPed)
    local distance = #(sourceCoords - targetCoords)

    if(distance > 5) then
        TriggerClientEvent("esx:showNotification", _source, "Hráč je moc daleko!", { type = "error" })
        return
    end

	TriggerClientEvent('strin_base:forceTrunkSelf', targetId)
end)