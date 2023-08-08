function CreateAxonCode(identifier, characterId)
	local code = "X"..math.random(1000000, 99999999)
	local insertId = MySQL.insert.await("INSERT INTO character_axons SET `identifier` = ?, `char_id` = ?, `code` = ?", {
		identifier,
		characterId,
		code
	})
	return code
end

AddEventHandler("strin_characters:characterDeleted", function(identifier, characterId)
	local code = MySQL.scalar.await("SELECT code FROM character_axons WHERE `identifier` = ? AND `char_id` = ?", {
		identifier,
		characterId
	})
	if(code) then
		local result = MySQL.query.await("DELETE FROM character_axons WHERE `identifier` = ? AND `char_id` = ?", {
			identifier,
			characterId
		})
	end
end)

function GetAxonCode(identifier, characterId)
	local code = MySQL.scalar.await("SELECT code FROM character_axons WHERE `identifier` = ? AND `char_id` = ?", {
		identifier,
		characterId
	})
	return code ~= nil and code or CreateAxonCode(identifier, characterId)
end

exports("GetAxonCode", GetAxonCode)

lib.callback.register('strin_axon:getCode', function(source)
	local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
	local characterId = xPlayer.get("char_id")
	if(not xPlayer or xPlayer.getJob()?.name ~= "police" or not characterId) then
		return nil
	end
	return GetAxonCode(xPlayer.identifier, characterId)
end)