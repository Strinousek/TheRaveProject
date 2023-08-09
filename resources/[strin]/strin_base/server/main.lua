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

lib.callback.register("strin_base:getPhoneNumber", function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    return xPlayer.get("phone_number")
end)