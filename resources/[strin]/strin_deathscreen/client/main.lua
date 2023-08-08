local IsDead = false
local IsDeathscreenVisible = false

AddEventHandler("esx:onPlayerSpawn", function()
    IsDead = false
    if(IsDeathscreenVisible) then
        HideDeathscreen()
    end
end)

AddEventHandler("strin_deathscreen:distress", function(lockDistress)
    if(IsDeathscreenVisible) then
        SendNUIMessage({
            action = "distress",
            lockDistress = lockDistress
        })
    end
end)

AddEventHandler("esx:onPlayerDeath", function()
    IsDead = true
end)

RegisterNetEvent("strin_jobs:startDeathTimer", function(timer)
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end
    ShowDeathscreen(timer)
    SetTimeout(timer, function()
        if(IsDead) then
            while IsDead do
                if(IsControlPressed(0, 38)) then
                    TriggerServerEvent("strin_jobs:checkDeathTimer")
                end
                Citizen.Wait(0)
            end
        end
    end)
end)

function ShowDeathscreen(time)
    if(IsDead) then
        -- if the time is over 1000 than its probably in milliseconds :KEKW:
        local time = time
        if(time > 1000) then
            time = time / 1000
        end
        IsDeathscreenVisible = true
        SendNUIMessage({
            action = "show",
            time = time
        })
    end
end

exports("ShowDeathscreen", ShowDeathscreen)

function HideDeathscreen()
    if(IsDeathscreenVisible) then
        IsDeathscreenVisible = false
        SendNUIMessage({
            action = "hide"
        })
    end
end

exports("HideDeathscreen", HideDeathscreen)