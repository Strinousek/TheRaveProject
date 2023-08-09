local NoClipEnabled = false
local NoClipSpeedOptions = {
    { label = "Very Slow", speed = 0 },
    { label = "Slow", speed = 0.5 },
    { label = "Normal", speed = 2 },
    { label = "Fast", speed = 4 },
    { label = "Very Fast", speed = 6 },
    { label = "Extremely Fast", speed = 10 },
    { label = "Extremely Fast v2.0", speed = 20 },
    { label = "Max Speed", speed = 25 }
}

Citizen.CreateThread(function()
    for i=1, #NoClipSpeedOptions do
        AddTextEntry("STRIN_ADMIN:NOCLIP:"..i, ("~INPUT_MOVE_UP_ONLY~ Dopredu\n~INPUT_SCRIPTED_FLY_UD~ Zpátky\n~INPUT_COVER~ Nahoru\n~INPUT_HUD_SPECIAL~ Dolu\n~INPUT_VEH_MOVE_UP_ONLY~ Zmena rychlosti (%s)"):format(NoClipSpeedOptions[i].label))
    end
end)

local NoClipDisabledControls = { 30, 31, 32, 33, 34, 35, 266, 267, 268, 269, 44, 20, 74 }

local NoClipCurrentSpeedIndex = 3
local NoClipCurrentSpeed = NoClipSpeedOptions[NoClipCurrentSpeedIndex].speed

local NoClipControls = {
    Forward = 32,  -- w
    Left = 34, -- a
    Backward = 33, -- s
    Right = 35, -- d
    Up = 85, -- q
    Down = 48, -- z
    Speed = 21, -- left shift
}

local function UpdateNoClipSpeed(index)
    NoClipCurrentSpeedIndex = index
    NoClipCurrentSpeed = NoClipSpeedOptions[index].speed
end

function NoClip()
    NoClipEnabled = not NoClipEnabled
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped)
    local usedEntity = vehicle ~= 0 and vehicle or ped
    SetEntityInvincible(ped, NoClipEnabled)
    if(NoClipEnabled) then
        SetEntityAlpha(usedEntity, 51, 0)
    else
        ResetEntityAlpha(usedEntity)
    end
    SetEntityCollision(usedEntity, not NoClipEnabled, not NoClipEnabled)
    FreezeEntityPosition(usedEntity, NoClipEnabled)
    SetEntityInvincible(usedEntity, NoClipEnabled)
    SetVehicleRadioEnabled(usedEntity, not NoClipEnabled)
    if(NoClipEnabled) then
        lib.disableControls:Add(NoClipDisabledControls)
        while true do
            if(not NoClipEnabled) then
                lib.disableControls:Clear(NoClipDisabledControls)
                break
            end

            local offsetZ = 0.0
            local offsetY = 0.0
            local changed = false

            DisplayHelpTextThisFrame("STRIN_ADMIN:NOCLIP:"..NoClipCurrentSpeedIndex, false)
            if(IsControlJustReleased(0, NoClipControls.Speed)) then
                changed = true
                if(NoClipCurrentSpeedIndex < #NoClipSpeedOptions) then
                    UpdateNoClipSpeed(NoClipCurrentSpeedIndex + 1)
                else
                    UpdateNoClipSpeed(1)
                end
            end
            
            lib.disableControls()

            if(IsDisabledControlPressed(0, NoClipControls.Forward)) then
                changed = true
                offsetY = 0.5
            end
            if(IsDisabledControlPressed(0, NoClipControls.Backward)) then
                changed = true
                offsetY = -0.5
            end
            /*if(IsDisabledControlPressed(0, NoClipControls.Left)) then
                changed = true
                local entityHeading = GetEntityHeading(usedEntity)
                SetEntityHeading(usedEntity, entityHeading + 3)
            end
            if(IsDisabledControlPressed(0, NoClipControls.Right)) then
                changed = true
                local entityHeading = GetEntityHeading(usedEntity)
                SetEntityHeading(usedEntity, entityHeading - 3)
            end*/
            if(IsDisabledControlPressed(0, NoClipControls.Up)) then
                changed = true
                offsetZ = 0.2
            end
            if(IsDisabledControlPressed(0, NoClipControls.Down)) then
                changed = true
                offsetZ = -0.2
            end

            if(changed) then
                local newCoords = GetOffsetFromEntityInWorldCoords(usedEntity, 0.0, offsetY * (NoClipCurrentSpeed + 0.3), offsetZ * (NoClipCurrentSpeed + 0.3))
                SetEntityVelocity(usedEntity, 0.0, 0.0, 0.0)
                SetEntityRotation(usedEntity, 0.0, 0.0, 0.0, 0, false)
                SetEntityCoordsNoOffset(usedEntity, newCoords.x, newCoords.y, newCoords.z, true, true, true)
                SetEntityHeading(usedEntity, GetGameplayCamRelativeHeading());
            end

            Citizen.Wait(0)
        end
        return
    end
    --lib.hideTextUI()
end