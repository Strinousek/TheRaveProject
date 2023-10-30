Target = exports.ox_target
Inventory = exports.ox_inventory
Base = exports.strin_base

local JobBlips = {}

RegisterCommand("duty", function(source, args)
	TriggerServerEvent("strin_switchjob:duty")
end)

Citizen.CreateThread(function()
    for k,v in pairs(Jobs) do
        local points = {}
        for pointType, point in pairs(v.Zones or {}) do
            for i=1, #point do
                points[#points + 1] = {
                    coords = (pointType ~= "Helipads" and pointType ~= "Shops") and point[i] or point[i].coords,
                    id = i,
                    type = pointType,
                }
            end
        end
        
        for _,point in pairs(points) do
            local options = {}
            if(point.type == "Storages") then
                options[#options + 1] = {
                    label = "Otevřít sklad",
                    onSelect = function()
                        TriggerServerEvent("strin_jobs:requestStash", k, point.type)
                    end
                }
            end
            if(point.type == "Armories") then
                options[#options + 1] = {
                    label = "Otevřít zbrojnici",
                    icon = "fa-solid fa-person-rifle",
                    onSelect = function()
                        TriggerServerEvent("strin_jobs:requestStash", k, point.type)
                    end
                }
            end
            if(point.type == "BossOffices") then
                options[#options + 1] = {
                    label = "Správa společnosti",
                    icon = "fa-solid fa-network-wired",
                    onSelect = function()
                        TriggerServerEvent("strin_jobs:requestBossOffice", k)
                    end,
                    canInteract = function()
                        return ESX.PlayerData.job and next(ESX.PlayerData.job) and (ESX.PlayerData.job.name == k and (
                            ESX.PlayerData.job.grade_name == "boss" or
                            ESX.PlayerData.job.grade_name == "manager"
                        ))
                    end
                }
            end
            if(point.type == "Shops") then
                local target = Jobs[k].Zones["Shops"][point.id].target
                local icon = nil
                if(target == "Armories") then
                    icon = "fa-solid fa-person-rifle"
                end
                options[#options + 1] = {
                    label = ShopLabels[target],
                    icon = icon,
                    onSelect = function()
                        OpenShopMenu(point.id)
                    end,
                    canInteract = function()
                        return ESX.PlayerData.job and next(ESX.PlayerData.job) and (ESX.PlayerData.job.name == k and (
                            ESX.PlayerData.job.grade_name == "boss" or
                            ESX.PlayerData.job.grade_name == "manager"
                        ))
                    end
                }
            end
            if(point.type == "Helipads") then
                local helipad = Jobs[k].Zones.Helipads[point.id]
                for i=1, #helipad.options do
                    local model = helipad.options[i]
                    local hash = GetHashKey(model)
                    options[#options + 1] = {
                        label = "Vytáhnout "..GetDisplayNameFromVehicleModel(hash):lower():gsub("^%l", string.upper),
                        onSelect = function()
                            ClearAreaOfVehicles(helipad.spawn?.coords, 20.0, false, false, false, false, false)
                            RequestModel(hash)
                            while not HasModelLoaded(hash) do
                                Citizen.Wait(0)
                            end
                            CreateVehicle(hash, helipad.spawn?.coords, helipad.spawn?.heading, true)
                        end,
                        canInteract = function()
                            return ESX.PlayerData.job and next(ESX.PlayerData.job) and (ESX.PlayerData.job.name == k)
                        end
                    }
                end
            end
            for optionIndex, option in pairs(options) do
                if(option.icon == nil) then
                    option.icon = "fa-solid fa-clipboard-list"
                end
                if(option.canInteract == nil) then
                    option.canInteract = function()
                        return ESX.PlayerData.job and next(ESX.PlayerData.job) and ESX.PlayerData.job.name == k 
                    end
                end
            end

            Target:addSphereZone({
                coords = point.coords,
                radius = 2.0,
                drawSprite = true,
                options = options
            })
        end
        if(v.StaticBlips and next(v.StaticBlips)) then
            for blipIndex,blipData in pairs(v.StaticBlips) do
                if(not blipData.id) then
                    blipData.id = k..blipIndex
                end
                JobBlips[blipData.id] = Base:CreateBlip(blipData)
            end
        end
    end
    -- Medical & Billing
    Target:addGlobalPlayer({
        {
            label = "Fakturovat",
            icon = "fa-solid fa-file-invoice-dollar",
            onSelect = function(data)
                local playerId = NetworkGetPlayerIndexFromPed(data.entity)
                local netId = GetPlayerServerId(playerId)
                ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "dialog_bill_label", {
                    title = "Text"
                }, function(data, menu)
                    menu.close()
                    ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "dialog_bill_amount", {
                        title = "Částka"
                    }, function(data2, menu2)
                        TriggerEvent("strin_base:executeCommand", "me", "vystavuje fakturu")
                        TriggerServerEvent("strin_jobs:billPlayer", netId, data.value or "", tonumber(data2.value or ""))
                        menu2.close()
                    end,function(data2, menu2)
                        menu2.close()
                    end)
                end,function(data, menu)
                    menu.close()
                end)
            end,
            canInteract = function()
                return HasAccessToAction(ESX.PlayerData?.job?.name, "billing")
            end,
        },
        {
            label = "Ošetřit",
            icon = "fa-solid fa-hand-holding-medical",
            onSelect = function(data)
                local entity = data.entity
                if(not IsEntityDead(entity) and IsPedInjured(entity)) then
                    local ped = PlayerPedId()
                    TaskStartScenarioInPlace(ped, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
                    Citizen.Wait(2000)
                    local playerId = NetworkGetPlayerIndexFromPed(entity)
                    local netId = GetPlayerServerId(playerId)
                    TriggerEvent("strin_base:executeCommand", "me", "ošetřuje osobu")
                    TriggerServerEvent("strin_jobs:healPlayer", netId)
                    ClearPedTasksImmediately(ped)
                end
            end,
            canInteract = function(entity)
                return HasAccessToAction(ESX.PlayerData?.job?.name, "medical") and
                not IsEntityDead(entity) and
                IsPedInjured(entity) 
            end,
        },
        {
            label = "Resuscitovat",
            icon = "fa-solid fa-hand-holding-medical",
            onSelect = function(data)
                local entity = data.entity
                if(IsEntityDead(entity)) then
                    local ped = PlayerPedId()
                    TaskStartScenarioInPlace(ped, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
                    Citizen.Wait(2000)
                    local playerId = NetworkGetPlayerIndexFromPed(entity)
                    local netId = GetPlayerServerId(playerId)
                    TriggerEvent("strin_base:executeCommand", "me", "začíná resuscitovat osobu")
                    TriggerServerEvent("strin_jobs:revivePlayer", netId)
                    ClearPedTasksImmediately(ped)
                end
            end,
            canInteract = function(entity)
                return HasAccessToAction(ESX.PlayerData?.job?.name, "medical") and IsEntityDead(entity)
            end,
        },
        {
            label = "Skenovat otisky prstů", 
            icon = "fa-solid fa-fingerprint",
            onSelect = function(data)
                local entity = data.entity
                local playerId = NetworkGetPlayerIndexFromPed(entity)
                local netId = GetPlayerServerId(playerId)
                
                lib.callback("strin_jobs:scanFingerprints", false, function(scan, scanName)
                    if(lib.progressBar({
                        label = "Skenování otisků",
                        duration = 10000,
                    })) then
                        if(not scan or not scanName) then
                            ESX.ShowNotification("Skenování se nezdařilo!", { type = "error" })
                            return
                        end
                        lib.setClipboard(scan)
                        ESX.ShowNotification(("Scan: %s - %s - Zkopírováno!"):format(scan, scanName))
                    end
                end, netId)
            end,
            canInteract = function()
                return lib.table.contains(LawEnforcementJobs, ESX?.PlayerData?.job?.name)
            end
        }
    })
    -- Mechanic
    Target:addGlobalVehicle({
        {
            label = "Opravit vozidlo",
            icon = "fa-solid fa-screwdriver-wrench",
            onSelect = function(data)
                local entity = data.entity
                if(GetVehicleBodyHealth(entity) < 1000) then
                    local ped = PlayerPedId()
                    TaskStartScenarioInPlace(ped, 'PROP_HUMAN_BUM_BIN', 0, true)
                    --SetEntityInvincible(ped, true)
                    Citizen.Wait(7000)
                    SetVehicleFixed(entity)
                    SetVehicleDeformationFixed(entity)
                    SetVehicleUndriveable(entity, false)
                    SetVehicleEngineOn(entity, true, true)
                    ClearPedTasksImmediately(ped)
                    --SetEntityInvincible(ped, false)
                    ESX.ShowNotification("Vozidlo úspešně opraveno!", {type = "success"})
                end
            end,
            canInteract = function(entity)
                local ped = PlayerPedId()
                local isVehicleDamaged = GetVehicleBodyHealth(entity) < 1000
                local hasAccess = HasAccessToAction(ESX.PlayerData?.job?.name, "mechanic")
                local isNotInVehicle = GetVehiclePedIsIn(ped) == 0
                return hasAccess and isVehicleDamaged and isNotInVehicle 
            end
        },
        {
            label = "Umýt vozidlo",
            icon = "fa-solid fa-soap",
            onSelect = function(data)
                local entity = data.entity
                if(GetVehicleDirtLevel(entity) > 0.0) then
                    local ped = PlayerPedId()
                    --SetEntityInvincible(ped, true)
                    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_MAID_CLEAN', 0, true)
                    Citizen.Wait(2000)
                    SetVehicleDirtLevel(entity, 0.0)
                    ClearPedTasksImmediately(ped)
                    --SetEntityInvincible(ped, false)
                    ESX.ShowNotification("Vozidlo úspěšně umyto!", {type = "success"})
                end
            end,
            canInteract = function(entity)
                local ped = PlayerPedId()
                local isVehicleDirty = GetVehicleDirtLevel(entity) > 0.0
                local hasAccess = HasAccessToAction(ESX.PlayerData?.job?.name, "mechanic")
                local isNotInVehicle = GetVehiclePedIsIn(ped) == 0
                return hasAccess and isVehicleDirty and isNotInVehicle 
            end
        },
        {
            label = "Vypáčit vozidlo",
            icon = "fa-solid fa-unlock",
            onSelect = function(data)
                local entity = data.entity
                if(GetVehicleDoorLockStatus(entity) == 2) then
                    local ped = PlayerPedId()
                    local useLockpick = not HasAccessToAction(ESX.PlayerData?.job?.name, "mechanic")
                    if(useLockpick) then
                        local lockpickUsed = lib.callback.await("strin_jobs:useLockpick", false)
                        if(not lockpickUsed) then
                            return
                        end
                    end
                    local dict = "mp_arresting"
                    LoadAnimationDict(dict)
                    --SetEntityInvincible(ped, true)
					TaskPlayAnim(ped, dict, 'a_uncuff', 8.0, -8, 2000, 49, 0, 0, 0, 0)
                    Citizen.Wait(2000)
					SetVehicleDoorsLocked(entity, 1)
					SetVehicleDoorsLockedForAllPlayers(entity, false)
                    ClearPedTasksImmediately(ped)
                    --SetEntityInvincible(ped, false)
                    RemoveAnimDict(dict)
                    ESX.ShowNotification("Vozidlo úspěšně odemknuto!", {type = "success"})
                end
            end,
            canInteract = function(entity)
                local ped = PlayerPedId()
                local isVehicleLocked = GetVehicleDoorLockStatus(entity) == 2
                local hasAccess = HasAccessToAction(ESX.PlayerData?.job?.name, "mechanic") or Inventory:GetItemCount("lockpick") > 0
                local isNotInVehicle = GetVehiclePedIsIn(ped) == 0
                return hasAccess and isVehicleLocked and isNotInVehicle
            end
        },
        {
            label = "Zkopírovat VIN",
            icon = "fa-solid fa-pen",
            onSelect = function(data)
                local netId = NetworkGetNetworkIdFromEntity(data.entity)
                lib.callback("strin_garages:getVehicleIdentifier", false, function(vehicleIdentifier)
                    if(not vehicleIdentifier) then
                        ESX.ShowNotification("Tohle vozidlo má zvláštní sériové číslo. (Neexistuje)", { type = "error" })
                        return
                    end
                    lib.setClipboard(tostring(vehicleIdentifier))
                    ESX.ShowNotification("Zkopírován VIN kód vozidla - "..tostring(vehicleIdentifier)..".")
                end, netId)
            end,
            canInteract = function(entity)
                return NetworkGetEntityIsNetworked(entity)
            end
        }
    })
end)

/*Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        print(HasCollisionLoadedAroundEntity(PlayerPedId()))
    end
end)*/

function LoadAnimationDict(dict)
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Wait(100)
	end
end

function HasAccessToAction(jobName, action)
    if(not Jobs[jobName]) then
        return false
    end
    local hasAccess = false
    for i=1, #(Jobs[jobName].Actions or {}) do
        if(action == Jobs[jobName].Actions[i]) then
            hasAccess = true
            break
        end
    end
    return hasAccess
end

exports("GetLawEnforcementJobs", function()
    return LawEnforcementJobs
end)

exports("GetDistressJobs", function()
    return DistressJobs
end)

AddEventHandler("onResourceStop", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        for k,v in pairs(JobBlips) do
            Base:DeleteBlip(k)
        end
    end
end)