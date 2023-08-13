local IsCreatingARace = false
local CreatedPoints = {}
local CreatedPointsBlips = {}

local OngoingRaces = {}

local RacingPoints = {}
local RacingPointBlip = nil
local IsRacing = false

RegisterNetEvent("strin_racing:syncRaces", function(races)
    
    for k,v in pairs(OngoingRaces) do
        if(v.point) then
            v.point:remove()
        end
    end
    OngoingRaces = races

    for k,v in pairs(OngoingRaces) do
        local totalDistance = 0
        for _,raceTrackPoint in pairs(v.raceTrack.points) do
            raceTrackPoint.coords = vector3(raceTrackPoint.coords.x, raceTrackPoint.coords.y, raceTrackPoint.coords.z)
        end
        for i=1, #v.raceTrack.points do
            if(i > 1) then
                totalDistance += ESX.Math.Round(#(v.raceTrack.points[i].coords - v.raceTrack.points[i - 1].coords), 2)
            end
        end
        local lines = {
            "Závod: #"..k,
            "Počet připojených řidičů: "..(#v.players)..(v.maxPlayers ~= 0 and "/"..v.maxPlayers or ""),
            "Celková vzdálenost: "..(#v.players),
            "Počet kol: "..(v.laps),
            {
                "~g~<b>[E]</b>~s~ Zapojit se",
                function()
                    return cache.vehicle and (v.maxPlayers == 0 or ((#v.players + 1) <= v.maxPlayers)) and not v.players[cache.serverId]
                end,
                function()
                    TriggerServerEvent("strin_racing:joinRace", k)
                end,
            },
            {
                "~r~<b>[E]</b>~s~ Odpojit se",
                function()
                    return v.players[cache.serverId]
                end,
                function()
                    TriggerServerEvent("strin_racing:leaveRace")
                end,
            }
        }
        if(not v.point and v.state == "STARTING") then
            v.point = lib.points.new({
                coords = v.coords,
                distance = 20.0,
            })

            function v.point:nearby()
                DrawMarker(1, v.coords, 0, 0, 0, 0, 0, 0, 6.0, 6.0, 3.0, 0, 255, 0, 10)
                if(self.currentDistance < 6.0) then
                    local maxHeight = (#lines * 0.25)
                    for i=1, #lines do
                        local line = lines[i]
                        if(type(line) ~= "table" or line[2]()) then
                            DrawText3D(v.coords + vector3(0, 0, 0.75) + vector3(0, 0, maxHeight), line?[1] or line)
                            maxHeight -= 0.25
                            if(line[3] and IsControlJustReleased(0, 38)) then
                                line[3]()
                            end
                        end
                    end
                end
            end
        end
    end
end)

RegisterNetEvent("strin_racing:openRaceTrackMenu", function(raceTrackIndex)
    local raceTrack = lib.callback.await("strin_racing:getRaceTrack", false, raceTrackIndex)
    if(not raceTrack) then
        return
    end
    for k,v in pairs(raceTrack.points) do
        v.coords = vector3(v.coords.x, v.coords.y, v.coords.z)
    end
    CreatedPoints = raceTrack.points
    SetupBlips()
    local elements = {}
    local totalDistance = 0
    for i=1, #raceTrack.points do
        if(i > 1) then
            totalDistance += ESX.Math.Round(#(raceTrack.points[i].coords - raceTrack.points[i - 1].coords), 2)
        end
    end
    table.insert(elements, {
        label = ([[<div style="display: flex; justify-content: space-between; align-items: center;">
            Počet cílových bodů<div>%s</div>
        </div>]]):format(#raceTrack.points.."x"),
    })
    table.insert(elements, { 
        label = ([[<div style="display: flex; justify-content: space-between; align-items: center;">
            Celková vzdálenost<div>%s</div>
        </div>]]):format(ESX.Math.GroupDigits(totalDistance).."m"),
    })
    table.insert(elements, { 
        label = ("Počet kol"),
        min = 1,
        value = 1,
        max = 5,
        type = "slider",
        key = "laps"
    })
    table.insert(elements, { 
        label = ("Automatický start za (n * 20) vteřin"),
        min = 1,
        value = 3,
        max = 6,
        type = "slider",
        key = "automatic_start"
    })
    table.insert(elements, { 
        label = ("Maximální počet řidičů (0 pro neomezeno)"),
        min = 0,
        value = 0,
        max = 20,
        type = "slider",
        key = "max_players"
    })
    table.insert(elements, { 
        label = ("Započnout závod"),
        key = "start"
    })
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "race_track_menu", {
        title = raceTrack.label,
        align = "center",
        elements = elements,
    }, function(data, menu)
        if(data.current.key == "start") then
            menu.close()
            CreatedPoints = {}
            DeletePointBlips()
            local raceData = {}
            for k,v in pairs(data.elements) do
                if(v.key and v.key ~= "start") then
                    raceData[v.key] = v.value
                end
            end
            TriggerServerEvent("strin_racing:initRace", raceTrackIndex, raceData)
        end
    end, function(data, menu)
        menu.close()
        CreatedPoints = {}
        DeletePointBlips()
        ExecuteCommand("rcreate")
    end)
end)

RegisterCommand("rcreate", function()
    if(IsRacing) then
        return
    end
    local elements = {}
    table.insert(elements, {
        label = "Vytvořit nový závod", value = "new_race",
    })
    local raceTracks = lib.callback.await("strin_racing:getRaceTracks", false)
    if(next(raceTracks)) then
        for k,v in pairs(raceTracks) do
            table.insert(elements, {
                label = v.label.." - #"..k, value = k,
            })
        end
    end
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "race_menu", {
        title = "Závodní menu",
        align = "center",
        elements = elements,
    }, function(data, menu)
        menu.close()
        if(data.current.value == "new_race") then    
            TriggerEvent("strin_racing:startRaceCreator")
        else
            TriggerEvent("strin_racing:openRaceTrackMenu", data.current.value)
        end
    end, function(data, menu)
        menu.close()
    end)
end)

RegisterCommand("rfinish", function()
    if(IsRacing) then
        return
    end
    if(not IsCreatingARace or #CreatedPoints <= 0) then
        return
    end
    
    IsCreatingARace = false
    SetupBlips()
    local elements = {}
    table.insert(elements, { 
        label = "Potvrdit",
        value = "confirm",
    })
    local totalDistance = 0
    for i=1, #CreatedPoints do
        if(i > 1) then
            totalDistance += ESX.Math.Round(#(CreatedPoints[i].coords - CreatedPoints[i - 1].coords), 2)
        end
        /*table.insert(elements, {
            label = ([[<div style="display: flex; justify-content: space-between; align-items: center;">
                Cílový bod - #%s<div>%s</div>
            </div>]]):format(i, distance and ESX.Math.GroupDigits(distance).."m" or ""),
        })*/
    end
    table.insert(elements, {
        label = ([[<div style="display: flex; justify-content: space-between; align-items: center;">
            Počet cílových bodů<div>%s</div>
        </div>]]):format(#CreatedPoints.."x"),
    })
    table.insert(elements, { 
        label = ([[<div style="display: flex; justify-content: space-between; align-items: center;">
            Celková vzdálenost<div>%s</div>
        </div>]]):format(ESX.Math.GroupDigits(totalDistance).."m"),
    })
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "race_creator_menu", {
        title = "Tvůrce závodů",
        align = "center",
        elements = elements,
    }, function(data, menu)
        if(data.current.value == "confirm") then
            menu.close()
            DeletePointBlips()
            if(GetCurrentFrontendMenuVersion() ~= -1) then
                SetFrontendActive(false)
            end
            ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "race_track_label", {
                title = "Název závodu",
            }, function(data2, menu2)
                menu2.close()
                if(not data2.value or data2.value:len() == 0) then
                    data2.value = "Závod"
                end
                TriggerServerEvent("strin_racing:registerRaceTrack", data2.value, CreatedPoints)
                CreatedPoints = {}
            end, function(data2, menu2)
                menu2.close()
                CreatedPoints = {}
            end)
        end
    end, function(data, menu)
        menu.close()
        DeletePointBlips()
        CreatedPoints = {}
    end)
end)

RegisterCommand("rleave", function()
    TriggerServerEvent("strin_racing:leaveRace")
end)

RegisterNetEvent("strin_racing:startRaceCreator", function()
    ESX.ShowNotification([[
        Otevřete mapu a zapomocí waypointů vytvářejte cílové body.<br/>
        Vytváření lze manuálně dokončit napsáním /rfinish.<br/>
        Maximální prodleva mezi vytvořením cílového bodu je 20 vteřin.<br/>
        Na vytvoření prvního cílového bodu máte 60 vteřin.<br/>
        Po uplynutí prodlevy se tvůrce závodů automaticky ukončí.<br/>
        Dvojitým kliknutím v blízkosti vytvořeného cílového bodu, smažete nejbližší cílový bod.
    ]], {
        length = 20000
    })

    if(GetFirstBlipInfoId(8) ~= 0) then
        SetWaypointOff()
        Citizen.Wait(500)
    end

    CreatedPoints = {}
    IsCreatingARace = true
    local timeoutTimer = GetGameTimer()
    while true do
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
        if((elapsedSeconds >= timeoutSeconds) or not IsCreatingARace) then
            if(IsCreatingARace) then
                ESX.ShowNotification("Dlouho nebyl vytvořen cílový bod, činnost byla proto ukončena.", {
                    type = "error",
                })
            end
            DeletePointBlips()
            lib.hideTextUI()
            if(IsCreatingARace) then
                ExecuteCommand("rfinish")
            end
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

function DrawText3D(coords, text)
    local vector = type(coords) == "vector3" and coords or vec(coords.x, coords.y, coords.z)

    local camCoords = GetFinalRenderedCamCoord()
    local distance = #(vector - camCoords)
    local size = 1.25

    local scale = (size / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    SetTextScale(0.0 * scale, 0.55 * scale)
    SetTextFont(ESX.FontId)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    BeginTextCommandDisplayText('STRING')
    SetTextCentre(true)
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(vector.xyz, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

AddEventHandler("onResourceStop", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        DeletePointBlips()
    end
end)