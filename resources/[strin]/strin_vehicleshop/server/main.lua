local Cooldowns = {}

local Base = exports.strin_base

Base:RegisterWebhook("BUY_VEHICLE", "https://discord.com/api/webhooks/687808267161960463/BR77_FiIi_TPh15v7X5Y8arWF46TghcNby6LUv6gKiVDJS5WgjXtOVG_UUQO19xPwKYx")

local OwnedVehiclesColumns = {
    "owner", "plate", "vehicle_identifier", "model", "props",
    "type", "job", "stored"
}

RegisterNetEvent("strin_vehicleshop:buyVehicle", function(vehicleName)
    if(type(vehicleName) ~= "string") then
        return
    end

    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    if(Cooldowns[xPlayer.identifier]) then
        xPlayer.showNotification("Provádíte nákupy moc rychle!", {type = "error"})
        return
    end

    local shop = GetNearestVehicleShop(_source)
    if(not shop) then
        xPlayer.showNotification("Nejste blízko žádné prodejny vozidel!", {type = "error"})
        return
    end

    local category = GetVehicleCategory(vehicleName)
    if(not category) then
        xPlayer.showNotification("Vozidlo buď neexistuje nebo nemá přiřazenou kategorii!", {type = "error"})
        return
    end

    local vehicleIndex = GetVehicleCatalogIndex(shop.catalog[category], vehicleName)
    if(not vehicleIndex) then
        xPlayer.showNotification("Vozidlo nemá index!", {type = "error"})
        return
    end

    local price = shop.catalog[category].vehicles[vehicleIndex].price
    local bankBalance = xPlayer.getAccount('bank').money
    if((bankBalance - price) < 0) then
        xPlayer.showNotification(([[
            Tohle vozidlo si nemůžete dovolit!<br/>
            Zůstatek na bankovním účtu: %s$<br/>
            Cena vozidla: %s$<br/>
            Nedoplatek: %s$<br/>
        ]]):format(bankBalance, price, price - bankBalance), {type = "error", duration = 10000})
        return
    end
    local owner = xPlayer.identifier..":"..xPlayer.get("char_id")
    xPlayer.showNotification("Probíhá transakce...", {
        type = "inform"
    })
    SetPlayerCooldown(xPlayer.identifier, 2000)
    local success = GenerateVehicle(owner, vehicleName, "car")
    if(not success) then
        xPlayer.showNotification("Nezdařilo se přiřadit vozidlo k hráči, zkuste akci znovu nebo kontaktujte dev. tým.", {
            type = "error"
        })
        return
    end
    Base:DiscordLog("BUY_VEHICLE", "THE RAVE PROJECT - ZAKOUPENÍ VOZIDLA", {
        { name = "Jméno kupce", value = ESX.SanitizeString(GetPlayerName(_source)) },
        { name = "Identifikace kupce", value = xPlayer.identifier },
        { name = "Jméno vozidla", value = vehicleName },
        { name = "Cena vozidla", value = ESX.Math.GroupDigits(price).."$" },
    }, {
        fields = true
    })
    xPlayer.removeAccountMoney('bank', price)
    xPlayer.showNotification(([[
        Zakoupil jste nové vozidlo - %s!<br/>
        Náš tým Vám ho každou chvílí zaveze do Vaší osobní garáže.<br/>
        Užijte si jízdu a děkujeme za nákup!
    ]]):format(vehicleName), {
        type = "success",
        duration = 10000,
    })
end)

local DefaultVehicleProperties = {}
Citizen.CreateThread(function()
    DefaultVehicleProperties = load(LoadResourceFile("strin_garages", "server/default_properties.lua"))()
end)

AddEventHandler("entityCreating", function(entity)
    if(GetEntityType(entity) ~= 2) then
        return
    end

    local vehicleIdentifier = GenerateVehicleIdentifier()
    Entity(entity).state.vehicleIdentifier = "1447"..vehicleIdentifier:sub(5)
end)

function GenerateVehicle(owner, modelName, vehicleType, job)
    if(not owner and not job) then
        return false
    end

    local colors = {
        0, -- black
        106, -- vanilla
        4, -- silver
        27, -- red
        135, -- electric pink
        54, -- topaz
        42, -- yellow
        49, -- met dark green
        36, -- orange
        45, -- brown
        71, -- purple
        117, -- chrome
        37, -- gold
    }

    math.randomseed(os.time())
    local primaryColor = math.random(1, #colors)
    local secondaryColor = math.random(1, #colors)

    local vehicleProperties = lib.table.deepclone(DefaultVehicleProperties)

    vehicleProperties.plate = GeneratePlate()
    vehicleProperties.model = GetHashKey(modelName)

    vehicleProperties.color1 = primaryColor
    vehicleProperties.color2 = secondaryColor

    local vehicleIdentifier = GenerateVehicleIdentifier()

    local parameters = {
        owner,
        vehicleProperties.plate,
        vehicleIdentifier,
        modelName,
        json.encode(vehicleProperties),
        vehicleType,
        job,
        1
    }

    local result = MySQL.insert.await(GenerateInsertVehicleQuery(), parameters)
    return result
end

exports("GenerateVehicle", GenerateVehicle)

AddEventHandler("strin_characters:characterDeleted", function(identifier, characterId)
    local owner = identifier..":"..characterId
    Citizen.Wait(1500) -- strin_tunning thing kek
    local deleteResult = MySQL.query.await("DELETE FROM owned_vehicles WHERE `owner` = ? AND `job` IS NULL", {
        owner
    })
    local updateResult = MySQL.query.await("UPDATE owned_vehicles SET `owner` = ? WHERE `owner` = ? AND `job` IS NOT NULL", {
        nil,
        owner
    })
end)

function SetPlayerCooldown(identifier, msec)
    Cooldowns[identifier] = true
    SetTimeout(msec, function()
        Cooldowns[identifier] = nil
    end)
end

function GenerateInsertVehicleQuery()
    local expressions = {}
    for _,column in pairs(OwnedVehiclesColumns) do
        expressions[#expressions + 1] = "`"..column.."` = ?"
    end
    return ("INSERT INTO owned_vehicles SET %s"):format(table.concat(expressions, ","))
end

function GetNearestVehicleShop(playerId)
    local ped = GetPlayerPed(playerId)
    local coords = GetEntityCoords(ped)
    local shop, distance = nil, 15000.0
    for k,v in pairs(VehicleShops) do
        local distanceToShop = #(coords - v.coords)
        if(distanceToShop < distance) then
            shop = v
            distance = distanceToShop
        end
    end
    return (distance < 15) and shop or nil
end

function GetVehicleCatalogIndex(category, vehicleName)
    local vehicleIndex = nil
    for i=1, #category.vehicles do
        if(category.vehicles[i].name == vehicleName) then
            vehicleIndex = i
            break
        end
    end
    return vehicleIndex
end

function GetVehicleCategory(vehicleName)
    local categoryName = nil
    for _,v in pairs(VehicleShops) do
        for category,data in pairs(v.catalog) do
            for i=1, #data.vehicles do
                if(data.vehicles[i].name == vehicleName) then
                    categoryName = category
                    break
                end
            end
        end
    end
    return categoryName
end

function GetCatalog()
    return AllBuyableVehicles
end

exports("GetCatalog", GetCatalog)

function GetVehiclePrice(vehicleModelName)
    local price = nil
    for categoryName,categoryData in pairs(AllBuyableVehicles) do
        for _,vehicle in pairs(categoryData.vehicles) do
            if(vehicle.name == vehicleModelName or GetHashKey(vehicle.name) == vehicleModelName) then
                price = vehicle.price
                break
            end
        end
    end
    return price
end

exports("GetVehiclePrice", GetVehiclePrice)

function GeneratePlate()
    return (GetRandomLetter(2)..GetRandomNumber(2)..GetRandomLetter(2)..GetRandomNumber(2)):upper()
end

function GenerateVehicleIdentifier()
    return (
        GetRandomLetter(2)..
        GetRandomLetter(2)..
        GetRandomNumber(2)..
        GetRandomNumber(2)..
        GetRandomLetter(2)..
        GetRandomLetter(2)
    ):upper()
end

local NumberCharset = {}
local Charset = {}

for i = 48,  57 do table.insert(NumberCharset, string.char(i)) end

for i = 65,  90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end

function GetRandomNumber(length)
    Citizen.Wait(100)
    math.randomseed(GetGameTimer() + math.random(10000, 99999))
    if length > 0 then
        return GetRandomNumber(length - 1) .. NumberCharset[math.random(1, #NumberCharset)]
    else
        return ''
    end
end

function GetRandomLetter(length)
    Citizen.Wait(100)
    math.randomseed(GetGameTimer() + math.random(10000, 99999))
    if length > 0 then
        return GetRandomLetter(length - 1) .. Charset[math.random(1, #Charset)]
    else
        return ''
    end
end