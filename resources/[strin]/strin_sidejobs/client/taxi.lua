local ClientBlip = nil
local ClientPoint = nil

local DestinationBlip = nil
local DestinationPoint = nil

Citizen.CreateThread(function()
    AddTextEntry("STRIN_SIDEJOBS:TAXI_CLIENT", "<FONT FACE='Righteous'>~g~<b>[E]</b>~s~ Přivolat zákazníka")
    AddTextEntry("STRIN_SIDEJOBS:TAXI_DROPOFF", "<FONT FACE='Righteous'>~g~<b>[E]</b>~s~ Vysadit zákazníka")
end)

RegisterNetEvent("strin_sidejobs:resetTaxiModule", function()
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end

    if(ClientBlip) then
        RemoveBlip(ClientBlip)
        ClientBlip = nil
    end

    if(ClientPoint) then
        ClientPoint:remove()
        ClientPoint = nil
    end

    if(DestinationBlip) then
        RemoveBlip(DestinationBlip)
        DestinationBlip = nil
    end

    if(DestinationPoint) then
        DestinationPoint:remove()
        DestinationPoint = nil
    end
end)

RegisterNetEvent("strin_sidejobs:initClient", function(data)
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end
    
    local clientNetId = data.client.netId
    local coords = data.destination.start.coords

    SetNewWaypoint(coords.x, coords.y)
    ClientBlip = CreateClientBlip(coords, true)
    ClientPoint = lib.points.new({
        coords = coords,
        distance = 10,
    })

    function ClientPoint:onEnter()
        if(NetworkDoesEntityExistWithNetworkId(clientNetId)) then
            local entity = NetworkGetEntityFromNetworkId(clientNetId)
            RemoveBlip(ClientBlip)
            ClientBlip = CreateClientBlip(coords, false, entity)
        end
    end

    function ClientPoint:onExit()
        if(not NetworkDoesEntityExistWithNetworkId(clientNetId)) then
            RemoveBlip(ClientBlip)
            ClientBlip = CreateClientBlip(coords, true)
        end
        if(NetworkDoesEntityExistWithNetworkId(clientNetId)) then
            local entity = NetworkGetEntityFromNetworkId(clientNetId)
            if(IsPedInAnyVehicle(entity)) then
                ClientPoint:remove()
                ClientPoint = nil
            end
        end
    end

    function ClientPoint:nearby()
        if(NetworkDoesEntityExistWithNetworkId(clientNetId)) then
            local entity = NetworkGetEntityFromNetworkId(clientNetId)
            if(not IsPedInAnyVehicle(entity)) then

                DisplayHelpTextThisFrame("STRIN_SIDEJOBS:TAXI_CLIENT")
                if(IsControlJustReleased(0, 38)) then
                    TriggerServerEvent("strin_sidejobs:takeInClient")
                end
            end
        end
    end
end)

RegisterNetEvent("strin_sidejobs:initDestination", function(data)
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end

    local clientNetId = data.client.netId
    local coords = data.destination.finish.coords

    SetNewWaypoint(coords.x, coords.y)
    DestinationPoint = lib.points.new({
        coords = coords,
        distance = 10,
    })
    
    DestinationBlip = CreateDestinationBlip(coords)

    function DestinationPoint:nearby()
        if(NetworkDoesEntityExistWithNetworkId(clientNetId)) then
            local entity = NetworkGetEntityFromNetworkId(clientNetId)
            if(IsPedInAnyVehicle(entity)) then
                DisplayHelpTextThisFrame("STRIN_SIDEJOBS:TAXI_DROPOFF")
                if(IsControlJustReleased(0, 38)) then
                    TriggerServerEvent("strin_sidejobs:dropOffClient")
                end
            end
        end
    end

    while DestinationPoint do
        if(not NetworkDoesEntityExistWithNetworkId(clientNetId)) then
            break
        end
        local entity = NetworkGetEntityFromNetworkId(clientNetId)
        if(GetVehiclePedIsIn(entity) == 0) then
            TaskWarpPedIntoVehicle(entity, GetVehiclePedIsIn(PlayerPedId()), data.client.seatIndex) 
        end
        Citizen.Wait(0)
    end
end)

function CreateClientBlip(coords, distant, entity)
    local blip = distant and AddBlipForCoord(coords.x, coords.y, coords.z) or AddBlipForEntity(entity)
    SetBlipDisplay(blip, 2)
    SetBlipSprite(blip, entity and 480 or 164)
    SetBlipColour(blip, 28)
    SetBlipScale(blip, 1.5)
    SetBlipShrink(blip, true)
    --BeginTextCommandDisplayText("STRING")
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("<FONT FACE='Righteous'>Zákazník</FONT>")
    EndTextCommandSetBlipName(blip)
    return blip
end

function CreateDestinationBlip(coords)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipDisplay(blip, 2)
    SetBlipSprite(blip, 164)
    SetBlipColour(blip, 2)
    SetBlipScale(blip, 1.5)
    SetBlipShrink(blip, true)
    --BeginTextCommandDisplayText("STRING")
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("<FONT FACE='Righteous'>Cílová destinace</FONT>")
    EndTextCommandSetBlipName(blip)
    return blip
end