local IsDead = true
--local DistressBlips = {}
local DeathCam = nil
local angleY = 0.0
local angleZ = 0.0

/*
    DeadPlayers[xPlayer.identifier] = {
        distress = false,
        victimId = _source,
        deathCause = data.deathCause,
        deathCoords = data.victimCoords,
        killedByPlayer = data.killedByPlayer,
        killerId = data.killerServerId,
        deadOn = GetGameTimer(),
    }
*/

/*RegisterNetEvent("strin_jobs:startDeathTimer", function(timer)
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end
    SetTimeout(timer, function()
        local ped = PlayerPedId()
        if(IsEntityDead(ped)) then
            TriggerServerEvent("strin_jobs:checkDeathTimer")
        end
    end)
end)*/

/*RegisterNetEvent("strin_jobs:addDistressBlip", function(distressedPlayer)
    if(source == "" and GetInvokingResource() ~= nil) then
        return
    end
    local index = #DistressBlips + 1
    if(distressedPlayer.distress) then
        DistressBlips[index] = CreateDistressBlip(distressedPlayer)
    end
    
    SetTimeout(RespawnTimer * 2, function()
        if(DoesBlipExist(DistressBlips[index])) then
            RemoveBlip(DistressBlips[index])
            DistressBlips[index] = nil
        end
    end)
end)*/

/*AddEventHandler("onResourceStop", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        if(not ESX.PlayerData.job) then
            return
        end
        if(not DistressJobs[ESX.PlayerData.job.name]) then
            ClearDistressBlips()
        end
    end
end)

RegisterNetEvent("esx:setJob", function(job)
    if(not DistressJobs[job.name]) then
        ClearDistressBlips()
    end
end)**/

AddEventHandler("esx:onPlayerDeath", function()
    IsDead = true
    Target:disableTargeting(true)
    /*StartDeathCam()
    lib.showTextUI("Stisknětě [G] pro zavolání pomoci", {
        position = 'left-center'
    })
    local distress = false
    local ped = PlayerPedId()
    ClearTimecycleModifier()
    SetTimecycleModifier("REDMIST_blend")
    SetTimecycleModifierStrength(0.7)
    SetExtraTimecycleModifier("fp_vig_red")
    SetExtraTimecycleModifierStrength(1.0)
    SetPedMotionBlur(ped, true)
    while true do
        local ped = PlayerPedId()
        if(not IsEntityDead(ped)) then
            lib.hideTextUI()
            EndDeathCam()
            break
        end
        if(IsControlJustReleased(0, 47) and not distress) then
            --TriggerServerEvent("strin_jobs:startDistress")
            lib.hideTextUI()
            distress = true
        end
        ProcessCamControls(ped)
        Citizen.Wait(0)
    end*/
end)

AddEventHandler("esx:onPlayerSpawn", function()
    if(IsDead) then
        Target:disableTargeting(false)
    end
    local ped = PlayerPedId()
    /*ClearTimecycleModifier()
    SetPedMotionBlur(ped, false)*/
    IsDead = false
end)

RegisterNetEvent("strin_jobs:revive", function()
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end

    local ped = PlayerPedId()
    if(IsEntityDead(ped)) then
        DoScreenFadeOut(500)
        Citizen.Wait(500)
        SetEntityCoordsNoOffset(ped, GetEntityCoords(ped), false, false, false, true)
        NetworkResurrectLocalPlayer(GetEntityCoords(ped), GetEntityHeading(ped), true, false)
        SetPlayerInvincible(ped, false)
        ClearPedBloodDamage(ped)
        TriggerEvent("esx:onPlayerSpawn")
        Citizen.Wait(500)
        DoScreenFadeIn(500)
    end
    
    TriggerServerEvent("strin_jobs:playerRevived")
end)

lib.callback.register("strin_jobs:setHealth", function(health)
    local ped = PlayerPedId()
    if(not IsEntityDead(ped)) then
        SetEntityHealth(ped, health)
        if(health > 0) then
            TriggerServerEvent("strin_jobs:playerHealed")
        end
    end
end)

/*function StartDeathCam()
    ClearFocus()
    local playerPed = PlayerPedId()
    DeathCam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", GetEntityCoords(playerPed), 0, 0, 0, GetGameplayCamFov())
    SetCamActive(DeathCam, true)
    RenderScriptCams(true, true, 1000, true, false)
end

function EndDeathCam()
    ClearFocus()
    RenderScriptCams(false, false, 0, true, false)
    DestroyCam(DeathCam, false)
    DeathCam = nil
end

function ProcessCamControls(playerPed)
    local playerCoords = GetEntityCoords(playerPed)
    -- disable 1st person as the 1st person camera can cause some glitches
    DisableFirstPersonCamThisFrame()
    -- calculate new position
    local newPos = ProcessNewPosition(playerPed, playerCoords)
    -- focus cam area
    SetFocusArea(newPos.x, newPos.y, newPos.z, 0.0, 0.0, 0.0)
    -- set coords of cam
    SetCamCoord(DeathCam, newPos.x, newPos.y, newPos.z)
    -- set rotation
    PointCamAtCoord(DeathCam, playerCoords.x, playerCoords.y, playerCoords.z + 0.5)
end

function ProcessNewPosition(ped, pCoords)
    local mouseX = 0.0
    local mouseY = 0.0
    -- keyboard
    if (IsInputDisabled(0)) then
        -- rotation
        mouseX = GetDisabledControlNormal(1, 1) * 8.0
        mouseY = GetDisabledControlNormal(1, 2) * 8.0
    -- controller
    else
        -- rotation
        mouseX = GetDisabledControlNormal(1, 1) * 1.5
        mouseY = GetDisabledControlNormal(1, 2) * 1.5
    end

    angleZ = angleZ - mouseX -- around Z axis (left / right)
    angleY = angleY + mouseY -- up / down

    -- limit up / down angle to 90°

    if (angleY > 89.0) then angleY = 89.0 elseif (angleY < -89.0) then angleY = -89.0 end

    local behindCam = {
        x = pCoords.x + ((Cos(angleZ) * Cos(angleY)) + (Cos(angleY) * Cos(angleZ))) / 2 * (5.5 + 0.5),
        y = pCoords.y + ((Sin(angleZ) * Cos(angleY)) + (Cos(angleY) * Sin(angleZ))) / 2 * (5.5 + 0.5),
        z = pCoords.z + ((Sin(angleY))) * (5.5 + 0.5)
    }

    local rayHandle = StartShapeTestRay(pCoords.x, pCoords.y, pCoords.z + 0.5, behindCam.x, behindCam.y, behindCam.z, -1, ped, 0)
    local a, hitBool, hitCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)

    local maxRadius = 5.5
    if (hitBool and #(vector3(pCoords.x, pCoords.y, pCoords.z + 0.5) - hitCoords) < 5.5 + 0.5) then
        maxRadius = #(vector3(pCoords.x, pCoords.y, pCoords.z + 0.5) - hitCoords)
    end

    local offset = {
        x = ((Cos(angleZ) * Cos(angleY)) + (Cos(angleY) * Cos(angleZ))) / 2 * maxRadius,
        y = ((Sin(angleZ) * Cos(angleY)) + (Cos(angleY) * Sin(angleZ))) / 2 * maxRadius,
        z = ((Sin(angleY))) * maxRadius
    }

    local pos = {
        x = pCoords.x + offset.x,
        y = pCoords.y + offset.y,
        z = pCoords.z + offset.z
    }
    
    return pos
end*/

/*function CreateDistressBlip(distressedPlayer)
    local playerCoords = distressedPlayer.deathCoords
    local blip = AddBlipForCoord(playerCoords.x, playerCoords.y, playerCoords.z)
    SetBlipSprite(blip, 409)
    SetBlipColour(blip, 38)
    SetBlipScale(blip, 1.5)
    SetBlipBright(blip, true)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('<FONT FACE="Righteous">Tísňový signál')
    EndTextCommandSetBlipName(blip)
    return blip
end

function ClearDistressBlips()
    if(#DistressBlips > 0) then
        for i=1, #DistressBlips do
            local blip = DistressBlips[i]
            if(DoesBlipExist(blip)) then
                RemoveBlip(blip)
                DistressBlips[i] = nil
            end
        end
    end
end*/