local AllowedSaves = {}
local NakedPlayers = {}
local Base = exports.strin_base
local SkinChanger = exports.skinchanger
local Components = SkinChanger:GetComponents()
local ComponentsDefaultValues = {} 
local Accessories = exports.strin_accessories
local ACCESSORY_TYPES = {}

Citizen.CreateThread(function()
	while GetResourceState("strin_accessories") ~= "started" do
		Citizen.Wait(0)
	end
	ACCESSORY_TYPES = Accessories:GetAccessoryTypes()
	for i=1, #Components do
		ComponentsDefaultValues[Components[i].name] = Components[i].value
	end
end)

local PedList = Base:GetPedList()

local NakedPieces = {
	["top"] = {
		['tshirt_1'] = 15, ['tshirt_2'] = 0,
		['torso_1'] = 15, ['torso_2'] = 0,
		['arms'] = 15, ['arms_2'] = 0
	},
	["bottom"] = {
		['pants_1'] = 21, ['pants_2'] = 0
	},
	["boots"] = {
		['shoes_1'] = 34, ['shoes_2'] = 0
	}
}

AddEventHandler("strin_characters:characterSwitched", function(identifier)
	local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
	if(not xPlayer) then
		return
	end
	if(not NakedPlayers[xPlayer.source]) then
		return
	end
	NakedPlayers[xPlayer.source] = nil
end)

AddEventHandler("strin_skin:allowSkinSave", function(identifier)
    AllowedSaves[identifier] = true
end)

RegisterNetEvent("strin_skin:updatePiece", function(pieceType)
	if(type(pieceType) ~= "string") then
		return
	end
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	if(not xPlayer) then
		return
	end

	if(xPlayer.get("char_type") ~= 1) then
		xPlayer.showNotification("Tento typ postavy není podporován!", { type = "error" })
		return
	end

	if(NakedPlayers[_source] and lib.table.contains(NakedPlayers[_source], pieceType)) then
		
		local savedSkin = json.decode(MySQL.scalar.await('SELECT `skin` FROM `users` WHERE `identifier` = ?', {
			xPlayer.identifier
		}) or "{}")
		if(not next(savedSkin)) then
			xPlayer.showNotification("Nepodařilo se získat uložený skin!", { type = "error" })
			return
		end
		local changes = {}
		for k,v in pairs(NakedPieces[pieceType]) do
			changes[k] = savedSkin[k]
		end

		local skin = SkinChanger:GetSkin(_source)
		if(not skin) then
			xPlayer.showNotification("Nepodařilo se získat aktivní skin!", { type = "error" })
			return
		end

		for i=1, #NakedPlayers[_source] do
			if(NakedPlayers[_source][i] == pieceType) then
				NakedPlayers[_source][i] = nil
			end
		end

		TriggerClientEvent("skinchanger:loadClothes", _source, skin, changes)
		xPlayer.showNotification("Oblékl/a jste si předešle sundané oblečení.")
		return
	end

	local piece, pieceParts = nil, {}
	for k,v in pairs(NakedPieces) do
		if(pieceType == k) then
			piece = k
			pieceParts = v
			break
		end
	end
	if(not piece) then
		xPlayer.showNotification("Neznámý kousek oblečení!", { type = "error" })
		return
	end

	local skin = SkinChanger:GetSkin(_source)
	if(not skin) then
		xPlayer.showNotification("Nepodařilo se získat skin!", { type = "error" })
		return
	end

	if(not NakedPlayers[_source]) then
		NakedPlayers[_source] = { piece }
	else
		table.insert(NakedPlayers[_source], piece)
	end
	
	TriggerClientEvent("skinchanger:loadClothes", _source, skin, pieceParts)
	
	xPlayer.showNotification("Sundal/a jste si oblečení.")
end)

lib.callback.register("strin_skin:saveSkin", function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

    if(not xPlayer or not AllowedSaves[xPlayer.identifier]) then
        return false
    end

	local charType = xPlayer.get("char_type") 
	local skin = nil
	if(charType == 1) then
		skin = SkinChanger:GetSkin(_source)
	else
		local ped = GetPlayerPed(_source)
		local model = GetEntityModel(ped)
		local peds = PedList[charType == 2 and "peds" or "animals"]
		if(lib.table.contains(peds, model)) then
			skin = { model = model }
		end
	end
	if(not skin) then
		return false
	end

	if(NakedPlayers[_source]) then
		local savedSkin = json.decode(MySQL.prepare.await('SELECT `skin` FROM `users` WHERE `identifier` = ?', {
			xPlayer.identifier
		}) or "{}")
		if(not savedSkin or not next(savedSkin)) then
			xPlayer.showNotification("Nepodařilo se získat uložený skin!", { type = "error" })
			return false
		end
		for _, pieceType in pairs(NakedPlayers[_source]) do
			if(pieceType) then
				for piece, pieceValue in pairs(NakedPieces[pieceType]) do
					if(skin[piece] == pieceValue) then
						skin[piece] = savedSkin[piece]
					end
				end
			end
		end
	end

	CheckForAccessories(xPlayer, skin)

	MySQL.prepare.await('UPDATE users SET `skin` = ? WHERE `identifier` = ?', {
		json.encode(skin),
		xPlayer.identifier
	})
	return true
end)

function CheckForAccessories(xPlayer, skin)
	local characterAccessories = Accessories:GetCharacterAccessories(xPlayer.identifier, xPlayer.get("char_id"))
	for i=1, #ACCESSORY_TYPES do
		local accessoryType = ACCESSORY_TYPES[i]
		if(accessoryType == "arms") then
			goto skipLoop
		end
		local column = Accessories:GetAccessoryColumn(accessoryType)
		local accessories = json.decode(characterAccessories[column] or "{}")
		local variationComponentName = accessoryType == "arms" and accessoryType or accessoryType.."_1"
		local textureComponentName = accessoryType.."_2"
		local accessoryFound = false
		for i=1, #accessories do
			local accessory = accessories[i]
			if(skin[variationComponentName] == accessory.variation and skin[textureComponentName] == accessory.texture) then
				accessoryFound = true
				break
			end
		end
		if(not accessoryFound) then
			if(
				skin[variationComponentName] == ComponentsDefaultValues[variationComponentName] and 
				skin[textureComponentName] == ComponentsDefaultValues[textureComponentName]
			) then
				goto skipLoop
			end
			Accessories:AddCharacterAccessory(
				xPlayer.identifier, 
				xPlayer.get("char_id"), 
				accessoryType, 
				skin[variationComponentName],
				skin[textureComponentName]
			)
		end
		::skipLoop::
	end
end

exports("CheckForAccessories", CheckForAccessories)

lib.callback.register("strin_skin:getSavedSkin", function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

    if(not xPlayer) then
        return
    end
	local skin = MySQL.prepare.await('SELECT `skin` FROM `users` WHERE `identifier` = ?', {
		xPlayer.identifier
	})
	
	return json.decode(skin or "{}")
end)

AddEventHandler("esx:playerDropped", function(playerId)
	local xPlayer = ESX.GetPlayerFromId(playerId)
	if(AllowedSaves[xPlayer.identifier]) then
		AllowedSaves[xPlayer.identifier] = nil
	end
	if(NakedPlayers[playerId]) then
		NakedPlayers[playerId] = nil
	end
end)