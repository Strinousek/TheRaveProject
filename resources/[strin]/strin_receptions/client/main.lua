local ReceptionsNPCs = {}
local Target = exports.ox_target

Citizen.CreateThread(function()
    for k,v in pairs(RECEPTIONS) do
        local receptionPoint = lib.points.new({
            coords = v.coords,
            distance = 20,
        })
        function receptionPoint:onEnter()
            if(not ReceptionsNPCs[k] or not DoesEntityExist(ReceptionsNPCs[k])) then
                ReceptionsNPCs[k] = CreateReceptionistNPC(v)
                local options = lib.table.deepclone(v.options)
                for _,option in pairs(options) do
                    option.distance = v.distance or 2.5
                    option.canInteract = function()
                        return DoesEntityExist(ReceptionsNPCs[k])
                    end
                end
                Target:addLocalEntity(ReceptionsNPCs[k], options)
            end
        end
        function receptionPoint:onExit()
            if(ReceptionsNPCs[k] or DoesEntityExist(ReceptionsNPCs[k])) then
                DeleteEntity(ReceptionsNPCs[k])
                ReceptionsNPCs[k] = nil
            end
        end
    end
end)

function CreateReceptionistNPC(reception)
    RequestModel(reception.model)
    while not HasModelLoaded(reception.model) do
        Citizen.Wait(100)
    end
    local _, groundZ = GetGroundZFor_3dCoord(reception.coords.x, reception.coords.y, reception.coords.z, 0)
    local ped = CreatePed(3, reception.model, reception.coords.x, reception.coords.y, groundZ, reception.heading, false, true)
    SetPedDefaultComponentVariation(ped)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedDiesWhenInjured(ped, false)
    SetEntityInvincible(ped, true)
    SetPedCanPlayAmbientAnims(ped, true)
    FreezeEntityPosition(ped, true)
    return ped
end

/*
    POLICE MODULE
*/

AddEventHandler("strin_receptions:copyLSPDDiscord", function()
    local discord = "https://dsc.gg/lspdonline"
    lib.setClipboard(discord)
    ESX.ShowNotification("LSPD Discord zkopírován. CTRL + V pro použití.")
end)

RegisterNetEvent("strin_receptions:openPermitsMenu", function()
    local hasCCWPermit = lib.callback.await("strin_licenses:hasLicense", false, "ccw")
    local elements = {}
    if(not hasCCWPermit) then
        table.insert(elements, { label = [[<div style="display: flex; justify-content: space-between; align-items: center;">
            CCW Permit - Zkoušky<div style="color: #2ecc71;">]]..ESX.Math.GroupDigits(10000)..[[$</div>
        </div>]], value = "test"})
    else
        table.insert(elements, { label = [[<div style="display: flex; justify-content: space-between; align-items: center;">
            CCW Permit - Karta<div style="color: #2ecc71;">]]..ESX.Math.GroupDigits(5000)..[[$</div>
        </div>]], value = "ccw_card"})
    end
    local hasFSCPermit = lib.callback.await("strin_licenses:hasLicense", false, "fsc")
    if(hasFSCPermit) then
        table.insert(elements, { label = [[<div style="display: flex; justify-content: space-between; align-items: center;">
            FSC - Karta<div style="color: #2ecc71;">]]..ESX.Math.GroupDigits(5000)..[[$</div>
        </div>]], value = "fsc_card"})
    end
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "permits_menu", {
        title = "CCW Permit",
        align = "center",
        elements = elements,
    }, function(data, menu)
        menu.close()
        if(data.current.value == "test") then
            RequestCCWPermitTestMenu()
        elseif(data.current.value == "ccw_card") then
            TriggerServerEvent("strin_receptions:requestCCWCard")
        elseif(data.current.value == "fsc_card") then
            TriggerServerEvent("strin_receptions:requestFSCCard")
        end
    end, function(data, menu)
        menu.close()
    end)
end)

RegisterNetEvent("strin_receptions:reportCrime", function()
    ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "report_crime_dialog", {
        title = "Zločin"
    }, function(data, menu)
        menu.close()
        if(not data.value or data.value:len() == 0) then
            return
        end
        ExecuteCommand("911 "..data.value)
    end, function(data, menu)
        menu.close()
    end)
end)

RegisterNetEvent("strin_receptions:fileComplain", function()
    local complainLink = "https://forms.gle/BGFkBpz7mxc5Ur1XA"
    local elements = {}
    table.insert(elements, { label = "Zavolat supervisora", value = "call_supervisor"})
    table.insert(elements, { label = "Odkaz na formulář", value = "complain_link"})
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "complain_menu", {
        title = "Stížnost",
        align = "center",
        elements = elements,
    }, function(data, menu)
        menu.close()
        if(data.current.value == "call_supervisor") then
            TriggerServerEvent("strin_receptions:callSupervisor")
        elseif(data.current.value == "complain_link") then
            ESX.ShowNotification("Formulář na podání stížnosti zkopírován. CTRL + V pro použití.")
            lib.setClipboard(complainLink)
        end
    end, function(data, menu)
        menu.close()
    end)
end)

function RequestCCWPermitTestMenu()
    local response, message = lib.callback.await("strin_receptions:requestCCWTest", false)
    if(not response) then
        ESX.ShowNotification(message, { type = "error" })
        return
    end
    local answeredQuestions = {}
    for k,v in pairs(response) do
        local elements = {}
        local answer
        for i=1, #v.answers do
            table.insert(elements, { label = tostring(v.answers[i]?[1]), value = i })
        end
        ESX.UI.Menu.Open("default", GetCurrentResourceName(), "ccw_permit_question_"..k, {
            title = v.title,
            align = "center",
            elements = elements
        }, function(data, menu)
            menu.close()
            answer = data.current.value
        end)
        while not answer do
            Citizen.Wait(0)
        end
        answeredQuestions[k] = answer
    end
    TriggerServerEvent("strin_receptions:validateCCWTest", answeredQuestions)
end