RegisterNetEvent("strin_base:getNearbyPlayers")
AddEventHandler("strin_base:getNearbyPlayers", function(cb, dontIncludeSelf)
    local players = getNearbyPlayers(dontIncludeSelf) 
    cb(players)
end)

function getNearbyPlayers(dontIncludeSelf)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local foundPlayers = {}
    local players = ESX.Game.GetPlayers()
    for k,v in pairs(players) do
        local tPed = GetPlayerPed(v)
        local tCoords = GetEntityCoords(tPed)
        local distance = #(coords - tCoords)
        if(distance < 3.5) then
            if(dontIncludeSelf) then
                if(GetPlayerServerId(v) ~= GetPlayerServerId(Playerid())) then
                    table.insert(foundPlayers, {pName = GetPlayerName(v), pId = GetPlayerServerId(v)})
                end
            else
                table.insert(foundPlayers, {pName = GetPlayerName(v), pId = GetPlayerServerId(v)})
            end
        end
    end
    return foundPlayers
end