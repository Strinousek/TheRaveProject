local CashRegistersInUse = {}
local CashRegisterRobberCheckingIntervalId = nil
local CashRegisterCheckIntervalId = SetInterval(function()
    local changed = false
    for k,v in pairs(CashRegistersInUse) do
        if(v and (v.state == "CANCELLED" or v.state == "ROBBED")) then
            if(v.state == "CANCELLED") then
                CashRegisters[k] = nil
                changed = true
            end
            if(v.state == "ROBBED") then
                local secondsSinceFinishedOn = (os.time() - v.finishedOn)
                if(secondsSinceFinishedOn >= (CashRegistersRefreshTime / 1000)) then
                    CashRegistersInUse[k] = nil
                    changed = true
                end
            end
        end
    end
    if(changed) then
        SyncCashRegistersInUse()
    end
end, 5000)

AddEventHandler("onResourceStop", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        ClearInterval(CashRegisterCheckIntervalId)
    end
end)

/*
    states = {
        "ROBBING", -- Robbery is in progress
        "CANCELLED", -- Player either went far away from rob point OR he disconnected.
        "ROBBED" -- Succesfully robbed by a player
    }
*/

RegisterNetEvent("strin_robberies:robCashRegister", function()
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

    local isAvailable, message = CheckBasicRobberyAvailability(CashRegistersRequiredCops)
    if(not isAvailable) then
        xPlayer.showNotification(message, { type = "error" })
        return
    end

    -- Check if player is near register id
    local registerId = GetNearestCashRegisterId(_source)
    if(not registerId) then
        xPlayer.showNotification("Nejste poblíž žádné kasy!", { type = "error" })
        return
    end
    
    -- Check if cash register is in use (no matter the state)
    if(CashRegistersInUse[registerId]) then
        xPlayer.showNotification("Tahle kasa je prázdná!", { type = "error" })
        return
    end

    -- Check for lockpicks count
    local lockpickCount = Inventory:GetItemCount(_source, "lockpick")
    if(lockpickCount <= 0) then
        xPlayer.showNotification("Nemáte sebou paklíč!", { type = "error" })
        return
    end

    -- Send skill check request to client and if client succeeds then continue with robbery processing in a different coroutine.
    lib.callback("strin_robberies:lockpickCashRegister", _source, function(success)
        if(success) then

            /*
                Check here again incase of an exploit?
                2 people could try to rob the same cash register or 2 cash registers at once
                so lets avoid it with this non-race condition workaround for now
            */
    
            local job = xPlayer.getJob()
            if(IsPlayerACop(job.name)) then
                xPlayer.showNotification("Nemůžete vykrást kasu jako strážník!", { type = "error" })
                return
            end
            
            local isAvailable, message = CheckBasicRobberyAvailability(CashRegistersRequiredCops)
            if(not isAvailable) then
                xPlayer.showNotification(message, { type = "error" })
                return
            end

            if(CashRegistersInUse[registerId]) then
                xPlayer.showNotification("Tahle kasa je prázdná!", { type = "error" })
                return
            end

            -- Remove lockpick
            Inventory:RemoveItem(_source, "lockpick", 1)
            
            -- Register cash register in use
            CashRegistersInUse[registerId] = {
                startedOn = os.time(), -- started robbing on 
                state = "ROBBING",
                finishedOn = nil,
                robberIdentifier = xPlayer.identifier, -- save robber's identifier for later use
            }

            -- Sync Cash Registers in Use so client's wont see register as robbable.
            SyncCashRegistersInUse()

            -- Start robbery timer
            Base:StartTimer(30)

            -- Show cash register robbery timer for all players near the register 
            TriggerClientEvent("strin_robberies:timeCashRegisterRobbery", -1, CashRegistersRobberyTime, registerId)

            /*
                Set a new interval for robber checking.

                This is currently HARDCODED for 1 player usage which is kinda goofy
                so rework in the future might be needed, but its cool for now.

                Set register robbery state as "CANCELlED" if:
                - Robber disconnected
                - Robber went far away
            */

            -- lazy ahh workarounds, but w/e
            local playerWentFarAway = false
            local intervalCleared = false

            CashRegisterRobberCheckingIntervalId = SetInterval(function()

                -- Robber disconnected
                if(not playerWentFarAway and CashRegistersInUse[registerId].state == "CANCELLED") then
                    NotifyCops("CANCEL", "Loupež v obchodě zrušena!")
                    Base:DiscordLog("DEFAULT", "THE RAVE PROJECT - LOUPEŽE - KASY", {
                        { name = "Akce", value = "Loupež zrušena - Disconnect" },
                        { name = "Jméno hráče", value = ESX.SanitizeString(GetPlayerName(_source)) },
                        { name = "Identifikace hráče", value = xPlayer.identifier },
                        { name = "Informace o loupeži", value = json.encode(CashRegistersInUse[bankId]) },
                    }, {
                        fields = true
                    })
                    intervalCleared = true
                    ClearInterval(CashRegisterRobberCheckingIntervalId)
                    return
                end

                local ped = GetPlayerPed(_source)
                local coords = GetEntityCoords(ped)
                local distance = #(coords - CashRegisters[registerId])

                -- Robber went far away
                if(distance > 20 and not playerWentFarAway) then
                    playerWentFarAway = true
                    intervalCleared = true
                    CashRegistersInUse[registerId].state = "CANCELLED"
                    Base:DiscordLog("DEFAULT", "THE RAVE PROJECT - LOUPEŽE - KASY", {
                        { name = "Akce", value = "Loupež zrušena - Hráč odešel moc daleko" },
                        { name = "Jméno hráče", value = ESX.SanitizeString(GetPlayerName(_source)) },
                        { name = "Identifikace hráče", value = xPlayer.identifier },
                        { name = "Informace o loupeži", value = json.encode(CashRegistersInUse[bankId]) },
                    }, {
                        fields = true
                    })
                    NotifyCops("CANCEL", "Loupež v obchodě zrušena!")
                    xPlayer.showNotification("Přepadení zrušeno, jste moc daleko!", { type = "error" })
                    ClearInterval(CashRegisterRobberCheckingIntervalId)
                end
            end, 1000)

            -- Notify cops that a robbery is happening
            NotifyCops("ROBBERY", "Loupež v obchodě", "Systémové zabezpečení", CashRegisters[registerId])
            Base:DiscordLog("DEFAULT", "THE RAVE PROJECT - LOUPEŽE - KASY", {
                { name = "Akce", value = "Loupež započnuta" },
                { name = "Jméno hráče", value = ESX.SanitizeString(GetPlayerName(_source)) },
                { name = "Identifikace hráče", value = xPlayer.identifier },
                { name = "Informace o loupeži", value = json.encode(CashRegistersInUse[bankId]) },
            }, {
                fields = true
            })

            -- Set timeout for robbery
            SetTimeout(CashRegistersRobberyTime, function()
                -- Clear checking interval (just in case it's not cleared already)
                if(not intervalCleared) then
                    ClearInterval(CashRegisterRobberCheckingIntervalId)
                end
                CashRegisterRobberCheckingIntervalId = nil
                if(CashRegistersInUse[registerId] and (CashRegistersInUse[registerId].state ~= "CANCELLED")) then
                    local ped = GetPlayerPed(_source)
                    local robberHealth = GetEntityHealth(ped) 
                    if(robberHealth > 2) then
                        CashRegistersInUse[registerId].state = "ROBBED"
                        CashRegistersInUse[registerId].finishedOn = os.time()
                        math.randomseed(os.time())
                        local reward = math.random(table.unpack(CashRegistersPayOut))
                        xPlayer.addMoney(reward)
                        Base:DiscordLog("DEFAULT", "THE RAVE PROJECT - LOUPEŽE - KASY", {
                            { name = "Akce", value = "Loupež dokončena" },
                            { name = "Jméno hráče", value = ESX.SanitizeString(GetPlayerName(_source)) },
                            { name = "Identifikace hráče", value = xPlayer.identifier },
                            { name = "Informace o loupeži", value = json.encode(CashRegistersInUse[bankId]) },
                            { name = "Částka", value = ESX.Math.GroupDigits(reward).."$" }
                        }, {
                            fields = true
                        })
                        xPlayer.showNotification(("Vykradl jste z kasy - %s$"):format(reward), { type = "success" })
                        return
                    end
                    CashRegistersInUse[registerId].state = "CANCELLED"
                    Base:DiscordLog("DEFAULT", "THE RAVE PROJECT - LOUPEŽE - KASY", {
                        { name = "Akce", value = "Loupež zrušena - Hráč je mrtev" },
                        { name = "Jméno hráče", value = ESX.SanitizeString(GetPlayerName(_source)) },
                        { name = "Identifikace hráče", value = xPlayer.identifier },
                        { name = "Informace o loupeži", value = json.encode(CashRegistersInUse[bankId]) },
                    }, {
                        fields = true
                    })
                    xPlayer.showNotification("Jste mrtev a nemůžete si vzít peníze z kasy!", { type = "error" })
                end
            end)
        end
    end)
end)

-- When player loads in, sync him with Cash Registers In Use
AddEventHandler("esx:playerLoaded", function()
    local _source = source
    SyncCashRegistersInUse(_source)
end)

-- When player leaves, sync players with Cash Registers In Use if he was a robber
AddEventHandler("playerDropped", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local changed = false
    for k,v in pairs(CashRegistersInUse) do
        if(v and (v.robberIdentifier == xPlayer.identifier)) then
            CashRegistersInUse[k].state = "CANCELLED"
            changed = true
            break
        end
    end

    -- Is this a must-have? yes it is actually lmao
    if(changed) then
        SyncCashRegistersInUse()
    end
end)

function SyncCashRegistersInUse(playerId)
    if(IsAnyCashRegisterInUse()) then
        if(playerId) then
            TriggerClientEvent("strin_robberies:syncCashRegistersInUse", playerId, CashRegistersInUse)
        else
            TriggerClientEvent("strin_robberies:syncCashRegistersInUse", -1, CashRegistersInUse)
        end
    end
end

function GetNearestCashRegisterId(playerId)
    local ped = GetPlayerPed(playerId)
    local coords = GetEntityCoords(ped)
    local cashRegisterId = nil
    local distanceToCashRegister = 15000.0
    for k,v in pairs(CashRegisters) do
        local distance = #(coords - v)
        if(distance < distanceToCashRegister) then
            distanceToCashRegister = distance
            cashRegisterId = k
        end
    end
    return (distanceToCashRegister < 15) and cashRegisterId or nil
end

function IsAnyCashRegisterInUse()
    local isAnyCashRegisterInUse = false
    for k,v in pairs(CashRegistersInUse) do
        if(v) then
            isAnyCashRegisterInUse = true
            break
        end
    end
    return isAnyCashRegisterInUse
end

/*
    [1] = {
        netId = ,
        coords = ,
    }
*/
/*
RegisterNetEvent("strin_robberies:robRegister", function(registerNetId)
    local _source = source
    local registerEntity = NetworkGetEntityFromNetworkId(registerNetId)
    local entityModel = GetEntityModel(registerEntity)
    print(entityModel)
    print(lib.table.contains(CashRegistersHashes, entityModel))
    CashRegisters[#CashRegisters + 1] = {
        netId = registerNetId,
        coords = GetEntityCoords(registerEntity),
        heading = GetEntityHeading(registerEntity),
        model = entityModel
    }
end)

Citizen.CreateThread(function()
    while true do
        for k,v in pairs(CashRegisters) do
            local entity = NetworkGetEntityFromNetworkId(v.netId)
            local entityModel = GetEntityModel(entity)
            print(entity, DoesEntityExist(entity), entityModel, entityModel == v.model)
        end
        Citizen.Wait(2000)
    end
end)*/