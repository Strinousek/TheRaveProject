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

/*ESX.RegisterCommand("showentity", "admin", function(xPlayer, args)
    local id = tonumber(args[1]) or 1
    if(id and (id == 1 or id == 2)) then
        TriggerClientEvent('strin_base:showEntity', xPlayer.source, id)
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


local DEBUG_MODE_ON = false
ESX.RegisterCommand("debugmode", "admin", function(xPlayer)
    DEBUG_MODE_ON = not DEBUG_MODE_ON
    xPlayer.showNotification("Debug Mode: "..(DEBUG_MODE_ON and "ON" or "OFF"))
    TriggerEvent("strin_base:debugStateChange", DEBUG_MODE_ON, function()
        print((GetInvokingResource() or GetCurrentResourceName())..": DEBUG MODE - "..(DEBUG_MODE_ON and "ON" or "OFF"))
    end)
end)

lib.callback.register("strin_base:getPhoneNumber", function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    return xPlayer.get("phone_number")
end)