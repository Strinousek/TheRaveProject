local WeedPlants = {}

/*
    Weed Plant:
    @property stage number
    @property point CPoint | nil
    @property coords vector3
    @property entity number | nil
*/

lib.callback.register("strin_drugs:shredWeed", function(count)
    return lib.progressBar({
        label = "Drtíte "..count.."x konopných palic",
        duration = 3000 + (math.ceil(1 + count) * 10),
        anim = {
            dict = "missheist_agency3aig_23",
            clip = "urinal_sink_loop"
        }
    })
end)

RegisterNetEvent("strin_drugs:syncWeedPlants", function(weedPlants)
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end

    for k,v in pairs(weedPlants) do
        -- If plant is cached on the client, but is not available on the server
        if((WeedPlants[k] and not v)) then
            -- If player is near and has the entity spawned then delete it
            if(WeedPlants[k].entity) then
                DeleteEntity(WeedPlants[k].entity)
            end

            -- Remove the plant from cache
            WeedPlants[k] = false
        end

        -- If plant is cached on the client and is available on the server aswell
        if(WeedPlants[k] and v) then
            local plant = WeedPlants[k]

            -- If stage differs from client cache and server
            if(plant.stage ~= v.stage) then

                -- Set the cached stage to the server received one
                WeedPlants[k].stage = v.stage

                -- If player is near and has the entity spawned then delete it and spawn a new one
                if(plant.entity) then
                    DeleteEntity(plant.entity)
                    WeedPlants[k].entity = CreatePlantObject(plant.coords, v.stage)
                end
            end

            -- If water status differs from client cache and server
            if(plant.water ~= v.water) then
                -- Set the cached water status to the server received one
                WeedPlants[k].water = v.water
            end

            -- If fertilizer status differs from client cache and server
            if(plant.fertilizer ~= v.fertilizer) then
                -- Set the cached fertilizer status to the server received one
                WeedPlants[k].fertilizer = v.fertilizer
            end
        end

        -- If plant is not cached on the client, but is available on the server
        if(v and not WeedPlants[k]) then
            -- Cache the plant
            WeedPlants[k] = v
        end
    end
end)

RegisterNetEvent("strin_drugs:receiveWeedOffer", function(offer)
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end
        

    local entity = NetworkGetEntityFromNetworkId(offer.pedNetId)
    local releaseEntity = function()
        ClearPedTasks(entity)
        FreezeEntityPosition(entity, false)
    end
    lib.registerContext({
        id = "weed_offer",
        title = "Nabídka",
        onExit = function()
            TriggerServerEvent("strin_drugs:finishWeedOffer", "DECLINE")
            releaseEntity()
        end,
        options = {
            {
                title = ("Přijmout (%sx - %s$)"):format(offer.amount, offer.total),
                icon = "fas fa-dollar-sign",
                iconColor = "#2ecc71",
                onSelect = function()
                    TriggerServerEvent("strin_drugs:finishWeedOffer", "ACCEPT")
                    releaseEntity()
                end,
            },
            {
                title = "Odmítnout",
                icon = "fas fa-times",
                iconColor = "#e74c3c",
                onSelect = function()
                    TriggerServerEvent("strin_drugs:finishWeedOffer", "DECLINE")
                    releaseEntity()
                end,
            },
        }
    })
    lib.showContext("weed_offer")
end)

Citizen.CreateThread(function()
    local weedBudsDrying = false
    local weedBudsReady = false
    Target:addModel(MicrowavesModelHashes, {
        {
            label = "Vysušit palice konopí",
            onSelect = function()
                weedBudsDrying = true
                local input = lib.inputDialog('Množství', {
                    {
                        type = "number",
                    }
                })
 
                if not input then
                    return
                end
                lib.callback("strin_drugs:dryWeedBuds", 500, function(success)
                    if(success) then
                        weedBudsReady = true
                    else
                        weedBudsDrying = false
                    end
                end, input[1])
            end,
            canInteract = function()
                local property, hasKey = exports.esx_property:GetPropertyPlayerIsIn()
                if(not hasKey and property?.Owner:find(ESX.PlayerData.identifier)) then
                    hasKey = true
                end
                return Inventory:GetItemCount("weed_bud", {
                    state = "fresh"
                }) > 0 and property and hasKey and not weedBudsReady and not weedBudsDrying
            end,
        },
        {
            label = "Vytáhnout vysušené palice konopí",
            onSelect = function()
                TriggerServerEvent("strin_drugs:retrieveDriedWeedBuds")
                weedBudsReady = false
                weedBudsDrying = false
            end,
            canInteract = function()
                local property, hasKey = exports.esx_property:GetPropertyPlayerIsIn()
                if(not hasKey and property?.Owner:find(ESX.PlayerData.identifier)) then
                    hasKey = true
                end
                return property and hasKey and weedBudsReady
            end,
        }
    })
    Target:addGlobalPed({
        {
            label = "Nabídnout joint",
            onSelect = function(data)
                local ped = PlayerPedId()
                TaskStandStill(data.entity, 1.0)
                FreezeEntityPosition(data.entity, true)
                SetEntityHeading(data.entity, GetEntityHeading(ped) + 180.0)
                local netId = NetworkGetNetworkIdFromEntity(data.entity)
                local input = lib.inputDialog('Množství', {
                    {
                        type = "number",
                    }
                })
 
                if not input then
                    ClearPedTasks(data.entity)
                    FreezeEntityPosition(data.entity, false)
                    return
                end
                TriggerServerEvent("strin_drugs:requestWeedOffer", netId, input[1])
            end,
            canInteract = function(entity)
                local jointCount = Inventory:GetItemCount("joint")
                return not Entity(entity).state.recentlyOffered and not IsEntityDead(entity) and jointCount > 0 and NetworkGetEntityOwner(entity) ~= -1
            end,
        }
    })
    while true do
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        for k,v in pairs(WeedPlants) do
            if(v) then
                local distance = #(coords - v.coords)
                if(distance < 20) then
                    if(not WeedPlants[k].entity) then
                        WeedPlants[k].entity = CreatePlantObject(v.coords, v.stage)
                        Target:addLocalEntity(WeedPlants[k].entity, {
                            {
                                label = "Rostlina",
                                onSelect = function()
                                    OpenWeedPlantMenu(k)
                                end,
                            }
                        })
                    end
                elseif(distance > 20) then
                    if(v.entity) then
                        DeleteEntity(v.entity)
                        Target:removeLocalEntity(WeedPlants[k].entity)
                        WeedPlants[k].entity = nil
                    end
                end
            end
        end
        Citizen.Wait(1000)
    end
end)

function OpenWeedPlantMenu(plantId)
    local plantData = WeedPlants[plantId]
    lib.registerContext({
        id = "weed_plant",
        title = "Rostlina - Konopí",
        options = {
            {
                title = "Stav - Hydratace",
                progress = plantData.water,
                colorScheme = "indigo",
                icon = "fas fa-tint",
                iconColor = "#748FFC",
                onSelect = function()
                    TriggerServerEvent("strin_drugs:refreshWeedPlant", plantId, "WATER")
                end,
            },
            {
                title = "Stav - Hnojení",
                progress = plantData.fertilizer,
                colorScheme = "orange",
                icon = "fas fa-leaf",
                iconColor = "#E67700",
                onSelect = function()
                    TriggerServerEvent("strin_drugs:refreshWeedPlant", plantId, "FERTILIZER")
                end,
            },
            {
                title = "Stav - Růst",
                progress = (100 / 3) * plantData.stage,
                colorScheme = "lime",
                icon = "fas fa-cannabis",
                iconColor = "#82C91E",
                onSelect = function()
                    if(plantData.stage == 3) then
                        TriggerServerEvent("strin_drugs:harvestWeedPlant", plantId)
                    end
                end,
                metadata = {
                    { label = "Fáze", value = plantData.stage },
                    { label = "Sklizitelné", value = plantData.stage == 3 and "Ano" or "Ne"}
                }
            },
            {
                title = "Zapálit",
                icon = "fab fa-gripfire",
                iconColor = "#e74c3c",
                onSelect = function()
                    TriggerServerEvent("strin_drugs:burnWeedPlant", plantId)
                end,
            },
        }
    })
    lib.showContext("weed_plant")
end

lib.callback.register("strin_drugs:getGroundMaterial", function()
    if(lib.progressBar({
        duration = 1000,
        label = "Kontroluji půdu...",
        anim = {
            dict = "random@domestic",
            clip = "pickup_low"
        }
    })) then
        return GetGroundMaterial()
    else
        return nil
    end
end)

function CreatePlantObject(coords, stage)
    local modelHash = WeedModelHashes[stage]
    if IsModelInCdimage(modelHash) then
        RequestModel(modelHash)
    
        while not HasModelLoaded(modelHash) do
            Citizen.Wait(0)
        end

        local plantObject = CreateObject(modelHash, coords.x, coords.y, coords.z, false, false, false)
    
        if not DoesEntityExist(plantObject) then
            return nil
        end
    
        SetEntityAsMissionEntity(plantObject, true, true)
        FreezeEntityPosition(entity, true)
        return plantObject
    end
end

function GetGroundMaterial()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local num = StartShapeTestCapsule(coords.x, coords.y, coords.z + 4, coords.x, coords.y, coords.z - 2.0, 1, 1, ped, 7)
    local _, _, _, _, material = GetShapeTestResultEx(num)
    return tonumber(material)
end

AddEventHandler("onResourceStop", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        for k,v in pairs(WeedPlants) do
            if(v and v.entity) then
                if(DoesEntityExist(v.entity)) then
                    DeleteEntity(v.entity)
                end
            end
        end
    end
end)