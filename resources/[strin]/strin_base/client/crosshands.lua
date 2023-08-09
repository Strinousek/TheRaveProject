local RPEmotes = exports.rpemotes
local IsRestrained = false
local crosshands = false

AddEventHandler("esx_policejob:handcuff", function()
    IsRestrained = true
    crosshands = false
end)

AddEventHandler("esx_policejob:unrestrain", function()
    IsRestrained = false
    crosshands = false
end)

AddEventHandler("strin_base:cancelledAnimation", function()
    if(crosshands) then
        crosshands = false
    end
end)

RegisterCommand("crosshands", function()
    local ped = PlayerPedId()
    if(IsControlPressed(0, 21) or IsRestrained) then
        if(IsRestrained and crosshands) then
            crosshands = false
        end
        return
    end
    if(not crosshands) then
        local isEntityPlayingAnyAnim = RPEmotes:IsEntityPlayingAnyAnim(ped) or RPEmotes:IsPlayerInAnim()
        if(isEntityPlayingAnyAnim) then
            return
        end
    end
    local dict = "rcmme_amanda1"
    if(crosshands) then
        ClearPedTasks(ped)
        RemoveAnimDict(dict)
        crosshands = false
        return
    end
    local pId = PlayerId()
    if(
        not IsPedInAnyVehicle(ped) and
        not IsPlayerFreeAiming(pId) and
        not IsPedSwimming(ped) and
        not IsPedSwimmingUnderWater(ped) and
        not IsPedRagdoll(ped) and
        not IsPedFalling(ped) and
        not IsPedShooting(ped) and
        not IsPedUsingAnyScenario(ped) and
        not IsPedInCover(ped, 0) and
        not IsPlayerAnAnimal()
    ) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Citizen.Wait(100)
        end
        crosshands = true
        TaskPlayAnim(ped, dict, "stand_loop_cop", 2.0, 2.0, -1, 50, 0, false, false, false)
    end
end)

RegisterKeyMapping('crosshands', '<FONT FACE="Righteous">Skřížit ruce~</FONT>', 'KEYBOARD', "G")