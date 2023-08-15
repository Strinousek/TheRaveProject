local showAxon = false

RegisterNetEvent("esx:playerLoaded", function()
    if(ESX?.PlayerData?.job?.name == "police") then
        local code = lib.callback.await("strin_axon:getCode")
        showAxon = true
        SendNUIMessage({
            display = true,
            code = code,
        })
    end
end)

RegisterNetEvent('esx:setJob', function(job)
    if(ESX?.PlayerData?.job?.name == "police") then
        showAxon = true
        if(not showAxon) then
            local code = lib.callback.await("strin_axon:getCode")
            showAxon = true
            SendNUIMessage({
                display = true,
                code = code,
            })
        else
            showAxon = false
            SendNUIMessage({
                display = false,
            })
        end
    else
        if(showAxon) then
            showAxon = false
            SendNUIMessage({
                display = false,
            })
        end
    end
end)

RegisterCommand("axon", function()
    if(ESX?.PlayerData?.job?.name == "police") then
        if(not showAxon) then
            local code = lib.callback.await("strin_axon:getCode")
            showAxon = true
            SendNUIMessage({
                display = true,
                code = code,
            })
        else
            showAxon = false
            SendNUIMessage({
                display = false,
            })
        end
    end
end)

AddEventHandler("onResourceStart", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        if(ESX?.PlayerData?.job?.name == "police") then
            local code = lib.callback.await("strin_axon:getCode")
            showAxon = true
            SendNUIMessage({
                display = true,
                code = code,
            })
        end
    end
end)