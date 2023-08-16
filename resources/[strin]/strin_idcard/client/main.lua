IsInMenu = false
CardDisplayed = false

local Target = exports.ox_target
local Inventory = exports.ox_inventory
local Base = exports.strin_base

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

Citizen.CreateThread(function()
    Target:addGlobalPlayer({
        GenerateTargetOption("Ukázat ID kartu", "identification_card"),
        GenerateTargetOption("Ukázat řidičský průkaz", "driving_license")
    })

    for k,v in pairs(CITY_HALLS) do
        v.blip = Base:CreateBlip({
            coords = v.coords,
            sprite = 525,
            colour = 28,
            scale = 0.8,
            label = "Úřad",
            id = "city_hall_"..k
        })
        Target:addSphereZone({
            coords = v.coords,
            radius = 5.0,
            options = {
                {
                    label = "Úřad",
                    distance = 2.0,
                    onSelect = function()
                        OpenCityHallMenu()
                    end
                }
            }
        })
    end

    while GetResourceState("ox_inventory") ~= "started" do
        Citizen.Wait(0)
    end
    Citizen.Wait(500)
    Inventory:displayMetadata("holder", "Držitel")
    Inventory:displayMetadata("issuedOn", "Datum vydání")
    Inventory:displayMetadata("classes", "Třídy")
end)

function OpenCityHallMenu()
    local elements = {}
    table.insert(elements, {
        label = ([[<div style="display: flex; justify-content: space-between; align-items: center;">
            Identifikační karta<div style="color: #2ecc71;">%s$</div>
        </div>]]):format(ESX.Math.GroupDigits(CARD_RENEWAL_PRICE)),
        value = "identification_card"
    })
    --local hasDrivingLicense = lib.callback.await("strin_licenses:hasLicense", false, "drive")
    --if(hasDrivingLicense) then
        table.insert(elements, {
            label = ([[<div style="display: flex; justify-content: space-between; align-items: center;">
                Řidičský průkaz<div style="color: #2ecc71;">%s$</div>
            </div>]]):format(ESX.Math.GroupDigits(CARD_RENEWAL_PRICE)),
            value = "driving_license"
        })
    --end
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "city_hall", {
        title = "Úřad",
        align = "center",
        elements = elements,
    }, function(data, menu)
        menu.close()
        TriggerServerEvent("strin_idcard:requestCard", data.current.value)
    end, function(data, menu)
        menu.close()
    end)
end

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

AddEventHandler("onResourceStop", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        for k,v in pairs(CITY_HALLS) do
            if(v.blip) then
                Base:DeleteBlip("city_hall_"..k)
            end
        end
    end
end)