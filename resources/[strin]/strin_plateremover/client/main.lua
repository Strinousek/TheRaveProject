local Inventory = exports.ox_inventory
local Target = exports.ox_target
local SCREWDRIVER_MODEL = `prop_tool_screwdvr01`
local ScrewdriverEntity = nil

RegisterNetEvent("strin_plateremover:screw", function(time)
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end

    StartScrewDrivingAnimation()
    if(lib.progressCircle({
        label = "Montáž SPZ",
        duration = time,
        useWhileDead = false,
        anim = {
            dict = "rcmextreme3",
            clip = "idle",
            flag = 1
        },
        disable = {
            move = true,
            combat = true,
            car = true,
        }
    })) then
        DeleteEntity(ScrewdriverEntity)
        ScrewdriverEntity = nil
    else
        DeleteEntity(ScrewdriverEntity)
        ScrewdriverEntity = nil
    end
end)

Target:addGlobalVehicle({
    {
        label = "Zamaskovat SPZ",
        icon = "fa-solid fa-screwdriver",
        bones = { "platelight" },
        onSelect = function(data)
            local netId = NetworkGetNetworkIdFromEntity(data.entity)
            TriggerServerEvent("strin_plateremover:removePlate", netId)
        end,
        canInteract = function(entity)
            return (
                not ScrewdriverEntity and
                GetVehicleNumberPlateText(entity) ~= "XXXXXXXX" and 
                NetworkGetEntityIsNetworked(entity) and 
                Inventory:GetItemCount("toolkit") > 0
            )
        end,
    },
    {
        label = "Odmaskovat SPZ",
        icon = "fa-solid fa-screwdriver",
        bones = { "platelight" },
        onSelect = function(data)
            local netId = NetworkGetNetworkIdFromEntity(data.entity)
            TriggerServerEvent("strin_plateremover:restorePlate", netId)
        end,
        canInteract = function(entity)
            return (
                not ScrewdriverEntity and
                GetVehicleNumberPlateText(entity) == "XXXXXXXX" and 
                NetworkGetEntityIsNetworked(entity) and 
                Inventory:GetItemCount("toolkit") > 0
            )
        end,
    },
})

function StartScrewDrivingAnimation()
    if(ScrewdriverEntity) then
        return
    end
    local ped = PlayerPedId()
    RequestModel(SCREWDRIVER_MODEL)
    while not HasModelLoaded(SCREWDRIVER_MODEL) do
        Citizen.Wait(0)
    end
    ScrewdriverEntity = CreateObject(SCREWDRIVER_MODEL, GetPedBoneCoords(ped, 28422), true, true)
    AttachEntityToEntity(ScrewdriverEntity, ped, GetPedBoneIndex(ped, 28422), 
    0.1, 0.015, -0.05, 
    30.0, 270.0, 5.0, 
    false, false, false, false, 5, false)
end

AddEventHandler("onResourceStop", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        if(ScrewdriverEntity) then
            DeleteEntity(ScrewdriverEntity)
        end
    end
end)