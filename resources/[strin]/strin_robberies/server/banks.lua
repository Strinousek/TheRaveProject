local BanksInUse = {}
local BanksRobberCheckingIntervalId = nil
local BanksCheckIntervalId = SetInterval(function()
    local changed = false
    for k,v in pairs(BanksInUse) do
        if(v and (v?.state == "CANCELLED" or v?.state == "ROBBED")) then
            if(v?.state == "CANCELLED") then
                BanksInUse[k] = nil
                changed = true
            end
            if(v?.state == "ROBBED") then
                local secondsSinceFinishedOn = (os.time() - v?.finishedOn)
                if(secondsSinceFinishedOn >= (BanksRefreshTime / 1000)) then
                    BanksInUse[k] = nil
                    changed = true
                end
            end
        end
    end
    if(changed) then
        SyncBanksInUse()
    end
end, 5000)

/*
    BanksInUse = {
        [bankId] = {
            state = "HACKING"
            hackerIdentifier = "xsdads"
        }
    }

    bankState: "HACKING" | "HACKED"
*/

RegisterCommand("hackdeck", function(source)
    local _source = source
    Inventory:AddItem(_source, "hackdeck", 1)
end)

RegisterNetEvent("strin_robberies:requestBankRobbery", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    local job = xPlayer.getJob()
    if(IsPlayerACop(job.name)) then
        xPlayer.showNotification("Nemůžete zakládat loupeže jako strážník!", { type = "error" })
        return
    end

    local isAvailable, message = CheckBasicRobberyAvailability(BanksRequiredCops)
    if(not isAvailable) then
        xPlayer.showNotification(message, { type = "error" })
        return
    end

    local bankId = GetNearestBankId(_source)
    if(not bankId) then
        xPlayer.showNotification("Nejste poblíž žádné bance!", { type = "error" })
        return
    end

    local bank = BanksInUse[bankId]

    if(bank?.state == "HACKING") then
        xPlayer.showNotification("Tuhle banku již někdo hackuje!", { type = "error" })
        return
    end

    if(bank?.state == "HACKED") then
        xPlayer.showNotification("Tuhle banku již někdo hacknul!", { type = "error" })
        return
    end

    if(bank?.state == "CANCELLED") then
        xPlayer.showNotification("Tahle banka není k dispozici!", { type = "error" })
        return
    end

    if(bank?.state == "ROBBED") then
        xPlayer.showNotification("Tuhle banku někdo nedávno vykrádl!", { type = "error" })
        return
    end

    local device = GetHackingDevice(_source)
    if(not device) then
        xPlayer.showNotification("Nemáte u sebe zařízení pro prolomení bezpečnostního systému!", { type = "error" })
        return
    end

    BanksInUse[bankId] = SetupBankInUse(xPlayer.identifier)
    SyncBanksInUse()
    local startedHackingOn = GetGameTimer()
    lib.callback("strin_robberies:startHackingBank", _source, function(results)
        local endedHackingOn = GetGameTimer()

        local bankId = GetNearestBankId(_source)
        if(not bankId) then
            xPlayer.showNotification("Nejste poblíž žádné bance!", { type = "error" })
            return
        end
        local job = xPlayer.getJob()
        if(IsPlayerACop(job.name)) then
            xPlayer.showNotification("Nemůžete zakládat loupeže jako strážník!", { type = "error" })
            return
        end

        local isAvailable, message = CheckBasicRobberyAvailability(BanksRequiredCops)
        if(not isAvailable) then
            xPlayer.showNotification(message, { type = "error" })
            return
        end

        local device = GetHackingDevice(_source)
        if(
            not results or
            not device or
            type(results) ~= "table" or
            (type(results) == "table" and (#results ~= #BanksHackingTimers)) or
            (endedHackingOn - startedHackingOn) < 5000
        ) then
            if(device) then
                local newDurability = (device.metadata?.durability and device.metadata?.durability or 100) - 25
                if(newDurability > 0) then
                    Inventory:SetDurability(_source, device.slot, newDurability)
                    xPlayer.showNotification("Vaše zařízení se lehce poškodilo.", { type = "inform" })
                elseif(newDurability <= 0) then
                    Inventory:RemoveItem(_source, device.name, device.count, nil, device.slot)
                    xPlayer.showNotification("Vaše zařízení se rozbilo!", { type = "error" })
                end
            end
            if(BanksInUse[bankId].state == "HACKING") then
                BanksInUse[bankId] = nil
                SyncBanksInUse()
            end
            return
        end
        
        Base:StartTimer(30)
        BanksInUse[bankId].state = "HACKED"
        BanksInUse[bankId].hackedOn = os.time()
        Inventory:RemoveItem(_source, device.name, device.count, nil, device.slot)
         /*
            Set a new interval for robber checking.

            This is currently HARDCODED for 1 player usage which is kinda goofy
            so rework in the future might be needed, but its cool for now.

            Set bank robbery state as "CANCELlED" if:
            - Robber disconnected
            - Robber went far away
        */

        -- lazy ahh workarounds, but w/e
        local playerWentFarAway = false
        local intervalCleared = false

        BanksRobberCheckingIntervalId = SetInterval(function()

            -- Robber disconnected
            if(not playerWentFarAway and BanksInUse[bankId]?.state == "CANCELLED") then
                NotifyCops("CANCEL", "Bankovní loupež zrušena!")
                Base:DiscordLog("DEFAULT", "THE RAVE PROJECT - LOUPEŽE - KASY", {
                    { name = "Akce", value = "Loupež zrušena - Disconnect" },
                    { name = "Jméno hráče", value = ESX.SanitizeString(GetPlayerName(_source)) },
                    { name = "Identifikace hráče", value = xPlayer.identifier },
                    { name = "Informace o loupeži", value = json.encode(BanksInUse[bankId]) },
                }, {
                    fields = true
                })
                intervalCleared = true
                ClearInterval(BanksRobberCheckingIntervalId)
                return
            end

            local ped = GetPlayerPed(_source)
            local coords = GetEntityCoords(ped)
            local distance = #(coords - Banks[bankId]?.coords)

            -- Robber went far away
            if(distance > 20 and not playerWentFarAway) then
                playerWentFarAway = true
                intervalCleared = true
                BanksInUse[bankId].state = "CANCELLED"
                Base:DiscordLog("DEFAULT", "THE RAVE PROJECT - LOUPEŽE - KASY", {
                    { name = "Akce", value = "Loupež zrušena - Hráč odešel moc daleko" },
                    { name = "Jméno hráče", value = ESX.SanitizeString(GetPlayerName(_source)) },
                    { name = "Identifikace hráče", value = xPlayer.identifier },
                    { name = "Informace o loupeži", value = json.encode(BanksInUse[bankId]) },
                }, {
                    fields = true
                })
                NotifyCops("CANCEL", "Bankovní loupež zrušena!")
                xPlayer.showNotification("Přepadení zrušeno, jste moc daleko!", { type = "error" })
                ClearInterval(BanksRobberCheckingIntervalId)
            end
        end, 1000)

        NotifyCops("ROBBERY", "Loupež v bance", "Systémové zabezpečení", Banks[bankId]?.coords)
        Base:DiscordLog("DEFAULT", "THE RAVE PROJECT - LOUPEŽE - BANKY", {
            { name = "Akce", value = "Loupež započnuta" },
            { name = "Jméno hráče", value = ESX.SanitizeString(GetPlayerName(_source)) },
            { name = "Identifikace hráče", value = xPlayer.identifier },
            { name = "Informace o loupeži", value = json.encode(BanksInUse[bankId]) },
        }, {
            fields = true
        })
        SetTimeout(BanksRobTime, function()
            
            -- Clear checking interval (just in case it's not cleared already)
            if(not intervalCleared) then
                ClearInterval(BanksRobberCheckingIntervalId)
            end

            local bank = BanksInUse[bankId]
            if(not bank or bank?.state == "CANCELLED") then
                return
            end

            local reward = type(BanksPayOut) == "table" and math.random(table.unpack(BanksPayOut)) or BanksPayOut
            BanksInUse[bankId].state = "ROBBED"
            BanksInUse[bankId].finishedOn = os.time()
            Base:DiscordLog("DEFAULT", "THE RAVE PROJECT - LOUPEŽE - BANKY", {
                { name = "Akce", value = "Loupež dokončena" },
                { name = "Jméno hráče", value = ESX.SanitizeString(GetPlayerName(_source)) },
                { name = "Identifikace hráče", value = xPlayer.identifier },
                { name = "Informace o loupeži", value = json.encode(BanksInUse[bankId]) },
                { name = "Částka", value = ESX.Math.GroupDigits(reward).."$" },
            }, {
                fields = true
            })
            xPlayer.addMoney(reward)
            SyncBanksInUse()
        end)
        SyncBanksInUse()
    end, bankId)
end)

function SetupBankInUse(identifier)
    local bank = {
        state = "HACKING",
        startedOn = os.time(),
        finishedOn = nil,
        hackedOn = nil,
        hackerIdentifier = identifier
    }
    return bank
end

-- When player loads in, sync him with Banks In Use
AddEventHandler("esx:playerLoaded", function()
    local _source = source
    SyncBanksInUse(_source)
end)

AddEventHandler("strin_jobs:onPlayerDeath", function(identifier)
    local changed = false
    for k,v in pairs(BanksInUse) do
        if(v) then
            if((v.hackerIdentifier == identifier and v.state == "HACKING")) then
                BanksInUse[k] = nil
                changed = true
            elseif((v.hackerIdentifier == identifier and v.state == "HACKED")) then
                BanksInUse[k].state = "CANCELLED"
                changed = true
            end
        end
    end
    if(changed) then
        SyncBanksInUse()
    end
end)

AddEventHandler("playerDropped", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end
    local changed = false
    for k,v in pairs(BanksInUse) do
        if(v) then
            if((v?.hackerIdentifier == xPlayer.identifier and v?.state == "HACKING")) then
                BanksInUse[k] = nil
                changed = true
            elseif((v?.hackerIdentifier == xPlayer.identifier and v?.state == "HACKED")) then
                BanksInUse[k].state = "CANCELLED"
                changed = true
            end
        end
    end
    if(changed) then
        SyncBanksInUse()
    end
end)

function SyncBanksInUse(playerId)
    if(playerId) then
        TriggerClientEvent("strin_robberies:syncBanksInUse", playerId, BanksInUse)
    else
        TriggerClientEvent("strin_robberies:syncBanksInUse", -1, BanksInUse)
    end
end

function GetHackingDevice(playerId)
    local hackingDevices = Inventory:GetSlotsWithItem(playerId, "hackdeck")
    if(not hackingDevices or not next(hackingDevices)) then
        return nil
    end
    if(#hackingDevices > 1) then
        table.sort(hackingDevices, function(a,b)
            if(not a.metadata?.durability) then
                a.metadata.durability = 100
            end
            if(not b.metadata?.durability) then
                b.metadata.durability = 100
            end
            return a.metadata?.durability < b.metadata?.durability
        end)
    end
    return hackingDevices[1]
end

function GetNearestBankId(playerId)
    local ped = GetPlayerPed(playerId)
    local coords = GetEntityCoords(ped)
    local bankId = nil
    local distanceToBank = 15000.0
    for k,v in pairs(Banks) do
        local distance = #(coords - v.coords)
        if(distance < distanceToBank) then
            distanceToBank = distance
            bankId = k
        end
    end
    return (distanceToBank < 5) and bankId or nil
end