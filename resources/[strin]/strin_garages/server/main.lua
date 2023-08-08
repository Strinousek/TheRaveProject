local Cooldowns = {}
local CalledImpounds = {}
SpawnedVehicles = {}

local Base = exports.strin_base

Base:RegisterWebhook("TRANSFERS", "https://discord.com/api/webhooks/778509982136139837/alIXJQ6deFQunMbvOmQ-uWs6bacBI6eDABy1VYrSLwZA27CMR9IN0jzw3jeNbItIKzMc")

Citizen.CreateThread(function()
    MySQL.update.await("UPDATE owned_vehicles SET `stored` = 1 WHERE `stored` = 0")
end)

AddEventHandler("entityRemoved", function(entity)
    local netId = NetworkGetNetworkIdFromEntity(entity)
    local entityType = GetEntityType(entity)
    if(entityType ~= 2) then
        return
    end
    local vehicleIdentifier = SpawnedVehicles[netId]
    if(not vehicleIdentifier) then
        return
    end
    MySQL.scalar("SELECT `id` FROM `owned_vehicles` WHERE `vehicle_identifier` = ?", {
        vehicleIdentifier
    }, function(id)
        if(not id) then
            SpawnedVehicles[netId] = nil
            return
        end
        Citizen.Wait(250)
        if(not CalledImpounds[id]) then
            CalledImpounds[id] = GetGameTimer() + (2 * 60000)
            SetTimeout(2 * 60000, function()
                CalledImpounds[id] = nil
                MySQL.update.await("UPDATE owned_vehicles SET `stored` = 1 WHERE `id` = ?", {
                    id
                })
            end)
        end
    end)
end)

ESX.RegisterCommand("tosociety", "user", function(xPlayer)
    local _source = xPlayer.source

    local job = xPlayer.getJob()
    if(job.grade_name ~= "boss" and job.grade_name ~= "manager") then
        xPlayer.showNotification("Nemáte dostatečnou pravomoc ve společnosti!", { type = "error" })
        return
    end

    local ped = GetPlayerPed(_source)
    local vehicle = GetVehiclePedIsIn(ped)

    if(not DoesEntityExist(vehicle) or GetVehicleType(vehicle) == 0) then
        xPlayer.showNotification("Vozidlo neexistuje!", { type = "error" })
        return
    end

    local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicleEntity)
    local vehicleIdentifier = SpawnedVehicles[vehicleNetId]
    if(not vehicleIdentifier) then
        xPlayer.showNotification("Vozidlo není zaregistrované v systému!", { type = "error" })
        return
    end

    local plate = GetVehicleNumberPlateText(vehicle):upper()
    local vehicleData = MySQL.single.await("SELECT * FROM `owned_vehicles` WHERE `vehicle_identifier` = ? AND `job` IS NULL", {
        vehicleIdentifier
    })
    if(not vehicleData or not next(vehicleData)) then
        xPlayer.showNotification("Vozidlo nevlastníte nebo není vlastněné!", { type = "error" })
        return
    end
    
    local currentOwner = xPlayer.identifier..":"..xPlayer.get("char_id")
    if(vehicleData.owner ~= currentOwner) then
        xPlayer.showNotification("Vozidlo nevlastníte!", { type = "error" })
        return
    end

    local affectedRows = MySQL.update.await("UDPATE `owned_vehicles` SET `owner` = ?, `job` = ? WHERE `id` = ?", {
        nil,
        job.name,
        vehicleData.id
    })
    if(not affectedRows or affectedRows <= 0) then
        xPlayer.showNotification("Při předávání nastala chyba!", { type = "error" })
        return
    end

    Base:DiscordLog("TRANSFERS", "THE RAVE PROJECT - TRANSFER AUTA - DO SPOLEČNOSTI", {
        { name = "Jméno předavatele", value = ESX.SanitizeString(GetPlayerName(_source)) },
        { name = "Identifikace předavatele", value = xPlayer.identifier },
        { name = "Jméno společnosti", value = ESX.SanitizeString(job.label) },
        { name = "Identifikace společnosti", value = job.name },
        { name = "SPZ vozidla", value = plate },
        { name = "VIN vozidla", value = vehicleIdentifier },
        { name = "Model vozidla", value = vehicleData.model },
        { name = "ID vozidla", value = vehicleData.id },
    }, {
        fields = true,
    })

    xPlayer.showNotification(("Přepsal/a jste na společnost %s své vozidlo - %s."):format(job.label, vehicleData.model))
end)

ESX.RegisterCommand("fromsociety", "user", function(xPlayer)
    local _source = xPlayer.source

    local job = xPlayer.getJob()
    if(job.grade_name ~= "boss" and job.grade_name ~= "manager") then
        xPlayer.showNotification("Nemáte dostatečnou pravomoc ve společnosti!", { type = "error" })
        return
    end

    local ped = GetPlayerPed(_source)
    local vehicle = GetVehiclePedIsIn(ped)

    if(not DoesEntityExist(vehicle) or GetVehicleType(vehicle) == 0) then
        xPlayer.showNotification("Vozidlo neexistuje!", { type = "error" })
        return
    end

    local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicleEntity)
    local vehicleIdentifier = SpawnedVehicles[vehicleNetId]
    if(not vehicleIdentifier) then
        xPlayer.showNotification("Vozidlo není zaregistrované v systému!", { type = "error" })
        return
    end

    local plate = GetVehicleNumberPlateText(vehicle):upper()
    local vehicleData = MySQL.single.await("SELECT * FROM `owned_vehicles` WHERE `vehicle_identifier` = ? AND `job` = ?", { vehicleIdentifier, job.name })
    if(not vehicleData or not next(vehicleData)) then
        xPlayer.showNotification("Vozidlo nevlastníte nebo není vlastněné!", { type = "error" })
        return
    end
    
    local owner = xPlayer.identifier..":"..xPlayer.get("char_id")

    local affectedRows = MySQL.update.await("UDPATE `owned_vehicles` SET `owner` = ?, `job` = ? WHERE `id` = ?", {
        owner,
        nil,
        vehicleData.id
    })
    if(not affectedRows or affectedRows <= 0) then
        xPlayer.showNotification("Při předávání nastala chyba!", { type = "error" })
        return
    end

    Base:DiscordLog("TRANSFERS", "THE RAVE PROJECT - TRANSFER AUTA - ZE SPOLEČNOSTI", {
        { name = "Jméno společnosti", value = ESX.SanitizeString(job.label) },
        { name = "Identifikace společnosti", value = job.name },
        { name = "Jméno obdržitele", value = ESX.SanitizeString(GetPlayerName(_source)) },
        { name = "Identifikace obdržitele", value = xPlayer.identifier },
        { name = "SPZ vozidla", value = plate },
        { name = "VIN vozidla", value = vehicleIdentifier },
        { name = "Model vozidla", value = vehicleData.model },
        { name = "ID vozidla", value = vehicleData.id },
    }, {
        fields = true,
    })

    xPlayer.showNotification(("Přepsal/a jste na sebe vozidlo %s ze společnosti %s."):format(vehicleData.model, job.label))
end)

ESX.RegisterCommand("givecar", "user", function(xPlayer, args)
    if(not args.targetId) then return end
    local _source = xPlayer.source

    if(args.targetId == _source) then
        xPlayer.showNotification("Nemůžete předat vozidlo sám sobě!", { type = "error" })
        return
    end

    local targetPlayer = ESX.GetPlayerFromId(args.targetId)
    if(not targetPlayer) then
        xPlayer.showNotification("Daný hráč neexistuje!", { type = "error" })
        return
    end

    local ped = GetPlayerPed(_source)
    local vehicle = GetVehiclePedIsIn(ped)

    if(not DoesEntityExist(vehicle) or GetVehicleType(vehicle) == 0) then
        xPlayer.showNotification("Vozidlo neexistuje!", { type = "error" })
        return
    end

    local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicleEntity)
    local vehicleIdentifier = SpawnedVehicles[vehicleNetId]
    if(not vehicleIdentifier) then
        xPlayer.showNotification("Vozidlo není zaregistrované v systému!", { type = "error" })
        return
    end

    local plate = GetVehicleNumberPlateText(vehicle):upper()
    local vehicleData = MySQL.single.await("SELECT * FROM `owned_vehicles` WHERE `vehicle_identifier` = ? AND `job` IS NULL", { vehicleIdentifier })
    if(not vehicleData or not next(vehicleData)) then
        xPlayer.showNotification("Vozidlo nevlastníte!", { type = "error" })
        return
    end

    local currentOwner = xPlayer.identifier..":"..xPlayer.get("char_id")
    if(vehicleData.owner ~= currentOwner) then
        xPlayer.showNotification("Vozidlo nevlastníte!", { type = "error" })
        return
    end

    local newOwner = targetPlayer.identifier..":"..targetPlayer.get("char_id")
    local affectedRows = MySQL.update.await("UDPATE `owned_vehicles` SET `owner` = ? WHERE `id` = ?", {
        newOwner,
        vehicleData.id
    })
    if(not affectedRows or affectedRows <= 0) then
        xPlayer.showNotification("Při předávání nastala chyba!", { type = "error" })
        return
    end

    Base:DiscordLog("TRANSFERS", "THE RAVE PROJECT - TRANSFER AUTA", {
        { name = "Jméno předavatele", value = ESX.SanitizeString(GetPlayerName(_source)) },
        { name = "Identifikace předavatele", value = xPlayer.identifier },
        { name = "Jméno obdržitele", value = ESX.SanitizeString(GetPlayerName(targetPlayer.source)) },
        { name = "Identifikace obdržitele", value = targetPlayer.identifier },
        { name = "VIN vozidla", value = vehicleIdentifier },
        { name = "SPZ vozidla", value = plate },
        { name = "Model vozidla", value = vehicleData.model },
        { name = "ID vozidla", value = vehicleData.id },
    }, {
        fields = true,
    })

    xPlayer.showNotification(("Přepsal/a jste na hráče #%s své vozidlo - %s."):format(targetPlayer.source, vehicleData.model))
    targetPlayer.showNotification(("Obdržel/a jste od hráče #%s vozidlo - %s."):format(_source, vehicleData.model))
end, false, {
    help = "Předání vozidla hráči",
    arguments = {
        { name = "targetId", type = "number", help = "ID hráče"}
    }
})

RegisterNetEvent("strin_garages:storeVehicle", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer or Cooldowns[xPlayer?.identifier]) then
        return
    end

    Cooldowns[xPlayer.identifier] = true
    SetTimeout(1000, function()
        Cooldowns[xPlayer.identifier] = nil
    end)
    
    local ped = GetPlayerPed(_source)
    local vehicleEntity = GetVehiclePedIsIn(ped)

    if(not DoesEntityExist(vehicleEntity) or GetVehicleType(vehicleEntity) == 0) then
        xPlayer.showNotification("Vozidlo neexistuje!", { type = "error" })
        return
    end

    local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicleEntity)
    local vehicleIdentifier = SpawnedVehicles[vehicleNetId]
    if(not vehicleIdentifier) then
        xPlayer.showNotification("Vozidlo není zaregistrované v systému!", { type = "error" })
        return
    end

    local job = xPlayer.getJob()
    local garage = GetNearestGarage(_source)
    if(not garage) then
        xPlayer.showNotification("Neplatná garáž!", { type = "error" })
        return
    end
    local plate = GetVehicleNumberPlateText(vehicleEntity):upper()

    local owner = xPlayer.identifier..":"..xPlayer.get("char_id")
    local vehicle = MySQL.single.await("SELECT * FROM owned_vehicles WHERE (`owner` = ? OR `job` = ?) AND `vehicle_identifier` = ?", {
        owner,
        job.name,
        vehicleIdentifier
    })
    if(not vehicle or not next(vehicle)) then
        xPlayer.showNotification("Takové vozidlo neexistuje!", { type = "error" })
        return
    end
    if(vehicle.stored == 1) then
        xPlayer.showNotification("Tohle vozidlo již v garáži je!", { type = "error" })
        return
    end
    if(vehicle.job and job.name == "police" and not garage.isPolice) then
        xPlayer.showNotification("Tohle vozidlo můžete uložit pouze na stanici!", { type = "error" })
        return
    end

    if(GetHashKey(vehicle.model) ~= GetEntityModel(vehicleEntity)) then
        xPlayer.showNotification("Tohle vozidlo není stejného typu!", { type = "error" })
        return
    end

    lib.callback("strin_garages:getVehicleProperties", _source, function(props)
        if(not props) then
            xPlayer.showNotification("Nastala chyba při zjišťování specifikací vozidla!", { type = "error" })
            return
        end
        props.plate = ESX.SanitizeString(plate)

        local savedProps = json.decode(vehicle.props)
        
        local changedProps = GetChangedVehicleProperties(props, savedProps)

        local areChangesValid = AreVehicleChangesValid(changedProps)
        if(not areChangesValid) then
            xPlayer.showNotification("Vaše vozidlo je zvláštně modifikováno!", { type = "error" })
            return
        end
        
        MySQL.update.await("UPDATE owned_vehicles SET `props` = ?, `stored` = 1 WHERE (`owner` = ? OR `job` = ?) AND `id` = ?", {
            json.encode(props),
            owner,
            job.name,
            vehicle.id
        })
        DeleteEntity(vehicleEntity)
        SpawnedVehicles[vehicleNetId] = nil
        xPlayer.showNotification("Úspěšně jste uložil vozidlo!", { type = "success" })
    end, vehicleNetId)
end)

RegisterNetEvent("strin_garages:takeOutVehicle", function(vehicleId)
    if(type(vehicleId) ~= "number") then
        return
    end
    
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    local job = xPlayer.getJob()
    local garage = GetNearestGarage(_source)
    if(not garage) then
        xPlayer.showNotification("Neplatná garáž!", { type = "error" })
        return
    end

    local owner = xPlayer.identifier..":"..xPlayer.get("char_id")
    local vehicle = MySQL.single.await("SELECT * FROM owned_vehicles WHERE (`owner` = ? OR `job` = ?) AND `id` = ?", {
        owner,
        job.name,
        vehicleId
    })
    
    if(not vehicle or not next(vehicle)) then
        xPlayer.showNotification("Takové vozidlo neexistuje!", { type = "error" })
        return
    end
    
    local vehicleFound = false
    for k,v in pairs(SpawnedVehicles) do
        if(v == vehicle.vehicle_identifier) then
            vehiclefo = true
            break
        end
    end
    if(vehicleFound) then
        xPlayer.showNotification("Vozidlo již je ve vytaženo!", { type = "error" })
        return
    end

    if(vehicle.stored ~= 1) then
        xPlayer.showNotification("Tohle vozidlo je na odtahové službě!", { type = "error" })
        return
    end

    if((job.name == "police" and vehicle.job == "police" and not garage?.isPolice)) then
        xPlayer.showNotification("Tohle vozidlo nelze ZDE vytáhnout!", { type = "error" })
        return
    end

    MySQL.update.await("UPDATE owned_vehicles SET `stored` = 0 WHERE (`owner` = ? OR `job` = ?) AND `id` = ?", {
        owner,
        job.name,
        vehicleId
    })
    
    SpawnedVehicles[SpawnVehicleFromGarage(_source, vehicle, garage)] = vehicle.vehicle_identifier
end)

RegisterNetEvent("strin_garages:callImpound", function(vehicleId)
    if(type(vehicleId) ~= "number") then
        return
    end
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end
    
    if(CalledImpounds[vehicleId]) then
        xPlayer.showNotification("Odtahová služba již je na cestě!", { type = "error" })
        return
    end

    local garage = GetNearestGarage(_source)
    if(not garage) then
        xPlayer.showNotification("Neplatná garáž!", { type = "error" })
        return
    end

    local vehicle = MySQL.single.await("SELECT * FROM owned_vehicles WHERE `id` = ?", {
        vehicleId
    })

    if(not vehicle or not next(vehicle)) then
        xPlayer.showNotification("Takové vozidlo neexistuje!", { type = "error" })
        return
    end

    if(vehicle.stored == 1) then
        xPlayer.showNotification("Nemůžete zavolat odtahovou službu na uložené vozidlo!", { type = "error" })
        return
    end

    local vehicleNetId = nil
    for k,v in pairs(SpawnedVehicles) do
        if(v == vehicle.vehicle_identifier) then
            vehicleNetId = k
        end
    end
    if(vehicleNetId) then
        local vehicleEntity = NetworkGetEntityFromNetworkId(vehicleNetId)
        if(DoesEntityExist(vehicleEntity)) then
            DeleteEntity(vehicleEntity)
            xPlayer.showNotification("Vozidlo bylo smazáno!", { type = "error" })
            SpawnedVehicles[vehicleNetId] = nil
        else
            SpawnedVehicles[vehicleNetId] = nil
        end
    end
    CalledImpounds[vehicleId] = GetGameTimer() + (2 * 60000)
    SetTimeout(2 * 60000, function()
        CalledImpounds[vehicleId] = nil
        MySQL.update.await("UPDATE owned_vehicles SET `stored` = 1 WHERE `id` = ?", {
            vehicleId
        })
    end)
    xPlayer.showNotification("Odtahová služba Vám brzy doveze Vaše vozidlo do garáže.")
end)

function SpawnVehicleFromGarage(playerId, vehicle, garage)
    local modelHash = GetHashKey(vehicle.model)
    local vehicleEntity = CreateVehicleServerSetter(modelHash, "automobile", garage.coords, garage.heading)
    for i=-1, 6 do
        local pedInVehicleSeat = GetPedInVehicleSeat(vehicleEntity, i)
        if(pedInVehicleSeat ~= 0) then
            DeleteEntity(pedInVehicleSeat)
        end
    end
    Entity(vehicleEntity).state.vehicleIdentifier = vehicle.vehicle_identifier
    local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicleEntity)
    if(GetPlayerName(playerId)) then
        TriggerClientEvent("strin_garages:setVehicleProperties", playerId, vehicleNetId, vehicle.props and json.decode(vehicle.props) or {
            plate = vehicle.plate
        })
    end
    return vehicleNetId
end

RegisterNetEvent("strin_garages:renameVehicle", function(vehicleId, vehicleLabel)
    if(type(vehicleId) ~= "number" or type(vehicleLabel) ~= "string") then
        return
    end
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end
    
    local label = string.len(vehicleLabel) == 0 and nil or ESX.SanitizeString(vehicleLabel)
    
    local owner = xPlayer.identifier..":"..xPlayer.get("char_id")
    MySQL.update.await("UPDATE owned_vehicles SET `label` = ? WHERE `owner` = ? AND `id` = ?", {
        label,
        owner,
        vehicleId
    })
    xPlayer.showNotification("Přejmenoval jste vozidlo.")
end)

lib.callback.register("strin_garages:getImpoundStatus", function(source, vehicleId)
    return CalledImpounds[vehicleId] and math.floor(((CalledImpounds[vehicleId] - GetGameTimer()) / 1000)) or nil
end)

lib.callback.register("strin_garages:getPersonalVehicles", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if(not xPlayer) then
        return {}
    end
    return ConvertVehicles(GetCharacterPersonalVehicles(xPlayer.identifier, xPlayer.get("char_id")))
end)

lib.callback.register("strin_garages:getSocietyVehicles", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if(not xPlayer) then
        return {}
    end
    local job = xPlayer.getJob()
    return ConvertVehicles(GetCharacterSocietyVehicles(xPlayer.identifier, xPlayer.get("char_id"), job.name))
end)

lib.callback.register("strin_garages:getAllVehicles", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if(not xPlayer) then
        return {}
    end
    local job = xPlayer.getJob()
    return ConvertVehicles(GetCharacterAllVehicles(xPlayer.identifier, xPlayer.get("char_id"), job.name))
end)

lib.callback.register("strin_garages:getAllCurrentVehicles", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if(not xPlayer) then
        return {}
    end
    local job = xPlayer.getJob()
    return ConvertVehicles(GetCharacterAllCurrentVehicles(xPlayer.identifier, xPlayer.get("char_id"), job.name))
end)

function ConvertVehicles(vehicles)
    if(not vehicles or not next(vehicles)) then
        return {}
    end
    for k,v in pairs(vehicles) do
        if(CalledImpounds[v.id]) then
            vehicles[k].impound = CalledImpounds[v.id]
        end
    end
    return vehicles
end

function GetCharacterPersonalVehicles(identifier, characterId)
    return MySQL.query.await(
        ("SELECT * FROM owned_vehicles WHERE `owner` = ? AND `job` IS NULL")
    ,{
        identifier..":"..characterId,
    }) or {}
end

function GetCharacterSocietyVehicles(identifier, characterId, jobName)
    local owner = identifier..":"..characterId
    return MySQL.query.await(
        ("SELECT * FROM owned_vehicles WHERE (`owner` = ? AND `job` IS NOT NULL) OR (`owner` IS NULL AND `job` = ?)")
    ,{
        owner,
        jobName
    }) or {}
end

function GetCharacterAllVehicles(identifier, characterId, jobName)
    local owner = identifier..":"..characterId
    return MySQL.query.await(
        ("SELECT * FROM owned_vehicles WHERE `owner` = ? OR (`owner` IS NULL AND `job` = ?)")
    ,{
        owner,
        jobName
    }) or {}
end

function GetCharacterAllCurrentVehicles(identifier, characterId, jobName)
    local owner = identifier..":"..characterId
    return MySQL.query.await(
        ("SELECT * FROM owned_vehicles WHERE (`owner` = ? AND `job` IS NULL) OR (`owner` = ? AND `job` = ?) OR (`owner` IS NULL AND `job` = ?)")
    ,{
        owner,
        owner,
        jobName,
        jobName
    }) or {}
end

function GetSocietyAllVehicles(jobName)
    return MySQL.query.await(
        ("SELECT * FROM owned_vehicles WHERE `job` = ?")
    ,{
        jobName
    }) or {}
end

function GetNearestGarage(playerId)
    local ped = GetPlayerPed(playerId)
    local coords = GetEntityCoords(ped)
    local garage = nil
    local distanceToGarage = 15000.0
    for _,v in pairs(Garages) do
        local distance = #(coords - v.coords)
        if(distance < distanceToGarage) then
            garage = v
            distanceToGarage = distance
        end
    end
    return (distanceToGarage < 15) and garage or nil 
end

/*function IsVehicleSpawned(netId)
    local found = false
    for k,v in pairs(SpawnedVehicles) do
        if(v == netId) then
            found = true
            break
        end
    end
    return found
end*/

local NonStaticProperties = {
    "windows", "bodyHealth", "oilLevel", "fuelLevel", "wheelSize",
    "extras", "tyres", "bulletProofTyres", "tankHealth", "wheelWidth",
    "dirtLevel", "modRoofLivery", "engineHealth", "doors", "modLightbar",
    "modLivery", "driftTyres" -- these need to adjust
}

function AreVehicleChangesValid(changes)
    local areValid = true
    for k,v in pairs(changes) do
        if(not lib.table.contains(NonStaticProperties, k)) then
            areValid = false
            break 
        end
    end
    return areValid
end

function GetChangedVehicleProperties(newProps, oldProps)
    local changes = {}
    for k,v in pairs(newProps) do
        if(type(v) ~= "table") then
            if(oldProps[k] ~= v) then
                changes[k] = v
            end
        else
            if(not lib.table.matches(v, oldProps[k])) then
                changes[k] = v
            end
        end
    end
    return changes
end

function GetSpawnedVehicle(__type, value)
    local spawnedVehicle = {} 
    for k,v in pairs(SpawnedVehicles) do
        if((__type == "identifier" and v == value) or (__type == "netId" and k == value)) then
            spawnedVehicle.netId = k
            spawnedVehicle.vehicleIdentifier = v
            break
        end
    end
    return next(spawnedVehicle) and spawnedVehicle or nil
end

exports("GetSpawnedVehicle", GetSpawnedVehicle)