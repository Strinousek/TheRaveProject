RegisteredHeres = {}
RegisteredStates = {}

DiscordWebhooks = {
    ["ABUSE"] = "https://discord.com/api/webhooks/679811102330060845/-g8UbXCQT5LS8QKZs2PZK8wn1d-gHk7yhQW9NSDA0NDkvrCfgm7MMqBRFK2y2gTZaW3o",
    ["RP"] = "https://discord.com/api/webhooks/679797776644964407/TcyN5Qt7TOw7KS_E2LJLRHPQbNpjzFktDVW6vpNerkqWjd5S2JGo9sUHmLLtXt96Ngo7"
}

Base = exports.strin_base
StrinJobs = exports.strin_jobs
LawEnforcementJobs = StrinJobs:GetLawEnforcementJobs()

do
    for k,v in pairs(DiscordWebhooks) do
        Base:RegisterWebhook(k, v)
    end
end

function getIdentity(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    return {
        firstname = xPlayer.get("firstname"),
        lastname = xPlayer.get("lastname"),
        fullname = xPlayer.get("fullname"),
        dateofbirth = xPlayer.get("dateofbirth"),
        sex = xPlayer.get("sex"),
        height = xPlayer.get("height"),
        group = xPlayer.getGroup(),
        name = ESX.SanitizeString(GetPlayerName(source)),
        job = xPlayer.getJob().name,
    }
end

function EditHere(index, message, identifier)
    if(RegisteredHeres?[identifier] and next(RegisteredHeres?[identifier]) ~= nil) then
        if(RegisteredHeres?[identifier]?[index]) then
            RegisteredHeres[identifier][index].message = message
            SyncHeres(-1)
        end
    end
end

function RemoveHere(index, identifier)
    if(RegisteredHeres?[identifier] and next(RegisteredHeres?[identifier]) ~= nil) then
        if(RegisteredHeres?[identifier]?[index]) then
            RegisteredHeres[identifier][index] = nil
            SyncHeres(-1)
        end
    end
end

function CheckForFreeHereSpot(registeredHeres)
    local spots = { 1, 2, 3, 4, 5 }
    for k,v in pairs(registeredHeres) do
        spots[k] = nil
    end
    if(#spots == 0) then
        return nil
    end
    local sanitizedSpots = {}
    for _,v in pairs(spots) do
        table.insert(sanitizedSpots, v)
    end
    table.sort(sanitizedSpots, function(a,b) return a > b end)
    return sanitizedSpots[1]
end

function CreateHere(message, coords, identifier)
    if(RegisteredHeres?[identifier] and next(RegisteredHeres?[identifier])) then
        local spot = CheckForFreeHereSpot(RegisteredHeres?[identifier])
        if(not spot) then
            local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
            xPlayer.showNotification("Již máte maximální počet /zde.", { type = "error" })
            return
        end
        RegisteredHeres[identifier][spot] = {
            coords = coords,
            message = message,
        }
    else
        RegisteredHeres[identifier] = {
            [1] = {
                coords = coords,
                message = message,
            }
        }
    end
    SyncHeres(-1)
end

function SyncHeres(playerId)
    TriggerClientEvent("strin_rpchat:syncHeres", playerId, RegisteredHeres)
end

function SyncStates(playerId)
    TriggerClientEvent("strin_rpchat:syncStates", playerId, RegisteredStates)
end

AddEventHandler('chatMessage', function(source, name, message)
  if string.sub(message, 1, string.len("/")) ~= "/" then
    local name = ESX.SanitizeString(GetPlayerName(source))
    TriggerClientEvent("sendProximityMessage", -1, source, "[L-OOC] " ..name, message)
    setLog(message, source)
  end
  TriggerEvent("strin_rpchat:chatMessage", source, name, message)
  CancelEvent()
end)

ESX.RegisterCommand("me", "user", function(xPlayer, args)
    local name = getIdentity(xPlayer.source)
    local fullName = name.fullname
    Base:DiscordLog("RP", "[ME] - "..xPlayer.getName(), fullName.." - "..table.concat(args, " "))
    TriggerClientEvent("sendProximityMessageMe", -1, xPlayer.source, name.firstname .. " " .. name.lastname, table.concat(args, " "))
end)

ESX.RegisterCommand("do", "user", function(xPlayer, args)
    local name = getIdentity(xPlayer.source)
    local fullName = name.fullname
    Base:DiscordLog("RP", "[DO] - "..xPlayer.getName(), fullName.." - "..table.concat(args, " "))
    TriggerClientEvent("sendProximityMessageDo", -1, xPlayer.source, name.firstname .. " " .. name.lastname, table.concat(args, " "))
end)

ESX.RegisterCommand("stav", "user", function(xPlayer, args)
    local name = getIdentity(xPlayer.source)
    local message = table.concat(args, " ")
    if(message:len() > 0) then
        RegisteredStates[xPlayer.source] = message
        SyncStates(-1)
    else
        RegisteredStates[xPlayer.source] = nil
        SyncStates(-1)
    end
end)

ESX.RegisterCommand("zde", "user", function(xPlayer, args)
    local message = table.concat(args, " ")
    local ped = GetPlayerPed(xPlayer.source)
    local coords = GetEntityCoords(ped) + vector(0.0, 0.0, 0.25)
    CreateHere(message, coords, xPlayer.identifier)
end)

ESX.RegisterCommand("zdelist", "user", function(xPlayer)
    TriggerClientEvent("strin_rpchat:openHeresMenu", xPlayer.source, RegisteredHeres?[xPlayer.identifier] or {})
end)

RegisterNetEvent("strin_rpchat:updateHere", function(hereId, message)
    if(type(hereId) ~= "number" or type(message) ~= "string") then
        return
    end
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end
    if(message:len() == 0) then
        RemoveHere(tonumber(hereId), xPlayer.identifier)
    else
        EditHere(tonumber(hereId), message, xPlayer.identifier)
    end
end)

ESX.RegisterCommand("doc", "user", function(xPlayer, args)
    local name = getIdentity(xPlayer.source)
    local fullName = name.fullname
    Base:DiscordLog("RP", "[DOC] - "..xPlayer.getName(), fullName.." - "..table.concat(args, " "))
    TriggerClientEvent("sendProximityMessageDoc", -1, xPlayer.source, name.firstname .. " " .. name.lastname, table.concat(args, " "))
end)

ESX.RegisterCommand("try", "user", function(xPlayer, args)
    local name = getIdentity(xPlayer.source)
    local fullName = name.fullname
    math.randomseed(os.time())
    local randomIndex = math.random(1,2)
    local messages = {"Ano", "Ne"}
    Base:DiscordLog("RP", "[TRY] - "..xPlayer.getName(), fullName.." - "..messages[randomIndex])
    TriggerClientEvent("sendProximityMessageDo", -1, xPlayer.source, name.firstname .. " " .. name.lastname, messages[randomIndex])
end)

/*ESX.RegisterCommand("3d", "user", function(xPlayer, args)
    TriggerClientEvent("sendProximityMessage3D", xPlayer.source, xPlayer.source)
end)

ESX.RegisterCommand("relchar", "user", function(xPlayer, args)
    TriggerClientEvent("char:reload", xPlayer.source)
end)*/

RegisterCommand('pd', function(source, args)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local job = xPlayer.getJob()
    local message = table.concat(args, " ")
    if lib.table.contains(LawEnforcementJobs, job.name) then
        TriggerClientEvent('chat:addMessage', -1, {
            template = '<div style="padding: 0.5vw; margin: 0.05vw; background-color: rgba(41, 128, 185, 0.6);"><i class="fas fa-briefcase"></i> <b>LSPD</b><br> {0}</div>',
            args = { message }
        })
        Base:DiscordLog("RP", "PD Chat", {
            ("**%s | %s | %s**"):format(GetPlayerName(_source), xPlayer.identifier, _source),
            message,
        })
        setLog(message, _source)        
    else     
        Base:DiscordLog("ABUSE", "Pokus o zneužití PD chatu", {
            ("**%s | %s | %s**"):format(GetPlayerName(_source), xPlayer.identifier, _source),
            message,
        })
	    TriggerClientEvent('chat:addMessage', _source, {
            template = '<div style="padding: 0.5vw; margin: 0.05vw; background-color: rgba(255, 0, 0, 0.7);"><i class="fas fa-exclamation-triangle"></i> <b>TO MYSLÍŠ VÁŽNĚ?</b> <i class="fas fa-exclamation-triangle"></i><br>^7 PŘIPADÁŠ SI SNAD JAKO POLICISTA?</div>',
            args = { message }
        })
    end   
end, false)

RegisterCommand("3d", function(source)
    TriggerClientEvent("sendProximityMessage3D", source)
end)

RegisterCommand('ems', function(source, args)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local job = xPlayer.getJob()
    local message = table.concat(args, " ")
    if lib.table.contains({"ambulance", "fire"}, job.name) then
        TriggerClientEvent('chat:addMessage', -1, {
            template = '<div style="padding: 0.5vw; margin: 0.05vw; background-color: rgba(231, 76, 60, 0.6)"><i class="fas fa-briefcase"></i> <b>EMS</b><br> {0}</div>',
            args = { message }
        })
        Base:DiscordLog("RP", "EMS Chat", {
            ("**%s | %s | %s**"):format(GetPlayerName(_source), xPlayer.identifier, _source),
            message,
        })
        setLog(message, _source)        
    else     
        Base:DiscordLog("ABUSE", "Pokus o zneužití EMS chatu", {
            ("**%s | %s | %s**"):format(GetPlayerName(_source), xPlayer.identifier, _source),
            message,
        })
	    TriggerClientEvent('chat:addMessage', _source, {
            template = '<div style="padding: 0.5vw; margin: 0.05vw; background-color: rgba(255, 0, 0, 0.7);"><i class="fas fa-exclamation-triangle"></i> <b>TO MYSLÍŠ VÁŽNĚ?</b> <i class="fas fa-exclamation-triangle"></i><br>^7 PŘIPADÁŠ SI SNAD JAKO DOKTOR?</div>',
            args = { message }
        })
    end   
end, false)

RegisterNetEvent('3dme:shareDisplay', function(text)
    TriggerClientEvent('3dme:triggerDisplay', -1, text, source)
    setLog(text, source)
end)

RegisterNetEvent('3dme:shareDisplayProS', function(text)
    TriggerClientEvent('3dme:triggerDisplayProS', -1, text, source)
    setLog(text, source)
end)

function setLog(text, source)
  local time = os.date("%d/%m/%Y %X")
  local name = GetPlayerName(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  local identifier = xPlayer.identifier
  local data = time .. ' : ' .. name .. ' - ' .. identifier .. ' : ' .. text

  local content = LoadResourceFile(GetCurrentResourceName(), "log.txt")
  local newContent = content .. '\r\n' .. data
  SaveResourceFile(GetCurrentResourceName(), "log.txt", newContent, -1)
end

AddEventHandler('playerDropped', function()
    local _source = source
    if(RegisteredStates[_source] ~= nil) then
        RegisteredStates[_source] = nil
        SyncStates(-1)
    end
end)