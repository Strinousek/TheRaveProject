local ShowAxon = false
local LawEnforcementJobs = exports.strin_jobs:GetLawEnforcementJobs()

RegisterNetEvent("esx:playerLoaded", function(xPlayer)
    if(lib.table.contains(LawEnforcementJobs, xPlayer.job?.name)) then
        lib.callback("strin_axon:getCode", false, function(code)
            ShowAxon = true
            SendNUIMessage({
                display = true,
                code = code,
            })
        end)
    end
end)

RegisterNetEvent('esx:setJob', function(job)
    if(not lib.table.contains(LawEnforcementJobs, job?.name)) then
        if(ShowAxon) then
            ShowAxon = false
            SendNUIMessage({
                display = false,
            })
        end
        return
    end
    lib.callback("strin_axon:getCode", false, function(code)
        ShowAxon = true
        SendNUIMessage({
            display = true,
            code = code,
        })
    end)
end)

RegisterCommand("axon", function()
    if(not lib.table.contains(LawEnforcementJobs, ESX?.PlayerData?.job?.name)) then
        ESX.ShowNotification("Nejste součástí LEO!", { type = "error" })
        return
    end
    if(ShowAxon) then
        ShowAxon = false
        SendNUIMessage({
            display = false,
        })
        return
    end

    lib.callback("strin_axon:getCode", false, function(code)
        ShowAxon = true
        SendNUIMessage({
            display = true,
            code = code,
        })
    end)
end)

AddEventHandler("onResourceStart", function(resourceName)
    if(GetCurrentResourceName() ~= resourceName) then
        return
    end
    if(not lib.table.contains(LawEnforcementJobs, ESX?.PlayerData?.job?.name)) then
        return
    end
    
    lib.callback("strin_axon:getCode", false, function(code)
        ShowAxon = true
        SendNUIMessage({
            display = true,
            code = code,
        })
    end)
end)