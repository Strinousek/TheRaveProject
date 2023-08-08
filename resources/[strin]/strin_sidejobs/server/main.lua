Base = exports.strin_base
Inventory = exports.ox_inventory 

/*  
    {
        [playerId] = {
            type = "TAXI"
        }
    }
*/
WorkingPlayers = {}

Base:RegisterWebhook("DEFAULT", "https://discord.com/api/webhooks/888188024091975730/2e6qgYNKMw0MJSq5MI6TMWA3ar8cWAu74-UDjb8iIJMeb1yb672vTJmvO4NO2G8Hfztd")

/*Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2000)
        print(json.encode(WorkingPlayers, { indent = true }))
    end
end)*/

/*function SetupSideJobModule(name)
    local name = name:gsub("^%l", string.upper)
    local setupString = UpdateStringWithPlaceholders([[
        local _Active:SideJobModule:s = {}

        Active:SideJobModule:s = setmetatable({}, {
            __index = function(_, k)
                return _Active:SideJobModule:s[k]
            end,
            __newindex = function(_, k, v)
                if(v and not WorkingPlayers[k]) then
                    WorkingPlayers[k] = {
                        type = :SideJobModuleLower:,
                    }
                elseif(not v and WorkingPlayers[k]) then
                    WorkingPlayers[k] = nil
                end
                _Active:SideJobModule:s[k] = v
            end,
        })
    
    ]], {
        ["SideJobModule"] = name,
        ["SideJobModuleLower"] = name:lower()
    })
    print(setupString)
    return load(setupString)()
end

function UpdateStringWithPlaceholders(text, placeholders)
    local text = text
    for k,v in pairs(placeholders) do
        text:gsub("%:"..k.."%:", v)
    end
    return text
end*/

ESX.RegisterCommand("cancelsidejob", "user", function(xPlayer)
    local _source = xPlayer.source
    if(not WorkingPlayers[_source]) then
        xPlayer.showNotification("Nejste v seznamu")
        return
    end
    TriggerClientEvent("strin_sidejobs:cancelSideJob", _source, WorkingPlayers[_source].type)
end)

lib.callback.register("strin_sidejobs:canBorrowVehicle", function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return false
    end
    
    local money = xPlayer.getMoney()
    if((money - JOB_CENTER_VEHICLE_BORROW_PRICE) < 0) then
        xPlayer.showNotification("Nemáte tolik peněz!", { type = "error" })
        return false
    end

    local items = Inventory:GetInventoryItems(_source)
    local hasAxe = false
    for k,v in pairs(items) do
        if(v.name:find("WEAPON_")) then
            local weaponHash = GetHashKey(v.name)
            if(lib.table.contains(LUMBERJACK_LOG_AXES, weaponHash)) then
                hasAxe = true
                break
            end
        end
    end

    if(not hasAxe) then
        xPlayer.showNotification("Nemáte sekeru na kácení stromů! Zajděte si jí nejprve koupit!", { type = "error" })
        return false
    end

    xPlayer.removeMoney(JOB_CENTER_VEHICLE_BORROW_PRICE)
    xPlayer.showNotification(("Zaplatil/a jste zálohu vozidla - %s$"):format(ESX.Math.GroupDigits(JOB_CENTER_VEHICLE_BORROW_PRICE)))
    return true
end)

function GenerateSideJobModule(sideJobModuleName, privateTable, onInitCommand, onCancelCommand)
    local sideJobModuleName = sideJobModuleName:lower()
    if(onInitCommand) then
        ESX.RegisterCommand(sideJobModuleName, "user", onInitCommand)
    end
    if(onCancelCommand) then
        ESX.RegisterCommand("cancel"..sideJobModuleName, "user", onCancelCommand)
    end
    return setmetatable({}, {
        __index = function(t, k)
            return privateTable[k]
        end,
        __newindex = function(t, k, v)
            if(v and not WorkingPlayers[k]) then
                WorkingPlayers[k] = {
                    type = sideJobModuleName,
                }
            elseif(not v and WorkingPlayers[k]) then
                WorkingPlayers[k] = nil
            end
            privateTable[k] = v
        end,
        __pairs = function(t)
            return next, privateTable, nil
        end
    })
end