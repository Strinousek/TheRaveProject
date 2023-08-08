IsInMenu = false
CardDisplayed = false

local Target = exports.ox_target
local Inventory = exports.ox_inventory

function GenerateTargetOption(label, __type)
    return {
        label = label,
        onSelect = function(data)
            local playerId = NetworkGetPlayerIndexFromPed(data.entity)
            local netId = GetPlayerServerId(playerId)
            if(Inventory:GetItemCount(__type) > 1) then
                local cardId = OpenCardsMenu(__type)
                if(not cardId) then
                    return
                end
                TriggerServerEvent("strin_idcard:showCard", __type, cardId, netId)
                return
            end
            TriggerServerEvent("strin_idcard:showCard", __type, nil, netId)
        end,
        canInteract = function()
            return Inventory:GetItemCount(__type) > 0 and not IsInMenu
        end,
    }
end

Target:addGlobalPlayer({
    GenerateTargetOption("Ukázat ID kartu", "identification_card"),
    GenerateTargetOption("Ukázat řidičský průkaz", "driving_license")
})

/*
    -- Debug Stuff
    Target:addGlobalPed({
        GenerateTargetOption("Ukázat ID kartu", "identification_card"),
        GenerateTargetOption("Ukázat řidičský průkaz", "driving_license")
    })
*/

function OpenCardsMenu(__type)
    IsInMenu = true
    local p = promise.new()
    local elements = {}
    local cards = Inventory:GetSlotsWithItem(__type)
    for k,v in pairs(cards) do
        table.insert(elements, {
            label = ([[<div style="display: flex; justify-content: space-between; align-items: center;">
                #%s<div>%s</div><div>%s</div>%s
            </div>]]):format(
                tostring(k), 
                tostring(v.metadata?.holder),
                tostring(v.metadata?.issuedOn),
                (__type == "driving_license" and "<div>"..table.concat(v.metadata?.classes, ",").."</div>" or "")
            ),
            value = k
        })
    end
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "cards_menu_"..__type, {
        title = __type == "identification_card" and "Identifikační karty" or "Řidičské průkazy",
        align = "center",
        elements = elements,
    }, function(data, menu)
        menu.close()
        IsInMenu = false
        p:resolve(cards[data.current.value].metadata?.id)
    end, function(data, menu)
        menu.close()
        IsInMenu = false
        p:resolve(nil)
    end)
    return Citizen.Await(p)
end

RegisterNetEvent("strin_idcard:showCard", function(__type, data)
    if(CardDisplayed) then
        CardDisplayed = false
        SendNUIMessage({
            display = false,
        })
    end
    CardDisplayed = true
    SendNUIMessage({
        display = true,
        type = __type,
        info = data,
    })
    while CardDisplayed do
        if(IsControlJustReleased(0, 177)) then
            SendNUIMessage({
                display = false,
            })
            CardDisplayed = false
        end
        Citizen.Wait(0)
    end
end)

RegisterNUICallback("hideCard", function(data, cb)
    CardDisplayed = false
    cb("ok")
end)

AddEventHandler("onResourceStart", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        Citizen.Wait(1000)
        Inventory:displayMetadata({
            holder = "Držitel",
            issuedOn = "Datum vydání",
            classes = "Třídy"
        })
    end
end)