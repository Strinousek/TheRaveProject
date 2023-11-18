local SpawnedSyntheticPickupables = {}
local Items = Inventory:Items()

Citizen.CreateThread(function ()
    Citizen.Wait(7500)
    if(not next(SpawnedSyntheticPickupables)) then
        TriggerServerEvent("strin_drugs:requestSyncSyntheticPickupables")
    end
end)

RegisterNetEvent("strin_drugs:syncSyntheticPickupables", function(syntheticPickupables)
    if(next(SpawnedSyntheticPickupables)) then
        for drug,v in pairs(SpawnedSyntheticPickupables) do
            for i=1, #v.harvestables do
                local location = v.harvestables[i]
                for j=1, #location do
                    local spot = location[j]
                    if(spot) then
                        if(spot.point) then
                            spot.point:remove()
                        end
                        if(spot.entity) then
                            DeleteEntity(spot.entity)
                        end
                    end
                end
            end
            for i=1, #v.chemicals do
                local location = v.chemicals[i]
                for j=1, #location do
                    local spot = location[j]
                    if(spot) then
                        if(spot.point) then
                            spot.point:remove()
                        end
                        if(spot.entity) then
                            DeleteEntity(spot.entity)
                        end
                    end
                end
            end
        end
    end
    SpawnedSyntheticPickupables = syntheticPickupables
    for k,v in pairs(SpawnedSyntheticPickupables) do
        for i=1, #v.harvestables do
            local location = v.harvestables[i]
            for j=1, #location do
                local pickupable = location[j]
                if(pickupable) then
                    pickupable.point = lib.points.new({
                        coords = pickupable.coords,
                        distance = 40,
                    })
                    pickupable.entity = nil
                    local point = pickupable.point
                    function point:onEnter()
                        local model = `prop_barrel_exp_01b`
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
    --print(ESX.DumpTable(SpawnedSyntheticPickupables))
end)

AddEventHandler("onResourceStop", function(resource)
    if(GetCurrentResourceName() == resource) then
        for k,v in pairs(SpawnedSyntheticPickupables) do
            for i=1, #v.harvestables do
                for j=1, #v.harvestables[i] do
                    local pickupable = v.harvestables[i][j]
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
            for i=1, #v.chemicals do
                for j=1, #v.chemicals[i] do
                    local pickupable = v.chemicals[i][j]
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
    end
end)