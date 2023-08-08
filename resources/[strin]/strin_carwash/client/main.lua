local CarWashStationsBlips = {}

Citizen.CreateThread(function()
    AddTextEntry("STRIN_CARWASH:INTERACT", "<FONT FACE='Righteous'>~g~<b>[E]</b>~w~ Automyčka - "..CarWashPrice.."$</FONT>")
	for k,v in pairs(CarWashStations) do
		if(v.showBlip) then
			CarWashStationsBlips[k] = CreateCarWashStationBlip(v)
		end
		local stationPoint = lib.points.new({
			coords = v.coords,
			distance = 5.0,
		})

		function stationPoint:nearby()
			local ped = PlayerPedId()
			local vehicle = GetVehiclePedIsIn(ped)
			if(vehicle ~= 0) then
				if(GetVehicleDirtLevel(vehicle) > 0.0) then
					local floatTextCoords = vector3(v.coords.x, v.coords.y, v.coords.z + 0.5)
					DrawFloatingText(floatTextCoords)
					if(IsControlJustReleased(0, 38)) then
						TriggerServerEvent("strin_carwash:requestCarWash")
					end
				end
			end
		end
	end
end)

function DrawFloatingText(coords)
	BeginTextCommandDisplayHelp('STRIN_CARWASH:INTERACT')
	SetFloatingHelpTextWorldPosition(1, coords)
	SetFloatingHelpTextStyle(1, 1, 72, -1, 3, 0)
	EndTextCommandDisplayHelp(2, false, false, -1)
	SetFloatingHelpTextWorldPosition(0, coords.x, coords.y, coords.z)
end

function CreateCarWashStationBlip(carWashStation)
	local blip = AddBlipForCoord(carWashStation.coords)
	SetBlipDisplay(blip, 2)
	SetBlipSprite(blip, 100)
	SetBlipColour(blip, 0)
	SetBlipAsShortRange(blip, true)
	SetBlipScale(blip, 0.8)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("<FONT FACE='Righteous'>Automyčka</FONT>")
	EndTextCommandSetBlipName(blip)
	return blip
end

AddEventHandler("onResourceStop", function(resourceName)
	if(GetCurrentResourceName() == resourceName) then
		for k,v in pairs(CarWashStationsBlips) do
			if(v) then
				if(DoesBlipExist(v)) then
					RemoveBlip(v)
				end
			end
		end
	end
end)