local Jobs = exports.strin_jobs
local CurrentTimer = {
    setOn = nil,
    duration = nil,
}

local TimerCheckIntervalId = SetInterval(function()
    if(CurrentTimer.setOn) then
        local time = (CurrentTimer.duration * 60000) - ((os.time() - CurrentTimer.setOn) * 1000)
        local timeInSeconds = math.floor(time / 1000)
        if(timeInSeconds <= 0) then
            ResetTimer()
        end
    end
end, 1000)

/*lib.callback.register('strin_base:enoughCops', function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local cops = CountCopPlayers()
    if xPlayer and (tonumber(cops) >= tonumber(minimum_cops)) then
        cb(true)
    else
        if sendNotify == nil then
            TriggerClientEvent('esx:showNotification', source, "~r~Nedostatek policistů!")
        end
        cb(false)
    end
end)*/

AddEventHandler("strin_base:startTimer", StartTimer)

function StartTimer(cooldownTime)
    CurrentTimer.setOn = os.time()
    CurrentTimer.duration = cooldownTime
end

exports("StartTimer", StartTimer)

AddEventHandler("strin_base:resetTimer", ResetTimer)

function ResetTimer()
    CurrentTimer.setOn = nil
    CurrentTimer.duration = nil
end

exports("ResetTimer", ResetTimer)

lib.callback.register("strin_base:getTimer", function(source)
    return GetTimer()
end)

function GetTimer()
    if(CurrentTimer.setOn) then
        local time = (CurrentTimer.duration * 60000) - ((os.time() - CurrentTimer.setOn) * 1000)
        local timeInSeconds = math.floor(time / 1000)
        return CurrentTimer, os.date("%M:%S", timeInSeconds)
    else
        return nil, nil
    end
end

exports("GetTimer", GetTimer)

function AreRobberiesAvailable()
    return CurrentTimer.duration ~= nil
end

exports("AreRobberiesAvailable", AreRobberiesAvailable)

function CountCops()
    local copJobs = Jobs:GetLawEnforcementJobs()
    local copCount = 0
    for _,v in pairs(copJobs) do
        local activeJobPlayers = ESX.GetExtendedPlayers("job", v)
        copCount += #activeJobPlayers
    end
    return copCount
end

exports("CountCops", CountCops)

ESX.RegisterCommand("resettimer", "admin", function()
    ResetTimer()
end)

AddEventHandler("onResourceStop", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        ClearInterval(TimerCheckIntervalId)
    end
end)