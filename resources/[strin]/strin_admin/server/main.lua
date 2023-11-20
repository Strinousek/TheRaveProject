Base = exports.strin_base
Society = exports.strin_society

Base:RegisterWebhook("BANS", "https://discord.com/api/webhooks/1134543967363535039/yzfZwWdGogjHwhiOT-K3pOcM5fI-OELhC6I3lFxHohQirKvx_mTlKmCrQj5lPIzgKEcD")
Base:RegisterWebhook("STALKING", "https://discord.com/api/webhooks/679812881306615835/aTEEVvBIFz9MLifKx9QYikvMeXo99sYpnFajcGNkgiYa7-gnKlYHBHsvOpKwqUU6Twy9")


RegisterCommand("adcl", function(source)
    if(source ~= 0) then
        return
    end

    local isAllowed = GetConvarInt("sv_fxdkMode", 0)
    if(not isAllowed) then
        print("ADCL: ON")
        SetConvarReplicated("sv_fxdkMode", "1")
    else
        print("ADCL: OFF")
        SetConvarReplicated("sv_fxdkMode", "0")
    end
end, true)

ESX.RegisterCommand("addsocietymoney", "admin", function(xPlayer, args)
    if(not args.society or not args.amount) then return end
    local _source = tonumber(xPlayer?.source)
    if(not _source) then
        xPlayer = { showNotification = function(message) print(message) end }
    end
    
    if(_source and not lib.table.contains(Admins, xPlayer.identifier)) then
        xPlayer.showNotification("Na tuto akci nemáte dostatečná práva.", { type = "error" })
        return
    end

    local society = Society:GetSociety(args.society)
    if(not society) then
        xPlayer.showNotification("Taková společnost neexistuje!", { type = "error" })
        return
    end
    if(args.amount <= 0) then
        xPlayer.showNotification("Obnos musí být více než 0!", { type = "error" })
        return
    end

    local success = Society:AddSocietyMoney(society.name, args.amount)
    if(not success) then
        xPlayer.showNotification("Peníze se nezdařilo přidat!", { type = "error" })
        return
    end
    Base:DiscordLog("STALKING", "THE RAVE PROJECT - PŘIDÁNÍ PENĚZ DO SPOLEČNOSTI", {
        { name = "Jméno admina", value = ESX.SanitizeString(_source and GetPlayerName(_source) or "Konzole") },
        { name = "Identifikace admina", value = _source and xPlayer.identifier or "{}" },
        { name = "Jméno společnosti", value = ESX.SanitizeString(society.label) },
        { name = "Identifikace společnosti", value = society.name },
        { name = "Původní zůstatek společnosti", value = ESX.Math.GroupDigits(society.balance).."$" },
        { name = "Částka", value = ESX.Math.GroupDigits(args.amount).."$" },
    }, {
        fields = true,
    })
end, true, {
    help = "Přidat peníze do společnosti",
    arguments = {
        { name = "society", type = "string", help = "Kód společnosti" },
        { name = "amount", type = "number", help = "Částka" },
    }
})

ESX.RegisterCommand("removesocietymoney", "admin", function(xPlayer, args)
    if(not args.society or not args.amount) then return end
    local _source = tonumber(xPlayer?.source)
    if(not _source) then
        xPlayer = { showNotification = function(message) print(message) end }
    end
    
    if(_source and not lib.table.contains(Admins, xPlayer.identifier)) then
        xPlayer.showNotification("Na tuto akci nemáte dostatečná práva.", { type = "error" })
        return
    end
    
    local society = Society:GetSociety(args.society)
    if(not society) then
        xPlayer.showNotification("Taková společnost neexistuje!", { type = "error" })
        return
    end
    if((society.balance - args.amount) < 0) then
        xPlayer.showNotification("Nelze jít do mínusu!", { type = "error" })
        return
    end

    local success = Society:RemoveSocietyMoney(society.name, args.amount)
    if(not success) then
        xPlayer.showNotification("Peníze se nezdařilo odebrat!", { type = "error" })
        return
    end
    Base:DiscordLog("STALKING", "THE RAVE PROJECT - ODEBRÁNÍ PENĚZ ZE SPOLEČNOSTI", {
        { name = "Jméno admina", value = ESX.SanitizeString(_source and GetPlayerName(_source) or "Konzole") },
        { name = "Identifikace admina", value = _source and xPlayer.identifier or "{}" },
        { name = "Jméno společnosti", value = ESX.SanitizeString(society.label) },
        { name = "Identifikace společnosti", value = society.name },
        { name = "Původní zůstatek společnosti", value = ESX.Math.GroupDigits(society.balance).."$" },
        { name = "Částka", value = ESX.Math.GroupDigits(args.amount).."$" },
    }, {
        fields = true,
    })
end, true, {
    help = "Odebrat peníze ze společnosti",
    arguments = {
        { name = "society", type = "string", help = "Kód společnosti" },
        { name = "amount", type = "number", help = "Částka" },
    }
})

ESX.RegisterCommand("setsocietymoney", "admin", function(xPlayer, args)
    if(not args.society or not args.amount) then return end
    local _source = tonumber(xPlayer?.source)
    if(not _source) then
        xPlayer = { showNotification = function(message) print(message) end }
    end
    
    if(_source and not lib.table.contains(Admins, xPlayer.identifier)) then
        xPlayer.showNotification("Na tuto akci nemáte dostatečná práva.", { type = "error" })
        return
    end
    
    local society = Society:GetSociety(args.society)
    if(not society) then
        xPlayer.showNotification("Taková společnost neexistuje!", { type = "error" })
        return
    end
    if(args.amount < 0) then
        xPlayer.showNotification("Nelze jít do mínusu!", { type = "error" })
        return
    end

    local success = Society:SetSocietyMoney(society.name, args.amount)
    if(not success) then
        xPlayer.showNotification("Peníze se nezdařilo nastavit!", { type = "error" })
        return
    end
    Base:DiscordLog("STALKING", "THE RAVE PROJECT - NASTAVENÍ PENĚZ SPOLEČNOSTI", {
        { name = "Jméno admina", value = ESX.SanitizeString(_source and GetPlayerName(_source) or "Konzole") },
        { name = "Identifikace admina", value = _source and xPlayer.identifier or "{}" },
        { name = "Jméno společnosti", value = ESX.SanitizeString(society.label) },
        { name = "Identifikace společnosti", value = society.name },
        { name = "Původní zůstatek společnosti", value = ESX.Math.GroupDigits(society.balance).."$" },
        { name = "Nový zůstatek společnosti", value = ESX.Math.GroupDigits(args.amount).."$" },
    }, {
        fields = true,
    })
end, true, {
    help = "Nastavit peníze společnosti",
    arguments = {
        { name = "society", type = "string", help = "Kód společnosti" },
        { name = "amount", type = "number", help = "Částka" },
    }
})

function GetPlayerIdentifiersTable(playerId, exclude)
    local playerIdentifiers = GetPlayerIdentifiers(playerId)
    local identifiers = {}
    local foundIdentifiersCount = 0
    for k, v in pairs(playerIdentifiers) do
        local separatorIndex = string.find(v, "%:")
        local identifierKey = string.sub(v, 1, separatorIndex - 1)
        if(exclude) then
            if(exclude == identifierKey or (type(exclude) == "table" and lib.table.contains(exclude, identifierKey))) then
                goto skipLoop
            end
        end 
        local identifierValue = string.sub(v, separatorIndex + 1)
        identifiers[identifierKey] = identifierValue
        foundIdentifiersCount += 1
        ::skipLoop::
    end
    return identifiers, foundIdentifiersCount
end

ESX.RegisterCommand("players", "admin", function(xPlayer)
    if(xPlayer) then
        return
    end
    if(not xPlayer) then
        for _, playerId in pairs(GetPlayers()) do
            print(GetPlayerName(tonumber(playerId)), playerId)
        end
    end
end, true)

RegisterNetEvent("strin_admin:killPlayer", function(targetId)
    if(type(targetId) ~= "number") then
        return
    end
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    
    if(not lib.table.contains(Admins, xPlayer.identifier)) then
        xPlayer.showNotification("Na tuto akci nemáte dostatečná práva.", { type = "error" })
        return
    end

    lib.callback("strin_jobs:setHealth", targetId, function()
        xPlayer.showNotification(("Hráč #%s zabit."):format(targetId))
    end, 0)
end)

RegisterNetEvent("strin_admin:summonPlayer", function(targetId)
    if(type(targetId) ~= "number") then
        return
    end
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    
    if(not lib.table.contains(Admins, xPlayer.identifier)) then
        xPlayer.showNotification("Na tuto akci nemáte dostatečná práva.", { type = "error" })
        return
    end

    local sourcePed = GetPlayerPed(_source)
    local sourceCoords = GetEntityCoords(sourcePed)
    local targetPed = GetPlayerPed(targetId)
    SetEntityCoords(targetPed, sourceCoords)
    xPlayer.showNotification(("Hráč #%s byl vyvolán."):format(targetId))
end)

RegisterNetEvent("strin_admin:teleportToPlayer", function(targetId, intoVehicle)
    if(type(targetId) ~= "number" or type(intoVehicle) ~= "boolean") then
        return
    end
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    
    if(not lib.table.contains(Admins, xPlayer.identifier)) then
        xPlayer.showNotification("Na tuto akci nemáte dostatečná práva.", { type = "error" })
        return
    end

    local sourcePed = GetPlayerPed(_source)
    local targetPed = GetPlayerPed(targetId)
    local targetCoords = GetEntityCoords(targetPed)
    FreezeEntityPosition(sourcePed, true)
    SetEntityCoords(sourcePed, targetCoords)
    if(intoVehicle) then
        local vehicle = GetVehiclePedIsIn(targetPed)
        if(vehicle ~= 0) then
            TaskWarpPedIntoVehicle(sourcePed, vehicle, 1)
        end
    end
    xPlayer.showNotification(("Portnul jste se k hráči #%s."):format(targetId))
    FreezeEntityPosition(sourcePed, false)
end)

local Spectates = {}

RegisterNetEvent("strin_admin:spectatePlayer", function(targetId)
    if(type(targetId) ~= "number") then
        return
    end
    local _source = source
    if(Spectates[_source]) then
        local sourcePed = GetPlayerPed(_source)
        TriggerClientEvent("strin_admin:spectate", _source, Spectates[_source].id)
        Citizen.Wait(250)
        SetEntityCoords(sourcePed, Spectates[_source].lastCoords)
        Spectates[_source] = nil
        return
    end
    local xPlayer = ESX.GetPlayerFromId(_source)
    
    if(not lib.table.contains(Admins, xPlayer.identifier)) then
        xPlayer.showNotification("Na tuto akci nemáte dostatečná práva.", { type = "error" })
        return
    end

    local sourcePed = GetPlayerPed(_source)
    local targetPed = GetPlayerPed(targetId)
    local targetCoords = GetEntityCoords(targetPed)
    SetEntityCoords(sourcePed, targetCoords)
    Spectates[_source] = {
        id = targetId,
        lastCoords = GetEntityCoords(sourcePed)
    }
    TriggerClientEvent("strin_admin:spectate", _source, targetId)
end)

lib.callback.register("strin_admin:getOnlinePlayers", function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return nil
    end
    
    if(not lib.table.contains(Admins, xPlayer.identifier)) then
        xPlayer.showNotification("Na tuto akci nemáte dostatečná práva.", { type = "error" })
        return nil
    end
    
    local players = {}

    for _, playerId in pairs(GetPlayers()) do
        local playerId = tonumber(playerId)
        players[#players + 1] = {
            id = playerId,
            name = ESX.SanitizeString(GetPlayerName(playerId)),
            coords = GetEntityCoords(GetPlayerPed(playerId)),
            identifiers = GetPlayerIdentifiersTable(playerId, {
                "ip"
            })
        }
    end

    return players
end)

lib.callback.register("strin_admin:isPlayerAdmin", function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return nil
    end

    return lib.table.contains(Admins, xPlayer.identifier)
end)


lib.callback.register("strin_admin:requestVehicle", function(source, hash)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return false
    end

    if(not lib.table.contains(Admins, xPlayer.identifier)) then
        return false
    end

    local ped = GetPlayerPed(_source)
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    local vehicle = CreateVehicleServerSetter(hash, "automobile", coords, heading)
    if(not DoesEntityExist(vehicle)) then
        return false
    end

    Entity(vehicle).state.spawnedByAdmin = true

    return NetworkGetNetworkIdFromEntity(vehicle)
end)

local CurrentTime = { hour = 12, minute = 30, second = 0 }
local TimeInterval = SetInterval(function()
    CurrentTime.second += 1
    if(CurrentTime.second == 60) then
        CurrentTime.second = 0
        CurrentTime.minute += 1
        if(CurrentTime.minute == 60) then
            CurrentTime.minute = 0
            CurrentTime.hour += 1
            if(CurrentTime.hour == 24) then
                CurrentTime.hour = 0
            end
        end
    end
end, 1000)

RegisterNetEvent("strin_admin:setTime", function(hour, minute)
    if(type(hour) ~= "number" or type(minute) ~= "number") then
        return
    end
    if((hour < 0 or hour > 24) or (minute < 0 or minute > 60)) then
        return
    end
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    if(not lib.table.contains(Admins, xPlayer.identifier)) then
        return
    end

    CurrentTime.hour = hour
    CurrentTime.minute = minute
    CurrentTime.second = 0

    TriggerClientEvent("strin_admin:setTime", -1, CurrentTime.hour, CurrentTime.minute, CurrentTime.second)
end)

/*local AvailableWeatherTypes = {
    'EXTRASUNNY', 
    'CLEAR', 
    'NEUTRAL', 
    'SMOG', 
    'FOGGY', 
    'OVERCAST', 
    'CLOUDS', 
    'CLEARING', 
    'RAIN', 
    'THUNDER', 
    'SNOW', 
    'BLIZZARD', 
    'SNOWLIGHT', 
    'XMAS', 
    'HALLOWEEN',
}

local CurrentWeather = "EXTRASUNNY"

RegisterNetEvent("strin_admin:setWeather", function(weather)
    if(type(weather) ~= "string") then
        return
    end

    if(not lib.table.contains(AvailableWeatherTypes, weather)) then
        return
    end

    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    if(not lib.table.contains(Admins, xPlayer.identifier)) then
        return
    end
    if CurrentWeather == "CLEAR" or CurrentWeather == "CLOUDS" or CurrentWeather == "EXTRASUNNY"  then
        local new = math.random(1,2)
        if new == 1 then
            CurrentWeather = "CLEARING"
        else
            CurrentWeather = "OVERCAST"
        end
    elseif CurrentWeather == "CLEARING" or CurrentWeather == "OVERCAST" then
        local new = math.random(1,6)
        if new == 1 then
            if CurrentWeather == "CLEARING" then CurrentWeather = "FOGGY" else CurrentWeather = "RAIN" end
        elseif new == 2 then
            CurrentWeather = "CLOUDS"
        elseif new == 3 then
            CurrentWeather = "CLEAR"
        elseif new == 4 then
            CurrentWeather = "EXTRASUNNY"
        elseif new == 5 then
            CurrentWeather = "SMOG"
        else
            CurrentWeather = "FOGGY"
        end
    elseif CurrentWeather == "THUNDER" or CurrentWeather == "RAIN" then
        CurrentWeather = "CLEARING"
    elseif CurrentWeather == "SMOG" or CurrentWeather == "FOGGY" then
        CurrentWeather = "CLEAR"
    end
end)*/

AddEventHandler("esx:playerLoaded", function(playerId)
    if(TimeInterval) then
        TriggerClientEvent("strin_admin:setTime", playerId, CurrentTime.hour, CurrentTime.minute, CurrentTime.second)
    end
end)


local RecentlyHealedPlayers = {}
local RecentlyRevivedPlayers = {}

local CachedPlayersHealth = {}

AddEventHandler("playerDropped", function()
    local _source = source
    if(Spectates[_source]) then
        Spectates[_source] = nil
    end
    if(RecentlyHealedPlayers[_source]) then
        RecentlyHealedPlayers[_source] = nil
    end
    if(RecentlyRevivedPlayers[_source]) then
        RecentlyRevivedPlayers[_source] = nil
    end
    if(CachedPlayersHealth[_source]) then
        CachedPlayersHealth[_source] = nil
    end
end)

AddEventHandler("strin_jobs:playerHealedSuccessfully", function(xPlayer)
    RecentlyHealedPlayers[xPlayer.source] = true
    SetTimeout(6000, function()
        RecentlyHealedPlayers[xPlayer.source] = nil
    end)
end)

AddEventHandler("strin_jobs:playerRevivedSuccessfully", function(xPlayer)
    RecentlyRevivedPlayers[xPlayer.source] = true
    SetTimeout(6000, function()
        RecentlyRevivedPlayers[xPlayer.source] = nil
    end)
end)

Citizen.CreateThread(function()
    while true do
        local xPlayers = ESX.GetExtendedPlayers()
        for i=1, #xPlayers do
            local xPlayer = xPlayers[i]
            local hasGodMode = GetPlayerInvincible(xPlayer.source)
            if(hasGodMode and not xPlayer.get("isAdmin")) then
                BanOnlinePlayer(nil, xPlayer.source, -1, "Detekován God Mode")
                goto skipLoop
            end
            local ped = GetPlayerPed(xPlayer.source)
            local playerHealth = GetEntityHealth(ped) - 100
            if(CachedPlayersHealth[xPlayer.source] and not xPlayer.get("isAdmin")) then
                local maxHealth = GetEntityMaxHealth(ped) - 100
                if(CachedPlayersHealth[xPlayer.source] <= (maxHealth / 2) and playerHealth > (maxHealth * 0.8)) then
                    if(not RecentlyHealedPlayers[xPlayer.source] and not RecentlyRevivedPlayers[xPlayer.source]) then
                        BanOnlinePlayer(nil, xPlayer.source, -1, "Detekována manipulace s HP")
                    end
                end
            end
            CachedPlayersHealth[xPlayer.source] = playerHealth
            ::skipLoop::
        end
        Citizen.Wait(3000)
    end
end)

/*
local RequestedHeartbeat = false
local ReceivedPlayerHeartbeats = {}
local IgnoredPlayerHeartbeats = {}

AddEventHandler("playerJoining", function()
    local _source = source
    local name = GetPlayerName(_source)
    IgnoredPlayerHeartbeats[name] = true
end)

RegisterNetEvent("strin_admin:onPlayerJoin", function(playerId)
    local _source = source
    local name = GetPlayerName(_source)
    IgnoredPlayerHeartbeats[name] = nil
end)

RegisterNetEvent("esx:playerLoaded", function(playerId)
    Citizen.Wait(5 * 60000)
    local _source = playerId
    local name = GetPlayerName(_source)
    if(name and IgnoredPlayerHeartbeats[name]) then
        IgnoredPlayerHeartbeats[name] = nil
    end
end)

RegisterNetEvent("strin_admin:sendSpectateState", function()
    local _source = source
    local name = GetPlayerName(_source)
    if(not RequestedHeartbeat and not IgnoredPlayerHeartbeats[name]) then
        BanOnlinePlayer(nil, _source, -1, "Nejste admin")
        return
    end
    ReceivedPlayerHeartbeats[_source] = true
end)

Citizen.CreateThread(function()
    Citizen.Wait(30000)
    while true do
        RequestedHeartbeat = true
        local start = GetGameTimer()
        for _, playerId in pairs(GetPlayers()) do
            local playerId = tonumber(playerId)
            ReceivedPlayerHeartbeats[playerId] = false
            TriggerClientEvent("strin_admin:getSpectateState", playerId)
        end
        Citizen.Wait(4000)
        for playerId, response in pairs(ReceivedPlayerHeartbeats) do
            local name = GetPlayerName(playerId)
            if(not response and name and not IgnoredPlayerHeartbeats[name]) then
                BanOnlinePlayer(nil, playerId, -1, "Vypnutí ochrany na klientovi")
            end
        end
        ReceivedPlayerHeartbeats = {}
        RequestedHeartbeat = false
        Citizen.Wait(30000 - (GetGameTimer() - start))
    end
end)
*/

local RegisteredResources = {}

function CollectResources()
    for i = 0, GetNumResources() - 1 do
        RegisteredResources[GetResourceByFindIndex(i)] = true
    end
end

CollectResources()

AddEventHandler("onResourceListRefresh", CollectResources)

RegisterNetEvent("strin_admin:validateResources", function(resources)
    local _source = source

    local invalidResources = {}
    for i=1, #resources do
        if(not RegisteredResources[resources[i]]) then
            table.insert(invalidResources, resources[i])
        end
    end

    if #invalidResources > 0 then
        BanOnlinePlayer(nil, _source, -1, "Nepovolené assety nalezeny - "..json.encode(invalidResources))
    end
end)