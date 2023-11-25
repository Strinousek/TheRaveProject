local SavedPlayers = {}

AddEventHandler("esx:playerLoaded", function(playerId, xPlayer)
    if(SavedPlayers[xPlayer.identifier]) then
        local ped = GetPlayerPed(playerId)
        TriggerEvent("strin_jobs:allowHeal", xPlayer.identifier)
        lib.callback("strin_jobs:setHealth", xPlayer.source, function() end, SavedPlayers[xPlayer.identifier].health)
        SetPedArmour(ped, SavedPlayers[xPlayer.identifier].armour)
    end
end)

AddEventHandler("playerDropped", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end
    local ped = GetPlayerPed(_source)
    local health = GetEntityHealth(ped)
    if(health < 5) then
        return
    end
    local armour = GetPedArmour(ped)
    SavedPlayers[xPlayer.identifier] = {
        health = health,
        armour = armour
    }
end)

local PlayerStats = {}

function GetFormattedPlayedTime(time)
  local days = math.floor(time / 86400)
  local remaining = time % 86400
  local hours = math.floor(remaining / 3600)
  remaining = remaining % 3600
  local minutes = math.floor(remaining / 60)
  remaining = remaining % 60
  local seconds = remaining
  /*if (hours < 10) then
    hours = "0" .. tostring(hours)
  end
  if (minutes < 10) then
    minutes = "0" .. tostring(minutes)
  end
  if (seconds < 10) then
    seconds = "0" .. tostring(seconds)
  end*/
  return {
    days = days,
    hours = hours,
    minutes = minutes,
    seconds = seconds
  }
end

exports("GetFormattedPlayedTime", GetFormattedPlayedTime)


RegisterNetEvent("esx:playerLoaded", function(playerId, xPlayer)
    if(not PlayerStats[xPlayer.identifier]) then
        PlayerStats[xPlayer.identifier] = {
            playedTime = 0,
        }
        xPlayer.set("played_time", GetFormattedPlayedTime(0))
    else
        xPlayer.set("played_time", GetFormattedPlayedTime(PlayerStats[xPlayer.identifier].playedTime))
    end
end)

Citizen.CreateThread(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `user_stats` (
            `identifier` VARCHAR(255) NOT NULL COLLATE 'latin1_swedish_ci',
            `played_time` BIGINT(20) NOT NULL DEFAULT '0',
            PRIMARY KEY (`identifier`) USING BTREE,
            UNIQUE INDEX `identifier` (`identifier`) USING BTREE
        )
        COLLATE='latin1_swedish_ci'
        ENGINE=InnoDB
        ;
    ]])
    MySQL.query.await([[
        ALTER TABLE `user_stats`
            ADD IF NOT EXISTS `identifier` VARCHAR(255) NOT NULL COLLATE 'latin1_swedish_ci',
            ADD IF NOT EXISTS `played_time` BIGINT(20) NOT NULL DEFAULT '0';
    ]])
    local results = MySQL.query.await("SELECT * FROM `user_stats`")
    for i=1, #results do
        local result = results[i]
        PlayerStats[result.identifier] = {
            playedTime = tonumber(result.played_time)
        }
    end
    local currentTick = 1
    while true do
        currentTick += 1
        for identifier, data in each(PlayerStats) do
            local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
            if(xPlayer and xPlayer?.source) then
                data.playedTime += 1
                if(currentTick >= 30) then
                    xPlayer.set("played_time", GetFormattedPlayedTime(data.playedTime))
                    MySQL.prepare("INSERT INTO `user_stats` SET `identifier` = ?, `played_time` = ? ON DUPLICATE KEY UPDATE `identifier` = ?, `played_time` = ?", {
                        identifier,
                        data.playedTime,
                        identifier,
                        data.playedTime,
                    })
                end
            end
        end
        if(currentTick >= 30) then
            currentTick = 1
        end
        Citizen.Wait(2000)
    end
end)

lib.callback.register("strin_base:getPlayerStats", function(_source)
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return false
    end
    local stats = lib.table.deepclone(PlayerStats[xPlayer.identifier])
    stats.playedTimeTable = GetFormattedPlayedTime(stats.playedTime)
    return stats
end)

/*local FoundObjects = {}
RegisterNetEvent("strin_base:foundObject", function(object)
    local _source = source
    if(not FoundObjects[_source]) then
        return
    end

    table.insert(FoundObjects[_source], object)
end)

ESX.RegisterCommand("objfind", "admin", function(xPlayer, args)
    if(not args.object and not FoundObjects[xPlayer.source]) then
        return
    end
    if(not args.object and FoundObjects[xPlayer.source]) then
        TriggerClientEvent("strin_base:setClipboard", xPlayer.source, json.encode(FoundObjects[xPlayer.source], { indent = true }))
        FoundObjects[xPlayer.source] = nil
        return
    end
    local hash = tonumber(args.object)
    if(not hash) then
        hash = GetHashKey(args.object)
    end
    FoundObjects[xPlayer.source] = {}
    TriggerClientEvent("strin_base:startObjectFinder", xPlayer.source, hash)
end, false, {
    help = "Hledač objektů",
    arguments = {
        {
            name = "object",
            help = "Název objektu / hash",
            type = "any"
        }
    }
})

AddEventHandler("playerDropped", function()
    local _source = source
    if(FoundObjects[_source]) then
        FoundObjects[_source] = nil
    end
end)*/

function LoadJSONFile(resourceName, filePath, defaultValue, returnInJSON)
    local content = type(defaultValue) == "string" and defaultValue or json.encode(defaultValue)
    local file = LoadResourceFile(resourceName, filePath)
    if(not file) then
        SaveResourceFile(resourceName, filePath, content, -1)
        return json.decode(content)
    end
    content = file:len() == 0 and content or file
    return ((returnInJSON) and content or json.decode(content))
end

exports("LoadJSONFile", LoadJSONFile)

ESX.RegisterCommand("id", "user", function(xPlayer)
    xPlayer.showNotification("Vaše ID: "..xPlayer.source, { duration = 10000 })
end)

local DebuggedResources = {}
local DebugModeStatus = false
ESX.RegisterCommand("debugmode", "admin", function(xPlayer)
    DebugModeStatus = not DebugModeStatus
    xPlayer.showNotification("Debug Mode: "..(DebugModeStatus and "ON" or "OFF"))
    TriggerEvent("strin_base:debugStateChange", DebugModeStatus, function()
        if(DebugModeStatus) then
            table.insert(DebuggedResources, GetInvokingResource() or GetCurrentResourceName())
        end
        print((GetInvokingResource() or GetCurrentResourceName())..": DEBUG MODE - "..(DebugModeStatus and "ON" or "OFF"))
    end)
    if(not DebugModeStatus) then
        DebuggedResources = {}
    end
end)

AddEventHandler("onResourceStart", function(resource)
    if(not lib.table.contains(DebuggedResources, resource)) then
        return
    end

    TriggerEvent("strin_base:debugStateChange", DebugModeStatus, function()
        print((GetInvokingResource() or GetCurrentResourceName())..": DEBUG MODE - "..(DebugModeStatus and "ON" or "OFF"))
    end)
end)

lib.callback.register("strin_base:getPhoneNumber", function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    return xPlayer.get("phone_number")
end)