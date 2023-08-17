local StrinJobs = exports.strin_jobs
local LawEnforcementJobs = StrinJobs:GetLawEnforcementJobs()
local DistressJobs = StrinJobs:GetDistressJobs()

-- ESX Framework Stuff ---------------------------------------------------------------

lib.callback.register("linden_outlawalert:getCharData", function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then
		return
	end

	return {
		firstname = xPlayer.get("firstname"),
		lastname = xPlayer.get("lastname"),
		phone_number = xPlayer.get("phone_number")
	}
end)

lib.callback.register("linden_outlawalert:isVehicleOwned", function(source, plate)

	if(not plate or type(plate) ~= "string") then
		return false
	end

	local _source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then
		return
	end

	local foundPlate = MySQL.scalar.await('SELECT `plate` FROM `owned_vehicles` WHERE `plate` = ?', {
		plate:upper()
	})

	return foundPlate and true or false
end)

-- ESX Framework Stuff ---------------------------------------------------------------


local name = ('%s %s'):format(firstname, lastname)
local title = ('%s %s'):format(rank, lastname)
caller = name
info = title

function getCaller(src)
	local xPlayer = ESX.GetPlayerFromId(src)
	return xPlayer.get("fullname")
end

function getTitle(src)
	local xPlayer = ESX.GetPlayerFromId(src)
	local identifier = xPlayer.identifier
	--local name = MySQL.Sync.fetchAll('SELECT lastname FROM users WHERE identifier = @identifier', {['@identifier'] = identifier})
	local title = ('%s %s'):format(xPlayer.job.grade_label, xPlayer.get("lastname"))
	return title
end

local dispatchCodes = {

	melee = { displayCode = '10-10', description = _U('melee'), isImportant = 0, recipientList = LawEnforcementJobs or {'police', "sheriff"},
	blipSprite = 310, blipColour = 84, blipScale = 1.5 },

	officerdown = {displayCode = '10-99', description = _U('officerdown'), isImportant = 1, recipientList = DistressJobs or {'police', 'ambulance', "sheriff"},
	blipSprite = 161, blipColour = 84, blipScale = 1.5, infoM = 'fa-portrait'},

	persondown = {displayCode = '10-52', description = _U('persondown'), isImportant = 0, recipientList = DistressJobs or {'police', 'ambulance', "sheriff"},
	blipSprite = 310, blipColour = 84, blipScale = 1.5, infoM = 'fa-portrait'},

	autotheft = {displayCode = '10-16', description = _U('autotheft'), isImportant = 0, recipientList = LawEnforcementJobs or {'police', "sheriff"},
	blipSprite = 645, blipColour = 84, blipScale = 1.5, infoM = 'fa-car', infoM2 = 'fa-palette' },

	speeding = {displayCode = '10-66', description = _U('speeding'), isImportant = 0, recipientList = LawEnforcementJobs or {'police', "sheriff"},
	blipSprite = 488, blipColour = 84, blipScale = 1.5, infoM = 'fa-car', infoM2 = 'fa-palette' },

	shooting = { displayCode = '10-13', description = _U('shooting'), isImportant = 0, recipientList = LawEnforcementJobs or {'police', "sheriff"}, length = 11000,
	blipSprite = 110, blipColour = 84, blipScale = 1.5 },

	driveby = { displayCode = '10-13', description = _U('driveby'), isImportant = 0, recipientList = LawEnforcementJobs or{'police', "sheriff"},
	blipSprite = 229, blipColour = 84, blipScale = 1.5, infoM = 'fa-car', infoM2 = 'fa-palette' },
}


--[[ Example custom alert
RegisterCommand('testvangelico', function(playerId, args, rawCommand)
	local data = {displayCode = '211', description = 'Robbery', isImportant = 0, recipientList = {'police'}, length = '10000', infoM = 'fa-info-circle', info = 'Vangelico Jewelry Store'}
	local dispatchData = {dispatchData = data, caller = 'Alarm', coords = vector3(-633.9, -241.7, 38.1)}
	TriggerEvent('wf-alerts:svNotify', dispatchData)
end, false)
--]]


local blacklistedIdentifiers = {
}

function Blacklisted()
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return false end
	local identifier = xPlayer.identifier
	for i = 1, #blacklistedIdentifiers do
		if identifier == blacklistedIdentifiers[i] then
			return true
		end
	end
	return false
end

RegisterServerEvent('wf-alerts:svNotify')
AddEventHandler('wf-alerts:svNotify', function(pData)
	if not Blacklisted(source) then
		local dispatchData
		if pData.dispatchCode == 'officerdown' then
			pData.info = getTitle(source)
		end
		if pData.dispatchCode == 'persondown' then
			pData.caller = getCaller(source)
		end
		if not pData.dispatchCode then 
			dispatchData = pData.dispatchData 
		elseif dispatchCodes[pData.dispatchCode] ~= nil then 
			dispatchData = dispatchCodes[pData.dispatchCode] 
		end
		if not pData.info then
			if(dispatchData.info == nil) then
				pData.info = "Incident "..math.random(10, 100)
			else
				pData.info = dispatchData.info.." | Incident "..math.random(10, 100)
			end
		else
			pData.info = pData.info.." | Incident "..math.random(10, 100)
		end
		if not pData.info2 then pData.info2 = dispatchData.info2 end
		if not pData.length then pData.length = dispatchData.length end
		pData.displayCode = dispatchData.displayCode
		pData.dispatchMessage = dispatchData.description
		pData.isImportant = dispatchData.isImportant
		pData.recipientList = dispatchData.recipientList
		pData.infoM = dispatchData.infoM
		pData.infoM2 = dispatchData.infoM2
		pData.sprite = dispatchData.blipSprite or 623
		pData.colour = dispatchData.blipColour or 84
		pData.scale = dispatchData.blipScale or 1.5
		TriggerClientEvent('wf-alerts:clNotify', -1, pData)
		local n = [[

	]]
		local details = pData.dispatchMessage
		if pData.info then details = details .. n .. pData.info end
		if pData.info2 then details = details .. n .. pData.info2 end
		if pData.recipientList[1] == 'police' or pData.recipientList[2] == 'sheriff'  then TriggerEvent('mdt:newCall', details, pData.caller, vector3(pData.coords.x, pData.coords.y, pData.coords.z), false) end
	end
end)


RegisterServerEvent('wf-alerts:svNotify911')
AddEventHandler('wf-alerts:svNotify911', function(message, caller, coords)
	if message ~= nil then
		local pData = {}
		pData.displayCode = '911'
		if caller == _U('caller_unknown') then pData.dispatchMessage = _U('unknown_caller') else
		pData.dispatchMessage = _U('call_from') .. caller end
		pData.recipientList = {'police', 'ambulance'}
		pData.length = 13000
		pData.infoM = 'fa-phone'
		pData.info = message
		pData.coords = vector3(coords.x, coords.y, coords.z)
		pData.sprite, pData.colour, pData.scale =  817, 84, 2.0 -- radar_vip, blue
		if not pData.info then
			if(message == nil) then
				pData.info = "Incident "..math.random(10, 100)
			else
				pData.info = message.." | Incident "..math.random(10, 100)
			end
		else
			pData.info = pData.info.." | Incident "..math.random(10, 100)
		end
--[[	local xPlayers = ESX.GetPlayers()
		for i= 1, #xPlayers do
			local source = xPlayers[i]
			local xPlayer = ESX.GetPlayerFromId(source)
			if xPlayer.job.name == 'police' or xPlayer.job.name == 'ambulance' then
				TriggerClientEvent('wf-alerts:clNotify', source, pData)
			end
		end]]
		TriggerClientEvent('wf-alerts:clNotify', -1, pData) -- Send to all clients then check auth clientside?
		TriggerEvent('mdt:newCall', message, caller, vector3(coords.x, coords.y, coords.z), false)
	end
end)
