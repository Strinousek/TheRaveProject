--local CachedPhoneBooths = {}

local Inventory = exports.ox_inventory
local Items = Inventory:Items()

local DEALER_LOCATIONS = {
    {
        dealer = {
            coords = vector3(-182.58978271484, 6056.4702148438, 30.816644668579),
            heading = 336.2
        },
        vehicle = {
            coords = vector3(-187.31819152832, 6058.1831054688, 31.170780181885),
            heading = 104.34
        }
    },
    {
        dealer = {
            coords = vector3(81.413635253906, 3756.4423828125, 39.754936218262),
            heading = 187.45
        },
        vehicle = {
            coords = vector3(85.702934265137, 3758.5979003906, 39.753288269043),
            heading = 342.88
        }    
    },
    {
        dealer = {
            coords = vector3(838.71228027344, 2126.7336425781, 52.296085357666),
            heading = 34.88
        },
        vehicle = {
            coords = vector3(833.83752441406, 2123.3911132813, 52.294673919678),
            heading = 386.28
        } 
    },
    {
        dealer = {
            coords = vector3(-814.29412841797, -1311.4145507813, 5.0003843307495),
            heading = 171.27
        },
        vehicle = {
            coords = vector3(-810.46826171875, -1309.4539794922, 5.0003824234009),
            heading = 19.68
        } 
    },
    {
        dealer = {
            coords = vector3(-602.78485107422, -2180.6879882813, 5.9929986000061),
            heading = 31.62
        },
        vehicle = {
            coords = vector3(-605.70043945313, -2183.5478515625, 5.992995262146),
            heading = 182.49
        } 
    },
    {
        dealer = {
            coords = vector3(93.901741027832, -2191.4367675781, 6.0069231987),
            heading = 276.57
        },
        vehicle = {
            coords = vector3(94.95719909668, -2187.4567871094, 5.9529814720154),
            heading = 236.1
        }
    },
    {
        dealer = {
            coords = vector3(1277.9505615234, -3327.1120605469, 5.9015965461731),
            heading = 103.35
        },
        vehicle = {
            coords = vector3(1279.724609375, -3332.9719238281, 5.9015884399414),
            heading = 59.05
        }
    },

}

local DEALER_STOCK_ROTATIONS = {
    {
        { name = "WEAPON_SWITCHBLADE", price = 500, count = 5 },
        { name = "WEAPON_PISTOL", price = 3800, count = 15 },
  
        { name = "weapon_microsmg", price = 26000, count = {1 , 3} },
        { name = "weapon_pistol50", price = 9500, count = {2 , 6} },
        { name = "weapon_heavypistol", price = 9500, count = {2 , 6} },
  
        { name = "ammo-9", price = 50, count = 2500 },
        { name = "ammo-50", price = 80, count = 500 },
        { name = "ammo-rifle", price = 50, count = 900 },
        { name = "ammo-shotgun", price = 50, count = 300 },
        { name = "ammo-45", price = 50, count = 100 },
    },
    --#################VIETNAMSKÝ TÝDEN############################
    {
        { name = "WEAPON_SWITCHBLADE", price = 500, count = 5 },
        { name = "WEAPON_PISTOL", price = 3800, count = 10 },
  
        { name = "weapon_mg", price = 65000, count = 1 },
        { name = "weapon_minismg", price = 26500, count = {1 , 3} },
        { name = "weapon_revolver_mk2", price = 10500, count = {2 , 4} },
        { name = "weapon_tacticalrifle", price = 35000, count = {1 , 2} },
  
        { name = "ammo-9", price = 50, count = 2500 },
        { name = "ammo-50", price = 80, count = 500 },
        { name = "ammo-rifle", price = 50, count = 900 },
        { name = "ammo-shotgun", price = 50, count = 300 },
        { name = "ammo-45", price = 50, count = 100 },
    },
    --#####################TÝDEN TEROSITY########################
    {
        { name = "WEAPON_SWITCHBLADE", price = 500, count = 20 },
        { name = "WEAPON_PISTOL", price = 3800, count = 20 },
  
        { name = "weapon_machinepistol", price = 20500, count = {1 , 3} },
        { name = "weapon_sns", price = 1850, count = {5 , 10} },
        { name = "weapon_compactrifle", price = 35000, count = 1 },
        { name = "weapon_assaultrifle", price = 35500, count = {1 , 2} },
  
        { name = "ammo-9", price = 50, count = 2500 },
        { name = "ammo-50", price = 80, count = 500 },
        { name = "ammo-rifle", price = 50, count = 900 },
        { name = "ammo-shotgun", price = 50, count = 300 },
        { name = "ammo-45", price = 50, count = 100 },
    },
     --################TÝDEN RÁDOBY POLICISTY######################
    {
        { name = "WEAPON_SWITCHBLADE", price = 500, count = 20 },
        { name = "WEAPON_PISTOL", price = 3800, count = 20 },
  
        { name = "weapon_nightstick", price = 320, count = {1, 10} },
        { name = "weapon_smg", price = 26000, count = {1, 3} },
        { name = "weapon_pistol_mk2", price = 6500, count = {2, 6} },
        { name = "weapon_carbinerifle", price = 40000, count = {1, 2} },
  
        { name = "ammo-9", price = 50, count = 2500 },
        { name = "ammo-50", price = 80, count = 500 },
        { name = "ammo-rifle", price = 50, count = 900 },
        { name = "ammo-shotgun", price = 50, count = 300 },
        { name = "ammo-45", price = 50, count = 100 },
    },
       --###################MAFIÁNSKÝ TÝDEN##################
    {
        { name = "WEAPON_SWITCHBLADE", price = 500, count = 20 },
        { name = "WEAPON_PISTOL", price = 3800, count = 20 },
  
        { name = "weapon_bat", price = 200, count = {1, 10} },
        { name = "weapon_vintagepistol", price = 6500, count = {2, 6} },
        { name = "weapon_dbshotgun", price = 35000, count = {1, 2} },
        { name = "weapon_gusenberg", price = 30000, count = {1, 3} },
        --{ name = "weapon_molotov", price = 1000, count = {1, 16} },
  
        { name = "ammo-9", price = 50, count = 2500 },
        { name = "ammo-50", price = 80, count = 500 },
        { name = "ammo-rifle", price = 50, count = 900 },
        { name = "ammo-shotgun", price = 50, count = 300 },
        { name = "ammo-45", price = 50, count = 100 },
    },
}

local Base = exports.strin_base

/*for i=1, #PHONE_BOOTHS_MODELS do
    Base:RegisterWhitelistedEntity(PHONE_BOOTHS_MODELS[i])
end*/

Base:RegisterWebhook("DEFAULT", "https://discord.com/api/webhooks/1136013216946868355/EOYEqSQucbN6HrYbhDCg2QCw8NFG0AdK-5JB3d3jJRCLh3Ea6K1KK3zd50T8t18l8yBl")


local MinuteInMilliseconds = 60 * 1000
local AutomaticRestockTimer = 60 * MinuteInMilliseconds
local RestockTimer = 30 * MinuteInMilliseconds

local CurrentDealer = {
    state = "INACTIVE",
}
/*
    INACTIVE - dealer is not spawned, but can get spawned
    RESTOCKING - dealer is despawned, no stocks left
    ACTIVE - dealer is spawned, has stock
*/

function SpawnDealer()
    math.randomseed(GetGameTimer() + math.random(1, 99999))
    local location = CurrentDealer?.location or DEALER_LOCATIONS[math.random(1, #DEALER_LOCATIONS)]

    CurrentDealer.location = location

    local vehicleModel = CurrentDealer?.vehicleModel or DEALER_VEHICLE_MODELS[math.random(1, #DEALER_VEHICLE_MODELS)]

    local dealerModel = CurrentDealer?.dealerModel or DEALER_MODELS[math.random(1, #DEALER_MODELS)]

    local vehicle = CreateVehicleServerSetter(vehicleModel, "automobile", location.vehicle.coords, location.vehicle.heading)
    FreezeEntityPosition(vehicle, true)
    SetVehicleNumberPlateText(vehicle, "BIGBOSS")
    SetVehicleDoorsLocked(vehicle, 2)
    CurrentDealer.vehicleModel = vehicleModel
    CurrentDealer.vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)

    local ped = CreatePed(0, dealerModel, location.dealer.coords, location.dealer.heading, true, true)
    Entity(ped).state.recentlyOffered = true -- strin_drugs weed shit
    SetPedConfigFlag(ped, 17, true)
    SetPedConfigFlag(ped, 294, true)
    FreezeEntityPosition(ped, true)
    CurrentDealer.dealerModel = dealerModel
    CurrentDealer.pedNetId = NetworkGetNetworkIdFromEntity(ped)

    CurrentDealer.state = "ACTIVE"
end

function DespawnDealer()
    local ped = NetworkGetEntityFromNetworkId(CurrentDealer?.pedNetId)
    local vehicle = NetworkGetEntityFromNetworkId(CurrentDealer?.vehicleNetId)
    FreezeEntityPosition(ped, false)
    SetVehicleDoorsLocked(vehicle, 0)
    TaskEnterVehicle(ped, vehicle, 1.0, -1, 1.0, 1, false)

    local distance = #(GetEntityCoords(ped) - GetEntityCoords(vehicle))
    Citizen.Wait(2500 * (distance / 2))

    CurrentDealer.state = "RESTOCKING"
    DeleteEntity(ped)
    DeleteEntity(vehicle)
    
    CurrentDealer.pedNetId = nil
    CurrentDealer.vehicleNetId = nil
    CurrentDealer.location = nil
    CurrentDealer.vehicleModel = nil
    CurrentDealer.dealerModel = nil
end

function GenerateDealerStocks()
    math.randomseed(GetGameTimer() + math.random(1, 99999))
    local stocks = lib.table.deepclone(DEALER_STOCK_ROTATIONS[math.random(1, #DEALER_STOCK_ROTATIONS)])
    for k,v in pairs(stocks) do
        if(not v.name:find("ammo")) then
            v.name = v.name:upper()
        end
        math.randomseed(os.time() + math.random(1, 99999))
        v.count = type(v.count) == "table" and math.random(v.count[1], v.count[2]) or v.count
    end
    return stocks
end

function StartRestocking(outOfStock)
    if(outOfStock) then
        if(CurrentDealer.state == "ACTIVE") then
            DespawnDealer()
            Citizen.Wait(250)
            TriggerClientEvent("strin_gundealer:receiveData", -1, CurrentDealer)
            SetTimeout(RestockTimer, function()
                CurrentDealer.state = "INACTIVE"
            end)
        end
        return
    end
    SetTimeout(AutomaticRestockTimer, function()
        if(CurrentDealer.state == "ACTIVE") then
            DespawnDealer()
            Citizen.Wait(250)
            TriggerClientEvent("strin_gundealer:receiveData", -1, CurrentDealer)
            SetTimeout(RestockTimer, function()
                CurrentDealer.state = "INACTIVE"
            end)
        end
    end)
end

AddEventHandler("entityRemoved", function(entity)
    local netId = NetworkGetNetworkIdFromEntity(entity)
    if((netId == CurrentDealer?.pedNetId) or (netId == CurrentDealer?.vehicleNetId)) then
        if(CurrentDealer.state == "ACTIVE") then
            local otherEntity = NetworkGetEntityFromNetworkId(
                netId == CurrentDealer?.pedNetId and
                CurrentDealer?.vehicleNetId or 
                CurrentDealer?.pedNetId
            )
            DeleteEntity(otherEntity)
            SpawnDealer()
        end
    end
end)

/*AddEventHandler("entityCreating", function(entity)
    local entityType = GetEntityType(entity)
    if(entityType ~= 3) then
        return
    end

    local model = GetEntityModel(entity)
    if(not lib.table.contains(PHONE_BOOTHS_MODELS, model)) then
        return
    end

    local coords = GetEntityCoords(entity)

    local foundRecord = false
    for k,v in pairs(CachedPhoneBooths) do
        if(lib.table.matches(v, coords)) then
            foundRecord = true
            break
        end
    end

    if(foundRecord) then
        CancelEvent()
        return
    end

    table.insert(CachedPhoneBooths, coords)
    CancelEvent()
end)*/

RegisterNetEvent("strin_gundealer:requestLocation", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    local isNearPhoneBooth = IsNearPhoneBooth(_source)
    if(not isNearPhoneBooth) then
        xPlayer.showNotification("Nejste poblíž žádné telefonní budky!", { type = "error" })
        return
    end

    local money = xPlayer.getMoney()
    if((money - DEALER_LOCATION_PRICE) < 0) then
        xPlayer.showNotification("Nemáte dostatek peněz!", { type = "error" })
        return
    end

    if(CurrentDealer.state == "RESTOCKING") then
        local landlineFee = math.floor(DEALER_LOCATION_PRICE / 3 + 0.5)
        xPlayer.removeMoney(landlineFee)
        xPlayer.showNotification(([[
            Dealer není přítomen, zkuste to příště.<br/>
            Bylo Vám naúčtováno %s$ za využití linky.
        ]]):format(ESX.Math.GroupDigits(landlineFee)), { type = "error" })
        return
    end

    xPlayer.removeMoney(DEALER_LOCATION_PRICE)
    if(CurrentDealer.state == "INACTIVE") then
        SpawnDealer()
        Citizen.Wait(200)
        CurrentDealer.stocks = GenerateDealerStocks()
        TriggerClientEvent("strin_gundealer:receiveData", -1, CurrentDealer, _source)
        TriggerEvent("gcPhone:tchat_addMessage", "blackmarket", "🔫 B1GBO$$ IN THE TOWN 🔥 VŠEHOCHUŤ ZBRANÍ 🦅 ZA HODINU PADÁME DO HAJZLU TAK ŠUP!")
        StartRestocking(false)
    elseif(CurrentDealer.state == "ACTIVE") then
        TriggerClientEvent("strin_gundealer:receiveData", _source, CurrentDealer, _source)
    end
end)

RegisterNetEvent("strin_gundealer:buyStocks", function(stocks)
    if(type(stocks) ~= "table" or not next(stocks)) then
        return
    end

    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    local isNearGundealer = IsNearGundealer(_source, 15.0)
    if(not isNearGundealer) then
        xPlayer.showNotification("Nejste poblíž dealera zbraní!", { type = "error" })
        return
    end
    
    local validatedStocks = ValidateStocks(CurrentDealer.stocks, stocks)
    if(not validatedStocks) then
        xPlayer.showNotification("Neplatná nabídka!", { type = "error" })
        return
    end

    local givenItems = {}
    local totalCost = 0
    local failedReason = nil
    local stocksToRemove = {}
    for k,v in pairs(validatedStocks) do
        for i=1, v.amount do
            local money = xPlayer.getMoney()
            if((money - v.price) < 0) then
                failedReason = "Nedostatek peněz"
                break
            end
            if(not Inventory:CanCarryWeight(_source, Items[v.name].weight)) then
                failedReason = "Moc těžký objekt"
                break
            end
            local success, response = Inventory:AddItem(_source, v.name, 1)
            if(not success) then
                failedReason = response == "inventory_full" and "Plný inventář" or response
                break
            end
            if(not response[1]) then
                failedReason = "Neexistující item"
                break
            end
            local response = response[1]
            response.metadata.registered = false
            Inventory:SetMetadata(_source, response.slot, response.metadata)
            table.insert(givenItems, response)
            xPlayer.removeMoney(v.price)
            totalCost += v.price
        end
        if(failedReason) then
            break
        end
    end

    if(failedReason) then
        xPlayer.showNotification("Napříč koupí nastala chyba - "..failedReason, { type = "error" })
        if(not next(givenItems)) then
            return
        end
    end

    for k,v in pairs(givenItems) do
        stocksToRemove[v.name] = stocksToRemove[v.name] and v.count + stocksToRemove[v.name] or v.count
    end

    local boughtStocks = {}
    local remainingStocks = 0
    for k,v in pairs(CurrentDealer.stocks) do
        for stockName, stockAmount in pairs(stocksToRemove) do
            if(v.name == stockName) then
                v.count -= stockAmount
                table.insert(boughtStocks, v.name:upper()..": "..stockAmount.."x")
                break
            end
        end
        remainingStocks += v.count
    end
    
    Base:DiscordLog("DEFAULT", "THE RAVE PROJECT - GUN DEALER", {
        { name = "Jméno hráče", value = ESX.SanitizeString(GetPlayerName(_source)) },
        { name = "Identifikace hráče", value = xPlayer.identifier },
        { name = "Nákup", value = table.concat(boughtStocks, "\n") },
        { name = "Cena nákupu", value = ESX.Math.GroupDigits(totalCost).."$"  },
        { name = "Chyba při nákupu", value = failedReason or "Žádná"  },
    }, {
        fields = true
    })
    
    xPlayer.showNotification(("Zakoupil/a jste zbraně v hodnotě %s$"):format(ESX.Math.GroupDigits(totalCost)))

    if(remainingStocks <= 0) then
        StartRestocking(true)
    end
end)

function ValidateStocks(dealerStocks, stocks)
    local validatedStocks = {}
    for k,v in pairs(stocks) do
        if((v?.name and v?.amount) and (type(v?.name) == "string" and type(v?.amount) == "number") and math.floor(v?.amount) > 0) then
            for _,v2 in pairs(dealerStocks) do
                if(v.name == v2.name and (v2.count - v.amount >= 0)) then
                    table.insert(validatedStocks, { name = v?.name, amount = math.floor(v?.amount), price = v2.price })
                end
            end
        end
    end
    return next(validatedStocks) and validatedStocks or nil
end

lib.callback.register("strin_gundealer:requestStocks", function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return false
    end

    local isNearGundealer = IsNearGundealer(_source, 15.0)
    if(not isNearGundealer) then
        xPlayer.showNotification("Nejste poblíž dealera zbraní!", { type = "error" })
        return false
    end

    return CurrentDealer.stocks
end)

AddEventHandler("esx:playerLoaded", function(playerId)
    if(CurrentDealer.state == "ACTIVE") then
        TriggerClientEvent("strin_gundealer:receiveData", playerId, CurrentDealer)
    end
end)

function IsNearPhoneBooth(playerId)
    /*local ped = GetPlayerPed(playerId)
    local coords = GetEntityCoords(ped)

    local phoneBoothIndex = nil
    local distanceToPhoneBooth = 15000.0

    for k,v in pairs(CachedPhoneBooths) do
        local distance = #(coords - v)
        if(distance < distanceToPhoneBooth) then
            phoneBoothIndex = k
            distanceToPhoneBooth = distance
        end
    end
    return (distanceToPhoneBooth < 10) and phoneBoothIndex or nil*/
    local isNearPhoneBooth = lib.callback.await("strin_gundealer:isNearPhoneBooth", playerId)
    return isNearPhoneBooth
end

function IsNearGundealer(playerId, distanceToleration)
    local isNearGundealer = false
    if(CurrentDealer?.location?.dealer?.coords) then
        local ped = GetPlayerPed(playerId)
        local coords = GetEntityCoords(ped)
        local distance = #(coords - CurrentDealer?.location?.dealer?.coords)
        if(distance < distanceToleration) then
            isNearGundealer = true
        end
    end
    return isNearGundealer
end

AddEventHandler("onResourceStop", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        if(CurrentDealer?.pedNetId) then
            local entity = NetworkGetEntityFromNetworkId(CurrentDealer?.pedNetId)
            DeleteEntity(entity)
        end
        if(CurrentDealer?.vehicleNetId) then
            local entity = NetworkGetEntityFromNetworkId(CurrentDealer?.vehicleNetId)
            DeleteEntity(entity)
        end
    end
end)