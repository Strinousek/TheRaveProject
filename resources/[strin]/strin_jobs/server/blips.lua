local JobBlips = {}

AddEventHandler("esx:playerLoaded", function(playerId, xPlayer)
    local job = xPlayer.getJob()
    if(not Jobs[job.name] or not Jobs[job.name].Blips) then
        return
    end

    local ped = GetPlayerPed(playerId)
    local coords = GetEntityCoords(ped)
    JobBlips[playerId] = {
        playerId = playerId,
        job = job.name,
        fullname = xPlayer.get("fullname"),
        coords = coords,
    }
    
    RefreshBlips(job.name)
end)

AddEventHandler("esx:setJob", function(playerId, job, lastJob)

    local blipId = GetPlayerBlipIndex(playerId)
    if(blipId) then
        local job = JobBlips[blipId].job
        JobBlips[blipId] = false
        TriggerClientEvent("strin_jobs:updateBlips", playerId, {})
        RefreshBlips(job)
    end

    if(not Jobs[job.name] or not Jobs[job.name].Blips) then
        return
    end

    local xPlayer = ESX.GetPlayerFromId(playerId)

    local ped = GetPlayerPed(playerId)
    local coords = GetEntityCoords(ped)
    JobBlips[playerId] = {
        playerId = playerId,
        job = job.name,
        fullname = xPlayer.get("fullname"),
        coords = coords,
    }

    RefreshBlips(job.name)
end)

AddEventHandler("playerDropped", function()
    local _source = source
    local blipId = GetPlayerBlipIndex(_source)
    if(blipId) then
        local job = JobBlips[blipId].job
        JobBlips[blipId] = false
        RefreshBlips(job)
    end
end)

Citizen.CreateThread(function()
    while true do
        local startTime = GetGameTimer()

        /*
            tohle je mega hnusný
            update může přijít několikrát pro jednoho člověka
            protože je v canSee a zároveň má svoje blipy
        */

        local jobs = {}
        for i=1, #JobBlips do
            local v = JobBlips[i]
            if(v) then
                local ped = GetPlayerPed(v.playerId)
                if(ped ~= 0) then
                    v.coords = GetEntityCoords(ped)
                end
                if(v.job and not lib.table.contains(jobs, v.job)) then
                    table.insert(jobs, v.job) 
                end
            end
        end
        
        for i=1, #jobs do
            RefreshBlips(jobs[i])
        end
        local endTime = GetGameTimer()
        Citizen.Wait(5000 - (endTime - startTime))
    end
end)

function RefreshBlips(job)
    local authorizedJobs = {}
    for k, v in pairs(Jobs) do
        if(v.Blips and (k == job or lib.table.contains(v.Blips?.canSee or {}, job))) then
            table.insert(authorizedJobs, k)
        end
    end
    
    local blips = {}
    for i=1, #authorizedJobs do
        local authorizedJob = authorizedJobs[i]
        for i=1, #JobBlips do
            local jobBlip = JobBlips[i]
            if(jobBlip?.job == authorizedJob or not jobBlip) then
                blips[i] = jobBlip
            elseif(jobBlip?.job ~= authorizedJob) then
                blips[i] = false
            end
        end
    end

    for i=1, #blips do
        local blip = blips[i]
        if(blip) then
            TriggerClientEvent("strin_jobs:updateBlips", blip.playerId, blips)
        end
    end
end

function GetPlayerBlipIndex(playerId)
    if(not JobBlips[playerId]) then
        return nil
    else
        return playerId
    end
end

AddEventHandler("onResourceStart", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        local xPlayers = ESX.GetExtendedPlayers()
        for _,xPlayer in pairs(xPlayers) do
            local job = xPlayer.getJob()
            if(Jobs[job.name].Blips and next(Jobs[job.name].Blips)) then
                local ped = GetPlayerPed(xPlayer.source)
                local coords = GetEntityCoords(ped)
                JobBlips[xPlayer.source] = {
                    playerId = xPlayer.source,
                    job = job.name,
                    fullname = xPlayer.get("fullname"),
                    coords = coords,
                }
            end
        end
    end
end)