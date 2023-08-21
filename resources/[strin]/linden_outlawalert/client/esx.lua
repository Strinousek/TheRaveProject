notLoaded, currentStreetName, intersectStreetName, lastStreet, speedlimit, nearbyPeds, isPlayerWhitelisted, playerPed, playerCoords, job, rank, firstname, lastname, phone = true
playerIsDead = false

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()
	GetPlayerInfo()
end)

RegisterNetEvent("strin_characters:characterCreated", function()
	GetPlayerInfo()
end)

RegisterNetEvent("strin_characters:characterSwitched", function()
	GetPlayerInfo()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    job = job.name
    rank = job.grade_label
    isPlayerWhitelisted = refreshPlayerWhitelisted()
end)

function GetPlayerInfo()
	lib.callback('linden_outlawalert:getCharData', false, function(chardata)
        firstname = chardata.firstname
        lastname = chardata.lastname
        phone = chardata.phone_number
        job = chardata.job.name
        rank = chardata.job.grade_label
        isPlayerWhitelisted = refreshPlayerWhitelisted()
    end)
end

AddEventHandler('esx:onPlayerDeath', function(data)
	playerIsDead = true
end)

AddEventHandler('esx:onPlayerSpawn', function(data)
	playerIsDead = false
end)

AddEventHandler('playerSpawned', function(data)
	playerIsDead = false
end)

AddEventHandler("onResourceStart", function(resourceName)
    if(GetCurrentResourceName() ~= resourceName) then
        return
    end
    Citizen.Wait(10000)
    if(not firstname) then
        GetPlayerInfo()
    end
end)