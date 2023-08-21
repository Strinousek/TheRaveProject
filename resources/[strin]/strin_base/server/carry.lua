local CarryInProgress = {}

/*
	[source] = target
*/

AddEventHandler("strin_jobs:onPlayerDeath", function(identifier)
	local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
	if(not xPlayer) then
		return
	end
	
	local carryId, carryType = GetPlayerCarryId(xPlayer.source)
	if(not carryId) then
		return
	end

	local players = { carryId, CarryInProgress[carryId] }
	for _,playerId in pairs(players) do
		TriggerClientEvent("strin_base:stopCarry", playerId)
	end

	CarryInProgress[carryId] = nil
end)

AddEventHandler("strin_actions:playerRestrained", function(restrainerId, restrainedPlayerId)
	local carryId, carryType = GetPlayerCarryId(restrainedPlayerId)
	if(not carryId) then
		return
	end

	local players = { carryId, CarryInProgress[carryId] }
	for _,playerId in pairs(players) do
		TriggerClientEvent("strin_base:stopCarry", playerId)
	end
	CarryInProgress[carryId] = nil
end)

AddEventHandler("playerDropped", function()
	local _source = source
	local carryId, carryType = GetPlayerCarryId(restrainedPlayerId)
	if(not carryId) then
		return
	end
	if(carryType == "source") then
		TriggerClientEvent("strin_base:stopCarry", CarryInProgress[carryId])
		return
	end

	TriggerClientEvent("strin_base:stopCarry", carryId)
	CarryInProgress[carryId] = nil
end)

RegisterNetEvent('strin_base:carry', function(carryType)
	if(not CarryTypes[carryType]) then
		return
	end
	local _source = source
	local closestPlayer = ESX.OneSync.GetClosestPlayer(_source, 10.0)
	
	if(not closestPlayer?.id) then
		TriggerClientEvent("esx:showNotification", _source, "Není žádný hráč poblíž!", { type = "error" })
		return
	end

	local targetCarryId = GetPlayerCarryId(closestPlayer.id)
	local sourceCarryId = GetPlayerCarryId(_source)
	if(targetCarryId or sourceCarryId) then
		TriggerClientEvent("esx:showNotification", _source, "Vy nebo hráč jste zaneprázdněni!", { type = "error" })
		return
	end

	local targetPed = GetPlayerPed(closestPlayer.id)
	if(GetVehiclePedIsIn(targetPed) ~= 0) then
		TriggerClientEvent("esx:showNotification", _source, "Hráč je ve vozidle!", { type = "error" })
		return
	end

	TriggerClientEvent('strin_base:syncTarget', closestPlayer.id, _source, carryType)
	TriggerClientEvent('strin_base:syncSource', _source, carryType)

	CarryInProgress[_source] = closestPlayer.id
end)

RegisterNetEvent('strin_base:stopCarry', function()
	local _source = source
	local carryId, carryType = GetPlayerCarryId(_source)
	if(not carryId) then
		return
	end
	local players = carryType == "source" and { _source, CarryInProgress[carryId] } or { _source, carryId}
	for _, playerId in pairs(players) do
		TriggerClientEvent('strin_base:stopCarry', playerId)
	end
	CarryInProgress[carryId] = nil
end)

function GetPlayerCarryId(playerId)
	local carryId = nil
	local carryType = nil
	for k,v in pairs(CarryInProgress) do
		if(v) then
			if((k == playerId) or (v == playerId)) then
				carryId = k
				carryType = k == playerId and "source" or "target"
				break
			end
		end
	end
	return carryId, carryType
end