--[[
	local availableActivities = {
		weedPlant = false,
		weedSell = false,
		robberyCooldown = false,
	}
	Citizen.CreateThread(function()
		while true do
			local startTime = GetGameTimer()
			local changed = initActivities()
			if(changed) then
				TriggerClientEvent("strin_scoreboard:updateActivities", -1, availableActivities)
			end
			Citizen.Wait(30000 - (GetGameTimer() - startTime))
		end
	end)
	function initActivities()
		local changed = false
		TriggerEvent("strin_weed:getCopRequirements", function(copRequirements)
			local cops = ESX.GetExtendedPlayers("job", "police")
			if(#cops >= copRequirements["plant"]) then
				if(not availableActivities.weedPlant) then
					availableActivities.weedPlant = true
					changed = true
				end
			else
				if(availableActivities.weedPlant) then
					availableActivities.weedPlant = false
					changed = true
				end
			end
			if(#cops >= copRequirements["sell"]) then
				if(not availableActivities.weedSell) then
					availableActivities.weedSell = true
					changed = true
				end
			else
				if(availableActivities.weedSell) then
					availableActivities.weedSell = false
					changed = true
				end
			end
		end)
		TriggerEvent("strin_base:isRobberyAvailable", function(cooldown)
			if(cooldown) then
				if(not availableActivities.robberyCooldown) then
					availableActivities.robberyCooldown = true
					changed = true
				end
			else
				if(availableActivities.robberyCooldown) then
					availableActivities.robberyCooldown = false
					changed = true
				end
			end
		end)
		return changed
	end
]]
local ConnectedPlayers, MAX_PLAYERS = {}, GetConvarInt('sv_maxclients', 64)

AddEventHandler("strin_scoreboard:refresh", function()
	ConnectedPlayers = {}
	AddPlayersToScoreboard()
end)

lib.callback.register("strin_scoreboard:getPlayers", function(source)
	return ConnectedPlayers
end)

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
	Citizen.Wait(500)
	AddPlayerToScoreboard(tonumber(playerId), true)
end)

AddEventHandler('esx:playerDropped', function(playerId)
	RemovePlayerFromScoreboard(tonumber(playerId), true)
end)

RegisterNetEvent("strin_scoreboard:requestUpdatePlayers", function()
	local _source = source
	TriggerClientEvent('strin_scoreboard:updatePlayers', _source, ConnectedPlayers)
end)

function RemovePlayerFromScoreboard(playerId, update)
	local newPlayers = {}
	for i=1, #ConnectedPlayers do
		if(ConnectedPlayers[i]) then
			local player = ConnectedPlayers[i]
			if(player?.id ~= playerId) then
				table.insert(newPlayers, player)
			end
		end
	end
	ConnectedPlayers = newPlayers
	if update then
		TriggerClientEvent('strin_scoreboard:updatePlayers', -1, ConnectedPlayers)
	end
end

function AddPlayerToScoreboard(playerId, update)

	local xPlayer = ESX.GetPlayerFromId(playerId)
	local data = {
		id = playerId,
		name = ESX.SanitizeString(GetPlayerName(playerId) or "Neznámý hráč", {
			html = true,
			sql = true,
			cc = true
		})
	}
	
	local vipData = xPlayer.get("vip")
	if(vipData?.backgroundImage and type(vipData?.backgroundImage) == "string") then
		data.backgroundImage = vipData?.backgroundImage
	end
	table.insert(ConnectedPlayers, data)

	if update then
		TriggerClientEvent('strin_scoreboard:updatePlayers', -1, ConnectedPlayers)
	end
end

function AddPlayersToScoreboard()

	for _,playerId in pairs(GetPlayers()) do
		AddPlayerToScoreboard(tonumber(playerId), false)
	end

	TriggerClientEvent('strin_scoreboard:updatePlayers', -1, ConnectedPlayers)
end

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Citizen.Wait(1000)
		AddPlayersToScoreboard()
	end
end)