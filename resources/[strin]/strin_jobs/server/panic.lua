ESX.RegisterCommand("panic", "user", function(xPlayer)
    local _source = xPlayer.source
    local ped = GetPlayerPed(_source)
    local coords = GetEntityCoords(ped)
    local job = xPlayer.getJob()
    if(lib.table.contains(LawEnforcementJobs, job.name)) then
        local data = {dispatchCode = "officerdown"}
        local dispatchData = {dispatchData = data, caller = 'Alarm', coords = coords}
        TriggerEvent('wf-alerts:svNotify', dispatchData)
    end
end)