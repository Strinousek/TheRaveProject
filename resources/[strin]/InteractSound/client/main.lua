

local standardVolumeOutput = 1.0;

RegisterNetEvent('interactsound:playSound', function(soundFile, soundVolume)
    SendNUIMessage({
        transactionType     = 'playSound',
        transactionFile     = soundFile,
        transactionVolume   = soundVolume
    })
end)

RegisterNetEvent('interactsound:playWithinDistance')
AddEventHandler('interactsound:playWithinDistance', function(placeCoords, maxDistance, soundFile, soundVolume)
    local coords = GetEntityCoords(PlayerPedId())
    local distance = #(coords - placeCoords)
    if(distance <= maxDistance) then
        SendNUIMessage({
            transactionType     = 'playSound',
            transactionFile     = soundFile,
            transactionVolume   = soundVolume
        })
    end
end)
