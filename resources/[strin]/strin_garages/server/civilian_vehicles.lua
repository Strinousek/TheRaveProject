local NPC_VEHICLE_IDENTIFIER_PREFIX = "C1V7"
local ClientCreatedVehicles = {}

local VehicleShop = exports.strin_vehicleshop

AddEventHandler("entityCreating", function(entity)
    if(GetEntityType(entity) ~= 2) then
        return
    end
    
    local netId = NetworkGetNetworkIdFromEntity(entity)
    if(ClientCreatedVehicles[netId] or SpawnedVehicles[netId]) then
        return
    end

    local success, response = pcall(function()
        local vehicleIdentifier = VehicleShop:GenerateVehicleIdentifier()
        return vehicleIdentifier
    end)
    if(not success) then
        response = "1X1X1X1X1X1X1X1X"
    end
    math.randomseed(GetGameTimer() + math.random(10000,99999))
    local randomNumber = math.random(1,2)
    if(randomNumber == 1) then
        response = NPC_VEHICLE_IDENTIFIER_PREFIX..response:sub(5)
    else
        response = response:sub(1, response:len() - 4)..NPC_VEHICLE_IDENTIFIER_PREFIX
    end
    ClientCreatedVehicles[netId] = response
end)

AddEventHandler("entityRemoved", function(entity)
    if(GetEntityType(entity) ~= 2) then
        return
    end
    
    local netId = NetworkGetNetworkIdFromEntity(entity)
    if(not ClientCreatedVehicles[netId]) then
        return
    end
    ClientCreatedVehicles[netId] = nil
end)

lib.callback.register("strin_garages:getVehicleIdentifier", function(source, netId)
    return ClientCreatedVehicles[netId] or SpawnedVehicles[netId]
end)