/*local animations = {
    ["melee@hatchet@streamed_core_fps"] = {  
        "plyr_front_takedown",
        "plyr_front_takedown_b",
        "plyr_rear_takedown",
        "plyr_rear_takedown_b",
    },
    ["melee@hatchet@streamed_core"] = {       
        "plyr_front_takedown",
        "plyr_front_takedown_b",
        "plyr_rear_takedown",
        "plyr_rear_takedown_b",
        "victim_front_takedown",
        "victim_front_takedown_b",
        "victim_rear_takedown",
        "victim_rear_takedown_b",
    }
}

RegisterCommand("test", function()
    for k,v in pairs(animations) do
        ESX.Streaming.RequestAnimDict(k, function()
            for i,anim in pairs(v) do
                print(k, anim, i)
                TaskPlayAnim(PlayerPedId(), k, anim, 1.0, 1.0, -1, 49, 1.0)
                Citizen.Wait(3000)
                ClearPedTasksImmediately(PlayerPedId())
            end
        end)
        Citizen.Wait(30000)
    end
end)*/

local TreeBlips = {}
local IsChopping = false
local LogEntity = nil
local DropOffBlip = nil
local DropOffPoint = nil

Citizen.CreateThread(function()
    AddTextEntry("STRIN_SIDEJOBS:LUMBERJACK_DROPOFF", "<FONT FACE='Righteous'>~g~<b>[E]</b>~s~ Vyložit klády")
    AddTextEntry("STRIN_SIDEJOBS:LUMBERJACK_DROP_LOG", "<FONT FACE='Righteous'>~g~<b>[X]</b>~s~ Položit kládu")
end)

RegisterNetEvent("strin_sidejobs:resetLumberjackModule", function()
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end
    for k,v in pairs(TreeBlips) do
        if(v and DoesBlipExist(v)) then
            RemoveBlip(v)
        end
    end
    if(LogEntity) then
        LogEntity = nil
    end
    if(IsChopping) then
        IsChopping = false
    end
    if(DropOffBlip) then
        RemoveBlip(DropOffBlip)
        DropOffBlip = nil
    end
    if(DropOffPoint) then
        DropOffPoint:remove()
        DropOffPoint = nil
    end
end)

RegisterNetEvent("strin_sidejobs:initDropOff", function()
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end

    DropOffPoint = lib.points.new({
        coords = LUMBERJACK_DROP_OFF_COORDS,
        distance = 12.5
    })

    SetNewWaypoint(LUMBERJACK_DROP_OFF_COORDS.x, LUMBERJACK_DROP_OFF_COORDS.y)

    DropOffBlip = CreateLumberjackBlip(false, LUMBERJACK_DROP_OFF_COORDS)

    function DropOffPoint:nearby()
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped)
        if(vehicle == 0) then
            return
        end
        if(not NetworkGetEntityIsNetworked(vehicle)) then
            return
        end
        if(not Entity(vehicle).state.logsStored or (Entity(vehicle).state.logsStored <= 0)) then
            return
        end
        DisplayHelpTextThisFrame("STRIN_SIDEJOBS:LUMBERJACK_DROPOFF")
        if(IsControlJustReleased(0, 38)) then
            TriggerServerEvent("strin_sidejobs:dropOffLogs")
        end
    end
end)

RegisterNetEvent("strin_sidejobs:attachLogToPed", function(logNetId)
    while not NetworkDoesEntityExistWithNetworkId(logNetId) do
        Citizen.Wait(0)
    end
    
    LogEntity = NetworkGetEntityFromNetworkId(logNetId)

    if(not (GetEntityModel(LogEntity) == LUMBERJACK_LOG_MODEL)) then
        return
    end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    LoadAnimDict(LUMBERJACK_ANIMATIONS["LOG"].dict)
    TaskPlayAnim(ped, LUMBERJACK_ANIMATIONS["LOG"].dict, LUMBERJACK_ANIMATIONS["LOG"].clip, 1.0, 1.0, -1, 49, 1.0)
    AttachEntityToEntity(LogEntity, ped, 28422, 0.0, 0.5, 0.2, 0.0, 0.0, 90.0, false, false, false, false, 2, true)
    IsChopping = false
    while LogEntity do
        DisplayHelpTextThisFrame("STRIN_SIDEJOBS:LUMBERJACK_DROP_LOG")
        if(IsControlJustReleased(0, 73) or IsDead) then
            DetachEntity(LogEntity)
            Target:removeEntity(logNetId, { "strin_sidejobs:takeWoodLog" })
            Target:addEntity(logNetId, {
                {
                    name = "strin_sidejobs:takeWoodLog",
                    label = "Vzít kládu",
                    onSelect = function(data)
                        TriggerEvent("strin_sidejobs:attachLogToPed", logNetId)
                    end,
                    canInteract = function(entity)
                        return not LogEntity and not IsChopping
                    end
                }
            })
            LogEntity = nil
            break
        end
        Citizen.Wait(0)
    end
end)

RegisterNetEvent("strin_sidejobs:initTrees", function(data)
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end

    -- we firstly want to set blips and a waypoint
    for _,v in pairs(data.trees) do
        TreeBlips[v.treeIndex] = CreateLumberjackBlip(true, v.coords)
    end
    SetNewWaypoint(data.trees[1].coords.x, data.trees[1].coords.y)

    /*
        now we can loop through trees to add targets
        because client knows of existing networkIds only in his 424 unit radius
        we have to do this in a different loop Sadge
    */
    for _,v in pairs(data.trees) do
        while not NetworkDoesNetworkIdExist(v.netId) do
            Citizen.Wait(100)
        end
        AddEntityTargetToTree(v.treeIndex, v.netId)
    end

    Target:removeEntity(data.vehicleNetId, { "strin_sidejobs:putLogInVehicle" })
    Target:addEntity(data.vehicleNetId, {
        {
            name = "strin_sidejobs:putLogInVehicle",
            label = "Naložit kládu",
            bones = { "boot" },
            onSelect = function(data)
                lib.callback("strin_sidejobs:putLogInVehicle", 500, function(success)
                    if(success) then
                        LogEntity = nil
                    end
                end)
            end,
            canInteract = function(entity)
                local model = GetEntityModel(entity)
                return LogEntity and not IsChopping and lib.table.contains(LUMBERJACK_LOG_VEHICLES, model)
            end
        }
    })
end)

function AddEntityTargetToTree(treeIndex, netId)
    Target:addEntity(netId, {
        {
            label = "Pokácet strom",
            distance = 2.0,
            onSelect = function()
                ChopTree(treeIndex)
            end,
            canInteract = function(entity)
                local _, weapon = GetCurrentPedWeapon(PlayerPedId())
                return GetEntityType(entity) == 3 and lib.table.contains(LUMBERJACK_LOG_AXES, weapon) and not IsChopping and not LogEntity
            end,
        }
    })
end

RegisterNetEvent("strin_sidejobs:initTreeTarget", function(treeIndex, netId)
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end
    while not NetworkDoesNetworkIdExist(netId) do
        Citizen.Wait(100)
    end
    AddEntityTargetToTree(treeIndex, netId)
end)

function ChopTree(treeIndex)
    IsChopping = true
    if(lib.progressCircle({
        duration = LUMBERJACK_CHOP_TIME,
        label = "Kácení stromu",
        canCancel = true,
        anim = {
            dict = LUMBERJACK_ANIMATIONS["CHOPPING"].dict,
            clip = LUMBERJACK_ANIMATIONS["CHOPPING"].clip
        },
        disable = {
            move = true
        }
    })) then
        RemoveBlip(TreeBlips[treeIndex])
        TreeBlips[treeIndex] = nil
        TriggerServerEvent("strin_sidejobs:chopTree")
    else
        IsChopping = false
    end
end

function CreateLumberjackBlip(isTree, coords)
    local blip = AddBlipForCoord(coords)
    SetBlipDisplay(blip, 2)
    SetBlipSprite(blip, isTree and 515 or 569)
    SetBlipColour(blip, isTree and 25 or 2)
    SetBlipScale(blip, isTree and 0.8 or 1.1)
    SetBlipShrink(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("<FONT FACE='Righteous'>"..(isTree and "Strom" or "Výložiště").."</FONT>")
    EndTextCommandSetBlipName(blip)
    return blip
end

AddEventHandler("onResourceStop", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        if(LogEntity) then
            ClearPedTasks(PlayerPedId())
        end
    end
end)