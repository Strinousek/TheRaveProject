local IsSitting, CurrentSitCoords, CurrentScenario = false, {}, nil
local CurrentSitEntity = nil
local Target = exports.ox_target
local IsPlayingAnSitEmote = false

RegisterCommand('sit', function(source, args)
    local ped = PlayerPedId()
    IsPlayingAnSitEmote = not IsPlayingAnSitEmote
    if IsPlayingAnSitEmote then
        local coords = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)
        TaskStartScenarioAtPosition(ped, 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', coords.x, coords.y, coords.z - 1, heading, 0, 0, false)
    else
        if(IsPedUsingScenario(ped, 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER')) then
            ClearPedTasks(ped)
        end
    end
end)

Citizen.CreateThread(function()
    AddTextEntry("STRIN_BASE:SITUP", "<FONT FACE='Righteous'>~g~<b>[E]</b>~s~ Vstát</FONT>")
    for chairModel, v in pairs(InteractableChairs) do
        local modelHash = GetHashKey(chairModel)
        Target:addModel(modelHash, {
            {
                label = "Sednout si",
                icon = "fa-solid fa-chair",
                distance = 1.5,
                onSelect = function(data)
                    local entity = data.entity
                    local distance = data.distance
                    if(distance < 1.5) then
                        SitOnChair(entity, v)
                    end
                end,
                canInteract = function()
                    return not IsSitting and not IsPlayingAnEmote and not IsEntityDead(PlayerPedId())
                end,
            }
        })
    end
end)

function SitOnChair(entity, data)
    
	CurrentSitEntity = entity
	FreezeEntityPosition(CurrentSitEntity, true)
    
	PlaceObjectOnGroundProperly(CurrentSitEntity)
	local currentSitCoords = GetEntityCoords(CurrentSitEntity)

    local chair = lib.callback.await("strin_base:getChair", 500, currentSitCoords)
    if(chair) then
        ESX.ShowNotification("Na této židli už někdo sedí!", { type = "error" })
        return
    end

    lib.callback("strin_base:sitOnChair", 500, function(success)
        if(success) then
            IsSitting = true
            local ped = PlayerPedId()
            CurrentSitCoords = currentSitCoords
            CurrentScenario = data.scenario
            local function StartScenario()
                local coords = GetEntityCoords(ped)
                -- + (playerPos.z - pos.z)/2 
                TaskStartScenarioAtPosition(
                    ped,
                    CurrentScenario,
                    currentSitCoords.x,
                    currentSitCoords.y,
                    currentSitCoords.z + (coords.z - currentSitCoords.z)/2,
                    GetEntityHeading(CurrentSitEntity) + 180.0,
                    0,
                    true,
                    false
                )
            end
            StartScenario()
        
            Citizen.Wait(2500)
            if GetEntitySpeed(ped) > 0 then
                ClearPedTasks(ped)
                StartScenario()
            end

            while IsPedUsingScenario(ped, CurrentScenario) do
                DisplayHelpTextThisFrame("STRIN_BASE:SITUP")
                if(IsControlJustReleased(0, 38)) then
                    LeaveChair()
                    break
                end
                Citizen.Wait(0)
            end
        end
    end, currentSitCoords)
end

AddEventHandler("esx:onPlayerDeath", function()
    if(IsSitting) then
        LeaveChair()
    end
    if(IsPlayingAnSitEmote) then
        IsPlayingAnSitEmote = false 
    end
end)

function LeaveChair()
    local ped = PlayerPedId()
    FreezeEntityPosition(CurrentSitEntity, false)
    TriggerServerEvent("strin_base:leaveChair")
    CurrentSitCoords, CurrentScenario = nil, nil
    ClearPedTasks(ped)
    IsSitting = false
end

AddEventHandler("strin_base:cancelledAnimation", function()
    if(IsSitting) then
	    LeaveChair()
    end
    if(IsPlayingAnSitEmote) then
        IsPlayingAnSitEmote = false
    end
end)