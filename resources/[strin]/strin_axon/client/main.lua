local showAxon = false
local checked = false

RegisterNetEvent("esx:playerLoaded", function()
    if(not checked) then
        checked = true
        if(ESX.PlayerData.job and ESX.PlayerData.job.name == "police" and not showAxon) then
            local code = lib.callback.await("strin_axon:getCode")
            showAxon = true
            SendNUIMessage({
                display = true,
                code = code,
            })
        end
    end
end)

RegisterNetEvent('esx:setJob', function(job)
    if(job.name == "police" and not showAxon) then
        local code = lib.callback.await("strin_axon:getCode")
        showAxon = true
        SendNUIMessage({
            display = true,
            code = code,
        })
    elseif(job.name ~= "police" and showAxon) then
        showAxon = false
        SendNUIMessage({
            display = false,
        })
    end
end)

AddEventHandler("onResourceStart", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        if(not checked) then
            checked = true
            if(ESX.PlayerData.job and ESX.PlayerData.job.name == "police" and not showAxon) then
                local code = lib.callback.await("strin_axon:getCode")
                showAxon = true
                SendNUIMessage({
                    display = true,
                    code = code,
                })
            end
        end
    end
end)