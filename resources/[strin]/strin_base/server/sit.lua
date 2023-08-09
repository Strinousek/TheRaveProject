local OccupiedChairs = {}

AddEventHandler("strin_jobs:onPlayerDeath", function(identifier, deathData)
    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
    if(not xPlayer) then
        return
    end
    Citizen.Wait(2500)
    if(not OccupiedChairs[xPlayer.identifier]) then
        return
    end
    OccupiedChairs[xPlayer.identifier] = nil
end)

lib.callback.register('strin_base:sitOnChair', function(source, chairCoords)
    if(type(chairCoords) ~= "vector3") then
        return false
    end
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return false
    end
    if(OccupiedChairs[xPlayer.identifier]) then
        xPlayer.showNotification("Již sedíte na židli!", { type = "error" })
        return false
    end

    local chair = GetChair(chairCoords)
    if(chair) then
        xPlayer.showNotification("Na téhle židli už někdo sedí!", { type = "error" })
        return false
    end
    local distanceToChair = #(GetEntityCoords(GetPlayerPed(_source)) - chairCoords)
    if(distanceToChair > 3) then
        xPlayer.showNotification("Od této židle jste příliš daleko!", { type = "error" })
        return false
    end
	OccupiedChairs[xPlayer.identifier] = chairCoords
    return true
end)

RegisterNetEvent('strin_base:leaveChair', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    if(not OccupiedChairs[xPlayer.identifier]) then
        xPlayer.showNotification("Nesedíte na žádné židli!", { type = "error" })
        return
    end
	OccupiedChairs[xPlayer.identifier] = nil
end)

lib.callback.register("strin_base:getChair", function(source, chairCoords)
    return GetChair(chairCoords)
end)

function GetChair(chairCoords)
    local chair = nil
    for k,v in pairs(OccupiedChairs) do
        if(v) then
            if(lib.table.matches(v, chairCoords)) then
                chair = v
                break
            end
        end
    end
    return chair
end