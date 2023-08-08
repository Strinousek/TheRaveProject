local JobBlips = {}

/*
    [1] = {
        playerId = 1,
        fullname = "Abraham Nigger",
        job = "police",
        coords = vector3(0, 0, 0)
    }
*/

AddEventHandler("esx:playerLoaded", function(playerId, xPlayer)
    local job = xPlayer.getJob()
    if(not Jobs[job.name] or not Jobs[job.name].Blips) then
        return
    end

    local ped = GetPlayerPed(playerId)
    local coords = GetEntityCoords(ped)
    table.insert(JobBlips, {
        playerId = playerId,
        job = job.name,
        fullname = xPlayer.get("fullname"),
        coords = coords,
    })
    
    RefreshBlips(job.name)
end)

AddEventHandler("esx:setJob", function(playerId, job, lastJob)

    local blipId = GetPlayerBlipIndex(playerId)
    if(blipId) then
        local job = JobBlips[blipId].job
        JobBlips[blipId] = nil
        TriggerClientEvent("strin_jobs:updateBlips", playerId, {})
        RefreshBlips(job)
    end

    if(not Jobs[job.name] or not Jobs[job.name].Blips) then
        return
    end

    local xPlayer = ESX.GetPlayerFromId(playerId)

    local ped = GetPlayerPed(playerId)
    local coords = GetEntityCoords(ped)
    table.insert(JobBlips, {
        playerId = playerId,
        job = job.name,
        fullname = xPlayer.get("fullname"),
        coords = coords,
    })

    RefreshBlips(job.name)
end)

AddEventHandler("playerDropped", function()
    local _source = source
    local blipId = GetPlayerBlipIndex(_source)
    if(blipId) then
        local job = JobBlips[blipId].job
        JobBlips[blipId] = nil
        RefreshBlips(job)
    end
end)

Citizen.CreateThread(function()
    while true do
        local startTime = GetGameTimer()
        for _,v in pairs(JobBlips) do
            if(v) then
                local ped = GetPlayerPed(v.playerId)
                if(ped ~= 0) then
                    v.coords = GetEntityCoords(ped)
                end
            end
        end
        /*
            tohle je mega hnusný
            update může přijít několikrát pro jednoho člověka
            protože je v canSee a zároveň má svoje blipy
        */
        local jobs = {}
        for _,v in pairs(JobBlips) do
            if(v?.job and not lib.table.contains(jobs, v?.job)) then
                table.insert(jobs, v?.job) 
            end
        end
        for _, job in pairs(jobs) do
            RefreshBlips(job)
        end
        local endTime = GetGameTimer()
        Citizen.Wait(5000 - (endTime - startTime))
    end
end)

function RefreshBlips(job)
    local authorizedJobs = {}
    for k, v in pairs(Jobs) do
        if(v.Blips and (k == job or lib.table.contains(v.Blips.canSee or {}, job))) then
            table.insert(authorizedJobs, k)
        end
    end
    
    local blips = {}
    for _,authorizedJob in pairs(authorizedJobs) do
        for blipId, blip in pairs(JobBlips) do
            if(blip.job == authorizedJob) then
                blips[blipId] = blip
            end
        end
    end
    
    for _,v in pairs(blips) do
        TriggerClientEvent("strin_jobs:updateBlips", v.playerId, blips)
    end
end

function GetPlayerBlipIndex(playerId)
    local index = nil
    for k,v in pairs(JobBlips) do
        if(v?.playerId == playerId) then
            index = k
            break
        end
    end
    return index
end

AddEventHandler("onResourceStart", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        local xPlayers = ESX.GetExtendedPlayers()
        for _,xPlayer in pairs(xPlayers) do
            local job = xPlayer.getJob()
            if(Jobs[job.name].Blips and next(Jobs[job.name].Blips)) then
                local ped = GetPlayerPed(xPlayer.source)
                local coords = GetEntityCoords(ped)
                table.insert(JobBlips, {
                    playerId = xPlayer.source,
                    job = job.name,
                    fullname = xPlayer.get("fullname"),
                    coords = coords,
                })
            end
        end
    end
end)