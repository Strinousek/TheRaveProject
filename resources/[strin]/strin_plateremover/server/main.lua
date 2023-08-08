local RemovedLocalPlates = {}
local PermittedScrewdriverSpawns = {}
local SCREWDRIVER_MODEL = `prop_tool_screwdvr01`
local Garages = exports.strin_garages
local Base = exports.strin_base

Base:RegisterWhitelistedEntity(SCREWDRIVER_MODEL)

AddEventHandler("entityCreating", function(entity)
    if(GetEntityType(entity) ~= 3) then
        return
    end
    local model = GetEntityModel(entity)
    if(model ~= SCREWDRIVER_MODEL) then
        return
    end
    local entityOwnerId = NetworkGetEntityOwner(entity)
    if(entityOwnerId and PermittedScrewdriverSpawns[entityOwnerId]) then
        return
    end
    CancelEvent()
end)

AddEventHandler("entityRemoved", function(entity)
    local netId = NetworkGetNetworkIdFromEntity(entity)
    if(not RemovedLocalPlates[netId]) then
        return
    end
    RemovedLocalPlates[netId] = nil
end)

RegisterNetEvent("strin_plateremover:removePlate", function(vehicleNetId)
    local _source = source
    
    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
    if(not DoesEntityExist(vehicle)) then
        TriggerClientEvent("esx:showNotification", _source, "Vozidlo neexistuje.", {
            type = "error"
        })
        return
    end

    if(GetEntityType(vehicle) ~= 2) then
        TriggerClientEvent("esx:showNotification", _source, "Vozidlo není vozidlo.", {
            type = "error"
        })
        return
    end

    local plate = GetVehicleNumberPlateText(vehicle)
    if(plate == "XXXXXXXX" or RemovedLocalPlates[vehicleNetId]) then
        TriggerClientEvent("esx:showNotification", _source, "Vozidlo již má zamaskovanou SPZ.", {
            type = "error"
        })
        return
    end
    
    local spawnedVehicle = Garages:GetSpawnedVehicle("netId", vehicleNetId)
    if(spawnedVehicle) then
        local props = json.decode(MySQL.scalar.await("SELECT `props` FROM `owned_vehicles` WHERE `vehicle_identifier` = ?", {
            spawnedVehicle.vehicleIdentifier
        }))
        props.plate = "XXXXXXXX"
        MySQL.update.await("UPDATE `owned_vehicles` SET `props` = ? WHERE `vehicle_identifier` = ?", {
            json.encode(props),
            spawnedVehicle.vehicleIdentifier
        })
        PermitPlayer(_source, function()
            SetVehicleNumberPlateText(vehicle, "XXXXXXXX")
            TriggerClientEvent("esx:showNotification", _source, "SPZ zamaskována!", {
                type = "success"
            })
        end)
        return
    end

    PermitPlayer(_source, function()
        RemovedLocalPlates[vehicleNetId] = plate
        SetVehicleNumberPlateText(vehicle, "XXXXXXXX")
        TriggerClientEvent("esx:showNotification", _source, "SPZ zamaskována!", {
            type = "success"
        })
    end)
end)

RegisterNetEvent("strin_plateremover:restorePlate", function(vehicleNetId)
    local _source = source

    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
    if(not DoesEntityExist(vehicle)) then
        TriggerClientEvent("esx:showNotification", _source, "Vozidlo neexistuje!", {
            type = "error"
        })
        return
    end

    if(GetEntityType(vehicle) ~= 2) then
        TriggerClientEvent("esx:showNotification", _source, "Vozidlo není vozidlo!", {
            type = "error"
        })
        return
    end

    local plate = GetVehicleNumberPlateText(vehicle)
    if(plate ~= "XXXXXXXX") then
        TriggerClientEvent("esx:showNotification", _source, "Vozidlo nemá zamaskovanou SPZ!", {
            type = "error"
        })
        return
    end
    
    local spawnedVehicle = Garages:GetSpawnedVehicle("netId", vehicleNetId)
    if(spawnedVehicle) then
        local plate = MySQL.scalar.await("SELECT `plate` FROM `owned_vehicles` WHERE `vehicle_identifier` = ?", {
            spawnedVehicle.vehicleIdentifier
        })
        local props = json.decode(MySQL.scalar.await("SELECT `props` FROM `owned_vehicles` WHERE `vehicle_identifier` = ?", {
            spawnedVehicle.vehicleIdentifier
        }))
        props.plate = plate
        MySQL.update.await("UPDATE `owned_vehicles` SET `props` = ? WHERE `vehicle_identifier` = ?", {
            json.encode(props),
            spawnedVehicle.vehicleIdentifier
        })
        PermitPlayer(_source, function()
            SetVehicleNumberPlateText(vehicle, plate)
            TriggerClientEvent("esx:showNotification", _source, "SPZ odmaskována!", {
                type = "success"
            })
        end)
        return
    end

    if(not RemovedLocalPlates[vehicleNetId]) then
        TriggerClientEvent("esx:showNotification", _source, "Vozidlo nemá zaregistrovanou zamaskovanou SPZ.", {
            type = "error"
        })
        return
    end

    PermitPlayer(_source, function()
        SetVehicleNumberPlateText(vehicle, RemovedLocalPlates[vehicleNetId])
        RemovedLocalPlates[vehicleNetId] = nil
        TriggerClientEvent("esx:showNotification", _source, "SPZ odmaskována!", {
            type = "success"
        })
    end)
end)

function PermitPlayer(playerId, cb)
    TriggerClientEvent("strin_plateremover:screw", playerId, 4000)
    PermittedScrewdriverSpawns[playerId] = true
    SetTimeout(1000, function()
        PermittedScrewdriverSpawns[playerId] = nil
    end)
    SetTimeout(4000, function()
        cb()
    end)
end

AddEventHandler("playerDropped", function()
    local _source = source
    if(not PermittedScrewdriverSpawns[_source]) then
        return
    end
    PermittedScrewdriverSpawns[_source] = nil
end)