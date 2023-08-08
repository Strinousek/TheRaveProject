/*
    This is hard-coded on the server,
    because we dont want to let clients know
    that we know how many cases there are supposed to be.
    Let cheaters try <3
    edit:
    nvm we not doing it
*/

local JeweleryStatus = {
    Method = nil,
    IsBeingRobbed = false,
    NotifiedCops = false,
    JeweleryCases = {}
}

local RobbingPlayers = {}
local CheckJeweleryIntervalId = SetInterval(function()
    if(JeweleryStatus.IsBeingRobbed) then
        if(not AreAllJeweleryCasesRobbed()) then
            local foundPlayer = false
            for _, playerId in pairs(GetPlayers()) do
                local playerId = tonumber(playerId)
                local jewelery = GetNearestJewelery(playerId)
                if(jewelery) then
                    foundPlayer = true
                    break
                end
            end
            if(not foundPlayer and JeweleryStatus.IsBeingRobbed) then
                JeweleryStatus.JeweleryCases = {}
                SyncJeweleryStatus()
            end
        end
    end
end, 5000)

/*
    JeweleryCase States:
    1. FULL
    2. BEING_ROBBED
    3. EMPTY
*/

local JeweleryCasesCount = #JeweleryCases

RegisterNetEvent("strin_robberies:robJeweleryCase", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end
    
    local job = xPlayer.getJob()
    if(IsPlayerACop(job.name)) then
        xPlayer.showNotification("Nemůžete vykrádat vitríny jako strážník!", { type = "error" })
        return
    end

    if(RobbingPlayers[xPlayer.identifier]) then
        xPlayer.showNotification("Již vykrádáte vitrínu!", { type = "error" })
        return
    end

    if(not JeweleryStatus.IsBeingRobbed) then
        xPlayer.showNotification("Zlatnictví není vykrádáno!", { type = "error" })
        return
    end
    
    -- Check if player is near jewelery
    local jewelery = GetNearestJewelery(_source)
    if(not jewelery) then
        xPlayer.showNotification("Nejste poblíž žádnému zlatnictví!", { type = "error" })
        return
    end

    local jeweleryCaseId = GetNearestJeweleryCaseId(_source)
    if(not jeweleryCaseId) then
        xPlayer.showNotification("Nejste poblíž žádné vitríny!", { type = "error" })
        return
    end

    local jeweleryCase = JeweleryStatus.JeweleryCases[jeweleryCaseId]
    if(not jeweleryCase) then
        xPlayer.showNotification("Tahle vitrína neexistuje!", { type = "error" })
        return
    end
    if(jeweleryCase.state == "BEING_ROBBED") then
        xPlayer.showNotification("Tuhle vitrínu už někdo vykrádá!", { type = "error" })
        return
    end
    if(jeweleryCase.state == "EMPTY") then
        xPlayer.showNotification("Tahle vitrína už je vykradená!", { type = "error" })
        return
    end

    JeweleryStatus.JeweleryCases[jeweleryCaseId].state = "BEING_ROBBED"
    RobbingPlayers[xPlayer.identifier] = true

    SyncJeweleryStatus()
    TriggerClientEvent("strin_robberies:robJeweleryCase", _source, jeweleryCaseId)
    SetTimeout(JeweleryCaseRobTime, function()
        if(RobbingPlayers[xPlayer.identifier]) then
            JeweleryStatus.JeweleryCases[jeweleryCaseId].state = "EMPTY"
            local givenJewels = {}
            for k,v in pairs(jeweleryCase.content) do
                if(not givenJewels[v]) then
                    givenJewels[v] = 0
                end
                local amountOfJewels = math.random(1, 2)
                givenJewels[v] += amountOfJewels
                Inventory:AddItem(_source, v, amountOfJewels)
            end
            if(JeweleryStatus.Method == "SILENT" and not JeweleryStatus.NotifiedCops) then
                NotifyCops("ROBBERY", "Loupež ve zlatnictví", "Systémové zabezpečení", Jewelery.centerCoords)
                JeweleryStatus.NotifiedCops = true
            end
            Base:DiscordLog("DEFAULT", "THE RAVE PROJECT - LOUPEŽE - ZLATNICTVÍ", {
                { name = "Akce", value = "Vitrína vykradnuta" },
                { name = "Jméno hráče", value = ESX.SanitizeString(GetPlayerName(_source)) },
                { name = "Identifikace hráče", value = xPlayer.identifier },
                { name = "Index vitríny", value = jeweleryCaseId },
                { name = "Získané šperky", value = json.encode(givenJewels) },
                { name = "Informace o loupeži", value = json.encode(JeweleryStatus) },
                { name = "Informace o zlatnictví", value = json.encode(jewelery) },
            }, {
                fields = true
            })
            RobbingPlayers[xPlayer.identifier] = nil
            SyncJeweleryStatus()
        else
            JeweleryStatus.JeweleryCases[jeweleryCaseId].state = "FULL"
        end
    end)
end)

RegisterNetEvent("strin_robberies:requestJeweleryRobbery", function(robberyMethod)
    -- Just check if the method is valid from client
    if(robberyMethod ~= "SILENT" and robberyMethod ~= "LOUD") then
        return
    end
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

    local isAvailable, message = CheckBasicRobberyAvailability(JeweleryRequiredCops)
    if(not isAvailable) then
        xPlayer.showNotification(message, { type = "error" })
        return
    end

    -- Check if player is near jewelery
    local jewelery = GetNearestJewelery(_source)
    if(not jewelery) then
        xPlayer.showNotification("Nejste poblíž žádnému zlatnictví!", { type = "error" })
        return
    end

    -- Check if jewelery is already being robbed
    if(JeweleryStatus.IsBeingRobbed) then
        xPlayer.showNotification("Zlatnictví již vykrádané je!", { type = "error" })
        return
    end

    if(robberyMethod == "LOUD") then
        xPlayer.showNotification([[
            Spustil se alarm!<br/>
            Rychle vyberte všechny vitríny a utečte!
        ]], { type = "inform" })
        SetupJeweleryStatus(robberyMethod)
        JeweleryStatus.NotifiedCops = true
        NotifyCops("ROBBERY", "Loupež ve zlatnictví", "Ozbrojené přepadení", jewelery.centerCoords)
        Base:DiscordLog("DEFAULT", "THE RAVE PROJECT - LOUPEŽE - ZLATNICTVÍ", {
            { name = "Akce", value = "Loupež započnuta - LOUD" },
            { name = "Jméno hráče", value = ESX.SanitizeString(GetPlayerName(_source)) },
            { name = "Identifikace hráče", value = xPlayer.identifier },
            { name = "Informace o loupeži", value = json.encode(JeweleryStatus) },
            { name = "Informace o zlatnictví", value = json.encode(jewelery) },
        }, {
            fields = true
        })
        SyncJeweleryStatus()
    elseif(robberyMethod == "SILENT") then
        local lockpickCount = Inventory:GetItemCount(_source, "lockpick")
        if(lockpickCount <= 0) then
            xPlayer.showNotification("Nemáte sebou paklíč!", { type = "error" })
            return
        end
        lib.callback("strin_robberies:lockpickSecurityDoor", _source, function(success)
            if(success) then
                
                local job = xPlayer.getJob()
                if(IsPlayerACop(job.name)) then
                    xPlayer.showNotification("Nemůžete zakládat loupeže jako strážník!", { type = "error" })
                    return
                end

                local isAvailable, message = CheckBasicRobberyAvailability(JeweleryRequiredCops)
                if(not isAvailable) then
                    xPlayer.showNotification(message, { type = "error" })
                    return
                end

                if(JeweleryStatus.IsBeingRobbed) then
                    xPlayer.showNotification("Zlatnictví již vykrádané je!", { type = "error" })
                    return
                end

                Inventory:RemoveItem(_source, "lockpick", 1)
                xPlayer.showNotification([[
                    Dostal jste se do systému!<br/>
                    Alarm se spustí až po rozbití první vitríny, budete mít lehkou výhodu!
                ]], { type = "success" })

                SetupJeweleryStatus(robberyMethod)
                
                Base:DiscordLog("DEFAULT", "THE RAVE PROJECT - LOUPEŽE - ZLATNICTVÍ", {
                    { name = "Akce", value = "Loupež započnuta - STEALTH" },
                    { name = "Jméno hráče", value = ESX.SanitizeString(GetPlayerName(_source)) },
                    { name = "Identifikace hráče", value = xPlayer.identifier },
                    { name = "Informace o loupeži", value = json.encode(JeweleryStatus) },
                    { name = "Informace o zlatnictví", value = json.encode(jewelery) },
                }, {
                    fields = true
                })

                SyncJeweleryStatus()
            end
        end)
    end
end)

function SetupJeweleryStatus(method)
    JeweleryStatus.IsBeingRobbed = true
    JeweleryStatus.Method = method
    JeweleryStatus.JeweleryCases = lib.table.deepclone(JeweleryCases)
    
    for i=1, #JeweleryStatus.JeweleryCases do
        JeweleryStatus.JeweleryCases[i].state = "FULL"
    end

    Base:StartTimer(30)

    SetTimeout(JeweleryRefreshTime, function()
        if(JeweleryStatus.IsBeingRobbed) then
            ResetJeweleryStatus()
            SyncJeweleryStatus()
        end
    end)
end

function ResetJeweleryStatus()
    local status = {} 
    status.Method = nil
    status.IsBeingRobbed = false
    status.NotifiedCops = false
    status.JeweleryCases = {}
    JeweleryStatus = status
end

function AreAllJeweleryCasesRobbed()
    if(not JeweleryStatus.JeweleryCases or not next(JeweleryStatus.JeweleryCases)) then
        return false
    end
    for k,v in pairs(JeweleryStatus.JeweleryCases) do
        if(v.state == "FULL") then
            return false
        end
    end

    return true
end

function SyncJeweleryStatus(playerId)
    if(playerId) then
        TriggerClientEvent("strin_robberies:syncJeweleryStatus", playerId, JeweleryStatus)
    else
        TriggerClientEvent("strin_robberies:syncJeweleryStatus", -1, JeweleryStatus)
    end
end

function GetNearestJewelery(playerId)
    local ped = GetPlayerPed(playerId)
    local coords = GetEntityCoords(ped)
    local jewelery = nil
    local distanceToJewelery = 15000.0
    -- This will need to get reworked if we add more jeweleries
        local distance = #(coords - Jewelery.centerCoords)
        if(distance < distanceToJewelery) then
            distanceToJewelery = distance
            jewelery = Jewelery
        end
    --
    return (distanceToJewelery < 20) and jewelery or nil
end

function GetNearestJeweleryCaseId(playerId)
    local ped = GetPlayerPed(playerId)
    local coords = GetEntityCoords(ped)
    local jeweleryCaseId = nil
    local distanceToJeweleryCase = 15000.0
    for k,v in pairs(JeweleryStatus.JeweleryCases) do
        local distance = #(coords - v.coords)
        if(distance < distanceToJeweleryCase) then
            distanceToJeweleryCase = distance
            jeweleryCaseId = k
        end
    end
    return (distanceToJeweleryCase < 5) and jeweleryCaseId or nil
end

AddEventHandler("playerDropped", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end
    if(RobbingPlayers[xPlayer.identifier]) then
        RobbingPlayers[xPlayer.identifier] = nil
    end
end)