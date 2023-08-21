local StreamerModes = {}

ESX.RegisterCommand("streamermode", "admin", function(xPlayer, args)
    StreamerModes[xPlayer.identifier] = not StreamerModes[xPlayer.identifier]
    if(StreamerModes[xPlayer.identifier]) then
        xPlayer.showNotification("Streamer Mode - Zapnut.")
    else
        xPlayer.showNotification("Streamer Mode - Vypnut.")
    end
end)

ESX.RegisterCommand("at", "admin", function(xPlayer, args)
    local message = table.concat(args, " ")
    local xAdmins = ESX.GetExtendedPlayers("group", "admin")
    for _,xAdmin in pairs(xAdmins) do
        if(not StreamerModes[xAdmin.identifier]) then
            TriggerClientEvent('chat:addMessage', xAdmin.source, {
                template = '<div style="padding: 0.5vw;margin: 0.05vw;background-color: rgba(192, 57, 43, 0.8);color: white;"><i class="fas fa-comment-alt"></i><b>ACHAT: {0} [ID: {1}] - {2}</b></div>',
                args = { name, xPlayer.source, message }
            })
        end
    end
end)

ESX.RegisterCommand("announce", "admin", function(xPlayer, args)
    local message = table.concat(args, " ")
    TriggerClientEvent('chat:addMessage', -1, {
        template = '<div style="padding: 0.5vw;margin: 0.05vw;background-color: rgba(192, 57, 43, 0.8);color: white;"><i class="fas fa-comment-alt"></i><b>OZNÁMENÍ: {0}</b></div>',
        args = { message }
    })
end)

ESX.RegisterCommand("report", "user", function(xPlayer, args)
    local message = table.concat(args, " ")

    local name = ESX.SanitizeString(GetPlayerName(xPlayer.source))
    TriggerClientEvent('chat:addMessage', xPlayer.source, {
        template = '<div style="padding: 0.5vw;margin: 0.05vw;background-color: rgba(192, 57, 43, 0.8);color: white;"><i class="fas fa-comment-alt"></i><b> {0} [ID: {1}] - {2}</b></div>',
        args = { name, xPlayer.source, message }
    })

    local xAdmins = ESX.GetExtendedPlayers("group", "admin")
    for _,xAdmin in pairs(xAdmins) do
        if(not StreamerModes[xAdmin.identifier]) then
            if(xAdmin.source ~= xPlayer.source) then
                TriggerClientEvent('chat:addMessage', xAdmin.source, {
                    template = '<div style="padding: 0.5vw;margin: 0.05vw;background-color: rgba(192, 57, 43, 0.8);color: white;"><i class="fas fa-comment-alt"></i><b> {0} [ID: {1}] - {2}</b></div>',
                    args = { name, xPlayer.source, message }
                })
            end
        end
    end
end, false)

ESX.RegisterCommand("reply", "admin", function(xPlayer, args)
    local targetId = tonumber(args[1])
    if(not targetId) then
        xPlayer.showNotification("Neplatné ID.", { type = "error" })
        return
    end

    local xTarget = ESX.GetPlayerFromId(targetId)
    if(not xTarget) then
        xPlayer.showNotification("Hráč neexistuje.", { type = "error" })
        return
    end

    local message = table.concat(args, " "):sub(args[1]:len() + 1)

    local name = ESX.SanitizeString(GetPlayerName(xPlayer.source))
    TriggerClientEvent('chat:addMessage', xTarget.source, {
        template = '<div style="padding: 0.5vw;margin: 0.05vw;background-color: rgba(192, 57, 43, 0.8);color: white;"><i class="fas fa-comment-alt"></i><b> {0} [ID: {1}] - {2}</b></div>',
        args = { name, xPlayer.source, message }
    })
    
    local xAdmins = ESX.GetExtendedPlayers("group", "admin")
    for _,xAdmin in pairs(xAdmins) do
        if(not StreamerModes[xAdmin.identifier]) then
            TriggerClientEvent('chat:addMessage', xAdmin.source, {
                template = '<div style="padding: 0.5vw;margin: 0.05vw;background-color: rgba(192, 57, 43, 0.8);color: white;"><i class="fas fa-comment-alt"></i><b> {0} [ID: {1}] - {2} [ID: {3}]</b></div>',
                args = { name, xPlayer.source, message, targetId }
            })
        end
    end
end, false)