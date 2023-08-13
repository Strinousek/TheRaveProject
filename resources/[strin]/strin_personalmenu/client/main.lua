function OpenCharacterInfoMenu()
    local elements = {}
    local data = lib.callback.await("strin_personalmenu:getCharacterData")
    table.insert(elements, {label = "Jméno: <span style='float: right;'>"..data.fullname.."</span>", value = "xxx"})
    table.insert(elements, {label = "Datum narození: <span style='float: right;'>"..data.dateofbirth.."</span>", value = "xxx"})
    table.insert(elements, {label = "Pohlaví: <span style='float: right;'>"..(data.sex:upper() == "M" and "Muž" or "Žena").."</span>", value = "xxx"})
    
    table.insert(elements, {label = "Cash: <span style='float: right;'>"..ESX.Math.GroupDigits(data.money).."$</span>", value = "xxx"})
    table.insert(elements, {label = "Bankovní účet: <span style='float: right;'>"..ESX.Math.GroupDigits(data.bank).."$</span>", value = "xxx"})
    table.insert(elements, {label = "Práce: <span style='float: right;'>"..data.job.label.." - "..data.job.grade_label.."</span>", value = "xxx"})
    --table.insert(elements, {label = "Váha: <span style='float: right;'>"..data.weight.."</span>", value = "xxx"})
    --table.insert(elements, {label = "Výška: <span style='float: right;'>"..data.height.."</span>", value = "xxx"})
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "character_info_menu", {
        title = "Info o postavě",
        align = "center",
        elements = elements
    }, nil, function(data, menu)
        menu.close()
        OpenPersonalMenu()
    end)
end

function OpenCharacterBillsMenu()
    local elements = {}
    local bills = lib.callback.await("strin_personalmenu:getCharacterBills")
    if(not next(bills)) then
        ESX.ShowNotification("Nemáte žádné faktury!", { type = "error" })
        OpenPersonalMenu()
        return
    end
    for k,v in pairs(bills) do
        table.insert(elements, {
            label = "#"..k.." - "..v.label.." - "..v.amount.."$",
            value = v.id,
        })
    end
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "character_info_menu", {
        title = "Faktury",
        align = "center",
        elements = elements
    }, function(data, menu)
        menu.close()
        TriggerServerEvent("strin_jobs:payBill", data.current.value)
        OpenPersonalMenu()
    end, function(data, menu)
        menu.close()
        OpenPersonalMenu()
    end)
end

AddEventHandler("esx:exitedVehicle", function()
    local vehicleMenuNames = {
        "vehicle_menu", "extras_menu",
        "liveries_menu", "doors_menu"
    }
    for _,v in pairs(vehicleMenuNames) do
        if(ESX.UI.Menu.IsOpen("default", GetCurrentResourceName(), v)) then
            ESX.UI.Menu.CloseAll() 
        end
    end
end)

local function CountVehicleExtras(vehicle)
    local vehicleExtrasCount = 0
    for i=0, 15 do
        if DoesExtraExist(vehicle, i) then
            vehicleExtrasCount += 1
        end
    end
    return vehicleExtrasCount
end

function OpenVehicleMenu(vehicle)
    local elements = {}
    if(GetEntityHealth(vehicle) >= GetEntityMaxHealth(vehicle)) then
        if(GetVehicleLiveryCount(vehicle) ~= -1) then
            table.insert(elements, {label = "Livery", value = "liveries"})
        end
        if(CountVehicleExtras(vehicle) > 0) then
            table.insert(elements, {label = "Extras", value = "extras"})
        end
    end
    table.insert(elements, {label = "Dveře", value = "doors"})
    if(not IsVehicleEngineStarting(vehicle) and not GetIsVehicleEngineRunning(vehicle)) then
        table.insert(elements, {label = "Motor: <span style='float: right'>NENASTARTOVANÝ</span>", value = "engine_turn_on"})
    else
        table.insert(elements, {label = "Motor: <span style='float: right'>NASTARTOVANÝ</span>", value = "engine_turn_off"})
    end
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "vehicle_menu", {
        title = "Vozidlo - "..GetVehicleNumberPlateText(vehicle),
        align = "center",
        elements = elements,
    }, function(data, menu)
        menu.close()
        if(data.current.value == "liveries") then
            OpenVehicleLiveriesMenu(vehicle)
        elseif(data.current.value == "extras") then
            OpenVehicleExtrasMenu(vehicle)
        elseif(data.current.value == "doors") then
            OpenVehicleDoorsMenu(vehicle)
        elseif(data.current.value == "engine_turn_on") then
            SetVehicleEngineOn(vehicle, true, false, false)
            OpenVehicleMenu(vehicle)
        elseif(data.current.value == "engine_turn_off") then
            SetVehicleEngineOn(vehicle, false, false, false)
            OpenVehicleMenu(vehicle)
        end
        /*if engine == true then
            SetVehicleEngineOn(veh, false, false, false)
            engine = false
            openVehicleMenu()
        elseif engine == false then
            SetVehicleEngineOn(veh, true, false, false)
            engine = true
            openVehicleMenu()
        end
        while engine == false do
            SetVehicleUndriveable(veh, true)
            Citizen.Wait(0)
        end
        while engine == true do
            SetVehicleUndriveable(veh, false)
            Citizen.Wait(0)
        end*/
        /*elseif(data.current.value == "hood") then
            if GetVehicleDoorAngleRatio(vehicle, 4) > 0.0 then 
                SetVehicleDoorShut(vehicle, 4, false)
            else
                SetVehicleDoorOpen(vehicle, 4, false)      
            end
        elseif(data.current.value == "trunk") then
            if GetVehicleDoorAngleRatio(veh, 5) > 0.0 then 
                SetVehicleDoorShut(vehicle, 5, false)
            else
                SetVehicleDoorOpen(vehicle, 5, false)      
            end
        end*/
    end, function(data, menu)
        menu.close()
        OpenPersonalMenu()
    end)
end

function OpenVehicleExtrasMenu(vehicle)
    local elements = {}

    for i=0, 15 do
        if DoesExtraExist(vehicle, i) then
            if IsVehicleExtraTurnedOn(vehicle, i) then
                table.insert(elements, {label = 'Extra #'..i.." ✔️", value = i})
            elseif not IsVehicleExtraTurnedOn(vehicle, i) then
                table.insert(elements, {label = 'Extra #'..i.." ❌", value = i})
            end
        end
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'extras_menu', {  
      title    = "Extras",
      align    = "center",
      elements = elements
    }, function(data, menu)
        menu.close()
        if data.current.value then
            if IsVehicleExtraTurnedOn(vehicle, data.current.value) then
                SetVehicleExtra(vehicle, data.current.value, 1)
                SetVehicleFixed(vehicle)
                OpenVehicleExtrasMenu(vehicle)
            else
                SetVehicleExtra(vehicle, data.current.value, 0)
                SetVehicleFixed(vehicle)
                OpenVehicleExtrasMenu(vehicle)
            end
        end
    end, function(data, menu)
        menu.close()
        OpenVehicleMenu(vehicle)
    end)    
end

function OpenVehicleLiveriesMenu(vehicle)
    local elements = {}
    local liveriesCount = GetVehicleLiveryCount(vehicle)
    if (liveriesCount == -1) then
        ESX.ShowNotification('Tohle vozidlo nemá žádné livery!', { type = "error" })
        OpenVehicleMenu(vehicle)
        return
    end

    for i=0, liveriesCount do
        if i == GetVehicleLivery(vehicle) then
            table.insert(elements, {label = 'Livery #'..i.." ✔️", value = i})
        else
            table.insert(elements, {label = 'Livery #'..i.." ❌", value = i})
        end
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'liveries_menu', {
        title    = "Livery",
        align    = "center",
        elements = elements
    }, function(data, menu)
        menu.close()
        if data.current.value then
            if GetVehicleLivery(vehicle) == data.current.value then
                SetVehicleLivery(vehicle, 1)
                SetVehicleFixed(vehicle)
                OpenVehicleLiveriesMenu(vehicle)
            else
                SetVehicleLivery(vehicle, data.current.value)
                SetVehicleFixed(vehicle)
                OpenVehicleLiveriesMenu(vehicle)
            end
        end
    end, function(data, menu)
        menu.close()
        OpenVehicleMenu(vehicle)
    end)
end

function OpenVehicleDoorsMenu(vehicle)
    local ped = PlayerPedId()
    local elements = {}
    if(not (GetPedInVehicleSeat(vehicle, -1) == ped)) then
        ESX.ShowNotification("Nejste řidič vozidla!", { type = "error" })
        OpenVehicleMenu(vehicle)
        return
    end

    table.insert(elements, { label = 'Otevřít všechny dveře', value = 'all_doors' })
    table.insert(elements, { label = 'Otevřít přední dveře', value = 'front_doors' })
    table.insert(elements, { label = 'Otevřít zadní dveře', value = 'back_doors' })

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "doors_menu", {
        title = "Dveře",
        align = "center",
        elements = elements
    }, function(data, menu)
        if(data.current.value == "all_doors") then
            if GetVehicleDoorAngleRatio(vehicle, 1) > 0.0 then 
                SetVehicleDoorShut(vehicle, 3, false)
                SetVehicleDoorShut(vehicle, 2, false)
                SetVehicleDoorShut(vehicle, 1, false)
                SetVehicleDoorShut(vehicle, 0, false)         
             else
                SetVehicleDoorOpen(vehicle, 3, false)
                SetVehicleDoorOpen(vehicle, 2, false)
                SetVehicleDoorOpen(vehicle, 1, false)
                SetVehicleDoorOpen(vehicle, 0, false)  
            end
        elseif(data.current.value == "front_doors") then
            if GetVehicleDoorAngleRatio(vehicle, 0) > 0.0 then 
                SetVehicleDoorShut(vehicle, 0, false)
            else
                SetVehicleDoorOpen(vehicle, 0, false)
            end
            if GetVehicleDoorAngleRatio(vehicle, 1) > 0.0 then 
                SetVehicleDoorShut(vehicle, 1, false)
            else
                SetVehicleDoorOpen(vehicle, 1, false)
            end
        elseif(data.current.value == "back_doors") then
            if GetVehicleDoorAngleRatio(vehicle, 2) > 0.0 then 
                SetVehicleDoorShut(vehicle, 2, false)
            else
                SetVehicleDoorOpen(vehicle, 2, false)
            end
            if GetVehicleDoorAngleRatio(vehicle, 3) > 0.0 then 
                SetVehicleDoorShut(vehicle, 3, false)
            else
                SetVehicleDoorOpen(vehicle, 3, false)
            end
        end
    end, function(data, menu)
        menu.close()
        OpenVehicleMenu(vehicle)
    end)
end

function OpenPersonalMenu()
    local elements = {}
    table.insert(elements, { label = "Informace o postavě", value = "character_info" })
    local ped = PlayerPedId()
    if(not IsEntityPlayingAnim(ped, 'mp_arresting', 'idle', 3) and (GetEntityHealth(ped) > 0)) then
        local vehicle = GetVehiclePedIsIn(ped)
        if(vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped) then
            table.insert(elements, { label = "Vozidlo", value = "vehicle_menu", vehicle = vehicle })
        end
        table.insert(elements, { label = "Faktury", value = "bills" })
    end
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "personal_menu", {
        title = "Osobní menu",
        align = "center",
        elements = elements,
    }, function(data, menu)
        menu.close()
        if(data.current.value == "character_info") then
            OpenCharacterInfoMenu()
        elseif(data.current.value == "vehicle_menu") then
            OpenVehicleMenu(data.current.vehicle)
        elseif(data.current.value == "bills") then
            OpenCharacterBillsMenu()
        end
    end, function(data, menu)
        menu.close()
    end)
end


RegisterCommand("personalmenu", function()
    OpenPersonalMenu() 
end)


RegisterKeyMapping("personalmenu", "<FONT FACE='Righteous'>Osobní menu~</FONT>", "keyboard", "F3")