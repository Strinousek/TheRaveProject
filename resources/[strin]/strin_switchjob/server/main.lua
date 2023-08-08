local Society = exports.strin_society
local Locales = {
    ["off_duty"] = "Šel jste mimo službu.",
    ["on_duty"] = "Šel jste do služby.",
    ["no_duty"] = "Tento job nemá zavedený služební systém.",
}

local Base = exports.strin_base
Base:RegisterWebhook("DEFAULT", "https://discord.com/api/webhooks/885288545089101885/yqdPQy1KEqTWo-FocwItLm591kQKC1qq_XRX7B6NIEjBS6vbijCCYNkZAO5kiDb6r6AA")
Base:RegisterWebhook("DUTY", "https://discord.com/api/webhooks/679796152668913664/Ns9ZQILc5lLqfw25yhFwOUoxLi-gzWv_z6WPwOXx1ZFNzmM-pGZSF14hBZWxgn6J5qri")

function GetOtherJobs(identifier, jsonify)
    local result = MySQL.scalar.await("SELECT other_jobs FROM users WHERE `identifier` = ?", {
        identifier
    })
    return jsonify and (result or "{}") or json.decode(result or "{}")
end

lib.callback.register("strin_switchjob:getOtherJobs", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if(not xPlayer) then
        return nil
    end
    return GetOtherJobs(xPlayer.identifier)
end)

ESX.RegisterCommand("switchjob", "user", function(xPlayer)
    local otherJobs = GetOtherJobs(xPlayer.identifier)
    local jobs = Society:GetSocieties()
    local labeledOtherJobs = {}
    if(next(otherJobs)) then
        for job,grade in pairs(otherJobs) do
            labeledOtherJobs[job] = {
                name = job,
                grade = grade,
                grade_label = jobs[job].grades[grade].label,
                label = jobs[job].label
            }
        end
    end
    TriggerClientEvent("strin_switchjob:openMenu", xPlayer.source, labeledOtherJobs)
end)

RegisterNetEvent("strin_switchjob:duty")
AddEventHandler("strin_switchjob:duty", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local currentJob = xPlayer.getJob().name
    local currentGrade = xPlayer.getJob().grade
    local mode = "off_duty"
    local offDutyJob = ""
    if(currentJob:find("off_")) then
        mode = "on_duty"
        offDutyJob = currentJob:gsub("off_", "")
    else
        offDutyJob = "off_"..currentJob
    end
    if(ESX.DoesJobExist(offDutyJob, currentGrade)) then
        xPlayer.setJob(offDutyJob, currentGrade)
        xPlayer.showNotification(Locales[mode], {type = "error"})
        Base:DiscordLog("DUTY", "THE RAVE PROJECT - DUTY SYSTÉM", {
            { name = "Jméno hráče", value = ESX.SanitizeString(GetPlayerName(_source)) },
            { name = "Identifikace hráče", value = xPlayer.identifier },
            { name = "Přechod", value = mode },
            { name = "Předešlý job", value = currentJob.." | "..currentGrade },
            { name = "Aktuální job", value = offDutyJob.." | "..currentGrade },
        }, {
            fields = true
        })
    else
        xPlayer.showNotification(Locales["no_duty"], {type = "error"})
    end
end)

RegisterNetEvent("strin_switchjob:switchJob")
AddEventHandler("strin_switchjob:switchJob", function(job)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local previousJob = xPlayer.getJob()
    local jobs = GetOtherJobs(xPlayer.identifier)
    if(jobs[job] ~= nil) then
        SwitchJob(xPlayer.identifier, job, jobs[job], function()
            xPlayer.showNotification("Nastavil jste si job na - "..job)
            Base:DiscordLog("DEFAULT", "THE RAVE PROJECT - SWITCHJOB", {
                { name = "Jméno hráče", value = ESX.SanitizeString(GetPlayerName(_source)) },
                { name = "Identifikace hráče", value = xPlayer.identifier },

                { name = "Ostatní joby hráče", value = json.encode(jobs) },

                { name = "Předešlý job", value = previousJob.name },
                { name = "Předešlý job grade", value = previousJob.grade },
                
                { name = "Aktuální job", value = job },
                { name = "Aktuální job grade", value = jobs[job] },
            }, {
                fields = true,
            })
        end)
    end
end)

ESX.RegisterCommand("addsjob", "admin", function(xPlayer, args)
    if(not args.targetId or not args.job or not args.grade) then return end
    local _source = tonumber(xPlayer?.source)
    if(not _source) then
        xPlayer = {
            showNotification = function(message) print(message) end
        }
    end
    local xTarget = ESX.GetPlayerFromId(args.targetId)
    if(not ESX.DoesJobExist(args.job, args.grade)) then
        xPlayer.showNotification("Tento job neexistuje!", { type = "error" })
        return
    end
    if(not xTarget) then
        xPlayer.showNotification("Hráč není online!", { type = "error" })
        return
    end
    AddSwitchJob(xTarget.identifier, args.job, args.grade, function()
        xPlayer.showNotification(("Přidal jste hráči switch job - %s / %s"):format(args.job, args.grade))
        Base:DiscordLog("STALKING", "THE RAVE PROJECT - SWITCHJOB - ADD", {
            { name = "Jméno admina", value = ESX.SanitizeString(_source and GetPlayerName(xPlayer.source) or "Konzole") },
            { name = "Identifikace admina", value = _source and xPlayer.identifier or "{}" },
            { name = "Jméno hráče", value = ESX.SanitizeString(GetPlayerName(xTarget.source)) },
            { name = "Identifikace hráče", value = xTarget.identifier },
            { name = "Job Name", value = args.job },
            { name = "Job Grade", value = args.grade },
        }, {
            fields = true,
            resource = "strin_admin"
        })
    end)
end, true, {
    help = "Přidat switch job hráči",
    arguments = {
        { name = "targetId", type = "number", help = "ID hráče" },
        { name = "job", type = "string", help = "Kód společnosti" },
        { name = "grade", type = "number", help = "Hodnost" },
    }
})

ESX.RegisterCommand("remsjob", "admin", function(xPlayer, args)
    if(not args.targetId or not args.job) then return end
    local _source = tonumber(xPlayer?.source)
    if(not _source) then
        xPlayer = {
            showNotification = function(message) print(message) end
        }
    end

    local xTarget = ESX.GetPlayerFromId(args.targetId)
    if(not ESX.DoesJobExist(args.job, args.grade)) then
        xPlayer.showNotification("Tento job neexistuje!", { type = "error" })
        return
    end
    if(not xTarget) then
        xPlayer.showNotification("Hráč není online!", { type = "error" })
        return
    end

    RemoveSwitchJob(xTarget.identifier, args.job, function()
        xPlayer.showNotification(("Vymazal jste hráči switch job - %s"):format(job))
        Base:DiscordLog("STALKING", "THE RAVE PROJECT - SWITCHJOB - REMOVE", {
            { name = "Jméno admina", value = ESX.SanitizeString(_source and GetPlayerName(xPlayer.source) or "Konzole") },
            { name = "Identifikace admina", value = _source and xPlayer.identifier or "{}" },
            { name = "Jméno hráče", value = ESX.SanitizeString(GetPlayerName(xTarget.source)) },
            { name = "Identifikace hráče", value = xTarget.identifier },
            { name = "Job Name", value = args.job },
        }, {
            fields = true,
            resource = "strin_admin"
        })
    end)
end, true, {
    help = "Odstranit switch job hráči",
    arguments = {
        { name = "targetId", type = "number", help = "ID hráče" },
        { name = "job", type = "string", help = "Kód společnosti" },
    }
})

function SwitchJob(identifier, job, grade, cb)
    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
    local lastJob = xPlayer.getJob().name
    local lastGrade = xPlayer.getJob().grade
    local otherJobs = GetOtherJobs(identifier)
    local cleanOtherJobs = {}
    for k,v in pairs(otherJobs) do
        if(k ~= job) then
            cleanOtherJobs[k] = v
        end
    end
    if(lastJob ~= "unemployed") then
        cleanOtherJobs[lastJob] = lastGrade
    end
    xPlayer.setJob(job, grade)
    MySQL.update("UPDATE `users` SET `other_jobs` = ?, `job` = ?, `job_grade` = ? WHERE `identifier` = ?", {
        json.encode(cleanOtherJobs),
        job,
        grade,
        identifier
    }, function()
        cb()
    end)
end

function AddSwitchJob(identifier, job, grade, cb)
    if(not ESX.DoesJobExist(job, grade)) then
        return
    end
    local otherJobs = GetOtherJobs(identifier)
    otherJobs[job] = grade
    MySQL.update("UPDATE `users` SET `other_jobs` = ? WHERE `identifier` = ?", {
        json.encode(otherJobs),
        identifier
    }, function()
        cb()
    end)
end

function RemoveSwitchJob(identifier, job, cb)
    local otherJobs = GetOtherJobs(identifier)
    local newOtherJobs = {}
    for k,v in pairs(otherJobs) do
        if(k ~= job) then
            newOtherJobs[k] = v
        end
    end
    MySQL.update("UPDATE `users` SET `other_jobs` = ? WHERE `identifier` = ?", {
        json.encode(newOtherJobs),
        identifier
    }, function()
        cb()
    end)
end