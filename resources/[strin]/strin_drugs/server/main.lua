SpawnedDehydrators = {}

local IsDebugModeOn = false
local DefaultConfigFile = LoadResourceFile(GetCurrentResourceName(), "config.lua")

AddEventHandler("strin_base:debugStateChange", function(state, onChange)
    IsDebugModeOn = state
    if(not state) then
        load(DefaultConfigFile)()
    else
        WeedPlantStageTimers = {
            [1] = 0,
            [2] = 0.001,
            [3] = 0.001
        }

        WeedBudHarvestAmount = { 20, 60 }
    end
    onChange()
end)


-- Mild alcohol
Base:RegisterItemListener({ "vine", "gin" }, function (item, inventory)
    local _source = inventory.id
    TriggerClientEvent("strin_drugs:useAlcohol", _source, 25)
    return true
end, {
    event = "usedItem"
})

-- Strong ass alcohol
Base:RegisterItemListener({ "averagewhisky", "goodwhisky", "awesomewhisky", "jager", "vodka" }, function (item, inventory)
    local _source = inventory.id
    TriggerClientEvent("strin_drugs:useAlcohol", _source, 50)
    return true
end, {
    event = "usedItem"
})

Base:RegisterItemListener("dehydrator", function(item, inventory, slot, data)
    local _source = inventory.id
    local ped = GetPlayerPed(_source)
    local heading = GetEntityHeading(ped)
    local coords = GetEntityCoords(ped)

    local headingRadius = math.rad(heading + 90.0)
    local dehydratorOffset = vector3(math.cos(headingRadius), math.sin(headingRadius), -1.0)

    local dehydratorCoords = (coords + dehydratorOffset)
    local dehydrator = CreateObjectNoOffset(DehydratorModelHash, dehydratorCoords, true, true)
    FreezeEntityPosition(dehydrator, true)
    table.insert(SpawnedDehydrators, {
        netId = NetworkGetNetworkIdFromEntity(dehydrator),
        coords = dehydratorCoords,
        spawnerId = _source,
        durability = 100.0,
        spawnedOn = os.time(),
    })
    Entity(dehydrator).state.durability = 100.0
end, {
    event = "usedItem"
})

function GetNearestDehydrator(playerId)
    local isNear, dehydratorIndex = false
    local nearestDehydratorDistance = 15000.0
    local ped = GetPlayerPed(playerId)
    local coords = GetEntityCoords(ped)
    for i=1, #SpawnedDehydrators do
        if(SpawnedDehydrators[i]) then
            local distance = #(coords - SpawnedDehydrators[i].coords)
            if(distance < nearestDehydratorDistance) then
                nearestDehydratorDistance = distance
                dehydratorIndex = i
            end
        end
    end
    if(nearestDehydratorDistance < 10.0) then
        isNear = true
    end
    return isNear, dehydratorIndex
end

AddEventHandler("entityRemoved", function(entity)
    if(GetEntityType(entity) ~= 3) then
        return
    end

    if(GetEntityModel(entity) ~= DehydratorModelHash) then
        return
    end

    local netId = NetworkGetNetworkIdFromEntity(entity)
    for i=1, #SpawnedDehydrators do
        if(SpawnedDehydrators[i]?.netId == netId) then
            SpawnedDehydrators[i] = false
            break
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        for i=1, #SpawnedDehydrators do
            if(SpawnedDehydrators[i]) then
                if(os.time() - SpawnedDehydrators[i].spawnedOn > (30 * 60)) then
                    local entity = NetworkGetEntityFromNetworkId(SpawnedDehydrators[i].netId)
                    DeleteEntity(entity)
                end
            end
        end
        Citizen.Wait(60000)
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        for i=1, #SpawnedDehydrators do
            if(SpawnedDehydrators[i]) then
                local entity = NetworkGetEntityFromNetworkId(SpawnedDehydrators[i].netId)
                DeleteEntity(entity)
            end
        end
    end
end)