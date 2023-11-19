SpawnedDehydrators = {}

local IsDebugModeOn = false
local DefaultConfigFile = LoadResourceFile(GetCurrentResourceName(), "config.lua")
local Items = Inventory:Items()

Base:RegisterWebhook("DRUG_SELL", "https://discord.com/api/webhooks/1136083529822900325/O1V0ZzMCLppPY9rFsV6j9qRqES1q8TasaoKjh5SJZxFrwhnUHY6EuxQ_0vtCY8xlfYKd")

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

        for _, data in each(SyntheticDrugs) do
            data.chemicals.respawnTimer = 5000
            data.harvestables.respawnTimer = 5000
        end
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

local DrugOffers = {}

RegisterNetEvent("strin_drugs:requestDrugOffer", function(pedNetId, drug, amount)
    if(type(pedNetId) ~= "number" or type(amount) ~= "number" or amount <= 0 or type(drug) ~= "string" or (drug ~= "joint" and not SyntheticDrugs[drug:gsub("_pooch", "")]) or not Items[drug]) then
        return
    end

    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    local pedEntity = NetworkGetEntityFromNetworkId(pedNetId)
    if(not DoesEntityExist(pedEntity)) then
        xPlayer.showNotification("Daný civilista neexistuje!", { type = "error" })
        return
    end
    
    if(Entity(pedEntity).state.recentlyOffered) then
        xPlayer.showNotification("Tento civilista již nedávno nabídku dostal!", { type = "error" })
        return
    end

    if(not DrugPrices[drug]) then
        xPlayer.showNotification("Tuhle drogu civilista nekupuje!", { type = "error" })
        return
    end

    local drugCount = Inventory:GetItemCount(_source, drug)
    if((drugCount - amount) < 0) then
        xPlayer.showNotification("Nemáte u sebe dané množství dané substance!", { type = "error" })
        return
    end

    math.randomseed(GetGameTimer() + math.random(10000, 99999))
    local declineChance = math.random(1, 100)
    if(declineChance > 60) then -- 60
        DrugOffers[xPlayer.identifier] = nil
        Entity(pedEntity).state.recentlyOffered = true
        ClearPedTasks(pedEntity)
        FreezeEntityPosition(pedEntity, false)
        xPlayer.showNotification("Civilista nemá zájem.", { type = "error" })
        math.randomseed(GetGameTimer() + math.random(10000, 99999))
        local callCopsChance = math.random(1, 100)
        if(callCopsChance > 50) then -- 50
            local recipientJobList = LawEnforcementJobs
            local data = {
                displayCode = '10-14',
                blipSprite = 469,
                description = "Nelegální činnost",
                isImportant = 0,
                recipientList = recipientJobList, 
                length = '15000',
                infoM = 'fa-tablets',
                info = "Prodej drog"
            }
            local dispatchData = { dispatchData = data, caller = 'Civilista', coords = GetEntityCoords(pedEntity)}
            TriggerEvent('wf-alerts:svNotify', dispatchData)
        end
        return
    end

    math.randomseed(GetGameTimer() + math.random(10000, 99999))
    local total = 0
    for i=1, amount do
        total += math.random(type(DrugPrices[drug]) == "table" and table.unpack(DrugPrices[drug]) or DrugPrices[drug])
    end
    DrugOffers[xPlayer.identifier] = {
        total = total,
        drug = drug,
        amount = amount,
        pedNetId = pedNetId
    }
    TriggerClientEvent("strin_drugs:receiveDrugOffer", _source, DrugOffers[xPlayer.identifier])
end)

RegisterNetEvent("strin_drugs:finishDrugOffer", function(finishMethod)
    if(type(finishMethod) ~= "string" or (finishMethod ~= "ACCEPT" and finishMethod ~= "DECLINE")) then
        return
    end
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    local offer = DrugOffers[xPlayer.identifier]
    if(not offer) then
        xPlayer.showNotification("Daná nabídka neexistuje!", { type = "error" })
        return
    end

    local pedEntity = NetworkGetEntityFromNetworkId(offer.pedNetId)
    if(not DoesEntityExist(pedEntity)) then
        WeedOffers[xPlayer.identifier] = nil
        xPlayer.showNotification("Daný civilista neexistuje!", { type = "error" })
        return
    end

    local drugCount = Inventory:GetItemCount(_source, offer.drug)
    if((drugCount - offer.amount) < 0) then
        DrugOffers[xPlayer.identifier] = nil
        xPlayer.showNotification("Nemáte u sebe tolik jointů!", { type = "error" })
        return
    end

    Entity(pedEntity).state.recentlyOffered = true
    
    if(finishMethod == "ACCEPT") then
        Inventory:RemoveItem(_source, offer.drug, offer.amount)
        xPlayer.addMoney(offer.total)
        Base:DiscordLog("DRUG_SELL", "THE RAVE PROJECT - DRUG SELL", {
            { name = "Jméno hráče", value = ESX.SanitizeString(GetPlayerName(_source)) },
            { name = "Identifikace hráče", value = xPlayer.identifier },
            { name = "Množství drogy", value = drugCount },
            { name = "Droga", value = offer.drug },
            { name = "Částka", value = ESX.Math.GroupDigits(offer.total).."$" },
        }, {
            fields = true,
        })
        return
    end
    
    DrugOffers[xPlayer.identifier] = nil
end)

AddEventHandler("playerDropped", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end
    if(DrugOffers[xPlayer.identifier]) then
        DrugOffers[xPlayer.identifier] = nil
    end
end)

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