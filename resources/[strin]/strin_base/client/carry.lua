local IsCarrying = false
local IsBeingCarried = false
local IsRestrained = false

AddEventHandler("esx_policejob:handcuff", function()
    IsRestrained = true
end)

AddEventHandler("esx_policejob:unrestrain", function()
    IsRestrained = false
    IsCarrying = false
	IsBeingCarried = false
end)


RegisterCommand("carry", function(source, args)
    if(IsRestrained) then
        return
    end
	if(not IsBeingCarried) then
		if not IsCarrying then
			local carryType = "Fireman"
			local arg = tonumber(args[1])
			if(arg) then
				if(arg == 2) then
					carryType = "Piggy"
				elseif(arg == 3) then
					carryType = "Arms"
				end
			end
			TriggerServerEvent("strin_base:carry", carryType)
		else
			TriggerServerEvent("strin_base:stopCarry")
		end
	else
		TriggerServerEvent("strin_base:stopCarry")
	end
end,false)

RegisterNetEvent('strin_base:syncTarget', function(carrierServerId, carryType)
	if(source == "" or GetInvokingResource() ~= nil) then
		return
	end

	local ped = PlayerPedId()
	local carrierPlayerId = GetPlayerFromServerId(carrierServerId)
	if(carrierPlayerId == -1) then
		return
	end
	local carrierPed = GetPlayerPed(carrierPlayerId)
	IsBeingCarried = true

	local animation = CarryTypes[carryType]
	local targetAnimation = animation.Target
	RequestAnimDict(targetAnimation.Dict)

	while not HasAnimDictLoaded(targetAnimation.Dict) do
		Citizen.Wait(0)
	end

	if animation.Spin == nil then
		animation.Spin = 180.0
	end
	AttachEntityToEntity(
		ped,
		carrierPed,
		animation?.BoneIndex or 0,
		animation.Source.Distance,
		targetAnimation.Distance,
		animation.Height,
		0.5,
		0.5,
		animation.Spin,
		false,
		false,
		false,
		false,
		2,
		false
	)
	if targetAnimation.ControlFlag == nil then
		targetAnimation.ControlFlag = 0
	end
	TaskPlayAnim(
		ped,
		targetAnimation.Dict,
		targetAnimation.Clip,
		8.0,
		-8.0,
		animation.Length,
		targetAnimation.ControlFlag,
		0,
		false,
		false,
		false
	)
	IsBeingCarried = true
	RemoveAnimDict(targetAnimation.Dict)
end)

RegisterNetEvent('strin_base:syncSource', function(carryType)
	if(source == "" or GetInvokingResource() ~= nil) then
		return
	end

	local ped = PlayerPedId()
	local animation = CarryTypes[carryType]
	local sourceAnimation = animation.Source
	RequestAnimDict(sourceAnimation.Dict)

	while not HasAnimDictLoaded(sourceAnimation.Dict) do
		Citizen.Wait(0)
	end

	if sourceAnimation.ControlFlag == nil then
		sourceAnimation.ControlFlag = 0
	end

	Citizen.Wait(500)

	TaskPlayAnim(
		ped,
		sourceAnimation.Dict,
		sourceAnimation.Clip,
		8.0,
		-8.0,
		animation.Length,
		sourceAnimation.ControlFlag,
		0,
		false,
		false,
		false
	)
	IsCarrying = true
	RemoveAnimDict(sourceAnimation.Dict)
end)

RegisterNetEvent('strin_base:stopCarry')
AddEventHandler('strin_base:stopCarry', function()
	if(source == "" and GetInvokingResource() ~= nil) then
		return
	end
	local ped = PlayerPedId()
	if(IsCarrying) then
		IsCarrying = false
		ClearPedSecondaryTask(ped)
	end
	if(IsBeingCarried) then
		IsBeingCarried = false
		ClearPedSecondaryTask(ped)
		DetachEntity(ped, true, false)
	end
end)