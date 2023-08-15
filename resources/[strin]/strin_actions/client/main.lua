Target = exports.ox_target
Inventory = exports.ox_inventory
Animations = {
	Default = {
		Dict = "mp_arresting",
		BeingArrested = "idle",
		Arresting = "a_uncuff",
	},
	Aggressive = {
		Dict = "mp_arrest_paired",
		BeingArrested = "crook_p2_back_left",
		Arresting = "cop_p2_back_left"
	},
	Handsup = {
		Dict = "missminuteman_1ig_2",
		IsSurrending = "handsup_enter"
	}
}

DragStatus = {
	isBeingDragged = false,
	draggerPlayerId = nil
}

Target:addGlobalVehicle({
	{
		label = "Dát do auta",
		canInteract = function(entity)
			local players = GetActivePlayers()
			local ped = PlayerPedId()
			local draggedPed = nil
			for _,playerId in pairs(players) do
				local playerPed = GetPlayerPed(tonumber(playerId))
				if(IsEntityAttachedToEntity(playerPed, ped)) then
					draggedPed = playerPed
					break
				end
			end
			return draggedPed ~= nil
		end,
		onSelect = function(data)
			local players = GetActivePlayers()
			local ped = PlayerPedId()
			local draggedPed = nil
			for _,playerId in pairs(players) do
				local playerPed = GetPlayerPed(tonumber(playerId))
				if(IsEntityAttachedToEntity(playerPed, ped)) then
					draggedPed = playerPed
					break
				end
			end
			if(draggedPed) then
				local playerId = NetworkGetPlayerIndexFromPed(draggedPed)
				local netId = GetPlayerServerId(playerId)
				TriggerServerEvent("strin_actions:putInVehicle", netId)
			end
		end
	},
	{
		label = "Vytáhnout z auta",
		canInteract = function(entity)
			local maxSeats, restrainedPlayerId = GetVehicleMaxNumberOfPassengers(entity)
			for i=maxSeats - 1, 0, -1 do
				local ped = GetPedInVehicleSeat(entity, i)
				local localPlayerId = NetworkGetPlayerIndexFromPed(ped)
				if ped ~= 0 and localPlayerId ~= -1 and IsPlayerRestrained(ped) then
					restrainedPlayerId = GetPlayerServerId(localPlayerId)
					break
				end
			end
			return restrainedPlayerId ~= nil
		end,
		onSelect = function(data)
			local entity = data.entity
			local maxSeats, restrainedPlayerId = GetVehicleMaxNumberOfPassengers(entity)
			for i=maxSeats - 1, 0, -1 do
				local ped = GetPedInVehicleSeat(entity, i)
				local localPlayerId = NetworkGetPlayerIndexFromPed(ped)
				if ped ~= 0 and localPlayerId ~= -1 and IsPlayerRestrained(ped) then
					restrainedPlayerId = GetPlayerServerId(localPlayerId)
					break
				end
			end
			if(restrainedPlayerId) then
				TriggerServerEvent("strin_actions:putOutOfVehicle", restrainedPlayerId)
			end
		end
	},
})

RegisterNetEvent("strin_actions:drag", function(targetNetId)
	if(source == "" or GetInvokingResource() ~= nil) then
		return
	end

	local ped = PlayerPedId()
	if(DragStatus.isBeingDragged) then
		DetachEntity(ped)
		DragStatus.isBeingDragged = false
		DragStatus.draggerPlayerId = nil
		return
	end

	local targetPlayerId = GetPlayerFromServerId(targetNetId)
	if(targetPlayerId == -1) then
		return
	end
	local draggerPed = GetPlayerPed(targetPlayerId)
	if(not DoesEntityExist(ped) or not DoesEntityExist(draggerPed)) then
		return
	end

	if((#(GetEntityCoords(ped) - GetEntityCoords(draggerPed))) > 10) then
		return
	end
	DragStatus.isBeingDragged = true
	DragStatus.draggerPlayerId = targetNetId
	AttachEntityToEntity(ped, draggerPed, 11816, 0.7, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, true, false, 2, true)
	while DragStatus.isBeingDragged do
		Citizen.Wait(0)

		local ped = PlayerPedId()
		local draggerId = GetPlayerFromServerId(DragStatus.draggerPlayerId)
		local draggerPed = GetPlayerPed(draggerId)
		if(draggerId == -1 or not IsEntityAttachedToAnyPed(ped) or (IsPedDeadOrDying(draggerPed) or IsPedDeadOrDying(ped)) or IsPedInAnyVehicle(draggerPed) or not DoesEntityExist(draggerPed)) then
			DragStatus.isBeingDragged = false
			DragStatus.draggerPlayerId = nil
			DetachEntity(ped)
		end
	end
end)

RegisterNetEvent("strin_actions:putInVehicle", function()
	if(source == "" or GetInvokingResource() ~= nil) then
		return
	end

	if not IsRestrained then
		return
	end

	local ped = PlayerPedId()
	local coords = GetEntityCoords(ped)

	local nearestVehicle = lib.getClosestVehicle(coords, 10.0)
	local vehicleCoords = GetEntityCoords(nearestVehicle)

	if(not nearestVehicle or not DoesEntityExist(nearestVehicle) or (#(coords - vehicleCoords) > 10.0)) then
		return
	end

	local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(nearestVehicle)

	for i=maxSeats - 1, 0, -1 do
		if IsVehicleSeatFree(nearestVehicle, i) then
			freeSeat = i
			break
		end
	end

	if freeSeat then
		DetachEntity(ped)
		TaskWarpPedIntoVehicle(ped, nearestVehicle, freeSeat)
		DragStatus.isBeingDragged = false
		DragStatus.draggerPlayerId = nil
	end
end)

RegisterNetEvent("strin_actions:putOutOfVehicle", function()
	if(source == "" or GetInvokingResource() ~= nil) then
		return
	end

	local ped = PlayerPedId()

	if not IsPedSittingInAnyVehicle(ped) then
		return
	end

	local vehicle = GetVehiclePedIsIn(ped, false)
	TaskLeaveVehicle(ped, vehicle, 64)
end)

/*AddEventHandler("onResourceStop", function(resourceName)
	if(GetCurrentResourceName() == resourceName) then
		if((not IsRestrained and IsPlayerRestrained(PlayerPedId())) or IsRestrained) then
			local ped = PlayerPedId()
			ClearPedTasksImmediately(ped)
			SetEnableHandcuffs(ped, false)
			DisablePlayerFiring(ped, false)
			SetPedCanPlayGestureAnims(ped, true)
		end
	end
end)*/