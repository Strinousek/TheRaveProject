--[[
---------------------------------------------------
LUXART VEHICLE CONTROL (FOR FIVEM)
---------------------------------------------------
Last revision: MAY 01 2017 (VERS. 1.01)
Coded by Lt.Caine
---------------------------------------------------
NOTES
	LVC will automatically apply to all emergency vehicles (vehicle class 18)
---------------------------------------------------
CONTROLS	
	Right indicator:	=	(Next Custom Radio Track)
	Left indicator:		-	(Previous Custom Radio Track)
	Hazard lights:	Backspace	(Phone Cancel)
	Toggle emergency lights:	Y	(Text Chat Team)
	Airhorn:	E	(Horn)
	Toggle siren:	,	(Previous Radio Station)
	Manual siren / Change siren tone:	N	(Next Radio Station)
	Auxiliary siren:	Down Arrow	(Phone Up)
---------------------------------------------------
]]

local count_bcast_timer = 0
local delay_bcast_timer = 200

local count_sndclean_timer = 0
local delay_sndclean_timer = 400

local actv_ind_timer = false
local count_ind_timer = 0
local delay_ind_timer = 180

local actv_lxsrnmute_temp = false
local srntone_temp = 0
local dsrn_mute = true

local state_indic = {}
local state_lxsiren = {}
local state_pwrcall = {}
local state_airmanu = {}

local ind_state_o = 0
local ind_state_l = 1
local ind_state_r = 2
local ind_state_h = 3

local snd_lxsiren = {}
local snd_pwrcall = {}
local snd_airmanu = {}

-- these models will use their real wail siren, as determined by their assigned audio hash in vehicles.meta
local eModelsWithFireSrn =
{
	"FIRETRUK",
}

-- models listed below will use AMBULANCE_WARNING as auxiliary siren
-- unlisted models will instead use the default wail as the auxiliary siren
local eModelsWithPcall =
{	
	"AMBULANCE",
	"FIRETRUK",
	"LGUARD",
}


---------------------------------------------------------------------
function ShowDebug(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(false, false)
end

---------------------------------------------------------------------
function useFiretruckSiren(veh)
	local model = GetEntityModel(veh)
	for i = 1, #eModelsWithFireSrn, 1 do
		if model == GetHashKey(eModelsWithFireSrn[i]) then
			return true
		end
	end
	return false
end

---------------------------------------------------------------------
function usePowercallAuxSrn(veh)
	local model = GetEntityModel(veh)
	for i = 1, #eModelsWithPcall, 1 do
		if model == GetHashKey(eModelsWithPcall[i]) then
			return true
		end
	end
	return false
end

---------------------------------------------------------------------
function CleanupSounds()
	if count_sndclean_timer > delay_sndclean_timer then
		count_sndclean_timer = 0
		for k, v in pairs(state_lxsiren) do
			if v > 0 then
				if not DoesEntityExist(k) or IsEntityDead(k) then
					if snd_lxsiren[k] ~= nil then
						StopSound(snd_lxsiren[k])
						ReleaseSoundId(snd_lxsiren[k])
						snd_lxsiren[k] = nil
						state_lxsiren[k] = nil
					end
				end
			end
		end
		for k, v in pairs(state_pwrcall) do
			if v == true then
				if not DoesEntityExist(k) or IsEntityDead(k) then
					if snd_pwrcall[k] ~= nil then
						StopSound(snd_pwrcall[k])
						ReleaseSoundId(snd_pwrcall[k])
						snd_pwrcall[k] = nil
						state_pwrcall[k] = nil
					end
				end
			end
		end
		for k, v in pairs(state_airmanu) do
			if v == true then
				if not DoesEntityExist(k) or IsEntityDead(k) or IsVehicleSeatFree(k, -1) then
					if snd_airmanu[k] ~= nil then
						StopSound(snd_airmanu[k])
						ReleaseSoundId(snd_airmanu[k])
						snd_airmanu[k] = nil
						state_airmanu[k] = nil
					end
				end
			end
		end
	else
		count_sndclean_timer = count_sndclean_timer + 1
	end
end

---------------------------------------------------------------------
function TogIndicStateForVeh(veh, newstate)
	if DoesEntityExist(veh) and not IsEntityDead(veh) then
		if newstate == ind_state_o then
			SetVehicleIndicatorLights(veh, 0, false) -- R
			SetVehicleIndicatorLights(veh, 1, false) -- L
		elseif newstate == ind_state_l then
			SetVehicleIndicatorLights(veh, 0, false) -- R
			SetVehicleIndicatorLights(veh, 1, true) -- L
		elseif newstate == ind_state_r then
			SetVehicleIndicatorLights(veh, 0, true) -- R
			SetVehicleIndicatorLights(veh, 1, false) -- L
		elseif newstate == ind_state_h then
			SetVehicleIndicatorLights(veh, 0, true) -- R
			SetVehicleIndicatorLights(veh, 1, true) -- L
		end
		state_indic[veh] = newstate
	end
end

---------------------------------------------------------------------
function TogMuteDfltSrnForVeh(veh, toggle)
	if DoesEntityExist(veh) and not IsEntityDead(veh) then
		DisableVehicleImpactExplosionActivation(veh, toggle)
	end
end

---------------------------------------------------------------------
function SetLxSirenStateForVeh(veh, newstate)
	if DoesEntityExist(veh) and not IsEntityDead(veh) then
		if newstate ~= state_lxsiren[veh] then
				
			if snd_lxsiren[veh] ~= nil then
				StopSound(snd_lxsiren[veh])
				ReleaseSoundId(snd_lxsiren[veh])
				snd_lxsiren[veh] = nil
			end
						
			if newstate == 1 then
				if useFiretruckSiren(veh) then
					TogMuteDfltSrnForVeh(veh, false)
				else
					snd_lxsiren[veh] = GetSoundId()	
					PlaySoundFromEntity(snd_lxsiren[veh], "VEHICLES_HORNS_SIREN_1", veh, 0, 0, 0)
					TogMuteDfltSrnForVeh(veh, true)
				end
				
			elseif newstate == 2 then
				snd_lxsiren[veh] = GetSoundId()
				PlaySoundFromEntity(snd_lxsiren[veh], "VEHICLES_HORNS_SIREN_2", veh, 0, 0, 0)
				TogMuteDfltSrnForVeh(veh, true)
			
			elseif newstate == 3 then
				snd_lxsiren[veh] = GetSoundId()
				if useFiretruckSiren(veh) then
					PlaySoundFromEntity(snd_lxsiren[veh], "VEHICLES_HORNS_AMBULANCE_WARNING", veh, 0, 0, 0)
				else
					PlaySoundFromEntity(snd_lxsiren[veh], "VEHICLES_HORNS_POLICE_WARNING", veh, 0, 0, 0)
				end
				TogMuteDfltSrnForVeh(veh, true)
				
			else
				TogMuteDfltSrnForVeh(veh, true)
				
			end				
				
			state_lxsiren[veh] = newstate
		end
	end
end

---------------------------------------------------------------------
function TogPowercallStateForVeh(veh, toggle)
	if DoesEntityExist(veh) and not IsEntityDead(veh) then
		if toggle == true then
			if snd_pwrcall[veh] == nil then
				snd_pwrcall[veh] = GetSoundId()
				if usePowercallAuxSrn(veh) then
					PlaySoundFromEntity(snd_pwrcall[veh], "VEHICLES_HORNS_AMBULANCE_WARNING", veh, 0, 0, 0)
				else
					PlaySoundFromEntity(snd_pwrcall[veh], "VEHICLES_HORNS_SIREN_1", veh, 0, 0, 0)
				end
			end
		else
			if snd_pwrcall[veh] ~= nil then
				StopSound(snd_pwrcall[veh])
				ReleaseSoundId(snd_pwrcall[veh])
				snd_pwrcall[veh] = nil
			end
		end
		state_pwrcall[veh] = toggle
	end
end

---------------------------------------------------------------------
function SetAirManuStateForVeh(veh, newstate)
	if DoesEntityExist(veh) and not IsEntityDead(veh) then
		if newstate ~= state_airmanu[veh] then
				
			if snd_airmanu[veh] ~= nil then
				StopSound(snd_airmanu[veh])
				ReleaseSoundId(snd_airmanu[veh])
				snd_airmanu[veh] = nil
			end
						
			if newstate == 1 then
				snd_airmanu[veh] = GetSoundId()
				if useFiretruckSiren(veh) then
					PlaySoundFromEntity(snd_airmanu[veh], "VEHICLES_HORNS_FIRETRUCK_WARNING", veh, 0, 0, 0)
				else
					PlaySoundFromEntity(snd_airmanu[veh], "SIRENS_AIRHORN", veh, 0, 0, 0)
				end
				
			elseif newstate == 2 then
				snd_airmanu[veh] = GetSoundId()
				PlaySoundFromEntity(snd_airmanu[veh], "VEHICLES_HORNS_SIREN_1", veh, 0, 0, 0)
			
			elseif newstate == 3 then
				snd_airmanu[veh] = GetSoundId()
				PlaySoundFromEntity(snd_airmanu[veh], "VEHICLES_HORNS_SIREN_2", veh, 0, 0, 0)
				
			end				
				
			state_airmanu[veh] = newstate
		end
	end
end


---------------------------------------------------------------------
RegisterNetEvent("lvc_TogIndicState_c")
AddEventHandler("lvc_TogIndicState_c", function(sender, newstate)
	local player_s = GetPlayerFromServerId(sender)
	if(player_s ~= -1) then
		local ped_s = GetPlayerPed(player_s)
		if DoesEntityExist(ped_s) and not IsEntityDead(ped_s) then
			if ped_s ~= GetPlayerPed(-1) then
				if IsPedInAnyVehicle(ped_s, false) then
					local veh = GetVehiclePedIsUsing(ped_s)
					TogIndicStateForVeh(veh, newstate)
				end
			end
		end
	end
end)

---------------------------------------------------------------------
RegisterNetEvent("lvc_TogDfltSrnMuted_c")
AddEventHandler("lvc_TogDfltSrnMuted_c", function(sender, toggle)
	local player_s = GetPlayerFromServerId(sender)
	if(player_s ~= -1) then
		local ped_s = GetPlayerPed(player_s)
		if DoesEntityExist(ped_s) and not IsEntityDead(ped_s) then
			if ped_s ~= GetPlayerPed(-1) then
				if IsPedInAnyVehicle(ped_s, false) then
					local veh = GetVehiclePedIsUsing(ped_s)
					TogMuteDfltSrnForVeh(veh, toggle)
				end
			end
		end
	end
end)

---------------------------------------------------------------------
RegisterNetEvent("lvc_SetLxSirenState_c")
AddEventHandler("lvc_SetLxSirenState_c", function(sender, newstate)
	local player_s = GetPlayerFromServerId(sender)
	if(player_s ~= -1) then
		local ped_s = GetPlayerPed(player_s)
		if DoesEntityExist(ped_s) and not IsEntityDead(ped_s) then
			if ped_s ~= GetPlayerPed(-1) then
				if IsPedInAnyVehicle(ped_s, false) then
					local veh = GetVehiclePedIsUsing(ped_s)
					SetLxSirenStateForVeh(veh, newstate)
				end
			end
		end
	end
end)

---------------------------------------------------------------------
RegisterNetEvent("lvc_TogPwrcallState_c")
AddEventHandler("lvc_TogPwrcallState_c", function(sender, toggle)
	local player_s = GetPlayerFromServerId(sender)
	if(player_s ~= -1) then
		local ped_s = GetPlayerPed(player_s)
		if DoesEntityExist(ped_s) and not IsEntityDead(ped_s) then
			if ped_s ~= GetPlayerPed(-1) then
				if IsPedInAnyVehicle(ped_s, false) then
					local veh = GetVehiclePedIsUsing(ped_s)
					TogPowercallStateForVeh(veh, toggle)
				end
			end
		end
	end
end)

---------------------------------------------------------------------
RegisterNetEvent("lvc_SetAirManuState_c")
AddEventHandler("lvc_SetAirManuState_c", function(sender, newstate)
	local player_s = GetPlayerFromServerId(sender)
	if(player_s ~= -1) then
		local ped_s = GetPlayerPed(player_s)
		if DoesEntityExist(ped_s) and not IsEntityDead(ped_s) then
			if ped_s ~= GetPlayerPed(-1) then
				if IsPedInAnyVehicle(ped_s, false) then
					local veh = GetVehiclePedIsUsing(ped_s)
					SetAirManuStateForVeh(veh, newstate)
				end
			end
		end
	end
end)

local lastVehicle = nil
AddEventHandler("esx:enteredVehicle", function()
	while true do
		CleanupSounds()
		local ped = PlayerPedId()
		local vehicle = GetVehiclePedIsIn(ped)
		if(vehicle == 0) then
			break
		end
		lastVehicle = vehicle
		if GetPedInVehicleSeat(vehicle, -1) == ped then
			
			DisableControlAction(0, 84, true) -- INPUT_VEH_PREV_RADIO_TRACK  
			DisableControlAction(0, 83, true) -- INPUT_VEH_NEXT_RADIO_TRACK 
			
			if state_indic[vehicle] ~= ind_state_o and state_indic[vehicle] ~= ind_state_l and state_indic[vehicle] ~= ind_state_r and state_indic[vehicle] ~= ind_state_h then
				state_indic[vehicle] = ind_state_o
			end
			
			-- INDIC AUTO CONTROL
			if actv_ind_timer == true then	
				if state_indic[vehicle] == ind_state_l or state_indic[vehicle] == ind_state_r then
					if GetEntitySpeed(vehicle) < 6 then
						count_ind_timer = 0
					else
						if count_ind_timer > delay_ind_timer then
							count_ind_timer = 0
							actv_ind_timer = false
							state_indic[vehicle] = ind_state_o
							PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
							TogIndicStateForVeh(vehicle, state_indic[veh])
							count_bcast_timer = delay_bcast_timer
						else
							count_ind_timer = count_ind_timer + 1
						end
					end
				end
			end
			
			
			--- IS EMERG VEHICLE ---
			if GetVehicleClass(vehicle) == 18 then
				
				local actv_manu = false
				local actv_horn = false
				
				DisableControlAction(0, 86, true) -- INPUT_VEH_HORN	
				DisableControlAction(0, 172, true) -- INPUT_CELLPHONE_UP 
				--DisableControlAction(0, 173, true) -- INPUT_CELLPHONE_DOWN
				--DisableControlAction(0, 174, true) -- INPUT_CELLPHONE_LEFT 
				--DisableControlAction(0, 175, true) -- INPUT_CELLPHONE_RIGHT 
				DisableControlAction(0, 81, true) -- INPUT_VEH_NEXT_RADIO
				DisableControlAction(0, 82, true) -- INPUT_VEH_PREV_RADIO
				DisableControlAction(0, 19, true) -- INPUT_CHARACTER_WHEEL 
				DisableControlAction(0, 85, true) -- INPUT_VEH_RADIO_WHEEL 
				DisableControlAction(0, 80, true) -- INPUT_VEH_CIN_CAM 
			
				SetVehRadioStation(vehicle, "OFF")
				SetVehicleRadioEnabled(vehicle, false)
				
				if state_lxsiren[vehicle] ~= 1 and state_lxsiren[vehicle] ~= 2 and state_lxsiren[vehicle] ~= 3 then
					state_lxsiren[vehicle] = 0
				end
				if state_pwrcall[vehicle] ~= true then
					state_pwrcall[vehicle] = false
				end
				if state_airmanu[vehicle] ~= 1 and state_airmanu[vehicle] ~= 2 and state_airmanu[vehicle] ~= 3 then
					state_airmanu[vehicle] = 0
				end
				
				if useFiretruckSiren(vehicle) and state_lxsiren[vehicle] == 1 then
					TogMuteDfltSrnForVeh(vehicle, false)
					dsrn_mute = false
				else
					TogMuteDfltSrnForVeh(vehicle, true)
					dsrn_mute = true
				end
				
				if not IsVehicleSirenOn(vehicle) and state_lxsiren[vehicle] > 0 then
					PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
					SetLxSirenStateForVeh(vehicle, 0)
					count_bcast_timer = delay_bcast_timer
				end
				if not IsVehicleSirenOn(vehicle) and state_pwrcall[vehicle] == true then
					PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
					TogPowercallStateForVeh(vehicle, false)
					count_bcast_timer = delay_bcast_timer
				end
			
				----- CONTROLS -----
				if not IsPauseMenuActive() then
				
					-- TOG DFLT SRN LIGHTS
					if IsDisabledControlJustReleased(0, 85) or IsDisabledControlJustReleased(0, 246) then
						if IsVehicleSirenOn(vehicle) then
							PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
							SetVehicleSiren(vehicle, false)
						else
							PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
							SetVehicleSiren(vehicle, true)
							count_bcast_timer = delay_bcast_timer
						end		
					
					-- TOG LX SIREN
					elseif IsDisabledControlJustReleased(0, 19) or IsDisabledControlJustReleased(0, 82) then
						local cstate = state_lxsiren[vehicle]
						if cstate == 0 then
							if IsVehicleSirenOn(vehicle) then
								PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1) -- on
								SetLxSirenStateForVeh(vehicle, 1)
								count_bcast_timer = delay_bcast_timer
							end
						else
							PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1) -- off
							SetLxSirenStateForVeh(vehicle, 0)
							count_bcast_timer = delay_bcast_timer
						end
						
					-- POWERCALL
					elseif IsDisabledControlJustReleased(0, 172) then
						if state_pwrcall[vehicle] == true then
							PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
							TogPowercallStateForVeh(vehicle, false)
							count_bcast_timer = delay_bcast_timer
						else
							if IsVehicleSirenOn(vehicle) then
								PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
								TogPowercallStateForVeh(vehicle, true)
								count_bcast_timer = delay_bcast_timer
							end
						end
						
					end
					
					-- BROWSE LX SRN TONES
					if state_lxsiren[vehicle] > 0 then
						if IsDisabledControlJustReleased(0, 80) or IsDisabledControlJustReleased(0, 81) then
							if IsVehicleSirenOn(vehicle) then
								local cstate = state_lxsiren[vehicle]
								local nstate = 1
								PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1) -- on
								if cstate == 1 then
									nstate = 2
								elseif cstate == 2 then
									nstate = 3
								else	
									nstate = 1
								end
								SetLxSirenStateForVeh(vehicle, nstate)
								count_bcast_timer = delay_bcast_timer
							end
						end
					end
								
					-- MANU
					if state_lxsiren[vehicle] < 1 then
						if IsDisabledControlPressed(0, 80) or IsDisabledControlPressed(0, 81) then
							actv_manu = true
						else
							actv_manu = false
						end
					else
						actv_manu = false
					end
					
					-- HORN
					if IsDisabledControlPressed(0, 86) then
						actv_horn = true
					else
						actv_horn = false
					end
				
				end
				
				---- ADJUST HORN / MANU STATE ----
				local hmanu_state_new = 0
				if actv_horn == true and actv_manu == false then
					hmanu_state_new = 1
				elseif actv_horn == false and actv_manu == true then
					hmanu_state_new = 2
				elseif actv_horn == true and actv_manu == true then
					hmanu_state_new = 3
				end
				if hmanu_state_new == 1 then
					if not useFiretruckSiren(vehicle) then
						if state_lxsiren[vehicle] > 0 and actv_lxsrnmute_temp == false then
							srntone_temp = state_lxsiren[vehicle]
							SetLxSirenStateForVeh(vehicle, 0)
							actv_lxsrnmute_temp = true
						end
					end
				else
					if not useFiretruckSiren(vehicle) then
						if actv_lxsrnmute_temp == true then
							SetLxSirenStateForVeh(vehicle, srntone_temp)
							actv_lxsrnmute_temp = false
						end
					end
				end
				if state_airmanu[vehicle] ~= hmanu_state_new then
					SetAirManuStateForVeh(vehicle, hmanu_state_new)
					count_bcast_timer = delay_bcast_timer
				end	
			end
			
				
			--- IS ANY LAND VEHICLE ---	
			if GetVehicleClass(vehicle) ~= 14 and GetVehicleClass(vehicle) ~= 15 and GetVehicleClass(vehicle) ~= 16 and GetVehicleClass(vehicle) ~= 21 then
			
				----- CONTROLS -----
				if not IsPauseMenuActive() then
				
					-- IND L
					if IsDisabledControlJustReleased(0, 84) then -- INPUT_VEH_PREV_RADIO_TRACK
						local cstate = state_indic[vehicle]
						if cstate == ind_state_l then
							state_indic[vehicle] = ind_state_o
							actv_ind_timer = false
							PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
						else
							state_indic[vehicle] = ind_state_l
							actv_ind_timer = true
							PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
						end
						TogIndicStateForVeh(vehicle, state_indic[vehicle])
						count_ind_timer = 0
						count_bcast_timer = delay_bcast_timer			
					-- IND R
					elseif IsDisabledControlJustReleased(0, 83) then -- INPUT_VEH_NEXT_RADIO_TRACK
						local cstate = state_indic[vehicle]
						if cstate == ind_state_r then
							state_indic[vehicle] = ind_state_o
							actv_ind_timer = false
							PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
						else
							state_indic[vehicle] = ind_state_r
							actv_ind_timer = true
							PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
						end
						TogIndicStateForVeh(vehicle, state_indic[vehicle])
						count_ind_timer = 0
						count_bcast_timer = delay_bcast_timer
					-- IND H
					elseif IsControlJustReleased(0, 202) then -- INPUT_FRONTEND_CANCEL / Backspace
						if GetLastInputMethod(0) then -- last input was with kb
							local cstate = state_indic[vehicle]
							if cstate == ind_state_h then
								state_indic[vehicle] = ind_state_o
								PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
							else
								state_indic[vehicle] = ind_state_h
								PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
							end
							TogIndicStateForVeh(vehicle, state_indic[vehicle])
							actv_ind_timer = false
							count_ind_timer = 0
							count_bcast_timer = delay_bcast_timer
						end
					end
				
				end
				
				
				----- AUTO BROADCAST VEH STATES -----
				if count_bcast_timer > delay_bcast_timer then
					count_bcast_timer = 0
					--- IS EMERG VEHICLE ---
					if GetVehicleClass(vehicle) == 18 then
						TriggerServerEvent("lvc_TogDfltSrnMuted_s", dsrn_mute)
						TriggerServerEvent("lvc_SetLxSirenState_s", state_lxsiren[vehicle])
						TriggerServerEvent("lvc_TogPwrcallState_s", state_pwrcall[vehicle])
						TriggerServerEvent("lvc_SetAirManuState_s", state_airmanu[vehicle])
					end
					--- IS ANY OTHER VEHICLE ---
					TriggerServerEvent("lvc_TogIndicState_s", state_indic[vehicle])
				else
					count_bcast_timer = count_bcast_timer + 1
				end
			
			end
			
		end
		Citizen.Wait(0)
	end
end)

AddEventHandler("esx:exitedVehicle", function(vehicle)
	if(lastVehicle == vehicle) then
		SetLxSirenStateForVeh(vehicle, 0)
	end
end)