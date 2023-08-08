local Target = exports.ox_target
local IsInGarage = false
local GaragesBlips = {}

Citizen.CreateThread(function()
    AddTextEntry("STRIN_GARAGES:INTERACT", "<FONT FACE='Righteous'>~g~<b>[E]</b>~w~ Garáž</FONT>")
    for garageId,garage in pairs(Garages) do
        if(garage.showBlip) then
            GaragesBlips[garageId] = CreateGarageBlip(garage)
        end
        local garagePoint = lib.points.new({
            coords = garage.coords,
            distance = 20.0,
        })

        function garagePoint:nearby()
            -- na serveru to zabezpečené není, takže dumpeři enjoy
            if(garage.jobs and next(garage.jobs) and not lib.table.contains(garage.jobs, ESX.PlayerData?.job?.name)) then
                return
            end
            if(self.currentDistance < (garage.showBlip and 20 or 12.5) and not IsInGarage) then
                local markerCoords = vector3(garage.coords.x, garage.coords.y, garage.coords.z - 1.0)
                DrawMarker(1, markerCoords, 0, 0, 0, 0, 0, 0, 2.5, 2.5, 0.25, 255, 255, 0, 5)
            end
            if(self.currentDistance < (garage.showBlip and 7.5 or 3.75) and not IsInGarage) then
                DrawFloatingText(garage.coords)
                if(IsControlJustReleased(0, 38)) then
                    local ped = PlayerPedId()
                    local vehicle = GetVehiclePedIsIn(ped)
                    if(vehicle ~= 0) then
                        TriggerServerEvent("strin_garages:storeVehicle")
                    else
                        OpenGarageMenu(garage, garageId)
                    end
                end
            end
        end
    end
end)

RegisterNetEvent("strin_garages:setVehicleProperties", function(netId, props)
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end

    if(not props or not next(props)) then
        return
    end
    
    if(not NetworkDoesEntityExistWithNetworkId(netId)) then
        while true do
            if(NetworkDoesEntityExistWithNetworkId(netId)) then
                break
            end
            Citizen.Wait(250)
        end
    end
    
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    local ped = PlayerPedId()
    TaskWarpPedIntoVehicle(ped, vehicle, -1)
    lib.setVehicleProperties(vehicle, props)
end)

lib.callback.register("strin_garages:getVehicleProperties", function(netId)  
    if(not NetworkDoesEntityExistWithNetworkId(netId)) then
        while not NetworkDoesEntityExistWithNetworkId(netId) do
            Citizen.Wait(0)
        end
    end
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if(not vehicle or vehicle == 0) then
        return nil
    end
    return lib.getVehicleProperties(vehicle)
end)

function OpenGarageMenu(garage, garageId)
    local elements = {}
    local vehicles = {
        personal = {},
        society = {}
    }
    local cbName = "getAllCurrentVehicles"
    /*
        nino jsi čurák, že tohle musím dělat - strin
    */
    if((ESX.PlayerData?.job?.name or ""):find("police") and garage.isPolice) then
        cbName = "getSocietyVehicles"
    elseif((ESX.PlayerData?.job?.name or ""):find("police") and not garage.isPolice) then
        cbName = "getPersonalVehicles"
    end
    
    local retrievedVehicles = lib.callback.await("strin_garages:"..cbName, 1000)
    if(not retrievedVehicles or not next(retrievedVehicles)) then
        ESX.ShowNotification("Nejsou dostupná žádná vozidla!", { type = "error" })
        return
    end
    for _,v in pairs(retrievedVehicles) do
        if(v.job) then
            table.insert(vehicles.society, v)
        else
            table.insert(vehicles.personal, v)
        end
    end
    if(#vehicles.personal > 0) then
        table.insert(elements, { label = "Osobní vozidla", value = "personal" })
    end
    if(#vehicles.society > 0) then
        table.insert(elements, { label = "Firemní vozidla", value = "society" })
    end
    IsInGarage = true
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "garage_"..garageId, {
        title = garage.label or "Garáž",
        align = "center",
        elements = elements
    }, function(data, menu)
        menu.close()
        OpenVehiclesMenu(vehicles[data.current.value])
    end, function(data, menu)
        menu.close()
        IsInGarage = false
    end)
end

function OpenVehiclesMenu(vehicles, pageNumber)
    local elements = {}
    local pageSize = 6
    local pageCount = (#vehicles % pageSize == 0) and math.floor(#vehicles / pageSize) or math.ceil(#vehicles / pageSize + 0.5)
    if(not pageNumber) then
        pageNumber = 1
    end
    local startIndex = (pageNumber == 1) and 1 or ((pageSize * (pageNumber - 1)) + 1)
    local endIndex = pageNumber * pageSize

    if(pageNumber > 1) then
        table.insert(elements, {
            label = '<span style="color: #e74c3c"> << Předchozí stránka </span>',
            value = "previous_page"
        })
    end
    for i=startIndex, endIndex do
        local vehicle = vehicles[i]
        if(vehicle) then
            table.insert(elements, {
                label = ([[<div style="display: flex; justify-content: space-between; align-items: center; min-width: 400px;">
                    %s (#%s)<div>%s</div><div style="color: %s;">%s</div>
                </div>]]):format(
                    (vehicle.label and vehicle.label or vehicle.model),
                    i,
                    vehicle.plate,
                    vehicle.stored == 1 and "#2ecc71" or "#e74c3c",
                    vehicle.stored == 1 and "Dostupné" or "Nedostupné"
                ),
                value = i,
            })
        end
    end

    if(pageNumber < pageCount) then
        table.insert(elements, {
            label = '<span style="color: #2ecc71"> Další stránka >> </span>',
            value = "next_page"
        })
    end
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "garage_vehicles", {
        title = "Garáž ("..pageNumber.."/"..pageCount..")",
        align = "center",
        elements = elements,
    }, function(data, menu)
        menu.close()
        if(data.current.value == "next_page") then
            OpenVehiclesMenu(vehicles, pageNumber + 1)
            return
        end
        if(data.current.value == "previous_page") then
            OpenVehiclesMenu(vehicles, pageNumber - 1)
            return
        end
        local vehicle = vehicles[data.current.value]
        if(vehicle.job and vehicle.stored ~= 1 and vehicle.owner == nil and not vehicle.impound) then
            TriggerServerEvent("strin_garages:callImpound", vehicle.id)
            OpenVehiclesMenu(vehicles, pageNumber)
            return
        elseif(vehicle.job and vehicle.stored ~= 1 and vehicle.owner == nil and vehicle.impound) then
            local result = lib.callback.await("strin_garages:getImpoundStatus", 1000, vehicle.id)
            ESX.ShowNotification(("Vozidlo je v přepravě do garáže, vyčkejte prosím%s."):format(
                result and (" %s vteřin"):format(result) or ""
            ))
            OpenVehiclesMenu(vehicles, pageNumber)
            return
        end
        OpenVehicleMenu(vehicle)
    end, function(data, menu)
        menu.close()
        IsInGarage = false
    end)
end

function OpenVehicleMenu(vehicle)
    local elements = {}
    table.insert(elements, {
        label = vehicle.stored == 1 and "Vytáhnout vozidlo" or "<span style='color: #e74c3c;'>Vozidlo není dostupné</span>",
        value = "spawn",
    })
    if(vehicle.owner) then
        table.insert(elements, {
            label = "Přejmenovat vozidlo",
            value = "rename",
        })
    end
    if(vehicle.stored ~= 1 and vehicle.impound) then
        table.insert(elements, {
            label = ("Vozidle je na cestě!"),
            value = "impound",
        })
    end
    if(vehicle.stored ~= 1 and not vehicle.impound) then
        table.insert(elements, {
            label = "Zavolat odtahovou službu",
            value = "impound",
        })
    end
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "vehicle_"..vehicle.id, {
        title = "Vozidlo - "..(vehicle.label and vehicle.label or vehicle.model).." - "..vehicle.plate..(
            json.decode(vehicle.props or "{}")?.plate == "XXXXXXXX" and ' <i class="fas fa-user-secret"></i>' or ""
        ),
        align = "center",
        elements = elements,
    }, function(data, menu)
        menu.close()
        if(data.current.value == "spawn" and vehicle.stored ~= 1) then
            ESX.ShowNotification("Tohle vozidlo je dostupné pouze u odtahové služby!", { type = "error" })
            IsInGarage = false
            return
        end
        if(data.current.value == "spawn") then
            TriggerServerEvent("strin_garages:takeOutVehicle", vehicle.id)
            IsInGarage = false
        end
        if(data.current.value == "rename") then
            ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "vehicle_label", {
                title = "Text (nechte prázdné pro reset)",
            }, function(data2, menu2)
                menu2.close()
                IsInGarage = false
                TriggerServerEvent("strin_garages:renameVehicle", vehicle.id, data2.value or "")
            end, function(data2, menu2)
                menu2.close()
                IsInGarage = false
            end)
        end
        if(data.current.value == "impound") then
            IsInGarage = false
            if(vehicle.impound) then
                local result = lib.callback.await("strin_garages:getImpoundStatus", 1000, vehicle.id)
                ESX.ShowNotification(("Vozidlo je na cestě k Vám, vyčkejte prosím%s."):format(
                    result and (" %s vteřin"):format(result) or ""
                ))
                return
            end
            TriggerServerEvent("strin_garages:callImpound", vehicle.id)
        end
    end, function(data, menu)
        menu.close()
        IsInGarage = false
    end)
end

function DrawFloatingText(coords)
    BeginTextCommandDisplayHelp('STRIN_GARAGES:INTERACT')
    SetFloatingHelpTextWorldPosition(1, coords)
    SetFloatingHelpTextStyle(1, 1, 72, -1, 3, 0)
    EndTextCommandDisplayHelp(2, false, false, -1)
    SetFloatingHelpTextWorldPosition(0, coords.x, coords.y, coords.z)
end

function CreateGarageBlip(garage)
    local blip = AddBlipForCoord(garage.coords)
    SetBlipDisplay(blip, 2)
    SetBlipSprite(blip, 50)
    SetBlipColour(blip, 16)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("<FONT FACE='Righteous'>Garáž</FONT>")
    EndTextCommandSetBlipName(blip)
    return blip
end

AddEventHandler("onResourceStop", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        for _,v in pairs(GaragesBlips) do
            if(DoesBlipExist(v)) then
                RemoveBlip(v)
            end
        end
    end
end)