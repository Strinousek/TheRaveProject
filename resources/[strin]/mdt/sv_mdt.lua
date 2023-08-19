local call_index = 0

Citizen.CreateThread(function()
    MySQL.query.await(([[
		CREATE TABLE IF NOT EXISTS `user_mdt` (
			`id` INT(11) NOT NULL AUTO_INCREMENT,
			`char_id` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
			`notes` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
			`mugshot_url` VARCHAR(255) NULL DEFAULT NULL COLLATE 'latin1_swedish_ci',
			`bail` BIT(1) NULL DEFAULT NULL,
			`wanted` BIT(1) NULL DEFAULT NULL,
			PRIMARY KEY (`id`) USING BTREE
		)
		COLLATE='utf8mb4_bin'
		ENGINE=InnoDB
		AUTO_INCREMENT=3;		
    ]]))
    MySQL.query.await(([[
        ALTER TABLE `user_mdt`
			ADD IF NOT EXISTS `id` INT(11) NOT NULL AUTO_INCREMENT,
			ADD IF NOT EXISTS `char_id` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
			ADD IF NOT EXISTS `notes` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
			ADD IF NOT EXISTS `mugshot_url` VARCHAR(255) NULL DEFAULT NULL COLLATE 'latin1_swedish_ci',
			ADD IF NOT EXISTS `bail` BIT(1) NULL DEFAULT NULL,
			ADD IF NOT EXISTS `wanted` BIT(1) NULL DEFAULT NULL;
    ]]))
end)

local function IsPedNearAnyStation(pedHandle, stations)
	local isNear = false
	local coords = GetEntityCoords(pedHandle)
	for i=1, #stations do
		if(#(coords - stations[i].coords) < 50) then
			isNear = true
			break
		end
	end
	return isNear
end

RegisterServerEvent("mdt:hotKeyOpen")
AddEventHandler("mdt:hotKeyOpen", function()
	local usource = source
    local xPlayer = ESX.GetPlayerFromId(source)
	local ped = GetPlayerPed(usource)
	local vehicle = GetVehiclePedIsIn(ped)
    if xPlayer.job.name == 'police' then
		local jobConfig = exports.strin_jobs:GetJobConfig(xPlayer.job.name)
		if((vehicle == 0 and not IsPedNearAnyStation(ped, jobConfig.StaticBlips))) then
			xPlayer.showNotification("MDT nelze otevřít!", { type = "error" })
			return
		end
    	MySQL.Async.fetchAll("SELECT * FROM (SELECT * FROM `mdt_reports` ORDER BY `id` DESC LIMIT 3) sub ORDER BY `id` DESC", {}, function(reports)
    		for r = 1, #reports do
    			reports[r].charges = json.decode(reports[r].charges)
    		end
    		MySQL.Async.fetchAll("SELECT * FROM (SELECT * FROM `mdt_warrants` ORDER BY `id` DESC LIMIT 3) sub ORDER BY `id` DESC", {}, function(warrants)
    			for w = 1, #warrants do
    				warrants[w].charges = json.decode(warrants[w].charges)
    			end


    			local officer = GetCharacterName(usource)
    			TriggerClientEvent('mdt:toggleVisibilty', usource, reports, warrants, officer, xPlayer.job.name, xPlayer.job.grade_label)
    		end)
    	end)
    end
end)

RegisterServerEvent("mdt:getOffensesAndOfficer")
AddEventHandler("mdt:getOffensesAndOfficer", function()
	local usource = source
	local charges = {}
	MySQL.Async.fetchAll('SELECT * FROM fine_types', {
	}, function(fines)
		for j = 1, #fines do
			if fines[j].category == 0 or fines[j].category == 1 or fines[j].category == 2 or fines[j].category == 3 then
				table.insert(charges, fines[j])
			end
		end

		local officer = GetCharacterName(usource)

		TriggerClientEvent("mdt:returnOffensesAndOfficer", usource, charges, officer)
	end)
end)

RegisterServerEvent("mdt:performOffenderSearch")
AddEventHandler("mdt:performOffenderSearch", function(query)
	local usource = source
	local matches = {}
	MySQL.Async.fetchAll([[
		SELECT characters.*, users.phone_number FROM `characters`
		LEFT JOIN `users` ON (characters.identifier = users.identifier AND characters.char_id = users.char_id)
		WHERE LOWER(characters.char_identifier) LIKE @query OR 
		LOWER(characters.firstname) LIKE @query OR 
		LOWER(characters.lastname) LIKE @query OR 
		CONCAT(LOWER(characters.firstname), ' ', LOWER(characters.lastname)) LIKE @query OR 
		users.phone_number LIKE @query2
	]], {
		['@query'] = string.lower('%'..query..'%'), -- % wildcard, needed to search for all alike results
		['@query2'] = string.lower(query..'%')
	}, function(result)

		for index, data in ipairs(result) do
			data.id = data.char_identifier
			table.insert(matches, data)
		end

		TriggerClientEvent("mdt:returnOffenderSearchResults", usource, matches)
	end)
end)

RegisterServerEvent("mdt:getOffenderDetails")
AddEventHandler("mdt:getOffenderDetails", function(offender)
	local usource = source
	GetLicenses(offender.identifier, offender.char_id, function(licenses) offender.licenses = licenses end)
	local start = GetGameTimer()
	while offender.licenses == nil do
		if(GetGameTimer() - start >= 5000) then
			break
		end
		Citizen.Wait(0)
	end
	if(offender.licenses == nil) then
		offender.licenses = {}
	end

	local result = MySQL.Sync.fetchAll('SELECT * FROM `user_mdt` WHERE `char_id` = @id', {
		['@id'] = offender.id
	})
	offender.notes = ""
	offender.mugshot_url = ""
	offender.bail = false
	offender.wanted = false
	if result[1] then
		offender.notes = result[1].notes
		offender.mugshot_url = result[1].mugshot_url
		offender.bail = result[1].bail
		offender.wanted = result[1].wanted
	end

	local convictions = MySQL.Sync.fetchAll('SELECT * FROM `user_convictions` WHERE `char_id` = @id', {
		['@id'] = offender.id
	})
	if convictions[1] then
		offender.convictions = {}
		for i = 1, #convictions do
			local conviction = convictions[i]
			offender.convictions[conviction.offense] = conviction.count
		end
	end

	local warrants = MySQL.Sync.fetchAll('SELECT * FROM `mdt_warrants` WHERE `char_id` = @id', {
		['@id'] = offender.id
	})
	if warrants[1] then
		offender.haswarrant = true
	end

	local offenderxPlayer = ESX.GetPlayerFromIdentifier(offender.identifier)
	if(offenderxPlayer) then
		if(offenderxPlayer.get("char_id") == offender.char_id) then
			offender.phone_number = offenderxPlayer.get("phone_number")
		else
			offender.phone_number = MySQL.prepare.await("SELECT `phone_number` FROM `characters` WHERE `identifier` = ? AND `char_id` = ?", {
				offender.identifier,
				offender.char_id
			})
		end
	else
		local activeCharId = MySQL.prepare.await("SELECT `char_id` FROM `users` WHERE `identifier` = ?", {
			offender.identifier
		})
		if(activeCharId == offender.char_id) then
			offender.phone_number = MySQL.prepare.await("SELECT `phone_number` FROM `users` WHERE `identifier` = ?", {
				offender.identifier
			})
		else
			offender.phone_number = MySQL.prepare.await("SELECT `phone_number` FROM `characters` WHERE `identifier` = ? AND `char_id` = ?", {
				offender.identifier,
				offender.char_id
			})
		end
	end

	print(json.encode(offender))

	local vehicles = MySQL.Sync.fetchAll('SELECT * FROM `owned_vehicles` WHERE `owner` = @identifier AND `job` IS NULL', {
		['@identifier'] = offender.identifier..":"..offender.char_id
	})
	for i = 1, #vehicles do
		vehicles[i].state, vehicles[i].stored, vehicles[i].job, vehicles[i].fourrieremecano, vehicles[i].vehiclename, vehicles[i].ownerName = nil
		vehicles[i].vehicle = json.decode(vehicles[i].props or "{}")
		vehicles[i].model = vehicles[i].model
		if vehicles[i].vehicle.color1 then
			if colors[tostring(vehicles[i].vehicle.color2)] and colors[tostring(vehicles[i].vehicle.color1)] then
				vehicles[i].color = colors[tostring(vehicles[i].vehicle.color2)] .. " on " .. colors[tostring(vehicles[i].vehicle.color1)]
			elseif colors[tostring(vehicles[i].vehicle.color1)] then
				vehicles[i].color = colors[tostring(vehicles[i].vehicle.color1)]
			elseif colors[tostring(vehicles[i].vehicle.color2)] then
				vehicles[i].color = colors[tostring(vehicles[i].vehicle.color2)]
			else
				vehicles[i].color = "Unknown"
			end
		end
		vehicles[i].vehicle = nil
	end
	offender.vehicles = vehicles

	TriggerClientEvent("mdt:returnOffenderDetails", usource, offender)
end)

RegisterServerEvent("mdt:getOffenderDetailsById")
AddEventHandler("mdt:getOffenderDetailsById", function(char_identifier)
	local usource = source

	local result = MySQL.Sync.fetchAll('SELECT * FROM `characters` WHERE `char_identifier` = @id', {
		['@id'] = char_identifier
	})
	local offender = result[1]

	offender.id = offender.char_identifier

	if not offender then
		TriggerClientEvent("mdt:closeModal", usource)
		TriggerClientEvent("mdt:sendNotification", usource, "This person no longer exists.")
		return
	end

	GetLicenses(offender.identifier, offender.char_id, function(licenses) offender.licenses = licenses end)
	local start = GetGameTimer()
	while offender.licenses == nil do
		if(GetGameTimer() - start >= 5000) then
			break
		end
		Citizen.Wait(0)
	end
	if(offender.licenses == nil) then
		offender.licenses = {}
	end

	local result = MySQL.Sync.fetchAll('SELECT * FROM `user_mdt` WHERE `char_id` = @id', {
		['@id'] = offender.char_identifier
	})
	offender.notes = ""
	offender.mugshot_url = ""
	offender.bail = false
	offender.wanted = false
	if result[1] then
		offender.notes = result[1].notes
		offender.mugshot_url = result[1].mugshot_url
		offender.bail = result[1].bail
		offender.wanted = result[1].wanted
	end

	local convictions = MySQL.Sync.fetchAll('SELECT * FROM `user_convictions` WHERE `char_id` = @id', {
		['@id'] = offender.char_identifier
	}) 
	if convictions[1] then
		offender.convictions = {}
		for i = 1, #convictions do
			local conviction = convictions[i]
			offender.convictions[conviction.offense] = conviction.count
		end
	end

	local warrants = MySQL.Sync.fetchAll('SELECT * FROM `mdt_warrants` WHERE `char_id` = @id', {
		['@id'] = offender.char_identifier
	})
	if warrants[1] then
		offender.haswarrant = true
	end

	local offenderxPlayer = ESX.GetPlayerFromIdentifier(offender.identifier)
	if(offenderxPlayer) then
		if(offenderxPlayer.get("char_id") == offender.char_id) then
			offender.phone_number = offenderxPlayer.get("phone_number")
		else
			offender.phone_number = MySQL.prepare.await("SELECT `phone_number` FROM `characters` WHERE `identifier` = ? AND `char_id` = ?", {
				offenderxPlayer.identifier,
				offender.char_id
			})
		end
	else
		local activeCharId = MySQL.prepare.await("SELECT `char_id` FROM `users` WHERE `identifier` = ?", {
			offender.identifier
		})
		if(activeCharId == offender.char_id) then
			offender.phone_number = MySQL.prepare.await("SELECT `phone_number` FROM `users` WHERE `identifier` = ?", {
				offender.identifier
			})
		else
			offender.phone_number = MySQL.prepare.await("SELECT `phone_number` FROM `characters` WHERE `identifier` = ? AND `char_id` = ?", {
				offender.identifier,
				offender.char_id
			})
		end
	end
	
	/*local phone_number = MySQL.Sync.fetchAll('SELECT `phone_number` FROM `users` WHERE `identifier` = @identifier', {
		['@identifier'] = offender.identifier
	})
	offender.phone_number = phone_number[1].phone_number*/

	local vehicles = MySQL.Sync.fetchAll('SELECT * FROM `owned_vehicles` WHERE `owner` = @identifier AND `job` IS NULL', {
		['@identifier'] = offender.identifier..":"..offender.char_id
	})
	for i = 1, #vehicles do
		vehicles[i].state, vehicles[i].stored, vehicles[i].job, vehicles[i].fourrieremecano, vehicles[i].vehiclename, vehicles[i].ownerName = nil
		vehicles[i].vehicle = json.decode(vehicles[i].props or {})
		vehicles[i].model = vehicles[i].model
		if vehicles[i].vehicle.color1 then
			if colors[tostring(vehicles[i].vehicle.color2)] and colors[tostring(vehicles[i].vehicle.color1)] then
				vehicles[i].color = colors[tostring(vehicles[i].vehicle.color2)] .. " on " .. colors[tostring(vehicles[i].vehicle.color1)]
			elseif colors[tostring(vehicles[i].vehicle.color1)] then
				vehicles[i].color = colors[tostring(vehicles[i].vehicle.color1)]
			elseif colors[tostring(vehicles[i].vehicle.color2)] then
				vehicles[i].color = colors[tostring(vehicles[i].vehicle.color2)]
			else
				vehicles[i].color = "Unknown"
			end
		end
		vehicles[i].vehicle = nil
	end
	offender.vehicles = vehicles

	TriggerClientEvent("mdt:returnOffenderDetails", usource, offender)
end)

RegisterServerEvent("mdt:saveOffenderChanges")
AddEventHandler("mdt:saveOffenderChanges", function(id, changes, identifier)
	local usource = source
	MySQL.Async.fetchAll('SELECT * FROM `user_mdt` WHERE `char_id` = @id', {
		['@id']  = id
	}, function(result)
		if result[1] then
			MySQL.Async.execute('UPDATE `user_mdt` SET `notes` = @notes, `mugshot_url` = @mugshot_url, `bail` = @bail, `wanted` = @wanted WHERE `char_id` = @id', {
				['@id'] = id,
				['@notes'] = changes.notes,
				['@mugshot_url'] = changes.mugshot_url,
				['@bail'] = changes.bail,
				['@wanted'] = changes.wanted,
			})
		else
			MySQL.Async.insert('INSERT INTO `user_mdt` (`char_id`, `notes`, `mugshot_url`, `bail`, `wanted`) VALUES (@id, @notes, @mugshot_url, @bail, @wanted)', {
				['@id'] = id,
				['@notes'] = changes.notes,
				['@mugshot_url'] = changes.mugshot_url,
				['@bail'] = changes.bail,
				['@wanted'] = changes.wanted,
			})
		end
		local characterId
		if(#changes.licenses_removed > 0) then
			characterId = MySQL.scalar.await("SELECT `char_id` FROM `characters` WHERE `char_identifier` = ?", { id })
		end
		for i = 1, #changes.licenses_removed do
			local license = changes.licenses_removed[i]
			MySQL.Async.execute('DELETE FROM `user_licenses` WHERE `type` = @type AND `owner` = @identifier', {
				['@type'] = license.type,
				['@identifier'] = identifier..":"..characterId
			})
		end

		if changes.convictions ~= nil then
			for conviction, amount in pairs(changes.convictions) do	
				MySQL.Async.execute('UPDATE `user_convictions` SET `count` = @count WHERE `char_id` = @id AND `offense` = @offense', {
					['@id'] = id,
					['@count'] = amount,
					['@offense'] = conviction
				})
			end
		end

		for i = 1, #changes.convictions_removed do
			MySQL.Async.execute('DELETE FROM `user_convictions` WHERE `char_id` = @id AND `offense` = @offense', {
				['@id'] = id,
				['offense'] = changes.convictions_removed[i]
			})
		end

		TriggerClientEvent("mdt:sendNotification", usource, "Změny pro suspekta byly uloženy.")
	end)
end)

RegisterServerEvent("mdt:saveReportChanges")
AddEventHandler("mdt:saveReportChanges", function(data)
	MySQL.Async.execute('UPDATE `mdt_reports` SET `title` = @title, `incident` = @incident WHERE `id` = @id', {
		['@id'] = data.id,
		['@title'] = data.title,
		['@incident'] = data.incident
	})
	TriggerClientEvent("mdt:sendNotification", source, "Změny v reportu byly uloženy.")
end)

RegisterServerEvent("mdt:deleteReport")
AddEventHandler("mdt:deleteReport", function(id)
	MySQL.Async.execute('DELETE FROM `mdt_reports` WHERE `id` = @id', {
		['@id']  = id
	})
	TriggerClientEvent("mdt:sendNotification", source, "Report byl smazán.")
end)

RegisterServerEvent("mdt:submitNewReport")
AddEventHandler("mdt:submitNewReport", function(data)
	local usource = source
	local author = GetCharacterName(source)
	charges = json.encode(data.charges)
	data.date = os.date('%m-%d-%Y %H:%M:%S', os.time())
	MySQL.Async.insert('INSERT INTO `mdt_reports` (`char_id`, `title`, `incident`, `charges`, `author`, `name`, `date`) VALUES (@id, @title, @incident, @charges, @author, @name, @date)', {
		['@id']  = data.char_id,
		['@title'] = data.title,
		['@incident'] = data.incident,
		['@charges'] = charges,
		['@author'] = author,
		['@name'] = data.name,
		['@date'] = data.date,
	}, function(id)
		TriggerEvent("mdt:getReportDetailsById", id, usource)
		TriggerClientEvent("mdt:sendNotification", usource, "Nový report byl zapsán.")
	end)

	for offense, count in pairs(data.charges) do
		MySQL.Async.fetchAll('SELECT * FROM `user_convictions` WHERE `offense` = @offense AND `char_id` = @id', {
			['@offense'] = offense,
			['@id'] = data.char_identifier
		}, function(result)
			if result[1] then
				MySQL.Async.execute('UPDATE `user_convictions` SET `count` = @count WHERE `offense` = @offense AND `char_id` = @id', {
					['@id']  = data.char_identifier,
					['@offense'] = offense,
					['@count'] = count + 1
				})
			else
				MySQL.Async.insert('INSERT INTO `user_convictions` (`char_id`, `offense`, `count`) VALUES (@id, @offense, @count)', {
					['@id']  = data.char_identifier,
					['@offense'] = offense,
					['@count'] = count
				})
			end
		end)
	end
end)

RegisterServerEvent("mdt:performReportSearch")
AddEventHandler("mdt:performReportSearch", function(query)
	local usource = source
	local matches = {}
	MySQL.Async.fetchAll("SELECT * FROM `mdt_reports` WHERE `id` LIKE @query OR LOWER(`title`) LIKE @query OR LOWER(`name`) LIKE @query OR LOWER(`author`) LIKE @query or LOWER(`charges`) LIKE @query", {
		['@query'] = string.lower('%'..query..'%') -- % wildcard, needed to search for all alike results
	}, function(result)

		for index, data in ipairs(result) do
			data.charges = json.decode(data.charges)
			table.insert(matches, data)
		end

		TriggerClientEvent("mdt:returnReportSearchResults", usource, matches)
	end)
end)

RegisterServerEvent("mdt:performVehicleSearch")
AddEventHandler("mdt:performVehicleSearch", function(query)
	local usource = source
	local matches = {}
	MySQL.Async.fetchAll("SELECT * FROM `owned_vehicles` WHERE LOWER(`plate`) LIKE @query OR LOWER(`vehicle_identifier`) LIKE @query", {
		['@query'] = string.lower('%'..query..'%') -- % wildcard, needed to search for all alike results
	}, function(result)

		for index, data in ipairs(result) do
			local data_decoded = json.decode(data.props or "{}")
			if data_decoded.color1 then
				data.color = colors[tostring(data_decoded.color1)]
				if colors[tostring(data_decoded.color2)] then
					data.color = colors[tostring(data_decoded.color2)] .. " on " .. colors[tostring(data_decoded.color1)]
				end
			end
			table.insert(matches, data)
		end

		TriggerClientEvent("mdt:returnVehicleSearchResults", usource, matches)
	end)
end)

RegisterServerEvent("mdt:performVehicleSearchInFront")
AddEventHandler("mdt:performVehicleSearchInFront", function(query)
	local usource = source
	local xPlayer = ESX.GetPlayerFromId(usource)
    if xPlayer.job.name == 'police' then
    	MySQL.Async.fetchAll("SELECT * FROM (SELECT * FROM `mdt_reports` ORDER BY `id` DESC LIMIT 3) sub ORDER BY `id` DESC", {}, function(reports)
    		for r = 1, #reports do
    			reports[r].charges = json.decode(reports[r].charges)
    		end
    		MySQL.Async.fetchAll("SELECT * FROM (SELECT * FROM `mdt_warrants` ORDER BY `id` DESC LIMIT 3) sub ORDER BY `id` DESC", {}, function(warrants)
    			for w = 1, #warrants do
    				warrants[w].charges = json.decode(warrants[w].charges)
    			end
    			MySQL.Async.fetchAll("SELECT * FROM `owned_vehicles` WHERE `plate` = @query", {
					['@query'] = query
				}, function(result)
					local officer = GetCharacterName(usource)
    				TriggerClientEvent('mdt:toggleVisibilty', usource, reports, warrants, officer, xPlayer.job.name)
					TriggerClientEvent("mdt:returnVehicleSearchInFront", usource, result, query)
				end)
    		end)
    	end)
	end
end)

RegisterServerEvent("mdt:getVehicle")
AddEventHandler("mdt:getVehicle", function(vehicle)
	local usource = source
	local separatorIndex = vehicle.owner:find(":")
	local identifier = vehicle.owner:sub(1, separatorIndex - 1)
	local char_id = tonumber(vehicle.owner:sub(separatorIndex + 1, string.len(vehicle.owner)))
	local result = MySQL.Sync.fetchAll("SELECT * FROM `characters` WHERE `identifier` = @query AND `char_id` = @char_id", {
		['@query'] = identifier,
		["@char_id"] = char_id
	})
	if result[1] then
		vehicle.owner = result[1].firstname .. ' ' .. result[1].lastname
		vehicle.owner_id = result[1].char_identifier
	end


	vehicle.vehicle_identifier = MySQL.prepare.await("SELECT `vehicle_identifier` FROM `owned_vehicles` WHERE `plate` = ?", {
		vehicle.plate
	})

	local data = MySQL.Sync.fetchAll('SELECT * FROM `vehicle_mdt` WHERE `plate` = @plate', {
		['@plate'] = vehicle.plate
	})
	if data[1] then
		if data[1].stolen == 1 then vehicle.stolen = true else vehicle.stolen = false end
		if data[1].notes ~= null then vehicle.notes = data[1].notes else vehicle.notes = '' end
	else
		vehicle.stolen = false
		vehicle.notes = ''
	end

	local warrants = MySQL.Sync.fetchAll('SELECT * FROM `mdt_warrants` WHERE `char_id` = @id', {
		['@id'] = vehicle.owner_id
	})
	if warrants[1] then
		vehicle.haswarrant = true
	end

	local custody = MySQL.Sync.fetchAll('SELECT `bail`, `wanted` FROM user_mdt WHERE `char_id` = @id', {
		['@id'] = vehicle.owner_id
	})
	if custody and custody[1] then 
		if(custody[1].bail == 1) then
			vehicle.bail = true 
		end
		if(custody[1].wanted == 1) then
			vehicle.wanted = true 
		end
	else 
		vehicle.bail = false 
		vehicle.wanted = false
	end

	vehicle.type = types[vehicle.type]
	TriggerClientEvent("mdt:returnVehicleDetails", usource, vehicle)
end)

RegisterServerEvent("mdt:getWarrants")
AddEventHandler("mdt:getWarrants", function()
	local usource = source
	MySQL.Async.fetchAll("SELECT * FROM `mdt_warrants`", {}, function(warrants)
		for i = 1, #warrants do
			warrants[i].expire_time = ""
			warrants[i].charges = json.decode(warrants[i].charges)
		end
		TriggerClientEvent("mdt:returnWarrants", usource, warrants)
	end)
end)

RegisterServerEvent("mdt:submitNewWarrant")
AddEventHandler("mdt:submitNewWarrant", function(data)
	local usource = source
	data.charges = json.encode(data.charges)
	data.author = GetCharacterName(source)
	data.date = os.date('%m-%d-%Y %H:%M:%S', os.time())
	MySQL.Async.insert('INSERT INTO `mdt_warrants` (`name`, `char_id`, `report_id`, `report_title`, `charges`, `date`, `expire`, `notes`, `author`) VALUES (@name, @char_id, @report_id, @report_title, @charges, @date, @expire, @notes, @author)', {
		['@name']  = data.name,
		['@char_id'] = data.char_identifier,
		['@report_id'] = data.report_id,
		['@report_title'] = data.report_title,
		['@charges'] = data.charges,
		['@date'] = data.date,
		['@expire'] = data.expire,
		['@notes'] = data.notes,
		['@author'] = data.author
	}, function()
		TriggerClientEvent("mdt:completedWarrantAction", usource)
		TriggerClientEvent("mdt:sendNotification", usource, "Nový warrant byl vytvořen.")
	end)
end)

RegisterServerEvent("mdt:deleteWarrant")
AddEventHandler("mdt:deleteWarrant", function(id)
	local usource = source
	MySQL.Async.execute('DELETE FROM `mdt_warrants` WHERE `id` = @id', {
		['@id']  = id
	}, function()
		TriggerClientEvent("mdt:completedWarrantAction", usource)
	end)
	TriggerClientEvent("mdt:sendNotification", usource, "Warrant byl smazán.")
end)

RegisterServerEvent("mdt:getReportDetailsById")
AddEventHandler("mdt:getReportDetailsById", function(query, _source)
	if _source then source = _source end
	local usource = source
	MySQL.Async.fetchAll("SELECT * FROM `mdt_reports` WHERE `id` = @query", {
		['@query'] = query
	}, function(result)
		if result and result[1] then
			result[1].charges = json.decode(result[1].charges)
			TriggerClientEvent("mdt:returnReportDetails", usource, result[1])
		else
			TriggerClientEvent("mdt:closeModal", usource)
			TriggerClientEvent("mdt:sendNotification", usource, "Žádný takový report nebyl nalezen.")
		end
	end)
end)

RegisterServerEvent("mdt:newCall")
AddEventHandler("mdt:newCall", function(details, caller, coords, sendNotification)
	call_index = call_index + 1
	local xPlayers = ESX.GetExtendedPlayers()
	for _,xPlayer in pairs(xPlayers) do
		if xPlayer.job.name == 'police' then
			TriggerClientEvent("mdt:newCall", source, details, caller, coords, call_index)
			if sendNotification ~= false then
				TriggerClientEvent("interactsound:playSound", source, 'demo', 0.0)
				TriggerClientEvent("mythic_notify:client:SendAlert", source, {type="inform", text="Nové hlášení.", length=5000, style = { ['background-color'] = '#ffffff', ['color'] = '#000000' }})
			end
		end
	end
end)

RegisterServerEvent("mdt:attachToCall")
AddEventHandler("mdt:attachToCall", function(index)
	local usource = source
	local charname = GetCharacterName(usource)
	local xPlayers = ESX.GetPlayers()
	for i= 1, #xPlayers do
		local source = xPlayers[i]
		local xPlayer = ESX.GetPlayerFromId(source)
		if xPlayer.job.name == 'police' then
			TriggerClientEvent("mdt:newCallAttach", source, index, charname)
		end
	end
	TriggerClientEvent("mdt:sendNotification", usource, "Byl jste přiřazen k tomuto callu.")
end)

RegisterServerEvent("mdt:detachFromCall")
AddEventHandler("mdt:detachFromCall", function(index)
	local usource = source
	local charname = GetCharacterName(usource)
	local xPlayers = ESX.GetPlayers()
	for i= 1, #xPlayers do
		local source = xPlayers[i]
		local xPlayer = ESX.GetPlayerFromId(source)
		if xPlayer.job.name == 'police' then
			TriggerClientEvent("mdt:newCallDetach", source, index, charname)
		end
	end
	TriggerClientEvent("mdt:sendNotification", usource, "Byl jste odebrán od tohoto callu.")
end)

RegisterServerEvent("mdt:editCall")
AddEventHandler("mdt:editCall", function(index, details)
	local usource = source
	local xPlayers = ESX.GetPlayers()
	for i= 1, #xPlayers do
		local source = xPlayers[i]
		local xPlayer = ESX.GetPlayerFromId(source)
		if xPlayer.job.name == 'police' then
			TriggerClientEvent("mdt:editCall", source, index, details)
		end
	end
	TriggerClientEvent("mdt:sendNotification", usource, "Poupravil jste tento call.")
end)

RegisterServerEvent("mdt:deleteCall")
AddEventHandler("mdt:deleteCall", function(index)
	local usource = source
	local xPlayers = ESX.GetPlayers()
	for i= 1, #xPlayers do
		local source = xPlayers[i]
		local xPlayer = ESX.GetPlayerFromId(source)
		if xPlayer.job.name == 'police' then
			TriggerClientEvent("mdt:deleteCall", source, index)
		end
	end
	TriggerClientEvent("mdt:sendNotification", usource, "Smazal jste tento call.")
end)

RegisterServerEvent("mdt:saveVehicleChanges")
AddEventHandler("mdt:saveVehicleChanges", function(data)
	if data.stolen then data.stolen = 1 else data.stolen = 0 end
	local usource = source
	MySQL.Async.fetchAll('SELECT * FROM `vehicle_mdt` WHERE `plate` = @plate', {
		['@plate'] = data.plate
	}, function(result)
		if result[1] then
			MySQL.Async.execute('UPDATE `vehicle_mdt` SET `stolen` = @stolen, `notes` = @notes WHERE `plate` = @plate', {
				['@plate'] = data.plate,
				['@stolen'] = data.stolen,
				['@notes'] = data.notes
			})
		else
			MySQL.Async.insert('INSERT INTO `vehicle_mdt` (`plate`, `stolen`, `notes`) VALUES (@plate, @stolen, @notes)', {
				['@plate'] = data.plate,
				['@stolen'] = data.stolen,
				['@notes'] = data.notes
			})
		end
		
		TriggerClientEvent("mdt:sendNotification", usource, "Úpravy vozidla byly uloženy.")
	end)
end)

function GetLicenses(identifier, characterId, cb)
	local licenses = exports.strin_licenses:GetLicenses(identifier, characterId)
	cb(licenses)
	return licenses
end

function GetCharacterName(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer then
		return xPlayer.get("fullname")
		
	--[[	-- If the wrong name displays, remove `return xPlayer.getName()` and uncomment this code block
		local identifier = xPlayer.getIdentifier()
		local result = MySQL.Sync.fetchAll('SELECT firstname, lastname FROM `users` WHERE identifier = @identifier', {
		['@identifier'] = identifier
		})

		if result[1] and result[1].firstname and result[1].lastname then
			return ('%s %s'):format(result[1].firstname, result[1].lastname)
		end
	]]
	end
end

function tprint (tbl, indent)
  if not indent then indent = 0 end
  local toprint = string.rep(" ", indent) .. "{\r\n"
  indent = indent + 2 
  for k, v in pairs(tbl) do
    toprint = toprint .. string.rep(" ", indent)
    if (type(k) == "number") then
      toprint = toprint .. "[" .. k .. "] = "
    elseif (type(k) == "string") then
      toprint = toprint  .. k ..  "= "   
    end
    if (type(v) == "number") then
      toprint = toprint .. v .. ",\r\n"
    elseif (type(v) == "string") then
      toprint = toprint .. "\"" .. v .. "\",\r\n"
    elseif (type(v) == "table") then
      toprint = toprint .. tprint(v, indent + 2) .. ",\r\n"
    else
      toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
    end
  end
  toprint = toprint .. string.rep(" ", indent-2) .. "}"
  return toprint
end
