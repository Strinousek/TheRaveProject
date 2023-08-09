local StrinJobs = exports.strin_jobs

RegisterWebhook("AI_DOCTOR", "https://discord.com/api/webhooks/888878864284135434/_iNqkDmYxdg8YCM0JBS4LZMbBfARfW5lZmlNe_6m7gfC9Apae2Nx_7exjUSOkAgvwS4_")

RegisterNetEvent("strin_base:requestAIRevive", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    local ped = GetPlayerPed(_source)
    local health = GetEntityHealth(ped)

    if(health > 5.0) then
        xPlayer.showNotification("Nejste mrtev!", {type = "error"})
        return
    end

    local nearestAIDoctor = GetNearestAIDoctor(_source)
    if(not nearestAIDoctor) then
        xPlayer.showNotification("Nejsi poblíž žádného doktora!", {type = "error"})
        return
    end

    local medicsCount = CountMedicPlayers()
    if(medicsCount > 0) then
        xPlayer.showNotification("Na serveru jsou dostupní záchranáři!", {type = "error"})
        return
    end

    local success = StrinJobs:RevivePlayer(_source)
    DiscordLog("AI_DOCTOR", "THE RAVE PROJECT - AI DOCTOR", {
        (xPlayer.identifier.." | "..GetPlayerName(_source).." | #".._source),
        (xPlayer.identifier.." využil AI doktora.")
    })
    --print(xPlayer.getName().." | "..xPlayer.source.." VYUŽIL AI DOKTORA", xPlayer.getName().." | "..xPlayer.identifier.." | "..xPlayer.source.." využil AI doktora.")
end)

function GetNearestAIDoctor(playerId)
    local ped = GetPlayerPed(playerId)
    local coords = GetEntityCoords(ped)
    local doctor = nil
    local distanceToAIDoctor = 15000.0
    for k,v in pairs(AIDoctors) do
        local distance = #(coords - v.coords)
        if(distance < distanceToAIDoctor) then
            doctor = v
            distanceToAIDoctor = distance
        end
    end
    return (distanceToAIDoctor < 12.5) and doctor or nil
end

function CountMedicPlayers()
    local medics = ESX.GetExtendedPlayers("job", "ambulance")
    local fire = ESX.GetExtendedPlayers("job", "fire")
    return #medics + #fire
end