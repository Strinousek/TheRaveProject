--[[SNÍH
Citizen.CreateThread(function()
    while true do
        
        SetWeatherTypePersist("XMAS")
        SetWeatherTypeNowPersist("XMAS")
        SetWeatherTypeNow("XMAS")
        SetOverrideWeather("XMAS")
        SetForcePedFootstepsTracks(true)
	    SetForceVehicleTrails(true)
        Citizen.Wait(0)
    end
end)]]