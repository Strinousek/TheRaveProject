local IsTackling = false
local IsBeingTackled = false

local TACKLE_DICT = 'missmic2ig_11'
local TACKLE_CLIP = 'mic_2_ig_11_intro_goon'
local TACKLE_VICTIM_CLIP = 'mic_2_ig_11_intro_p_one'

RegisterCommand("tackle", function()
    if(cache.vehicle) then
        return
    end

    if(not IsControlPressed(0, 21)) then
        return
    end

    local playerId, playerPed = lib.getClosestPlayer(GetEntityCoords(cache.ped), 4.0)
    if(not playerPed) then
        return
    end

    if(IsEntityDead(playerPed)) then
        return
    end


    local playerServerId = GetPlayerServerId(playerId)
    TriggerServerEvent("strin_base:tacklePlayer", playerServerId)
end)

RegisterKeyMapping('tackle', '<FONT FACE="Righteous">Shodit hráče na zem (SHIFT +)</FONT>', 'KEYBOARD', "H")


RegisterNetEvent("strin_base:tackle", function()
    IsTackling = true

	RequestAnimDict(TACKLE_DICT)
	while not HasAnimDictLoaded(TACKLE_DICT) do
		Citizen.Wait(0)
	end

	TaskPlayAnim(cache.ped, TACKLE_DICT, TACKLE_CLIP, 8.0, -8.0, 3000, 0, 0, false, false, false)
	Citizen.Wait(3000)
	IsTackling = false
end)

RegisterNetEvent("strin_base:getTackled", function(tacklerId)
    local tacklerPlayerId = GetPlayerFromServerId(tacklerId)
    if(tacklerPlayerId == -1) then
        return
    end

	IsBeingTackled = true
	local tacklerPed = GetPlayerPed(tacklerPlayerId)

	RequestAnimDict(TACKLE_DICT)
	while not HasAnimDictLoaded(TACKLE_DICT) do
		Citizen.Wait(0)
	end

	AttachEntityToEntity(cache.ped, tacklerPed, 11816, 0.25, 0.5, 0.0, 0.5, 0.5, 180.0, false, false, false, false, 2, false)
	TaskPlayAnim(cache.ped, TACKLE_DICT, TACKLE_VICTIM_CLIP, 8.0, -8.0, 3000, 0, 0, false, false, false)

	Citizen.Wait(3000)
	DetachEntity(cache.ped, true, false)
    ExecuteCommand("+ragdoll")
	IsBeingTackled = false
end)