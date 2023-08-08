hasOpenedScoreboard = false
onlinePlayers = {}

Citizen.CreateThread(function()
    onlinePlayers = lib.callback.await("strin_scoreboard:getPlayers", false)
end)

RegisterNetEvent('strin_scoreboard:updatePlayers')
AddEventHandler('strin_scoreboard:updatePlayers', function(players)
	onlinePlayers = players
end)

--[[RegisterNetEvent('strin_scoreboard:updateActivities')
AddEventHandler('strin_scoreboard:updateActivities', function(updatedActivities)
	activites = updatedActivities
    SendNUIMessage({
        action = "updateActivities",
        activities = updatedActivities,
    })
end)]]

RegisterCommand("opensb", function(source, args)
    if(next(onlinePlayers)) then
        if(hasOpenedScoreboard == true) then
            hasOpenedScoreboard = false
            SendNUIMessage({
                action = "hideScoreboard",
            })
        elseif(hasOpenedScoreboard == false) then
            hasOpenedScoreboard = true
            SendNUIMessage({
                action = "showScoreboard",
                players = onlinePlayers,
            })
            while true do
                Citizen.Wait(0)
                if(not hasOpenedScoreboard) then
                    break
                end
                if(IsControlJustReleased(0, 174)) then -- a
                    SendNUIMessage({
                        action = "switch",
                        side = "LEFT"
                    })
                end
                if((IsControlJustReleased(0, 175))) then -- d
                    SendNUIMessage({
                        action = "switch",
                        side = "RIGHT"
                    })
                end
            end
        end
    end
end)

RegisterKeyMapping('opensb', '<FONT FACE="Righteous">Otevřít tabulku hráčů~</FONT>', 'keyboard', "DELETE")