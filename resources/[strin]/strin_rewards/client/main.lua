local IsFocused = false
local COMMANDS = { "daily", "rewards", "dailyrewards", "odmeny", "denniodmeny" }

function OpenRewards()
    local data = lib.callback.await("strin_rewards:getData", false)
    if(not data) then
        ESX.ShowNotification("Při načítání dat nastala chyba, zkuste to znovu později!", { type = "error" })
        return
    end
    SendNUIMessage({
        action = "showBoard",
        playedTime = data.playedTime,
        rewards = data.rewards
    })
    SetFocus(true)
end

do
    for i=1, #COMMANDS do
        local commandName = COMMANDS[i]
        RegisterCommand(commandName, OpenRewards)
    end
end

RegisterNUICallback("claimReward", function(data, cb)
    local rewards = lib.callback.await("strin_rewards:claimReward", false, tonumber(data.day))
    if(not rewards) then
        cb({})
        return
    end
    SendNUIMessage({
        action = "updateBoardRewards",
        rewards = rewards
    })
    cb({})
end)

RegisterNUICallback("hideBoard", function(data, cb)
    SetFocus(false)
    SendNUIMessage({
        action = "hideBoard",
    })
    cb({})
end)

function SetFocus(state)
    IsFocused = state
    SetNuiFocus(IsFocused, IsFocused)
end
