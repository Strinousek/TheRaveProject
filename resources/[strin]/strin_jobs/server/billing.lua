local BillingCooldown = {}

local BillingColumns = {
    "society", "sender_identifier",
    "sender_char_id", "target_identifier",
    "target_char_id", "label", "amount"
}

local Base = exports.strin_base

Base:RegisterWebhook("BILLING", "https://discord.com/api/webhooks/1137782351238275183/SiaRrFdEqeS8r1tfon3DGhj4GKVrF7Os69bodRkqt5AKL0X3AfZTKbHaTcXRTLqjknpe")

RegisterNetEvent("strin_jobs:billPlayer", function(targetNetId, label, amount)
    if(type(targetNetId) ~= "number" or type(label) ~= "string" or type(amount) ~= "number") then
        return
    end

    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local job = xPlayer.getJob()
    if(not xPlayer or BillingCooldown[xPlayer.identifier] or not Jobs[job.name]) then
        return
    end

    if(label:len() > 250) then
        xPlayer.showNotification("Max počet znaků je 250!", {type = "error"})
        return
    end

    if(not HasAccessToAction(job.name, "billing")) then
        xPlayer.showNotification("K této akci nemá Vaše společnost přístup!", {type = "error"})
        return
    end

    local targetPlayer = ESX.GetPlayerFromId(targetNetId)
    if(not targetPlayer) then
        xPlayer.showNotification("Cílový hráč neexistuje!", {type = "error"})
        return
    end
    local arePlayersNearEachother = ArePlayersNearEachother(_source, targetNetId)
    if(not arePlayersNearEachother) then
        xPlayer.showNotification("Nejste hráči dostatečně blízko!", {type = "error"})
        return
    end

    local amount = type(amount) == "number" and amount or 0
    if(amount <= 0) then
        xPlayer.showNotification("Nemůžete vystavit fakturu o nulové sazbě!", {type = "error"})
        return
    end
    
    local label = type(label) == "string" and ESX.SanitizeString(label) or "Faktura"
    MySQL.insert.await(GenerateInsertBillingQuery(), {
        job.name,
        xPlayer.identifier,
        xPlayer.get("char_id"),  
        targetPlayer.identifier, 
        targetPlayer.get("char_id"),
        label,
        amount
    })
    Base:DiscordLog("BILLING", "THE RAVE PROJECT - FAKTURY - VYSTAVENÍ", {
        { name = "Jméno odesílatele", value = GetPlayerName(_source) },
        { name = "Identifikace odesílatele", value = xPlayer.identifier },
        { name = "Jméno postavy odesílatele", value = xPlayer.get("fullname").." | "..xPlayer.get("char_id") },
        { name = "Jméno obdržitele", value = GetPlayerName(targetPlayer.source) },
        { name = "Identifikace obdržitele", value = targetPlayer.identifier },
        { name = "Jméno postavy obdržitele", value = targetPlayer.get("fullname").." | "..targetPlayer.get("char_id") },
        { name = "Společnost", value = job.name },
        { name = "Název faktury", value = label },
        { name = "Částka faktury", value = ESX.Math.GroupDigits(amount).."$" },
    }, {
        fields = true
    })
    xPlayer.showNotification(("Vystavil jste fakturu na jméno %s - %s - %s$"):format(
        xPlayer.get("fullname"),
        label,
        amount
    ), {type = "success"})
    targetPlayer.showNotification(("Byla Vam vystavena faktura - %s - %s$"):format(
        label,
        amount
    ), {type = "inform"})
    BillingCooldown[xPlayer.identifier] = true
    SetTimeout(2000, function()
        BillingCooldown[xPlayer.identifier] = nil
    end)
end)

RegisterNetEvent("strin_jobs:payBill", function(billId)
    if(type(billId) ~= "number") then
        return
    end
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    local bill = MySQL.single.await("SELECT * FROM `billing` WHERE `id` = ?", { billId })
    if(not bill or not next(bill)) then
        xPlayer.showNotification("Taková faktura neexistuje!", { type = "error" })
        return
    end

    local bankMoney = xPlayer.getAccount('bank').money
    if(bankMoney - bill.amount < 0) then
        xPlayer.showNotification("Nemáte na zaplacení této faktury!", { type = "error" })
        return
    end

    MySQL.query.await("DELETE FROM `billing` WHERE `id` = ?", { billId })

    Base:DiscordLog("BILLING", "THE RAVE PROJECT - FAKTURY - ZAPLACENÍ", {
        { name = "Jméno hráče", value = GetPlayerName(_source) },
        { name = "Identifikace hráče", value = xPlayer.identifier },
        { name = "Jméno postavy hráče", value = xPlayer.get("fullname").." | "..xPlayer.get("char_id") },
        { name = "Společnost", value = bill.society },
        { name = "Název faktury", value = bill.label },
        { name = "Částka faktury", value = ESX.Math.GroupDigits(bill.amount).."$" },
    }, {
        fields = true
    })

    Society:AddSocietyMoney(bill.society, bill.amount)
    xPlayer.removeAccountMoney('bank', bill.amount)
    xPlayer.showNotification(("Zaplatil jste fakturu - %s - %s$"):format(bill.label, bill.amount))
end)

function GetCharacterBills(identifier, characterId)
    return MySQL.query.await("SELECT * FROM `billing` WHERE `target_identifier` = ? AND `target_char_id` = ?", {
        identifier,
        tonumber(characterId)
    })
end

exports("GetCharacterBills", GetCharacterBills)

function GenerateInsertBillingQuery()
    local expressions = {}
    for _,column in pairs(BillingColumns) do
        expressions[#expressions + 1] = "`"..column.."` = ?"
    end
    return ("INSERT INTO billing SET %s"):format(table.concat(expressions, ","))
end
