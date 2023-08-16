local docUsed = false
local heres = {}
local states = {}
local displaying = {}
local currenttxt = {}
local displayingProS = {}
local currenttxtProS = {}
local show3d = true
local fontId = RegisterFontId('Righteous')

RegisterNetEvent('strin_rpchat:syncHeres')
AddEventHandler('strin_rpchat:syncHeres', function(newHeres)
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end
    heres = newHeres
end)

RegisterNetEvent('strin_rpchat:syncStates')
AddEventHandler('strin_rpchat:syncStates', function(newStates)
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end
    states = newStates
end)

RegisterNetEvent('strin_rpchat:openHeresMenu', function(heres)
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end
    local elements = {}
    for i=1, 5 do
        if(heres[i]) then
            table.insert(elements, { label = "#"..i.." - "..heres[i].message, value = i})
        else
            table.insert(elements, { label = "#"..i.." - Dostupný /zde slot", value = i})
        end
    end
    local function OpenHeresMenu()
        ESX.UI.Menu.Open("default", GetCurrentResourceName(), "heres_menu", {
            title = "Seznam /zde",
            align = "center",
            elements = elements
        }, function(data, menu)
            menu.close()
            if(heres[data.current.value]) then
                ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "here_"..data.current.value, {
                    title = "Text (nechte prázdné pro vymazání)"
                }, function(data2, menu2)
                    menu2.close()
                    TriggerServerEvent("strin_rpchat:updateHere", data.current.value, data2.value or "")
                end, function(data2, menu2)
                    menu2.close()
                    OpenHeresMenu()
                end)
            else
                ESX.ShowNotification("Sloty jsou přiřazovány automaticky - použijte /zde.")
                OpenHeresMenu()
            end
        end, function(data, menu)
            menu.close()
        end)
    end
    OpenHeresMenu()
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        if(next(heres) ~= nil) then
            for _,here in pairs(heres) do
                for _,v in pairs(here) do
                    local distance = #(coords - v.coords)
                    if(distance < 10.0) then
                        drawHereText(v.coords, v.message)
                    end
                end
            end
        else
            Citizen.Wait(1000)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        if(next(states) ~= nil) then
            for serverId, msg in pairs(states) do
                local myId = PlayerId()
                local stateId = GetPlayerFromServerId(tonumber(serverId))
                if(stateId ~= -1) then
                    if(myId == stateId) then
                        drawHereText(coords, msg)
                    elseif(#(GetEntityCoords(GetPlayerPed(stateId)) - coords) < 3) then
                        local stateCoords = GetEntityCoords(GetPlayerPed(stateId))
                        drawHereText(stateCoords, msg)
                    end
                end
            end
        else
            Citizen.Wait(1000)
        end
    end
end)

function drawHereText(coords, text)
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


--[[RegisterNetEvent('char:reload')
AddEventHandler('char:reload', function()
    local dead = IsPedDeadOrDying(PlayerPedId())
    local health = GetEntityHealth(PlayerPedId())
    if dead then
        SetEntityHealth(PlayerPedId(), 0)
        ESX.ShowNotification('~r~Nemůžeš si dát reload, když jsi mrtvý')
    else
        ESX.TriggerServerCallback('esx_skin:getActivePlayerSkin', function(skin, jobSkin)
            SetPlayerModel(PlayerId(), GetEntityModel(PlayerPedId()))
            SetModelAsNoLongerNeeded(GetEntityModel(PlayerPedId()))

            TriggerEvent('skinchanger:loadSkin', skin)
            TriggerEvent('esx:restoreLoadout')
            local playerPed = GetPlayerPed(-1)
            ClearPedBloodDamage(playerPed)
            ResetPedVisibleDamage(playerPed)
            ClearPedLastWeaponDamage(playerPed)
            NetworkSetFriendlyFireOption(true)
            SetCanAttackFriendly(PlayerPedId(), true, true)     
            SetEntityHealth(PlayerPedId(), health)     
        end)
    end
end)]]

RegisterNetEvent('sendProximityMessage')
AddEventHandler('sendProximityMessage', function(id, name, message)
    local myId = PlayerId()
    local pid = GetPlayerFromServerId(id)
    if(pid ~= -1) then
        if pid == myId then
            TriggerEvent('chatMessage', name, {111, 111, 111}, " " .. message)        
        elseif #(GetEntityCoords(GetPlayerPed(myId)) - GetEntityCoords(GetPlayerPed(pid))) < 19.999 then
            TriggerEvent('chatMessage', name, {111, 111, 111}, " " .. message)
        end
    end
end)

RegisterNetEvent('sendProximityMessageMe')
AddEventHandler('sendProximityMessageMe', function(id, name, message)
    local myId = PlayerId()
    local pid = GetPlayerFromServerId(id)
    if(pid ~= -1) then
        if(message == "") then
            if(pid == myId) then
                TriggerEvent("chatMessage", "^1System", {255, 0, 0}, "Prázdná zpráva!")
            end
            return
        end  
        if pid == myId then
            displayingProS[myId.."player"] = false
            TriggerServerEvent('3dme:shareDisplayProS', message)
            TriggerEvent('chatMessage', "", {230, 180, 255}, "* " .. name .." " .. message)
        elseif #(GetEntityCoords(GetPlayerPed(myId)) - GetEntityCoords(GetPlayerPed(pid))) < 19.999 then
            displayingProS[pid.."player"] = false    
            TriggerEvent('chatMessage', "", {230, 180, 255}, "* " .. name .." " .. message)
        end
    end
end)

RegisterNetEvent('sendProximityMessageDo')
AddEventHandler('sendProximityMessageDo', function(id, name, message)
    local myId = PlayerId()
    local pid = GetPlayerFromServerId(id)
    if(pid ~= -1) then
        if(message == "") then
            if(pid == myId) then
                TriggerEvent("chatMessage", "^1System", {255, 0, 0}, "Prázdná zpráva!")
            end
            return
        end
        if pid == myId then
            displaying[myId.."player"] = false
            TriggerServerEvent('3dme:shareDisplay', message)
            TriggerEvent('chatMessage', "", {255, 255, 150}, "* " .. message .. " [" .. name .. "]")   
        elseif #(GetEntityCoords(GetPlayerPed(myId)) - GetEntityCoords(GetPlayerPed(pid))) < 13.999 then
            displaying[pid.."player"] = false
            TriggerEvent('chatMessage', "", {255, 255, 150}, "* " .. message .. " [" .. name .. "]")
        end
    end
end)
  
RegisterNetEvent('sendProximityMessageDoc')
AddEventHandler('sendProximityMessageDoc', function(id, name, message)
    local myId = PlayerId()
    local pid = GetPlayerFromServerId(id)
    if(pid ~= -1) then
        if(docUsed) then
            if pid == myId then
                ESX.ShowNotification('Počítadlo již běži!', "", "red")        
            end
            return
        end
        if (tonumber(message) == nil) then
            if pid == myId then
                ESX.ShowNotification('Musí to být číslo!', "", "red")   
            end
            return
        end
        if(tonumber(message) > 20) then
            if pid == myId then
                ESX.ShowNotification('Maximalni počet je 20.', "", "red")           
            end
            return
        end
        if(tonumber(message) < 1) then
            if pid == myId then
                ESX.ShowNotification('Minimalni počet je 1.', "", "red")       
            end
            return
        end
        if pid == myId then
            docUsed = true
        end
        Citizen.CreateThread(function()
            for i=1, tonumber(message) do
                if pid == myId then
	                displaying[myId.."player"] = false
                    TriggerServerEvent('3dme:shareDisplay', i .. "/" ..message)
                    TriggerEvent('chatMessage', "", {255, 255, 150}, "* " .. i .. "/" ..message.. " [" .. name .. "]")    
                elseif GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(myId)), GetEntityCoords(GetPlayerPed(pid)), true) < 13.999 then
		            displaying[pid.."player"] = false
                    TriggerEvent('chatMessage', "", {255, 255, 150}, "* " .. i .. "/" ..message.. " [" .. name .. "]")       	 
                end
                if(i == tonumber(message)) then
                    docUsed = false
                end
                Citizen.Wait(1000)
            end
        end)
    end
end)

local colorS = { r = 230, g = 180, b = 255, alpha = 255}
local color = { r = 255, g = 255, b = 150, alpha = 255}
local background = {
    enable = true,
    color = { r = 0, g = 0, b = 0, alpha = 100 },
}
local time = 8000
local timeProS = 9000
local backgroundProS = {
    enable = true,
    color = { r = 0, g = 0, b = 0, alpha = 100 },
}
local chatMessage = false
local dropShadow = true

local nbrDisplaying = 1

RegisterNetEvent('3dme:triggerDisplay')
AddEventHandler('3dme:triggerDisplay', function(text, source)
    local myId = PlayerId()
    local pid = GetPlayerFromServerId(source)
    if not show3d then
        return
    end
    if(pid == -1) then
        return
    end
    if (pid == myId) or (#(GetEntityCoords(GetPlayerPed(myId)) - GetEntityCoords(GetPlayerPed(pid))) < 19.999) then
        local offset = 1 + (nbrDisplaying*0.14)
        currenttxt[GetPlayerFromServerId(source).."player"] = text
        Display(GetPlayerFromServerId(source), text, offset)
    else
        return
    end
end)


RegisterNetEvent('3dme:triggerDisplayProS')
AddEventHandler('3dme:triggerDisplayProS', function(text, source)
    local myId = PlayerId()
    local pid = GetPlayerFromServerId(source)
    if(pid == -1) then
        return
    end
    if (pid == myId) or (#(GetEntityCoords(GetPlayerPed(myId)) - GetEntityCoords(GetPlayerPed(pid))) < 19.999) then
        local offset = 1 + (nbrDisplaying*0.14)
        currenttxtProS[GetPlayerFromServerId(source).."player"] = text
        DisplayProS(GetPlayerFromServerId(source), text, offset)
    else
        return
    end
end)


/*RegisterNetEvent('sendProximityMessage3D')
AddEventHandler('sendProximityMessage3D', function(id)
    local myId = PlayerId()
    if show3d then
        show3d = false
        TriggerEvent("chatMessage", "^1System", {255, 0, 0}, "Zobrazování 3D textů vypnuto.")
    else
        show3d = true
        TriggerEvent("chatMessage", "^1System", {255, 0, 0}, "Zobrazování 3D textů zapnuto.")
    end
end)*/

function Display(mePlayer, text, offset)
    displaying[mePlayer.."player"] = true
    Citizen.CreateThread(function()
        Wait(time)
        if(currenttxt[mePlayer.."player"] == text) then
          displaying[mePlayer.."player"] = false
        end
    end)
    Citizen.CreateThread(function()
        nbrDisplaying = nbrDisplaying + 1
        while displaying[mePlayer.."player"] do
            Wait(0)
            local coordsMe = GetEntityCoords(GetPlayerPed(mePlayer), false)
            local coords = GetEntityCoords(PlayerPedId(), false)
            local dist = #(coordsMe - coords)
            if dist < 200 then
                DrawText3D(coordsMe['x'], coordsMe['y'], coordsMe['z']+offset, text)
            end
        end
        nbrDisplaying = nbrDisplaying - 1
    end)
end

function DrawText3D(x,y,z, text)
    z = z - 1.2
    fontId = RegisterFontId('Righteous')

    local onScreen,_x,_y = World3dToScreen2d(x,y,z)
    local px,py,pz = table.unpack(GetGameplayCamCoord())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)

    --local scale = ((1/dist)*2)*(1/(GetGameplayCamFov()))*60
    --[[local scale = 0.68]] local scale = 0.54
    if onScreen then

        -- Formalize the text
        SetTextColour(color.r, color.g, color.b, color.alpha)
        SetTextScale(0.0*scale, 0.55*scale)
        SetTextFont(fontId) -- (font)
        SetTextProportional(1)
        SetTextCentre(true)
        if dropShadow then
            SetTextDropshadow(10, 100, 100, 100, 255)
        end

        -- Calculate width and height
        local height = GetTextScaleHeight(0.55*scale, font)
        local width = utf8.len(text)*0.0032

        -- Diplay the text
        SetTextEntry("STRING")
        AddTextComponentString(text)
        EndTextCommandDisplayText(_x, _y)

        if background.enable then
            DrawRect(_x, _y+scale/45, width + 0.070, height + 0.010, background.color.r, background.color.g, background.color.b , background.color.alpha)
        end
    end
end

function DisplayProS(mePlayer, text, offset)
    displayingProS[mePlayer.."player"] = true
    Citizen.CreateThread(function()
        Wait(timeProS)
        if(currenttxtProS[mePlayer.."player"] == text) then
          displayingProS[mePlayer.."player"] = false
        end
    end)
    Citizen.CreateThread(function()
        nbrDisplaying = nbrDisplaying + 1
        while displayingProS[mePlayer.."player"] do
            Wait(0)
            local coordsMe = GetEntityCoords(GetPlayerPed(mePlayer), false)
            local coords = GetEntityCoords(PlayerPedId(), false)
            local dist = #(coordsMe - coords)
            if dist < 200 then
                DrawText3DProS(coordsMe['x'], coordsMe['y'], coordsMe['z']+offset, text)
            end
        end
        nbrDisplaying = nbrDisplaying - 1
    end)
end

function DrawText3DProS(x,y,z, text)
    z = z - 0.2
    fontId = RegisterFontId('Righteous')
    local onScreen,_x,_y = World3dToScreen2d(x,y,z)
    local px,py,pz = table.unpack(GetGameplayCamCoord())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)

    --[[local scale = 0.68]] local scale = 0.54

    if onScreen then

        -- Formalize the text
        SetTextColour(colorS.r, colorS.g, colorS.b, colorS.alpha)
        SetTextScale(0.0*scale, 0.55*scale)
        SetTextFont(fontId) -- (font)
        SetTextProportional(1)
        SetTextCentre(true)
        if dropShadow then
            SetTextDropshadow(10, 100, 100, 100, 255)
        end

        -- Calculate width and height
        local height = GetTextScaleHeight(0.55*scale, fontId)
        local width = utf8.len(text)*0.0032

        -- Diplay the text
        SetTextEntry("STRING")
        AddTextComponentString(text)
        EndTextCommandDisplayText(_x, _y)

        if backgroundProS.enable then
            DrawRect(_x, _y+scale/45, width + 0.070, height + 0.010, backgroundProS.color.r, backgroundProS.color.g, backgroundProS.color.b , backgroundProS.color.alpha)
        end
    end
end