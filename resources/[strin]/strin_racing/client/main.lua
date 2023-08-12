local IsCreatingARace = false
local CreatedPoints = {}
local CreatedPointsBlips = {}

RegisterCommand("rstart", function()
    TriggerEvent("strin_racing:startRaceCreator")
end)

RegisterCommand("rfinish", function()

end)

RegisterNetEvent("strin_racing:startRaceCreator", function()
    ESX.ShowNotification([[
        Otevřete mapu a zapomocí waypointů vytvářejte cílové body.<br/>
        Vytváření lze dokončit napsáním /rfinish.<br/>
        Maximální prodleva mezi vytvořením cílového bodu je 20 vteřin.<br/>
        Na vytvoření prvního cílového bodu máte 60 vteřin.<br/>
        Po uplynutí prodlevy se tvůrce závodů automaticky ukončí.<br/>
    ]], {
        length = 20000
    })

    if(GetFirstBlipInfoId(8) ~= 0) then
        SetWaypointOff()
    end
    IsCreatingARace = true
    local timeoutTimer = GetGameTimer()
    while IsCreatingARace do
        local currentTimer = GetGameTimer()
        local elapsedSeconds = (currentTimer - timeoutTimer) / 1000
        local markerBlip = GetFirstBlipInfoId(8)
        local timeoutSeconds = (#CreatedPoints > 0) and 20 or 60
        if(markerBlip ~= 0) then
            local coords = GetBlipInfoIdCoord(markerBlip)
            local blipDeleted = false
            if(#CreatedPoints > 0) then
                for k,v in pairs(CreatedPoints) do
                    local distance = #(coords - v.coords)
                    if(distance < 2.0) then
                        CreatedPoints[v.index] = nil
                        blipDeleted = true
                        local newPoints = {}
                        for k,v in pairs(CreatedPoints) do
                            local newPointIndex = #newPoints + 1 
                            newPoints[newPointIndex] = {
                                index = newPointIndex,
                                coords = v.coords,
                            }
                        end
                        CreatedPoints = newPoints
                        break
                    end
                end
                DeletePointBlips()
            end
            if(not blipDeleted) then
                local pointIndex = #CreatedPoints + 1 
                CreatedPoints[pointIndex] = {
                    index = pointIndex,
                    coords = coords,
                }
            end
            SetWaypointOff()
            SetupBlips()
            timeoutTimer = GetGameTimer()
        end
        if((elapsedSeconds >= timeoutSeconds)) then
            ESX.ShowNotification("Dlouho nebyl vytvořen cílový bod, činnost byla proto ukončena.", {
                type = "error",
            })
            DeletePointBlips()
            lib.hideTextUI()
            IsCreatingARace = false
            break
        end
        lib.showTextUI("Zbývající čas: "..math.floor(timeoutSeconds - elapsedSeconds).." sekund", {
            position = "left-center",
        })
        Citizen.Wait(500)
    end
end)

function DeletePointBlips()
    for _,v in pairs(CreatedPointsBlips) do
        RemoveBlip(v)
    end
    CreatedPointsBlips = {}
end

function SetupBlips()
    for k,v in pairs(CreatedPoints) do
        local blip = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
        SetBlipColour(blip, 5)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("<FONT FACE='Righteous'>Cílový bod</FONT>")
        ShowNumberOnBlip(blip, v.index)
        EndTextCommandSetBlipName(blip)
        table.insert(CreatedPointsBlips, blip)
    end
end

AddEventHandler("onResourceStop", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        DeletePointBlips()
    end
end)