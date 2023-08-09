--[[local disableShuffle = true
function disableSeatShuffle(flag)
	disableShuffle = flag
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)
        if(disableShuffle) then
            local ped = PlayerPedId()
            local inVeh = IsPedInAnyVehicle(ped)
		    if inVeh then
                local veh = GetVehiclePedIsIn(ped)
                local driver = GetPedInVehicleSeat(veh, 0) 
			    if driver == PlayerPedId() then
				    if GetIsTaskActive(ped, 165) then
                        SetPedIntoVehicle(ped, veh, 0)
				    end
			    end
		    end
        else
            Citizen.Wait(1000)
        end
	end
end)

RegisterNetEvent("strin_base:seatShuffle")
AddEventHandler("strin_base:seatShuffle", function()
	if IsPedInAnyVehicle(PlayerPedId(), false) then
		disableSeatShuffle(false)
		Citizen.Wait(5000)
		disableSeatShuffle(true)
	else
		CancelEvent()
	end
end)


RegisterCommand("shuff", function(source, args)
    TriggerEvent("strin_base:seatShuffle")
end, false)]]