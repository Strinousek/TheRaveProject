local AIDoctorNPCs = {}

Citizen.CreateThread(function()
    for k,v in pairs(AIDoctors) do
        local doctorPoint = lib.points.new({
            coords = v.coords,
            distance = 20
        })

        function doctorPoint:onEnter()
            if(not AIDoctorNPCs[k] or not DoesEntityExist(AIDoctorNPCs[k])) then
                AIDoctorNPCs[k] = CreateDoctorPed(v)
            end
        end

        function doctorPoint:onExit()
            if(AIDoctorNPCs[k] and DoesEntityExist(AIDoctorNPCs[k])) then
                DeleteEntity(AIDoctorNPCs[k])
                AIDoctorNPCs[k] = nil
            end
        end

        function doctorPoint:nearby()
            if(self.currentDistance < 3) then
                local ped = PlayerPedId()
                local health = GetEntityHealth(ped)
                if(health < 5) then
                    Draw3DText(v.coords, "~g~<b>[E]</b>~w~ Doktor")
                    if(IsControlJustReleased(0, 38)) then
                        TriggerServerEvent("strin_base:requestAIRevive")
                    end
                end
            end
        end
    end
end)

function Draw3DText(coords, text)
    local onScreen,_x,_y = World3dToScreen2d(coords.x,coords.y,coords.z)
    local px,py,pz = table.unpack(GetGameplayCamCoord())
    local dist = #(vector3(px,py,pz) - coords)
    local scale = 0.54
    if onScreen then
        SetTextColour(255, 255, 255, 255)
        SetTextScale(0.0*scale, 0.55*scale)
        SetTextFont(fontId) -- (font)
        SetTextProportional(1)
        SetTextCentre(true)
        if dropShadow then
            SetTextDropshadow(10, 100, 100, 100, 255)
        end
        local height = GetTextScaleHeight(0.55*scale, font)
        local width = utf8.len(text)*0.0032
        SetTextEntry("STRING")
        AddTextComponentString(text)
        EndTextCommandDisplayText(_x, _y)
        DrawRect(_x, _y+scale/45, width + 0.070, height + 0.010, 0, 0, 0, 100)
    end
end

function CreateDoctorPed(doctor)
    RequestModel(doctor.model)
    while not HasModelLoaded(doctor.model) do
        Citizen.Wait(0)
    end
    local _, groundZ = GetGroundZFor_3dCoord(doctor.coords.x, doctor.coords.y, doctor.coords.z, 0)
    local ped = CreatePed(0, doctor.model, doctor.coords.x, doctor.coords.y, groundZ, doctor.heading, false, false)
    SetPedDefaultComponentVariation(ped)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedDiesWhenInjured(ped, false)
    SetEntityInvincible(ped, true)
    SetPedCanPlayAmbientAnims(ped, true)
    FreezeEntityPosition(ped, true)
    return ped
end

AddEventHandler("onResourceStop", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        for k,v in pairs(AIDoctorNPCs) do
            if(v and DoesEntityExist(v)) then
                DeleteEntity(v)
            end
        end
    end
end)