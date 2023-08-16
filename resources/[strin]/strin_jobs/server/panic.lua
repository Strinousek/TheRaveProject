ESX.RegisterCommand("panic", "user", function(xPlayer)
    local _source = xPlayer.source
    local ped = GetPlayerPed(_source)
    local coords = GetEntityCoords(ped)
    local job = xPlayer.getJob()
    if(lib.table.contains(LawEnforcementJobs, job.name)) then
        local data = {displayCode = '10-99', description = 'Officer down', isImportant = 1, recipientList = LawEnforcementJobs, 
        length = '15000', infoM = 'fa-info-circle', info = job.grade_label.." "..xPlayer.get("lastname")}
        local dispatchData = {dispatchData = data, caller = 'Alarm', coords = coords}
        TriggerEvent('wf-alerts:svNotify', dispatchData)
    end
end)