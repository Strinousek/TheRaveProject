TunnedVehicles = {}

TunningPlayers = {}

Base:RegisterWebhook("TUNNING", "https://discord.com/api/webhooks/679812996360699993/x1oNqxUOD1RN-J6Rc8a33itB-Wp9hcH5X3iggOWPspjIrW6UL5uHURftdNsMxrB8hG1S")

/*ESX.RegisterCommand("sqltable", "admin", function(xPlayer)
    local file = load(LoadResourceFile("strin_tunning", "properties.lua"))()
    local sqlTableColumns = {}
    for k,v in pairs(file) do
        if(type(v) == "string") then
            sqlTableColumns[k] = "VARCHAR(50) NULL DEFAULT NULL"
        elseif(type(v) == "boolean") then
            sqlTableColumns[k] = "TINYINT NULL DEFAULT NULL"
        elseif(type(v) == "table") then
            sqlTableColumns[k] = "LONGTEXT NULL DEFAULT NULL"
        elseif(type(v) == "number") then
            sqlTableColumns[k] = "INT NULL DEFAULT NULL"
        end
    end
    local sqlTableColumnStrings = {}
    for k,v in pairs(sqlTableColumns) do
        table.insert(sqlTableColumnStrings, (
            "`"..k.."`".." "..v
        ))
    end
    local sqlTableString = ([[
        ALTER TABLE `tunning_tickets` (
            `id` INT NOT NULL AUTO_INCREMENT
            %s
            PRIMARY KEY (`id`)
            UNIQUE KEY (`id`)
        )
    ]]):format(table.concat(sqlTableColumnStrings, ",\n"))
    SaveResourceFile("strin_tunning", "database.sql", sqlTableString, -1)
end)*/

AddEventHandler("strin_characters:characterDeleted", function(identifier, characterId)
    local owner = identifier..":"..characterId
    local vehicles = MySQL.query.await("SELECT * FROM `owned_vehicles` WHERE `owner` = ?", {
        owner
    })
    if(#vehicles > 0) then
        for _,vehicle in pairs(vehicles) do
            MySQL.query("SELECT * FROM `tunning_tickets` WHERE `plate` = ?", { v.plate:upper() }, function(tickets)
                if(#tickets > 0) then
                    for _,ticket in pairs(tickets) do
                        MySQL.query("DELETE FROM `tunning_tickets` WHERE `plate` = ?", { ticket.id })
                    end
                end
            end)
        end
    end
end)

local Cooldowns = {}

lib.callback.register("strin_tunning:requestTicket", function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return false
    end

    local ped = GetPlayerPed(_source)
    local vehicle = GetVehiclePedIsIn(ped)
    if(vehicle == 0) then
        xPlayer.showNotification("Nejste v žádném vozidle!", { type = "error" })
        return false
    end

    local tunningZoneId = GetNearestTunningZoneId(_source)
    if(not tunningZoneId) then
        xPlayer.showNotification("Nejste poblíž žádné dílny!", { type = "error" })
        return
    end

    local plate = GetVehicleNumberPlateText(vehicle)

    local vehicleId = MySQL.scalar.await("SELECT `id` FROM `owned_vehicles` WHERE `owner` = ? AND `plate` = ?", {
        xPlayer.identifier..":"..xPlayer.get("char_id"),
        plate:upper()
    })

    if(not vehicleId) then
        xPlayer.showNotification("Tohle vozidlo nevlastníte!", { type = "error" })
        return false
    end

    local tickets = GetTicketsForVehicle(vehicle)
    if(#tickets >= MaxTicketsPerVehicle) then
        xPlayer.showNotification("Pro toto vozidlo již existuje maximum lístků!", { type = "error" })
        return false
    end

    local ticketId = CreateTicketForVehicle(vehicle)
    Inventory:AddItem(_source, "ticket", 1, {
        category = "tunning",
        plate = plate:upper(),
        id = ticketId
    })
    return ticketId
end)

RegisterNetEvent("strin_tunning:startTunning", function(ticketId)
    if(type(ticketId) ~= "number") then
        return
    end
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    if(TunningPlayers[xPlayer.identifier]) then
        xPlayer.showNotification("Již jste zaregistrován v systému tunningu!", { type = "error" })
        return
    end

    local ticketCount = Inventory:GetItemCount(_source, "ticket", {
        category = "tunning",
        id = ticketId
    })

    if(ticketCount <= 0) then
        xPlayer.showNotification("Nemáte žádný takový lístek!", { type = "error" })
        return
    end

    local ped = GetPlayerPed(_source)
    local vehicle = GetVehiclePedIsIn(ped)

    if(vehicle == 0) then
        xPlayer.showNotification("Nejste v žádném vozidle!", { type = "error" })
        return
    end

    local tunningZoneId = GetNearestTunningZoneId(_source)
    if(not tunningZoneId) then
        xPlayer.showNotification("Nejste poblíž žádné dílny!", { type = "error" })
        return
    end

    local plate = GetVehicleNumberPlateText(vehicle)

    local ticketData = MySQL.single.await("SELECT * FROM `tunning_tickets` WHERE `id` = ? AND `plate` = ?", {
        ticketId,
        plate:upper()
    })

    if(not ticketData or not next(ticketData) or CountKeysInTable(ticketData) == 0) then
        xPlayer.showNotification("Takový lístek neexistuje!", { type = "error" })
        Inventory:RemoveItem(_source, "ticket", 1, {
            category = "tunning",
            plate = plate:upper(),
            id = ticketId
        })
        return
    end

    lib.callback("strin_tunning:getVehicleProperties", _source, function(vehicleProperties)
        if(not vehicleProperties or type(vehicleProperties) ~= "table" or not next(vehicleProperties)) then
            return
        end

        local ped = GetPlayerPed(_source)
        local vehicle = GetVehiclePedIsIn(ped)
    
        if(vehicle == 0) then
            xPlayer.showNotification("Nejste v žádném vozidle!", { type = "error" })
            return
        end

        local tunningZoneId = GetNearestTunningZoneId(_source)
        if(not tunningZoneId) then
            xPlayer.showNotification("Nejste poblíž žádné dílny!", { type = "error" })
            return
        end
        
        TunningPlayers[xPlayer.identifier] = {
            ticketId = ticketId,
            vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle),
            vehicleProperties = vehicleProperties
        }

        TriggerClientEvent("strin_tunning:startTunning", 
            _source,
            tunningZoneId,
            TunningPlayers[xPlayer.identifier].vehicleNetId,
            CountKeysInTable(ticketData) > 2 and GetVehiclePropertiesFromTicket(ticketData) or nil
        )
    end)
end)

Base:RegisterItemListener("ticket", function(item, inventory, slot, data)
    local _source = inventory.id
    local item = Inventory:GetSlot(_source, slot)
    if(item.metadata?.category == "tunning" and item.metadata?.id) then
        local xPlayer = ESX.GetPlayerFromId(_source)
        if(not xPlayer) then
            return
        end

        if(TunningPlayers[xPlayer.identifier]) then
            xPlayer.showNotification("Lístky nelze použit při výběru tunningu!", { type = "error" })
            return
        end

        local job = xPlayer.getJob()
        if(not StrinJobs:HasAccessToAction(job.name, "mechanic")) then
            xPlayer.showNotification("Nejste mechanik!", { type = "error" })
            return
        end

        local ped = GetPlayerPed(_source)
        local vehicle = GetVehiclePedIsIn(ped)

        if(vehicle == 0) then
            xPlayer.showNotification("Nejste v žádném vozidle!", { type = "error" })
            return
        end

        local tunningZoneId = GetNearestTunningZoneId(_source)
        if(not tunningZoneId) then
            xPlayer.showNotification("Nejste poblíž žádné dílny!", { type = "error" })
            return
        end

        local tunningZone = TunningZones[tunningZoneId]
        if(job.name ~= tunningZone.society) then
            xPlayer.showNotification("Nejste mechanikem této dílny!", { type = "error" })
            return
        end

        local plate = GetVehicleNumberPlateText(vehicle)

        local ticketData = MySQL.single.await("SELECT * FROM `tunning_tickets` WHERE `id` = ? AND `plate` = ?", {
            item.metadata?.id,
            item.metadata?.plate
        })

        if(not ticketData or not next(ticketData) or CountKeysInTable(ticketData) == 0) then
            xPlayer.showNotification("Takový lístek neexistuje!", { type = "error" })
            Inventory:RemoveItem(_source, "ticket", 1, {
                category = "tunning",
                plate = item.metadata?.plate,
                id = item.metadata?.id
            })
            return
        end
        
        if(CountKeysInTable(ticketData) <= 2) then
            xPlayer.showNotification("Na tomhle lístku nic nebylo!", { type = "error" })

            MySQL.query.await("DELETE FROM `tunning_tickets` WHERE `id` = ? AND `plate` = ?", {
                item.metadata?.id,
                item.metadata?.plate
            })
            Inventory:RemoveItem(_source, "ticket", 1, {
                category = "tunning",
                plate = item.metadata?.plate,
                id = item.metadata?.id
            })
            return
        end

        lib.callback("strin_tunning:getVehicleProperties", _source, function(vehicleProperties)
            if(not vehicleProperties or type(vehicleProperties) ~= "table" or not next(vehicleProperties)) then
                return
            end

            local ped = GetPlayerPed(_source)
            local vehicle = GetVehiclePedIsIn(ped)
        
            if(vehicle == 0) then
                xPlayer.showNotification("Nejste v žádném vozidle!", { type = "error" })
                return
            end

            local tunningZoneId = GetNearestTunningZoneId(_source)
            if(not tunningZoneId) then
                xPlayer.showNotification("Nejste poblíž žádné dílny!", { type = "error" })
                return
            end

            local ticketProperties = GetVehiclePropertiesFromTicket(ticketData)

            local owner = MySQL.scalar.await("SELECT `owner` FROM `owned_vehicles` WHERE `plate` = ?", {
                plate:upper()
            })

            if(not owner) then
                xPlayer.showNotification("Vozidlo nemá majitele!", { type = "error" })
                return
            end
            local ownerIdentifier = owner:sub(1, owner:find(":") - 1)
            local ownerCharacterId = tonumber(owner:sub(owner:find(":") + 1, string.len(owner)))
            local ownerPlayer = ESX.GetPlayerFromIdentifier(ownerIdentifier)
            if(not ownerPlayer or ownerPlayer.get("char_id") ~= ownerCharacterId) then
                xPlayer.showNotification("Majitel vozidla není přítomen!", { type = "error" })
                return
            end

            -- calculate price here
            local price = CalculateTunningPrice(ticketProperties, GetEntityModel(vehicle))

            local societyCutPercentage = TunningZones[tunningZoneId]?.societyCut
            local societyCut = math.floor(price * societyCutPercentage)

            Society:AddSocietyMoney(TunningZones[tunningZoneId]?.society, societyCut)

            local bankMoney = ownerPlayer.getAccount('bank')?.money

            if((bankMoney - price) < 0) then
                xPlayer.showNotification("Majitel vozidla nemá na bankovním účte dostatek peněz!", { type = "error" })
                ownerPlayer.showNotification("Nemáte tolik peněz na bankovním účtě!", { type = "error" })
                return
            end

            for k,v in pairs(ticketProperties) do
                vehicleProperties[k] = type(vehicleProperties[k]) == "boolean" and (v >= 1 and true or false) or v
            end
            MySQL.update.await("UPDATE `owned_vehicles` SET `props` = ? WHERE `plate` = ?", { json.encode(vehicleProperties), item.metadata?.plate })
            MySQL.query.await("DELETE FROM `tunning_tickets` WHERE `id` = ? AND `plate` = ?", { item.metadata?.id, item.metadata?.plate })
            Inventory:RemoveItem(_source, "ticket", 1, {
                category = "tunning",
                plate = item.metadata?.plate,
                id = item.metadata?.id
            })
            Base:DiscordLog("TUNNING", "THE RAVE PROJECT - TUNNING", {
                { name = "SPZ vozidla", value = item.metadata?.plate },
                { name = "ID ticketu", value = item.metadata?.id },

                { name = "Jméno majitele vozidla", value = GetPlayerName(ownerPlayer.source) },
                { name = "Identifikace majitele vozidla", value = ownerPlayer.identifier },

                { name = "Jméno mechanika", value = GetPlayerName(xPlayer.source) },
                { name = "Identifikace mechanika", value = xPlayer.identifier },

                { name = "Změny na vozidle", value = json.encode(ticketProperties) },
                { name = "Celková částka", value = ESX.Math.GroupDigits(price).."$" },

                { name = "Dílna", value = TunningZones[tunningZoneId]?.society.." | "..tunningZoneId },
                { name = "Tip pro dílnu ("..(societyCutPercentage * 100).."%)", value = ESX.Math.GroupDigits(societyCut).."$" },
            }, {
                fields = true
            })
            ownerPlayer.removeAccountMoney('bank', price)
            lib.callback("strin_tunning:setVehicleProperties", NetworkGetEntityOwner(vehicle), function()
                xPlayer.showNotification("Vozidlo úspěšně upraveno!", { type = "success" })
            end, vehicleProperties, NetworkGetNetworkIdFromEntity(vehicle))
        end)
    end
end, {
    event = "usingItem"
})

RegisterNetEvent("strin_tunning:stopTunning", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    if(not TunningPlayers[xPlayer.identifier]) then
        xPlayer.showNotification("Nejste zaregistrován v systému tunningu!", { type = "error" })
        return
    end

    local ped = GetPlayerPed(_source)
    local vehicle = GetVehiclePedIsIn(ped)
    if(vehicle ~= 0) then
        FreezeEntityPosition(vehicle, false)
    end

    
    lib.callback("strin_tunning:setVehicleProperties", NetworkGetEntityOwner(vehicle), function()
        TriggerClientEvent("strin_tunning:stopTunning", _source)
    end, TunningPlayers[xPlayer.identifier].vehicleProperties, NetworkGetNetworkIdFromEntity(vehicle))

    TunningPlayers[xPlayer.identifier] = nil
end)

AddEventHandler("strin_jobs:onPlayerDeath", function(identifier)
    if(not TunningPlayers[identifier]) then
        return
    end

    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
    if(not xPlayer) then
        return
    end

    local _source = source
    local ped = GetPlayerPed(_source)
    local vehicle = GetVehiclePedIsIn(ped)
    if(vehicle ~= 0) then
        FreezeEntityPosition(vehicle, false)
    end
    
    lib.callback("strin_tunning:setVehicleProperties", NetworkGetEntityOwner(vehicle), function()
        TriggerClientEvent("strin_tunning:stopTunning", _source)
    end, TunningPlayers[xPlayer.identifier].vehicleProperties, NetworkGetNetworkIdFromEntity(vehicle))

    TunningPlayers[xPlayer.identifier] = nil
end)

RegisterNetEvent("esx:exitedVehicle", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    if(not TunningPlayers[xPlayer.identifier]) then
        return
    end

    local ped = GetPlayerPed(_source)
    local vehicle = GetVehiclePedIsIn(ped)
    if(vehicle ~= 0) then
        FreezeEntityPosition(vehicle, false)
    end

    lib.callback("strin_tunning:setVehicleProperties", NetworkGetEntityOwner(vehicle), function()
        TriggerClientEvent("strin_tunning:stopTunning", _source)
    end, TunningPlayers[xPlayer.identifier].vehicleProperties, NetworkGetNetworkIdFromEntity(vehicle))

    TunningPlayers[xPlayer.identifier] = nil
end)

RegisterNetEvent("strin_tunning:installMod", function(modType, modValue)
    if(type(modType) ~= "string" or (type(modValue) ~= "table" and type(modValue) ~= "boolean" and type(modValue) ~= "number")) then
        return
    end
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

    -- if this goes through on an unknown modType then sql injection goes brr
    if(not IsKeyInTable(CarParts.Cosmetics, modType) and not IsKeyInTable(CarParts.Upgrades, modType)) then
        xPlayer.showNotification("Neznámý díl!", { type = "error" })
        return
    end

    if(not TunningPlayers[xPlayer.identifier]) then
        xPlayer.showNotification("Nejste zaregistrován v systému!", { type = "error" })
        return
    end

    local ticketId = TunningPlayers[xPlayer.identifier].ticketId
    MySQL.update(("UPDATE `tunning_tickets` SET `%s` = ? WHERE `id` = ?"):format(modType), {
        type(modValue) ~= "table" and modValue or json.encode(modValue),
        ticketId
    }, function()
        lib.callback("strin_tunning:setVehicleProperties", NetworkGetEntityOwner(vehicle), function()
            xPlayer.showNotification("Nový díl zapsán na lístek.")
        end, {
            [modType] = modValue
        }, NetworkGetNetworkIdFromEntity(vehicle))
    end)
end)

lib.callback.register("strin_tunning:getVehicleTickets", function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return {}
    end

    local ped = GetPlayerPed(_source)
    local vehicle = GetVehiclePedIsIn(ped)
    if(vehicle == 0) then
        return {}
    end

    local tickets = GetTicketsForVehicle(vehicle)
    if(#tickets > 0) then
        for k,v in pairs(tickets) do
            if(CountKeysInTable(v) > 2) then
                v.price = CalculateTunningPrice(GetVehiclePropertiesFromTicket(v), GetEntityModel(vehicle))
            end
        end
    end
    return tickets
end)

function CreateTicketForVehicle(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle)
    return MySQL.insert.await("INSERT INTO `tunning_tickets` SET `plate` = ?", { plate:upper() })
end

function GetNearestTunningZoneId(playerId)
    local ped = GetPlayerPed(playerId)
    local coords = GetEntityCoords(ped)
    local tunningZoneId = nil
    local distanceToTunningZone = 15000.0
    for k,v in pairs(TunningZones) do
        local distance = #(coords - v.coords)
        if(distance < distanceToTunningZone) then
            tunningZoneId = k
            distanceToTunningZone = distance
        end
    end
    return (distanceToTunningZone < 15) and tunningZoneId or nil
end

function GetTicketsForVehicle(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle)
    local tickets = MySQL.query.await("SELECT * FROM `tunning_tickets` WHERE `plate` = ?", { plate:upper() })
    --print(tickets)
    for k,v in pairs(tickets) do
        --print(k, json.encode(v, { indent = true }))
        --for _,ticket in pairs(v) do
            if(v.tyreSmokeColor) then
                tickets[k].tyreSmokeColor = json.decode(v.tyreSmokeColor)
            end
            if(v.neonColor) then
                tickets[k].neonColor = json.decode(v.neonColor)
            end
            if(v.neonEnabled) then
                tickets[k].neonEnabled = json.decode(v.neonEnabled)
            end
        --end
    end
    return tickets
end

function GetVehiclePropertiesFromTicket(ticketData)
    local vehicleProperties = {}
    for k,v in pairs(ticketData) do
        if(k ~= "id" and k ~= "plate") then
            if(type(v) == "string") then
                vehicleProperties[k] = json.decode(v)
                /*local firstChar = v:sub(1,1)
                if(firstChar == "[" or firstChar == "{") then
                    vehicleProperties[k] = json.decode(v)
                end*/
            else
                vehicleProperties[k] = v
            end
        end
    end
    return vehicleProperties
end

local OtherVehicleProperties = { "neonEnabled", "modSmokeEnabled", "xenonColor", "wheels" }

function IsKeyInTable(desiredTable, keyName, isRecursive)
    local foundKey = false
    for k,v in pairs(desiredTable) do
        if(k == keyName or v == keyName or (type(v) == "table" and v?.modType == keyName)) then
            foundKey = true
            break
        end
        if(type(v) == "table" and not v?.modType and not foundKey) then
            foundKey = IsKeyInTable(v, keyName, true)
        end
    end
    if(not foundKey and not isRecursive) then
        foundKey = IsKeyInTable(OtherVehicleProperties, keyName, true)
    end
    return foundKey
end

function CalculateTunningPrice(properties, vehicleModelName)
    local vehiclePrice = GetVehiclePrice(vehicleModelName)
    local price = 0
    for k,v in pairs(properties) do     
        if((k == "modSmokeEnabled") or (k == "wheels") or (k == "modFrontWheels") or (k == "neonEnabled") or (k == "xenonColor")) then
            if(k == "modSmokeEnabled") then
                local mod = CarParts.Cosmetics.wheels.tyreSmokeColor
                local modPrice = math.floor(vehiclePrice * (type(mod.price) == "number" and mod.price or mod.price[1]) / 100)
                price += modPrice
            end
            if(k == "wheels") then
                local mod = { price = 1.0 }
                local wheelTypes = CarParts.Cosmetics.wheels.modFrontWheels.wheelTypes
                for k,v in pairs(wheelTypes) do
                    if(v.index == v) then
                        mod = v
                    end
                end
                local modPrice = math.floor(vehiclePrice * (type(mod.price) == "number" and mod.price or mod.price[1]) / 100)
                price += modPrice
            end
        elseif((k == "modXenon" and v == 1) or k ~= "modXenon") then
            if(v == true)  then
                local mod = nil
                if(CarParts.Upgrades[k]) then
                    mod = CarParts.Upgrades[k]
                elseif(CarParts.Cosmetics[k]) then
                    mod = CarParts.Cosmetics[k]
                end
                if(mod) then     
                    local modPrice = math.floor(vehiclePrice * (type(mod.price) == "number" and mod.price or mod.price[1]) / 100) 
                    price += modPrice
                end
            else
                local mod = { price = 1.0 }
                if(CarParts.Upgrades[k]) then
                    mod = CarParts.Upgrades[k]
                    if(k ~= "modTurbo") then
                        if(v > -1) then
                            mod.price = type(mod.price) == "table" and mod.price[v + 1] or mod.price
                        end
                    else
                        mod.price = type(mod.price) == "table" and mod.price[1] or mod.price
                    end
                elseif(CarParts.Cosmetics[k] or not CarParts.Upgrades[k]) then
                    mod = CarParts.Cosmetics[k]
                    if(not mod) then
                        if(CarParts.Cosmetics.bodyparts[k]) then
                            mod = CarParts.Cosmetics.bodyparts[k]
                        end
                        if(CarParts.Cosmetics.wheels[k]) then
                            mod = CarParts.Cosmetics.wheels[k]
                        end
                        if(CarParts.Cosmetics.respray[k]) then
                            mod = CarParts.Cosmetics.respray[k]
                        end
                    end
                end
                if(v == -1) then
                    mod.price = 1.0
                end
                --.print(json.encode(mod.price))
                local modPrice = math.floor(vehiclePrice * mod.price / 100) 
                price += modPrice
            end
        end
    end
    return price
end

function GetVehiclePrice(vehicleModelName)
    local price = VehicleShop:GetVehiclePrice(vehicleModelName) or 50000
    return price
end

AddEventHandler("onResourceStop", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        for k,v in pairs(TunningPlayers) do
            if(v) then
                local xPlayer = ESX.GetPlayerFromIdentifier(k)
                if(xPlayer) then
                    TriggerClientEvent("strin_tunning:stopTunning", xPlayer.source, v.vehicleNetId, v.vehicleProperties)
                else
                    local vehicle = NetworkGetEntityFromNetworkId(v.vehicleNetId)
                    if(DoesEntityExist(vehicle)) then
                        local vehicleCoords = GetEntityCoords(vehicle)
                        local closestPlayer = ESX.OneSync.GetClosestPlayer(vehicleCoords, 300.0)
                        if(closestPlayer?.id) then
                            lib.callback("strin_tunning:setVehicleProperties", closestPlayer?.id, function()
                                -- we dont want to pause the loop, so cb >>
                            end)
                        else
                            DeleteEntity(vehicle)
                        end
                    end
                end
            end
        end
    end
end)