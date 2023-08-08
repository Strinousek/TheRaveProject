local DeadPlayers = {}
local AllowedRevives = {}
local AllowedHeals = {}

AddEventHandler("esx:playerLoaded", function(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if(not xPlayer) then
        return
    end
    if(DeadPlayers[xPlayer.identifier]) then
        lib.callback.await("strin_jobs:setHealth", playerId, 0)
        return
    end
end)

RegisterNetEvent("esx:onPlayerDeath", function(data)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        DropPlayer(_source, "Hráč není uveden v systému.")
        return
    end
    if(DeadPlayers[xPlayer.identifier]) then
        return
    end
    DeadPlayers[xPlayer.identifier] = {
        distress = false,
        victimId = _source,
        deathCause = data.deathCause,
        deathCoords = data.victimCoords,
        killedByPlayer = data.killedByPlayer,
        killerId = data.killerServerId,
        deadOn = GetGameTimer(),
    }
    local distressJobsPlayerCount = GetDistressJobsPlayerCount()
    local timer = (distressJobsPlayerCount <= 0) and RespawnTimer or (RespawnTimer * 2)
    TriggerClientEvent("strin_jobs:startDeathTimer", _source, timer)
    TriggerEvent("strin_jobs:onPlayerDeath", xPlayer.identifier, DeadPlayers[xPlayer.identifier])
end)

RegisterNetEvent("strin_jobs:checkDeathTimer", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return 
    end
    if(not DeadPlayers[xPlayer.identifier]) then
        return
    end
    local deadOn = DeadPlayers[xPlayer.identifier].deadOn
    local currentTime = GetGameTimer()
    local baseTimer = RespawnTimer
    if((currentTime - deadOn) < baseTimer) then
        xPlayer.showNotification("Snažíte se oživit moc brzy!", {type = "error"})
        return
    end
    local ped = GetPlayerPed(_source)
    local success = RevivePlayer(_source)
    if(success) then
        Citizen.Wait(1000)
        SetEntityCoords(ped, RespawnLocation)
    end
end)

RegisterNetEvent("strin_jobs:startDistress", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    if(not DeadPlayers[xPlayer.identifier]) then
        return
    end

    if(DeadPlayers[xPlayer.identifier].distress) then
        return
    end
    local ped = GetPlayerPed(_source)
    local coords = GetEntityCoords(ped)
    DeadPlayers[xPlayer.identifier].distress = true
    /*for _,jobName in pairs(DistressJobs) do
        TriggerEvent("esx_addons_gcphone:startCallWithIdentifier", xPlayer.identifier, jobName, "Tísňový signál", coords)
        local xPlayers = ESX.GetExtendedPlayers("job", jobName)
        for _, xPlayer in pairs(xPlayers) do
            TriggerClientEvent("strin_jobs:addDistressBlip", xPlayer.source, DeadPlayers[xPlayer.identifier])
        end
    end*/
    xPlayer.showNotification("Zavolal jste o pomoc!", {type = "success"})
end)

RegisterNetEvent("strin_jobs:playerRevived", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        DropPlayer(_source, "Hráč není uveden v systému.")
        return
    end
    if(not AllowedRevives[xPlayer.identifier]) then
        lib.callback("strin_jobs:setHealth", _source, function()
            print(("Hráč %s (%s) se pokusil oživit!"):format(xPlayer.identifier, _source))
        end, 0)
        return
    end

    AllowedRevives[xPlayer.identifier] = nil
end)

RegisterNetEvent("strin_jobs:playerHealed", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        DropPlayer(_source, "Hráč není uveden v systému.")
        return
    end
    if(not AllowedHeals[xPlayer.identifier]) then
        lib.callback("strin_jobs:setHealth", _source, function()
            print(("Hráč %s (%s) se pokusil ošetřit!"):format(xPlayer.identifier, _source))
        end, AllowedHeals[xPlayer.identifier].lastHealth)
        return
    end
    AllowedHeals[xPlayer.identifier] = nil
end)

RegisterNetEvent("strin_jobs:revivePlayer", function(targetNetId)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    local job = xPlayer.getJob()
    if(not HasAccessToAction(job.name, "medical")) then
        xPlayer.showNotification("K této akci nemáte přístup!", {type = "error"})
        return
    end

    local targetPlayer = ESX.GetPlayerFromId(targetNetId)
    if(not targetPlayer) then
        xPlayer.showNotification("Cílový hráč neexistuje!", {type = "error"})
        return
    end

    local arePlayersNearEachother = ArePlayersNearEachother(_source, targetNetId)
    if(not arePlayersNearEachother) then
        xPlayer.showNotification("Nejste hráči dostatečně blízko!", {type = "error"})
        return
    end

    local success = RevivePlayer(targetNetId)
    if(not success) then
        xPlayer.showNotification("Nepodařilo se Vám resuscitovat hráče!", {type = "success"})
        return
    end
    xPlayer.showNotification("Úspěšně jste resuscitoval hráče!", {type = "success"})
end)

RegisterNetEvent("strin_jobs:healPlayer", function(targetNetId)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    local job = xPlayer.getJob()
    if(not HasAccessToAction(job.name, "medical")) then
        xPlayer.showNotification("K této akci nemáte přístup!", {type = "error"})
        return
    end

    local targetPlayer = ESX.GetPlayerFromId(targetNetId)
    if(not targetPlayer) then
        xPlayer.showNotification("Cílový hráč neexistuje!", {type = "error"})
        return
    end

    local arePlayersNearEachother = ArePlayersNearEachother(_source, targetNetId)
    if(not arePlayersNearEachother) then
        xPlayer.showNotification("Nejste hráči dostatečně blízko!", {type = "error"})
        return
    end

    local success = HealPlayer(targetNetId, 100)
    if(not success) then
        xPlayer.showNotification("Nepodařilo se Vám ošetřilt hráče!", {type = "success"})
        return
    end
    xPlayer.showNotification("Úspěšně jste ošetřil hráče!", {type = "success"})
end)

function GetDistressJobsPlayerCount()
    local distressJobPlayerCount = 0
    for _,jobName in pairs(DistressJobs) do
        local xPlayers = ESX.GetExtendedPlayers("job", jobName)
        distressJobPlayerCount += #xPlayers
    end
    return distressJobPlayerCount
end

function RevivePlayer(playerId)
    local playerId = tonumber(playerId)
    if(not playerId) then
        return
    end

    local xPlayer = ESX.GetPlayerFromId(playerId)
    if(not xPlayer) then
        return
    end

    DeadPlayers[xPlayer.identifier] = nil
    AllowedRevives[xPlayer.identifier] = true
    TriggerClientEvent("strin_jobs:revive", playerId)
    return true
end

exports("RevivePlayer", RevivePlayer)

function HealPlayer(playerId, amount)
    local playerId = tonumber(playerId)
    if(not playerId) then
        return
    end

    local amount = tonumber(amount)
    if(not amount) then
        return
    end

    local xPlayer = ESX.GetPlayerFromId(playerId)
    if(not xPlayer) then
        return
    end

    local ped = GetPlayerPed(playerId)
    AllowedHeals[xPlayer.identifier] = {
        lastHealth = GetEntityHealth(ped)
    }
    lib.callback.await("strin_jobs:setHealth", playerId, amount)
    return true
end

exports("HealPlayer", HealPlayer)

AddEventHandler("playerDropped", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end
    if(AllowedRevives[xPlayer.identifier]) then
        AllowedRevives[xPlayer.identifier] = nil
    end
    if(AllowedHeals[xPlayer.identifier]) then
        AllowedHeals[xPlayer.identifier] = nil
    end
end)

ESX.RegisterCommand("revive", "admin", function(xPlayer, args)
    if(xPlayer and GetEntityHealth(GetPlayerPed(xPlayer.source)) <= 0 and not args.playerId) then
        args.playerId = xPlayer.source
    end
    if(args.playerId) then
        local success = RevivePlayer(args.playerId)
        if(success) then
            if(xPlayer) then
                xPlayer.showNotification(("Oživil jste hráče - %s"):format(args.playerId), {type = "success"})
            else
                print(("Hrac - %s - byl oziven konzoli!"):format(args.playerId))
            end
        end
    end
end, true, {
    help = "Oživení hráče",
    arguments = {
        {
            name = "playerId",
            help = "ID hráče",
            type = "number"
        }
    }
})

ESX.RegisterCommand("heal", "admin", function(xPlayer, args)
    if(args.playerId and args.health) then
        local success = HealPlayer(args.playerId, args.health)
        if(success) then
            if(xPlayer) then
                xPlayer.showNotification(("Ošetřil jste hráče - %s (%s)"):format(args.playerId, args.health), {type = "success"})
            else
                print(("Hráč - %s (%s) - byl ošetřen konzolí!"):format(args.playerId, args.health))
            end
        end
    end
end, true, {
    help = "Ošetření hráče",
    arguments = {
        {
            name = "playerId",
            help = "ID hráče",
            type = "number"
        },
        {
            name = "health",
            help = "Množství HP",
            type = "number"
        },
    }
})