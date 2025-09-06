local RegisterCooldown = {}
local CHARACTER_DATA_TYPES = { 
	["firstname"] = "string",
	["lastname"] = "string",
	["sex"] = { "M", "F" },
	["dateofbirth"] = "string",
	["height"] = "number",
	["weight"] = "number",
	["char_type"] = { 1, 2, 3 },
	["car"] = { 1, 2, 3 },
}

local BaseBucketId = 70000
local UsedRegisterBuckets = {}
local _ExpectedRegisters = {}
ExpectedRegisters = setmetatable({}, {
	__index = function(t, k)
		return _ExpectedRegisters[k]
	end,
	__newindex = function(t, k, v)
		_ExpectedRegisters[k] = v
		if(v) then
			UsedRegisterBuckets[k] = BaseBucketId + 1
            SetRoutingBucketEntityLockdownMode(UsedRegisterBuckets[k], "strict")
			SetPlayerRoutingBucket(k, UsedRegisterBuckets[k])
			BaseBucketId += 1 
		else
			UsedRegisterBuckets[k] = nil
			if(GetPlayerName(k)) then
				SetPlayerRoutingBucket(k, 0)
			end
		end
	end,
})
Inventory = exports.ox_inventory
SkinChanger = exports.skinchanger

RegisterNetEvent('esx:playerLoaded', function(playerId, xPlayer)
	if(not xPlayer.get("firstname")) then
		ExpectedRegisters[playerId] = true
		TriggerClientEvent('strin_characters:register', xPlayer.source)
		return
	end

	MySQL.prepare('SELECT `skin` FROM users WHERE `identifier` = ?', {
		xPlayer.identifier
	}, function(result)
		local skin = (result ~= nil) and json.decode(result) or {}
		if(not next(skin)) then
			TriggerEvent("strin_skin:allowSkinSave", xPlayer.identifier)
			TriggerClientEvent('strin_characters:demandSkin', xPlayer.source)
		end
	end)
end)

AddEventHandler("playerDropped", function()
	local _source = source
	if(not ExpectedRegisters[_source]) then
		return
	end
	ExpectedRegisters[_source] = nil
end)

RegisterNetEvent("strin_characters:register", function(data)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
	if(not xPlayer) then
		return
	end
    if(not ExpectedRegisters[_source]) then
		xPlayer.showNotification("Nemáte povolenou tvorbu postavy", { type = "error" })
        return
    end
	local data = ValidateCharacterData(data)
	if(not data) then
		xPlayer.showNotification("Data nejsou validní, ověřte zápis.", { type = "error" })
		return
	end
	if(data.char_type > 1) then
		local hasAccess = exports.strin_base:DoesPlayerHaveDiscordRole(_source, data.char_type == 2 and "Ped" or "Animal")
		if(not hasAccess) then
			xPlayer.showNotification("K tomuto typu postavy nemáte povolení, zažádejte si o něj u administrátorského týmu.", { type = "error" })
			return
		end
	end
    local previousInventory = json.encode(xPlayer.getInventory(true))
    local previousAccounts = json.encode(xPlayer.getAccounts(true))
    Inventory:ClearInventory(xPlayer.source)
    local configAccounts = data.char_type < 3 and { bank = 4000, money = 500} or { bank = 0, money = 0 }
    for k,v in pairs(configAccounts) do
        xPlayer.setAccountMoney(k, v)
    end
	xPlayer.showNotification("Data o postavě se zpracovávají, prosím vyčkejte.")
	ExpectedRegisters[_source] = nil
	SetupCharacterBasics(data, _source, function()
		TriggerEvent("strin_characters:createCharacter", {
			accounts = json.encode(xPlayer.getAccounts(true)),
			firstname = data.firstname,
			lastname = data.lastname,
			dateofbirth = data.dateofbirth,
			sex = data.sex,
			height = data.height,
			weight = data.weight,
			--hair_color = data.hairColor,
			--eyes = data.eyes,
			inventory = json.encode(xPlayer.getInventory(true)),
			prevInventory = previousInventory,
			prevAccounts = previousAccounts,
			char_type = data.char_type,
			skin = json.encode({}),
		}, _source)
		TriggerEvent("strin_skin:allowSkinSave", xPlayer.identifier)
		TriggerClientEvent("strin_characters:validateRegister", _source, data.char_type)
	end)
end)

function ValidateCharacterData(data)
	local isDataValid = true
	for k,v in pairs(data) do 
		if(not CHARACTER_DATA_TYPES[k]) then
			isDataValid = false
			break
		end
		if(type(CHARACTER_DATA_TYPES[k]) == "table" and not lib.table.contains(CHARACTER_DATA_TYPES[k], v)) then
			isDataValid = false
			break
		end
		if(type(CHARACTER_DATA_TYPES[k]) ~= "table" and CHARACTER_DATA_TYPES[k] ~= type(v)) then
			isDataValid = false
			break
		end
	end
	for k,v in pairs(CHARACTER_DATA_TYPES) do
		if(not data[k]) then
			isDataValid = false
			break
		end
	end
	if(isDataValid) then
		if(
			data.firstname:len() <= 0 or 
			data.firstname:len() > 20 or 
			data.lastname:len() <= 0 or 
			data.lastname:len() > 20 or 
			data.weight < 30 or 
			data.weight > 300
		) then
			isDataValid = false
		end
	end
	if(isDataValid) then
		data.sex = data.sex:upper()
	end
	return isDataValid and data or nil
end

function SetupCharacterBasics(identity, playerId, cb)
    local xPlayer = ESX.GetPlayerFromId(playerId)
	local slot = GetAvailableSlotForIdentifier(xPlayer.identifier)

	local parameters = {}
	for k,v in pairs(identity) do
		if(k ~= "car") then
			parameters[k] = v
		end
	end
	parameters["owner"] = xPlayer.identifier..":"..slot
	local expressions = {}
	local queryParameters = {}
	for k,v in pairs(parameters) do
		table.insert(expressions, "`"..k.."` = ?")
		table.insert(queryParameters, v)
	end
	local characterDataId = MySQL.insert.await(("INSERT INTO `character_data` SET %s"):format(
		table.concat(expressions, ", ")
	), queryParameters)

	if(identity.char_type == 3) then
		cb()
		return
	end

	--local cars = {"ingot", "rancherxl", "bagger"}
	local cars = { "intruder", "cavalcade", "faggio" }
	local time = os.date("%d/%m/%Y")
	local car = cars[identity.car] or cars[1]

	exports.strin_vehicleshop:GenerateVehicle(xPlayer.identifier..":"..slot, car, "car")
	exports.strin_licenses:AddLicense(xPlayer.identifier, "drive", slot)

	Inventory:AddItem(xPlayer.source, "driving_license", 1, {
		holder = identity.firstname.." "..identity.lastname,
		id = characterDataId,
		issuedOn = time,
		classes = { "C" },
	})
	Inventory:AddItem(xPlayer.source, "identification_card", 1, {
		holder = identity.firstname.." "..identity.lastname,
		id = characterDataId,
		issuedOn = time,
	})
	Inventory:AddItem(xPlayer.source, "phone", 1)
	cb()
end

--[[function checkDOBFormat(dob)
	local date = tostring(dob)
	if checkDate(date) then
		return true
	else
		return false
	end
end

function checkSexFormat(sex)
	if sex == "m" or sex == "M" or sex == "f" or sex == "F" then
		return true
	else
		return false
	end
end

function checkHeightFormat(height)
	local numHeight = tonumber(height)
	if numHeight < Config.MinHeight and numHeight > Config.MaxHeight then
		return false
	else
		return true
	end
end

function formatName(name)
	local loweredName = convertToLowerCase(name)
	local formattedName = convertFirstLetterToUpper(loweredName)
	return formattedName
end

function convertToLowerCase(str)
	return string.lower(str)
end

function convertFirstLetterToUpper(str)
	return str:gsub("^%l", string.upper)
end

function checkAlphanumeric(str)
	return (string.match(str, "%W"))
end

function checkForNumbers(str)
	return (string.match(str,"%d"))
end

function checkDate(str)
	if string.match(str, '(%d%d)/(%d%d)/(%d%d%d%d)') ~= nil then
		local m, d, y = string.match(str, '(%d+)/(%d+)/(%d+)')
		m = tonumber(m)
		d = tonumber(d)
		y = tonumber(y)
		if ((d <= 0) or (d > 31)) or ((m <= 0) or (m > 12)) or ((y <= Config.LowestYear) or (y > Config.HighestYear)) then
			return false
		elseif m == 4 or m == 6 or m == 9 or m == 11 then
			if d > 30 then
				return false
			else
				return true
			end
		elseif m == 2 then
			if y%400 == 0 or (y%100 ~= 0 and y%4 == 0) then
				if d > 29 then
					return false
				else
					return true
				end
			else
				if d > 28 then
					return false
				else
					return true
				end
			end
		else
			if d > 31 then
				return false
			else
				return true
			end
		end
	else
		return false
	end
end]]
