local Base = exports.strin_base
local LawEnforcementJobs = exports.strin_jobs:GetLawEnforcementJobs()

Base:RegisterWebhook("AXON", "https://discord.com/api/webhooks/1136613719556751390/_vKBcwyMMbZg67FBM5jbyW5MRYBBFGw6_w5V0SptLee0G10Bht0aufodCYWvsOjWw0iE")

function CreateAxonCode(identifier, characterId)
	local code = "X"..math.random(1000000, 99999999)
	MySQL.prepare.await("INSERT INTO `character_axons` SET `identifier` = ?, `char_id` = ?, `code` = ?", {
		identifier,
		characterId,
		code
	})
	local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
	if(not xPlayer) then
		local data = exports.strin_characters:GetSpecificCharacter(identifier, characterId)
		local variables = {
			fullname = data.firstname.." "..data.lastname,
			char_identifier = data.char_identifier,
			char_id = characterId,
		}
		xPlayer = {
			identifier = identifier,
			variables = variables,
			get = function(k)
				return variables[k]
			end,
		}
	end
	Base:DiscordLog("AXON", "LEO - AXON CREATE", {
		{ name = "Identifikátor hráče", value = identifier },
		{ name = "Číslo postavy", value = characterId },
		{ name = "CitizenID", value = xPlayer.get("char_identifier") },
		{ name = "Jméno postavy", value = xPlayer.get("fullname") },
		{ name = "Axon Code", value = code },
	}, {
		fields = true
	})
	return code
end

AddEventHandler("strin_characters:characterDeleted", function(identifier, characterId)
	MySQL.prepare("DELETE FROM character_axons WHERE `identifier` = ? AND `char_id` = ?", {
		identifier,
		characterId
	}, function() end)
end)

function GetAxonCode(identifier, characterId)
	local code = MySQL.prepare.await("SELECT `code` FROM `character_axons` WHERE `identifier` = ? AND `char_id` = ?", {
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
	local job = xPlayer.getJob()
	if(not xPlayer or not lib.table.contains(LawEnforcementJobs, job.name) or not characterId) then
		return nil
	end
	return GetAxonCode(xPlayer.identifier, characterId)
end)