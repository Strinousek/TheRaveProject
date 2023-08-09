PedModels = PED_LIST["peds"]

local MP_FREEMODE_MALE = `mp_m_freemode_01`
local MP_FREEMODE_FEMALE = `mp_f_freemode_01`

IsEntityAPed = function(entity)
	local model = GetEntityModel(entity)
	return model ~= MP_FREEMODE_MALE and model ~= MP_FREEMODE_FEMALE
end

exports("IsEntityAPed", IsEntityAPed)

IsPlayerAPed = function()
	local ped = PlayerPedId()
	return IsEntityAPed(ped)
end

exports("IsPlayerAPed", IsPlayerAPed)

GetPedModels = function()
	return PedModels
end

exports("GetPedModels", GetPedModels)

AnimalModels = PED_LIST["animals"]

IsEntityAnAnimal = function(entity)
	local model = GetEntityModel(entity)
	return lib.table.contains(AnimalModels, model)
end

exports("IsEntityAnAnimal", IsEntityAnAnimal)

IsPlayerAnAnimal = function()
	local ped = PlayerPedId()
	return IsEntityAnAnimal(ped)
end

exports("IsPlayerAnAnimal", IsPlayerAnAnimal)

GetAnimalModels = function()
	return AnimalModels
end

exports("GetAnimalModels", GetAnimalModels)

AddEventHandler("esx:playerPedChanged", function(ped)
	local model = GetEntityModel(ped)
	if(model ~= `a_c_shepherd`) then
		return
	end
	while GetEntityModel(ped) == `a_c_shepherd` do
		RestorePlayerStamina(PlayerId(), 1.0)
		Citizen.Wait(1000)
	end
end)