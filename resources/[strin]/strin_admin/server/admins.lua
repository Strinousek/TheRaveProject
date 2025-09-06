Admins = {}

AddEventHandler("esx:playerLoaded", function(playerId, xPlayer)
    if(xPlayer.getGroup() == "admin" and (not lib.table.contains(Admins, xPlayer.identifier))) then
        table.insert(Admins, xPlayer.identifier)
    end
    if(lib.table.contains(Admins, xPlayer.identifier)) then
        xPlayer.set("isAdmin", true)
    end
end)