local SpawnedSyntheticPickupables = {}
local HarvestablesTimers = {}
local ChemicalsTimers = {}
local Items = Inventory:Items()

RegisterNetEvent("strin_drugs:requestSyncSyntheticPickupables", function()
    local _source = source
    TriggerClientEvent("strin_drugs:syncSyntheticPickupables", _source, SpawnedSyntheticPickupables)
end)

RegisterNetEvent("strin_drugs:pickupSyntheticPickupable", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    local nearestPickupable = GetNearestPickupable(_source)
    if(nearestPickupable.distance > 5) then
        return
    end
    local pickupableData = SyntheticDrugs[nearestPickupable.drug][nearestPickupable._type]
    local count = pickupableData.itemCount or 1
    local spot = SpawnedSyntheticPickupables[nearestPickupable.drug][nearestPickupable._type][nearestPickupable.locationIndex][nearestPickupable.spotIndex]
    if(not Inventory:CanCarryItem(_source, spot.item, count)) then
        xPlayer.showNotification("Tento předmět je na Vás už moc těžký.", { type = "error" })
        return
    end

    Inventory:AddItem(_source, spot.item, count)
    --TriggerClientEvent("esx:showNotification", _source, spot.item.." x"..count)
    SpawnedSyntheticPickupables[nearestPickupable.drug][nearestPickupable._type][nearestPickupable.locationIndex][nearestPickupable.spotIndex] = false
    TriggerClientEvent("strin_drugs:syncSyntheticPickupables", -1, SpawnedSyntheticPickupables)
end)


local PickupablesCounterParts = {}

do
    for drug, data in each(SyntheticDrugs) do
        for requiredItem, _ in each(data.recipe.requiredItems) do
            Base:RegisterItemListener(requiredItem, function(__, inventory, slot)
                local _source = inventory.id
                local xPlayer = ESX.GetPlayerFromId(_source)
                if(not xPlayer) then
                    return false
                end
                local itemCounts = lib.table.deepclone(data.recipe.requiredItems)
                local doesntHaveEnoughItems = false
                for item, ___ in each(itemCounts) do
                    itemCounts[item] = itemCounts[item] - Inventory:GetItemCount(_source, item)
                    if(itemCounts[item] > 0) then
                        doesntHaveEnoughItems = true
                        break
                    end 
                end
                if(doesntHaveEnoughItems) then
                    xPlayer.showNotification("Nemáte dostatek látek na zpracování syntetické drogy!", { type = "error" })
                    return false
                end
                for item, count in each(data.recipe.requiredItems) do
                    Inventory:RemoveItem(_source, item, count)
                end
                math.randomseed(GetGameTimer() + math.random(10000, 99999))
                Inventory:AddItem(_source, data.recipe.item, type(data.recipe.count) == "table" and math.random(table.unpack(data.recipe.count)) or tonumber(data.recipe.count))
            end, {
                event = "usingItem"
            })
        end
        Base:RegisterItemListener(data.recipe.item, function(_, inventory)
            local _source = inventory.id
            local xPlayer = ESX.GetPlayerFromId(_source)
            if(not xPlayer) then
                return false
            end
            if(not Inventory:RemoveItem(_source, data.recipe.item, 1)) then
                return false
            end
            Inventory:AddItem(_source, drug.."_brick", math.random(6,8))
        end, {
            event = "usingItem"
        })
        Base:RegisterItemListener(drug.."_brick", function(_, inventory)
            local _source = inventory.id
            local xPlayer = ESX.GetPlayerFromId(_source)
            if(not xPlayer) then
                return false
            end
            local poochCount = Inventory:GetItemCount(_source, "pooch")
            if(poochCount < 20) then
                xPlayer.showNotification("Nemáte u sebe dostatek sáčků! (20)", { type = "error" })
                return false
            end
            if(not Inventory:RemoveItem(_source, "pooch", 20)) then
                return false
            end
            if(not Inventory:RemoveItem(_source, drug.."_brick", 1)) then
                return false
            end
            Inventory:AddItem(_source, drug.."_pooch", 20)
        end, {
            event = "usingItem"
        })
    end
end

function GetNearestPickupable(playerId)
    local ped = GetPlayerPed(playerId)
    local coords = GetEntityCoords(ped)
    local nearestPickupable = {
        _type = nil,
        drug = nil,
        distance = 15000.0,
        locationIndex = nil,
        spotIndex = nil,
    }
    for k,v in pairs(SpawnedSyntheticPickupables) do
        for i=1, #v.harvestables do
            local location = v.harvestables[i]
            for j=1, #location do
                local spot = location[j]
                if(spot) then
                    local distance = #(coords - spot.coords)
                    if(distance < nearestPickupable.distance) then
                        nearestPickupable._type = "harvestables"
                        nearestPickupable.drug = k
                        nearestPickupable.distance = distance
                        nearestPickupable.locationIndex = i
                        nearestPickupable.spotIndex = j
                    end
                end
            end
        end
        for i=1, #v.chemicals do
            local location = v.chemicals[i]
            for j=1, #location do
                local spot = location[j]
                if(spot) then
                    local distance = #(coords - spot.coords)
                    if(distance < nearestPickupable.distance) then
                        nearestPickupable._type = "chemicals"
                        nearestPickupable.drug = k
                        nearestPickupable.distance = distance
                        nearestPickupable.locationIndex = i
                        nearestPickupable.spotIndex = j
                    end
                end
            end
        end
    end
    return nearestPickupable
end

AddEventHandler("esx:playerLoaded", function (playerId)
    TriggerClientEvent("strin_drugs:syncSyntheticPickupables", playerId, SpawnedSyntheticPickupables)
end)

---@param locationType "harvestables" | "chemicals"
---@param drugType string
function SetupPickupablesLocations(locationType, drugType)
    local v = SyntheticDrugs[drugType][locationType]
    for i=1, #v.locations do
        local location = v.locations[i]
        SpawnedSyntheticPickupables[drugType][locationType][i] = {}
        for j=1, location.count do
            math.randomseed(GetGameTimer() + math.random(1, 99999))
            table.insert(SpawnedSyntheticPickupables[drugType][locationType][i], {
                coords = vector3(location.coords.x + math.random(1, location.radius), location.coords.y + (math.random(1, location.radius)), location.coords.z),
                item = location.item or v.item,
            })
            if(locationType == "harvestables") then
                HarvestablesTimers[drugType] = GetGameTimer()
            else
                ChemicalsTimers[drugType] = GetGameTimer()
            end
        end
    end
end

---@param locationType "harvestables" | "chemicals"
---@param drugType string
function RespawnPickupable(locationType, drugType)
    local v = SyntheticDrugs[drugType][locationType]
    for i=1, #SpawnedSyntheticPickupables[drugType][locationType] do
        local pickupables = SpawnedSyntheticPickupables[drugType][locationType][i]
        for j=1, #pickupables do
            local pickupable = pickupables[i]
            if(not pickupable) then
                if(((GetGameTimer() - HarvestablesTimers[drugType]) >= v.respawnTimer)) then
                    local location = v.locations[i]
                    SpawnedSyntheticPickupables[drugType][locationType][i][j] = {
                        coords = vector3(location.coords.x + math.random(1, location.radius), location.coords.y + (math.random(1, location.radius)), location.coords.z),
                        item = location.item or v.item
                    }
                    if(locationType == "harvestables") then
                        HarvestablesTimers[drugType] = GetGameTimer()
                    else
                        ChemicalsTimers[drugType] = GetGameTimer()
                    end
                end
            end
        end
    end
end

Citizen.CreateThread(function()
    while true do
        local respawn = false
        for k,_ in pairs(SyntheticDrugs) do
            if(not SpawnedSyntheticPickupables[k]) then
                SpawnedSyntheticPickupables[k] = {
                    harvestables = {},
                    chemicals = {}
                }
                SetupPickupablesLocations("harvestables", k)
                SetupPickupablesLocations("chemicals", k)
                respawn = true
            end
            if(RespawnPickupable("harvestables", k)) then
                respawn = true
            end
            if(RespawnPickupable("chemicals", k)) then
                respawn = true
            end
        end
        
        if(respawn) then
            TriggerClientEvent("strin_drugs:syncSyntheticPickupables", -1, SpawnedSyntheticPickupables)
        end
        Citizen.Wait(3000)
    end
end)