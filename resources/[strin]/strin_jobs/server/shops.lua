local Items = Inventory:Items()
local VehicleShop = exports.strin_vehicleshop

RegisterNetEvent("strin_jobs:processBasket", function(shopId, basket)
    local _source = source

    if(type(shopId) ~= "number" or type(basket) ~= "table") then
        return
    end

    if(not next(basket)) then
        return
    end

    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    local job = xPlayer.getJob()
    if(not Jobs[job.name] or not Jobs[job.name].Zones?.Shops or not Jobs[job.name].Zones?.Shops?[shopId]) then
        xPlayer.showNotification("Požadovaný firemní obchod neexistuje!", {type = "error"})
        return
    end

    if(job.grade_name ~= "boss" and job.grade_name ~= "manager") then
        xPlayer.showNotification("Nemáte dostatečně oprávnění!", {type = "error"})
        return
    end
    
    local isNearShop = IsPlayerNearShop(_source, job.name, shopId)
    if(not isNearShop) then
        xPlayer.showNotification("Nejste dostatečně blízko!", {type = "error"})
        return
    end

    local society = Society:GetSociety(job.name)
    if(not society) then
        xPlayer.showNotification("Vaše společnost není zařazena v systému!", {type = "error"})
        return
    end

    local shop = Jobs[job.name].Zones.Shops[shopId]
    local basket = ProcessBasket(basket, shop.stocks)
    if(not next(basket)) then
        xPlayer.showNotification("Košík nebyl správně zpracován!", {type = "error"})
        return
    end

    local totalPrice = GetTotalBasketPrice(basket)
    if((society.balance - totalPrice) < 0) then
        xPlayer.showNotification(([[
            Vaše společnost nemá tolik peněz!<br/>
            Rozpočet: %s$<br/>
            Cena košíku: %s$<br/>
            Nedoplatek: %s$<br/>
        ]]):format(
            society.balance,
            totalPrice,
            totalPrice - society.balance
        ), {type = "error", duration = 10000})
        return
    end

    if(shop.target == "Vehicles") then
        xPlayer.showNotification("Probíhá transakce...", {type = "inform", duration = 5000})
        local addedVehicles = GenerateVehiclesFromBasket(job.name, basket)
        Society:RemoveSocietyMoney(job.name, totalPrice)
        local receiptText = GenerateBasketReceipt(totalPrice, addedVehicles)
        xPlayer.showNotification(([[
            Váš nákup byl úspěšný!
            Seznam zakoupených vozidel:<br/>
            %s
        ]]):format(receiptText), {type = "success"})
        TriggerClientEvent("strin_jobs:clearBasket", _source)
        return
    end

    local totalSpent, addedItems = AddBasketItemsToStash(job.name, basket, shop.target)
    xPlayer.showNotification("Probíhá transakce...", {type = "inform"})
    if(totalSpent ~= totalPrice) then
        if(#addedItems == 0) then
            xPlayer.showNotification([[
                Úložiště je buď přetížené nebo plné.
                Prosíme uvolněte místo a proveďte nákup znovu.
            ]], {type = "error"})
            return
        end

        Society:RemoveSocietyMoney(job.name, totalSpent)
        local receiptText = GenerateBasketReceipt(totalSpent, addedItems)
        xPlayer.showNotification(([[
            Úložiště je buď přetížené nebo plné.
            Z košíku byly naúčtovány pouze některé předměty:<br/>
            %s
        ]]):format(receiptText), {type = "inform"})
        return
    end

    Society:RemoveSocietyMoney(job.name, totalPrice)
    local receiptText = GenerateBasketReceipt(totalPrice, basket)
    xPlayer.showNotification(([[
        Váš nákup byl úspěšný!
        Seznam zakoupených předmětů:<br/>
        %s
    ]]):format(receiptText), {type = "success"})
    TriggerClientEvent("strin_jobs:clearBasket", _source)
end)

function IsPlayerNearShop(playerId, jobName, shopId)
    if(not Jobs[jobName].Zones?.Shops) then
        return false
    end
    local ped = GetPlayerPed(playerId)
    local coords = GetEntityCoords(ped)
    local shop = Jobs[jobName].Zones?.Shops[shopId]
    if(not shop) then
        return false
    end
    return (#(coords - shop.coords) < 12.5)
end

function ProcessBasket(basket, stocks)
    local newBasket = {}
    for i=1, #basket do
        local item = basket[i]
        if(not item?.count or not item?.name or not IsStockValid(item?.name, stocks)) then
            return {}
        end
        if(item.count > 20) then
            item.count = 20
        end
        if(item.count > 0) then
            local stock = GetStockByStockName(item?.name, stocks)
            newBasket[#newBasket + 1] = {
                name = item.name,
                count = item.count,
                price = stock.price
            }
        end
    end
    return newBasket
end

function IsStockValid(stockName, stocks)
    if(not stocks) then
        return false
    end
    local isValid = false
    for j=1, #stocks do
        if(stocks[j].name == stockName) then
            isValid = true
        end
    end
    return isValid
end

function GetTotalBasketPrice(basket)
    local totalPrice = 0
    for i=1, #basket do
        local item = basket[i]
        totalPrice += (item.count * item.price)
    end
    return totalPrice
end

function GetStockByStockName(stockName, stocks)
    if(not stocks) then
        return nil
    end
    local stock = nil
    for j=1, #stocks do
        if(stocks[j].name == stockName) then
            stock = stocks[j]
        end
    end
    return stock
end

function AddBasketItemsToStash(jobName, basket, stashType)
    local stashId = stashType == "Armories" and Formats.Armory.Id:format(jobName) or Formats.Storage.Id:format(jobName)
    local totalSpent = 0
    local addedItems = {}
    for basketId, item in pairs(basket) do
        if(Inventory:CanCarryItem(stashId, item.name, item.count)) then
            local metadata = nil
            local isGhost = false
            if(item.name:find("WEAPON_") and Items[item.name].ammoname) then
                if(lib.table.contains(LawEnforcementJobs, jobName)) then
                    metadata = { registered = jobName, serial = "POL" }
                else
                    metadata = { registered = true }
                    isGhost = true
                end
            end
            success, response = Inventory:AddItem(stashId, item.name, item.count, metadata)
            if(not success) then
                break
            end
            if(isGhost) then
                for i=1, #response do
                    response[i].metadata.registered = false
                    Inventory:SetMetadata(stashId, response[i].slot, response[i].metadata)
                end
            end
            totalSpent += (item.count * item.price)
            addedItems[#addedItems + 1 ] = { name = item.name, count = item.name, item.count, price = item.price }
        end
    end
    return totalSpent, addedItems
end

function GenerateVehiclesFromBasket(jobName, basket)
    local addedVehicles = {}
    for _,v in pairs(basket) do
        for i=1, v.count do
            VehicleShop:GenerateVehicle(nil, v.name, "car", jobName)
        end
        v.label = v.name
        addedVehicles[#addedVehicles + 1] = v
    end
    return addedVehicles
end

function GenerateBasketReceipt(totalSpent, addedItems)
    local texts = {}
    for i=1, #addedItems do
        local addedItem = addedItems[i]
        texts[#texts + 1] = ([[
            %s - %sx - %s$
        ]]):format(
            Items[addedItem.name]?.label or addedItem.label,
            addedItem.count,
            addedItem.count * addedItem.price
        )
    end
    texts[#texts + 1] = ("Celková úhrada - %s$"):format(totalSpent)
    return table.concat(texts, "<br/>")
end