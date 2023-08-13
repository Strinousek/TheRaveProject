local Base = exports.strin_base
local ResourceName = GetCurrentResourceName()
local CachedRaces = Base:LoadJSONFile(ResourceName, "server/races.json", "[]")
local CachedRaceTracks = Base:LoadJSONFile(ResourceName, "server/race_tracks.json", "[]")

local OngoingRaces = {}

lib.callback.register("strin_racing:getRaceTracks", function()
    return CachedRaceTracks
end)

lib.callback.register("strin_racing:getRaceTrack", function(raceTrackIndex)
    return CachedRaceTracks[raceTrackIndex]
end)

RegisterNetEvent("strin_racing:registerRaceTrack", function(raceTrackLabel, raceTrackPoints)
    if(type(raceTrackLabel) ~= "string" or type(raceTrackPoints) ~= "table") then
        return
    end
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    local label = ESX.SanitizeString(raceTrackLabel)
    if(label:len() == 0) then
        xPlayer.showNotification("Neplatný název závodu!", { type = "error" })
        return
    end

    local validatedRaceTrackPoints = ValidateRaceTrackPoints(raceTrackPoints)
    if(not validatedRaceTrackPoints) then
        xPlayer.showNotification("Neplatná jízda!", { type = "error" })
        return 
    end

    local raceTrackIndex = #CachedRaceTracks + 1
    CachedRaceTracks[raceTrackIndex] = {
        label = raceTrackLabel,
        points = raceTrackPoints
    }
    SaveResourceFile(ResourceName, "server/race_tracks.json", json.encode(CachedRaceTracks), -1)
    TriggerClientEvent("strin_racing:openRaceTrackMenu", _source, raceTrackIndex)
end)

RegisterNetEvent("strin_racing:initRace", function(raceTrackIndex, raceData)
    if(type(raceTrackIndex) ~= "number" or type(raceData) ~= "table") then
        return
    end
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end
    local raceId = GetPlayerActiveRaceId(_source)
    if(raceId) then
        xPlayer.showNotification("Jste v aktivním závodě, nelze vytvořit nový závod.")
        return
    end

    if(not CachedRaceTracks[raceTrackIndex]) then
        xPlayer.showNotification("Takový závod neexistuje!", { type = "error" })
        return
    end

    local validatedRaceData = ValidateRaceData(raceData)

    if(not validatedRaceData) then
        xPlayer.showNotification("Obdržené data jsou špatné!", { type = "error" })
        return
    end

    local newRaceId = #OngoingRaces + 1
    local raceData = {
        raceTrackIndex = raceTrackIndex,
        raceTrack = CachedRaceTracks[raceTrackIndex],
        state = "STARTING",
        coords = GetEntityCoords(GetPlayerPed(_source)) - vector3(0, 0, 1.0),
        laps = validatedRaceData.laps,
        automaticStart = validatedRaceData.automaticStart,
        maxPlayers = validatedRaceData.maxPlayers,
        players = {}
    }
    OngoingRaces[newRaceId] = raceData
    TriggerClientEvent("strin_racing:syncRaces", -1, OngoingRaces)
    SetTimeout(validatedRaceData.automaticStart * 1000 - 15000, function()
        for playerId, playerData in pairs(raceData.players) do
            TriggerClientEvent("esx:showNotification", playerId, [[
                Závod, ve kterém jste zapojen/a se spustí za 15 vteřin.<br/>
                Jděte se připravit na své pozice.
            ]])
        end
    end)
    SetTimeout(validatedRaceData.automaticStart * 1000, function()
        for playerId, playerData in pairs(raceData.players) do
            local ped = GetPlayerPed(playerId)
            local coords = GetEntityCoords(ped)
            if(#(coords - raceData.coords) > 30.0) then
                raceData.players[playerId] = nil
                goto skipLoop
            end
            local vehicle = GetVehiclePedIsIn(ped)
            if(vehicle == 0 or NetworkGetNetworkIdFromEntity(vehicle) ~= playerData.vehicleNetId) then
                raceData.players[playerId] = nil
                goto skipLoop
            end
            ::skipLoop::
        end
        if(#raceData.players == 0) then
            OngoingRaces[newRaceId] = nil
            TriggerClientEvent("strin_racing:syncRaces", -1, OngoingRaces)
            return
        end

        raceData.state = "STARTED"
        TriggerClientEvent("strin_racing:syncRaces", -1, OngoingRaces)
    end)
end)

RegisterNetEvent("strin_racing:joinRace", function(raceId)
    if(type(raceId) ~= "number") then
        return
    end

    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    local race = OngoingRaces[raceId]
    if(not race) then
        xPlayer.showNotification("Daný závod neexistuje!", { type = "error" })
        return
    end

    if(race.maxPlayers ~= 0 and (race.maxPlayers + 1) > race.maxPlayers) then
        xPlayer.showNotification("V závodě není místo!", { type = "error" })
        return
    end

    local ped = GetPlayerPed(_source)
    local vehicle = GetVehiclePedIsIn(ped)
    if(vehicle == 0) then
        xPlayer.showNotification("Nejste ve vozidle!", { type = "error" })
        return
    end

    local coords = GetEntityCoords(ped)
    if(#(coords - race.coords) > 20.0) then
        xPlayer.showNotification("Od závodu jste moc daleko!", { type = "error" })
        return
    end

    race.players[_source] = {
        lap = 1,
        point = 0,
        vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)
    }
    xPlayer.showNotification([[
        Připojil/a jste se do závodu. <br/>
        Těsně před začátkem závodu si nastupte do vozidla, s kterým jste se připojil/a.
        V případě nesplnění této podmínky budete odebrán automaticky.
    ]])
    TriggerClientEvent("strin_racing:syncRaces", -1, OngoingRaces)
end)

RegisterNetEvent("strin_racing:leaveRace", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    local race = nil

    for k,v in pairs(OngoingRaces) do
        if(v.players[_source]) then
            race = v
            break
        end
    end

    if(not race) then
        xPlayer.showNotification("Daný závod neexistuje!", { type = "error" })
        return
    end

    race.players[_source] = nil
    xPlayer.showNotification("Odpojil/a jste se ze závodu.")
    TriggerClientEvent("strin_racing:syncRaces", -1, OngoingRaces)
end)

AddEventHandler("playerDropped", function()
    local _source = source
    for k,v in pairs(OngoingRaces) do
        if(v.players[_source]) then
            v.players[_source] = nil
            break
        end
    end
end)

function ValidateRaceData(raceData)
    local data = {}
    for k,v in pairs(raceData) do
        if(type(v) == "number") then
            raceData[k] = math.floor(v)
        end
    end
    if(
        not raceData.max_players or 
        type(raceData.max_players) ~= "number" or
        raceData.max_players > 20 or 
        raceData.max_players < 0
    ) then
        return 
    end
    if(
        not raceData.laps or 
        type(raceData.laps) ~= "number" or 
        raceData.laps > 5 or 
        raceData.laps < 1
    ) then
        return 
    end
    data.maxPlayers = raceData.max_players
    data.automaticStart = raceData.automatic_start * 20
    data.laps = raceData.laps

    return next(data) and data or nil
end

function GetPlayerActiveRaceId(playerId)
    local raceId
    for k,v in pairs(OngoingRaces) do
        if(v.players[playerId]) then
            raceId = k
            break
        end
    end
    return raceId
end

function ValidateRaceTrackPoints(raceTrackPoints)
    local points = {}
    for k,v in pairs(raceTrackPoints) do
        if((not v.index or type(v.index) ~= "number") or (not v.coords or type(v.coords) ~= "vector3")) then
            points = {}
            break
        end
        points[v.index] = {
            index = v.index,
            coords = v.coords,
        }
    end

    return next(points) and points or nil
end