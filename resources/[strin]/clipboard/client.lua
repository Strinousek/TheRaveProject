RegisterNetEvent('clipboard')
AddEventHandler('clipboard', function(text)
	SendNUIMessage({
		text = text
	})
end)

-- {"x" = -74.974227905273, "y" = -819.19201660156, "z" = 326.17504882813, "heading" = 10.46}

exports("copy", function(text)
	SendNUIMessage({
		text = text
	})
end)

RegisterCommand('coords', function(source, args, rawCommand)
	local coords = GetEntityCoords(PlayerPedId())
	local vectorCoords = ("vector3(%s, %s, %s)"):format(coords.x, coords.y, coords.z)
	local objectCoords = ("{x: %s, y: %s, z: %s}"):format(coords.x, coords.y, coords.z)
	local text = (args[1] == "table") and objectCoords or vectorCoords
	SendNUIMessage({
		text = text
	})
end)
