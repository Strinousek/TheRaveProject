local SlothUI = exports["ps-ui"]

local BanksInUse = {}
local TimerRunningForBankId = nil

RegisterNetEvent("strin_robberies:syncBanksInUse", function(banksInUse)
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end
    for k,v in pairs(banksInUse) do
        if(v.state == "HACKED") then
            if(not BanksInUse[k]?.estimatedRobbedOn) then
                v.estimatedRobbedOn = GetGameTimer() + BanksRobTime
            else
                v.estimatedRobbedOn = BanksInUse[k]?.estimatedRobbedOn
            end
        end
    end
    BanksInUse = banksInUse
end)

lib.callback.register("strin_robberies:startHackingBank", function(bankId)
    local deviceHash = GetHashKey(BanksDeviceModel)
    RequestModel(deviceHash)
    while (not HasModelLoaded(deviceHash)) do
        Citizen.Wait(0)
    end
    local bank = Banks[bankId]
    local ped = PlayerPedId()
    SetEntityCoords(ped, bank.codeLock.coords.x, bank.codeLock.coords.y, bank.codeLock.coords.z - 1.0)
    SetEntityHeading(ped, bank.codeLock.heading)
    FreezeEntityPosition(ped, true)
    TaskStartScenarioInPlace(ped, "PROP_HUMAN_ATM", 0, true)
    Citizen.Wait(1000)
    local deviceObject = CreateObject(deviceHash, bank.codeLock.coords, true, true)
    local boneIndex = GetPedBoneIndex(ped, 28422)
    AttachEntityToEntity(deviceObject, ped, boneIndex, 0.12, 0.028, 0.001, 10.0, 175.0, 0.0, true, true, false, true, 1, true)
    local results = {}
    for i=1, #BanksHackingTimers do
        results[i] = SlothUI:Scrambler(nil, "numeric", BanksHackingTimers[i])
        Citizen.Wait(1000)
        if(not results[i]) then
            break
        end
    end
    DetachEntity(deviceObject)
    DeleteEntity(deviceObject)
    FreezeEntityPosition(ped, false)
    ClearPedTasks(ped)
    return results
end)

Citizen.CreateThread(function()
    AddTextEntry("STRIN_ROBBERIES:CODE", "<FONT FACE='Righteous'>~g~<b>[E]~w~</b> Hack</FONT>")
    local hackingDeviceCount = 0
    for bankId, bank in pairs(Banks) do
        local bankPoint = lib.points.new({
            coords = bank.coords,
            distance = 1.0
        })

        function bankPoint:onEnter()
            hackingDeviceCount = Inventory:GetItemCount("hackdeck")
        end

        function bankPoint:onExit()
            hackingDeviceCount = 0
            TimerRunningForBankId = nil
        end

        function bankPoint:nearby()
            local bankInUse = BanksInUse[bankId] 
            if(not bankInUse) then
                DrawFloatingText(bank.codeLock.coords, "STRIN_ROBBERIES:CODE")
                if(IsControlJustReleased(0, 38)) then
                    if(hackingDeviceCount > 0) then
                        TriggerServerEvent("strin_robberies:requestBankRobbery")
                    else
                        ESX.ShowNotification("Nemáte u sebe zařízení pro prolomení bezpečnostního systému!", { type = "error" })
                    end
                end
            else
                if(bankInUse?.state == "HACKED" and bankInUse?.estimatedRobbedOn) then 
                    ShowTimer(bankInUse?.estimatedRobbedOn)
                end
            end
        end
    end
end)

function ShowTimer(estimatedRobbedOn)
    local remainingSeconds = math.floor((estimatedRobbedOn - GetGameTimer()) / 1000) 
    if(remainingSeconds > 0) then
        Draw2DText(("Trezor se otevře za ~r~%s~w~ sekund"):format(remainingSeconds))
    else
        Draw2DText(("Trezor se otevře každou chvílí"))
    end
end