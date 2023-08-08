RegisterNetEvent('esx_addons_gcphone:call')
AddEventHandler('esx_addons_gcphone:call', function(data)
  local playerPed   = PlayerPedId()
  local coords      = GetEntityCoords(playerPed)
  local message     = nil
  local number      = data.number
  ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "gcphone_new_message", {
    title = "Zpráva"
  }, function(data, menu)
    message = data.value or ""
    menu.close()
  end, function(data, menu)
    message = ""
    menu.close()
  end)
  while message == nil do
    Citizen.Wait(0)
  end
  if message ~= nil and message ~= "" then
    TriggerServerEvent('esx_addons_gcphone:startCall', number, message, {
      x = coords.x,
      y = coords.y,
      z = coords.z
    })
  end
end)
