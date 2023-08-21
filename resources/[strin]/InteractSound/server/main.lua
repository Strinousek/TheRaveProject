/*RegisterNetEvent('InteractSound_SV:PlayOnOne', function(clientNetId, soundFile, soundVolume)
    TriggerClientEvent('InteractSound_CL:PlayOnOne', clientNetId, soundFile, soundVolume)
end)*/

RegisterNetEvent('InteractSound_SV:PlayOnSource', function(soundFile, soundVolume)
    TriggerClientEvent('interactsound:playSound', source, soundFile, soundVolume)
end)

RegisterNetEvent("interactsound:playSound", function(soundFile, soundVolume)
    TriggerClientEvent('interactsound:playSound', source, soundFile, soundVolume)
end)

local Cooldowns = {}

function PlayWithinDistance(maxDistance, soundFile, soundVolume, coords)
    if(type(maxDistance) ~= "number" or type(soundFile) ~= "string") then
        return
    end
    if(maxDistance > 10) then
        maxDistance = 10
    end
    if(not soundVolume or type(soundVolume) ~= "number" or soundVolume > 1.0) then
        soundVolume = 1.0
    end
    local _source = tonumber(source)
    if(_source) then
        if(Cooldowns[_source]) then
            return
        end
        local ped = GetPlayerPed(_source)
        coords = GetEntityCoords(ped)
    end
    TriggerClientEvent('interactsound:playWithinDistance', -1, coords, maxDistance, soundFile, soundVolume)
    if(_source) then
        Cooldowns[_source] = true
        SetTimeout(1000, function()
            Cooldowns[_source] = nil
        end)
    end
end

RegisterNetEvent('InteractSound_SV:PlayWithinDistance', PlayWithinDistance)
RegisterNetEvent("interactsound:playWithinDistance", PlayWithinDistance)

