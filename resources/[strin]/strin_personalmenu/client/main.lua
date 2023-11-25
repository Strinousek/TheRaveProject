function OpenCharacterInfoMenu()
    local elements = {}
    local data = lib.callback.await("strin_personalmenu:getCharacterData", false)
    if(not data or not next(data)) then
        ESX.ShowNotification("Nastala chyba při načítání dat postavy, zkuste znovu.")
        return
    end
    table.insert(elements, {label = "CitizenID: <span style='float: right;'>"..data.char_identifier.."</span>", value = "char_identifier"})
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
    }, function(menuData, menu)
        if(menuData.current.value == "char_identifier") then
            lib.setClipboard(data.char_identifier)
            ESX.ShowNotification("Zkopírováno CitizenID - "..data.char_identifier..".")
        end
    end, function(menuData, menu)
        menu.close()
        OpenPersonalMenu()
    end)
end

function OpenVIPMenu()
    local elements = {}
    local data = lib.callback.await("strin_base:getVIP", false)
    /*
        backgroundImage = "https://imgur.com/lLOuaiK.gif",
        impoundReductionPercentage = 100,
        propertyDiscountPercentage = 10,
        sideJobBonusPercentage = 12.5,
        multicharEverywhere = true,
        queuePoints = 5000,
    */
    local insertSplitElement = function(leftText, rightText, value)
        table.insert(elements, {
            label = ([[<div style="display: flex; justify-content: space-between; align-items: center;">
                %s<div>%s</div>
            </div>]]):format(leftText, rightText),
            value = value or "xxx",
        })
    end
    insertSplitElement(
        "Pozadí v scoreboardu:",
        data.backgroundImage and (
            type(data.backgroundImage) == "string" and 
            "<img src='"..data.backgroundImage.."' width='64px' height='36px'>" or 
            "Nenastaveno"
        ) or '<i class="fas fa-times"></i>',
        "background"
    )
    insertSplitElement(
        "Zkrácení osobní odtahové služby:",
        data.impoundReductionPercentage.."%"
    )
    insertSplitElement(
        "Zvýšení výdělků ze sidejobů:",
        data.sideJobBonusPercentage.."%"
    )
    insertSplitElement(
        "Sleva na nemovitosti:",
        data.propertyDiscountPercentage.."%"
    )
    insertSplitElement(
        "/multichar kdekoliv:",
        data.multicharEverywhere and '<i class="fas fa-check"></i>' or '<i class="fas fa-times"></i>'
    )
    insertSplitElement(
        "Queue pointy:",
        ESX.Math.GroupDigits(data.queuePoints)
    )
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "vip_menu", {
        title = "VIP",
        align = "center",
        elements = elements
    }, function(menuData, menu)
        if(menuData.current.value == "xxx") then
            return
        elseif(menuData.current.value == "background") then
            if(data.backgroundImage) then
                ESX.ShowNotification("O nastavení pozadí si musíte zažádat u admin / dev. týmu.")
            end
            return
        end
        menu.close()
        OpenPersonalMenu()
    end, function(data, menu)
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
            SetPedConfigFlag(PlayerPedId(), 429, true)
            while (not GetIsVehicleEngineRunning(vehicle) and not IsVehicleEngineStarting(vehicle)) do
                SetVehicleUndriveable(vehicle, true)
                SetVehicleEngineOn(vehicle, false, false, false)
                if(not cache.vehicle) then
                    SetPedConfigFlag(PlayerPedId(), 429, false)
                    break
                end
                Citizen.Wait(0)
            end
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

RegisterCommand("engine", function()
    if(not cache.vehicle) then
        ESX.ShowNotification("Nejste ve vozidle!", { type = "error" })
        return
    end
    local vehicle = cache.vehicle
    if(not IsVehicleEngineStarting(vehicle) and not GetIsVehicleEngineRunning(vehicle)) then
        ESX.ShowNotification("Motor zapnut.")
        SetVehicleEngineOn(vehicle, true, false, false)
        SetPedConfigFlag(PlayerPedId(), 429, false)
    else
        ESX.ShowNotification("Motor vypnut.")
        SetVehicleEngineOn(vehicle, false, false, false)
        SetPedConfigFlag(PlayerPedId(), 429, true)
        while (not GetIsVehicleEngineRunning(vehicle) and not IsVehicleEngineStarting(vehicle)) do
            SetVehicleUndriveable(vehicle, true)
            SetVehicleEngineOn(vehicle, false, false, false)
            if(not cache.vehicle) then
                SetPedConfigFlag(PlayerPedId(), 429, false)
                break
            end
            Citizen.Wait(0)
        end
    end
end)

lib.onCache("vehicle", function(value)
    if(not value) then
        SetPedConfigFlag(PlayerPedId(), 429, false)
    end
end)

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
    table.insert(elements, { label = "Denní odměny / Odehraný čas", value = "rewards" })
    table.insert(elements, { label = "Informace o postavě", value = "character_info" })
    local ped = PlayerPedId()
    if(not IsEntityPlayingAnim(ped, 'mp_arresting', 'idle', 3) and (GetEntityHealth(ped) > 0)) then
        local vehicle = GetVehiclePedIsIn(ped)
        if(vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped) then
            table.insert(elements, { label = "Vozidlo", value = "vehicle_menu", vehicle = vehicle })
        end
        table.insert(elements, { label = "Faktury", value = "bills" })
    end
    local hasVIP = lib.callback.await("strin_base:hasVIP", false)
    if(hasVIP) then
        table.insert(elements, { label = "VIP", value = "vip_menu" })
    end
    table.insert(elements, { label = "Schopnosti", value = "skills_menu" })
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "personal_menu", {
        title = "Osobní menu",
        align = "center",
        elements = elements,
    }, function(data, menu)
        menu.close()
        if(data.current.value == "character_info") then
            OpenCharacterInfoMenu()
        elseif(data.current.value == "rewards") then
            ExecuteCommand("daily")
        elseif(data.current.value == "vehicle_menu") then
            OpenVehicleMenu(data.current.vehicle)
        elseif(data.current.value == "bills") then
            OpenCharacterBillsMenu()
        elseif(data.current.value == "vip_menu") then
            OpenVIPMenu()
        elseif(data.current.value == "skills_menu") then
            ExecuteCommand("skills")
        end
    end, function(data, menu)
        menu.close()
    end)
end


RegisterCommand("personalmenu", function()
    OpenPersonalMenu() 
end)


RegisterKeyMapping("personalmenu", "<FONT FACE='Righteous'>Osobní menu~</FONT>", "keyboard", "F3")