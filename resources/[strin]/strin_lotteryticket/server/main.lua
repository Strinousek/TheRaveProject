local Base = exports.strin_base
local Inventory = exports.ox_inventory

Base:RegisterItemListener("lottery_ticket", function(_, inventory, slot)
    local _source = inventory.id
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return false
    end
    local item = Inventory:GetSlot(_source, slot)
    if(item?.metadata?.winnings) then
        Inventory:RemoveItem(_source, "lottery_ticket", 1, item?.metadata, slot)
        xPlayer.addMoney(tonumber(item?.metadata?.winnings))
        return true
    end
    local ticketNumbers = GenerateNumbers()
    local winningNumbers = GenerateNumbers()
    TriggerClientEvent("strin_lotteryticket:open", _source, ticketNumbers, winningNumbers)
    Inventory:SetMetadata(_source, slot, {
        ticketNumbers = table.concat(ticketNumbers, ", "),
        winningNumbers = table.concat(winningNumbers, ", "),
        winnings = GetWinnings(ticketNumbers, winningNumbers)
    })
    return true
end, {
    event = "usingItem",
})

function GenerateNumbers()
    local numbers = {}
    for i=1, 4 do
        math.randomseed(GetGameTimer() + math.random(10000, 99999))
        table.insert(numbers, math.random(0, 9))
    end
    return numbers
end

function GetWinnings(numbers, winningNumbers)
    local winnings = 0
    for i=1, #winningNumbers do
        if(numbers[i] == winningNumbers[i]) then
            winnings += CASH_AMOUNT_PER_NUMBER
        end
    end
    return winnings
end