RegisterNetEvent('mythic_notify:client:SendAlert')
AddEventHandler('mythic_notify:client:SendAlert', function(data)
	Normal(data.type, data.text)
end)

RegisterNetEvent('strin_notify:notify')
AddEventHandler('strin_notify:notify', function(data)
	Normal(data.type, data.text)
end)

RegisterNetEvent('strin_notify:long_notify')
AddEventHandler('strin_notify:long_notify', function(data)
	Long(data.type, data.text)
end)

RegisterNetEvent('strin_notify:short_notify')
AddEventHandler('strin_notify:short_notify', function(data)
	Short(data.type, data.text)
end)

RegisterNetEvent('strin_notify:custom_notify')
AddEventHandler('strin_notify:custom_notify', function(data)
	Custom(data.type, data.text or data.description or data.title, data.length or data.duration)
end)

--[[RegisterCommand('notify', function()
	Normal('green', 'This is a normal green / successful notification.')
	Citizen.Wait(2000)
	Short('neutral', 'This is a short blue / informal notification.')
	Citizen.Wait(500)
	Long('red', 'This is a long red / error notification.')
end)]]

--[[ESX.ShowNotification = function(msg, title, typ)
	if title == nil then
		title = ""
	end
	if typ == nil then
		typ = 'neutral'
	elseif typ == 'neutral' or typ == 'inform' then
		typ = 'neutral'
	elseif typ == 'red' or typ == 'error' then
		typ = 'red'
	elseif typ == 'green' or typ == 'success' then
		typ = 'green'
	end	
    exports['dev_ui']:Text(typ, title.. '' ..msg)		
end

ESX.ShowAdvancedNotification = function(title, subject, msg, icon, iconType, typ)
	if typ == nil then
		typ = 'neutral'
	end
	if title == nil then
		title = ""
	end
	if subject == nil then
		subject = ""
	end		
    exports['dev_ui']:Text(typ, '<b>'.. title .. '</b> - '.. subject ..'<br>' .. msg)			
end]]

function Short(type, text)
	local finalText = CleanStringFromSyntaxes(text)
	SendNUIMessage({
		action = 'short',
		type = GetNotificationType(type),
		text = finalText,
		length = 2000
	})
end

function Normal(type, text)
	local finalText = CleanStringFromSyntaxes(text)
	SendNUIMessage({
		action = 'normal',
		type = GetNotificationType(type),
		text = finalText,
		length = 3500
	})
end

function Long(type, text)
	local finalText = CleanStringFromSyntaxes(text)
	SendNUIMessage({
		action = 'long',
		type = GetNotificationType(type),
		text = finalText,
		length = 5000
	})
end

function Custom(type, text, length)
	local finalText = CleanStringFromSyntaxes(text)
	SendNUIMessage({
		action = 'custom',
		type = GetNotificationType(type),
		text = finalText,
		length = length
	})
end

function CleanStringFromSyntaxes(str)
	local replacements = {
		['~w~'] = '',
		['~y~'] = '',
		['~r~'] = '',
		['~g~'] = '',
		['~o~'] = '',
		['~p~'] = '',
		['~b~'] = '',
		['~c~'] = '',
		['~s~'] = '',
		['~h~'] = '',
		['~u~'] = '',
		['~m~'] = '',
		['~n~'] = '',
	  }
  
	for k, v in pairs(replacements) do
	  str = str:gsub("%"..k, v)
	end
  
	return str
end

function GetNotificationType(recType)
	local type = 'neutral'
	if recType == nil then
		type = 'neutral'
	elseif recType == 'neutral' or recType == 'inform' or recType == "info" then
		type = 'neutral'
	elseif recType == 'red' or recType == 'error' or recType == "warning" then
		type = 'red'
	elseif recType == 'green' or recType == 'success' then
		type = 'green'
	end	
	return type
end