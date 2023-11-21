local HasFocus = false
local Inventory = exports.ox_inventory

Citizen.CreateThread(function()
    while GetResourceState("ox_inventory") ~= "started" do
        Citizen.Wait(0)
    end
    Citizen.Wait(500)
    Inventory:displayMetadata("ticketNumbers", "Kombinace")
    Inventory:displayMetadata("winningNumbers", "Výherní kombinace")
    Inventory:displayMetadata("winnings", "Výhra $$$")
end)

AddEventHandler('esx:onPlayerDeath', function(data)
    if(HasFocus) then
        SetFocus(false)
        SendNUIMessage({
            action = "hideLottery"
        })
    end
end)

RegisterNetEvent("strin_lotteryticket:open", function(numbers, winningNumbers)
    SendNUIMessage({
        action = "showLottery",
        numbers = numbers,
        winningNumbers = winningNumbers,
    })
    SetFocus(true)
end)

RegisterNUICallback("confirm", function(data, cb)
    SendNUIMessage({
        action = "hideLottery"
    })
    SetFocus(false)
    cb("Ok")
end)

function SetFocus(state)
    HasFocus = state
    SetNuiFocus(state, state)
end