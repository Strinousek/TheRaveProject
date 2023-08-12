local RPEmotes = exports.rpemotes
local IsRestrained = false

Citizen.CreateThread(function()
	fontId = RegisterFontId('Righteous')
	font = fontId

    AddTextEntryByHash(`BLIP_OTHPLYR`, "<FONT FACE='Righteous'>Hráči~w~</FONT>")
    AddTextEntryByHash(`BLIP_PROPCAT`, "<FONT FACE='Righteous'>Nemovitosti~w~</FONT>")
    AddTextEntryByHash(`BLIP_APARTCAT`, "<FONT FACE='Righteous'>Vlastněná nemovitost~w~</FONT>")
    while GetResourceState("ox_inventory") ~= "started" do
        Citizen.Wait(0)
    end
    exports.ox_inventory:displayMetadata("ammoType", "Typ nábojů")
end)

SetRelationshipBetweenGroups(1, `AMBIENT_GANG_HILLBILLY`, `PLAYER`)
SetRelationshipBetweenGroups(1, `AMBIENT_GANG_BALLAS`, `PLAYER`)
SetRelationshipBetweenGroups(1, `AMBIENT_GANG_MEXICAN`, `PLAYER`)
SetRelationshipBetweenGroups(1, `AMBIENT_GANG_FAMILY`, `PLAYER`)
SetRelationshipBetweenGroups(1, `AMBIENT_GANG_MARABUNTE`, `PLAYER`)
SetRelationshipBetweenGroups(1, `AMBIENT_GANG_SALVA`, `PLAYER`)
SetRelationshipBetweenGroups(1, `GANG_1`, `PLAYER`)
SetRelationshipBetweenGroups(1, `GANG_2`, `PLAYER`)
SetRelationshipBetweenGroups(1, `GANG_9`, `PLAYER`)
SetRelationshipBetweenGroups(1, `GANG_10`, `PLAYER`)
SetRelationshipBetweenGroups(1, `FIREMAN`, `PLAYER`)
SetRelationshipBetweenGroups(1, `MEDIC`, `PLAYER`)
SetRelationshipBetweenGroups(1, `COP`, `PLAYER`)

AddEventHandler("esx:enteredVehicle", function(plate)
    while(true) do
        Citizen.Wait(0)
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped)
        if(vehicle == 0) then
            break
        end
        
        if(vehicle ~= 0 and IsControlPressed(2, 75) and not IsEntityDead(ped)) then
            SetVehicleEngineOn(vehicle, true, true, false)
            TaskLeaveVehicle(ped, vehicle, 0)
        end
        local roll = GetEntityRoll(vehicle)
        if (roll > 75.0 or roll < -75.0) and GetEntitySpeed(vehicle) < 2 then
            DisableControlAction(2,59,true) -- Disable left/right
            DisableControlAction(2,60,true) -- Disable up/down
        end

        local vehicleHealth = GetVehicleEngineHealth(vehicle)
        if(vehicleHealth > 101) then
            SetVehicleUndriveable(vehicle, false)
        elseif(vehicleHealth <= 101) then
            SetVehicleUndriveable(vehicle, true)
        end
    end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		DisableControlAction(0, 26, true)
		DisableControlAction(0, 36, true)
	end
end)

/*
RegisterNetEvent("strin_base:cancelEmote")
AddEventHandler("strin_base:cancelEmote", function()
    local ped = PlayerPedId()
    if(isDog()) then
        if(dogProps.isPlayingEmote) then
            cancelDogEmote()
        end
    else
        ClearPedTasksImmediately(ped)
    end
end)
*/

AddEventHandler("esx_policejob:handcuff", function()
    IsRestrained = true
    inHandsup = false
    crouched = false
end)

AddEventHandler("esx_policejob:unrestrain", function()
    IsRestrained = false
    inHandsup = false
    crouched = false
end)

local inHandsup = false
local crouched = false

function Handsup()
    local ped = PlayerPedId()
    inHandsup = not inHandsup
    if inHandsup then
        local dict = "random@mugging3"
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(0)
        end
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(0)
        end
        TaskPlayAnim(ped, dict, "handsup_standing_base", 2.0, 2.0, -1, 49, 0, false, false, false)
    else
        ClearPedSecondaryTask(ped)
    end
end

RegisterCommand("cancelanim", function()
    if(IsControlPressed(0, 21)) then
        return
    end

    local ped = PlayerPedId()
    if(IsRestrained) then
        return
    end
    if(inHandsup) then
        inHandsup = false
    end
    if(crouched) then
        crouched = false
        local animSet = "move_ped_crouched"
		SetPedMaxMoveBlendRatio(ped, 1.0)
		ResetPedMovementClipset(ped, 0.55)
		ResetPedStrafeClipset(ped)		
		SetPedCanPlayAmbientAnims(ped, true)
		SetPedCanPlayAmbientBaseAnims(ped, true)	
		ResetPedWeaponMovementClipset(ped)
		RemoveAnimSet(animSet)
    end
    RPEmotes:CanCancelEmote(true)
    RPEmotes:EmoteCancel(true)
    ClearPedTasks(ped)
    TriggerEvent("strin_base:cancelledAnimation")
end)

RegisterCommand("handsup", function()
    if(not IsControlPressed(0, 21) or IsPedInAnyVehicle(PlayerPedId())) then
        return
    end
    
    Handsup()
end)

RegisterCommand("crouch", function()
	local ped = PlayerPedId()
	local animSet = "move_ped_crouched"
	if(crouched) then
		SetPedMaxMoveBlendRatio(ped, 1.0)
		ResetPedMovementClipset(ped, 0.55)
		ResetPedStrafeClipset(ped)		
		SetPedCanPlayAmbientAnims(ped, true)
		SetPedCanPlayAmbientBaseAnims(ped, true)	
		ResetPedWeaponMovementClipset(ped)
		RemoveAnimSet(animSet)
		crouched = false
		return
	end

	if(DoesEntityExist(ped) and not IsEntityDead(ped) and not IsPlayerAnAnimal() and not IsPauseMenuActive() and not IsPedInAnyVehicle(ped)) then
		RequestAnimSet(animSet)
		while (not HasAnimSetLoaded( animSet) ) do 
			Citizen.Wait( 100 )
		end
		crouched = true
		while(true) do
			Citizen.Wait(0)
			if(not crouched) then
				break
			end
			SetPedMovementClipset( ped, "move_ped_crouched", 0.55 )
			SetPedStrafeClipset(ped, "move_ped_crouched_strafing")
		end
	end
end)

RegisterKeyMapping('crouch', '<FONT FACE="Righteous">Skrčit se</FONT>', 'KEYBOARD', "C")

RegisterKeyMapping("handsup", "<FONT FACE='Righteous'>Zvednout ruce (LSHIFT +)~</FONT>", "keyboard", "X")

RegisterKeyMapping("cancelanim", "<FONT FACE='Righteous'>Ukoncit animaci~</FONT>", "keyboard", "X")


