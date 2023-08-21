local Target = exports.ox_target
local ATMModels = {
    "prop_atm_01",
    "prop_atm_02",
    "prop_atm_03",
    "prop_fleeca_atm",
}
local BankBlips = {}

Citizen.CreateThread(function()
    local ATMHashes = {}
    for i=1, #ATMModels do
        ATMHashes[i] = GetHashKey(ATMModels[i])
    end

    Target:addModel(ATMHashes, {
        {
            label = "Bankomat",
            icon = "fa-solid fa-money-bill-transfer",
            onSelect = function()
                OpenBankingMenu(nil, "ATM")
            end
        }
    })

    for i=1, #BankLocations do
        BankBlips[i] = CreateBankBlip(BankLocations[i])
        Target:addSphereZone({
            coords = BankLocations[i],
            radius = 2.0,
            drawSprite = true,
            options = {
                {
                    label = "Banka",
                    icon = "fa-solid fa-building-columns",
                    onSelect = function()
                        OpenBankingMenu(i, "BANK")
                    end
                }
            }
        })
    end
end)

function OpenBankingMenu(bankId, bankType)
    local account = {
        money = 0
    }
    for k,v in pairs(ESX.PlayerData.accounts) do
        if(v.name == "bank") then
            account = v
            break
        end
    end
    local elements = {
        { 
            label = ([[<div style="display: flex; justify-content: space-between; align-items: center;">
                Bankovní zůstatek<div>%s$</div>
            </div>]]):format(account.money or "???"),
            value = "balance",
        },
        { 
            label = ("Vložit peníze"),
            value = "deposit",
        },
        { 
            label = ("Vybrat peníze"),
            value = "withdraw",
        },
    }
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), (bankType == "bank ") and "bank_"..bankId or "atm", {
        title = (bankType == "BANK") and "Bankovní účet" or "Bankomat",
        align = "center",
        elements = elements
    }, function(data, menu)
        menu.close()
        if(bankType == "ATM") then
            local ATMElements = {}
            for i=1, #MaxATMTransfers do
                table.insert(ATMElements, {
                    label = MaxATMTransfers[i].."$",
                    value = MaxATMTransfers[i]
                })
            end
            if(data.current.value == "deposit") then
                ESX.UI.Menu.Open("default", GetCurrentResourceName(), "atm_deposit", {
                    title = "Bankomat - vklad",
                    align = "center",
                    elements = ATMElements,
                }, function(data2, menu2)
                    menu2.close()
                    TriggerServerEvent("strin_banking:transferATM", "deposit", data2.current.value)
                end, function(data2, menu2)
                    menu2.close()
                end)
            end
            if(data.current.value == "withdraw") then
                ESX.UI.Menu.Open("default", GetCurrentResourceName(), "atm_withdraw", {
                    title = "Bankomat - výběr",
                    align = "center",
                    elements = ATMElements,
                }, function(data2, menu2)
                    menu2.close()
                    TriggerServerEvent("strin_banking:transferATM", "withdraw", data2.current.value)
                end, function(data2, menu2)
                    menu2.close() 
                end)
            end
            return
        end
        if(bankType == "BANK") then
            if(data.current.value == "deposit") then
                ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "atm_deposit", {
                    title = "Částka vkladu"
                }, function(data2, menu2)
                    menu2.close()
                    TriggerServerEvent("strin_banking:transferBank", "deposit", data2.value or "")
                end, function(data2, menu2)
                    menu2.close()
                end)
            end
            if(data.current.value == "withdraw") then
                ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "atm_deposit", {
                    title = "Částka výběru"
                }, function(data2, menu2)
                    menu2.close()
                    TriggerServerEvent("strin_banking:transferBank", "withdraw", data2.value or "")
                end, function(data2, menu2)
                    menu2.close()
                end)
            end
        end
    end, function(data, menu)
        menu.close()
    end)
end

function CreateBankBlip(bankCoords)
    local blip = AddBlipForCoord(bankCoords.x, bankCoords.y, bankCoords.z)
    SetBlipSprite(blip, 207)
    SetBlipColour(blip, 52)
    SetBlipScale(blip, 1.0)
    SetBlipBright(blip, true)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('<FONT FACE="Righteous">Banka')
    EndTextCommandSetBlipName(blip)
    return blip
end

AddEventHandler("onResourceStop", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        for i=1, #BankBlips do
            local blip = BankBlips[i]
            if(DoesBlipExist(blip)) then
                RemoveBlip(blip)
            end
        end
    end
end)