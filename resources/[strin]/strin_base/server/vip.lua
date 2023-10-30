Citizen.CreateThread(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `user_vips` (
            `identifier` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
            `started_on` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
            `duration` INT(11) NULL DEFAULT NULL,
            `tier` INT(11) NULL DEFAULT NULL,
            `data` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
            INDEX `identifier` (`identifier`(191)) USING BTREE
        )
        ENGINE=InnoDB
        ;
    ]])
    MySQL.query.await([[
        ALTER TABLE `user_vips`  
            ADD COLUMN IF NOT EXISTS `identifier` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
            ADD COLUMN IF NOT EXISTS `started_on` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
            ADD COLUMN IF NOT EXISTS `duration` INT(11) NULL DEFAULT NULL,
            ADD COLUMN IF NOT EXISTS `tier` INT(11) NULL DEFAULT NULL,
            ADD COLUMN IF NOT EXISTS `data` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_bin';
    ]])
end)

local VIP_TIERS = {
    [1] = {
        backgroundImage = false,
        impoundReductionPercentage = 0,
        propertyDiscountPercentage = 0,
        sideJobBonusPercentage = 5,
        multicharEverywhere = false,
        queuePoints = 1000,
    },
    [2] = {
        backgroundImage = "https://imgur.com/1nILYpV.jpg",
        impoundReductionPercentage = 50,
        propertyDiscountPercentage = 5,
        sideJobBonusPercentage = 7.5,
        multicharEverywhere = false,
        queuePoints = 2500,
    },
    [3] = {
        backgroundImage = "https://imgur.com/lLOuaiK.gif",
        impoundReductionPercentage = 100,
        propertyDiscountPercentage = 10,
        sideJobBonusPercentage = 12.5,
        multicharEverywhere = true,
        queuePoints = 5000,
    }
}

local CachedVIPPlayers = {}

Citizen.CreateThread(function()
    CachedVIPPlayers = MySQL.query.await("SELECT * FROM `user_vips`")
    for i=1, #CachedVIPPlayers do
        local cachedVIPPlayer = CachedVIPPlayers[i]
        cachedVIPPlayer.data = json.decode(cachedVIPPlayer.data or "{}")
    end
    if(#GetPlayers() > 0) then
        for i=1, #CachedVIPPlayers do
            local cachedVIPPlayer = CachedVIPPlayers[i]
            local xPlayer = ESX.GetPlayerFromIdentifier(cachedVIPPlayer.identifier)
            if(xPlayer) then
                xPlayer.set("vip", CreateDataFromCache(cachedVIPPlayer))
            end
        end
    end
end)

lib.callback.register("strin_base:hasVIP", function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return false
    end
    local vipData = xPlayer.get("vip")
    if(not vipData) then
        return false
    end
    return true
end)

lib.callback.register("strin_base:getVIP", function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return nil
    end
    local vipData = xPlayer.get("vip")
    if(not vipData) then
        return nil
    end
    vipData.startedOnDate = os.date('%m-%d-%Y %H:%M:%S', tonumber(vipData.startedOn))
    vipData.expiresOnDate = os.date('%m-%d-%Y %H:%M:%S', tonumber(vipData.startedOn) + (vipData.duration * 24 * 60 * 60))
    return vipData
end)


function CreateDataFromCache(cache)
    local cache = lib.table.deepclone(cache)
    local data = cache.data
    data.duration = cache.duration
    data.tier = cache.tier
    data.startedOn = cache.started_on
    for k,v in pairs(VIP_TIERS[cache.tier]) do
        if(k == "backgroundImage") then
            if(v and data?.backgroundImage) then
                local hasCustomBackground = true
                for j=1, #VIP_TIERS do
                    if(data?.backgroundImage == VIP_TIERS[j]?.backgroundImage) then
                        hasCustomBackground = false
                    end
                end
                if(hasCustomBackground) then
                    goto skipLoop
                end
            end
        end
        data[k] = v
        ::skipLoop::
    end
    return data
end

RegisterNetEvent("esx:playerLoaded", function(playerId, xPlayer)
    for i=1, #CachedVIPPlayers do
        local cachedVIPPlayer = CachedVIPPlayers[i]
        if(cachedVIPPlayer?.identifier == xPlayer.identifier) then
            xPlayer.set("vip", CreateDataFromCache(cachedVIPPlayer))
            break
        end
    end
end)

ESX.RegisterCommand("givevip", "admin", function(xPlayer, args)
    local _source = xPlayer?.source
    if(not _source) then
        xPlayer = { showNotification = function(message) print(message) end }
    end
    if(not VIP_TIERS[args.vipTier]) then
        xPlayer.showNotification("Takový VIP tier neexistuje!", { type = "error" })
        return
    end
    local playerIdentifier = nil
    if(tonumber(args.playerIdentifier)) then
        playerIdentifier = ESX.GetIdentifier(tonumber(args.playerIdentifier))
        if(not playerIdentifier) then
            xPlayer.showNotification("Nepodařilo se získat licenci hráče!", { type = "error" })
            return
        end
    else
        playerIdentifier = args.playerIdentifier
    end
    local cachedVIPPlayer = nil
    for i=1, #CachedVIPPlayers do
        if(CachedVIPPlayers[i].identifier == playerIdentifier) then
            cachedVIPPlayer = CachedVIPPlayers[i]
        end
    end
    local tier = tonumber(args.vipTier)
    if(cachedVIPPlayer) then
        if(tier == cachedVIPPlayer.tier) then
            cachedVIPPlayer.duration += 30
            MySQL.update("UPDATE `user_vips` SET `duration` = ? WHERE `identifier` = ?", {
                cachedVIPPlayer.duration,
                playerIdentifier
            }, function() 
                xPlayer.showNotification("VIP - Prodlouzeni o 30 dní - HRÁČ: "..playerIdentifier.." - TIER: "..cachedVIPPlayer.tier)
                local targetPlayer = ESX.GetPlayerFromIdentifier(cachedVIPPlayer.identifier)               
                
                if(not targetPlayer) then
                    return
                end
                
                targetPlayer.showNotification("Byl Vám prodloužen aktuální VIP balíček o 30 dní.")
                targetPlayer.set("vip", CreateDataFromCache(cachedVIPPlayer))
            end)
            return
        end
        
        local data = CreateDataFromCache(cachedVIPPlayer)

        xPlayer.showNotification("VIP - Změna tieru - HRÁČ: "..cachedVIPPlayer.identifier.." - PŮVODNÍ TIER: "..cachedVIPPlayer.tier.." - NOVÝ TIER: "..tier)
        
        local time = os.time()
        cachedVIPPlayer.duration = 30
        cachedVIPPlayer.tier = tier
        cachedVIPPlayer.started_on = time
        cachedVIPPlayer.data = {}
        if(data.backgroundImage and VIP_TIERS[tier].backgroundImage) then
            cachedVIPPlayer.data.backgroundImage = data.backgroundImage
        else
            cachedVIPPlayer.data.backgroundImage = VIP_TIERS[tier].backgroundImage
        end

        MySQL.update("UPDATE `user_vips` SET `duration` = ?, `tier` = ?, `started_on` = ?, `data` = ? WHERE `identifier` = ?", {
            cachedVIPPlayer.duration,
            cachedVIPPlayer.tier,
            cachedVIPPlayer.started_on,
            json.encode(cachedVIPPlayer.data),
            cachedVIPPlayer.identifier
        }, function()
            local targetPlayer = ESX.GetPlayerFromIdentifier(cachedVIPPlayer.identifier)  
            if(not targetPlayer) then
                return
            end

            targetPlayer.showNotification("Byl Vám změněn tier VIP balíčku na #"..tier..".")
            targetPlayer.set("vip", CreateDataFromCache(cachedVIPPlayer))
            TriggerEvent("strin_scoreboard:refresh")
        end)
        return
    end

    cachedVIPPlayer = {}
    cachedVIPPlayer.identifier = playerIdentifier
    cachedVIPPlayer.duration = 30
    cachedVIPPlayer.tier = tier
    cachedVIPPlayer.started_on = os.time()
    cachedVIPPlayer.data = {}
    cachedVIPPlayer.data.backgroundImage = VIP_TIERS[tier].backgroundImage

    MySQL.insert("INSERT INTO `user_vips` SET `duration` = ?, `tier` = ?, `started_on` = ?, `data` = ?, `identifier` = ?", {
        cachedVIPPlayer.duration,
        cachedVIPPlayer.tier,
        cachedVIPPlayer.started_on,
        json.encode(cachedVIPPlayer.data),
        cachedVIPPlayer.identifier
    }, function()
        table.insert(CachedVIPPlayers, cachedVIPPlayer)
        xPlayer.showNotification("Hráči byl udělen VIP balíček TIER - "..tier)
        local targetPlayer = ESX.GetPlayerFromIdentifier(cachedVIPPlayer.identifier)  
        if(not targetPlayer) then
            return
        end

        targetPlayer.showNotification("Byl Vám udělen VIP balíček TIER - "..tier)
        targetPlayer.set("vip", CreateDataFromCache(cachedVIPPlayer))
        TriggerEvent("strin_scoreboard:refresh")
    end)
end, true, {
    help = "Dát VIP hráči na 30 dní",
    arguments = {
        { name = "playerIdentifier", help = "ID hráče | License Identifier", type = "any" },
        { name = "vipTier", help = "1 / 2 / 3", type = "number" },
    }
})

ESX.RegisterCommand("removevip", "admin", function(xPlayer, args)
    local _source = xPlayer?.source
    if(not _source) then
        xPlayer = { showNotification = function(message) print(message) end }
    end
    local playerIdentifier = nil
    if(tonumber(args.playerIdentifier)) then
        playerIdentifier = ESX.GetIdentifier(tonumber(args.playerIdentifier))
        if(not playerIdentifier) then
            xPlayer.showNotification("Nepodařilo se získat licenci hráče!", { type = "error" })
            return
        end
    else
        playerIdentifier = args.playerIdentifier
    end
    local cachedVIPPlayer = nil
    for i=1, #CachedVIPPlayers do
        if(CachedVIPPlayers[i].identifier == playerIdentifier) then
            table.remove(CachedVIPPlayers, i)
            break
        end
    end
    MySQL.query("DELETE FROM `user_vips` WHERE `identifier` = ?", {
        playerIdentifier
    }, function()
        xPlayer.showNotification("Hráči byl odebrán VIP balíček.")
        local targetPlayer = ESX.GetPlayerFromIdentifier(playerIdentifier)
        if(not targetPlayer) then
            return
        end
        targetPlayer.set("vip", nil)
        targetPlayer.showNotification("Byl Vám odebrán VIP balíček.")
        TriggerEvent("strin_scoreboard:refresh")
    end)
end, true, {
    help = "Odebrat VIP hráči",
    arguments = {
        { name = "playerIdentifier", help = "ID hráče | License Identifier", type = "any" },
    }
})

ESX.RegisterCommand("setbg", "admin", function(xPlayer, args)
    local _source = xPlayer?.source
    if(not _source) then
        xPlayer = { showNotification = function(message) print(message) end }
    end
    local playerIdentifier = nil
    if(tonumber(args.playerIdentifier)) then
        playerIdentifier = ESX.GetIdentifier(tonumber(args.playerIdentifier))
        if(not playerIdentifier) then
            xPlayer.showNotification("Nepodařilo se získat licenci hráče!", { type = "error" })
            return
        end
    else
        playerIdentifier = args.playerIdentifier
    end
    local cachedVIPPlayer = nil
    for i=1, #CachedVIPPlayers do
        if(CachedVIPPlayers[i].identifier == playerIdentifier) then
            cachedVIPPlayer = CachedVIPPlayers[i]
        end
    end
    if(not cachedVIPPlayer) then
        xPlayer.showNotification("Hráč není uveden ve VIP systému!", { type = "error" })
        return
    end

    cachedVIPPlayer.data.backgroundImage = tostring(args.backgroundImageLink)

    MySQL.update("UPDATE `user_vips` SET `data` = ? WHERE `identifier` = ?", {
        json.encode(cachedVIPPlayer.data),
        cachedVIPPlayer.identifier
    }, function()
        xPlayer.showNotification("Hráči byl změněn obrázek ve scoreboardu.")
        local targetPlayer = ESX.GetPlayerFromIdentifier(cachedVIPPlayer.identifier)  
        if(not targetPlayer) then
            return
        end

        targetPlayer.showNotification("Byl Vám změněn obrázek ve scoreboardu.")
        targetPlayer.set("vip", CreateDataFromCache(cachedVIPPlayer))
        TriggerEvent("strin_scoreboard:refresh")
    end)
end, true, {
    help = "Nastavit hráči pozadí v scoreboardu",
    arguments = {
        { name = "playerIdentifier", help = "ID hráče | License Identifier", type = "any" },
        { name = "backgroundImageLink", help = "Link na obrázek (musí obsahovat příponu .jpg apod.)", type = "string" },
    }
})

Citizen.CreateThread(function ()
    while true do
        local startedOn = GetGameTimer()
        local xPlayers = ESX.GetExtendedPlayers()
        for i=1, #xPlayers do
            local xPlayer = xPlayers[i]
            local vipData = xPlayer.get("vip")
            if(vipData and vipData?.startedOn) then
                local expireByTime = vipData.startedOn + (vipData.duration * 24 * 60 * 60)

                -- If current time is higher or equal to the expire time
                if(os.time() >= expireByTime) then
                    MySQL.query("DELETE FROM `user_vips` WHERE `identifier` = ?", {
                        xPlayer.identifier
                    }, function()
                        xPlayer.set("vip", nil)
                        xPlayer.showNotification("Byl Vám odebrán VIP balíček.")
                        TriggerEvent("strin_scoreboard:refresh")
                    end)
                end
            end
        end
        Citizen.Wait((30 * 60000) - (GetGameTimer() - startedOn))
    end
end)

exports("GetPlayerVIP", function(identifier)
    local cachedVIPPlayer = nil
    for i=1, #CachedVIPPlayers do
        if(CachedVIPPlayers[i].identifier == identifier) then
            cachedVIPPlayer = CachedVIPPlayers[i]
            break
        end
    end
    if(cachedVIPPlayer) then
        return CreateDataFromCache(cachedVIPPlayer)
    else
        return nil
    end
end)

exports("GetVIPPlayers", function()
    return CachedVIPPlayers
end)