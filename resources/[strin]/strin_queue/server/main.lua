/* 
    { 
        {
            license, 
            points, 
            source
        }
    }
*/
local Players = {}

/* 
    { 
       license1,
       license2,
       ...licenseN
    }
*/
local Waiting = {}

/* 
    { 
       license1,
       license2,
       ...licenseN
    }
*/
local Connecting = {}

StopResource('hardcap')

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		if GetResourceState('hardcap') == 'stopped' then
			StartResource('hardcap')
		end
	end
end)

Citizen.CreateThread(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `user_queuepoints` (
            `identifier` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
            `points` INT(11) NULL DEFAULT NULL,
            INDEX `identifier` (`identifier`(191)) USING BTREE
        )
        ENGINE=InnoDB
        ;
    ]])
    MySQL.query.await([[
        ALTER TABLE `user_queuepoints`  
            ADD COLUMN IF NOT EXISTS `identifier` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
            ADD COLUMN IF NOT EXISTS `points` INT(11) NULL DEFAULT NULL;
    ]])
    MySQL.query("SELECT * FROM `user_queuepoints`", function(results)
        if(not results or not next(results)) then
            return
        end
        for i=1, #results do
            table.insert(QUEUE_POINTS, {
                results[i].identifier,
                results[i].points
            })
        end
        print("Loaded "..#results.."x queue point records.")
    end)
end)

ESX.RegisterCommand("addqp", "admin", function(xPlayer, args)
    local _source = xPlayer?.source
    if(not _source) then
        xPlayer = { showNotification = function(message) print(message) end }
    end
    local playerIdentifier = nil
    if(tonumber(args.playerIdentifier)) then
        playerIdentifier = ESX.GetIdentifier(tonumber(args.playerIdentifier))
        if(not playerIdentifier) then
            xPlayer.showNotification("Nepodařilo se získat licenci hráče!", { type = "error" })
            return
        end
    else
        playerIdentifier = args.playerIdentifier
    end
    
    local points = MySQL.scalar.await("SELECT `points` FROM `user_queuepoints` WHERE `identifier` = ?", { playerIdentifier })
    if(not points) then
        points = 0
    end
    points += tonumber(args.queuePoints)
    MySQL.query("INSERT INTO `user_queuepoints` SET `identifier` = ?, `points` = ? ON DUPLICATE KEY UPDATE `points` = VALUES(points)", {
        playerIdentifier,
        points
    }, function()
		for i=1, #QUEUE_POINTS do
			if(QUEUE_POINTS[i][1] == playerIdentifier) then
				QUEUE_POINTS[i][2] = points
				break
			end
		end
		xPlayer.showNotification("Hráči bylo přidáno "..args.queuePoints.." queue pointů.")
    end)
end, true, {
    help = "Přidá queue pointy hráči",
    arguments = {
        { name = "playerIdentifier", help = "ID hráče | License Identifier", type = "any" },
        { name = "queuePoints", help = "Množství queue pointů", type = "number" }
    }
})


ESX.RegisterCommand("setqp", "admin", function(xPlayer, args)
	local _source = xPlayer?.source
    if(not _source) then
        xPlayer = { showNotification = function(message) print(message) end }
    end
    local playerIdentifier = nil
    if(tonumber(args.playerIdentifier)) then
        playerIdentifier = ESX.GetIdentifier(tonumber(args.playerIdentifier))
        if(not playerIdentifier) then
            xPlayer.showNotification("Nepodařilo se získat licenci hráče!", { type = "error" })
            return
        end
    else
        playerIdentifier = args.playerIdentifier
    end

    local points = tonumber(args.queuePoints)
    MySQL.query("INSERT INTO `user_queuepoints` SET `identifier` = ?, `points` = ? ON DUPLICATE KEY UPDATE `points` = VALUES(points)", {
        playerIdentifier,
        points
    }, function()
		for i=1, #QUEUE_POINTS do
			if(QUEUE_POINTS[i][1] == playerIdentifier) then
				QUEUE_POINTS[i][2] = points
				break
			end
		end
		xPlayer.showNotification("Hráči bylo nastaveno "..args.queuePoints.." queue pointů.")
    end)
end, true, {
    help = "Nastaví queue pointy hráči",
    arguments = {
        { name = "queuePoints", help = "Množství queue pointů", type = "number" }
    }
})

AddEventHandler("playerConnecting", function(name, _, deferrals)
	local _source = source
	local identifier = GetLicenseIdentifier(_source)
    deferrals.defer()

	if not identifier then
        deferrals.done(NO_LICENSE_MESSAGE)
		return
	end

	if not InitQueueForPlayer(_source, identifier, deferrals) then
		CancelEvent()
	end
end)

function InitQueueForPlayer(playerId, identifier, deferrals)
	AntiSpam(deferrals)
	RemoveFromQueue(identifier)

	AddPlayer(playerId, identifier)

	table.insert(Waiting, identifier)

	local stop = false
	repeat

		for i,connectingIdentifier in ipairs(Connecting) do
			if connectingIdentifier == identifier then
				stop = true
				break
			end
		end

		for j,waitingIdentifier in ipairs(Waiting) do
			for i,player in ipairs(Players) do
				if waitingIdentifier == player[1] and player[1] == identifier and (GetPlayerPing(player[3]) == 0) then
					RemoveFromQueue(identifier)
					deferrals.done(ACCIDENT_MESSAGE)
					return false
				end
			end
		end

		deferrals.update(GetMessage(identifier))
		Citizen.Wait(REFRESH_EMOJIS_TIMER * 1000)

	until stop
	
	deferrals.done()
	return true
end

Citizen.CreateThread(function()
	local maxServerSlots = GetConvarInt('sv_maxclients', 64)	
    Citizen.CreateThread(function()
        while true do
            UpdatePoints()
            Citizen.Wait(UPDATE_POINTS_TIMER * 1000)
        end
    end)
	while true do
		Citizen.Wait(CHECK_PLACES_TIMER * 1000)
		CheckConnecting()
		if #Waiting > 0 and #Connecting + #GetPlayers() < maxServerSlots then
			ConnectFirst()
		end
	end
end)

AddEventHandler("esx:playerLoaded", function(playerId, xPlayer)
	RemoveFromQueue(xPlayer.identifier)
end)

AddEventHandler("playerDropped", function(reason)
    local _source = source
	local identifier = GetLicenseIdentifier(_source)
	RemoveFromQueue(identifier)
end)

function CheckConnecting()
	for i,identifier in ipairs(Connecting) do
		for j,player in ipairs(Players) do
			if player[1] == identifier and (GetPlayerPing(player[3]) == 500) then
				table.remove(Connecting, i)
				break
			end
		end
	end
end

function ConnectFirst()
	if #Waiting == 0 then return end

	local minPoints = 0
	local firstIdentifier = Waiting[1][1]
	local firstWaitId = 1

	for i,identifier in ipairs(Waiting) do
		local points = GetPoints(identifier)
		if points > minPoints then
			minPoints = points
			firstIdentifier = identifier
			firstWaitId = i
		end
	end
	
	table.remove(Waiting, firstWaitId)
	table.insert(Connecting, firstIdentifier)
end

function GetPoints(identifier)
	for i,player in ipairs(Players) do
		if player[1] == identifier then
			return player[2]
		end
	end
end

function UpdatePoints()
	for i,player in ipairs(Players) do

		local found = false

		for _,identifier in ipairs(Waiting) do
			if player[1] == identifier then
				player[2] = player[2] + ADD_POINTS_WHILE_WAITING
				found = true
				break
			end
		end

		if not found then
			for _,identifier in ipairs(Connecting) do
				if player[1] == identifier then
					found = true
					break
				end
			end
		
			if not found then
				player[2] = player[2] - REMOVE_POINTS_ON_JOIN
				if player[2] < GetInitialPoints(player[1]) - REMOVE_POINTS_ON_JOIN then
					RemoveFromQueue(player[1])
					table.remove(Players, i)
				end
			end
		end

	end
end

function AddPlayer(playerId, identifier)
	for i,player in ipairs(Players) do
		if identifier == player[1] then
			Players[i] = { player[1], player[2], playerId }
			return
		end
	end

	local initialPoints = GetInitialPoints(identifier)
	table.insert(Players, { identifier, initialPoints, playerId })
end

function GetInitialPoints(identifier)
	local points = REMOVE_POINTS_ON_JOIN + 1

	for _,v in ipairs(QUEUE_POINTS) do
		if v[1] == identifier then
			points = v[2]
			break
		end
	end

	local vipPoints = exports.strin_base:GetPlayerVIP(identifier)?.queuePoints
	points += vipPoints or 0

	return points
end

function GetPlace(identifier)
	local points = GetPoints(identifier)
	local place = 1

	for i,identifier in ipairs(Waiting) do
		for j,player in ipairs(Players) do
			if player[1] == identifier and player[2] > points then
				place = place + 1
			end
		end
	end
	
	return place
end

function GetMessage(identifier)
	local message = ""

    local points = GetPoints(identifier)
	if points ~= nil then
        local emojis = {}
        for i=1, 3 do
            table.insert(emojis, GetRandomEmoji())
        end

		local emojiText = table.concat(emojis, "")
		if( emojis[1] == emojis[2] and emojis[2] == emojis[3] ) then
			emojiText = emojiText .. EMOJI_BOOST_MESSAGE
			LotteryBoost(identifier)
		end

        message = WAITING_MESSAGE:format(
            ESX.Math.GroupDigits(points), 
            GetPlace(identifier),
            #Waiting,
            EMOJI_MESSAGE:format(emojiText)
        )
	else
		message = ACCIDENT_MESSAGE
	end

	return message
end

function LotteryBoost(identifier)
	for i,player in ipairs(Players) do
		if player[1] == identifier then
			player[2] = player[2] + LOTTERY_BONUS_POINTS
			return
		end
	end
end

function RemoveFromQueue(identifier)
	for i,connectingIdentifier in ipairs(Connecting) do
		if connectingIdentifier == identifier then
			table.remove(Connecting, i)
		end
	end

	for i,waitingIdentifier in ipairs(Waiting) do
		if waitingIdentifier == identifier then
			table.remove(Waiting, i)
		end
	end
end

function AntiSpam(deferrals)
	for i=ANTI_SPAM_TIMER,0,-1 do
		deferrals.update(PLEASE_WAIT_MESSAGE:format(i))
		Citizen.Wait(1000)
	end
end

function GetRandomEmoji()
	local randomEmoji = EMOJI_LIST[math.random(#EMOJI_LIST)]
	return randomEmoji
end

function GetLicenseIdentifier(playerId)
	local identifier = nil
    local license = GetPlayerIdentifierByType(playerId, "license")
    if(license) then
        identifier = license:gsub("license:", "")
    end
	return identifier
end
