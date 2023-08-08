local WeedPlants = {}
local WeedIndex = 1
local LoadedPlantsFromDatabase = false
local WeedPlantCheckInterval = SetInterval(function()
    local currentTime = os.time()
    local changed = false
    for k,v in pairs(WeedPlants) do
        if(v) then
            if(v.stage < 3) then
                local deleted = false
                WeedPlants[k].fertilizer -= 1 -- -180 after 90 minutes - 2 fertilizers needed per plant?
                WeedPlants[k].water -= 2 -- -360 after 90 minutes - 4 waters needed per plant?
                if(WeedPlants[k].fertilizer <= 0 or WeedPlants[k].water <= 0) then
                    deleted = true
                    DeletePlant(k, v.id)
                end
                if(not deleted) then
                    local elapsedMinutes = math.floor((currentTime - v.plantedOn) / 60)
                    local nextStageTimer = CalculateNextStageTimer(v.stage + 1)
                    if(elapsedMinutes >= nextStageTimer) then
                        UpdateWeedPlantStage(k, v.id, v.stage + 1)
                    end
                end
                changed = true
            end
        end
    end
    if(changed) then
        SyncWeedPlants()
    end
end, 30000)


local Base = exports.strin_base
Base:RegisterWebhook("WEED_PLANT", "https://discord.com/api/webhooks/885287209916334100/duF25VkXgjFKz94RrDXch8s7B9tTNy0R-1MyH-Lw58-QdJ7kufhxh2gBfMap39nWxDPk")
Base:RegisterWebhook("WEED_HARVEST", "https://discord.com/api/webhooks/1136083276822499428/bgsYFZN8tZFO6MSPe0VZnLmtcAQmw4L8hBakJMjJ9zZEtHs3rW_tudG5m41syw8Fz_pZ")
Base:RegisterWebhook("WEED_PROCESS", "https://discord.com/api/webhooks/679799729273700364/wtiSlpTnWZNsm_Tn2kd68naU25_qB7Xdh2osJ3wev2fTd9x2ew6Q7QWHJWpSzaYIlFou")
Base:RegisterWebhook("WEED_SELL", "https://discord.com/api/webhooks/1136083529822900325/O1V0ZzMCLppPY9rFsV6j9qRqES1q8TasaoKjh5SJZxFrwhnUHY6EuxQ_0vtCY8xlfYKd")

/*ESX.RegisterCommand("weed", "user", function(xPlayer)
    Inventory:AddItem(xPlayer.source, "weed_bud", 100, {
        state = "fresh"
    })
    Inventory:AddItem(xPlayer.source, "weed_bud", 100, {
        state = "dried"
    })
    Inventory:AddItem(xPlayer.source, "weed", 100)
    Inventory:AddItem(xPlayer.source, "smoke_papers", 100)
    Inventory:AddItem(xPlayer.source, "weed_shredder", 1)
end)*/

Citizen.CreateThread(function()
    Citizen.Wait(2500)
    local savedPlants = MySQL.query.await("SELECT * FROM `weed_plants`")
    if(next(savedPlants)) then
        for _,v in pairs(savedPlants) do
            v.coords = json.decode(v.coords)
            WeedPlants[WeedIndex] = GeneratePlantData(v)
            WeedIndex += 1
        end
    end
    local playerCount = #(GetPlayers())
    if(playerCount > 0) then
        SyncWeedPlants()
    end
    LoadedPlantsFromDatabase = true
end)

RegisterNetEvent("esx:playerLoaded", function(playerId)
    SyncWeedPlants(playerId)
end)

exports("weed_seed", function(event, item, inventory, slot, data)
    if(event ~= "usingItem") then
        return
    end

    local xPlayer = ESX.GetPlayerFromId(inventory.id)
    if(not xPlayer) then
        return
    end

    local _source = xPlayer.source

    lib.callback("strin_drugs:getGroundMaterial", _source, function(material)
        if(not lib.table.contains(SoilMaterials, material)) then
            xPlayer.showNotification("Špatný povrch pro rostlinu!", { type = "error" })
            return
        end
        local ped = GetPlayerPed(_source)
        local heading = GetEntityHeading(ped)
        local coords = GetEntityCoords(ped)

        local headingRadius = math.rad(heading + 90.0)
        local weedOffset = vector3(math.cos(headingRadius), math.sin(headingRadius), -1.0)

        local weedCoords = (coords + weedOffset)

        if(IsPlantCloseToOtherPlants(weedCoords)) then
            xPlayer.showNotification("Rostlina je až moc blízko jiné rostliny!", { type = "error" })
            return
        end

        local time = os.time()
        WeedPlants[WeedIndex] = GeneratePlantData({
            id = MySQL.insert.await("INSERT INTO `weed_plants` SET `coords` = ?, `planted_on` = ?", {
                json.encode(weedCoords),
                time
            }),
            coords = weedCoords,
            stage = 1,
            plantedOn = time
        })
        
        Base:DiscordLog("WEED_PLANT", "THE RAVE PROJECT - WEED PLANT", {
            { name = "Jméno hráče", value = ESX.SanitizeString(GetPlayerName(_source)) },
            { name = "Identifikace hráče", value = xPlayer.identifier },
            { name = "Lokace rostlny", value = json.encode(WeedPlants[WeedIndex].coords) },
            { name = "Informace o rostlině", value = json.encode(WeedPlants[WeedIndex]) },
        }, {
            fields = true,
        })

        WeedIndex += 1

        Inventory:RemoveItem(_source, "weed_seed", 1)
        xPlayer.showNotification("Zasadil/a jste semínko konopí.")

        SyncWeedPlants()
    end)
end)

exports("weed_shredder", function(event, item, inventory, slot, data)
    if(event ~= "usingItem") then
        return
    end

    local xPlayer = ESX.GetPlayerFromId(inventory.id)
    if(not xPlayer) then
        return
    end

    local _source = xPlayer.source
    local driedWeedBudCount = Inventory:GetItemCount(_source, "weed_bud", {
        state = "dried"
    })
    if(driedWeedBudCount <= 0) then
        xPlayer.showNotification("Nemáte u sebe žádné vysušené palice konopí!", { type = "error" })
        return
    end
    lib.callback("strin_drugs:shredWeed", _source, function(success)
        if(success) then
            local driedWeedBudCount = Inventory:GetItemCount(_source, "weed_bud", {
                state = "dried"
            })
            if(driedWeedBudCount <= 0) then
                xPlayer.showNotification("Nemáte u sebe žádné vysušené palice konopí!", { type = "error" })
                return
            end
            Inventory:RemoveItem(_source, "weed_bud", driedWeedBudCount, {
                state = "dried"
            })
            Inventory:AddItem(_source, "weed", math.floor(driedWeedBudCount * 1.7))
            Base:DiscordLog("WEED_PROCESS", "THE RAVE PROJECT - WEED PROCESS - SHRED", {
                { name = "Jméno hráče", value = ESX.SanitizeString(GetPlayerName(_source)) },
                { name = "Identifikace hráče", value = xPlayer.identifier },
                { name = "Množství sušených palic", value = driedWeedBudCount },
                { name = "Množství získané trávy", value = math.floor(driedWeedBudCount * 1.7) },
            }, {
                fields = true,
            })
        end
    end, driedWeedBudCount)
end)

exports("smoke_papers", function(event, item, inventory, slot, data)
    if(event ~= "usingItem") then
        return
    end

    local xPlayer = ESX.GetPlayerFromId(inventory.id)
    if(not xPlayer) then
        return
    end

    local _source = xPlayer.source
    local weedCount = Inventory:GetItemCount(_source, "weed")
    if(weedCount < 10) then
        xPlayer.showNotification("Nemáte u sebe dostatek žádné substance k ubalení!", { type = "error" })
        return
    end
    
    Inventory:RemoveItem(_source, "weed", 10)
    Inventory:AddItem(_source, "joint", 1)
    Base:DiscordLog("WEED_PROCESS", "THE RAVE PROJECT - WEED PROCESS - PAPER", {
        { name = "Jméno hráče", value = ESX.SanitizeString(GetPlayerName(_source)) },
        { name = "Identifikace hráče", value = xPlayer.identifier },
        { name = "Množství použité trávy", value = 10 },
        { name = "Množství získaných jointů", value = 1 },
    }, {
        fields = true,
    })
    /*lib.callback("strin_drugs:shredWeed", _source, function(success)
        if(success) then
            local driedWeedBudCount = Inventory:GetItemCount(_source, "weed_bud", {
                state = "dried"
            })
            if(driedWeedBudCount <= 0) then
                xPlayer.showNotification("Nemáte u sebe žádné vysušené palice konopí!", { type = "error" })
                return
            end
            Inventory:RemoveItem(_source, "weed_bud", driedWeedBudCount, {
                state = "dried"
            })
            Inventory:AddItem(_source, "weed", math.floor(driedWeedBudCount * 1.2))
        end
    end, driedWeedBudCount)*/
end)

RegisterNetEvent("strin_drugs:refreshWeedPlant", function(plantId, refresher)
    if(type(plantId) ~= "number" or (refresher ~= "FERTILIZER" and refresher ~= "WATER")) then
        return
    end
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    if(not WeedPlants[plantId]) then
        xPlayer.showNotification("Taková rostlina neexistuje!", { type = "error" })
        return
    end

    local refresherCount = Inventory:GetItemCount(_source, refresher:lower())
    if(refresherCount <= 0) then
        local message = (refresher == "WATER") and "žádnou vodu" or "žádné hnojivo"
        xPlayer.showNotification(("Nemáte u sebe %s!"):format(message), { type = "error" })
        return
    end

    local plant = WeedPlants[plantId]
    local distanceToPlant = #(GetEntityCoords(GetPlayerPed(_source)) - plant.coords)
    if(distanceToPlant > 3.0) then
        xPlayer.showNotification("Jste od rostliny moc daleko!", { type = "error" })
        return
    end

    Inventory:RemoveItem(_source, refresher:lower(), 1)
    WeedPlants[plantId][refresher:lower()] = 100.0
    local message = (refresher == "WATER") and "Zalil/a jste rostlinu." or "Pohnojil/a jste rostlinu."
    xPlayer.showNotification(message)
    SyncWeedPlants()
end)

RegisterNetEvent("strin_drugs:burnWeedPlant", function(plantId)
    if(type(plantId) ~= "number") then
        return
    end
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    if(not WeedPlants[plantId]) then
        xPlayer.showNotification("Taková rostlina neexistuje!", { type = "error" })
        return
    end

    local job = xPlayer.getJob()
    local hasLighter = Inventory:GetItemCount(_source, "lighter") > 0 or lib.table.contains(LawEnforcementJobs, job.name)
    if(not hasLighter) then
        xPlayer.showNotification("Nemáte u sebe zapalovač!", { type = "error" })
        return
    end

    local plant = WeedPlants[plantId]
    local distanceToPlant = #(GetEntityCoords(GetPlayerPed(_source)) - plant.coords)
    if(distanceToPlant > 3.0) then
        xPlayer.showNotification("Jste od rostliny moc daleko!", { type = "error" })
        return
    end

    DeletePlant(plantId, plant.id)
    xPlayer.showNotification("Zapálil/a jste rostlinu.")
    SyncWeedPlants()
end)

RegisterNetEvent("strin_drugs:harvestWeedPlant", function(plantId)
    if(type(plantId) ~= "number") then
        return
    end
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    if(not WeedPlants[plantId]) then
        xPlayer.showNotification("Taková rostlina neexistuje!", { type = "error" })
        return
    end


    local plant = WeedPlants[plantId]
    if(plant.stage < 3) then
        xPlayer.showNotification("Rostlina ještě není vyzrálá!", { type = "error" })
        return
    end

    local distanceToPlant = #(GetEntityCoords(GetPlayerPed(_source)) - plant.coords)
    if(distanceToPlant > 3.0) then
        xPlayer.showNotification("Jste od rostliny moc daleko!", { type = "error" })
        return
    end

    math.randomseed(os.time())
    local amount = math.random(1,3)
    Inventory:AddItem(_source, "weed_bud", amount, {
        state = "fresh"
    })
    Base:DiscordLog("WEED_HARVEST", "THE RAVE PROJECT - WEED HARVEST", {
        { name = "Jméno hráče", value = ESX.SanitizeString(GetPlayerName(_source)) },
        { name = "Identifikace hráče", value = xPlayer.identifier },
        { name = "Množství získaných živých palic", value = amount },
        { name = "Informace o rostlině", value = json.encode(WeedPlants[plantId]) },
    }, {
        fields = true,
    })
    DeletePlant(plantId, plant.id)
    xPlayer.showNotification("Sklidil jste rostlinu.")
    SyncWeedPlants()
end)

local DriedWeedBuds = {}

lib.callback.register("strin_drugs:dryWeedBuds", function(source, amount)
    if(type(amount) ~= "number") then
        return false
    end
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return false
    end


    local weedBudCount = Inventory:GetItemCount(_source, "weed_bud", {
        state = "fresh"
    })
    if(weedBudCount - amount < 0) then
        xPlayer.showNotification("Tolik palicí konopí u sebe nemáte!", { type = "error" })
        return false
    end

    local isInProperty = IsPlayerInValidProperty(_source, xPlayer.identifier..":"..xPlayer.get("char_id"))

    if(not isInProperty) then
        xPlayer.showNotification("Nejste v platné nemovitosti!", { type = "error" })
        return false
    end

    DriedWeedBuds[xPlayer.identifier] = amount

    Inventory:RemoveItem(_source, "weed_bud", amount, {
        state = "fresh"
    })
    xPlayer.showNotification("Palice se suší, vyčkejte chvíli.")
    Citizen.Wait(3000)
    xPlayer.showNotification("Palice jsou vysušeny, vemte si je z mikrovlnné trouby.")
    return true
end)

RegisterNetEvent("strin_drugs:retrieveDriedWeedBuds", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    if(not DriedWeedBuds[xPlayer.identifier]) then
        return
    end

    local isInProperty = IsPlayerInValidProperty(_source, xPlayer.identifier..":"..xPlayer.get("char_id"))

    if(not isInProperty) then
        xPlayer.showNotification("Nejste v platné nemovitosti!", { type = "error" })
        return
    end

    Inventory:AddItem(_source, "weed_bud", DriedWeedBuds[xPlayer.identifier], {
        state = "dried"
    })
    Base:DiscordLog("WEED_PROCESS", "THE RAVE PROJECT - WEED PROCESS - DRYING", {
        { name = "Jméno hráče", value = ESX.SanitizeString(GetPlayerName(_source)) },
        { name = "Identifikace hráče", value = xPlayer.identifier },
        { name = "Množství získaných sušených palic", value = DriedWeedBuds[xPlayer.identifier] },
    }, {
        fields = true,
    })
    DriedWeedBuds[xPlayer.identifier] = nil
end)

local WeedOffers = {}

RegisterNetEvent("strin_drugs:requestWeedOffer", function(pedNetId, amount)
    if(type(pedNetId) ~= "number" or type(amount) ~= "number" or amount <= 0) then
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

    local jointCount = Inventory:GetItemCount(_source, "joint")
    if((jointCount - amount) < 0) then
        xPlayer.showNotification("Nemáte u sebe tolik jointů!", { type = "error" })
        return
    end

    math.randomseed(os.time())
    local declineChance = math.random(1, 100)
    if(declineChance > 60) then -- 60
        WeedOffers[xPlayer.identifier] = nil
        Entity(pedEntity).state.recentlyOffered = true
        ClearPedTasks(pedEntity)
        FreezeEntityPosition(pedEntity, false)
        xPlayer.showNotification("Civilista nemá zájem.", { type = "error" })
        local callCopsChance = math.random(1, 100)
        if(callCopsChance > 50) then -- 50
            local recipientJobList = LawEnforcementJobs
            local data = {
                displayCode = '10-14',
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

    local total = 0
    for i=1, amount do
        total += math.random(WeedJointPrice[1], WeedJointPrice[2])
    end
    WeedOffers[xPlayer.identifier] = {
        total = total,
        amount = amount,
        pedNetId = pedNetId
    }
    TriggerClientEvent("strin_drugs:receiveWeedOffer", _source, WeedOffers[xPlayer.identifier])
end)

RegisterNetEvent("strin_drugs:finishWeedOffer", function(finishMethod)
    if(type(finishMethod) ~= "string" or (finishMethod ~= "ACCEPT" and finishMethod ~= "DECLINE")) then
        return
    end
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    local offer = WeedOffers[xPlayer.identifier]
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

    local jointCount = Inventory:GetItemCount(_source, "joint")
    if((jointCount - offer.amount) < 0) then
        WeedOffers[xPlayer.identifier] = nil
        xPlayer.showNotification("Nemáte u sebe tolik jointů!", { type = "error" })
        return
    end

    Entity(pedEntity).state.recentlyOffered = true
    
    if(finishMethod == "ACCEPT") then
        Inventory:RemoveItem(_source, "joint", offer.amount)
        xPlayer.addMoney(offer.total)
        Base:DiscordLog("WEED_SELL", "THE RAVE PROJECT - WEED SELL", {
            { name = "Jméno hráče", value = ESX.SanitizeString(GetPlayerName(_source)) },
            { name = "Identifikace hráče", value = xPlayer.identifier },
            { name = "Množství jointů", value = jointCount },
            { name = "Částka", value = ESX.Math.GroupDigits(offer.total).."$" },
        }, {
            fields = true,
        })
        return
    end
    
    WeedOffers[xPlayer.identifier] = nil
end)

AddEventHandler("playerDropped", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end
    if(WeedOffers[xPlayer.identifier]) then
        WeedOffers[xPlayer.identifier] = nil
    end
    if(DriedWeedBuds[xPlayer.identifier]) then
        Inventory:AddItem(_source, "weed_bud", DriedWeedBuds[xPlayer.identifier], {
            state = "dried"
        })
        DriedWeedBuds[xPlayer.identifier] = nil
    end
end)

function GeneratePlantData(data)
    local data = {
        id = data.id,
        coords = type(data.coords) == "table" and vector3(data.coords.x, data.coords.y, data.coords.z) or data.coords,
        stage = data.stage or 1,
        plantedOn = (data.plantedOn or data.planted_on) and tonumber(data.plantedOn or data.planted_on) or os.time(),
        water = data.water or 100.0,
        fertilizer = data.fertilizer or 100.0
    }
    return data
end

function DeletePlant(plantId, databaseId)
    WeedPlants[plantId] = false
    MySQL.query.await("DELETE FROM `weed_plants` WHERE `id` = ?", {
        databaseId
    })
end

function CalculateNextStageTimer(stage)
    local totalMinutes = 0
    for i=1, stage do
        totalMinutes += WeedPlantStageTimers[i]
    end
    return totalMinutes
end

function SyncWeedPlants(playerId)
    if(playerId) then
        TriggerClientEvent("strin_drugs:syncWeedPlants", playerId, WeedPlants)
    else
        TriggerClientEvent("strin_drugs:syncWeedPlants", -1, WeedPlants)
    end
end

function UpdateWeedPlantStage(plantId, databaseId, stage)
    WeedPlants[plantId].stage = stage
    MySQL.update.await("UPDATE `weed_plants` SET `stage` = ? WHERE `id` = ?", {
        stage,
        databaseId
    })
end

function IsPlantCloseToOtherPlants(coords)
    local isPlantClose = false
    for _,v in pairs(WeedPlants) do
        if(v) then
            local distance = #(coords - v.coords)
            if(distance < 2) then
                isPlantClose = true
                break
            end
        end
    end
    return isPlantClose
end

function IsPlayerInValidProperty(playerId, playerIdentifier)
    local properties = Property:GetOwnedProperties()
    local ped = GetPlayerPed(playerId)
    local coords = GetEntityCoords(ped)
    local isInProperty = false
    for _,v in pairs(properties) do
        local interior = Property:GetInteriorValues(v.Interior)
        local distance = #(coords - interior.pos)
        if(distance < 25) then
            if(v.Owner == playerIdentifier or v.Keys[playerIdentifier]) then
                isInProperty = true
                break
            end
        end
    end
    return isInProperty
end

/*

-- ONESYNC NETWORKED PLANT ENTITIES - DISCONTINUED - NETWORKED ENTITIES LIMIT ON LIMIT

AddEventHandler("entityRemoved", function(entity)
    local netId = NetworkGetNetworkIdFromEntity(entity)
    local entityType = GetEntityType(entity)
    local entityModel = GetEntityModel(entity)
    if(entityType == 3) then
        if(lib.table.contains(WeedModelHashes, entityModel)) then
            local plantInfo, plantId = GetPlantInfoFromNetworkId(netId)
                -- This won't work on resource stop
            if(plantId and (plantInfo.stage < 3 or (plantInfo == 3 and not plantInfo.upForDelete))) then
                WeedPlants[plantId].netId = CreatePlantObject(plantInfo.coords, plantInfo.stage, true)
            end
        end
        

        -- debug stuff
        if(lib.table.contains(WeedModelHashes, entityModel)) then
            print(netId, entityType, entityModel)
        end
    end
end)

function GeneratePlant(coords, stage, isNew)
    local plant = { 
        netId = CreatePlantObject(coords, stage, isNew),
        coords = coords,
        stage = stage,
        upForDelete = stage == 3 and true or false
    }
    return plant
end

function CreatePlantObject(coords, stage, isNew)
    local plantEntity = CreateObjectNoOffset(WeedModelHashes[stage], coords, true, true, true)
    while not DoesEntityExist(plantEntity) do
        Wait(100)
    end
    FreezeEntityPosition(plantEntity, true)
    return NetworkGetNetworkIdFromEntity(plantEntity)
end

function GetPlantInfoFromNetworkId(netId)
    local plantInfo = nil
    local plantId = nil
    for k,v in pairs(WeedPlants) do
        if(v?.netId == netId) then
            plantInfo = v
            plantId = k
            break
        end
    end
    return plantInfo, plantId
end

AddEventHandler("onResourceStop", function()
    for k,v in pairs(WeedPlants) do
        if(v) then
            local entity = NetworkGetEntityFromNetworkId(v.netId)
            if(DoesEntityExist(entity)) then
                DeleteEntity(entity)
            end
        end
    end
end)
*/

/*AddEventHandler("onResourceStart", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        StopResource("ox_inventory")
        while GetResourceState(resourceName) ~= "started" do
            Citizen.Wait(0)
        end
        StartResource("ox_inventory")
    end
end)*/