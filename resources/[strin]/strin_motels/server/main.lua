local RoutingBucketId = 65335
local Rooms = {}

do
    for k,v in pairs(MOTELS) do
        Rooms[k] = {}
        for i=1, #v.Rooms do
            Rooms[k][i] = {
                bucketId = RoutingBucketId + 1,
                players = {}
            }
            SetRoutingBucketEntityLockdownMode(RoutingBucketId + 1, "strict")
            RoutingBucketId += 1 
        end
    end
end

RegisterNetEvent("strin_motels:enterRoom", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    local motelIndex, roomIndex = GetNearestMotelIndexAndRoomIndex(_source)
    if(not motelIndex or roomIndex == -1) then
        return
    end

    local room = Rooms[motelIndex][roomIndex]
    SetPlayerRoutingBucket(_source, room.bucketId)
    room.players[_source] = true
    TriggerClientEvent("strin_motels:teleportToRoom", _source, motelIndex, roomIndex)
end)

lib.callback.register("strin_motels:canTeleport", function(source)
    local _source = source
    local canTeleport = false
    for k,v in pairs(Rooms) do
        for i=1, #v do
            local room = v[i]
            if(room.players[_source]) then
                canTeleport = true
                break
            end
        end
    end
    return canTeleport
end)

RegisterNetEvent("strin_motels:exitRoom", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    local motelIndex, roomIndex = GetNearestMotelIndexAndRoomIndex(_source)
    if(not motelIndex or roomIndex ~= -1) then
        return
    end

    for k,v in pairs(Rooms[motelIndex]) do
        if(v.players[_source]) then
            roomIndex = k
            v.players[_source] = nil
            break
        end
    end
    SetPlayerRoutingBucket(_source, 0)
    SetEntityCoords(
        GetPlayerPed(_source),
        (roomIndex ~= -1) and MOTELS[motelIndex].Rooms[roomIndex] or MOTELS[motelIndex].Blip.coords
    )
end)

AddEventHandler("playerDropped", function()
    local _source = source
    for k,v in pairs(Rooms) do
        for i=1, #v do
            local room = v[i]
            if(room.players[_source]) then
                room.players[_source] = nil
                break
            end
        end
    end
end)

function GetNearestMotelIndexAndRoomIndex(playerId)
    local ped = GetPlayerPed(playerId)
    local coords = GetEntityCoords(ped)
    local distanceToRoom = 15000.0

    local motelIndex, roomIndex
    for k,v in pairs(MOTELS) do
        for i=1, #v.Rooms do
            local distance = #(coords - v.Rooms[i])
            if(distance < distanceToRoom) then
                motelIndex = k
                roomIndex = i
                distanceToRoom = distance
            end
        end
        local distanceToExit = #(coords - v.RoomDefaults.exit)
        if(distanceToExit < 20) then
            motelIndex = k
            roomIndex = -1
            distanceToRoom = distanceToExit
            break
        end
    end

    if(distanceToRoom < 20) then
        return motelIndex, roomIndex
    end

    return nil, nil
end

exports("IsPlayerInMotelRoom", function(playerId)
    local motelIndex, roomIndex = GetNearestMotelIndexAndRoomIndex(playerId)
    return motelIndex and (roomIndex == -1)
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 5000
        for k,v in pairs(Rooms) do
            for i=1, #v do
                local room = v[i]
                if(#(room.players) > 0) then
                    for playerId,_ in pairs(room.players) do
                        local ped = GetPlayerPed(playerId)
                        local coords = GetEntityCoords(ped)
                        local distance = #(coords - MOTELS[k].RoomDefaults.exit)
                        if(distance > 20) then
                            SetEntityCoords(ped, MOTELS[k].RoomDefaults.exit)
                        end
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)