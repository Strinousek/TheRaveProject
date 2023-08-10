local RecentlyCalledOfficerTime = nil
local LawEnforcementJobs = exports.strin_jobs:GetLawEnforcementJobs()

RegisterNetEvent("strin_receptions:callOfficer", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    if(RecentlyCalledOfficerTime) then
        local remainingSeconds = math.floor((RecentlyCalledOfficer + (5 * 60)) - os.time())
        if(remainingSeconds > 0) then
            xPlayer.showNotification(("Officer byl už nedávno vyžádán, vyčkejte %s sekund."):format(
                remainingSeconds
            ))
            return
        else
            RecentlyCalledOfficerTime = nil
        end
    end

    local distance = #(GetEntityCoords(GetPlayerPed(_source)) - RECEPTIONS["mrpd"].coords)
    if(distance > 10.0) then
        xPlayer.showNotification("Od recepce jste moc daleko!", { type = "error" })
        return
    end

    RecentlyCalledOfficerTime = os.time()
    local data = {
        displayCode = 'MRPD',
        description = "Vyžádání Officera",
        isImportant = 0,
        recipientList = LawEnforcementJobs, 
        length = '20000',
        infoM = 'fa-info-circle',
        info = xPlayer.get("fullname"),
    }
    local dispatchData = { dispatchData = data, caller = 'Fero', coords = RECEPTIONS["mrpd"].coords}
    TriggerEvent('wf-alerts:svNotify', dispatchData)
end)