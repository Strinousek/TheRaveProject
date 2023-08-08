local watched = false
local spawned = false
local shutdowned = false

function CheckLoadingScreenShutdown()
    if(watched and spawned and not shutdowned) then
        ShutdownLoadingScreen()
        ShutdownLoadingScreenNui()
        TriggerEvent("esx:loadingScreenOff")
        shutdowned = true
        SendLoadingScreenMessage(json.encode({
            action = "hideLoadingScreen"
        }))
        Citizen.Wait(1000)
        SetNuiFocus(false, false)
    end
end

RegisterNUICallback("status", function(data, cb)
    watched = data
    CheckLoadingScreenShutdown()
    cb("Ok")
end)

RegisterNetEvent("esx:onPlayerSpawn", function()
    spawned = true
    CheckLoadingScreenShutdown()
end)

AddEventHandler("onClientResourceStart", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        SendLoadingScreenMessage(json.encode({
            action = "resourceReady"
        }))
    end
end)
