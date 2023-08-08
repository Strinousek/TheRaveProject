local Basket = {}
local Items = Inventory:Items()
local IsShopMenuOpen = false
local IsInVehiclePreview = false
local LastCoords = nil
local CurrentSpawnedVehicle = nil
/*¨
    Basket = {
        [1] = {
            name = "lockpick",
            price = 100,
            count = 10
        }
    }
*/

RegisterNetEvent("strin_jobs:clearBasket", function()
    Basket = {}
    if(IsShopMenuOpen) then
        ESX.UI.Menu.CloseAll()
    end
end)

function OpenShopMenu(shopId)
    local jobName = ESX.PlayerData.job.name
    local shop = Jobs[jobName].Zones.Shops[shopId]
    if(not Jobs[jobName] or not shop) then
        return
    end
    IsShopMenuOpen = true
    local totalPrice = CalculateBasketPrice()
    local totalCount = CalculateBasketCount()
    local elements = {
        {
            label = ([[
                <div style="display: flex; justify-content: space-between; align-items: center">
                    Košík<div>%sx (%s)</div><div>%s$</div>
                </div>
            ]]):format(
                #Basket,
                totalCount,
                totalPrice
            ),
            value = "basket"
        },
        {
            label = ShopLabels[shop.target],
            value = "shop"
        }
    }
    if(#Basket > 0) then
        table.insert(elements, {
            label = ([[
                <div style="display: flex; background-color: green; padding: 8px; color: white;">
                    Potvrdit a zaplatit nákup (%s$)
                </div>
            ]]):format(
                totalPrice
            ),
            value = "confirm"
        })
    end
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), jobName.."_shop_menu", {
        title = "Firemní obchod",
        align = "center",
        elements = elements
    }, function(data, menu)
        menu.close()
        if(data.current.value == "basket") then
            if(#Basket == 0) then
                ESX.ShowNotification("Košík je prázdný!", {type = "error"})
                OpenShopMenu(shopId)
                return
            end
            OpenBasketMenu(shopId)
        elseif(data.current.value == "shop") then
            OpenStocksMenu(shopId)
        elseif(data.current.value == "confirm") then
            TriggerServerEvent("strin_jobs:processBasket", shopId, Basket)
        end
    end, function(data, menu)
        menu.close()
        IsShopMenuOpen = false
        Basket = {}
    end)
end

function OpenStocksMenu(shopId)
    local jobName = ESX.PlayerData.job.name
    local shop = Jobs[jobName].Zones.Shops[shopId]
    local elements = GenerateElementsFromStocks(shop.stocks)
    if(shop.target == "Vehicles") then
        if(LastCoords) then
            while LastCoords do
                Citizen.Wait(0)
            end
        end
        local ped = PlayerPedId()
        LastCoords = GetEntityCoords(ped)
        IsInVehiclePreview = true
        DoScreenFadeOut(500)
        Citizen.CreateThread(function()
            SetEntityInvincible(ped, true)
            SetFocusPosAndVel(VehiclePreviewLocation)
            --SetEntityCoords(ped, LastCoords)
            Citizen.Wait(1000)
            StartPlayerTeleport(PlayerId(), VehiclePreviewLocation)
            while IsPlayerTeleportActive() do
                Citizen.Wait(0)
            end
            DoScreenFadeIn(500)
            CurrentSpawnedVehicle = SpawnVehicle(shop.stocks?[elements[1].id]?.name)
            while true do
                Citizen.Wait(0)
                if(not IsInVehiclePreview) then
                    DoScreenFadeOut(500)
                    FreezeEntityPosition(CurrentSpawnedVehicle, false)
                    if(DoesEntityExist(CurrentSpawnedVehicle)) then
                        DeleteEntity(CurrentSpawnedVehicle)
                    end
                    CurrentSpawnedVehicle = nil
                    SetFocusPosAndVel(LastCoords)
                    --SetEntityCoords(ped, LastCoords)
                    Citizen.Wait(1000)
                    StartPlayerTeleport(PlayerId(), LastCoords)
                    while IsPlayerTeleportActive() do
                        Citizen.Wait(0)
                    end
                    LastCoords = nil  
                    SetEntityLocallyVisible(ped)
                    Citizen.Wait(1000)
                    DoScreenFadeIn(500)
                    SetFocusEntity(ped)
                    break
                end
                FreezeEntityPosition(CurrentSpawnedVehicle, true)
                SetEntityLocallyInvisible(ped)
                DisableAllControlActions(0)
                EnableControlAction(0, 1)
                EnableControlAction(0, 2)
            end
        end)
    end
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), jobName.."_shop_stocks", {
        title = "Firemní obchod",
        align = "center",
        elements = elements
    }, function(data, menu)
        menu.close()
        local input = lib.inputDialog("Množství", {
             {type = "number", default = data.current.value, min = 0, max = 20, required = true }
        })

        if(DoesEntityExist(CurrentSpawnedVehicle)) then
            DeleteEntity(CurrentSpawnedVehicle)
        end

        if(not input) then
            IsInVehiclePreview = false
            OpenStocksMenu(shopId)
            return
        end

        local item = shop.stocks[data.current.id]
        local basketId = GetBasketId(item.name)
        if(input[1] <= 0) then
            if(basketId) then
                Basket[basketId] = nil
                Basket = SanitizeBasket()
                IsInVehiclePreview = false
                OpenStocksMenu(shopId)
                return 
            end
            IsInVehiclePreview = false
            OpenStocksMenu(shopId)
            return
        end

        if(input[1] > 20) then
            input[1] = 20
        end
        
        Basket[basketId or (#Basket+1)] = {
            name = item.name,
            count = input[1],
            price = item.price,
        }
        IsInVehiclePreview = false
        OpenStocksMenu(shopId)
    end, function(data, menu)
        menu.close()
        IsInVehiclePreview = false
        if(DoesEntityExist(CurrentSpawnedVehicle)) then
            DeleteEntity(CurrentSpawnedVehicle)
        end
        for _,v in pairs(menu.data.elements) do
            if(v.id) then
                local item = shop.stocks[v.id]
                local basketId = GetBasketId(item.name)
                if(v.value <= 0 and basketId) then
                    Basket[basketId] = nil
                end
                if(v.value > 0) then
                    Basket[basketId or (#Basket+1)] = {
                        name = item.name,
                        count = v.value,
                        price = item.price,
                    }
                end
            end
        end
        Basket = SanitizeBasket()
        OpenShopMenu(shopId)
    end, function(data, menu)
        if(data.current.id) then
            local item = shop.stocks[data.current.id]
            local basketId = GetBasketId(item.name)
            if(data.current.value <= 0 and basketId) then
                Basket[basketId] = nil
            end
            if(data.current.value > 0) then
                Basket[basketId or (#Basket+1)] = {
                    name = item.name,
                    count = data.current.value,
                    price = item.price,
                }
            end
            Basket = SanitizeBasket()
        end
        if(shop.target == "Vehicles") then
            local model = GetEntityModel(CurrentSpawnedVehicle)
            local displayName = GetDisplayNameFromVehicleModel(model):lower()
            if(displayName == shop.stocks?[data.current.id]?.name) then
                return
            end

            if(DoesEntityExist(CurrentSpawnedVehicle)) then
                DeleteEntity(CurrentSpawnedVehicle)
            end
            CurrentSpawnedVehicle = SpawnVehicle(shop.stocks?[data.current.id]?.name)
        end
    end)
end

function OpenBasketMenu(shopId)
    local jobName = ESX.PlayerData.job.name
    local elements = GenerateElementsFromBasket()
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), jobName.."_shop_basket", {
        title = "Firemní obchod",
        align = "center",
        elements = elements
    }, function(data, menu)
        menu.close()
        if(data.current.value == "clear") then
            Basket = {}
            OpenBasketMenu(shopId)
            return
        end
        local input = lib.inputDialog("Množství", {
             {type = "number", default = Basket[data.current.id].count, min = 0, max = 20, required = true }
        })
        if(not input) then
            OpenBasketMenu(shopId)
            return
        end

        if(input[1] <= 0) then
            Basket[data.current.id] = nil
            Basket = SanitizeBasket()
            ESX.ShowNotification("Položka odebrána", {type = "error"})
            OpenBasketMenu(shopId)
            return
        end

        if(input[1] > 20) then
            input[1] = 20
        end
        
        Basket[data.current.id].count = input[1]
        OpenBasketMenu(shopId)
    end, function(data, menu)
        menu.close()
        for _,v in pairs(menu.data.elements) do
            if(v.id and v.value <= 0) then
                Basket[v.id] = nil
            end
        end
        Basket = SanitizeBasket()
        OpenShopMenu(shopId)
    end, function(data, menu)
        if(data.current.id) then
            Basket[data.current.id].count = tonumber(data.current.value)
        end
    end)
end

function GenerateElementsFromBasket()
    local elements = {}
    for i=1, #Basket do
        local item = Basket[i]
        local itemData = (Items[item.name] ~= nil) and Items[item.name] or {
            label = GetDisplayNameFromVehicleModel(item.name)
        }
        elements[i] = {
            label = ("%s - %s$"):format(
                itemData.label,
                item.price
            ),
            min = 0,
            value = item.count,
            max = 20,
            type = "slider",
            id = i
        }
    end
    elements[#elements + 1] = {
        label = "Vyčistit košík",
        value = "clear"
    }
    return elements
end

function GenerateElementsFromStocks(stocks)
    local elements = {}
    for i=1, #stocks do
        local item = stocks[i]
        local basketId = GetBasketId(item.name)
        item.count = (basketId ~= nil) and Basket[basketId].count or 0
        local itemData = (Items[item.name] ~= nil) and Items[item.name] or {
            label = GetDisplayNameFromVehicleModel(item.name)
        }
        elements[i] = {
            label = ("%s - %s$"):format(
                itemData.label,
                item.price
            ),
            min = 0,
            value = item.count,
            max = 20,
            type = "slider",
            id = i
        }
    end
    return elements
end

function GetBasketId(stockName)
    local basketId = nil
    for i=1, #Basket do
        if(Basket[i].name == stockName) then
            basketId = i
        end
    end
    return basketId
end

function SanitizeBasket()
    local newBasket = {}
    for i=1, #Basket do
        if(Basket[i]) then
            newBasket[#newBasket+1] = Basket[i]
        end
    end
    return newBasket
end

function SpawnVehicle(model)
    if(not model) then
        IsInVehiclePreview = false
        ESX.ShowNotification("Neexistující model.", {type = "error"})
        ESX.UI.Menu.CloseAll()
        return false
    end
    local ped = PlayerPedId()
    local hash = LoadVehicleModel(model)
    local vehicle = CreateVehicle(hash, VehiclePreviewLocation, 90.0, false)
    TaskWarpPedIntoVehicle(ped, vehicle, -1)
    return vehicle
end

function LoadVehicleModel(model)
    local hash = GetHashKey(model)
    local p = promise.new()
    if(not HasModelLoaded(hash)) then
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Citizen.Wait(0)
        end
        p:resolve(hash)
    elseif(HasModelLoaded(hash)) then
        p:resolve(hash)
    end
    return Citizen.Await(p)
end

function CalculateBasketCount()
    local count = 0
    for i=1, #Basket do
        local item = Basket[i]
        count += item.count 
    end
    return count
end

function CalculateBasketPrice()
    local price = 0
    for i=1, #Basket do
        local item = Basket[i]
        price += (item.price * item.count) 
    end
    return price
end

AddEventHandler("onResourceStop", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        if(LastCoords) then
            if(DoesEntityExist(CurrentSpawnedVehicle)) then
                DeleteEntity(CurrentSpawnedVehicle)
            end
            SetFocusPosAndVel(LastCoords)
            StartPlayerTeleport(PlayerId(), VehiclePreviewLocation)
            while IsPlayerTeleportActive() do
                Citizen.Wait(0)
            end
            local ped = PlayerPedId()
            SetEntityInvincible(ped, false)
            SetEntityLocallyVisible(ped)
            Citizen.Wait(500)
            SetFocusEntity(ped)
        end
    end
end)