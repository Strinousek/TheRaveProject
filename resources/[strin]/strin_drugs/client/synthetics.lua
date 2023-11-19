local SpawnedSyntheticPickupables = {}
local Items = Inventory:Items()

Citizen.CreateThread(function ()
    Citizen.Wait(7500)
    if(not next(SpawnedSyntheticPickupables)) then
        TriggerServerEvent("strin_drugs:requestSyncSyntheticPickupables")
    end
end)

RegisterNetEvent("strin_drugs:useSyntheticDrug", function(drug, strength)      
    TaskStartScenarioInPlace(cache.ped, "WORLD_HUMAN_SMOKING_POT", 0, 1)
    Citizen.Wait(3000)
    ESX.ShowNotification("Tohle je jinej dělobuch!")
    ClearPedTasksImmediately(cache.ped)
    SetTimecycleModifier("drug_drive_blend01")
    ShakeGameplayCam("DRUNK_SHAKE", 0.1)
    if(drug:find("coke")) then
        SetPlayerMeleeWeaponDamageModifier(cache.playerId, 1.1)
        SetRunSprintMultiplierForPlayer(cache.playerId, 1.1) 
    end
    local startingStrength = DrugEffectStrength
    while DrugEffectStrength < (startingStrength + (strength / 100)) do
        DrugEffectStrength += 0.001
        SetTimecycleModifierStrength(DrugEffectStrength)
        Citizen.Wait(0)
    end
    
    Citizen.Wait(45000)
    SetPedMoveRateOverride(playerId, 1.0)
    if(drug:find("coke")) then
        SetRunSprintMultiplierForPlayer(cache.playerId, 1.0)
        SetPlayerMeleeWeaponDamageModifier(cache.playerId, 1.0)
    end

    while DrugEffectStrength > 0 do
        DrugEffectStrength -= 0.001
        SetTimecycleModifierStrength(DrugEffectStrength)
        Citizen.Wait(0)
    end
    DrugEffectStrength = 0.0
    ShakeGameplayCam("DRUNK_SHAKE", 0.0)
    ClearTimecycleModifier()
end)

function DeleteOrUpdatePickupables(_type, drug, v, syntheticPickupables)
    for i=1, #v[_type] do
        local location = v[_type][i]
        for j=1, #location do
            local spot = location[j]
            local receivedSpot = syntheticPickupables[drug][_type][i][j]
            if(spot and not receivedSpot) then
                if(spot.point) then
                    spot.point:remove()
                end
                if(spot.entity) then
                    DeleteEntity(spot.entity)
                end
            elseif(spot and receivedSpot) then
                if(spot.point) then
                    receivedSpot.point = spot.point
                end
                if(spot.entity) then
                    receivedSpot.entity = spot.entity
                end
            end
        end
    end
end

function SpawnPickupables(_type, v)
    for i=1, #v[_type] do
        local location = v[_type][i]
        for j=1, #location do
            local pickupable = location[j]
            if(pickupable and (not pickupable.point or not pickupable.entity)) then
                pickupable.point = lib.points.new({
                    coords = pickupable.coords,
                    distance = 40,
                })
                pickupable.entity = nil
                local point = pickupable.point
                function point:onEnter()
                    local model = pickupable.item:find("leaves") and `prop_plant_01a` or `prop_barrel_exp_01b`
                    RequestModel(model)
                    while not HasModelLoaded(model) do
                        Citizen.Wait(0)
                    end
                    local _, groundZ = GetGroundZFor_3dCoord(pickupable.coords.x, pickupable.coords.y, pickupable.coords.z, 0)
                    pickupable.entity = CreateObject(model, pickupable.coords.x, pickupable.coords.y, groundZ, false, false, false)
                    FreezeEntityPosition(pickupable.entity, true)
                    Target:addLocalEntity(pickupable.entity, {
                        {
                            label = "Vzít "..Items[pickupable.item].label,
                            icon = "fa-solid fa-hand",
                            onSelect = function()
                                TriggerServerEvent("strin_drugs:pickupSyntheticPickupable")
                            end,
                        }
                    })
                end

                function point:onExit()
                    if(pickupable.entity) then
                        DeleteEntity(pickupable.entity)
                        pickupable.entity = nil
                    end
                end
            end
        end
    end
end

RegisterNetEvent("strin_drugs:syncSyntheticPickupables", function(syntheticPickupables)
    if(next(SpawnedSyntheticPickupables)) then
        for drug,v in pairs(SpawnedSyntheticPickupables) do
            DeleteOrUpdatePickupables("harvestables", drug, v, syntheticPickupables)
            DeleteOrUpdatePickupables("chemicals", drug, v, syntheticPickupables)
        end
    end
    SpawnedSyntheticPickupables = syntheticPickupables
    for k,v in pairs(SpawnedSyntheticPickupables) do
        SpawnPickupables("harvestables", v)
        SpawnPickupables("chemicals", v)
    end
end)

function DeletePickupables(_type, v)
    for i=1, #v[_type] do
        for j=1, #v[_type][i] do
            local pickupable = v[_type][i][j]
            if(pickupable) then
                if(pickupable.point) then
                    pickupable.point:remove()
                end
                if(pickupable.entity) then
                    DeleteEntity(pickupable.entity)
                end
            end
        end
    end
end

AddEventHandler("onResourceStop", function(resource)
    if(GetCurrentResourceName() == resource) then
        for k,v in pairs(SpawnedSyntheticPickupables) do
            DeletePickupables("harvestables", v)
            DeletePickupables("chemicals", v)
        end
    end
end)