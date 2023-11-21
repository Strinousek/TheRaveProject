local DealerPoint = nil
local DealerBlip = nil
local IsInMenu = false

local StrinJobs = exports.strin_jobs
local Target = exports.ox_target
local Inventory = exports.ox_inventory
local Items = Inventory:Items()
local LawEnforcementJobs = StrinJobs:GetLawEnforcementJobs()

local PHONE_BOOTHS_MODELS = {
    `p_phonebox_01b_s`,
    `p_phonebox_02_s`,
    `prop_phonebox_01a`,
    `prop_phonebox_01b`,
    `prop_phonebox_01c`,
    `prop_phonebox_02`,
    `prop_phonebox_03`,
    `prop_phonebox_04`
}

AddTextEntry("STRIN_GUNDEALER:INTERACT", "<FONT FACE='Righteous'>~g~<b>[E]</b>~s~ Dealer zbraní</FONT>")

RegisterNetEvent("strin_gundealer:receiveData", function(data, playerId)
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end

    if((data.state == "INACTIVE" or data.state == "RESTOCKING")) then
        if(DealerPoint) then 
            DealerPoint:remove()
            DealerPoint = nil
        end
        if(DealerBlip) then
            RemoveBlip(DealerBlip)
            DealerBlip = nil
        end
        return
    end

    if(data.state == "ACTIVE") then
        if(not DealerPoint) then
            DealerPoint = lib.points.new({
                coords = data.location?.dealer?.coords,
                distance = 5.0
            })

            function DealerPoint:nearby()
                if(NetworkDoesNetworkIdExist(data.pedNetId)) then
                    local entity = NetworkGetEntityFromNetworkId(data.pedNetId)
                    if(GetEntityHealth(entity) < 5) then
                        local maxHealth = GetEntityMaxHealth(entity)
                        SetEntityHealth(entity, maxHealth)
                        if(IsPedDeadOrDying(entity)) then
                            ResurrectPed(entity)
                            SetEntityHealth(entity, maxHealth)
                            ClearPedBloodDamage(entity)
                            ClearPedTasksImmediately(entity)
                        end
                    end
                    if(not IsInMenu) then
                        DisplayHelpTextThisFrame("STRIN_GUNDEALER:INTERACT")
                        if(IsControlJustReleased(0, 38)) then
                            OpenGunDealerStocks()
                        end
                    end
                end
            end
        end
        if(not DealerBlip and (GetPlayerServerId(PlayerId()) == playerId)) then
            ESX.ShowNotification("B1GBO$$ označen na GPS.")
            DealerBlip = CreateDealerBlip(data.location?.dealer?.coords)
        end
    end
end)

Target:addModel(PHONE_BOOTHS_MODELS, {
    {
        label = "Zavolat na zvláštní linku",
        distance = 1.0,
        onSelect = function(data)
            local entity = data.entity
            OpenLandlineMenu(entity)
        end,
        canInteract = function()
            return ESX.PlayerData?.job?.name and not lib.table.contains(LawEnforcementJobs, ESX.PlayerData?.job?.name)
        end,
    }
})

lib.callback.register("strin_gundealer:isNearPhoneBooth", function()
    local nearbyBooth = nil
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    for i=1, #PHONE_BOOTHS_MODELS do
        local phoneBooth = GetClosestObjectOfType(coords, 5.0, PHONE_BOOTHS_MODELS[i])
        if(phoneBooth ~= 0) then
            nearbyBooth = phoneBooth
            break
        end
    end
    return nearbyBooth
end)

AddEventHandler("esx:onPlayerDeath", function()
    if(
        ESX.UI.Menu.IsOpen("default", GetCurrentResourceName(), "landline_menu") or 
        ESX.UI.Menu.IsOpen("default", GetCurrentResourceName(), "gundealer_stocks_menu")
    ) then
        ESX.UI.Menu.CloseAll()
    end
end)

function OpenLandlineMenu(entity)
    local elements = {}
    if(not DealerBlip) then
        table.insert(elements, {
            label = ([[<div style="display: flex; justify-content: space-between; align-items: center;">
                Dealer zbraní<div>%s$</div>
            </div>]]):format(ESX.Math.GroupDigits(DEALER_LOCATION_PRICE)),
            value = "gundealer"
        })
    end

    if(not next(elements)) then
        ESX.ShowNotification("Zvláštní linka je nedostupná!", { type = "error" })
        return
    end

    local ped = PlayerPedId()
    FreezeEntityPosition(ped, true)
    TaskStartScenarioInPlace(ped, "PROP_HUMAN_ATM", 0, false)
    TriggerServerEvent("interactsound:playWithinDistance", 2.0, "coin_machine")
    local function clearPed()
        FreezeEntityPosition(ped, false)
        ClearPedTasksImmediately(ped)
        TriggerServerEvent("interactsound:playWithinDistance", 2.0, "hang_up")
    end

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "landline_menu", {
        title = "Zvláštní linka",
        align = "center",
        elements = elements
    }, function(data, menu)
        menu.close()
        if(data.current.value == "gundealer") then
            TriggerServerEvent("strin_gundealer:requestLocation")
            clearPed()
        end
    end, function(data, menu)
        menu.close()
        clearPed()
    end)
end

function CreateDealerBlip(coords)
    local blip = AddBlipForCoord(coords)
    SetBlipDisplay(blip, 2)
    SetBlipSprite(blip, 567)
    SetBlipColour(blip, 17)
    SetBlipScale(blip, 1.0)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("<FONT FACE='Righteous'>~o~B1G BO$$~s~</FONT>")
    EndTextCommandSetBlipName(blip)
    return blip
end

AddEventHandler("onResourceStop", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        if(DealerPoint) then
            DealerPoint:remove()
        end
        if(DealerBlip and DoesBlipExist(DealerBlip)) then
            RemoveBlip(DealerBlip)
        end
    end
end)

function CountGunDealerStocks(stocks)
    local stockCount = 0
    for k,v in pairs(stocks) do
        if(v) then
            stockCount += v?.count
        end
    end
    return stockCount
end

function OpenGunDealerStocks()
    local stocks = lib.callback.await("strin_gundealer:requestStocks", 500)
    if(not stocks or not next(stocks) or (next(stocks) and CountGunDealerStocks(stocks) == 0)) then
        ESX.ShowNotification("Dealer nemá nic na prodej.")
        return
    end
    local elements = {}
    for k,v in pairs(stocks) do
        if(v) then
            table.insert(elements, {
                label = ([[
                    %s - %s$
                ]]):format(Items[v?.name].label, ESX.Math.GroupDigits(v?.price)),
                min = 0,
                value = 0,
                max = v?.count,
                stockName = v?.name,
                type = "slider",
            })
        end
    end
    if(#elements <= 0) then
        ESX.ShowNotification("Dealer nemá nic na prodej.")
        return
    end

    table.insert(elements, {
        label = "<span style='color: #2ecc71;'>Potvrdit nákup</span>",
        value = "confirm",
    })
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "gundealer_stocks_menu", {
        title = "B1G BO$$",
        align = "center",
        elements = elements
    }, function(data, menu)
        if(data.current.value == "confirm") then
            menu.close()
            local items = {}
            for k,v in pairs(data.elements) do
                v.value = tonumber(v.value)
                if(v.value and v.value > 0) then
                    table.insert(items, { name = v.stockName, amount = v.value})
                end
            end
            if(not next(items)) then
                OpenGunDealerStocks()
                return
            end 
            TriggerServerEvent("strin_gundealer:buyStocks", items)
            OpenGunDealerStocks()
        end
    end, function(data, menu)
        menu.close()
    end)
end