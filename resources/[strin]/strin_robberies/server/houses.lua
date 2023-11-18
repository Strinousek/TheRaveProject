local housesData = {}

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
	        `last_reset` INT(11) NULL DEFAULT NULL COLLATE 'utf8mb4_bin'
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
	        ADD IF NOT EXISTS `last_reset` INT(11) NULL DEFAULT NULL COLLATE 'utf8mb4_bin';
    ]])
    local currentTime = os.time()
    MySQL.query("SELECT * FROM robbed_houses", function(houses)
        for i, house in each(houses) do
            local lockHouse, changeHouse, resetTime, robbed = false, false, house.last_reset, house.robbed
            local difference = (house.lastreset + 10800) - currentTime
            if difference < 0 then
                lockHouse, changeHouse, resetTime, robbed = true, true, currentTime, {}
            end
            housesData[house.house] = {
                locked = lockHouse,
                robbed = {},
                players = json.decode(house.players),
                lastReset = resetTime,
                changed = changeHouse
            }
        end

        SyncHousesData()
    end)
end)

RegisterNetEvent("rob_houses:sync", function()
    local _source = source
    TriggerClientEvent("rob_houses:sync", _source, housesData, true)
end)

RegisterNetEvent("rob_houses:lockpick", function(house)
    local _source = source
    local policeCount = Base:CountCops()
    local neededPoliceCount = Houses[house].houseType.needPoliceCount

    if policeCount < neededPoliceCount then
        TriggerClientEvent(
            "chat:addMessage",
            _source,
            {
                templateId = "error",
                args = {
                    "Pro vykradení tohoto domu musí být na serveru alespoň " .. neededPoliceCount .. " policisti!"
                }
            }
        )
        return
    end
    local result = Inventory:RemoveItem(_source, "lockpick", 1)
    if result then
        --TriggerClientEvent("rob_houses:lockpick", _source, house)
    else
        --TriggerClientEvent("rob_houses:error", _source, "Musíš mít u sebe šperhák!")
    end
end)

RegisterNetEvent("rob_houses:unlockHouse", function(house)
    local _source = source
    local houseType = Houses[house].houseType

    if math.random(100) <= houseType.reportChance then
        TriggerEvent(
            "outlawalert:sendAlert",
            {
                Type = "house",
                Coords = Houses[house].coords.xyz
            }
        )
        if math.random(100) > houseType.reportChance then
            TriggerClientEvent(
                "notify:display",
                _source,
                {
                    type = "error",
                    title = "Alarm",
                    text = "Spustil jsi alarm!",
                    icon = "fas fa-exclamation-triangle",
                    length = 5000
                }
            )
        end
    end

    if housesData[house] then
        housesData[house].locked = false
    else
        housesData[house] = {
            locked = false,
            robbed = {},
            players = {},
            lastReset = os.time(),
            changed = true
        }
    end
    --TriggerClientEvent("rob_houses:sync", -1, housesData, false)
end)

RegisterNetEvent("rob_houses:joinHouse", function(house)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end
    local identifier = xPlayer.identifier

    local alreadyIn = false

    if housesData[house] then
        for i, player in each(housesData[house].players) do
            if player == identifier then
                alreadyIn = true
                break
            end
        end
    else
        housesData[house] = {
            locked = false,
            robbed = {},
            players = {},
            lastReset = os.time(),
            changed = true
        }
    end

    if not alreadyIn then
        table.insert(housesData[house].players, identifier)
    end
end)

RegisterNetEvent("rob_houses:robbedHousePlace", function(house, place)
    local _source = source
    local houseType = Houses[house].houseType

    if math.random(1, 100) <= houseType.chanceToFindNothing then
        --TriggerClientEvent("rob_houses:searchResult", _source, nil, nil)
    else
        local foundItem, count, foundItemData = nil, 1, {}
        while not foundItem do
            for i, item in each(houseType.items) do
                if math.random(100) <= item.chance then
                    foundItem = item.item
                    count = math.random(item.minCount, item.maxCount)
                end
            end
            Citizen.Wait(0)
        end
        local addedItem = false
        if(Inventory:CanCarryItem(_source, foundItem, count)) then
            addedItem = true
            Inventory:AddItem(_source, foundItem, count)
        end

        if addedItem then
            --TriggerClientEvent("rob_houses:searchResult", _source, foundItem, count)
        else
            --TriggerClientEvent("rob_houses:error", _source, addResult)
        end
    end

    table.insert(housesData[house].robbed, place)
    housesData[house].changed = true
    --TriggerClientEvent("rob_houses:sync", -1, housesData, false)
end)

RegisterNetEvent("rob_houses:leaveHouse", function(house)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end
    local identifier = xPlayer.identifier

    for i, player in each(housesData[house].players) do
        if player == identifier then
            table.remove(housesData[house].players, i)
            housesData[house].changed = true
            break
        end
    end
end)

function SyncHousesData()
    local currentTime = os.time()
    for house, data in pairs(housesData) do
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
            MySQL.prepare(
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
    --TriggerClientEvent("rob_houses:sync", -1, housesData)
    SetTimeout(1800000, SyncHousesData)
end
