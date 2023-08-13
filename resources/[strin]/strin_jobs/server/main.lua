Society = exports.strin_society
Inventory = exports.ox_inventory

Citizen.CreateThread(function()
    while GetResourceState("strin_society") ~= "started" do
        Citizen.Wait(0)
    end
    for k,v in pairs(Jobs) do
        if(not v.Society or not next(v.Society) or lib.table.contains(LawEnforcementJobs, k) or lib.table.contains(DistressJobs, k)) then
            goto skipLoop
        end
        Society:CreateNewSociety(k, v.Society?.label or k, 0, v.Society?.grades or {
            { label = "Nováček" },
            { label = "Pokročilý" },
            { label = "Zkušený" },
            { name = "boss", label = "Šéf" },
        })
        ::skipLoop::
    end
end)

Formats = {
    Storage = { 
        Id = "strin_jobs:storage:%s",
        Label = "%s - Sklad",
    },
    Armory = {
        Id = "strin_jobs:armory:%s",
        Label = "%s - Zbrojnice",
    }
}

Citizen.CreateThread(function()
    for i=1, #DistressJobs do
        TriggerEvent('esx_phone:registerNumber', DistressJobs[i], "Alert - "..DistressJobs[i], true, true)
    end

    while GetResourceState("ox_inventory") ~= "started" or GetResourceState("strin_society") ~= "started" do
        Citizen.Wait(0)
    end
    
    for k,v in pairs(Jobs) do
        local society = Society:GetSociety(k) or {
            label = k,
        }
        Inventory:RegisterStash(
            Formats["Storage"].Id:format(k),
            Formats["Storage"].Label:format(society.label),
            50,
            100000
        )
        Inventory:RegisterStash(
            Formats["Armory"].Id:format(k),
            Formats["Armory"].Label:format(society.label),
            50, 
            100000
        )
    end
end)

lib.callback.register("strin_jobs:useLockpick", function(source)
    local _source = source
    local lockpickCount = Inventory:GetItemCount(_source, "lockpick")
    if(lockpickCount <= 0) then
        return false
    end
    local lockpickRemoved = Inventory:RemoveItem(_source, "lockpick", 1)
    return lockpickRemoved
end)

lib.callback.register("strin_jobs:scanFingerprints", function(source, targetId)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return false
    end

    local job = xPlayer.getJob()
    if(not lib.table.contains(LawEnforcementJobs, job.name)) then
        return false
    end

    local targetPlayer = ESX.GetPlayerFromId(targetId)
    if(not targetPlayer) then
        return false
    end

    local ped = GetPlayerPed(_source)
    local targetPed = GetPlayerPed(targetPlayer.source)

    if(#(GetEntityCoords(ped) - GetEntityCoords(targetPed)) > 7.5) then
        return false
    end

    return targetPlayer.get("char_identifier")
end)

RegisterNetEvent("strin_jobs:requestStash", function(jobName, stashType)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer or (stashType ~= "Armories" and stashType ~= "Storages")) then
        return
    end

    local job = xPlayer.getJob()
    if(job.name ~= jobName) then
        xPlayer.showNotification("K této akci nemáte přístup!", {type = "error"})
        return
    end

    local isNearStash = IsNearJobStash(_source, jobName, stashType)
    if(not isNearStash) then
        xPlayer.showNotification("Nejste dostatečně blízko!", {type = "error"})
        return
    end
    
    if(stashType == "Armories") then
        Inventory:forceOpenInventory(_source, "stash", Formats["Armory"].Id:format(jobName))
    elseif(stashType == "Storages") then
        Inventory:forceOpenInventory(_source, "stash", Formats["Storage"].Id:format(jobName))
    end
end)

function IsNearJobStash(playerId, jobName, stashType)
    local isNear = false
    local ped = GetPlayerPed(playerId)
    local coords = GetEntityCoords(ped)
    local stashes = Jobs[jobName]?.Zones?[stashType] or {}
    for i=1, #stashes do
        local distance = #(coords - stashes[i])
        if(distance < 10) then
            isNear = true
            break
        end
    end
    return isNear
end

function HasAccessToAction(jobName, action)
    if(not Jobs[jobName]) then
        return false
    end
    local hasAccess = false
    for i=1, #(Jobs[jobName].Actions or {}) do
        if(action == Jobs[jobName].Actions[i]) then
            hasAccess = true
            break
        end
    end
    return hasAccess
end

function ArePlayersNearEachother(playerOneId, playerTwoId)
    local areNear = false
    local playerOnePed = GetPlayerPed(playerOneId)
    local playerTwoPed = GetPlayerPed(playerTwoId)
    local playerOneCoords = GetEntityCoords(playerOnePed)
    local playerTwoCoords = GetEntityCoords(playerTwoPed)
    local distance = #(playerOneCoords - playerTwoCoords)
    if(distance < 10) then
        areNear = true
    end
    return areNear
end

exports("GetLawEnforcementJobs", function()
    return LawEnforcementJobs
end)

function GetJobsWithAction(actionName)
    local jobs = {}
    for k,v in pairs(Jobs) do
        if(v.Actions and lib.table.contains(v.Actions, actionName)) then
            jobs[#jobs + 1] = k
        end
    end
    return jobs
end

exports("GetJobsWithAction", GetJobsWithAction)

exports("HasAccessToAction", HasAccessToAction)

exports("GetDistressJobs", function()
    return DistressJobs
end)