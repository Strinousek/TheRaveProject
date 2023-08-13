local Base = exports.strin_base
local Inventory = exports.ox_inventory

local CHARACTER_DATA_TYPES = { 
	["firstname"] = "string",
	["lastname"] = "string",
	["sex"] = { "M", "F" },
	["dateofbirth"] = "string",
	["height"] = "number",
	["weight"] = "number",
	["char_type"] = { 1, 2, 3 },
}

/*RegisterCommand("idcard", function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local identity = xPlayer.variables
	local time = os.date("%d/%m/%Y")

	xPlayer.addInventoryItem("driving_license", 1, {
        holder = identity.firstname.." "..identity.lastname,
		id = 6,
		issuedOn = time,
		classes = { "C" },
	})

	xPlayer.addInventoryItem("identification_card", 1, {
		holder = identity.firstname.." "..identity.lastname,
		id = 6,
		issuedOn = time,
	})
end)*/

local CARDS = { "identification_card", "driving_license" }

function ShowCard(__type, cardId, playerId)
    if(type(playerId) ~= "number" or (type(cardId) ~= "number" and type(cardId) ~= "nil") or not lib.table.contains(CARDS, __type)) then
        return
    end
    local _source = source or playerId
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    local targetPlayer = _source == playerId and xPlayer or ESX.GetPlayerFromId(playerId)
    if(not targetPlayer) then
        xPlayer.showNotification("Hráč neexistuje!", { type = "error" })
        return
    end

    local distance = #(GetEntityCoords(GetPlayerPed(_source)) - GetEntityCoords(GetPlayerPed(playerId)))
    if(distance > 5) then
        xPlayer.showNotification("Hráč je moc daleko!", { type = "error" })
        return
    end

    local card = Inventory:GetSlotWithItem(_source, __type, cardId and {
        id = cardId
    } or nil)
    if(not card) then
        xPlayer.showNotification("Daná karta neexistuje!", { type = "error" })
        return
    end
    local data = MySQL.single.await("SELECT * FROM `character_data` WHERE `id` = ?", { card.metadata?.id })
    data.issuedOn = card.metadata?.issuedOn
    if(__type == "driving_license") then
        data.classes = card.metadata?.classes
    end
    TriggerClientEvent("strin_idcard:showCard", targetPlayer.source, __type, data)
end

RegisterNetEvent("strin_idcard:showCard", ShowCard)

RegisterNetEvent("strin_idcard:requestCard", function(cardType)
    if(not lib.table.contains(CARDS, cardType)) then
        return
    end
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    if((xPlayer.getMoney() - CARD_RENEWAL_PRICE) < 0) then
        xPlayer.showNotification("Nemáte dostatek peněz!", { type = "error" })
        return
    end

    local ped = GetPlayerPed(_source)
    local coords = GetEntityCoords(ped)

    local nearestDistance = 15000.0
    for _,v in pairs(CITY_HALLS) do
        local distance = #(coords - v.coords)
        if(distance < nearestDistance) then
            nearestDistance = distance
        end
    end

    if(nearestDistance > 15.0) then
        xPlayer.showNotification("Nejste poblíž žádnému úřadu!", { type = "error" })
        return
    end

    local characterData = {
        --xPlayer.identifier..":"..xPlayer.get("char_id"),
        xPlayer.get("firstname"),
        xPlayer.get("lastname"),
        xPlayer.get("sex"),
        xPlayer.get("height"),
        xPlayer.get("weight"),
    }
    
    local characterDataId = MySQL.scalar.await([[SELECT `id` FROM `character_data` WHERE (
        `firstname` = ? AND `lastname` = ? AND `sex` = ? AND `height` = ? AND `weight` = ?
    )]], {
        table.unpack(characterData)
    })

    if(not characterDataId) then
        local parameters = {}
        for k,v in pairs(CHARACTER_DATA_TYPES) do
            parameters[k] = xPlayer.get(k)
        end
        parameters["owner"] = xPlayer.identifier..":"..xPlayer.get("char_id")
        local expressions = {}
        for k,v in pairs(parameters) do
            table.insert(expressions, "`"..k.."` = @"..k)
        end
        characterDataId = MySQL.insert.await(("INSERT INTO `character_data` SET %s"):format(
            table.concat(expressions, ",")
        ), parameters)
    end

	local time = os.date("%d/%m/%Y")
    local cardMetadata = {
        holder = xPlayer.get("fullname"),
        id = characterDataId,
        issuedOn = time,
    }
    if(cardType == "driving_license") then
        cardMetadata.classes = { "C" }
    end
    Inventory:AddItem(_source, cardType, 1, cardMetadata)
    xPlayer.removeMoney(CARD_RENEWAL_PRICE)
end)

Base:RegisterItemListener(CARDS, function(item, inventory, slot, data)
    local _source = inventory.id
    local item = Inventory:GetSlot(_source, slot)
    if(item.metadata?.id and lib.table.contains(CARDS, item.name)) then
        ShowCard(item.name, item.metadata?.id, _source)
    end
end, {
    event = "usingItem"
})

/*Base:RegisterItemListener("identification_card", function(item, inventory, slot, data)
    print("this handler2")
    local _source = inventory.id
    local item = Inventory:GetSlot(_source, slot)
end, {
    event = "usingItem"
})*/