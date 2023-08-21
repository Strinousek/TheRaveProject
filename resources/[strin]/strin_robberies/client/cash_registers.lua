local CashRegistersInUse = {}
local CurrentCashRegister = {
    entity = nil,
    coords = nil
}

RegisterNetEvent("strin_robberies:syncCashRegistersInUse", function(cashRegistersInUse)
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end

    CashRegistersInUse = cashRegistersInUse
end)

RegisterNetEvent("strin_robberies:timeCashRegisterRobbery", function(time, registerId)
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local registerCoords = CashRegisters[registerId]
    local distanceToRegister = #(coords - registerCoords)
    if(distanceToRegister > 20) then
        return
    end

    local remainingTimeInSeconds = (time / 1000)
    local lastGameTimer = GetGameTimer()
    while true do
        if(GetGameTimer() - lastGameTimer  >= 1000) then
            remainingTimeInSeconds -= 1
            lastGameTimer = GetGameTimer()
        end

        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local distanceToRegister = #(coords - registerCoords)

        if(remainingTimeInSeconds <= 0 or not IsRegisterInUse(registerId) or CashRegistersInUse[registerId].state == "CANCELLED" or (distanceToRegister > 20)) then
            break
        end
        Draw2DText(("Kasa se otevře za ~r~%s~w~ sekund"):format(math.floor(remainingTimeInSeconds)))
        Citizen.Wait(0)
    end
end)

lib.callback.register("strin_robberies:lockpickCashRegister", function()
    if(CurrentCashRegister.entity) then
        local ped = PlayerPedId()
        local cashRegisterHeading = GetEntityHeading(CurrentCashRegister.entity)
        SetEntityHeading(ped, cashRegisterHeading)
        PlayAnim(ped, "mp_arresting", "a_uncuff")
        --PlayAnim(ped, "mini@safe_cracking", "dial_turn_clock_normal")
        local skillCheckResult = lib.skillCheck({"easy", "easy", "easy", "easy"}, {"q", "w", "e", "r"})
        ClearPedTasks(ped)
        return skillCheckResult
    else
        return nil
    end
end)

Citizen.CreateThread(function()
    local lockpickCount = 0

    AddTextEntry("STRIN_ROBBERIES:CASH_REGISTERS:INTERACT", "<FONT FACE='Righteous'>~g~<b>[E]</b>~s~ Vykrást kasu</FONT>")

    for registerId,registerLocation in pairs(CashRegisters) do
        local registerPoint = lib.points.new({
            coords = registerLocation,
            distance = 1.0,
        })
        
        function registerPoint:onEnter()
            lockpickCount = Inventory:GetItemCount("lockpick")
            /*if(not IsRegisterInUse(registerId) and lockpickCount > 0) then
                lib.showTextUI("[E] Vykrást kasu", {
                    position = "left-center"
                })
            end*/
        end

        function registerPoint:onExit()
            CurrentCashRegister = { entity = nil, coords = nil }
            --lib.hideTextUI()
        end

        function registerPoint:nearby()
            if(not CurrentCashRegister.entity) then
                for _,hash in pairs(CashRegistersHashes) do
                    local cashRegisterEntity = GetClosestObjectOfType(registerLocation, 5.0, hash)
                    if(cashRegisterEntity ~= 0) then
                        CurrentCashRegister.entity = cashRegisterEntity
                        CurrentCashRegister.coords = GetEntityCoords(cashRegisterEntity)
                        break
                    end
                end
            end
            if(CurrentCashRegister.entity and lockpickCount > 0) then
                if(not IsRegisterInUse(registerId)) then
                    local markerCoords = vector3(
                        CurrentCashRegister.coords.x, 
                        CurrentCashRegister.coords.y,
                        CurrentCashRegister.coords.z + 0.5
                    )
                    DrawMarker(0, markerCoords, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.1, 255, 0, 0, 255, true)
                    DisplayHelpTextThisFrame("STRIN_ROBBERIES:CASH_REGISTERS:INTERACT")
                    if(IsControlJustReleased(0, 38)) then
                        TriggerServerEvent("strin_robberies:robCashRegister")
                    end
                else          
                    if(lib.isTextUIOpen()) then
                        lib.hideTextUI()
                    end
                end
            end
        end
    end
    /*
        -- Jednou to udělám na všechny modely kas, určo :) *thanks to onesync btw* - strin

        Target:addModel(CashRegistersHashes, {
            label = "Vykrást",
            onSelect = function(data)
                local netId = NetworkGetNetworkIdFromEntity(data.entity)
                local networkedEntity = NetworkGetEntityFromNetworkId(netId)
                print(netId, networkedEntity)
                if(networkedEntity == 0) then
                    NetworkRegisterEntityAsNetworked(data.entity)
                    netId = NetworkGetNetworkIdFromEntity(data.entity)
                    networkedEntity = NetworkGetEntityFromNetworkId(netId)
                    SetNetworkIdCanMigrate(netId, true)
                    SetNetworkIdExistsOnAllMachines(netId, true)
                end
                TriggerServerEvent("strin_robberies:robRegister", netId)
                print(netId, networkedEntity)
                --NetworkRegisterEntityAsNetworked()
            end,
            canInteract = function(entity)
                return not Entity(entity).state.isRobbed
            end
        })
    */
end)

function IsRegisterInUse(registerId)
    local inUse = false
    for k,v in pairs(CashRegistersInUse) do
        if(k == registerId and v) then
            inUse = true
            break
        end
    end
    return inUse
end