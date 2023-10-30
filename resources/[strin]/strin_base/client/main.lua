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
    Citizen.Wait(500)
    exports.ox_inventory:displayMetadata("ammoType", "Typ nábojů")
end)

/*SetRelationshipBetweenGroups(1, `AMBIENT_GANG_HILLBILLY`, `PLAYER`)
SetRelationshipBetweenGroups(1, `AMBIENT_GANG_BALLAS`, `PLAYER`)
SetRelationshipBetweenGroups(1, `AMBIENT_GANG_MEXICAN`, `PLAYER`)
SetRelationshipBetweenGroups(1, `AMBIENT_GANG_FAMILY`, `PLAYER`)
SetRelationshipBetweenGroups(1, `AMBIENT_GANG_MARABUNTE`, `PLAYER`)
SetRelationshipBetweenGroups(1, `AMBIENT_GANG_SALVA`, `PLAYER`)
SetRelationshipBetweenGroups(1, `GANG_1`, `PLAYER`)
SetRelationshipBetweenGroups(1, `GANG_2`, `PLAYER`)
SetRelationshipBetweenGroups(1, `GANG_9`, `PLAYER`)
SetRelationshipBetweenGroups(1, `GANG_10`, `PLAYER`)*/
SetRelationshipBetweenGroups(1, `FIREMAN`, `PLAYER`)
SetRelationshipBetweenGroups(1, `MEDIC`, `PLAYER`)
SetRelationshipBetweenGroups(1, `COP`, `PLAYER`)


IsShuffleDisabled = true

function SetShuffDisabled(flag)
	IsShuffleDisabled = flag
end

local IsFinderActive = false

AddEventHandler("esx:playerPedChanged", function(ped)
    SetEntityMaxHealth(ped, 200)
end)

RegisterNetEvent("strin_base:setClipboard", function(text)
    lib.setClipboard(text)
    IsFinderActive = false
end)

RegisterNetEvent("strin_base:startObjectFinder", function(objectModelHash)
    IsFinderActive = true
    local alreadySentObjects = {}
    while true do
        if(not IsFinderActive) then
            for i=1, #alreadySentObjects do
                DeleteBlip("object_"..i)
            end
            break
        end
        local objects = lib.getNearbyObjects(GetEntityCoords(cache.ped), 50.0)
        for i=1, #objects do
            if(GetEntityModel(objects[i].object) == objectModelHash) then
                for j=1, #alreadySentObjects do
                    if(lib.table.matches(alreadySentObjects[j].coords, objects[i].coords)) then
                        goto skipLoop
                    end
                end
                table.insert(alreadySentObjects, objects[i])
                CreateBlip({
                    id = "object_"..#alreadySentObjects,
                    coords = objects[i].coords,
                    sprite = 1,
                    colour = 3,
                    label = "Objekt #"..#alreadySentObjects
                })
                TriggerServerEvent("strin_base:foundObject", objects[i])
            end
            ::skipLoop::
        end
        Citizen.Wait(0)
    end
end)

RegisterNetEvent("strin_base:executeCommand", function(commandName, message)
    ExecuteCommand(commandName.." "..message)
end)

RegisterNetEvent("strin_base:seatShuffle", function()
	if cache.vehicle then
		SetShuffDisabled(false)
		Citizen.Wait(5000)
		SetShuffDisabled(true)
	else
        ESX.ShowNotification("Nejste ve vozidle!", { type = "error" })
		CancelEvent()
	end
end)

RegisterCommand("shuff", function(source, args)
    TriggerEvent("strin_base:seatShuffle")
end, false)

lib.onCache("vehicle", function(value)
    if(value) then
        local vehicle = value
        local vehicleClass = GetVehicleClass(vehicle)
        if(vehicleClass == 13) then
            return
        end
        while(true) do
            Citizen.Wait(0)
            local ped = cache.ped or PlayerPedId()
            if(not cache.vehicle) then
                break
            end

            if(IsShuffleDisabled) then
                local passenger = GetPedInVehicleSeat(vehicle, 0) 
                if passenger == ped then
                    if GetIsTaskActive(ped, 165) then
                        SetPedIntoVehicle(ped, vehicle, 0)
                    end
                end
            end

            if(IsControlPressed(2, 75) and not IsEntityDead(ped)) then
                Citizen.Wait(150)
                if(IsControlPressed(2, 75) and not IsEntityDead(ped)) then
                    SetVehicleEngineOn(vehicle, true, true, false)
                    if(IsControlPressed(2, 21)) then
                        TaskLeaveVehicle(ped, vehicle, 256)
                    else
                        TaskLeaveVehicle(ped, vehicle, 0)
                    end
                end
            end
            local roll = GetEntityRoll(vehicle)
            if (roll > 75.0 or roll < -75.0) and GetEntitySpeed(vehicle) < 2 then
                DisableControlAction(2, 59, true) -- Disable left/right
                DisableControlAction(2, 60, true) -- Disable up/down
            end
    
            local vehicleHealth = GetVehicleEngineHealth(vehicle)
            if(vehicleHealth > 101) then
                SetVehicleUndriveable(vehicle, false)
            elseif(vehicleHealth <= 101) then
                SetVehicleUndriveable(vehicle, true)
            end
        end
    end
end)

local ShowBlackBars = false

RegisterCommand("bb", function()
    ShowBlackBars = not ShowBlackBars
end)

local DENSITY_MULTIPLIER = 0.5
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if(not cache.vehicle) then
            DisableControlAction(0, 26, true)
            if IsPlayerFreeAiming(cache.playerId) and IsControlPressed(0, 25) then
                DisableControlAction(0, 22, true)
            end
        end
		--DisableControlAction(0, 36, true)

        if(ShowBlackBars) then
            DrawRect(1.0, 1.0, 2.0, 0.25, 0, 0, 0, 255)
            DrawRect(1.0, 0.0, 2.0, 0.25, 0, 0, 0, 255)
        end

	    SetVehicleDensityMultiplierThisFrame(DENSITY_MULTIPLIER)
	    SetPedDensityMultiplierThisFrame(DENSITY_MULTIPLIER)
	    SetRandomVehicleDensityMultiplierThisFrame(DENSITY_MULTIPLIER)
	    SetParkedVehicleDensityMultiplierThisFrame(DENSITY_MULTIPLIER)
	    SetScenarioPedDensityMultiplierThisFrame(DENSITY_MULTIPLIER, DENSITY_MULTIPLIER)
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

local IsDead = false

AddEventHandler("esx_policejob:handcuff", function()
    IsRestrained = true
    inHandsup = false
    crouched = false
    exports.ox_target:disableTargeting(true)
end)

AddEventHandler("esx:onPlayerDeath", function()
    IsDead = true
end)

AddEventHandler("esx:onPlayerSpawn", function()
    IsDead = false
end)

AddEventHandler("esx_policejob:unrestrain", function()
    IsRestrained = false
    inHandsup = false
    crouched = false
    if(not IsDead) then
        exports.ox_target:disableTargeting(false)
    end
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

AddEventHandler("strin_base:cancelledAnimation", function()
    if(not WasEventCanceled()) then
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
    end
end)

RegisterCommand("cancelanim", function()
    if(IsControlPressed(0, 21)) then
        return
    end

    TriggerEvent("strin_base:cancelledAnimation")
end)

AddEventHandler("strin_base:handsup", function()
    if(IsPedInAnyVehicle(PlayerPedId())) then
        return
    end
    
    Handsup()
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

RegisterCommand("+takeplayerout", function()
    if(cache.vehicle) then
        return
    end
    local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 3.0)
    if(not vehicle) then
        return
    end
    if(IsControlPressed(0, 21) and GetRelationshipBetweenGroups("player", "player") == 1) then
        local playerId, playerPed = lib.getClosestPlayer(GetEntityCoords(cache.ped), 3.0)
        if(not playerId) then
            return
        end
        local closestOccupiedSeatIndex = nil
        for i=-1, GetVehicleMaxNumberOfPassengers(vehicle) - 1 do
            local ped = GetPedInVehicleSeat(vehicle, i)
            if(ped ~= 0 and ped == playerPed) then
                closestOccupiedSeatIndex = i
                break
            end
        end
        if(not closestOccupiedSeatIndex) then
            ESX.ShowNotification("Nebylo nalezené žádné okupované místo ve vozidle!", { type = "error" })
            return
        end
        SetRelationshipBetweenGroups(2, 'player', 'player')
        TaskEnterVehicle(cache.ped, vehicle, 1.0, closestOccupiedSeatIndex, 1.0, 8, 0)
        local touchCount = 0
        while true do
            if(IsEntityTouchingEntity(cache.ped, playerPed)) then
                touchCount += 1
            end
            if(touchCount >= 4) then
                ClearPedTasksImmediately(cache.ped)
                break
            end
            Citizen.Wait(200)
        end
    end
end)

RegisterCommand("-takeplayerout", function()
    if(cache.vehicle) then
        return
    end
    Citizen.Wait(3000)
    if(GetRelationshipBetweenGroups("player", "player") == 2) then
        SetRelationshipBetweenGroups(1, 'player', 'player')
    end
end)

RegisterKeyMapping('+takeplayerout', '<FONT FACE="Righteous">Vytáhnout hráče z vozidla (SHIFT +)</FONT>', 'KEYBOARD', "J")

RegisterKeyMapping('crouch', '<FONT FACE="Righteous">Skrčit se</FONT>', 'KEYBOARD', "C")
RegisterKeyMapping("handsup", "<FONT FACE='Righteous'>Zvednout ruce (LSHIFT +)~</FONT>", "keyboard", "X")
RegisterKeyMapping("cancelanim", "<FONT FACE='Righteous'>Ukoncit animaci~</FONT>", "keyboard", "X")


