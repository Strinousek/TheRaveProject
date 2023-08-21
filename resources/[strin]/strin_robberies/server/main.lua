Inventory = exports.ox_inventory
Base = exports.strin_base
Jobs = exports.strin_jobs

Base:RegisterWebhook("DEFAULT", "https://discord.com/api/webhooks/691794167877206056/MBWE8lNNkOURuWxAXPHUA3yR4F1Ta5-taC6Y2DuUsggJRBKAMaRXnAzNjPHIGOelnwVa")

local LawEnforcementJobs = Jobs:GetLawEnforcementJobs()

local IsDebugModeOn = false
local DefaultConfigFile = LoadResourceFile(GetCurrentResourceName(), "config.lua")

AddEventHandler("strin_base:debugStateChange", function(state, onChange)
    IsDebugModeOn = state
    if(not state) then
        load(DefaultConfigFile)()
    else
        CashRegistersRequiredCops = 0
        CashRegistersRefreshTime = 5 * 60000
        CashRegistersRobberyTime = 120 * 1000

        JeweleryRefreshTime = 5 * 60000
        JeweleryRequiredCops = 0

        BanksRobTime = 2 * 60000
        BanksRequiredCops = 0
        BanksRefreshTime = 5 * 60000
    end
    onChange()
end)

function IsPlayerACop(job)
    if(lib.table.contains(LawEnforcementJobs, job) and not IsDebugModeOn) then
        return true
    end
    return false
end

function CheckBasicRobberyAvailability(requiredCops)
    local isAvailable, message = true, ""

    if(not IsDebugModeOn) then
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
            blipSprite = 814,
            blipColour = 84,
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