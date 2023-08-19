local Target = exports.ox_target
local VehicleShopNPCs = {}
local VehicleShopBlips = {}
local IsInVehicleShop = false

Citizen.CreateThread(function()
    for shopId, shop in pairs(VehicleShops) do
        VehicleShopBlips[shopId] = CreateVehicleShopBlip(shop)
        local shopPoint = lib.points.new({
            coords = shop.coords,
            distance = 20,
        })
        function shopPoint:onEnter()
            if(not VehicleShopNPCs[shopId] or not DoesEntityExist(VehicleShopNPCs[shopId])) then
                VehicleShopNPCs[shopId] = CreateCarDealerNPC(shop)
                Target:addLocalEntity(VehicleShopNPCs[shopId], {
                    {
                        label = "Vzít si katalog",
                        distance = 1.5,
                        onSelect = function()
                            OpenVehicleShop(shop, shopId)
                        end,
                        canInteract = function()
                            return DoesEntityExist(VehicleShopNPCs[shopId])
                        end,
                    }
                })
            end
        end
        function shopPoint:onExit()
            if(VehicleShopNPCs[shopId] or DoesEntityExist(VehicleShopNPCs[shopId])) then
                DeleteEntity(VehicleShopNPCs[shopId])
                VehicleShopNPCs[shopId] = nil
            end
        end
    end
end)

RegisterCommand("pdm", function()
    OpenVehicleShop(VehicleShops["PDM"], "PDM")
end)

function OpenVehicleShop(shop, shopId)
    SetNUIStatus(true)
    local convertedCatalog = ConvertVehicleShopCatalog(shop.catalog)
    SendNUIMessage({
        action = "loadShop",
        catalog = convertedCatalog,
        shop = shop,
    })
end

function CreateVehicleShopBlip(shop)
    local blip = AddBlipForCoord(shop.coords)
    SetBlipDisplay(blip, 2)
	SetBlipSprite(blip, shop.blip.sprite)
	SetBlipColour(blip, shop.blip.color)
	SetBlipScale(blip, 1.0)
    SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('<FONT FACE="Righteous">'..shop.title..'</FONT>')
	EndTextCommandSetBlipName(blip)
    return blip
end

function ConvertVehicleShopCatalog(catalog)
    local convertedVehicles = {}
    local convertedCategories = {}
    for category, v in pairs(catalog) do
        convertedCategories[category] = v.label
        for i=1, #v.vehicles do
            local hash = GetHashKey(v.vehicles[i].name)
            local displayName = GetDisplayNameFromVehicleModel(hash)
            local vehicleLabel = GetLabelText(displayName)
            table.insert(convertedVehicles, {
                id = i,
                name = v.vehicles[i].name,
                label = vehicleLabel == "NULL" and displayName or vehicleLabel,
                hash = hash,
                price = v.vehicles[i].price,
                category = category
            })
        end
    end
    return {
        categories = convertedCategories,
        vehicles = convertedVehicles
    }
end

function SetNUIStatus(display)
    SetNuiFocus(display, display)
    IsInVehicleShop = display
end

RegisterNUICallback("hideShop", function(_, cb)
    SetNUIStatus(false)
    SendNUIMessage({
        action = "hideShop"
    })
    cb("Ok")
end)

RegisterNUICallback("buyVehicle", function(data, cb)
    SetNUIStatus(false)
    SendNUIMessage({
        action = "hideShop"
    })
    local elements = {
        { label = "Zakoupit vozidlo", value = "buy" },
        { label = "Vrátit se do katalogu", value = "back" },
    }
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "buy_vehicle", {
        title = data.label.." - "..FormatPrice(data.price).."$",
        align = "center",
        elements = elements,
    }, function(menuData, menu)
        menu.close()
        if(menuData.current.value == "buy") then
            TriggerServerEvent("strin_vehicleshop:buyVehicle", data.name)
        elseif(menuData.current.value == "back") then
            local shopId = GetNearestVehicleShopId()
            if(shopId) then
                OpenVehicleShop(VehicleShops[shopId], shopId)
            end
        end
    end, function(menuData, menu)
        menu.close()
    end)
    cb("Ok")
end)

function GetNearestVehicleShopId()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local shopId, distance = nil, 15000.0
    for k,v in pairs(VehicleShops) do
        local distanceToShop = #(coords - v.coords)
        if(distanceToShop < distance) then
            shopId = k
            distance = distanceToShop
        end
    end
    return (distance < 15) and shopId or nil
end

function CreateCarDealerNPC(shop)
    RequestModel(VehicleShopNPC)
    while not HasModelLoaded(VehicleShopNPC) do
        Citizen.Wait(100)
    end
    local _, groundZ = GetGroundZFor_3dCoord(shop.coords.x, shop.coords.y, shop.coords.z, 0)
    local ped = CreatePed(3, VehicleShopNPC, shop.coords.x, shop.coords.y, groundZ, shop.heading, false, true)
    SetPedDefaultComponentVariation(ped)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedDiesWhenInjured(ped, false)
    SetEntityInvincible(ped, true)
    SetPedCanPlayAmbientAnims(ped, true)
    FreezeEntityPosition(ped, true)
    return ped
end

function FormatPrice(price)
    local i, j, minus, int, fraction = tostring(price):find('([-]?)(%d+)([.]?%d*)')
    int = int:reverse():gsub("(%d%d%d)", "%1,")
    return minus .. int:reverse():gsub("^,", "") .. fraction
end

function GetCatalog()
    return AllBuyableVehicles
end

exports("GetCatalog", GetCatalog)

function GetVehiclePrice(vehicleModelName)
    local price = nil
    for category,vehicles in pairs(AllBuyableVehicles) do
        for _,vehicle in pairs(vehicles) do
            if(vehicle.name == vehicleModelName) then
                price = vehicle.price
                break
            end
        end
    end
    return price
end

exports("GetVehiclePrice", GetVehiclePrice)

AddEventHandler("onResourceStop", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        for _,blip in pairs(VehicleShopBlips) do
            if(DoesBlipExist(blip)) then
                RemoveBlip(blip)
            end
        end
    end
end)
  