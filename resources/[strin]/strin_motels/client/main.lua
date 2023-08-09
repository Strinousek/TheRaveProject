local MotelBlips = {}
local Base = exports.strin_base

Citizen.CreateThread(function()
    AddTextEntry("STRIN_MOTELS:ROOM", "<FONT FACE='Righteous'>~g~<b>[E]</b>~s~ Pokoj")
    AddTextEntry("STRIN_MOTELS:EXIT_ROOM", "<FONT FACE='Righteous'>~g~<b>[E]</b>~s~ Opustit pokoj")
    for k,v in pairs(MOTELS) do
        local blipData = v.Blip
        blipData.id = k
        blipData.label = (blipData.prefixColour or "")..v.label
        MotelBlips[k] = Base:CreateBlip(blipData)
        for i=1, #v.Rooms do
            local roomEnter = v.Rooms[i]

            local roomEnterPoint = lib.points.new({
                coords = v.Rooms[i],
                distance = 5.0,
            })

            function roomEnterPoint:nearby()
                if(self.currentDistance < 1) then
                    DisplayHelpTextThisFrame("STRIN_MOTELS:ROOM")
                    if(IsControlJustReleased(0, 38)) then
                        EnterMotelRoom()
                    end
                    return
                end
                DrawMarker(0, v.Rooms[i] + vector3(0, 0, 0.6), 0, 0, 0, 0, 0, 0, 1.25, 1.25, 1.5, 255, 0, 0, 1, true)
            end
        end

        local roomExitPoint = lib.points.new({
            coords = v.RoomDefaults.exit,
            distance = 1.0
        })

        function roomExitPoint:nearby()
            DisplayHelpTextThisFrame("STRIN_MOTELS:EXIT_ROOM")
            if(IsControlJustReleased(0, 38)) then
                ExitMotelRoom()
            end
        end
    end
end)

RegisterNetEvent("strin_motels:teleportToRoom", function(motelIndex, roomIndex)
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end

    local canTeleport = lib.callback.await("strin_motels:canTeleport", false, motelIndex, roomIndex)
    if(not canTeleport) then
        return
    end

    DoScreenFadeOut(500)
    Citizen.Wait(500)
    StartPlayerTeleport(PlayerId(), MOTELS[motelIndex].RoomDefaults.exit, 0.0, false, true, false)
    while IsPlayerTeleportActive() do
        Citizen.Wait(0)
    end
    DoScreenFadeIn(500)
end)

function EnterMotelRoom()
    TriggerServerEvent("strin_motels:enterRoom")
end

function ExitMotelRoom()
    DoScreenFadeOut(500)
    Citizen.Wait(500)
    TriggerServerEvent("strin_motels:exitRoom")
    Citizen.Wait(500)
    DoScreenFadeIn(500)
end

AddEventHandler("onResourceStop", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        for k,v in pairs(MotelBlips) do
            Base:DeleteBlip(k)
        end
    end
end)