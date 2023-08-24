RegisterNetEvent("strin_drugs:takeLSD", function()      
    RequestAnimDict("mp_suicide")
    while not HasAnimDictLoaded("mp_suicide") do
        Citizen.Wait(0)
    end
    TaskPlayAnim(cache.ped, "mp_suicide", "pill_fp", 8.0, 1.0, 3000, 1, 2, false, false, false)
    Citizen.Wait(3000)
    ESX.ShowNotification("WOOHOO! A JEDEME DO PÍČI!")
    ClearPedTasksImmediately(cache.ped)
    SetTimecycleModifier("drug_drive_blend01")
    ShakeGameplayCam("DRUNK_SHAKE", 0.1)
    SetRunSprintMultiplierForPlayer(cache.playerId, 1.2) 
    local startingStrength = DrugEffectStrength
    while DrugEffectStrength < (startingStrength + 0.5) do
        DrugEffectStrength += 0.001
        SetTimecycleModifierStrength(DrugEffectStrength)
        Citizen.Wait(50)
    end
    
    Citizen.Wait(45000)
    SetPedMoveRateOverride(playerId, 1.0)
    SetRunSprintMultiplierForPlayer(cache.playerId, 1.0)

    while DrugEffectStrength > 0 do
        DrugEffectStrength -= 0.001
        SetTimecycleModifierStrength(DrugEffectStrength)
        Citizen.Wait(0)
    end
    DrugEffectStrength = 0.0
    ShakeGameplayCam("DRUNK_SHAKE", 0.0)
    ClearTimecycleModifier()
end)

lib.callback.register("strin_drugs:checkForLSDSellers", function()
    if(not IsInGangArea()) then
        return false
    end
    local peds = lib.getNearbyPeds(GetEntityCoords(cache.ped), 10.0)
    if(#peds == 0) then
        return false
    end
    local foundGangster = false
    for i=1, #peds do
        if(IsModelGangster(GetEntityArchetypeName(peds[i].ped))) then
            foundGangster = true
            break
        end
    end

    return foundGangster
end)

Target:addGlobalPed({
    {
        label = "Zeptat se na LSD ("..LSDPrice.."$)",
        icon = "fa-solid fa-pills",
        onSelect = function()
            TriggerServerEvent("strin_drugs:requestLSD")
        end,
        canInteract = function(entity)
            return not lib.table.contains(LawEnforcementJobs, ESX?.PlayerData?.job?.name) and IsInGangArea() and IsModelGangster(GetEntityArchetypeName(entity))
        end,
    }
})