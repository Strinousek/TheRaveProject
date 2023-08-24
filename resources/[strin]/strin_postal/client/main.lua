local ShowPostal = false

local CurrentBlip = nil
local Base = exports.strin_base
local LawEnforcementJobs = exports.strin_jobs:GetLawEnforcementJobs()

Citizen.CreateThread(function()
	ESX.FontId = RegisterFontId('Righteous')
    Citizen.Wait(500)
    TriggerEvent("chat:addSuggestion", "/pc", "Nastavit navigaci na Postal Code", {
        {
            name = "číslo",
            help = "PC číslo"
        }
    })

    if(lib.table.contains(LawEnforcementJobs, ESX?.PlayerData?.job?.name)) then
        ShowPostal = true
        if cache.vehicle then
            StartPostalLurking()
        end
    end
end)

RegisterNetEvent("esx:playerLoaded", function(xPlayer)
    if(lib.table.contains(LawEnforcementJobs, xPlayer?.job.name)) then
        ShowPostal = true
        if(cache.vehicle) then
            StartPostalLurking()
        end
    end
end)

RegisterNetEvent("esx:setJob", function(job)
    if(lib.table.contains(LawEnforcementJobs, job.name)) then
        ShowPostal = true
        if(cache.vehicle) then
            StartPostalLurking()
        end
    end
end)

RegisterCommand("postal", function()
    ShowPostal = not ShowPostal
    if(ShowPostal and cache.vehicle) then
        StartPostalLurking()
    end
end)

lib.onCache("vehicle", function(value)
    if(value) then
        Citizen.Wait(500)
        StartPostalLurking()
    end
end)

function StartPostalLurking()
    local ped = cache.ped
    local nearestPostal = nil

    if GetVehicleClass(cache.vehicle) == 13 then
        return
    end

    Citizen.CreateThread(function()
        while ShowPostal and cache.vehicle do
            local coords = GetEntityCoords(cache.ped)
            nearestPostal = nil
            for i=1, #POSTALS do
                local postal = POSTALS[i]
                local distance = #(coords - vec3(postal.coords.xy, coords.z))
                if not nearestPostal or distance < nearestPostal.distance then
                    nearestPostal = {
                        index = i,
                        distance = distance
                    }
                end
            end

            if CurrentBlip then
                local blipCoords = GetBlipCoords(CurrentBlip.blipId)
                local distance = #(coords - vec3(blipCoords.xy, coords.z))
                if distance < 20.0 then
                    Base:DeleteBlip(CurrentBlip.id)
                    CurrentBlip = nil
                end
            end
            Citizen.Wait(200)
        end
    end)
    while ShowPostal and cache.vehicle do
        while not nearestPostal do
            Citizen.Wait(500)
        end
        local distance = math.sqrt(nearestPostal.distance ^ 2)
        local text = ("POSTAL: %s - %.2fm"):format(POSTALS[nearestPostal.index].code, distance)
        SetTextScale(0.42, 0.42)
        SetTextFont(ESX.FontId)
        SetTextOutline()

        /*local z = 0.775 / 2
        if IsBigmapActive() then
            z = 0.545 / 2
        end
        EndTextCommandDisplayText(z, 1.0)*/
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(0.66 - 1.0/2, 1.44 - 1.0/2 + 0.005)
        Citizen.Wait(0)
    end
end

RegisterCommand("pc", function(_, args)
    if cache.vehicle then
        if CurrentBlip and (not args or #args <= 0) then
            ESX.ShowNotification("Postal Code - Navigace na Postal Code odebrána!")
            Base:DeleteBlip(CurrentBlip.id)
            CurrentBlip = nil
        elseif CurrentBlip and CurrentBlip.code == args[1] then
            ESX.ShowNotification("Postal Code - Tenhle Postal Code už v navigaci je nastavený!", { type = "error" })
        elseif args and tonumber(args[1]) then
            SetGPSToPostal(args[1])
        else
            ESX.ShowNotification("Postal Code - Musíte zadat Postal Code!", { type = "error" })
        end
    end
end)

function SetGPSToPostal(postalCode)
    local postal = nil
    for i=1, #POSTALS do
        if POSTALS[i].code == postalCode then
            postal = POSTALS[i]
            break
        end
    end

    if(not postal) then
        ESX.ShowNotification("Postal Code - Zadaný Postal Code nenalezen!", {
            type = "error"
        })
        return
    end

    if CurrentBlip then
        Base:DeleteBlip(CurrentBlip.id)
    end

    CurrentBlip = {
        id = "postal_"..postal.code,
        coords = postal.coords,
        blipId = Base:CreateBlip({
            id = "postal_"..postal.code,
            coords = vector3(postal.coords.x, postal.coords.y, 0.0),
            sprite = 8,
            scale = 0.8,
            colour = 3,
            label = ("POSTAL #%s"):format(postal.code)
        }),
        code = postal.code
    }

    SetBlipRoute(CurrentBlip.blipId, true)
    SetBlipRouteColour(CurrentBlip.blipId, 3)

    ESX.ShowNotification("Postal Code - Navigace nastavena na PC #"..postal.code.."!", { type = "success" })
end
