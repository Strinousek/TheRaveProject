local IsInMenu = false
local RequestedServer = false

local FAIcons = {
    ["cog"] = "fas fa-cog",
    ["cogs"] = "fas fa-cogs",
    ["wrench"] = "fas fa-wrench",
    ["tools"] = "fas fa-tools",
    ["drafting-compass"] = "fas fa-drafting-compass",
    ["screwdriver"] = "fas fa-screwdriver",
    ["battery"] = "fas fa-car-battery",
    ["spray-can"] = "fas fa-spray-can",
}

lib.callback.register("strin_tunning:getVehicleProperties", function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped)
    return vehicle ~= 0 and lib.getVehicleProperties(vehicle) or nil
end)

lib.callback.register("strin_tunning:setVehicleProperties", function(properties, vehicleNetId)
    local ped = PlayerPedId()
    local vehicle = vehicleNetId and NetworkGetEntityFromNetworkId(vehicleNetId) or GetVehiclePedIsIn(ped)
    return vehicle ~= 0 and lib.setVehicleProperties(vehicle, properties) or nil
end)

Citizen.CreateThread(function()
    AddTextEntry("STRIN_TUNNING:INTERACT", "<FONT FACE='Righteous'>~g~<b>[E]</b>~s~ Tunning</FONT>")
    for k,v in pairs(TunningZones) do
        local point = lib.points.new({
            coords = v.coords,
            distance = v.distance or 3.0
        })

        function point:nearby()
            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped, false)
            if(vehicle ~= 0 and not RequestedServer and not IsInMenu) then
                DisplayHelpTextThisFrame("STRIN_TUNNING:INTERACT")
                if(IsControlJustReleased(0, 38)) then
                    OpenTicketsMenu(k)
                end
            end
        end
    end
    while GetResourceState("ox_inventory") ~= "started" do
        Citizen.Wait(0)
    end
    exports.ox_inventory:displayMetadata({
        category = "Kategorie",
        plate = "SPZ",
    })
    while true do
        local sleep = 1000
        if(IsInMenu or RequestedServer) then
            sleep = 0
            
			DisableControlAction(0, 288, true)
			DisableControlAction(0, 289, true)
			DisableControlAction(0, 170, true)
			DisableControlAction(0, 167, true)
			DisableControlAction(0, 168, true)
			DisableControlAction(0, 23, true)  -- Disable exit vehicle
			DisableControlAction(0, 75, true)  -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle
            /*
                DisableAllControlActions(0)
                EnableControlAction(0, 1) -- mouse - left rotation
                EnableControlAction(0, 2) -- mouse - right rotation
                EnableControlAction(0, 32) -- W - forward - for tyre smoke
                EnableControlAction(0, 33) -- S - back - for tyre smoke
                EnableControlAction(0, 38) -- E - horn
                EnableControlAction(0, 320) -- V 1 - view
                EnableControlAction(0, 325) -- V 2 - view
                EnableControlAction(0, 337) -- X - hydraulics
                EnableControlAction(0, 338) -- A - hydraulics - left
                EnableControlAction(0, 339) -- D - hydraulics - right
                EnableControlAction(0, 340) -- LEFT SHIFT - hydraulics up
                EnableControlAction(0, 341) -- LEFT CTRL - hydraulics down
            */
        end
        Citizen.Wait(sleep)
    end
end)

/*RegisterCommand("tunningtest", function()
    lib.setClipboard(ESX.DumpTable(lib.getVehicleProperties(GetVehiclePedIsIn(PlayerPedId()))))
end)*/

RegisterNetEvent("strin_tunning:stopTunning", function(vehicleNetId, vehicleProperties)
    if(
        source == "" or
        GetInvokingResource() ~= nil
    ) then
        return
    end
    ESX.UI.Menu.CloseAll()
    IsInMenu = false
    RequestedServer = false
    /*local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
    if(vehicleProperties) then
        lib.setVehicleProperties(vehicle, vehicleProperties)
    end
    FreezeEntityPosition(vehicle, false)*/
end)

RegisterNetEvent("strin_tunning:startTunning", function(tunningZoneId, vehicleNetId, vehicleProperties)
    if(
        source == "" or
        GetInvokingResource() ~= nil or 
        type(tunningZoneId) ~= "number" or 
        type(vehicleNetId) ~= "number" or 
        not NetworkDoesEntityExistWithNetworkId(vehicleNetId)
    ) then
        return
    end
    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
    if(vehicleProperties) then
        lib.setVehicleProperties(vehicle, vehicleProperties)
    end
    RequestedServer = false
    FreezeEntityPosition(vehicle, true)
    OpenTunningMenu(tunningZoneId, vehicle)
end)

function OpenTicketsMenu()
    IsInMenu = true
    local options = {}

    local inventoryTickets = Inventory:GetSlotsWithItem("ticket", { category = "tunning" })
    local vehicleTickets = lib.callback.await("strin_tunning:getVehicleTickets", false)
    if(#(vehicleTickets or {}) < MaxTicketsPerVehicle) then
        table.insert(options, {
            label = "Vytvořit nový tunning lístek",
            value = "request_ticket"
        })
    end
    if(#inventoryTickets > 0) then
        if(vehicleTickets and next(vehicleTickets)) then
            for vehicleTicketId,vehicleTicket in pairs(vehicleTickets) do
                for inventoryTicketId,inventoryTicket in pairs(inventoryTickets) do
                    if(inventoryTicket.metadata?.id == vehicleTicket.id) then
                        table.insert(options, {
                            label = "Lístek - "..inventoryTicket.metadata?.plate.." - "..(vehicleTicket.price or 0).."$ - ".." #"..vehicleTicket.id,
                            value = "use_ticket",
                            ticketId = vehicleTicket.id
                        })
                    end
                end
            end
        end
    end

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "tunning_menu_tickets", {
        title = "Tunning lístky",
        align = "center",
        elements = options,
    }, function(data, menu)
        menu.close()
        if(data.current.value == "request_ticket") then
            local ticketId = lib.callback.await("strin_tunning:requestTicket")
            if(not ticketId) then
                OpenTicketsMenu()
                return
            end
            RequestedServer = true
            IsInMenu = false
            TriggerServerEvent("strin_tunning:startTunning", ticketId)
        elseif(data.current.value == "use_ticket") then
            RequestedServer = true
            IsInMenu = false
            TriggerServerEvent("strin_tunning:startTunning", data.current.ticketId)
        end
    end, function(data, menu)
        menu.close()
        IsInMenu = false
    end)
end

function OpenTunningMenu(tunningZoneId, vehicle, onAdminCloseCallback)
    IsInMenu = true
    if(NetworkGetEntityOwner(vehicle) ~= PlayerId()) then
        NetworkRequestControlOfEntity(vehicle)
        local start = GetGameTimer()
        while NetworkGetEntityOwner(vehicle) ~= PlayerId() do
            if((GetGameTimer() - start) > 5000) then
                RequestedServer = true
                TriggerServerEvent("strin_tunning:stopTunning")
                Citizen.Wait(500)
                OpenTicketsMenu()
                return
            end
            Citizen.Wait(0)
        end
    end
    local options = {
        {
            label = _U("upgrades"),
            value = "upgrades",
        },
        {
            label = _U("cosmetics"),
            value = "cosmetics",
        },
    }
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "tunning_menu_main", {
        title = "Tunning - "..(TunningZones[tunningZoneId]?.label or "Dílna"),
        align = "center",
        elements = options,
    }, function(data, menu)
        menu.close()
        if(data.current.value == "upgrades") then
            OpenUpgradesMenu(tunningZoneId, vehicle, onAdminCloseCallback)
        elseif(data.current.value == "cosmetics") then
            OpenCosmeticsMenu(tunningZoneId, vehicle, onAdminCloseCallback)
        end
    end, function(data, menu)
        menu.close()
        if(not onAdminCloseCallback) then
            RequestedServer = true
            TriggerServerEvent("strin_tunning:stopTunning")
            Citizen.Wait(500)
            OpenTicketsMenu()
        else
            onAdminCloseCallback()
        end
    end)
end

exports("OpenTunningMenu", function(cb)
    local isAdmin = lib.callback.await("strin_admin:isPlayerAdmin", false)
    if(isAdmin) then
        OpenTunningMenu("NONE", GetVehiclePedIsIn(PlayerPedId()), cb)
    else
        cb("NOT_ADMIN")
    end
end)

function OpenUpgradesMenu(tunningZoneId, vehicle, onAdminCloseCallback)
    local options = {}
    for k,v in pairs(CarParts.Upgrades) do
        local optionIndex = #options + 1
        local option = {
            label = v.label or _U(k),
            value = k,
            mod = v
        }
        options[optionIndex] = option
    end

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "tunning_menu_upgrades", {
        title = _U("upgrades"),
        align = "center",
        elements = options,
    }, function(data, menu)
        menu.close()
        local savedProperties = lib.getVehicleProperties(vehicle)
        OpenModMenu(tunningZoneId, vehicle, data.current.value, data.current.mod, function(changedValue)
            lib.setVehicleProperties(vehicle, savedProperties)
            if(type(changedValue) ~= "nil") then
                lib.setVehicleProperties(vehicle, {
                    [data.current.value] = changedValue
                })
            end
            OpenUpgradesMenu(tunningZoneId, vehicle, onAdminCloseCallback)
        end, onAdminCloseCallback ~= nil)
    end, function(data, menu)
        menu.close()
        OpenTunningMenu(tunningZoneId, vehicle, onAdminCloseCallback)
    end)
end

function OpenCosmeticsMenu(tunningZoneId, vehicle, onAdminCloseCallback)
    local options = {}
    local currentVehicleProperties = lib.getVehicleProperties(vehicle)
    local vehiclePrice = GetVehiclePrice(vehicle)
    for k,v in pairs(CarParts.Cosmetics) do
        local optionIndex = #options + 1
        local option = {
            label = v?.label or _U(k:lower()),
            value = k,
        }

        if(v.modType) then
            option.mod = v
        end

        options[optionIndex] = option
    end

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "tunning_menu_cosmetics", {
        title = _U("cosmetics"),
        align = "center",
        elements = options,
    }, function(data, menu)
        menu.close()
        if(not data.current.mod) then
            OpenCosmeticsSubMenu(tunningZoneId, vehicle, data.current.value, CarParts.Cosmetics[data.current.value], onAdminCloseCallback)
            return
        end
        local savedProperties = lib.getVehicleProperties(vehicle)
        OpenModMenu(tunningZoneId, vehicle, data.current.value, data.current.mod, function(changedValue)
            lib.setVehicleProperties(vehicle, savedProperties)
            if(type(changedValue) ~= "nil") then
                if(data.current.value == "modXenon" or data.current.value == "neonColor") then
                    if(data.current.value == "modXenon") then
                        lib.setVehicleProperties(vehicle, {
                            [data.current.value] = changedValue ~= 255 and true or false,
                            ["xenonColor"] = changedValue
                        })
                    else
                        local neon = CarNeons[changedValue]
                        local isNeonOff = neon.r == 0 and neon.g == 0 and neon.b == 0
                        lib.setVehicleProperties(vehicle, {
                            ["neonEnabled"] = {  table.unpack(isNeonOff and { false, false, false, false} or { true, true, true, true }) },
                            [data.current.value] = { neon.r, neon.g, neon.b }
                        })
                    end
                else
                    lib.setVehicleProperties(vehicle, {
                        [data.current.value] = changedValue
                    })
                end
            end
            OpenCosmeticsMenu(tunningZoneId, vehicle, onAdminCloseCallback)
        end, onAdminCloseCallback ~= nil)
    end, function(data, menu)
        menu.close()
        OpenTunningMenu(tunningZoneId, vehicle, onAdminCloseCallback)
    end)
end

function OpenCosmeticsSubMenu(tunningZoneId, vehicle, modKey, mods, onAdminCloseCallback)
    local options = {}
    local currentVehicleProperties = lib.getVehicleProperties(vehicle)
    local vehiclePrice = GetVehiclePrice(vehicle)
    for k,v in pairs(mods) do
        local optionIndex = #options + 1
        local option = {
            label = v?.label or _U(k:lower()),
            value = k,
        }

        if(v.modType) then
            option.mod = v
        end

        options[optionIndex] = option
    end
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "tunning_submenu_cosmetics", {
        title = _U(modKey:lower()),
        align = "center",
        elements = options
    }, function(data, menu)
        menu.close()
        if(data.current.value == "modFrontWheels") then
            local wheelType = OpenWheelTypesMenu(data.current.mod.wheelTypes)
            if(not wheelType) then
                OpenCosmeticsSubMenu(tunningZoneId, vehicle, modKey, mods, onAdminCloseCallback)
                return
            end
            data.current.mod.wheelType = wheelType
            local savedProperties = lib.getVehicleProperties(vehicle)
            OpenModMenu(tunningZoneId, vehicle, data.current.value, data.current.mod, function(changedValue)
                lib.setVehicleProperties(vehicle, savedProperties)
                if(type(changedValue) ~= "nil") then
                    lib.setVehicleProperties(vehicle, {
                        ["wheels"] = wheelType.index,
                        [data.current.value] = changedValue
                    })
                end
                OpenCosmeticsSubMenu(tunningZoneId, vehicle, modKey, mods, onAdminCloseCallback)
            end, onAdminCloseCallback ~= nil)
            return
        end
        if(data.current.value == "color1" or data.current.value == "color2" or data.current.value == "pearlescentColor" or data.current.value == "wheelColor") then
            local colour = OpenColoursMenu()
            if(not colour) then
                OpenCosmeticsSubMenu(tunningZoneId, vehicle, modKey, mods, onAdminCloseCallback)
                return
            end
            local colours = GetColoursFromName(colour)
            data.current.mod.colours = colours
            local savedProperties = lib.getVehicleProperties(vehicle)
            OpenModMenu(tunningZoneId, vehicle, data.current.value, data.current.mod, function(changedValue)
                lib.setVehicleProperties(vehicle, savedProperties)
                if(type(changedValue) ~= "nil") then
                    if(data.current.value == "tyreSmokeColor") then
                        local neon = CarNeons[changedValue]
                        local isNeonOff = neon.r == 0 and neon.g == 0 and neon.b == 0
                        local modSmokeEnabled = false
                        lib.setVehicleProperties(vehicle, {
                            ["modSmokeEnabled"] = not isNeonOff and true or false,
                            [data.current.value] = { neon.r, neon.g, neon.b }
                        })
                    else
                        lib.setVehicleProperties(vehicle, {
                            [data.current.value] = changedValue
                        })
                    end
                end
                OpenCosmeticsSubMenu(tunningZoneId, vehicle, modKey, mods, onAdminCloseCallback)
            end, onAdminCloseCallback ~= nil)
            return
        end

        local savedProperties = lib.getVehicleProperties(vehicle)
        OpenModMenu(tunningZoneId, vehicle, data.current.value, data.current.mod, function(changedValue)
            lib.setVehicleProperties(vehicle, savedProperties)
            if(type(changedValue) ~= "nil") then
                if(data.current.value == "tyreSmokeColor") then
                    local neon = CarNeons[changedValue]
                    local isNeonOff = neon.r == 0 and neon.g == 0 and neon.b == 0
                    lib.setVehicleProperties(vehicle, {
                        ["modSmokeEnabled"] = (not isNeonOff) and true or false,
                        [data.current.value] = { neon.r, neon.g, neon.b }
                    })
                end
                lib.setVehicleProperties(vehicle, {
                    [data.current.value] = changedValue
                })
            end
            OpenCosmeticsSubMenu(tunningZoneId, vehicle, modKey, mods, onAdminCloseCallback)
        end, onAdminCloseCallback ~= nil)
    end, function(data, menu)
        menu.close()
        OpenCosmeticsMenu(tunningZoneId, vehicle, onAdminCloseCallback)
    end)
end

function OpenModMenu(tunningZoneId, vehicle, modKey, mod, onCloseCallback, isAdmin)
    local elements = {}
    local currentVehicleProperties = lib.getVehicleProperties(vehicle)
    local vehiclePrice = GetVehiclePrice(vehicle)
    if(mod.modType == 11 or mod.modType == 12 or mod.modType == 13 or mod.modType == 15 or mod.modType == 16) then
        if(not currentVehicleProperties[modKey]) then
            currentVehicleProperties[modKey] = -1
        end
        for i=-1, GetNumVehicleMods(vehicle, mod.modType) - 1 do
            local level = i + 1
            if(level == 0) then
                mod.price[level] = 1
            end
            local modPrice = math.floor(vehiclePrice * mod.price[level] / 100)
            table.insert(elements, {label = "Level - "..(level == 0 and "Základní" or level).." - "..(
                i == currentVehicleProperties[modKey] and
                "Nainstalováno" or
                modPrice.."$"
            ), modValue = i})
        end
    end

    if(mod.modType == 17 or mod.modType == 38) then -- turbo / hydraulics
        local modPrice = math.floor(vehiclePrice * (type(mod.price) == "number" and mod.price or mod.price[1]) / 100) 
        table.insert(elements, { label = "Ne", modValue = false })
        table.insert(elements, { label = "Ano"..(
            currentVehicleProperties[modKey] and
            " - Nainstalováno" or
            " - "..modPrice.."$"
        ), modValue = true })
    end

    if(mod.modType == 22) then -- xenons
        local modPrice = math.floor(vehiclePrice * (type(mod.price) == "number" and mod.price or mod.price[1]) / 100) 
        local xenonOff = currentVehicleProperties.xenonColor == 255 and true or false  
        for i=1, #CarXenonColours do
            local xenon = CarXenonColours[i]
            table.insert(elements, { label = ("<span style='color: %s;'>"):format(
                xenon.value == 255 and "white" or xenon.label:lower()
            )..xenon.label.."</span>"..(
                currentVehicleProperties.xenonColor == xenon.color and
                " - Nainstalováno" or
                " - "..modPrice.."$"
            ), modValue = xenon.value,
        })
        end
    end

    if(mod.modType == "windowTint") then
        local modPrice = math.floor(vehiclePrice * (type(mod.price) == "number" and mod.price or mod.price[1]) / 100) 
        for i=1, #CarWindowTintNames do
            table.insert(elements, { label = CarWindowTintNames[i]..(
                i == currentVehicleProperties[modKey] and
                " - Nainstalováno" or
                " - "..modPrice.."$"
            ), modValue = i })
        end
    end

    if(mod.modType == "neonColor" or mod.modType == "tyreSmokeColor") then
        local modPrice = math.floor(vehiclePrice * (type(mod.price) == "number" and mod.price or mod.price[1]) / 100) 
        for i=1, #CarNeons do
            local neon = CarNeons[i]
            table.insert(elements, {
                label = ("<span style='color: rgb(%s, %s, %s);'>"):format(table.unpack(i > 1 and {neon.r, neon.g, neon.b} or {255, 255, 255})).. neon.label.."</span> "..modPrice.."$",
                modValue = i,
            })
        end
    end

    if(mod.modType == 14) then
        local modPrice = math.floor(vehiclePrice * (type(mod.price) == "number" and mod.price or mod.price[1]) / 100) 
        for i=-1, #CarHornNames do
            local hornName = CarHornNames[i]
            table.insert(elements, { label = hornName..(
                i == currentVehicleProperties[modKey] and
                " Nainstalováno" or
                " - "..modPrice.."$"
            ), modValue = i})
        end
    end

    if(mod.modType == 'color1' or mod.modType == 'color2' or mod.modType == 'pearlescentColor' or mod.modType == 'wheelColor') then
        local modPrice = math.floor(vehiclePrice * (type(mod.price) == "number" and mod.price or mod.price[1]) / 100) 
        for i=1, #mod.colours do
            local colour = mod.colours[i]
            table.insert(elements, { label = colour.label..(
                colour.index == currentVehicleProperties[modKey] and
                " - Nainstalováno" or
                " - "..modPrice.."$"
            ), modValue = colour.index})
        end
    end

    if(mod.modType == 23) then
        lib.setVehicleProperties(vehicle, {
            ["wheels"] = mod.wheelType?.index,
        })
        local modCount = GetNumVehicleMods(vehicle, mod.modType)
        local modPrice = math.floor(vehiclePrice * (type(mod.wheelType?.price) == "number" and mod.wheelType?.price or mod.wheelType?.price[1]) / 100) 

        for i=0, modCount do
            local modName = GetModTextLabel(vehicle, mod.modType, i)
            if modName then
                local modLabel = GetLabelText(modName)
                table.insert(elements, {label = modLabel.." - "..(
                    i == currentVehicleProperties[modKey] and
                    "Nainstalováno" or
                    modPrice.."$"
                ), modValue = i})
            end
        end
    end

    if(#elements == 0) then
        local modCount = GetNumVehicleMods(vehicle, mod.modType) -- BODYPARTS
        if(modCount == 0) then
            onCloseCallback()
            ESX.ShowNotification("Nejsou dostupné žádná vylepšení pro tuto sekci.", { type = "error" })
            return
        end

        local modPrice = math.floor(vehiclePrice * (type(mod.price) == "number" and mod.price or mod.price[1]) / 100) 
        for i=0, modCount do
            local modName = GetModTextLabel(vehicle, mod.modType, i)
            if modName then
                local modLabel = GetLabelText(modName)
                table.insert(elements, {label = modLabel.." - "..(
                    i == currentVehicleProperties[modKey] and
                    "Nainstalováno" or
                    modPrice.."$"
                ), modValue = i})
            end
        end
    end

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "tunning_menu_"..modKey, {
        title = mod?.label or _U(modKey),
        align = "center",
        elements = elements,
    }, function(data, menu)
        menu.close()
        if(mod.modType == "neonColor" or mod.modType == "tyreSmokeColor" or modKey == "modXenon" or modKey == "modFrontWheels") then
            if(not (modKey == "modXenon") and not (modKey == "modFrontWheels")) then
                if(not isAdmin) then
                    TriggerServerEvent("strin_tunning:installMod", mod.modType == "tyreSmokeColor" and "modSmokeEnabled" or "neonEnabled",
                    (mod.modType == "tyreSmokeColor" and true or {
                        true,
                        true,
                        true,
                        true
                    }))
                    Citizen.Wait(1000)
                    local neon = CarNeons[data.current.modValue]
                    TriggerServerEvent("strin_tunning:installMod", modKey, {
                        neon.r,
                        neon.g,
                        neon.b
                    })
                    Citizen.Wait(500)
                end
                OpenModMenu(tunningZoneId, vehicle, modKey, mod, function(modValue)
                    onCloseCallback(modValue or data.current.modValue)
                end)
            else
                if(modKey == "modFrontWheels") then
                    if(not isAdmin) then
                        TriggerServerEvent("strin_tunning:installMod", "wheels", mod.wheelType?.index)
                        Citizen.Wait(1000)
                        TriggerServerEvent("strin_tunning:installMod", modKey, data.current.modValue)
                        Citizen.Wait(500)
                    end
                    OpenModMenu(tunningZoneId, vehicle, modKey, mod, function(modValue)
                        onCloseCallback(modValue or data.current.modValue)
                    end)
                else
                    if(not isAdmin) then
                        TriggerServerEvent("strin_tunning:installMod", modKey, data.current.modValue ~= 255)
                        Citizen.Wait(1000)
                        TriggerServerEvent("strin_tunning:installMod", "xenonColor", data.current.modValue)
                        Citizen.Wait(500)
                    end
                    OpenModMenu(tunningZoneId, vehicle, modKey, mod, function(modValue)
                        onCloseCallback(modValue or data.current.modValue)
                    end)
                end
            end
            return
        end
        if(not isAdmin) then
            TriggerServerEvent("strin_tunning:installMod", modKey, data.current.modValue)
            Citizen.Wait(500)
        end
        OpenModMenu(tunningZoneId, vehicle, modKey, mod, function(modValue)
            onCloseCallback(modValue or data.current.modValue)
        end)
    end, function(data, menu)
        menu.close()
        onCloseCallback()
    end, function(data, menu)
        ApplyPreviewMod(modKey, data.current.modValue)
    end)
    ApplyPreviewMod(modKey, elements[1].modValue or currentVehicleProperties[modKey])
end

function OpenWheelTypesMenu(wheelTypes)
    local p = promise.new()
    local elements = {}
    for i=1, #wheelTypes do
        table.insert(elements, { label = wheelTypes[i].label, value = wheelTypes[i].index, price = wheelTypes[i].price})
    end
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "tunning_wheels_menu", {
        title = "Typy kol",
        align = "center",
        elements = elements,
    }, function(data, menu)
        menu.close()
        p:resolve({
            label = data.current.label,
            index = data.current.value,
            price = data.current.price,
        })
    end, function(data, menu)
        menu.close()
        p:resolve(nil)
    end)
    return Citizen.Await(p)
end

function OpenColoursMenu()
    local p = promise.new()
    local elements = {}
    for i=1, #CarColours do
        table.insert(elements, { label = _U(CarColours[i]:lower()), value = CarColours[i]})
    end
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "tunning_colours_menu", {
        title = "Barvy",
        align = "center",
        elements = elements,
    }, function(data, menu)
        menu.close()
        p:resolve(data.current.value)
    end, function(data, menu)
        menu.close()
        p:resolve(nil)
    end)
    return Citizen.Await(p)
end

function ApplyPreviewMod(modKey, modValue)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped)
    if(vehicle == 0) then
        return
    end

    if (modKey == "modSpeakers" or
        modKey == "modTrunk" or
        modKey == "modHydrolic" or
        modKey == "modEngineBlock" or
        modKey == "modAirFilter" or
        modKey == "modStruts" or
        modKey == "modTank") then
        SetVehicleDoorOpen(vehicle, 4, false)
        SetVehicleDoorOpen(vehicle, 5, false)
    elseif (modKey == "modDoorSpeaker") then
        SetVehicleDoorOpen(vehicle, 0, false)
        SetVehicleDoorOpen(vehicle, 1, false)
        SetVehicleDoorOpen(vehicle, 2, false)
        SetVehicleDoorOpen(vehicle, 3, false)
    else
        SetVehicleDoorsShut(vehicle, false)
    end

    if(modKey == "neonColor" or modKey == "tyreSmokeColor" or modKey == "modXenon") then
        if(not (modKey == "modXenon")) then
            local neon = CarNeons[modValue]
            local isNeonOff = neon.r == 0 and neon.g == 0 and neon.b == 0
            if(modKey == "neonColor") then
                lib.setVehicleProperties(vehicle, {
                    ["neonEnabled"] = {  table.unpack(isNeonOff and { false, false, false, false } or { true, true, true, true }) },
                    [modKey] = { neon.r, neon.g, neon.b }
                })
            else
                lib.setVehicleProperties(vehicle, {
                    ["modSmokeEnabled"] = (not isNeonOff) and true or false,
                    [modKey] = { neon.r, neon.g, neon.b }
                })
            end
        else
            lib.setVehicleProperties(vehicle, {
                [modKey] = modValue ~= 255 and true or false,
                ["xenonColor"] = modValue
            })
        end
        return
    end

    lib.setVehicleProperties(vehicle, {
        [modKey] = modValue
    })
end

function GetVehiclePrice(vehicle)
    local vehicleModelHash = GetEntityModel(vehicle)
    local vehicleModelName = GetDisplayNameFromVehicleModel(vehicleModelHash)
    local price = VehicleShop:GetVehiclePrice(vehicleModelName) or 50000
    return price
end

function GetIcon(iconIndex, exclude)
    if(not iconIndex) then
        local index = 1
        local indexes = {}
        for k,v in pairs(FAIcons) do
            indexes[index] = k
            index += 1
        end
        math.randomseed(GetGameTimer())
        local iconKey = indexes[math.random(1, #indexes)]
        if(not exclude or (exclude and not lib.table.contains(exclude, iconKey))) then
            return FAIcons[iconKey]
        end

        return GetIcon(nil, exclude)
    end

    return FAIcons[iconIndex]
end

AddEventHandler("onResourceStop", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        if(RequestedServer or IsInMenu) then
            TriggerServerEvent("strin_tunning:stopTunning")
        end
    end
end)