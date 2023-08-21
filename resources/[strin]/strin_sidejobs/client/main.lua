Target = exports.ox_target
IsDead = false

local JobCenterBlip = nil
local JobCenterNPCEntity = nil

Citizen.CreateThread(function()
    local point = lib.points.new({
        coords = JOB_CENTER_COORDS,
        distance = 20.0
    })

    JobCenterBlip = CreateJobCenterBlip(JOB_CENTER_COORDS)

    function point:onEnter()
        if(not JobCenterNPCEntity or not DoesEntityExist(JobCenterNPCEntity)) then
            JobCenterNPCEntity = CreateNPCPed(JOB_CENTER_NPC_MODEL, JOB_CENTER_COORDS, JOB_CENTER_NPC_HEADING)
            Target:addLocalEntity(JobCenterNPCEntity, {
                {
                    label = "Zeptat se na práci",
                    icon = "fa-solid fa-briefcase",
                    distance = 1.5,
                    onSelect = function()
                        OpenSideJobListMenu()
                    end,
                    canInteract = function()
                        return DoesEntityExist(JobCenterNPCEntity)
                    end,
                }
            })
        end
    end

    function point:onExit()
        if(JobCenterNPCEntity or DoesEntityExist(JobCenterNPCEntity)) then
            DeleteEntity(JobCenterNPCEntity)
            JobCenterNPCEntity = nil
        end
    end
end)

function OpenSideJobListMenu()
    local elements = {}
    for k,v in pairs(JOB_CENTER_SIDEJOBS) do
        table.insert(elements, {
            label = v.label.." - Záloha vozidla = "..ESX.Math.GroupDigits(JOB_CENTER_VEHICLE_BORROW_PRICE).."$",
            value = k
        })
    end
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "side_job_list_menu", {
        title = "Práce",
        align = "center",
        elements = elements
    }, function(data, menu)
        menu.close()
        SpawnSideJobVehicle(data.current.value)
    end, function(data, menu)
        menu.close()
    end)
end

function SpawnSideJobVehicle(sideJobName)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    if(#(coords - JOB_CENTER_COORDS) > 30) then
        return
    end
    local isSpawnpointClear = ESX.Game.IsSpawnPointClear(JOB_CENTER_VEHICLE_SPAWNPOINT_COORDS, 6.0)
    if(not isSpawnpointClear) then
        ESX.ShowNotification("Místo pro vozidla je okupované vozidly!", { type = "error" })
        return
    end
    lib.callback("strin_sidejobs:canBorrowVehicle", 1000, function(canBorrow)
        if(canBorrow) then
            ESX.Game.SpawnVehicle(
                JOB_CENTER_VEHICLES[sideJobName],
                JOB_CENTER_VEHICLE_SPAWNPOINT_COORDS,
                JOB_CENTER_VEHICLE_SPAWNPOINT_HEADING,
                function(vehicle)
                    if(DoesEntityExist(vehicle)) then
                        TaskWarpPedIntoVehicle(ped, vehicle, -1)
                        Citizen.Wait(2000) -- RACE CONDITION POGGERS
                        ExecuteCommand(sideJobName)
                    end
                end
            )
        end
    end, sideJobName)
end
function CreateJobCenterBlip(coords)
    local blip = AddBlipForCoord(coords)
    SetBlipDisplay(blip, 2)
    SetBlipSprite(blip, 133)
    SetBlipColour(blip, 18)
    SetBlipScale(blip, 1.0)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("<FONT FACE='Righteous'>Úřad práce</FONT>")
    EndTextCommandSetBlipName(blip)
    return blip
end

function CreateNPCPed(model, coords, heading)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(100)
    end
    local _, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, 0)
    local ped = CreatePed(0, model, coords.x, coords.y, groundZ, heading, false, false)
    SetPedDefaultComponentVariation(ped)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedDiesWhenInjured(ped, false)
    SetEntityInvincible(ped, true)
    SetPedCanPlayAmbientAnims(ped, true)
    FreezeEntityPosition(ped, true)
    return ped
end

RegisterNetEvent("strin_sidejobs:cancelSideJob", function(sideJobName)
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end
    ExecuteCommand("cancel"..sideJobName)
end)

AddEventHandler("esx:onPlayerSpawn", function()
    IsDead = false
end)

AddEventHandler("esx:onPlayerDeath", function()
    IsDead = true
end)

AddEventHandler("onResourceStop", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        if(DoesBlipExist(JobCenterBlip)) then
            RemoveBlip(JobCenterBlip)
        end
    end
end)

function LoadAnimDict(animDict)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(0)
    end
end