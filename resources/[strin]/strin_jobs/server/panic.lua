ESX.RegisterCommand("panic", "user", function(xPlayer)
    local _source = xPlayer.source
    local ped = GetPlayerPed(_source)
    local coords = GetEntityCoords(ped)
    local job = xPlayer.getJob()
    if(lib.table.contains(LawEnforcementJobs, job.name)) then
        local data = {
            displayCode = '10-99',
            description = "Officer down", 
            info = ('%s %s'):format(xPlayer.job.grade_label, xPlayer.get("lastname")),
	        blipSprite = 161, 
            blipColour = 84, 
            blipScale = 1.5,
            isImportant = 1,
            recipientList = DistressJobs or {'police', 'ambulance', "sheriff"}, 
            infoM = 'fa-portrait', 
            length = 8000
        }
        local dispatchData = {dispatchData = data, caller = 'Alarm', coords = coords}
        TriggerEvent('wf-alerts:svNotify', dispatchData)
    end
end)