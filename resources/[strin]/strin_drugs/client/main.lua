DrugEffectStrength = 0.0

local GANG_AREAS = {
    vector3(217.30010986328, -1739.8660888672, 28.951532363892),
    vector3(337.65951538086, -2044.3520507813, 21.195701599121),
    vector3(556.69750976563, -1834.1633300781, 26.58028793335),
    vector3(-131.70149230957, -2135.837890625, 15.942228317261),
    vector3(-580.71868896484, -1696.7685546875, 24.824825286865),
    vector3(-222.70825195313, -1427.1926269531, 32.94482421875),
    vector3(-157.13949584961, -1622.6182861328, 37.004825592041),
    vector3(80.161987304688, -1908.2202148438, 24.824825286865),
    vector3(174.37782287598, -1752.5985107422, 32.94482421875),
}

RegisterNetEvent("strin_drugs:useAlcohol", function(alcoholStrength)
    RequestAnimDict("mp_suicide")
    while not HasAnimDictLoaded("mp_suicide") do
        Citizen.Wait(0)
    end
    TaskStartScenarioInPlace(cache.ped, "WORLD_HUMAN_PARTYING", 0, true)
    Citizen.Wait(3000)
    ESX.ShowNotification("Yes! Tohle kope!")
    ClearPedTasksImmediately(cache.ped)
    SetTimecycleModifier("spectator5")
    SetPedIsDrunk(cache.ped, true)
    SetPedMotionBlur(cache.ped, true)
    SetPedMovementClipset(cache.ped, "MOVE_M@DRUNK@SLIGHTLYDRUNK", true)
    ShakeGameplayCam("DRUNK_SHAKE", 0.1)
    --SetRunSprintMultiplierForPlayer(cache.playerId, 1.2) 
    local startingStrength = DrugEffectStrength
    while DrugEffectStrength < (startingStrength + (alcoholStrength / 100)) do
        DrugEffectStrength += 0.001
        SetTimecycleModifierStrength(DrugEffectStrength)
        Citizen.Wait(50)
    end
    
    Citizen.Wait(45000)
    --SetPedMoveRateOverride(cache.playerId, 1.0)
    --SetRunSprintMultiplierForPlayer(cache.playerId, 1.0)

    while DrugEffectStrength > 0 do
        DrugEffectStrength -= 0.001
        SetTimecycleModifierStrength(DrugEffectStrength)
        Citizen.Wait(0)
    end
    DrugEffectStrength = 0.0
    ShakeGameplayCam("DRUNK_SHAKE", 0.0)
    ResetPedMovementClipset(cache.ped, 0)
    SetPedMotionBlur(cache.ped, false)
    ClearTimecycleModifier()
end)


RegisterNetEvent("strin_drugs:receiveDrugOffer", function(offer)
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end
        

    local entity = NetworkGetEntityFromNetworkId(offer.pedNetId)
    local releaseEntity = function()
        ClearPedTasks(entity)
        FreezeEntityPosition(entity, false)
    end
    lib.registerContext({
        id = "drug_offer",
        title = "Nabídka",
        onExit = function()
            TriggerServerEvent("strin_drugs:finishDrugOffer", "DECLINE")
            releaseEntity()
        end,
        options = {
            {
                title = ("Přijmout (%sx - %s$)"):format(offer.amount, ESX.Math.GroupDigits(offer.total)),
                icon = "fas fa-dollar-sign",
                iconColor = "#2ecc71",
                onSelect = function()
                    TriggerServerEvent("strin_drugs:finishDrugOffer", "ACCEPT")
                    releaseEntity()
                end,
            },
            {
                title = "Odmítnout",
                icon = "fas fa-times",
                iconColor = "#e74c3c",
                onSelect = function()
                    TriggerServerEvent("strin_drugs:finishDrugOffer", "DECLINE")
                    releaseEntity()
                end,
            },
        }
    })
    lib.showContext("drug_offer")
end)

function OnDrugSelect(data, drug)
    local isAnimal = GetPedType(data.entity) == 28
    if(isAnimal) then

        RequestAnimDict("dancing_wave_part_one@anim")
        while not HasAnimDictLoaded("dancing_wave_part_one@anim") do
            Citizen.Wait(0)
        end
        NetworkRequestControlOfEntity(data.entity)
        while NetworkGetEntityOwner(data.entity) ~= NetworkGetEntityOwner(cache.ped) do
            Citizen.Wait(0)
        end
        TaskPlayAnim(
            data.entity, 
            "dancing_wave_part_one@anim", 
            "headspin", 
            5.0, 
            5.0, 
            5000, 
            1, 
            0, 
            false, 
            false, 
            false
        )
        TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 4.0, "easteregg1", 0.6)
        RemoveAnimDict("dancing_wave_part_one@anim")
        ESX.ShowNotification("Už se to roztáčí!")
        return
    end
    local ped = PlayerPedId()
    TaskStandStill(data.entity, 1.0)
    FreezeEntityPosition(data.entity, true)
    SetEntityHeading(data.entity, GetEntityHeading(ped) + 180.0)
    local netId = NetworkGetNetworkIdFromEntity(data.entity)
    local input = lib.inputDialog('Množství', {
        {
            type = "number",
        }
    })

    if not input then
        ClearPedTasks(data.entity)
        FreezeEntityPosition(data.entity, false)
        return
    end
    TriggerServerEvent("strin_drugs:requestDrugOffer", netId, drug, input[1])
end

function OnDrugInteract(entity, drug)
    local drugCount = Inventory:GetItemCount(drug)
    /*
        local isNotAnimal = GetPedType(entity) ~= 28
        return not Entity(entity).state.recentlyOffered and not IsEntityDead(entity) and isNotAnimal and jointCount > 0 and NetworkGetEntityOwner(entity) ~= -1
    */
    return not Entity(entity).state.recentlyOffered and not IsEntityDead(entity) and drugCount > 0 and NetworkGetEntityOwner(entity) ~= -1
end

Citizen.CreateThread(function ()
    Target:addGlobalPed({
        {
            label = "Nabídnout joint",
            icon = "fa-solid fa-joint",
            onSelect = function(data)
                OnDrugSelect(data, "joint")
            end,
            canInteract = function(entity)
                return OnDrugInteract(entity, "joint")
            end,
        },
        {
            label = "Nabídnout sáček s kokainem",
            icon = "fa-solid fa-wolf-pack-battalion",
            onSelect = function(data)
                OnDrugSelect(data, "coke_pooch")
            end,
            canInteract = function(entity)
                return OnDrugInteract(entity, "coke_pooch")
            end,
        },
        {
            label = "Nabídnout sáček s methem",
            icon = "fa-solid fa-smog",
            onSelect = function(data)
                OnDrugSelect(data, "meth_pooch")
            end,
            canInteract = function(entity)
                return OnDrugInteract(entity, "meth_pooch")
            end,
        },
        {
            label = "Nabídnout sáček s heroinem",
            icon = "fa-solid fa-pills",
            onSelect = function(data)
                OnDrugSelect(data, "heroin_pooch")
            end,
            canInteract = function(entity)
                return OnDrugInteract(entity, "heroin_pooch")
            end,
        },
    })
end)

function DrawFloatingText(entry, coords)
	BeginTextCommandDisplayHelp(entry)
	SetFloatingHelpTextWorldPosition(1, coords)
	SetFloatingHelpTextStyle(1, 1, 72, -1, 3, 0)
	EndTextCommandDisplayHelp(2, false, false, -1)
	SetFloatingHelpTextWorldPosition(0, coords.x, coords.y, coords.z)
end

function IsInGangArea()
    local isInArea = false
    local coords = GetEntityCoords(cache.ped)
    for i=1, #GANG_AREAS do
        local distance = #(coords - GANG_AREAS[i])
        if(distance < 80) then
            isInArea = true
            break
        end
    end
    return isInArea
end

local GANG_NAMES = {
    "g_m_y", "balla", "grove", "vagos", "soucent", "punk", "fam"
}

function IsModelGangster(modelName)
    local isGangster = false
    if(modelName) then
        for i=1, #GANG_NAMES do
            if(modelName:find(GANG_NAMES[i])) then
                isGangster = true
                break
            end
        end
    end
    return isGangster
end