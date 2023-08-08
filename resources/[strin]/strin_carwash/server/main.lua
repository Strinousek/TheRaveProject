RegisterNetEvent("strin_carwash:requestCarWash", function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	if(not xPlayer) then
		return
	end

	local ped = GetPlayerPed(_source)
	local vehicle = GetVehiclePedIsIn(ped)
	if(vehicle == 0) then
		xPlayer.showNotification("Nesedíte v žádném vozidle!", { type = "error" })
		return
	end

	local dirtLevel = GetVehicleDirtLevel(vehicle)
	if(dirtLevel == 0.0) then
		xPlayer.showNotification("Vaše vozidlo již čisté je!", { type = "error" })
		return
	end

	local nearCarWashStation = GetNearestCarWashStation(_source)
	if(not nearCarWashStation) then
		xPlayer.showNotification("Nejste poblíž žádné automyčky!", { type = "error" })
		return
	end

	local money = xPlayer.getMoney()
	if((money - CarWashPrice) < 0) then
		xPlayer.showNotification("Nemáte dostatek peněz na automyčku!", { type = "error" })
		return
	end

	SetVehicleDirtLevel(vehicle, 0.0)
	xPlayer.removeMoney(tonumber(CarWashPrice))
	xPlayer.showNotification("Vaše vozidlo bylo umyto!", { type = "success" })
end)

function GetNearestCarWashStation(playerId)
	local ped = GetPlayerPed(playerId)
	local coords = GetEntityCoords(ped)
	local carWashStation = nil
	local distanceToCarWashStation = 15000.0
	for _,v in pairs(CarWashStations) do
		local distance = #(coords - v.coords)
		if(distance < distanceToCarWashStation) then
			carWashStation = v
			distanceToCarWashStation = distance
		end
	end
	return (distanceToCarWashStation < 15) and carWashStation or nil
end