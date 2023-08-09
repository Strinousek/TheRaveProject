local BansLoaded = false
local BannedUsers = {}
local Base = exports.strin_base

Citizen.CreateThread(function()
    BannedUsers = Base:LoadJSONFile(GetCurrentResourceName(), "server/bans.json", "[]")
    BansLoaded = true
end)

/*RegisterNetEvent("strin_admin:unban", function(identifiers, reason)
    if(type(identifiers) ~= "table" or type(reason) ~= "string") then
        return
    end
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    if(not lib.table.contains(Admins, xPlayer.identifier)) then
        xPlayer.showNotification("Na tuto akci nemáte dostatečná práva.", { type = "error" })
        return
    end


    local playerUnbanned = UnbanPlayer(nil, identifiers, string.len(reason) == 0 and "Neuveden" or reason)
    if(not playerUnbanned) then
        xPlayer.showNotification(("Hráče se nepodařilo odbanovat!"):format(targetId), { type = "error" })
        return
    end
    xPlayer.showNotification(("Hráč byl odbanován!"), { type = "success" })
end)

RegisterNetEvent("strin_admin:ban", function(targetId, duration, reason)
    if(type(targetId) ~= "number" or type(duration) ~= "number" or type(reason) ~= "string" ) then
        return
    end
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    if(not lib.table.contains(Admins, xPlayer.identifier)) then
        xPlayer.showNotification("Na tuto akci nemáte dostatečná práva.", { type = "error" })
        return
    end


    if(not GetPlayerName(tonumber(targetId))) then
        xPlayer.showNotification("Hráč není online!", { type = "error" })
        return
    end

    local ban = BanOnlinePlayer(xPlayer.source, tonumber(targetId), (duration > 0) and duration or -1, string.len(reason) == 0 and nil or reason)
    xPlayer.showNotification(("Hráč #%s byl zabanován!"):format(targetId), { type = "success" })
end)*/

RegisterNetEvent("strin_admin:updateBan", function(licenseIdentifier, valueType, value)
    if(type(licenseIdentifier) ~= "string" or type(valueType) ~= "string" or (type(value) ~= "string" and type(value) ~= "number") ) then
        return
    end
    if(valueType ~= "DURATION" and valueType ~= "REASON") then
        return
    end
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    if(not lib.table.contains(Admins, xPlayer.identifier)) then
        xPlayer.showNotification("Na tuto akci nemáte dostatečná práva.", { type = "error" })
        return
    end

    local bannedUserRef = {}
    for bannedUserId, bannedUser in pairs(BannedUsers) do
        if(bannedUser.identifiers.license == licenseIdentifier) then
            bannedUserRef = bannedUser
            break
        end
    end

    if(not next(bannedUserRef)) then
        xPlayer.showNotification("Ban nenalezen.", { type = "error" })
        return
    end

    if(valueType == "DURATION") then
        local value = tonumber(value)
        
        Base:DiscordLog("BANS", "THE RAVE PROJECT - ZMĚNA BANU - "..valueType, {
            { name = "Jméno admina", value = GetPlayerName(_source) },
            { name = "Identifikace admina", value = json.encode(GetPlayerIdentifiersTable(_source) or {}) },

            { name = "Jméno zabanovaného", value = bannedUserRef.name },
            { name = "Identifikace odbanovaného", value = json.encode(bannedUserRef.identifiers or {}) },
            { name = "Původní trvání banu", value = bannedUserRef.duration.." dní" },
            { name = "Nové trvání banu", value = (value > 0 and value or "∞").." dní" },
        }, {
            fields = true
        })

        bannedUserRef.duration = value > 0 and value or -1
    elseif(valueType == "REASON") then
        
        Base:DiscordLog("BANS", "THE RAVE PROJECT - ZMĚNA BANU - "..valueType, {
            { name = "Jméno admina", value = GetPlayerName(_source) },
            { name = "Identifikace admina", value = json.encode(GetPlayerIdentifiersTable(_source) or {}) },

            { name = "Jméno zabanovaného", value = bannedUserRef.name },
            { name = "Identifikace odbanovaného", value = json.encode(bannedUserRef.identifiers or {}) },
            { name = "Původní důvod banu", value = bannedUserRef.reason },
            { name = "Nový důvod banu", value = tostring(value) },
        }, {
            fields = true
        })
        bannedUserRef.reason = tostring(value)
    end

    SaveBans()

    xPlayer.showNotification(("Upravil jste ban."), { type = "success" })
end)

lib.callback.register("strin_admin:getBannedUsers", function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return nil
    end
    
    if(not lib.table.contains(Admins, xPlayer.identifier)) then
        xPlayer.showNotification("Na tuto akci nemáte dostatečná práva.", { type = "error" })
        return nil
    end

    local bannedUsers = lib.table.deepclone(BannedUsers)

    for k,v in pairs(bannedUsers) do
        if(v) then
            local bannedOnTime = os.time(v.bannedOn)
            bannedUsers[k].bannedOnDate = os.date("%d/%m/%Y %H:%M:%S", bannedOnTime)
            bannedUsers[k].bannedUntilDate = (
                v.duration ~= -1 and 
                os.date("%d/%m/%Y %H:%M:%S", math.ceil(bannedOnTime + CalculateBanTime(v.duration))) or 
                "∞"
            )
        end
    end
    
    return bannedUsers
end)

ESX.RegisterCommand("unban", "admin", function(xPlayer, args)
    if(not args[1] or (not args[2] and xPlayer?.source)) then
        return
    end
    local _source = xPlayer?.source
    local targetIdentifier = args[1]
    
    -- +2 because 1 for whitespace character and another 1 for startIndex 
    local unbanReason = (args[2]) and table.concat(args, " "):sub((targetIdentifier):len() + 2) or nil

    local playerUnbanned = UnbanPlayer(_source, {
        license = targetIdentifier
    }, unbanReason)
    if(playerUnbanned) then
        if(xPlayer) then
            xPlayer.showNotification("Ban odebrán.")
        else
            print("Uzivatel odbanovan.")
        end
    else
        if(xPlayer) then
            xPlayer.showNotification("Ban se nezdařilo odebrat.")
        else
            print("Uzivatele se nezdarilo odebrat.")
        end
    end
end, true)

ESX.RegisterCommand("ban", "admin", function(xPlayer, args)
    if(not args[1] or not tonumber(args[2]) or not args[3]) then
        return
    end
    local _source = xPlayer?.source
    local targetIdentifier = args[1]
    local duration = tonumber(args[2])

    -- +3 because 2 for whitespace characters and another 1 for startIndex 
    local banReason = (args[2]) and table.concat(args, " "):sub((targetIdentifier..duration):len() + 3) or nil

    if(tonumber(targetIdentifier) and GetPlayerName(tonumber(targetIdentifier))) then
        if(_source == tonumber(targetIdentifier)) then
            xPlayer.showNotification("Nemůžete zabanovat sám sebe!", { type = "error" })
            return
        end
        local success = BanOnlinePlayer(_source, tonumber(targetIdentifier), duration, banReason)
        if(success) then
            if(_source) then
                xPlayer.showNotification("Hráč zabanován.")
            else
                print("Hrac zabanovan")
            end
        end
    else
        local success = BanPlayer(_source and {
            name = GetPlayerName(_source),
            identifiers = GetPlayerIdentifiersTable(_source)
        } or nil, {
            identifiers = {
                license = targetIdentifier
            }
        }, duration, banReason)
        if(success) then
            if(_source) then
                xPlayer.showNotification("Hráč zabanován.")
            else
                print("Hrac zabanovan")
            end
        end
    end
end, true)

ESX.RegisterCommand("refreshbans", "admin", function(xPlayer)
    BansLoaded = false
    BannedUsers = Base:LoadJSONFile(GetCurrentResourceName(), "server/bans.json", "[]")
    BansLoaded = true
end, true)

function DoIdentifiersMatch(playerIdentifiers, banIdentifiers)
    local identifiersMatch = false
    for k,v in pairs(banIdentifiers) do
        if(v == playerIdentifiers[k]) then
            identifiersMatch = true
            break
        end
    end
    return identifiersMatch
end

function CalculateBanTime(days)
    return days * 24 * 60 * 60
end

function ConvertDateTime(dateTime)
    local convertedDateTime = {}
    local dateKeys = {"day", "month", "year", "hour", "min", "sec"}
    for k,v in pairs(dateTime) do
        if(lib.table.contains(dateKeys, k)) then
            convertedDateTime[k] = v
        end
    end
    return convertedDateTime
end

function UnbanPlayer(unbannerId, identifiers, reason)
    local unbanner = {
        name = unbannerId and GetPlayerName(unbannerId) or "Konzole",
        identifiers = unbannerId and GetPlayerIdentifiersTable(unbannerId) or {}
    }
    local bannedUserData = {}
    for bannedUserId, bannedUser in pairs(BannedUsers) do
        if(DoIdentifiersMatch(identifiers, bannedUser.identifiers)) then
            bannedUserData = lib.table.deepclone(bannedUser)
            BannedUsers[bannedUserId] = nil
            break
        end
    end
    if(next(bannedUserData) ~= nil) then
        SaveBans()
        local bannedOnDate = os.date("%d/%m/%Y %H:%M:%S", os.time(bannedUserData.bannedOn))
        local bannedUntilDate = bannedUserData.duration ~= -1 and os.date("%d/%m/%Y %H:%M:%S", math.ceil(os.time(bannedUserData.bannedOn) + CalculateBanTime(bannedUserData.duration))) or "∞"
        Base:DiscordLog("BANS", "THE RAVE PROJECT - UNBAN", {
            { name = "Jméno admina", value = unbanner.name },
            { name = "Identifikace admina", value = json.encode(unbanner.identifiers) },

            { name = "Jméno odbanovaného", value = bannedUserData.name },
            { name = "Identifikace odbanovaného", value = json.encode(bannedUserData.identifiers) },
            { name = "Důvod banu", value = bannedUserData.reason },

            { name = "Důvod unbanu", value = reason or "Neuveden" },

            { name = "Původní délka banu", value = (bannedUserData.duration ~= -1 and bannedUserData.duration or "∞").." dní" },
            { name = "Datum udělení banu", value = bannedOnDate },
            { name = "Původní datum expirace banu", value = bannedUntilDate },

            { name = "Jméno udělitele banu", value = bannedUserData.bannedBy.name },
            { name = "Identifikace udělitele banu", value = json.encode(bannedUserData.bannedBy.identifiers) },
        }, {
            fields = true
        })
    end
    return next(bannedUserData) ~= nil
end

function GenerateReasonCard(ban, html)
    local bannedOnTime = os.time(ban.bannedOn)
    local bannedOnDate = os.date("%d/%m/%Y %H:%M:%S", bannedOnTime)
    local bannedUntilDate = "∞"
    if(ban.duration ~= -1) then
        local bannedUntilTime = math.ceil(bannedOnTime + CalculateBanTime(ban.duration))
        bannedUntilDate = os.date("%d/%m/%Y %H:%M:%S", bannedUntilTime)
    end
    if(html) then
        return ([[<br/>
            <span style="font-size: 36px;"><b>The Rave Project | Ban systém</b></span><br/>
            <b>Byl jste nalezen v seznamu zabanovaných hráčů.</b><br/>
            <b>Informace o uděleném banu:</b><br/>
            Důvod: %s<br/>
            Ban udělil/a: %s<br/>
            Datum udělení banu: %s<br/>
            Datum expirace banu: %s<br/>
            <br/>
            Máte zájem se obhájit nebo získat podrobnosti k Vašemu banu?
            Připojte se na náš <b><a href="https://discord.gg/MkNBdbRRmU">discord</a></b> a kontaktujte nás.
        ]]):format(
            ban.reason or "Neuveden",
            ban.bannedBy.name,
            bannedOnDate,
            bannedUntilDate
        )
    else
        -- gotta do this the ocky way, because DropPlayer reason doesn't fuck with multi-line strings. Sadge
        local banLines = {
            "",
            "The Rave Project | Ban systém",
            "Byl jste zabanován.",
            "",
            "Důvod: "..(ban.reason or "Neuveden"),
            "Ban udělil/a: "..ban.bannedBy.name,
            "Datum udělení banu: "..bannedOnDate,
            "Datum expirace banu: "..bannedUntilDate,
            "",
            "Máte zájem se obhájit nebo získat podrobnosti k Vašemu banu?",
            "Připojte se na náš discord a kontaktujte nás."
        }
        return table.concat(banLines, "\n")
    end
end

function BanOnlinePlayer(bannerId, targetId, duration, reason)
    local target = {
        name = nil,
        identifiers = {}
    }
    local banner = {
        name = "Konzole",
        identifiers = {}
    }
    if(bannerId) then
        banner.name = GetPlayerName(bannerId)
        banner.identifiers = GetPlayerIdentifiersTable(bannerId)
    end
    
    target.name = ESX.SanitizeString(GetPlayerName(targetId))
    target.identifiers = GetPlayerIdentifiersTable(targetId)

    if(lib.table.contains(Admins, target.identifiers?.license) and (banner.identifiers?.license ~= Admins[1]) and next(banner.identifiers)) then
        return false
    end

    local ban = BanPlayer(banner, target, duration, reason or "Neuveden")
    if(ban) then
        DropPlayer(targetId, GenerateReasonCard(ban))
    end
    return ban
end

exports("BanOnlinePlayer", BanOnlinePlayer)

function BanPlayer(banner, target, duration, reason)
    local foundPlayer = false
    for bannedUserId, bannedUser in pairs(BannedUsers) do
        if(DoIdentifiersMatch(target.identifiers, bannedUser.identifiers)) then
            foundPlayer = true
            break
        end
    end
    if(foundPlayer) then
        return false
    end

    if(lib.table.contains(Admins, target.identifiers?.license) and (banner.identifiers?.license ~= Admins[1]) and next(banner.identifiers)) then
        return false
    end

    local ban = {
        name = target?.name or "Unknown",
        bannedOn = ConvertDateTime(os.date("*t")),
        reason = reason or "Neuveden",
        duration = duration > 0 and duration or -1,
        identifiers = target?.identifiers,
        bannedBy = {
            name = banner?.name or "Konzole",
            identifiers = banner?.identifiers or {}
        }
    }
    BannedUsers[#BannedUsers + 1] = ban
    SaveBans()
    local bannedOnDate = os.date("%d/%m/%Y %H:%M:%S", os.time(ban.bannedOn))
    local bannedUntilDate = ban.duration ~= -1 and os.date("%d/%m/%Y %H:%M:%S", math.ceil(os.time(ban.bannedOn) + CalculateBanTime(ban.duration))) or "∞"
    Base:DiscordLog("BANS", "THE RAVE PROJECT - BAN", {
        { name = "Jméno admina", value = ban.bannedBy.name },
        { name = "Identifikace admina", value = json.encode(ban.bannedBy.identifiers) },

        { name = "Jméno zabanovaného", value = ban.name },
        { name = "Identifikace zabanovaného", value = json.encode(ban.identifiers) },
        { name = "Důvod banu", value = ban.reason },

        { name = "Délka banu", value = (ban.duration ~= -1 and ban.duration or "∞").." dní" },
        { name = "Datum udělení banu", value = bannedOnDate },
        { name = "Datum expirace banu", value = bannedUntilDate },
    }, {
        fields = true
    })
    return ban
end

exports("BanPlayer", BanPlayer)

function GetBans()
    local sanitizedBans = {}
    for _,v in pairs(BannedUsers) do
        sanitizedBans[#sanitizedBans + 1] = v
    end
    return sanitizedBans
end
exports("GetBans", GetBans)

function SaveBans()
    local bans = GetBans()
    SaveResourceFile(GetCurrentResourceName(), "server/bans.json", json.encode(bans), -1)
end

exports("SaveBans", SaveBans)

AddEventHandler("playerConnecting", function(playerName, setCallback, deferrals)
    deferrals.defer()
    deferrals.presentCard({
        type = "AdaptiveCard",
        version = "1.0",
        body = {
            {
                type = "TextBlock",
                text = "**The Rave Project | Ban systém**"
            },
            {
                type = "TextBlock",
                text = "**Probíhá kontrola identifikátorů...**"
            }
        }
    })
    local _source = source

    if (not BansLoaded) then
        deferrals.done("Doposud nebyl načten seznam zabanovaných uživatelů, prosím chvíli vyčkejte a zkuste se připojit znovu.")
        return
    end

    local identifiers, identifiersCount = GetPlayerIdentifiersTable(_source)

    if (not next(identifiers) or identifiersCount <= 0) then
        deferrals.done([[<br/>
            <span style="font-size: 36px;"><b>The Rave Project | Ban systém</b></span><br/>
            <b>Nebyly u Vás nalezené žádné identifikátory!</b><br/>
        ]])
        return
    end

    for bannedUserId, bannedUser in pairs(BannedUsers) do
        if(bannedUser) then
            if(DoIdentifiersMatch(identifiers, bannedUser.identifiers)) then
                if(bannedUser.duration ~= -1) then
                    local bannedUntilTime = os.time(bannedUser.bannedOn) + CalculateBanTime(bannedUser.duration)
                    local currentTime = os.time()

                    if(currentTime - bannedUntilTime < 0) then
                        deferrals.done(GenerateReasonCard(bannedUser, true))
                    elseif(currentTime - bannedUntilTime >= 0) then
                        UnbanPlayer(nil, bannedUser.identifiers, "Expirace banu")
                    end
                else
                    deferrals.done(GenerateReasonCard(bannedUser, true))
                end
                break
            end
        end
    end

    deferrals.done()
end)