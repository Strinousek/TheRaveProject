function TchatGetMessageChannel (channel, cb)
    MySQL.query("SELECT * FROM phone_app_chat WHERE `channel` = ? ORDER BY time DESC LIMIT 100", {
      channel
    }, cb)
end

function TchatAddMessage (channel, message)
  local Query = "INSERT INTO phone_app_chat SET `channel` = ?, `message` = ?"
  local Query2 = 'SELECT * from phone_app_chat WHERE `id` = ?'
  local insertId = MySQL.insert.await(Query, {
    channel,
    message
  })
  local result = MySQL.query.await(Query2, { insertId } )
  TriggerClientEvent('gcPhone:tchat_receive', -1, result[1])
end


RegisterServerEvent('gcPhone:tchat_channel')
AddEventHandler('gcPhone:tchat_channel', function(channel)
  local sourcePlayer = tonumber(source)
  TchatGetMessageChannel(channel, function (messages)
    TriggerClientEvent('gcPhone:tchat_channel', sourcePlayer, channel, messages)
  end)
end)

local TChatCooldowns = {}

RegisterServerEvent('gcPhone:tchat_addMessage')
AddEventHandler('gcPhone:tchat_addMessage', function(channel, message)
  local _source = tonumber(source)
  if(_source) then
      if(TChatCooldowns[_source]) then
        TriggerClientEvent("esx:showNotification", _source, "Nemůžete posílat zprávy tak rychle!", { type = "error" })
        return
      end
  end
  TchatAddMessage(channel, ESX.SanitizeString(message))
  if(_source) then
    TChatCooldowns[_source] = true
    SetTimeout(1500, function()
      if(TChatCooldowns[_source]) then
        TChatCooldowns[_source] = nil
      end
    end)
  end
end)

AddEventHandler("playerDropped", function()
  local _source = source
  if(not TChatCooldowns[_source]) then
    return
  end
  TChatCooldowns[_source] = nil
end)