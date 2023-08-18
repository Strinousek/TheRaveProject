local ready = false
local isFocused = false
local cam = nil
local Skin = exports.strin_skin

RegisterNetEvent('strin_characters:validateRegister')
AddEventHandler('strin_characters:validateRegister', function(charType)
	SetNuiFocus(false, false)
	isFocused = false
	SendNUIMessage({
		action = "close"
	})
    local ped = PlayerPedId()
	SetEntityCollision(ped, true, true)
	DoScreenFadeOut(1000)
	Wait(1000)
	SetCamActive(cam,  false)
	RenderScriptCams(false,  false,  0,  true,  true)
	FreezeEntityPosition(ped, false)
	DoScreenFadeIn(1000)
	--SetPedDefaultComponentVariation(PlayerPedId())
	SetEntityVisible(ped, true)
	DemandConfirmedSkinMenu(function()
		TriggerEvent("strin_hud:openHud")
	end)
	--[[if(isCharDog) then
		openDogMenu(function(skin)
			TriggerServerEvent("strin_register:registerDogSkin", skin)
			ESX.ShowNotification("Skin si dolaďte zapomocí vMenu na klávese M.", {length = 20000})
			dprint("novej, otevírám hud")
			Citizen.Wait(500)
			TriggerEvent("strin_hud:openHud")
		end)
	else
		ESX.ShowNotification("Skin si vytvořte zapomocí vMenu na klávese M.", {length = 20000})
	end]]
end)

RegisterNetEvent('strin_characters:register')
AddEventHandler('strin_characters:register', function()
	while not loadingScreenFinished do
		Wait(100)
	end
	DoScreenFadeOut(1000)
	TriggerEvent("strin_hud:closeHud")
	local starter = GetGameTimer()
	while true do
        Citizen.Wait(0)

		if(not IsScreenFadedOut()) then
			DoScreenFadeOut(1000)
		end
        
        if( GetGameTimer() - starter > 4000) then
            
            while IsPlayerSwitchInProgress() do
                Citizen.Wait(0)
            end
            break
        end
    end
	if not DoesCamExist(cam) then
		cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
	end
	SetCamActive(cam,  true)
	RenderScriptCams(true,  false,  0,  true,  true)
	SetCamCoord(cam, 391.18594360352,743.15155029297,418.2214050293)
	PointCamAtCoord(cam, 731.7666015625,1192.4577636719,350.49603271484)
	
	DoScreenFadeIn(1000)
	local ped = PlayerPedId()
	SetEntityCollision(ped,  false,  false)
	SetEntityVisible(ped,  false)
	FreezeEntityPosition(ped, true);
	SetNuiFocus(true, true)
	isFocused = true
	SendNUIMessage({
		action = "open"
	})
	while true do
		if(not isFocused) then
			SetEntityInvincible(cache.ped, false)
			break
		end
		SetEntityInvincible(cache.ped, true)
		Citizen.Wait(0)
	end
end)

RegisterNUICallback("register", function(data, cb)
	cb("ok")
	if(not ready) then
		TriggerServerEvent("strin_characters:register", data)
		ready = true
		SetTimeout(5000, function()
			ready = false
		end)
	end
end)

Citizen.CreateThread(function()
	while true do
		local sleep = 1500
		if(isFocused or isMenuOpen) then
			sleep = 0
			DisableControlAction(0, 24, true) -- Attack
			DisablePlayerFiring(cache.ped, true) -- Disable weapon firing
			DisableControlAction(0, 142, true) -- MeleeAttackAlternate
			DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
		end
		Citizen.Wait(sleep)
	end
end)