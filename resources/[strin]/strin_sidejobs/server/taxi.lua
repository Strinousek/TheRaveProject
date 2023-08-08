local SideJobModuleName = "taxi"
local _ActiveTaxis = {}

ActiveTaxis = GenerateSideJobModule(SideJobModuleName, _ActiveTaxis, function(xPlayer)
    local _source = xPlayer.source
    local ped = GetPlayerPed(_source)
    local vehicle = GetVehiclePedIsIn(ped)
    if(vehicle == 0) then
        xPlayer.showNotification("Nejste ve vozidle!", { type = "error" })
        return
    end

    if(GetEntityModel(vehicle) ~= `taxi`) then
        xPlayer.showNotification("Nejste ve taxi vozidle!", { type = "error" })
        return
    end

    if(WorkingPlayers[_source]) then
        xPlayer.showNotification("Již provádíte jinou práci!", { type = "error" })
        return
    end

    ActiveTaxis[_source] = GenerateTaxiService()
    TriggerClientEvent("strin_sidejobs:initClient", _source, ActiveTaxis[_source])
    xPlayer.showNotification("Zákazník na Vás čeká.")
end, function(xPlayer)
    local _source = xPlayer.source
    local activeTaxi = ActiveTaxis[_source]
    if(not activeTaxi) then
        xPlayer.showNotification("Nejste zaregistrován/a v taxi službě!", { type = "error" })
        return
    end
    local entity = NetworkGetEntityFromNetworkId(activeTaxi.client.netId)
    DeleteEntity(entity)
    ActiveTaxis[_source] = nil
    TriggerClientEvent("strin_sidejobs:resetTaxiModule", _source)
    xPlayer.showNotification("Odhlásil jste se z taxi služby.")
end)

RegisterNetEvent("strin_sidejobs:takeInClient", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end
    local ped = GetPlayerPed(_source)
    local vehicle = GetVehiclePedIsIn(ped)
    if(vehicle == 0) then
        xPlayer.showNotification("Nejste ve vozidle!", { type = "error" })
        return
    end

    if(GetEntitySpeed(vehicle) > 0) then
        xPlayer.showNotification("Musíte vozidlo zastavit!", { type = "error" })
        return
    end

    if(GetEntityModel(vehicle) ~= `taxi`) then
        xPlayer.showNotification("Nejste ve taxi vozidle!", { type = "error" })
        return
    end

    local activeTaxi = ActiveTaxis[_source]
    if(not activeTaxi) then
        xPlayer.showNotification("Nejste zaregistrován/a v taxi službě!", { type = "error" })
        return
    end

    if(not IsPlayerNearCoords(_source, activeTaxi.destination.start.coords, 15.0)) then
        xPlayer.showNotification("Nejste dostatečné blízko!", { type = "error" })
        return
    end

    if(activeTaxi.seatIndex) then
        xPlayer.showNotification("Zákazník již je ve vozidle!", { type = "error" })
        return
    end

    local freeSeat = GetFreeVehicleSeat(vehicle)
    if(not freeSeat) then
        xPlayer.showNotification("Nejste zaregistrován/a v taxi službě!", { type = "error" })
        return
    end

    FreezeEntityPosition(entity, false)
    activeTaxi.seatIndex = freeSeat
    local entity = NetworkGetEntityFromNetworkId(activeTaxi.client.netId)
    TaskWarpPedIntoVehicle(entity, vehicle, freeSeat)
    TriggerClientEvent("strin_sidejobs:initDestination", _source, activeTaxi)
end)

RegisterNetEvent("strin_sidejobs:dropOffClient", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end
    local ped = GetPlayerPed(_source)
    local vehicle = GetVehiclePedIsIn(ped)
    if(vehicle == 0) then
        xPlayer.showNotification("Nejste ve vozidle!", { type = "error" })
        return
    end

    if(GetEntitySpeed(vehicle) > 0) then
        xPlayer.showNotification("Musíte vozidlo zastavit!", { type = "error" })
        return
    end

    if(GetEntityModel(vehicle) ~= `taxi`) then
        xPlayer.showNotification("Nejste ve taxi vozidle!", { type = "error" })
        return
    end

    local activeTaxi = ActiveTaxis[_source]
    if(not activeTaxi) then
        xPlayer.showNotification("Nejste zaregistrován/a v taxi službě!", { type = "error" })
        return
    end

    if(not IsPlayerNearCoords(_source, activeTaxi.destination.finish.coords, 15.0)) then
        xPlayer.showNotification("Nejste dostatečné blízko!", { type = "error" })
        return
    end

    if(not activeTaxi.seatIndex) then
        xPlayer.showNotification("Zákazník není ve vozidle!", { type = "error" })
        return
    end

    local client = GetPedInVehicleSeat(vehicle, activeTaxi.seatIndex)
    if(client == 0) then
        xPlayer.showNotification("Zákazník není ve vozidle! Ruším jízdu!", { type = "error" })
        ActiveTaxis[_source] = nil
        return
    end

    local entity = NetworkGetEntityFromNetworkId(activeTaxi.client.netId)
    local distance = #(activeTaxi.destination.start.coords - activeTaxi.destination.finish.coords)

    local finishTime = os.time() - activeTaxi.startedOn 
    
    if(finishTime < 20) then
        xPlayer.showNotification("Jízda byla moc rychlá! Vyčkejte.", { type = "error" })
        return
    end

    local payout = math.floor(distance * TAXI_DISTANCE_MULTIPLIER)
    xPlayer.showNotification(("Zákazník Vám vyplatil %s$"):format(ESX.Math.GroupDigits(payout)), { type = "success" })
    xPlayer.addMoney(payout)

    Base:DiscordLog("DEFAULT", "THE RAVE PROJECT - SIDE JOBS", {
        { name = "Typ", value = SideJobModuleName },
        { name = "Hráč", value = ("#%s - %s - %s"):format(_source, xPlayer.getName(), xPlayer.identifier) },
        { name = "Výplata", value = ("%s$"):format(ESX.Math.GroupDigits(payout)) },
        { name = "Délka úseku", value = ("%s"):format(math.floor(distance)) },
        { name = "Čas", value = ("%ss"):format(finishTime) },
    }, {
        fields = true
    })

    DeleteEntity(entity)
    ActiveTaxis[_source] = nil
    TriggerClientEvent("strin_sidejobs:resetTaxiModule", _source)
    
    ActiveTaxis[_source] = GenerateTaxiService()
    TriggerClientEvent("strin_sidejobs:initClient", _source, ActiveTaxis[_source])
    xPlayer.showNotification("Zákazník na Vás čeká.")
end)

function GenerateTaxiService()
    math.randomseed(GetGameTimer())
    local destinationIndex = math.random(1, #TAXI_CLIENT_DESTINATIONS)
    local destination = TAXI_CLIENT_DESTINATIONS[destinationIndex]
    local clientModelIndex = math.random(1, #TAXI_CLIENT_MODELS)
    local clientModel = TAXI_CLIENT_MODELS[clientModelIndex]
    return {
        destination = destination, 
        client = {
            model = clientModel,
            seatIndex = nil,
            netId = CreateClientPed(clientModel, destination.start.coords, destination.start.heading),
        },
        startedOn = os.time(),
        --finishedOn = os.time(),
    }
end

function CreateClientPed(model, coords, heading)
    local entity = CreatePed(0, model, coords, heading, true, true)
    SetPedDefaultComponentVariation(entity)
    FreezeEntityPosition(entity, true)
    return NetworkGetNetworkIdFromEntity(entity)
end

function GetFreeVehicleSeat(vehicle)
    local freeSeat = nil
    for i=0, 3 do
        if(GetPedInVehicleSeat(vehicle, i) == 0) then
            freeSeat = i
            break
        end
    end
    return freeSeat
end

function IsPlayerNearCoords(playerId, coords, distance)
    local ped = GetPlayerPed(playerId)
    local pedCoords = GetEntityCoords(ped)
    local distanceToCoords = #(pedCoords - coords)
    return distanceToCoords < distance
end

AddEventHandler("entityRemoved", function(entity)
    local netId = NetworkGetNetworkIdFromEntity(entity)
    for k,v in pairs(ActiveTaxis) do
        if(v.client.netId == netId) then
            ActiveTaxis[k] = nil
            TriggerClientEvent("strin_sidejobs:resetTaxiModule", k) 
        end
    end
end)

AddEventHandler("strin_jobs:onPlayerDeath", function(_, deathData)
    for k,v in pairs(ActiveTaxis) do
        if(k == deathData.victimId and v.client.netId) then
            local entity = NetworkGetEntityFromNetworkId(v.client.netId)
            DeleteEntity(entity)
            ActiveTaxis[k] = nil
            TriggerClientEvent("strin_sidejobs:resetTaxiModule", k) 
        end
    end
end)

AddEventHandler("playerDropped", function()
    local _source = source
    for k,v in pairs(ActiveTaxis) do
        if(k == _source and v.client.netId) then
            local entity = NetworkGetEntityFromNetworkId(v.client.netId)
            DeleteEntity(entity)
            ActiveTaxis[_source] = nil
        end
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        for k,v in pairs(ActiveTaxis) do
            local entity = NetworkGetEntityFromNetworkId(v.client.netId)
            DeleteEntity(entity)
            TriggerClientEvent("strin_sidejobs:resetTaxiModule", k) 
        end
    end
end)