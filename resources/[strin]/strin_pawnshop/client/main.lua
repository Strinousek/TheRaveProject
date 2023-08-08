Target = exports.ox_target
Items = Inventory:Items()
PawnShopBlips = {}

Citizen.CreateThread(function()
    for k,v in pairs(PAWNSHOPS) do
        PawnShopBlips[k] = CreatePawnShopBlip(v.coords)
        Target:addSphereZone({
            coords = v.coords,
            distance = 2.0,
            options = {
                {
                    label = "Zastavárna",
                    onSelect = function()
                        OpenPawnShopMenu()
                    end
                }
            }
        })
    end
end)

function OpenPawnShopMenu()
    local stocks, secondsUntilRestock = lib.callback.await("strin_pawnshop:getStocks", false)
    if(not stocks or not next(stocks)) then
        if(secondsUntilRestock) then
            ESX.ShowNotification(("Tato zastavárna již nevykupuje. Obnovení za %s sekund."):format(secondsUntilRestock), { type = "error" })
        end
        return
    end
    local elements = {}
    for k,v in pairs(stocks) do
        local count = Inventory:GetItemCount(v.name)
        table.insert(elements, {
            label = Items[v.name].label.." - "..ESX.Math.GroupDigits(v.price).."$ / 1ks",
            stockName = v.name,
            min = 0,
            value = count > v.max and v.max or count,
            max = v.max,
            type = "slider"
        })
    end
    table.insert(elements, {
        label = "Potvrdit prodej",
        value = "submit"
    })
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "pawnshop_menu", {
        title = "Zastavárna",
        align = "center",
        elements = elements
    }, function(data, menu)
        menu.close()
        if(data.current.value == "submit") then
            local items = {}
            for k,v in pairs(data.elements) do
                v.value = tonumber(v.value)
                if(v.value and v.value > 0) then
                    table.insert(items, { name = v.stockName, amount = v.value})
                end
            end
            if(not next(items)) then
                OpenPawnShopMenu()
                return
            end 
            TriggerServerEvent("strin_pawnshop:sellStocks", items)
            return
        end
        OpenPawnShopMenu()
    end, function(data, menu)
        menu.close()
    end)
end

function CreatePawnShopBlip(coords)
    local blip = AddBlipForCoord(coords)
    SetBlipDisplay(blip, 2)
    SetBlipSprite(blip, 642)
    SetBlipColour(blip, 51)
    SetBlipScale(blip, 0.6)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("<FONT FACE='Righteous'>Zastavárna</FONT>")
    EndTextCommandSetBlipName(blip)
    return blip
end

AddEventHandler("onResourceStop", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        for _,v in pairs(PawnShopBlips) do
            if(v and DoesBlipExist(v)) then
                RemoveBlip(v)
            end
        end
    end
end)