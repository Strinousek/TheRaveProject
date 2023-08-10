local ReceptionsNPCs = {}
local Target = exports.ox_target

Citizen.CreateThread(function()
    for k,v in pairs(RECEPTIONS) do
        local receptionPoint = lib.points.new({
            coords = v.coords,
            distance = 20,
        })
        function receptionPoint:onEnter()
            if(not ReceptionsNPCs[k] or not DoesEntityExist(ReceptionsNPCs[k])) then
                ReceptionsNPCs[k] = CreateReceptionistNPC(v)
                local options = lib.table.deepclone(v.options)
                for _,option in pairs(options) do
                    option.distance = v.distance or 2.5
                    option.canInteract = function()
                        return DoesEntityExist(ReceptionsNPCs[k])
                    end
                end
                Target:addLocalEntity(ReceptionsNPCs[k], options)
            end
        end
        function receptionPoint:onExit()
            if(ReceptionsNPCs[k] or DoesEntityExist(ReceptionsNPCs[k])) then
                DeleteEntity(ReceptionsNPCs[k])
                ReceptionsNPCs[k] = nil
            end
        end
    end
end)

function CreateReceptionistNPC(reception)
    RequestModel(reception.model)
    while not HasModelLoaded(reception.model) do
        Citizen.Wait(100)
    end
    local _, groundZ = GetGroundZFor_3dCoord(reception.coords.x, reception.coords.y, reception.coords.z, 0)
    local ped = CreatePed(3, reception.model, reception.coords.x, reception.coords.y, groundZ, reception.heading, false, true)
    SetPedDefaultComponentVariation(ped)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedDiesWhenInjured(ped, false)
    SetEntityInvincible(ped, true)
    SetPedCanPlayAmbientAnims(ped, true)
    FreezeEntityPosition(ped, true)
    return ped
end

/*
    POLICE MODULE
*/

AddEventHandler("strin_receptions:copyLSPDDiscord", function()
    local discord = "https://discord.gg/xxx"
    lib.setClipboard(discord)
    ESX.ShowNotification("LSPD Discord zkopírován. CTRL + V pro použití.")
end)