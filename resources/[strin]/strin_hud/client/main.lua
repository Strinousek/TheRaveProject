showHud = true
inEdit = false
hasSeatbelt = false

function GetMinimapAnchor()
    -- Safezone goes from 1.0 (no gap) to 0.9 (5% gap (1/20))
    -- 0.05 * ((safezone - 0.9) * 10)
    /*local safezone = GetSafeZoneSize()
    local safezone_x = 1.0 / 20.0
    local safezone_y = 1.0 / 20.0*/
    local aspect_ratio = GetAspectRatio(0)
    local res_x, res_y = GetActiveScreenResolution()
    local xscale = 1.0 / res_x
    --local yscale = 1.0 / res_y
    local Minimap = {}
    Minimap.width = xscale * (res_x / (4 * aspect_ratio))
    /*Minimap.height = yscale * (res_y / 5.674)
    Minimap.left_x = xscale * (res_x * (safezone_x * ((math.abs(safezone - 1.0)) * 10)))
    Minimap.bottom_y = 1.0 - yscale * (res_y * (safezone_y * ((math.abs(safezone - 1.0)) * 10)))
    Minimap.right_x = Minimap.left_x + Minimap.width
    Minimap.top_y = Minimap.bottom_y - Minimap.height
    Minimap.x = Minimap.left_x
    Minimap.y = Minimap.top_y
    Minimap.xunit = xscale
    Minimap.yunit = yscale*/
    return Minimap
end

local MinimapWidth = GetMinimapAnchor()?.width

local PlayerId = PlayerId
local PlayerPedId = PlayerPedId

Citizen.CreateThread(function()
    local sleep = 500
    while true do
        DisplayRadar(false)
        if not showHud then
            sleep = 1000
        end
        if(showHud) then
            sleep = 500
            local ped = cache.ped
            local player = cache.playerId
            local health = GetEntityHealth(ped)
            local maxHealth = GetEntityMaxHealth(ped)
            local vehicle = cache.vehicle
            local breath = GetPlayerUnderwaterTimeRemaining(player)
            local data = {
                action = "updateData",
                health = health,
                maxHealth = maxHealth,
                armor = GetPedArmour(ped),
                energy = 100 - GetPlayerSprintStaminaRemaining(player),
                minimapWidth = MinimapWidth,
            }
            if(breath < 10.0) then
                data.isUnderwater = true
                data.breath = breath
            else
                data.isUnderwater = false
            end
            if(vehicle) then
                DisplayRadar(true)
                local pos = cache.coords or GetEntityCoords(vehicle)
                local speed = roundNum(GetEntitySpeed(vehicle) * 2.236936)
                local fuel = roundNum(Entity(vehicle).state?.fuel or 100)
                local street1, street2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
                local currentZone = GetLabelText(GetNameOfZone(pos.x, pos.y, pos.z))
                local vehicleClass = GetVehicleClass(vehicle)
                data.inVehicle = true
                data.speed = speed
                data.fuel = fuel
                data.isSeatbeltAvailable = vehicleClass ~= 8 and vehicleClass ~= 13
                if(data.isSeatbeltAvailable) then
                    data.hasSeatbelt = hasSeatbelt
                end
                data.street1 = GetStreetNameFromHashKey(street1)
                data.street2 = GetStreetNameFromHashKey(street2)
                data.zone = currentZone
            else
                data.inVehicle = false
            end
            SendNUIMessage(data)
        end
        Citizen.Wait(sleep)
    end
end)

--[[Citizen.CreateThread(function()
    local currSpeed = 0.0
    local cruiseSpeed = 999.0
    local prevVelocity = {x = 0.0, y = 0.0, z = 0.0}
    local seatbeltEjectSpeed = 45.0 
    local seatbeltEjectAccel = 100.0

    while true do
        Citizen.Wait(0)
        local player = PlayerPedId()
        local position = GetEntityCoords(player)
        local vehicle = GetVehiclePedIsIn(player, false)
        
        if IsPedInAnyVehicle(player, false) then
            local vehicleClass = GetVehicleClass(vehicle)
            if IsPedInAnyVehicle(player, false) and vehicleClass ~= 13 then
                local prevSpeed = currSpeed
                currSpeed = GetEntitySpeed(vehicle)

                SetPedConfigFlag(PlayerPedId(), 32, true)
                if not hasSeatbelt then
                    local vehIsMovingFwd = GetEntitySpeedVector(vehicle, true).y > 1.0
                    local vehAcc = (prevSpeed - currSpeed) / GetFrameTime()
                    if (vehIsMovingFwd and (prevSpeed > (seatbeltEjectSpeed/2.237)) and (vehAcc > (seatbeltEjectAccel*9.81))) then
                        SetEntityCoords(player, position.x, position.y, position.z - 0.47, true, true, true)
                        SetEntityVelocity(player, prevVelocity.x, prevVelocity.y, prevVelocity.z)
                        SetPedToRagdoll(player, 1000, 1000, 0, 0, 0, 0)
                    else
                        prevVelocity = GetEntityVelocity(vehicle)
                    end
                else
                    DisableControlAction(0, 75)
                end

            end
        else
            Citizen.Wait(500)
        end
    end
end)]]

RegisterCommand("seatbelt", function()
    TriggerEvent("strin_hud:seatbelt")
end)

AddEventHandler("esx:enteredVehicle", function()
    local currSpeed = 0.0
    local cruiseSpeed = 999.0
    local prevVelocity = {x = 0.0, y = 0.0, z = 0.0}
    local seatbeltEjectSpeed = 45.0 
    local seatbeltEjectAccel = 100.0
    while true do
        Citizen.Wait(0)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local vehicle = GetVehiclePedIsIn(ped, false)

        if(vehicle == 0) then
            if(hasSeatbelt) then
                hasSeatbelt = false
            end
            break
        end
        
        local vehicleClass = GetVehicleClass(vehicle)
        if(vehicleClass == 13) then
            break
        end
        
        local prevSpeed = currSpeed
        currSpeed = GetEntitySpeed(vehicle)

        SetPedConfigFlag(ped, 32, true)
        
        if not hasSeatbelt then
            local vehIsMovingFwd = GetEntitySpeedVector(vehicle, true).y > 1.0
            local vehAcc = (prevSpeed - currSpeed) / GetFrameTime()
            if (vehIsMovingFwd and (prevSpeed > (seatbeltEjectSpeed/2.237)) and (vehAcc > (seatbeltEjectAccel*9.81))) then
                SetEntityCoords(ped, coords.x, coords.y, coords.z - 0.47, true, true, true)
                SetEntityVelocity(ped, prevVelocity.x, prevVelocity.y, prevVelocity.z)
                SetPedToRagdoll(ped, 1000, 1000, 0, 0, 0, 0)
            else
                prevVelocity = GetEntityVelocity(vehicle)
            end
        else
            DisableControlAction(0, 75)
        end
    end
end)

RegisterKeyMapping('seatbelt', '<FONT FACE="Righteous">Bezpečnostní pás~</FONT>', 'KEYBOARD', "B")

RegisterNetEvent("strin_hud:seatbelt", function(toggle)
    local vehicle = cache.vehicle
    if(not vehicle) then
        return
    end
    local vehicleClass = GetVehicleClass(vehicle)
    if(vehicleClass ~= 8 and vehicleClass ~= 13) then
        if(toggle ~= nil) then
            hasSeatbelt = toggle
        else
            hasSeatbelt = not hasSeatbelt
        end
    else
        hasSeatbelt = false
    end
    SendNUIMessage({
        action = "updateSeatbelt",
        hasSeatbelt = hasSeatbelt
    })
end)

RegisterNetEvent("strin_hud:closeHud", function()
    showHud = false
    SendNUIMessage({
        action = "closeHud",
    })
end)

RegisterNetEvent("strin_hud:openHud", function()
    showHud = true
    SendNUIMessage({
        action = "openHud",
    })
end)

RegisterCommand("hud", function(source, args)
    showHud = not showHud
    if(showHud == false) then
        SendNUIMessage({
            action = "closeHud",
        })
    else
        SendNUIMessage({
            action = "openHud",
        })
    end
end)

RegisterCommand("edithud", function(source, args)
    inEdit = true
    SetNuiFocus(inEdit, inEdit)
    SendNUIMessage({
        action = "openHud",
    })
    SendNUIMessage({
        action = "editHud",
    })
end)

RegisterCommand("limit", function(source, args)
    local ped = PlayerPedId()
    if(args[1] ~= nil and args[1] ~= "" and args[1] ~= 0) then
        if(cache.vehicle) then
            local type = "MPH"
            local limit = tonumber(args[1])
            local vehicle = cache.vehicle
            local maxSpeed = GetVehicleHandlingFloat(vehicle, "CHandlingData","fInitialDriveMaxFlatVel")
            if(ShouldUseMetricMeasurements()) then
                type= "KPH"
            end
            if(type == "MPH") then
                if((limit * 2.237) <= maxSpeed) then
                    SetEntityMaxSpeed(vehicle, limit / 2.237)
                    ESX.ShowNotification("Tachometr nastaven na "..limit.." (MPH)", {type = "success"})
                else
                    ESX.ShowNotification("Tento limit převršuje maximální rychlost vozidla!", {type = "error"})
                end
            elseif(type == "KPH") then
                if((limit * 3.6) <= maxSpeed) then
                    SetEntityMaxSpeed(vehicle, limit / 3.6)
                    ESX.ShowNotification("Tachometr nastaven na "..limit.." (KPH)", {type = "success"})
                else
                    ESX.ShowNotification("Tento limit převršuje maximální rychlost vozidla!", {type = "error"})
                end
            end
        else
            ESX.ShowNotification("Tachometr můžete nastavit pouze ve vozidle!", {type = "error"})
        end
    else
        if(cache.vehicle) then
            local vehicle = cache.vehicle
            local maxSpeed = GetVehicleHandlingFloat(vehicle,"CHandlingData","fInitialDriveMaxFlatVel")
            SetEntityMaxSpeed(vehicle, maxSpeed)
            ESX.ShowNotification("Tachometr resetován.", {type = "success"})
        else
            ESX.ShowNotification("Tachometr nemůžete resetovat mimo vozidlo!", {type = "error"})
        end
    end
end)

RegisterNUICallback("exitEdit", function(data)
    inEdit = false
    SetNuiFocus(inEdit, inEdit)
    if(showHud == false) then
        SendNUIMessage({
            action = "closeHud",
        })
    else
        SendNUIMessage({
            action = "openHud",
        })
    end
end)

function roundNum(num)
    return math.floor(num + 0.5)
end