RegisteredPaychecks = {}

local FreePayouts = {
    "police", "fire", "ambulance", "unemployed"
}

StartPaycheck = function()
    return SetInterval(function()
        local totalPayouts = {}
        if(next(RegisteredPaychecks)) then
            for identifier, v in pairs(RegisteredPaychecks) do
                if(v) then
                    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
                    if(xPlayer) then
                        if(GetRemainingTimeUntilNextPaycheck(identifier) <= 0) then
                            local job = xPlayer.getJob()
                            local society = GetSociety(job.name)
                            local salary = society?.grades[job.grade].salary
                            if(not lib.table.contains(FreePayouts, job.name) and not lib.table.contains(FreePayouts, "off_"..job.name)) then
                                if(not totalPayouts[job.name]) then
                                    totalPayouts[job.name] = 0
                                end
                                if((society.balance - (totalPayouts[job.name] + salary)) >= 0) then
                                    totalPayouts[job.name] += salary
                                    xPlayer.addAccountMoney('bank', salary)
                                    xPlayer.showNotification(("Společnost Vám vyplatila %s$."):format(salary), {type = "inform"})
                                else
                                    xPlayer.showNotification(("Společnost nemá na Vaší výplatu."), {type = "inform"})
                                end
                                RegisteredPaychecks[identifier] = os.time() + (60 * 60)
                            else
                                xPlayer.addAccountMoney('bank', salary)
                                xPlayer.showNotification(("Společnost Vám vyplatila %s$."):format(salary), {type = "inform"})
                                RegisteredPaychecks[identifier] = os.time() + (60 * 60)
                            end
                        end
                    else
                        RegisteredPaychecks[identifier] = nil
                    end
                end
            end
        end
        if(next(totalPayouts)) then
            for k, v in pairs(totalPayouts) do
                RemoveSocietyMoney(k, v)
            end
        end
    end, 60000)
end

function GetRemainingTimeUntilNextPaycheck(identifier)
    local remainingTime = 0
    if(RegisteredPaychecks[identifier]) then
        remainingTime = RegisteredPaychecks[identifier] - os.time()
    end
    return remainingTime
end

lib.callback.register("strin_society:getPaycheckRemainingTime", function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    return GetRemainingTimeUntilNextPaycheck(xPlayer?.identifier)
end)

ESX.RegisterCommand("vyplata", "user", function(xPlayer)
    local remainingTime = GetRemainingTimeUntilNextPaycheck(xPlayer.identifier)
    if(remainingTime <= 0) then
        xPlayer.showNotification(("Výplata Vám bude vyplacena každou chvílí!"))
        return
    end
    xPlayer.showNotification(("Do další výplaty zbývá - %s"):format(os.date("%M:%S", remainingTime)))
end)

RegisterNetEvent("esx:playerLoaded", function(playerId, xPlayer)
    RegisteredPaychecks[xPlayer.identifier] = os.time() + (60 * 60)
end)

RegisterNetEvent("playerDropped", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end
    RegisteredPaychecks[xPlayer.identifier] = nil
end)

AddEventHandler("onResourceStart", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        local xPlayers = ESX.GetExtendedPlayers()
        for _, xPlayer in pairs(xPlayers) do
            RegisteredPaychecks[xPlayer.identifier] = os.time() + (60 * 60)
        end
    end
end)