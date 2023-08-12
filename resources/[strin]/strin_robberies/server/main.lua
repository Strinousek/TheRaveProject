Inventory = exports.ox_inventory
Base = exports.strin_base
Jobs = exports.strin_jobs

Base:RegisterWebhook("DEFAULT", "https://discord.com/api/webhooks/691794167877206056/MBWE8lNNkOURuWxAXPHUA3yR4F1Ta5-taC6Y2DuUsggJRBKAMaRXnAzNjPHIGOelnwVa")

local LawEnforcementJobs = Jobs:GetLawEnforcementJobs()

function IsPlayerACop(job)
    if(lib.table.contains(LawEnforcementJobs, job)) then
        return true
    end
    return false
end

function CheckBasicRobberyAvailability(requiredCops)
    local isAvailable, message = true, ""

    -- Check robbery timer
    local timer, remainingTimeFormatted = Base:GetTimer()
    if(timer) then
        isAvailable = false
        message = ("Nelegální činnosti jsou pozdržené, zbývá %s!"):format(remainingTimeFormatted)
    end

    -- Check Cop Count
    local copCount = Base:CountCops()
    if(copCount < requiredCops) then
        isAvailable = false
        message = ("Ve městě není dostatek strážníků!")
    end

    return isAvailable, message
    --return true, nil
end

/*
    notifyType: "ROBBERY" | "CANCEL"
*/

function NotifyCops(notifyType, message, subtitle, coords)
    if(notifyType == "ROBBERY") then
        local recipientJobList = LawEnforcementJobs
        local data = {
            displayCode = '10-68',
            description = message,
            isImportant = 1,
            recipientList = recipientJobList, 
            length = '20000',
            infoM = 'fa-info-circle',
            info = subtitle
        }
        local dispatchData = { dispatchData = data, caller = 'Alarm', coords = coords}
        TriggerEvent('wf-alerts:svNotify', dispatchData)
    elseif(notifyType == "CANCEL") then
        local copJobs = LawEnforcementJobs
        for _,v in pairs(copJobs) do
            local xPlayers = ESX.GetExtendedPlayers("job", v)
            for _,xPlayer in pairs(xPlayers) do
                xPlayer.showNotification(message, { type = "error", length = 10000 })
            end
        end
    end
end