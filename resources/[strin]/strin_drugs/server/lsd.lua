local Cooldowns = {}

RegisterNetEvent("strin_drugs:requestLSD", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return false
    end
    if(xPlayer.getMoney() - LSDPrice < 0) then
        xPlayer.showNotification("Nemáte u sebe dostatek peněz!", { type = "error" })
        return false
    end
    if(Cooldowns[_source]) then
        xPlayer.showNotification("Nedávno jste si LSD koupil/a, dejte si pohov!", { type = "error" })
        return false
    end
    lib.callback("strin_drugs:checkForLSDSellers", _source, function(success)
        if(not success) then
            xPlayer.showNotification("Nelze koupit LSD!", { type = "error" })
            return
        end

        if(xPlayer.getMoney() - LSDPrice < 0) then
            xPlayer.showNotification("Nemáte u sebe dostatek peněz!", { type = "error" })
            return false
        end

        xPlayer.showNotification("Tady máš, ale bacha. Pěkně to jede! Nedoporučuju dávat víc jak 3x.")
        Inventory:AddItem(_source, "lsd", 1)
        xPlayer.removeMoney(LSDPrice)
        Cooldowns[_source] = true
        SetTimeout(7500, function()
            Cooldowns[_source] = nil
        end)
    end)
end)

Base:RegisterItemListener("lsd", function(item, inventory, slot, data)
    local xPlayer = ESX.GetPlayerFromId(inventory.id)
    if(not xPlayer) then
        return false
    end
    TriggerClientEvent("strin_drugs:takeLSD", xPlayer.source)
end, {
    event = "usedItem" 
})