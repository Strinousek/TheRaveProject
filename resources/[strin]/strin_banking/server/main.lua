local Base = exports.strin_base

Base:RegisterWebhook("DEFAULT", "https://discord.com/api/webhooks/770802593940111390/rnRlUHQ_OR23JlaDKOk4Y2updITcG07yV1i-20oPGAIxIdXT3hdFUwG5cl00x17YPaz5")

RegisterNetEvent("strin_banking:transferATM", function(mode, amount)
    if((mode ~= "withdraw" and mode ~= "deposit") or not tonumber(amount)) then
        return
    end

    local amount = tonumber(amount)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    local isAmountValid = IsATMTransferAmountValid(amount)
    if(not isAmountValid) then
        xPlayer.showNotification("Tato částka není platná!", {type = "error"})
        return
    end

    local balance = xPlayer.getAccount('bank').money
    if(mode == "withdraw") then
        if((balance - amount) < 0) then
            xPlayer.showNotification("Tolik peněz nemáte!", {type = "error"})
            return
        end
        xPlayer.removeAccountMoney('bank', amount)
        xPlayer.addMoney(amount)
        Base:DiscordLog("DEFAULT", "THE RAVE PROJECT - ATM WITHDRAW", {
            { name = "Jméno hráče", value = ESX.SanitizeString(GetPlayerName(_source)) },
            { name = "Identifikace hráče", value = xPlayer.identifier },
            { name = "Částka", value = ESX.Math.GroupDigits(amount).."$" },
        }, {
            fields = true
        })
        xPlayer.showNotification(("Vybral jste z Vašeho bankovního účtu %s$!"):format(amount), {type = "inform"})
        return
    end
    local playerBalance = xPlayer.getAccount('money').money
    if((playerBalance - amount) < 0) then
        xPlayer.showNotification("Tolik peněz nemáte!", {type = "error"})
        return
    end
    Base:DiscordLog("DEFAULT", "THE RAVE PROJECT - ATM DEPOSIT", {
        { name = "Jméno hráče", value = ESX.SanitizeString(GetPlayerName(_source)) },
        { name = "Identifikace hráče", value = xPlayer.identifier },
        { name = "Částka", value = ESX.Math.GroupDigits(amount).."$" },
    }, {
        fields = true
    })
    xPlayer.addAccountMoney('bank', amount)
    xPlayer.removeMoney(amount)
    xPlayer.showNotification(("Vložil jste na Váš bankovní účet %s$!"):format(amount), {type = "inform"})
end)

RegisterNetEvent("strin_banking:transferBank", function(mode, amount)
    if((mode ~= "withdraw" and mode ~= "deposit") or not tonumber(amount)) then
        return
    end

    local amount = tonumber(amount)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    local isNearBank = IsNearBank(_source)
    if(not isNearBank) then
        xPlayer.showNotification("Nejste blízko banky!", {type = "error"})
        return
    end

    local balance = xPlayer.getAccount('bank').money
    if(mode == "withdraw") then
        if((balance - amount) < 0) then
            xPlayer.showNotification("Tolik peněz nemáte!", {type = "error"})
            return
        end
        Base:DiscordLog("DEFAULT", "THE RAVE PROJECT - BANK WITHDRAW", {
            { name = "Jméno hráče", value = ESX.SanitizeString(GetPlayerName(_source)) },
            { name = "Identifikace hráče", value = xPlayer.identifier },
            { name = "Částka", value = ESX.Math.GroupDigits(amount).."$" },
        }, {
            fields = true
        })
        xPlayer.removeAccountMoney('bank', amount)
        xPlayer.addMoney(amount)
        xPlayer.showNotification(("Vybral jste z Vašeho bankovního účtu %s$!"):format(amount), {type = "inform"})
        return
    end
    local playerBalance = xPlayer.getAccount('money').money
    if((playerBalance - amount) < 0) then
        xPlayer.showNotification("Tolik peněz nemáte!", {type = "error"})
        return
    end
    Base:DiscordLog("DEFAULT", "THE RAVE PROJECT - BANK DEPOSIT", {
        { name = "Jméno hráče", value = ESX.SanitizeString(GetPlayerName(_source)) },
        { name = "Identifikace hráče", value = xPlayer.identifier },
        { name = "Částka", value = ESX.Math.GroupDigits(amount).."$" },
    }, {
        fields = true
    })
    xPlayer.addAccountMoney('bank', amount)
    xPlayer.removeMoney(amount)
    xPlayer.showNotification(("Vložil jste na Váš bankovní účet %s$!"):format(amount), {type = "inform"})
end)

function IsATMTransferAmountValid(amount)
    local amountFound = false
    for i=1, #MaxATMTransfers do
        if(MaxATMTransfers[i] == amount) then
            amountFound = true
            break
        end
    end
    return amountFound
end

function IsNearBank(playerId)
    local ped = GetPlayerPed(playerId)
    local coords = GetEntityCoords(ped)
    local closestDistance = 15000.0
    for i=1, #BankLocations do
        local distance = #(coords - BankLocations[i])
        if(distance < closestDistance) then
            closestDistance = distance
        end
    end
    return closestDistance < 15.0
end