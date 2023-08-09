JailedPlayers = {}

Inventory = exports.ox_inventory
Base = exports.strin_base
LawEnforcementJobs = exports.strin_jobs:GetLawEnforcementJobs() or {}

Base:RegisterWebhook("JAIL", "https://discord.com/api/webhooks/680579714250702848/5KfFNYwjPh7kO88tkuY-89tP0BkLibUtrbn5NjH24r1fhCmVnaW6HTnFpALa_Zda2QeW")

Citizen.CreateThread(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `jail` (
            `character_identifier` VARCHAR(255) NOT NULL,
            `reason` VARCHAR(255) NULL DEFAULT NULL,
            `jailed_on` BIGINT(24) NULL DEFAULT NULL,
            `duration` FLOAT NOT NULL DEFAULT 0,

            PRIMARY KEY (`owner`),
            UNIQUE KEY (`owner`)
        )
    ]])
end)

AddEventHandler("esx:playerLoaded", function(playerId, xPlayer)
    local characterIdentifier = xPlayer.identifier..":"..xPlayer.get("char_id")
    local data = MySQL.single.await("SELECT * FROM `jail` WHERE `character_identifier` = ?", { characterIdentifier })

    if(not data or not next(data)) then
        return
    end
    JailPlayer(targetPlayer.source, data)
end)

ESX.RegisterCommand("jail", "admin", function(xPlayer, args)
    if(not args.targetId or not args.reason or not args.duration) then
        return
    end
    local _source = xPlayer?.source
    if(not _source) then
        xPlayer = {
            showNotification = function(message) print(message) end
        }
    end
    local targetPlayer = ESX.GetPlayerFromId(args.targetId)
    if(not targetPlayer) then
        xPlayer.showNotification("Daný hráč neexistuje!", { type = "error" })
        return
    end
    if(JailedPlayers[targetPlayer.source]) then
        xPlayer.showNotification("Hráč již je ve vězení!", { type = "error" })
        return
    end
    local data = {
        character_identifier = targetPlayer.identifier..":"..targetPlayer.get("char_id"),
        duration = args.duration,
        reason = args.reason:len() == 0 and "Neuvedeno" or ESX.SanitizeString(args.reason),
        jailed_on = os.time()
    }
    MySQL.prepare("INSERT INTO `jail` SET `character_identifier` = ?, `duration` = ?, `reason` = ?, `jailed_on` = ?", {
        data.character_identifier,
        data.duration,
        data.reason,
        data.jailed_on
    }, function()
        Inventory:ConfiscateInventory(targetPlayer.source)
        JailPlayer(targetPlayer.source, data)
    end)
end, true, {
    help = "Jail",
    arguments = {
        { name = "targetId", help = "ID Hráče", type = "number" },
        { name = "duration", help = "Doba trvání (v minutách)", type = "number" },
        { name = "reason", help = "Důvod jailu (jednoslovně)", type = "string" },
    }
})

ESX.RegisterCommand("unjail", "admin", function(xPlayer, args)
    if(not args.targetId or not args.reason) then
        return
    end
    local _source = xPlayer?.source
    if(not _source) then
        xPlayer = {
            showNotification = function(message) print(message) end
        }
    end
    local targetPlayer = ESX.GetPlayerFromId(args.targetId)
    if(not targetPlayer) then
        xPlayer.showNotification("Daný hráč neexistuje!", { type = "error" })
        return
    end
    if(not JailedPlayers[targetPlayer.source]) then
        xPlayer.showNotification("Hráč není ve vězení!", { type = "error" })
        return
    end
    local character_identifier = targetPlayer.identifier..":"..targetPlayer.get("char_id")
    Base:DiscordLog("JAIL", "THE RAVE PROJECT - UNJAIL - ADMIN", {
        { name = "Jméno admina", value = xPlayer.getName() },
        { name = "Identifikace admina", value = xPlayer.identifier..":"..xPlayer.get("char_id") },
        { name = "Jméno stíhaného", value = targetPlayer.get("fullname") },
        { name = "Identifikace stíhaného", value = character_identifier },
        { name = "Důvod propuštění", value = args.reason },
        { name = "Trvání uvěznění", value = data.duration.." minut" },
    }, {
        fields = true
    })
    UnjailPlayer(targetPlayer.source, character_identifier)
end, true, {
    help = "Unjail",
    arguments = {
        { name = "targetId", help = "ID Hráče", type = "number" },
        { name = "reason", help = "Důvod unjailu (jednoslovně)", type = "string" },
    }
})

RegisterNetEvent("strin_jail:jailPlayer", function(playerId, duration, reason)
    if(type(playerId) ~= "number" or type(duration) ~= "number" or type(reason) ~= "string") then
        return
    end
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    if(duration <= 0) then
        xPlayer.showNotification("Neplatná doba.", { type = "error" })
        return
    end

    local job = xPlayer.getJob()
    if((not lib.table.contains(LawEnforcementJobs, job.name)) and (xPlayer.getGroup() ~= "admin")) then
        xPlayer.showNotification("Na tuto akci nemáte dostatečně oprávnění", { type = "error" })
        return
    end

    local targetPlayer = ESX.GetPlayerFromId(playerId)
    if(not targetPlayer) then
        xPlayer.showNotification("Daný hráč neexistuje!", { type = "error" })
        return
    end

    local distance = #(GetEntityCoords(GetPlayerPed(_source)) - GetEntityCoords(GetPlayerPed(targetPlayer.source)))
    if(distance > 15) then
        xPlayer.showNotification("Od daného hráče jste moc daleko!", { type = "error" })
        return
    end

    local data = {
        character_identifier = targetPlayer.identifier..":"..targetPlayer.get("char_id"),
        duration = duration,
        reason = reason:len() == 0 and "Neuvedeno" or ESX.SanitizeString(reason),
        jailed_on = os.time()
    }
    MySQL.prepare("INSERT INTO `jail` SET `character_identifier` = ?, `duration` = ?, `reason` = ?, `jailed_on` = ?", {
        data.character_identifier,
        data.duration,
        data.reason,
        data.jailed_on
    }, function()
        Base:DiscordLog("JAIL", "THE RAVE PROJECT - JAIL", {
            { name = "Jméno strážníka", value = xPlayer.get("fullname") },
            { name = "Identifikace strážníka", value = xPlayer.identifier..":"..xPlayer.get("char_id") },
            { name = "Jméno stíhaného", value = targetPlayer.get("fullname") },
            { name = "Identifikace stíhaného", value = data.character_identifier },
            { name = "Důvod uvěznění", value = data.reason },
            { name = "Trvání uvěznění", value = data.duration.." minut" },
        }, {
            fields = true
        })
        Inventory:ConfiscateInventory(targetPlayer.source)
        JailPlayer(targetPlayer.source, data)
    end)
end)

AddEventHandler("playerDropped", function()
    local _source = source
    if(JailedPlayers[_source]) then
        JailedPlayers[_source] = nil
    end
end)

/*function GetJailedPlayer(characterIdentifier)
    local jailedPlayer, jailedPlayerIndex
    for k,v in pairs(JailedPlayers) do
        if(v.owner == characterIdentifier) then
            jailedPlayer = v
            jailedPlayerIndex = k
            break
        end
    end
    return jailedPlayer, jailedPlayerIndex
end*/

function JailPlayer(playerId, data)
    JailedPlayers[playerId] = data
    targetPlayer.showNotification(("Byl/a jste uvězněn/a na %s sekund."):format(math.floor(data.duration * 60)))
    local ped = GetPlayerPed(playerId)
    FreezeEntityPosition(ped, true)
    SetEntityCoords(ped, JAIL_LOCATION)
    Citizen.Wait(2000)
    FreezeEntityPosition(ped, false)
    TriggerClientEvent("strin_jail:showTimer", playerId, 
        (data.jailed_on + math.floor(data.duration * 60)) - os.time()
    )
end

function UnjailPlayer(playerId, owner)
    MySQL.prepare("DELETE FROM `jail` WHERE `character_identifier` = ?", { owner },  function()
        local ped = GetPlayerPed(playerId)
        SetEntityCoords(ped, JAIL_OUTSIDE_LOCATION)
        TriggerClientEvent("esx:showNotification", playerId, "Byl/a jste propuštěn/a.", {
            type = "success"
        })
        Inventory:ReturnInventory(playerId)
        JailedPlayers[k] = nil
    end)
end

Citizen.CreateThread(function()
    while true do
        local sleep = (next(JailedPlayers)) and 5000 or 10000   
        for k,v in pairs(JailedPlayers) do
            local ped = GetPlayerPed(k)
            local coords = GetEntityCoords(ped)
            local distanceToJail = #(coords - JAIL_LOCATION)
            if(distanceToJail > 100) then
                SetEntityCoords(ped, JAIL_LOCATION)
            end
            local jailedUntilTime = v.jailed_on + (v.duration * 60)
            local currentTime = os.time()
            if((currentTime - jailedUntilTime) <= 0) then
                UnjailPlayer(k, v.character_identifier)
            end
        end
        Citizen.Wait(5000)
    end
end)