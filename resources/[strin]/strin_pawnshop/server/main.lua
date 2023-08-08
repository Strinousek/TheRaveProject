
local PawnShopStocks = {}
local lastlyRestocked = os.time()
RestockIntervalId = nil

local Base = exports.strin_base
Base:RegisterWebhook("DEFAULT", "https://discord.com/api/webhooks/1136013122885390367/_JuFZo5D7hU8JXkBnXh-a_HC28kvo-Hec_qF7Uc1wkafEw3WjXrLXKMhRUnDw0txtgBR")

Citizen.CreateThread(function()
    local MaxRestocks = {}
    for k,v in pairs(PAWNSHOPS) do
        local stocks = v.items and lib.table.deepclone(v.items) or lib.table.deepclone(DEFAULT_PAWNSHOPS_ITEMS)
        PawnShopStocks[k] = stocks
        if(not MaxRestocks[k]) then
            MaxRestocks[k] = {}
        end
        for _,stock in pairs(stocks) do 
            MaxRestocks[k][stock.name] = stock.max
        end
    end
    
    RestockIntervalId = SetInterval(function()
        for k,v in pairs(PawnShopStocks) do
            for itemId,item in pairs(v) do
                item.max = MaxRestocks[k][item.name]
            end
        end
        lastlyRestocked = os.time()
    end, 30 * 60000)
end)

lib.callback.register("strin_pawnshop:getStocks", function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return false
    end

    local nearestPawnshopId = GetNearestPawnshopId(_source, 10.0)
    if(not nearestPawnshopId) then
        return false
    end

    local stocks = PawnShopStocks[nearestPawnshopId]
    local availableStocks = {}
    for _,v in pairs(stocks) do
        if(v.max > 0) then
            table.insert(availableStocks, v)
        end
    end
    return availableStocks, (30 * 60 + lastlyRestocked) - os.time()
end)

RegisterNetEvent("strin_pawnshop:sellStocks", function(stocks)
    if(type(stocks) ~= "table" or not next(stocks)) then
        return
    end
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    local nearestPawnshopId = GetNearestPawnshopId(_source, 10.0)
    if(not nearestPawnshopId) then
        xPlayer.showNotification("Nejste poblíž žádné zastavárny!", { type = "error" })
        return
    end

    local pawnShopStocks = PawnShopStocks[nearestPawnshopId]

    local validatedStocks = ValidateStocks(pawnShopStocks, stocks)
    if(not validatedStocks) then
        xPlayer.showNotification("Neplatná nabídka!", { type = "error" })
        return
    end

    local totalReward = 0
    for k,v in pairs(validatedStocks) do
        local itemCount = Inventory:GetItemCount(_source, v.name)
        if((itemCount - v.amount) >= 0) then
            Inventory:RemoveItem(_source, v.name, v.amount)
            xPlayer.addMoney(v.amount * v.price)
            totalReward += v.amount * v.price
            for _,v2 in pairs(pawnShopStocks) do
                if(v.name == v2.name) then
                    v2.max -= v.amount
                end
            end
        end
    end
    
    if(totalReward > 0) then
        Base:DiscordLog("DEFAULT", "THE RAVE PROJECT - ZASTAVÁRNA", {
            { name = "Jméno hráče", value = ESX.SanitizeString(GetPlayerName(_source)) },
            { name = "Identifikace hráče", value = xPlayer.identifier },
            { name = "Zastavené zboží", value = json.encode(validatedStocks) },
            { name = "Částka", value = ESX.Math.GroupDigits(totalReward).."$" },
        }, {
            fields = true,
        })
    end
    
    xPlayer.showNotification(("Zastavil/a jste zboží v hodnotě %s$"):format(ESX.Math.GroupDigits(totalReward)))
end)

function ValidateStocks(pawnShopStocks, stocks)
    local validatedStocks = {}
    for k,v in pairs(stocks) do
        if((v?.name and v?.amount) and (type(v?.name) == "string" and type(v?.amount) == "number") and math.floor(v?.amount) > 0) then
            for _,v2 in pairs(pawnShopStocks) do
                if(v.name == v2.name and (v2.max - v.amount >= 0)) then
                    table.insert(validatedStocks, { name = v?.name, amount = math.floor(v?.amount), price = v2.price })
                end
            end
        end
    end
    return next(validatedStocks) and validatedStocks or nil
end

function GetNearestPawnshopId(playerId, distanceToleration)
    local ped = GetPlayerPed(playerId)
    local coords = GetEntityCoords(ped)
    local nearestPawnshopId = nil
    local distanceToPawnshop = 15000.0
    for k,v in pairs(PAWNSHOPS) do
        local distance = #(coords - v.coords)
        if(distance < distanceToPawnshop) then
            nearestPawnshopId = k
            distanceToPawnshop = distance
        end
    end
    return (distanceToPawnshop < distanceToleration) and nearestPawnshopId or nil
end