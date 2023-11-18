local HousesData = {}
local RoutingBucketId = 75335

do
    for _,v in pairs(Houses) do
        v.bucketId = RoutingBucketId
        SetRoutingBucketEntityLockdownMode(RoutingBucketId, "strict")
        RoutingBucketId += 1
    end
end

Citizen.CreateThread(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `robbed_houses` (
	        `house` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
	        `locked` BIT(1) NULL DEFAULT NULL,
	        `robbed` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
	        `players` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
	        `last_reset` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
            UNIQUE INDEX `house` (`house`) USING BTREE
        )
        COLLATE='utf8mb4_bin'
        ENGINE=InnoDB	
    ]])
    MySQL.query.await([[
		ALTER TABLE `robbed_houses`
	        ADD IF NOT EXISTS `house` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
	        ADD IF NOT EXISTS `locked` BIT(1) NULL DEFAULT NULL,
	        ADD IF NOT EXISTS `robbed` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
	        ADD IF NOT EXISTS `players` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
	        ADD IF NOT EXISTS `last_reset` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_bin';
    ]])
    local currentTime = os.time()
    MySQL.query("SELECT * FROM `robbed_houses`", function(houses)
        for i, house in each(houses) do
            local resetTime = tonumber(house.last_reset or os.time())
            local lockHouse, changeHouse = false, false
            local difference = (resetTime + 10800) - currentTime
            if difference > 0 then
                lockHouse, changeHouse, resetTime = true, true, currentTime
            end
            HousesData[house.house] = {
                locked = lockHouse,
                robbed = {},
                players = json.decode(house.players),
                lastReset = resetTime,
                changed = changeHouse
            }
        end

        for house, _ in each(Houses) do
            if(not HousesData[house]) then
                HousesData[house] = {
                    locked = true,
                    robbed = {},
                    players = {},
                    lastReset = os.time(),
                    changed = true
                }
            end
        end

        SyncHousesData()
    end)
end)

RegisterNetEvent("esx:playerLoaded", function(playerId, xPlayer)
    TriggerClientEvent("strin_robberies:syncHouses", playerId, HousesData)
    for house, data in each(HousesData) do
        if(lib.table.contains(data.players, xPlayer.identifier)) then
            SetPlayerRoutingBucket(playerId, Houses[house].bucketId)
        end
    end
end)

lib.callback.register("strin_robberies:lockpickHouse", function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if(not xPlayer) then
        return false
    end

    -- No need to check whether the player is already in a house, because the distance would always be >5
    local house = GetNearestHouse(_source, 5)
    if(not house) then
        xPlayer.showNotification(("Nejste poblíž žádného domu na vyloupení!"), {
            type = "error"
        })
        return false
    end

    local houseData = HousesData[house]

    if(not houseData?.locked) then
        xPlayer.showNotification(("Dům je již odemčený!"), {
            type = "error"
        })
        return false
    end

    local neededPoliceCount = Houses[house].houseType.needPoliceCount
    local isAvailable, message = CheckBasicRobberyAvailability(neededPoliceCount)

    if not isAvailable then
        xPlayer.showNotification(message, {
            type = "error"
        })
        return false
    end

    local result = Inventory:RemoveItem(_source, "lockpick", 1)
    if not result then
        xPlayer.showNotification(("Nemáte u sebe žádný šperhák!"), {
            type = "error"
        })
        return false
    end

    math.randomseed(GetGameTimer() + math.random(10000, 99999))
    if math.random(100) <= Houses[house].houseType.reportChance then
        NotifyCops("ROBBERY", "Vloupání do domu", "Domácí zabezpečení", Houses[house].coords.xyz)

        math.randomseed(GetGameTimer() + math.random(10000, 99999))
        if math.random(100) > Houses[house].houseType.reportChance then
            xPlayer.showNotification("Spustil/a jste alarm!", { type = "error" })
        end
    end

    Base:StartTimer(30)
    houseData.locked = false
    houseData.changed = true
    table.insert(houseData.players, xPlayer.identifier)
    SetPlayerRoutingBucket(_source, Houses[house].bucketId)
    SyncHousesData()
    return true
end)

lib.callback.register("strin_robberies:enterHouse", function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return false
    end

    -- No need to check whether the player is already in a house, because the distance would always be >5
    local house = GetNearestHouse(_source, 5)
    if(not house) then
        xPlayer.showNotification(("Nejste poblíž žádného domu na vyloupení!"), {
            type = "error"
        })
        return false
    end

    local foundPlayer = false
    for _, data in each(HousesData) do
        if(lib.table.contains(data.players, xPlayer.identifier)) then
            foundPlayer = true
            break
        end
    end

    if(foundPlayer) then
        return false
    end

    local houseData = HousesData[house]
    if(houseData.locked and not IsPlayerADistressEmployee(xPlayer.job.name)) then
        xPlayer.showNotification(("Nemůžete do zamčeného domu!"), {
            type = "error"
        })
        return false
    end

    table.insert(houseData.players, xPlayer.identifier)
    SetPlayerRoutingBucket(_source, Houses[house].bucketId)
    houseData.changed = true
    SyncHousesData()

    return true
end)

lib.callback.register("strin_robberies:leaveHouse", function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return false
    end

    local foundPlayer = false
    for house, data in each(HousesData) do
        for i, identifier in each(data.players) do
            if(identifier == xPlayer.identifier) then
                foundPlayer = true
                table.remove(data.players, i)
                data.changed = true
                SetPlayerRoutingBucket(_source, 0)
                break
            end
        end
    end

    if(not foundPlayer) then
        return false
    end

    SyncHousesData()
    return true
end)

lib.callback.register("strin_robberies:robHousePlace", function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return false
    end

    -- No need to check whether the player is already in a house, because the distance would always be >5
    local house = nil

    for houseKey, data in each(HousesData) do
        if(lib.table.contains(data.players, xPlayer.identifier)) then
            house = houseKey
            break
        end
    end
    if(not house) then
        xPlayer.showNotification(("Nejste poblíž žádného domu na vyloupení!"), {
            type = "error"
        })
        return false
    end

    if(HousesData[house].locked) then
        xPlayer.showNotification(("Tenhle dům už je zamčený, vypadněte než Vás někdo uvidí!"), {
            type = "error"
        })
        return false
    end

    local ped = GetPlayerPed(_source)
    local coords = GetEntityCoords(ped)

    local houseData = Houses[house].houseType

    local nearestPlace, distanceToNearestPlace = nil, 15000.0
    for place, placeCoords in each(houseData.insidePositions) do
        local distance = #(coords - placeCoords.xyz)
        if(distance < distanceToNearestPlace) then
            distanceToNearestPlace = distance
            nearestPlace = place
        end
    end

    if(distanceToNearestPlace > 5 or nearestPlace == "Exit") then
        xPlayer.showNotification("Nejste poblíž žádného místa k prohledání!", { type = "error" })
        return false
    end

    if(lib.table.contains(HousesData[house].robbed, nearestPlace)) then
        xPlayer.showNotification("Tohle místo už je prázdné!", { type = "error" })
        return false
    end

    math.randomseed(GetGameTimer() + math.random(10000, 99999))

    if math.random(100) <= houseData.chanceToFindNothing then
        xPlayer.showNotification("Nepovedlo se Vám nic najít, zkuste to znovu.")
        return false
    end
    
    local foundItem, count = nil, 1
    while not foundItem do
        for i, item in each(houseData.items) do
            math.randomseed(GetGameTimer() + math.random(10000, 99999))
            if math.random(100) <= item.chance then
                foundItem = item.item
                count = math.random(item.minCount, item.maxCount)
            end
        end
        Citizen.Wait(0)
    end

    local addedItem = false
    if(Inventory:CanCarryItem(_source, foundItem, count)) then
        addedItem = Inventory:AddItem(_source, foundItem, count)
    end

    if(not addedItem) then
        xPlayer.showNotification("Něco se Vám povedlo najít, ale již to neunesete!", { type = "error" })
        return false
    end

    xPlayer.showNotification("Něco se Vám povedlo najít!", { type = "success" })
    table.insert(HousesData[house].robbed, nearestPlace)
    HousesData[house].changed = true
    SyncHousesData()
    return true
end)

function GetNearestHouse(playerId, distanceToleration)
    local ped = GetPlayerPed(playerId)
    local coords = GetEntityCoords(ped)
    local houseKey, distanceToHouse = nil, 15000.0
    for house, data in each(Houses) do
        local distance = #(coords - data.coords.xyz)
        if(distance < distanceToHouse) then
            distanceToHouse = distance
            houseKey = house
        end
    end
    if(distanceToleration and distanceToHouse > distanceToleration) then
        return false, 15000.0
    end
    return houseKey, distanceToHouse
end

function SyncHousesData()
    local currentTime = os.time()
    for house, data in pairs(HousesData) do
        if data.changed then
            data.changed = false
            local lockHouse = data.locked
            local difference = currentTime - (data.lastReset + 10800)
            if difference > 0 then
                lockHouse = true
            end
            if lockHouse then
                data.locked = true
                data.robbed = {}
                data.lastReset = os.time()
            end
            MySQL.query(
                "INSERT INTO robbed_houses (house, locked, robbed, players) VALUES (@house, @locked, @robbed, @players) ON DUPLICATE KEY UPDATE locked = @locked, robbed = @robbed, players = @players, last_reset = @last_reset",
                {
                    ["@house"] = house,
                    ["@robbed"] = json.encode(data.robbed),
                    ["@players"] = json.encode(data.players),
                    ["@locked"] = lockHouse,
                    ["@last_reset"] = data.lastReset
                }
            )
        end
    end
    Citizen.Wait(750)
    TriggerClientEvent("strin_robberies:syncHouses", -1, HousesData)
end
