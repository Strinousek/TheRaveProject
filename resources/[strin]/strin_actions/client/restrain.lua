IsRestrained = false
local IsBeingAggressivelyArrested = false

function RestrainPlayer(playerEntity, item, restrainType)
	local playerIndex = NetworkGetPlayerIndexFromPed(playerEntity)
    local netId = GetPlayerServerId(playerIndex)
    local success = lib.callback.await("strin_actions:restrain", false, netId, item, restrainType)
	if(success) then
		if(netId ~= GetPlayerServerId(PlayerId())) then
			TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 4.0, item == "zipties" and 'ziptie' or "busted", 1.0)
		end
    end
end

function UnrestrainPlayer(playerEntity)
	LoadAnimDict(Animations.Default.Dict)
	local playerIndex = NetworkGetPlayerIndexFromPed(playerEntity)
    local netId = GetPlayerServerId(playerIndex)
    local success, item = lib.callback.await("strin_actions:unrestrain", false, netId)
	if(success) then
		local ped = PlayerPedId()
		TaskPlayAnim(ped, Animations.Default.Dict, Animations.Default.Arresting, 8.0, -8, 5000, 49, 0, 0, 0, 0)
		TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 4.0, item == "zipties" and 'ziptie' or "busted", 1.0)
	end
	RemoveAnimDict(Animations.Default.Dict)
end

function IsPlayerRestrained(playerEntity)
	local isRestrained = IsEntityPlayingAnim(playerEntity, Animations.Default.Dict, Animations.Default.BeingArrested, 3)
	local isBeingArrested = IsEntityPlayingAnim(playerEntity, Animations.Aggressive.Dict, Animations.Aggressive.BeingArrested, 3)
	return isRestrained or isBeingArrested or IsPedCuffed(playerEntity)
end

function IsPlayerSurrending(playerEntity)
	local isSurrending = IsEntityPlayingAnim(playerEntity, Animations.Handsup.Dict, Animations.Handsup.IsSurrending, 3)
	return isSurrending
end

function CanPlayerBeDragged(playerEntity)
	local isRestrained = IsEntityPlayingAnim(playerEntity, Animations.Default.Dict, Animations.Default.BeingArrested, 3)
	return isRestrained
end

Target:addGlobalPlayer({
    {
        label = "Svázat",
		distance = 1.5,
        items = { ["zipties"] = 1 },
		canInteract = function(entity)
            return not IsPlayerRestrained(entity)
		end,
        onSelect = function(data)
            RestrainPlayer(data.entity, "zipties", "default")
        end
    },
    {
        label = "Spoutat",
		distance = 1.5,
        items = { ["handcuffs"] = 1 },
		canInteract = function(entity)
            return not IsPlayerRestrained(entity)
		end,
        onSelect = function(data)
            RestrainPlayer(data.entity, "handcuffs", "default")
        end
    },
    {
        label = "Osvobodit",
		distance = 1.5,
        canInteract = function(entity)
            return IsPlayerRestrained(entity)
        end,
		onSelect = function(data)
			UnrestrainPlayer(data.entity)
		end
    },
    {
        label = "Prohledat",
		distance = 1.5,
		canInteract = function(entity)
            return IsPlayerRestrained(entity) or IsEntityDead(entity) or IsPlayerSurrending(entity)
		end,
        onSelect = function(data)
			ExecuteCommand("steal")
			/*local netId = NetworkGetNetworkIdFromEntity(data.entity)
			TriggerServerEvent("strin_actions:search", netId, IsPlayerSurrending(data.entity))*/
        end
    },
	{
        label = "Táhnout",
		distance = 1.5,
		canInteract = function(entity)
            return IsPlayerRestrained(entity)
		end,
        onSelect = function(data)		
			local playerIndex = NetworkGetPlayerIndexFromPed(data.entity)
			local netId = GetPlayerServerId(playerIndex)
			TriggerServerEvent("strin_actions:drag", netId)
        end
    }
})

Citizen.CreateThread(function()
	while true do
		local sleep = 1000
		if(IsRestrained) then
			local ped = PlayerPedId()
			if(not IsPlayerRestrained(ped)) then
				sleep = 0
				LoadAnimDict(Animations.Default.Dict)
				TaskPlayAnim(ped, Animations.Default.Dict, Animations.Default.BeingArrested, 8.0, -8, -1, 49, 0, 0, 0, 0)
				SetEnableHandcuffs(ped, true)
				DisablePlayerFiring(ped, true)
				SetPedCanPlayGestureAnims(ped, false)
				RemoveAnimDict(Animations.Default.Dict)
			end
		end
		Citizen.Wait(sleep)
	end
end)

RegisterCommand("aggressive_restrain", function()
	if(IsControlPressed(0, 21)) then
		local ped = PlayerPedId()
		local coords = GetEntityCoords(ped)
		local targetPlayerId = ESX.Game.GetClosestPlayer(coords)

		if(targetPlayerId == -1) then
			ESX.ShowNotification("Žádný hráč poblíž!", { type = "error" })
			return
		end
		local targetPlayerPed = GetPlayerPed(targetPlayerId)
		if(IsPlayerRestrained(targetPlayerPed)) then
			ESX.ShowNotification("Hráč již spoutaný je!", { type = "error" })
			return
		end
		local ziptiesCount = Inventory:GetItemCount("zipties")
		local handcuffsCount = Inventory:GetItemCount("handcuffs")
		if((ziptiesCount > 0 and (handcuffsCount > 0 and ESX.PlayerData.job?.name == "police")) or handcuffsCount > 0) then
			RestrainPlayer(targetPlayerPed, "handcuffs", "aggressive")
			return
		end

		if(ziptiesCount > 0) then
			RestrainPlayer(targetPlayerPed, "zipties", "aggressive")
			return
		end
	end
end)

RegisterKeyMapping("aggressive_restrain", "<FONT FACE='Righteous'>Rychlé svázání/spoutání (LSHIFT +)~</FONT>", "KEYBOARD", "H")

function LoadAnimDict(dict)
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Wait(100)
	end
end

RegisterNetEvent("strin_actions:restrain", function()
	if((source == "" or GetInvokingResource() ~= nil)) then
		return
	end

    IsRestrained = true

	local ped = PlayerPedId()
	
	if(IsBeingAggressivelyArrested) then
		while true do
			Citizen.Wait(0)
			if(not IsBeingAggressivelyArrested) then
				break
			end
		end
	end

	LoadAnimDict(Animations.Default.Dict)

	TaskPlayAnim(ped, Animations.Default.Dict, Animations.Default.BeingArrested, 8.0, -8, -1, 49, 0, 0, 0, 0)
	SetEnableHandcuffs(ped, true)
	DisablePlayerFiring(ped, true)
	SetPedCanPlayGestureAnims(ped, false)
	RemoveAnimDict(Animations.Default.Dict)
	TriggerEvent("esx_policejob:handcuff") -- compatibility shit
	while IsRestrained do
		DisableControlAction(0, 24, true) -- Attack
		DisableControlAction(0, 257, true) -- Attack 2
		DisableControlAction(0, 25, true) -- Aim
		DisableControlAction(0, 263, true) -- Melee Attack 1

		DisableControlAction(0, 45, true) -- Reload
		DisableControlAction(0, 22, true) -- Jump
		DisableControlAction(0, 44, true) -- Cover
		DisableControlAction(0, 37, true) -- Select Weapon
		DisableControlAction(0, 23, true) -- Also 'enter'?

		DisableControlAction(0, 288,  true) -- Disable phone
		DisableControlAction(0, 289, true) -- Inventory
		DisableControlAction(0, 170, true) -- Animations
		DisableControlAction(0, 167, true) -- Job

		DisableControlAction(0, 0, true) -- Disable changing view
		DisableControlAction(0, 26, true) -- Disable looking behind
		DisableControlAction(0, 73, true) -- Disable clearing animation
		DisableControlAction(2, 199, true) -- Disable pause screen

		DisableControlAction(0, 59, true) -- Disable steering in vehicle
		DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
		DisableControlAction(0, 72, true) -- Disable reversing in vehicle

		DisableControlAction(2, 36, true) -- Disable going stealth

		DisableControlAction(0, 47, true)  -- Disable weapon
		DisableControlAction(0, 264, true) -- Disable melee
		DisableControlAction(0, 257, true) -- Disable melee
		DisableControlAction(0, 140, true) -- Disable melee
		DisableControlAction(0, 141, true) -- Disable melee
		DisableControlAction(0, 142, true) -- Disable melee
		DisableControlAction(0, 143, true) -- Disable melee
		DisableControlAction(0, 75, true)  -- Disable exit vehicle
		DisableControlAction(27, 75, true) -- Disable exit vehicle
		if(IsEntityPlayingAnim(cache.ped, Animations.Default.Dict, Animations.Default.BeingArrested, 3) ~= 1) then
			LoadAnimDict(Animations.Default.Dict)
			TaskPlayAnim(cache.ped, Animations.Default.Dict, Animations.Default.BeingArrested, 8.0, -8, -1, 49, 0.0, false, false, false)
			RemoveAnimDict(Animations.Default.Dict)
		end
		Citizen.Wait(0)
	end
end)

RegisterNetEvent("strin_actions:unrestrain", function()
	if(source == "" or GetInvokingResource() ~= nil) then
		return
	end
    IsRestrained = false
	local ped = PlayerPedId()

	ClearPedSecondaryTask(ped)
	SetEnableHandcuffs(ped, false)
	DisablePlayerFiring(ped, false)
	SetPedCanPlayGestureAnims(ped, true)
	TriggerEvent("esx_policejob:unrestrain") -- compatibility shit
end)

RegisterNetEvent("strin_actions:arrest", function(restrainType)
	if(source == "" or GetInvokingResource() ~= nil or (restrainType ~= "default" and restrainType ~= "aggressive")) then
		return
	end

	local ped = PlayerPedId()
	if(restrainType == "aggressive") then
		LoadAnimDict(Animations.Aggressive.Dict)
		TaskPlayAnim(ped, Animations.Aggressive.Dict, Animations.Aggressive.Arresting, 8.0, -8.0, 3500, 33, 0, false, false, false)
		RemoveAnimDict(Animations.Aggressive.Dict)
	elseif(restrainType == "default") then
		LoadAnimDict(Animations.Default.Dict)
		TaskPlayAnim(ped, Animations.Default.Dict, Animations.Default.Arresting, 8.0, -8, 5000, 49, 0, 0, 0, 0)
		RemoveAnimDict(Animations.Default.Dict)
	end
end)

RegisterNetEvent("strin_actions:getAggressivelyArrested", function(arresterNetId)
	if(source == "" or GetInvokingResource() ~= nil) then
		return
	end
	
	IsBeingAggressivelyArrested = true
	local ped = PlayerPedId()
	local arrestPlayerId = GetPlayerFromServerId(arresterNetId) 
	if(arrestPlayerId == -1) then
		return
	end
	local arresterPed = GetPlayerPed(arrestPlayerId)
	if(not DoesEntityExist(ped) or not DoesEntityExist(arresterPed)) then
		IsBeingAggressivelyArrested = false
		return
	end

	if((#(GetEntityCoords(ped) - GetEntityCoords(arresterPed))) > 10) then
		IsBeingAggressivelyArrested = false
		return
	end
	
	LoadAnimDict(Animations.Aggressive.Dict)

	AttachEntityToEntity(ped, arresterPed, 11816, -0.1, 0.45, 0.0, 0.0, 0.0, 20.0, false, false, false, false, 20, false)
	TaskPlayAnim(ped, Animations.Aggressive.Dict, Animations.Aggressive.BeingArrested, 8.0, -8.0, 4500, 33, 0, false, false, false)

	Citizen.Wait(1500)
	IsBeingAggressivelyArrested = false
	DetachEntity(ped, true, false)
	RemoveAnimDict(Animations.Aggressive.Dict)
end)