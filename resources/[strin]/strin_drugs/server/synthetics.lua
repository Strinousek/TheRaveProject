local SpawnedSyntheticPickupables = {}
local HarvestablesTimers = {}
local ChemicalsTimers = {}

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
    if(nearestPickupable._type == "harvestables") then
        if(GetGameTimer() - HarvestablesTimers[nearestPickupable.drug] > SyntheticDrugs[nearestPickupable.drug][nearestPickupable._type].respawnTimer) then
            HarvestablesTimers[nearestPickupable.drug] = GetGameTimer()
        end
    else
        if(GetGameTimer() - HarvestablesTimers[nearestPickupable.drug] > SyntheticDrugs[nearestPickupable.drug][nearestPickupable._type].respawnTimer) then
            ChemicalsTimers[nearestPickupable.drug] = GetGameTimer()
        end
    end
    TriggerClientEvent("strin_drugs:syncSyntheticPickupables", -1, SpawnedSyntheticPickupables)
end)

do
    for drug, data in each(SyntheticDrugs) do
        Base:RegisterItemListener(drug.."_pooch", function(__, inventory)
            local _source = inventory.id
            local xPlayer = ESX.GetPlayerFromId(_source)
            if(not xPlayer) then
                return false
            end
            TriggerClientEvent("strin_drugs:useSyntheticDrug", _source, drug, drug == "coke" and 75 or (drug == "heroin" and 50 or 25))
            return true
        end, {
            event = "usedItem"
        })
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

RegisterNetEvent("esx:playerLoaded", function (playerId)
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
    local locations = SpawnedSyntheticPickupables[drugType][locationType]
    for i=1, #locations do
        local location = locations[i]
        for j=1, #location do
            local spot = location[j]
            if(not spot) then
                local timerTable = locationType == "harvestables" and HarvestablesTimers or ChemicalsTimers
                local defaultLocation = v.locations[i]
                if(((GetGameTimer() - timerTable[drugType]) >= v.respawnTimer)) then
                    locations[i][j] = {
                        coords = vector3(defaultLocation.coords.x + math.random(1, defaultLocation.radius), defaultLocation.coords.y + (math.random(1, defaultLocation.radius)), defaultLocation.coords.z),
                        item = defaultLocation.item or v.item
                    }
                    timerTable[drugType] = GetGameTimer()
                    return true
                end
            end
        end
    end
    return false
end

Citizen.CreateThread(function()
    while true do
        local sync = false
        for k,_ in pairs(SyntheticDrugs) do
            if(not SpawnedSyntheticPickupables[k]) then
                SpawnedSyntheticPickupables[k] = {
                    harvestables = {},
                    chemicals = {}
                }
                SetupPickupablesLocations("harvestables", k)
                SetupPickupablesLocations("chemicals", k)
                sync = true
            end
            if(RespawnPickupable("harvestables", k)) then
                sync = true
            end
            if(RespawnPickupable("chemicals", k)) then
                sync = true
            end
        end
        
        if(sync) then
            TriggerClientEvent("strin_drugs:syncSyntheticPickupables", -1, SpawnedSyntheticPickupables)
        end
        Citizen.Wait(3000)
    end
end)