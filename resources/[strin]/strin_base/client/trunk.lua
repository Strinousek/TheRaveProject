local InTrunk = false

local FrontTrunks = {}

local DisabledTrunks = {
	[1] = { ["name"]= "penetrator"},
	[2] = { ["name"]= "vacca"},
	[3] = { ["name"]= "monroe"},
	[4] = { ["name"]= "turismor"},
	[5] = { ["name"]= "osiris"},
	[6] = { ["name"]= "comet"},
	[7] = { ["name"]= "ardent"},
	[8] = { ["name"]= "jester"},
	[9] = { ["name"]= "nero"},
	[10] = { ["name"]= "nero2"},
	[11] = { ["name"]= "vagner"},
	[12] = { ["name"]= "infernus"},
	[13] = { ["name"]= "zentorno"},
	[14] = { ["name"]= "comet2"},
	[15] = { ["name"]= "comet3"},
	[16] = { ["name"]= "comet4"},
	[17] = { ["name"]= "bullet"},
	[18] = { ["name"]= "brioso"},
	[19] = { ["name"]= "dominator3"},
	[20] = { ["name"]= "issi3"},
	[21] = { ["name"]= "ninef"},
	[22] = { ["name"]= "comet2"},
	[23] = { ["name"]= "comet3"},
	[24] = { ["name"]= "felon2"},
	[25] = { ["name"]= "feltzer2"},
	[26] = { ["name"]= "infernus2"},
	[27] = { ["name"]= "monroe"},
	[28] = { ["name"]= "phoenix"},
	[29] = { ["name"]= "prairie"},
	[30] = { ["name"]= "premier"},
	[31] = { ["name"]= "rapidgt"},
	[32] = { ["name"]= "rapidgt2"},
	[33] = { ["name"]= "romero"},
	[34] = { ["name"]= "sultan"},
	[35] = { ["name"]= "vigero"},
	[36] = { ["name"]= "ztype"},
	[37] = { ["name"]= "gp1"},
	[38] = { ["name"]= "jester"},
	[39] = { ["name"]= "jester2"},
	[40] = { ["name"]= "italigtb"},
	[41] = { ["name"]= "italigtb2"},
	[42] = { ["name"]= "kuruma"},
	[43] = { ["name"]= "lynx"},
	[44] = { ["name"]= "nero"},
	[45] = { ["name"]= "nero2"},
	[46] = { ["name"]= "retinue"},
	[47] = { ["name"]= "seven70"},
	[48] = { ["name"]= "sultanrs"},
	[49] = { ["name"]= "tempesta"},
	[50] = { ["name"]= "trophytruck"},
	[51] = { ["name"]= "trophytruck2"},
	[52] = { ["name"]= "tropos"},
	[53] = { ["name"]= "turismo2"},
	[54] = { ["name"]= "windsor2"},
	[55] = { ["name"]= "xa21"},
	[56] = { ["name"]= "zr"},
}

local OffsetsTrunks = {
	[1] = { ["name"] = "taxi", ["yoffset"] = 0.0, ["zoffset"] = -0.5},
	[2] = { ["name"] = "buccaneer", ["yoffset"] = 0.5, ["zoffset"] = 0.0},
	[3] = { ["name"] = "peyote", ["yoffset"] = 0.35, ["zoffset"] = -0.15},
	[4] = { ["name"] = "regina", ["yoffset"] = 0.2, ["zoffset"] = -0.35},
	[5] = { ["name"] = "pigalle", ["yoffset"] = 0.2, ["zoffset"] = -0.15},
	[6] = { ["name"] = "blista2", ["yoffset"] = 0.0, ["zoffset"] = -0.15},
	[7] = { ["name"] = "buccaneer2", ["yoffset"] = 0.1, ["zoffset"] = -0.05},
	[8] = { ["name"] = "bodhi2", ["yoffset"] = -0.25, ["zoffset"] = -0.35},
	[9] = { ["name"] = "coquette3", ["yoffset"] = 0.0, ["zoffset"] = -0.10},
	[10] = { ["name"] = "dubsta", ["yoffset"] = 0.15, ["zoffset"] = -0.10},
	[11] = { ["name"] = "dubsta3", ["yoffset"] = 0.15, ["zoffset"] = -0.30},
	[12] = { ["name"] = "f620", ["yoffset"] = 0.00, ["zoffset"] = 0.15},
	[13] = { ["name"] = "gauntlet", ["yoffset"] = -0.10, ["zoffset"] = 0.0},
	[14] = { ["name"] = "gauntlet2", ["yoffset"] = -0.10, ["zoffset"] = 0.0},
	[15] = { ["name"] = "granger", ["yoffset"] = 0.0, ["zoffset"] = -0.20},
	[16] = { ["name"] = "habanero", ["yoffset"] = 0.20, ["zoffset"] = -0.20},
	[17] = { ["name"] = "manana", ["yoffset"] = 0.0, ["zoffset"] = -0.10},
	[18] = { ["name"] = "picador", ["yoffset"] = 0.0, ["zoffset"] = 0.10},
	[19] = { ["name"] = "rocoto", ["yoffset"] = 0.0, ["zoffset"] = -0.20},
	[20] = { ["name"] = "sabregt", ["yoffset"] = 0.60, ["zoffset"] = 0.10},
	[21] = { ["name"] = "stanier", ["yoffset"] = 0.10, ["zoffset"] = -0.10},
	[21] = { ["name"] = "sentinel3", ["yoffset"] = 0.05, ["zoffset"] = -0.30},
	[22] = { ["name"] = "superd", ["yoffset"] = -0.05, ["zoffset"] = -0.20},
	[23] = { ["name"] = "surano", ["yoffset"] = -0.15, ["zoffset"] = 0.10},
	[24] = { ["name"] = "tornado", ["yoffset"] = 0.0, ["zoffset"] = -0.10},
	[25] = { ["name"] = "tornado2", ["yoffset"] = 0.0, ["zoffset"] = -0.10},
	[26] = { ["name"] = "tornado3", ["yoffset"] = 0.0, ["zoffset"] = -0.10},
	[27] = { ["name"] = "blade", ["yoffset"] = 0.30, ["zoffset"] = -0.15},
	[28] = { ["name"] = "casco", ["yoffset"] = 0.0, ["zoffset"] = -0.15},
	[29] = { ["name"] = "chino", ["yoffset"] = 0.30, ["zoffset"] = -0.05},
	[30] = { ["name"] = "chino2", ["yoffset"] = 0.30, ["zoffset"] = -0.05},
	[31] = { ["name"] = "cognoscenti", ["yoffset"] = 0.0, ["zoffset"] = -0.15},
	[32] = { ["name"] = "contender", ["yoffset"] = 0.0, ["zoffset"] = -0.25},
	[33] = { ["name"] = "tampa", ["yoffset"] = 0.30, ["zoffset"] = 0.0},
	[34] = { ["name"] = "elegy", ["yoffset"] = 0.30, ["zoffset"] = -0.10},
	[35] = { ["name"] = "glendale", ["yoffset"] = 0.00, ["zoffset"] = -0.35},
	[36] = { ["name"] = "hotknife", ["yoffset"] = 0.00, ["zoffset"] = 0.15},
	[37] = { ["name"] = "mamba", ["yoffset"] = 0.00, ["zoffset"] = -0.05},
	[38] = { ["name"] = "massacro", ["yoffset"] = -0.10, ["zoffset"] = 0.05},
	[39] = { ["name"] = "massacro2", ["yoffset"] = -0.10, ["zoffset"] = 0.05},
	[40] = { ["name"] = "feltzer3", ["yoffset"] = 0.15, ["zoffset"] = -0.05},
	[41] = { ["name"] = "verlierer2", ["yoffset"] = 0.15, ["zoffset"] = 0.0},
	[42] = { ["name"] = "virgo", ["yoffset"] = 0.0, ["zoffset"] = -0.05},
	[43] = { ["name"] = "voodoo", ["yoffset"] = 0.0, ["zoffset"] = -0.05},
	[44] = { ["name"] = "voodoo2", ["yoffset"] = 0.0, ["zoffset"] = -0.05},
	[45] = { ["name"] = "warrener", ["yoffset"] = 0.20, ["zoffset"] = -0.15},
	[46] = { ["name"] = "dilettante", ["yoffset"] = 0.00, ["zoffset"] = -0.15}
}

local TrunkCamera = nil
function CamTrunk()
    local ped = PlayerPedId()
	if(not DoesCamExist(TrunkCamera)) then
        local coords = GetEntityCoords(ped)
		TrunkCamera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
		SetCamCoord(TrunkCamera, coords)
		SetCamRot(TrunkCamera, 0.0, 0.0, 0.0)
		SetCamActive(TrunkCamera, true)
		RenderScriptCams(true, false, 0, true, true)
		SetCamCoord(TrunkCamera, coords)
	end
    local heading = GetEntityHeading(ped)
	--NetworkSetTalkerProximity(0.2)
	AttachCamToEntity(TrunkCamera, ped, -1.0,-2.5, 1.0, true)
	SetCamRot(TrunkCamera, -15.0, 0.0, heading-40.0 )
end

function CamDisable()
	RenderScriptCams(false, false, 0, 1, 0)
	DestroyCam(TrunkCamera, false)
end

function TrunkOffset(veh)
	for i=1,#OffsetsTrunks do
		if GetEntityModel(veh) == GetHashKey(OffsetsTrunks[i]["name"]) then
			return i
		end
	end
	return 0
end

function DisabledCarCheck(vehicle)
	for i =1, #DisabledTrunks do
		if GetEntityModel(vehicle) == GetHashKey(DisabledTrunks[i]["name"]) then
			return true
		end
	end
	return false
end

function FrontTrunkCheck(vehicle)
	for i=1, #FrontTrunks do
		if GetEntityModel(vehicle) == GetHashKey(FrontTrunks[i]) then
			return true
		end
	end
	return false
end

local TrunkPlate = nil
local TrunkVehicle = nil

Citizen.CreateThread(function()
    AddTextEntry("STRIN_BASE:TRUNK", "<FONT FACE='Righteous'>~g~<b>[G]</b>~s~ Vylézt~</FONT>")
end)
function PutInTrunk(vehicle)
	local disabledCar = DisabledCarCheck(vehicle)
	if disabledCar then
		return 
	end
	if not DoesVehicleHaveDoor(vehicle, 6) and DoesVehicleHaveDoor(vehicle, 5) and IsThisModelACar(GetEntityModel(vehicle)) then
		SetVehicleDoorOpen(vehicle, 5, 1, 1)
		local ped = PlayerPedId()
		local d1,d2 = GetModelDimensions(GetEntityModel(vehicle))
		if d2["z"] > 2.4 then
			return
		end

		TrunkPlate = GetVehicleNumberPlateText(vehicle)
		InTrunk = true
		local testdic = "fin_ext_p1-7"
		local testanim = "cs_devin_dual-7"
		RequestAnimDict(testdic)
		while not HasAnimDictLoaded(testdic) do
			Citizen.Wait(100)
		end

		SetBlockingOfNonTemporaryEvents(ped, true)
		SetPedSeeingRange(ped, 0.0)
		SetPedHearingRange(ped, 0.0)
		SetPedFleeAttributes(ped, 0, false)
		SetPedKeepTask(ped, true)
		DetachEntity(ped)
		ClearPedTasks(ped)
		DoScreenFadeOut(10)
		TaskPlayAnim(ped, testdic, testanim, 8.0, 8.0, -1, 1, 999.0, 0, 0, 0)
		DecorSetInt(vehicle, "GamemodeCar", 955)
		local offsetId = TrunkOffset(vehicle)

		if offsetId > 0 then
			AttachEntityToEntity(ped, vehicle, 0, -0.1, (d1.y+0.85) + OffsetsTrunks[offset]?.yoffset,(d2.z-0.87) + OffsetsTrunks[offset]?.zoffset, 0, 0, 40.0, 1, 1, 1, 1, 1, 1)
		else
			AttachEntityToEntity(ped, vehicle, 0, -0.1, d1.y+0.85,d2.z-0.87, 0, 0, 40.0, 1, 1, 1, 1, 1, 1)
		end
		Citizen.Wait(1000)
		DoScreenFadeIn(1000)

		TrunkVehicle = vehicle

		while InTrunk do

			CamTrunk()

			Citizen.Wait(0)

            DisplayHelpTextThisFrame("STRIN_BASE:TRUNK")

			/*if IsControlJustReleased(0,38) then

				if GetVehicleDoorAngleRatio(veh, 5) > 0.0 then
					SetVehicleDoorShut(veh, 5, 1, 0)
				else
					SetVehicleDoorOpen(veh, 5, 1, 0)
				end
			end*/
			if IsControlJustReleased(0,47) then
				InTrunk = false
			end

			if GetVehicleEngineHealth(vehicle) < 100.0 or not DoesEntityExist(vehicle) then
				InTrunk = false
				TrunkVehicle = nil
				TrunkPlate = nil
			end

			if not IsEntityPlayingAnim(ped, testdic, testanim, 3) then
				TaskPlayAnim(ped, testdic, testanim, 8.0, 8.0, -1, 1, 999.0, 0, 0, 0)
			end
		end

		DoScreenFadeOut(10)
		Citizen.Wait(1000)
		CamDisable()

		DetachEntity(ped)

		if DoesEntityExist(vehicle) then
			local trunkPedPosition = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, d1.y-0.5, 0.0)
			SetEntityCoords(ped, trunkPedPosition)
		end
		DoScreenFadeIn(2000)
	end
end

RegisterNetEvent('strin_base:forceTrunkSelf')
AddEventHandler('strin_base:forceTrunkSelf', function()
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end
	local ped = PlayerPedId()
	local coords = GetEntityCoords(ped)
	local offsetCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 100.0, 0.0)
	local vehicle = ESX.Game.GetVehicleInDirection()

	if DoesEntityExist(vehicle) then
		local d1,d2 = GetModelDimensions(GetEntityModel(vehicle))
		local trunkCoords = GetOffsetFromEntityInWorldCoords(vehicle, 0.0,d1.y-0.5,0.0)
		if #(trunkCoords - coords) > 1.0 then
			ESX.ShowNotification("Příliš daleko!", { type = "error" })
			return
		end

		local driverPed = GetPedInVehicleSeat(vehicle, -1)
		if DoesEntityExist(driverPed) and not IsPedAPlayer(driverPed) then
			ESX.ShowNotification("NPC Vozidlo!", { type = "error" })
			return
		end

		local lockStatus = GetVehicleDoorLockStatus(vehicle)
		if lockStatus ~= 1 and lockStatus ~= 0 then
			ESX.ShowNotification("Zamčeno!", { type = "error" })
			return
		end
		DecorSetInt(vehicle, "GamemodeCar", 955)
		--SetEntityAsMissionEntity(vehicle, false, true)

		PutInTrunk(vehicle)
	end
end)

RegisterNetEvent('strin_base:forceTrunk', function()
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end
    local ped = PlayerPedId()
	local coords = GetEntityCoords(ped)
	local offsetCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 100.0, 0.0)
	local vehicle = ESX.Game.GetVehicleInDirection()

	if DoesEntityExist(vehicle) then
        local closestPlayer, distanceToClosestPlayer = ESX.Game.GetClosestPlayer()
		local d1,d2 = GetModelDimensions(GetEntityModel(vehicle))
		local trunkCoords = GetOffsetFromEntityInWorldCoords(vehicle, 0.0,d1.y-0.5,0.0)
		if #(trunkCoords - coords) > 1.0 then
			ESX.ShowNotification("Příliš daleko!", { type = "error" })
			return
		end

		local driverPed = GetPedInVehicleSeat(vehicle, -1)
		if DoesEntityExist(driverPed) and not IsPedAPlayer(driverPed) then
			ESX.ShowNotification("NPC Vozidlo!", { type = "error" })
			return
		end

		local lockStatus = GetVehicleDoorLockStatus(vehicle)
		if lockStatus ~= 1 and lockStatus ~= 0 then
			ESX.ShowNotification("Zamčeno!", { type = "error" })
			return
		end
		DecorSetInt(vehicle, "GamemodeCar", 955)
		--SetEntityAsMissionEntity(vehicle, false, true)

        local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)
        TriggerServerEvent('strin_base:requestforceTrunk', GetPlayerServerId(closestPlayer), vehicleNetId)
	end
end)