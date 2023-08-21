local Target = exports.ox_target
local LawEnforcementJobs = exports.strin_jobs:GetLawEnforcementJobs()

local IsTimerDisplayed = false

Citizen.CreateThread(function()
	ESX.FontId = RegisterFontId('Righteous')
end)

RegisterNetEvent("strin_jail:cancelTimer", function()
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end
    IsTimerDisplayed = false
end)

RegisterNetEvent("strin_jail:showTimer", function(remainingSeconds)
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end
    IsTimerDisplayed = true
    local lastGameTimer = GetGameTimer()
    while IsTimerDisplayed do
        if(GetGameTimer() - lastGameTimer >= 1000) then
            remainingSeconds -= 1
            lastGameTimer = GetGameTimer()
        end
        if(remainingSeconds > 0) then
            Draw2DText(("Propuštění za ~r~%s~w~ sekund."):format(math.floor(remainingSeconds)))
        else
            Draw2DText(("Budete propuštěn/a každou chvílí."))
        end
        Citizen.Wait(0)
    end
end)

Target:addGlobalPlayer({
    {
        label = "Uvěznit",
        onSelect = function(data)
            local playerId = NetworkGetPlayerIndexFromPed(data.entity)
            local netId = GetPlayerServerId(playerId)
            ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "jail_reason", {
                title = "Důvod uvěznění",
            }, function(data, menu)
                menu.close()
                if(not data.value) then
                    return
                end
                ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "jail_duration", {
                    title = "Doba uvěznění (v minutách)",
                }, function(data2, menu2)
                    menu2.close()
                    if(not tonumber(data2.value)) then
                        return
                    end
                    TriggerServerEvent("strin_jail:jailPlayer", netId, tonumber(data2.value), data.value)
                end, function(data2, menu2)
                    menu2.close()
                end)
            end, function(data, menu)
                menu.close()
            end)
        end,
        canInteract = function()
            return lib.table.contains(LawEnforcementJobs, ESX.PlayerData?.job?.name)
        end,
    }
})

function Draw2DText(text)
    SetTextFont(ESX.FontId)
    SetTextProportional(0)
    SetTextScale(0.4, 0.4)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(0.66 - 1.0/2, 1.44 - 1.0/2 + 0.005)
end