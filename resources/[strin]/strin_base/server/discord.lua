Webhooks = {}

function RegisterWebhook(webhookKey, webhook, resourceName)
    local resource = resourceName or GetInvokingResource() or GetCurrentResourceName()
    if(not Webhooks[resource]) then
        Webhooks[resource] = {}
    end
    Webhooks[resource][webhookKey] = webhook
end

function DoesPlayerHaveDiscordRole(playerId, roleId, cb)
    local p = nil
    if(not cb) then
        p = promise.new()
    end
    exports.strin_base:_internalDoesPlayerHaveDiscordRole(playerId, roleId, function(result)
        if(cb) then
            cb(result)
        else
            p:resolve(result)
        end
    end)
    if(p) then
        return Citizen.Await(p)
    end
end

exports("DoesPlayerHaveDiscordRole", DoesPlayerHaveDiscordRole)

RegisterWebhook("DEFAULT", "https://discord.com/api/webhooks/1121786936474996788/qcHxaDFjISaHue1GD9DcmEnFjGYo8n6Iza0Jp3-baPyPwcMWXUrhznWKzYOEFX67HTsi")

RegisterWebhook("SYSTEM", "https://discordapp.com/api/webhooks/679798073165086776/gRps5DWgSn2_yt1ZMWgWqvQ9X4e8Y9-mK7mA-R76bR-OTXaPzdo7xzrC18X0vtMy2dA6")
RegisterWebhook("KILLING", "https://discordapp.com/api/webhooks/679798241088241667/dpDKmhkmlWayNUq2HA6PplEO-L72KmW91WwVzXJ7uo04yaQTuegDP52JYDXp0J59MBcO")
RegisterWebhook("CHAT", "https://discordapp.com/api/webhooks/679798010280280064/H2kxDxTgJJSCQ9S3c-NlZTXDb_8loxLVphOYFDvaIVRTh6ndY6CRDr_jaPeh6wm2JlnO")

RegisterWebhook(
    "INVENTORY",
    "https://discord.com/api/webhooks/1121786935342538852/NKnmsqpqy1F-q64L7olJXtc7wrj2R-24LI1nz_wrrXK7EozIhyUkZO8_ot313hUrAKFY",
    "ox_inventory"    
)

exports("RegisterWebhook", RegisterWebhook)

function DiscordLog(webhookKey, title, description, options)
    local options = options or {
        fields = false,
        resource = GetInvokingResource() or GetCurrentResourceName()
    }

    if(not options.resource) then
        options.resource = GetInvokingResource() or GetCurrentResourceName()
    end

    local webhookKey = webhookKey or "DEFAULT"

    local message = ""
    if(not options.fields) then
        if(type(description) == "table") then
            for k,v in pairs(description) do
                message = message..(message:len() == 0 and "" or "\n")..v
            end
        else
            message = tostring(description)
        end
    end

    if(options.fields and type(description) == "table") then
        local pairedDescription = {}
        for k,v in pairs(description) do
            if(type(v) == "table") then
                table.insert(pairedDescription, { name = v.name, value = v.value, inline = true })
            elseif(type(v) == "string") then
                table.insert(pairedDescription, { name = #pairedDescription + 1, value = tostring(v), inline = true })
            end
        end
        description = pairedDescription
    elseif(options.fields and type(description) == "string") then
        local pairedDescription = {
            { name = "#1", value = description, inline = true }
        }
        description = pairedDescription
    end

	local embedData = { {
		['title'] = title,
		['color'] = 16744192,
		['footer'] = {
			['text'] = options.resource.." - " .. os.date(),
			['icon_url'] = "https://imgur.com/szxS8N5.png"
		},
		["fields"] = options.fields and description or nil,
        ["description"] = options.fields and "" or message
		/*['author'] = {
			['name'] = "Strin",
			['icon_url'] = "https://imgur.com/cpkFrqW.gif"
		}*/
	}}

	PerformHttpRequest(Webhooks?[options.resource]?[webhookKey], nil, 'POST', json.encode({
		username = 'Logs',
		embeds = embedData
	}), {
		['Content-Type'] = 'application/json'
	})
end

exports("DiscordLog", DiscordLog)

--DiscordLog("SYSTEM", "THE RAVE PROJECT - SYSTÉM", "Discord logger zapnut.")

AddEventHandler('playerConnecting', function()
    local _source = source
    DiscordLog("SYSTEM", "THE RAVE PROJECT - SYSTÉM", GetPlayerName(_source).." se připojuje.")
end)

AddEventHandler('playerDropped', function(reason)
    local _source = source
    DiscordLog("SYSTEM", "THE RAVE PROJECT - SYSTÉM", GetPlayerName(_source).." se odpojuje. ("..reason..")")
end)

AddEventHandler("strin_jobs:onPlayerDeath", function(playerIdentifier, deathData)
	DiscordLog("KILLING", "THE RAVE PROJECT - KILL", {
		{ name = "Hráč", value = "#"..tostring(deathData.victimId).." - "..GetPlayerName(tonumber(deathData.victimId)).." - "..playerIdentifier, inline = true },
		{ name = "Příčina smrti", value = tostring(deathData.deathCause), inline = true },
		{ name = "Místo smrti", value = json.encode(deathData.deathCoords), inline = true },
		{ name = "Zabit hráčem", value = tostring(deathData.killedByPlayer).." - #"..tostring(deathData.killerServerId), inline = true }
	}, {
		fields = true,
        resource = GetCurrentResourceName()
	})
end)

AddEventHandler("strin_rpchat:chatMessage", function(source, author, message)
    LogMessage(source, author, message)
end)
AddEventHandler("chat:commandExecuted", function(source, command, message)
    LogMessage(source, GetPlayerName(source), message)
end)

function LogMessage(source, playerName, message)
    local _source = source

	for i = 0, 9 do
		message = message:gsub('%^' .. i, '')
		playerName = playerName:gsub('%^' .. i, '')
	end

    DiscordLog("CHAT", "THE RAVE PROJECT - CHAT - "..playerName.." [ID: ".._source.."]", playerName.." - "..message, {
        resource = GetCurrentResourceName()
    })
end