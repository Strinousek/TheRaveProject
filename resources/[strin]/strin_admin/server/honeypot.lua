local HoneyPotEvents = {}
local HoneyPotEventHandlers = {}

Citizen.CreateThread(function()
    local fileContent = LoadResourceFile("strin_admin", "server/honeypot.json")
    if(not fileContent) then
        SaveResourceFile("strin_admin", "server/honeypot.json", "[]", -1)
    else
        HoneyPotEvents = json.decode(fileContent)
    end
    for k,v in pairs(HoneyPotEvents) do
        HoneyPotEventHandlers[v] = RegisterNetEvent(v, function()
            local _source = source
            BanOnlinePlayer(nil, _source, -1, "Zneužití eventu - "..v)
        end)
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        for k,v in pairs(HoneyPotEventHandlers) do
            RemoveEventHandler(v)
        end
    end
end)