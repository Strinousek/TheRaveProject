local SideJobModuleName = "lumberjack"
local _ActiveLumberjacks = {}
ActiveLumberjacks = GenerateSideJobModule(SideJobModuleName, _ActiveLumberjacks, function(xPlayer)
    local _source = xPlayer.source
    if(WorkingPlayers[_source]) then
        xPlayer.showNotification("Již provádíte jinou práci!", { type = "error" })
        return
    end

    local ped = GetPlayerPed(_source)
    local vehicle = GetVehiclePedIsIn(ped)
    if(vehicle == 0 or not lib.table.contains(LUMBERJACK_LOG_VEHICLES, GetEntityModel(vehicle))) then
        xPlayer.showNotification("Nejste ve příslušném vozidle!", { type = "error" })
        return
    end

    local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)

    local lumberjack = GenerateLumberjackService(vehicleNetId)
    if(not lumberjack) then
        xPlayer.showNotification("Všechny místa kácení jsou zabrané! Zkuste později.", { type = "error" })
        return
    end

    ActiveLumberjacks[_source] = lumberjack
    TriggerClientEvent("strin_sidejobs:initTrees", _source, lumberjack)
    xPlayer.showNotification("Byly Vám označeny stromy ke skácení.")
end, function(xPlayer)
    local _source = xPlayer.source
    local activeLumberjack = ActiveLumberjacks[_source]
    if(not activeLumberjack) then
        xPlayer.showNotification("Nejste zaregistrován jako dřevorubec!", { type = "error" })
        return
    end
    for i, tree in pairs(activeLumberjack.trees) do
        local treeEntity = NetworkGetEntityFromNetworkId(tree.netId)
        activeLumberjack.trees[i].chopped = true
        DeleteEntity(treeEntity)
        if(tree.logNetId) then
            local logEntity = NetworkGetEntityFromNetworkId(tree.logNetId)
            activeLumberjack.trees[i].logNetId = false
            DeleteEntity(logEntity)
        end
    end
    local vehicle = NetworkGetEntityFromNetworkId(activeLumberjack.vehicleNetId)
    if(DoesEntityExist(vehicle)) then
        Entity(vehicle).state.logsStored = 0
    end
    ActiveLumberjacks[_source] = nil
    TriggerClientEvent("strin_sidejobs:resetLumberjackModule", _source)
    xPlayer.showNotification("Odhlásil jste se jako dřevorubec.")
end)

RegisterNetEvent("strin_sidejobs:chopTree", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    local activeLumberjack = ActiveLumberjacks[_source]
    if(not activeLumberjack) then
        xPlayer.showNotification("Nejste zaregistrován jako dřevorubec!", { type = "error" })
        return
    end

    local tree = GetNearestTree(_source, 10.0)
    if(not tree) then
        xPlayer.showNotification("Nejste poblíž žádnému stromu!", { type = "error" })
        return
    end
    
    if(tree.chopped) then
        xPlayer.showNotification("Tento strom již je pokácený!", { type = "error" })
        return
    end

    local treeEntity = NetworkGetEntityFromNetworkId(tree.netId)
    DeleteEntity(treeEntity)
    local ped = GetPlayerPed(_source)
    local coords = GetEntityCoords(ped)
    activeLumberjack.trees[tree.treeIndex].chopped = true
    local logEntity = CreateObjectNoOffset(LUMBERJACK_LOG_MODEL, coords, true, true)
    local logNetId = NetworkGetNetworkIdFromEntity(logEntity)
    activeLumberjack.trees[tree.treeIndex].logNetId = logNetId
    TriggerClientEvent("strin_sidejobs:attachLogToPed", _source, logNetId)
    if(not AreAllTreesChopped(_source)) then
        return
    end
    TriggerClientEvent("strin_sidejobs:initDropOff", _source)
    xPlayer.showNotification("Na GPS Vám bylo označeno místo vyložení.")
end)

RegisterNetEvent("strin_sidejobs:dropOffLogs", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    local activeLumberjack = ActiveLumberjacks[_source]
    if(not activeLumberjack) then
        xPlayer.showNotification("Nejste zaregistrován jako dřevorubec!", { type = "error" })
        return
    end

    local vehicle = NetworkGetEntityFromNetworkId(activeLumberjack.vehicleNetId)
    if(not DoesEntityExist(vehicle)) then
        xPlayer.showNotification("Takové vozidlo neexistuje!", { type = "error" })
        return
    end

    local ped = GetPlayerPed(_source)
    local coords = GetEntityCoords(ped)
    local vehicleCoords = GetEntityCoords(vehicle)
    local distanceToVehicle = #(coords - vehicleCoords)
    if(distanceToVehicle > 10) then
        xPlayer.showNotification("Jste od vozidla moc daleko!", { type = "error" })
        return
    end

    local distanceToDropOff = #(coords - LUMBERJACK_DROP_OFF_COORDS)
    if(distanceToDropOff > 20) then
        xPlayer.showNotification("Jste od místa vyložení moc daleko!", { type = "error" })
        return
    end

    local choppedTreesCount = 0
    for k,v in pairs(activeLumberjack.trees) do
        if(v.chopped) then 
            choppedTreesCount += 1
        end
    end

    if(choppedTreesCount ~= #activeLumberjack.trees) then
        xPlayer.showNotification("Musíte pokácet všechny stromy!", { type = "error" })
        return
    end

    local logsStored = Entity(vehicle).state.logsStored or 0

    if(logsStored > choppedTreesCount) then
        print("STRIN_SIDEJOBS: "..xPlayer.identifier.." has a vehicle with logs = "..logsStored.."/"..choppedTreesCount)
        return
    end

    local finishTime = os.time() - activeLumberjack.startedOn 
    
    if(finishTime < 60) then
        print("STRIN_SIDEJOBS: "..xPlayer.identifier.." tried to finish lumberjack too fast")
        return
    end

    local totalPayout = PayoutSideJob(_source, math.floor(LUMBERJACK_TREE_LOG_PRICE * logsStored))
    xPlayer.showNotification(("Bylo Vám vyplaceno %s$ za dovezení dřeva."):format(ESX.Math.GroupDigits(totalPayout)))

    Base:DiscordLog("DEFAULT", "THE RAVE PROJECT - SIDE JOBS", {
        { name = "Typ", value = SideJobModuleName },
        { name = "Hráč", value = ("#%s - %s - %s"):format(_source, xPlayer.getName(), xPlayer.identifier) },
        { name = "Výplata", value = ("%s$"):format(ESX.Math.GroupDigits(totalPayout)) },
        { name = "Počet klád", value = ("%sx"):format(math.floor(logsStored)) },
        { name = "Počet skácených stromů", value = ("%sx"):format(math.floor(choppedTreesCount)) },
        { name = "Čas", value = ("%ss"):format(finishTime) },
    }, {
        fields = true
    })

    for i, tree in pairs(activeLumberjack.trees) do
        local treeEntity = NetworkGetEntityFromNetworkId(tree.netId)
        activeLumberjack.trees[i].chopped = true
        DeleteEntity(treeEntity)
        if(tree.logNetId) then
            local logEntity = NetworkGetEntityFromNetworkId(tree.logNetId)
            activeLumberjack.trees[i].logNetId = false
            DeleteEntity(logEntity)
        end
    end
    Entity(vehicle).state.logsStored = 0
    local vehicleNetId = activeLumberjack.vehicleNetId
    TriggerClientEvent("strin_sidejobs:resetLumberjackModule", _source)

    ActiveLumberjacks[_source] = nil
    local newLumberjack = GenerateLumberjackService(vehicleNetId)
    if(not newLumberjack) then
        xPlayer.showNotification("Všechny místa kácení jsou zabrané! Zkuste později.", { type = "error" })
        return
    end
    
    ActiveLumberjacks[_source] = newLumberjack
    TriggerClientEvent("strin_sidejobs:initTrees", _source, newLumberjack)
end)

AddEventHandler("entityRemoved", function(entity)
    local netId = NetworkGetNetworkIdFromEntity(entity)
    for k,v in pairs(ActiveLumberjacks) do
        for treeIndex, tree in pairs(v.trees) do
             if(tree.netId == netId and not tree.chopped) then
                local treeEntity = CreateObjectNoOffset(LUMBERJACK_TREE_MODEL, tree.coords - vector3(0, 0, 1.0), true, true)
                FreezeEntityPosition(treeEntity, true)
                TriggerClientEvent("strin_sidejobs:initTreeTarget", k, treeIndex, tree.netId)
             end
             if(type(tree.logNetId) ~= "boolean" and tree.logNetId == tree.netId) then
                local ped = GetPlayerPed(k)
                local coords = GetEntityCoords(ped)
                local logEntity = CreateObjectNoOffset(LUMBERJACK_LOG_MODEL, coords, true, true)
                local logNetId = NetworkGetNetworkIdFromEntity(logEntity)
                v.trees[treeIndex].logNetId = logNetId
                TriggerClientEvent("strin_sidejobs:attachLogToPed", _source, logNetId)
             end
        end
        if(v.vehicleNetId == netId) then
            for i, tree in pairs(v.trees) do
                local treeEntity = NetworkGetEntityFromNetworkId(tree.netId)
                v.trees[i].chopped = true
                DeleteEntity(treeEntity)
                if(tree.logNetId) then
                    local logEntity = NetworkGetEntityFromNetworkId(tree.logNetId)
                    v.trees[i].logNetId = false
                    DeleteEntity(logEntity)
                end
            end
            ActiveLumberjacks[k] = nil
        end
    end
end)

lib.callback.register("strin_sidejobs:putLogInVehicle", function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return false
    end

    local activeLumberjack = ActiveLumberjacks[_source]
    if(not activeLumberjack) then
        xPlayer.showNotification("Nejste zaregistrován jako dřevorubec!", { type = "error" })
        return false
    end

    local vehicle = NetworkGetEntityFromNetworkId(activeLumberjack.vehicleNetId)
    if(not DoesEntityExist(vehicle)) then
        xPlayer.showNotification("Takové vozidlo neexistuje!", { type = "error" })
        return false
    end

    local ped = GetPlayerPed(_source)
    local coords = GetEntityCoords(ped)
    local vehicleCoords = GetEntityCoords(vehicle)
    local distance = #(coords - vehicleCoords)
    if(distance > 10) then
        xPlayer.showNotification("Jste od vozidla moc daleko!", { type = "error" })
        return false
    end

    local logNetId, treeIndex = GetCurrentLogNetworkId(_source)
    if(not logNetId or not treeIndex) then
        xPlayer.showNotification("Kláda nebo strom neexistuje!", { type = "error" })
        return false
    end

    local logsStored = Entity(vehicle).state.logsStored
    Entity(vehicle).state.logsStored = logsStored and logsStored + 1 or 1

    local logEntity = NetworkGetEntityFromNetworkId(logNetId)
    DeleteEntity(logEntity)
    ClearPedTasks(ped)
    activeLumberjack.trees[treeIndex].logNetId = false
    return true
end)

function GenerateLumberjackService(vehicleNetId)
    local treeSpotIndex = FindFreeTreeSpotIndex()
    if(not treeSpotIndex) then
        return false
    end

    local treeSpot = LUMBERJACK_TREE_SPOTS[treeSpotIndex]
    local trees = {}
    for i=1, #treeSpot do
        local tree = CreateObjectNoOffset(LUMBERJACK_TREE_MODEL, treeSpot[i] - vector3(0, 0, 1.0), true, true)
        FreezeEntityPosition(tree, true)
        trees[i] = {
            netId = NetworkGetNetworkIdFromEntity(tree),
            coords = treeSpot[i],
            logNetId = false,
            chopped = false,
            treeIndex = i,
        }
    end
    return {
        startedOn = os.time(),
        treeSpotIndex = treeSpotIndex,
        trees = trees,
        vehicleNetId = vehicleNetId
    }
end

function GetCurrentLogNetworkId(playerId)
    local activeLumberjack = ActiveLumberjacks[playerId]
    local treeIndex = nil
    local logNetId = nil
    for k,v in pairs(activeLumberjack.trees) do
        if(v.logNetId) then
            logNetId = v.logNetId
            treeIndex = k
        end
    end
    return logNetId, treeIndex
end

function GetNearestTree(playerId, distanceToleration)
    local activeLumberjack = ActiveLumberjacks[playerId]
    local ped = GetPlayerPed(playerId)
    local coords = GetEntityCoords(ped)
    local nearestTree = nil
    local distanceToNearestTree = 15000.0
    for i=1, #activeLumberjack.trees do
        local distance = #(coords - activeLumberjack.trees[i].coords)
        if(distance < distanceToNearestTree) then
            distanceToNearestTree = distance
            nearestTree = activeLumberjack.trees[i]
        end
    end
    return (distanceToNearestTree < distanceToleration) and nearestTree or nil
end

function FindFreeTreeSpotIndex()
    local availableTreeSpots = lib.table.deepclone(LUMBERJACK_TREE_SPOTS)
    for k,v in pairs(ActiveLumberjacks) do
        availableTreeSpots[v.treeSpotIndex] = false
    end
    local sanitizedTreeSpotIndexes = {}
    for k,v in pairs(availableTreeSpots) do
        if(v) then
            table.insert(sanitizedTreeSpotIndexes, k)
        end
    end
    math.randomseed(GetGameTimer())
    return next(sanitizedTreeSpotIndexes) and sanitizedTreeSpotIndexes[math.random(1, #sanitizedTreeSpotIndexes)] or nil
end

function AreAllTreesChopped(playerId)
    local allTreesAreChopped = true
    for k,v in pairs(ActiveLumberjacks[playerId].trees) do
        if(not v.chopped) then
            allTreesAreChopped = false
            break
        end
    end
    return allTreesAreChopped
end

AddEventHandler("onResourceStop", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        for k,v in pairs(ActiveLumberjacks) do
            for i, tree in pairs(v.trees) do
                local treeEntity = NetworkGetEntityFromNetworkId(tree.netId)
                v.trees[i].chopped = true
                DeleteEntity(treeEntity)
                if(tree.logNetId) then
                    local logEntity = NetworkGetEntityFromNetworkId(tree.logNetId)
                    v.trees[i].logNetId = false
                    DeleteEntity(logEntity)
                end
            end
            local vehicle = NetworkGetEntityFromNetworkId(v.vehicleNetId)
            if(DoesEntityExist(vehicle)) then
                Entity(vehicle).state.logsStored = 0
            end
            TriggerClientEvent("strin_sidejobs:resetLumberjackModule", k)
        end
    end
end)

AddEventHandler("playerDropped", function()
    local _source = source
    if(not ActiveLumberjacks[_source]) then
        return
    end
    local activeLumberjack = ActiveLumberjacks[_source]
    for i, tree in pairs(activeLumberjack.trees) do
        local treeEntity = NetworkGetEntityFromNetworkId(tree.netId)
        activeLumberjack.trees[i].chopped = true
        DeleteEntity(treeEntity)
        if(tree.logNetId) then
            local logEntity = NetworkGetEntityFromNetworkId(tree.logNetId)
            activeLumberjack.trees[i].logNetId = false
            DeleteEntity(logEntity)
        end
    end
    ActiveLumberjacks[_source] = nil
end)