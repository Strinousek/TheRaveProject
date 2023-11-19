SkinChanger = exports.skinchanger
IsSpectating = false

Citizen.CreateThread(function()
	ESX.FontId = RegisterFontId('Righteous')
    TriggerServerEvent("strin_admin:onPlayerJoin")
    Citizen.Wait(45000)
    while true do
        local resources = {}
        for i=0, GetNumResources() - 1 do
            table.insert(resources, GetResourceByFindIndex(i))
        end
        TriggerServerEvent("strin_admin:validateResources", resources)

        math.randomseed(GetGameTimer())
        local sleep = math.random(60000, 90000) 
        Citizen.Wait(sleep)
    end
end)

RegisterCommand("adminmenu", function()
    local isAdmin = lib.callback.await("strin_admin:isPlayerAdmin", 500)
    if(isAdmin) then
        OpenAdminMenu()
    end
end)

RegisterKeyMapping("adminmenu", "<FONT FACE='Righteous'>Admin Menu</FONT>", "keyboard", "M")

RegisterCommand("noclip", function()
    local isAdmin = lib.callback.await("strin_admin:isPlayerAdmin", 500)
    if(isAdmin) then
        NoClip()
    end
end)

RegisterKeyMapping("noclip", "<FONT FACE='Righteous'>No Clip</FONT>", "keyboard", "F7")


/*RegisterNetEvent("esx:playerLoaded", function()
    local isAdmin = lib.callback.await("strin_admin:isPlayerAdmin", 500)
    if(isAdmin) then
        ESX.RegisterInput("adminmenu", "Admin Menu", "keyboard", "M", function()
            local isAdmin = lib.callback.await("strin_admin:isPlayerAdmin", 500)
            if(isAdmin) then
                OpenAdminMenu()
            end
        end)
        ESX.RegisterInput("noclip", "Noclip", "keyboard", "F7", function()
            local isAdmin = lib.callback.await("strin_admin:isPlayerAdmin", 500)
            if(isAdmin) then
                NoClip()
            end
        end)
    end
end)*/

function OpenAdminMenu()
    local elements = {}
    table.insert(elements, { label = "Online hráči", value = "online_players"})
    table.insert(elements, { label = "Zabanovaní hráči", value = "banned_users"})

    table.insert(elements, { label = "Možnosti hráče", value = "player_options"})
    table.insert(elements, { label = "Možnosti vozidla", value = "vehicle_options"})

    table.insert(elements, { label = "Možnosti času", value = "time_options"})
    table.insert(elements, { label = "Ostatní možnosti", value = "misc_options"})

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "admin_menu", {
        title = "Admin Menu",
        align = "center",
        elements = elements,
    }, function(data, menu)
        menu.close()
        if(data.current.value == "online_players") then
            OpenOnlinePlayersMenu()
        elseif(data.current.value == "banned_users") then
            OpenBannedUsersMenu()
        elseif(data.current.value == "player_options") then
            OpenPlayerOptionsMenu()
        elseif(data.current.value == "vehicle_options") then
            OpenVehicleOptionsMenu()
        elseif(data.current.value == "time_options") then
            OpenTimeMenu()
        elseif(data.current.value == "misc_options") then
            OpenMiscMenu()
        end
    end, function(data, menu)
        menu.close()
    end)
end

function OpenBannedUsersMenu(bannedUsers, pageNumber)
    local elements = {}
    local bannedUsers = bannedUsers and bannedUsers or lib.callback.await("strin_admin:getBannedUsers", false)
    
    if(not bannedUsers or not next(bannedUsers)) then
        OpenAdminMenu()
        ESX.ShowNotification("Nejsou dostupné žádné bany.", { type = "error" })
        return
    end

    local pageSize = 8
    local pageCount = (#bannedUsers % pageSize == 0) and math.floor(#bannedUsers / pageSize) or math.ceil(#bannedUsers / pageSize + 0.5)
    if(not pageNumber) then
        pageNumber = 1
    end
    local startIndex = (pageNumber == 1) and 1 or ((pageSize * (pageNumber - 1)) + 1)
    local endIndex = pageNumber * pageSize

    if(pageNumber > 1) then
        table.insert(elements, {
            label = '<span style="color: #e74c3c"> << Předchozí stránka </span>',
            value = "previous_page"
        })
    end
    for i=startIndex, endIndex do
        local bannedUser = bannedUsers[i]
        if(bannedUser) then
            table.insert(elements, {
                label = ([[<div style="display: flex; justify-content: space-between; align-items: center;">
                    %s <div>%s</div><div>%s</div><div>%s dní</div>
                </div>]]):format(
                    bannedUser.name,
                    bannedUser.bannedOnDate,
                    bannedUser.reason:sub(1, 10),
                    bannedUser.duration == -1 and bannedUser.bannedUntilDate or bannedUser.duration
                ),
                value = i
            })
        end
    end

    if(pageNumber < pageCount) then
        table.insert(elements, {
            label = '<span style="color: #2ecc71"> Další stránka >> </span>',
            value = "next_page"
        })
    end
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "admin_menu_banned_users", {
        title = "Zabanovaní hráči",
        align = "center",
        elements = elements,
    }, function(data, menu)
        menu.close()
        if(data.current.value == "next_page") then
            OpenBannedUsersMenu(bannedUsers, pageNumber + 1)
            return
        end
        if(data.current.value == "previous_page") then
            OpenBannedUsersMenu(bannedUsers, pageNumber - 1)
            return
        end
        OpenBannedUserMenu(bannedUsers[data.current.value], function()
            OpenBannedUsersMenu(bannedUsers, pageNumber)
        end)
    end, function(data, menu)
        menu.close()
        OpenAdminMenu()
    end)
end

function OpenBannedUserMenu(bannedUser, returnCallback)
    local elements = {}
    table.insert(elements, {
        label = ([[<div style="display: flex; justify-content: space-between; align-items: center;">
            Důvod banu<div>%s</div>
        </div>]]):format(bannedUser.reason),
        value = "reason"
    })
    table.insert(elements, {
        label = ([[<div style="display: flex; justify-content: space-between; align-items: center;">
            Trvání banu<div>%s</div>
        </div>]]):format(bannedUser.duration == -1 and bannedUser.bannedUntilDate or bannedUser.duration),
        value = "duration"
    })
    table.insert(elements, { label = "<span style='color: #e74c3c;'>Odbanovat hráče</span>", value = "unban" })
    table.insert(elements, {
        label = ([[<div style="display: flex; justify-content: space-between; align-items: center;">
            Datum udělení banu<div>%s</div>
        </div>]]):format(bannedUser.bannedOnDate),
    })
    table.insert(elements, {
        label = ([[<div style="display: flex; justify-content: space-between; align-items: center;">
            Datum expirace banu<div>%s</div>
        </div>]]):format(bannedUser.bannedUntilDate),
    })
    if(next(bannedUser.identifiers)) then
        table.insert(elements, { label = "Zkopírovat identifikátory zabanovaného", value = "banned_user_identifiers" })

        for identifierKey, identifierValue in pairs(bannedUser.identifiers) do
            table.insert(elements, {
                label = ([[<div style="display: flex; justify-content: space-between; align-items: center;">
                    %s: <div>%s</div>
                </div>]]):format(
                    identifierKey:gsub("^%l", string.upper),
                    identifierValue
                ),
                value = identifierKey,
                type = "banned_user",
            })
        end
    end
    table.insert(elements, {
        label = ([[<div style="display: flex; justify-content: space-between; align-items: center;">
            Ban udělil/a<div>%s</div>
        </div>]]):format(bannedUser.bannedBy.name),
    })
    if(next(bannedUser.bannedBy.identifiers)) then
        table.insert(elements, { label = "Zkopírovat identifikátory udělitele", value = "banner_identifiers" })

        for identifierKey, identifierValue in pairs(bannedUser.bannedBy.identifiers) do
            table.insert(elements, {
                label = ([[<div style="display: flex; justify-content: space-between; align-items: center;">
                    %s: <div>%s</div>
                </div>]]):format(
                    identifierKey:gsub("^%l", string.upper),
                    identifierValue
                ),
                value = identifierKey,
                type = "banner",
            })
        end
    end
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "admin_menu_banned_user", {
        title = "Ban - "..bannedUser.name,
        align = "center",
        elements = elements,
    }, function(data, menu)
        if(data.current.value) then
            if(data.current.value == "reason") then
                menu.close()
                ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "ban_reason", {
                    title = bannedUser.reason,
                }, function(data2, menu2)
                    menu2.close()
                    TriggerServerEvent("strin_admin:updateBan", bannedUser.identifiers.license, "REASON", (data2.value or ""):len() == 0 and "Neuveden" or data2.value)
                    OpenBannedUsersMenu()
                end, function(data2, menu2)
                    menu2.close()
                    OpenBannedUserMenu(bannedUser, returnCallback)
                end)
                return
            end
            if(data.current.value == "duration") then
                menu.close()
                ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "ban_duration", {
                    title = bannedUser.duration.." (text, 0, -1 = perma)",
                }, function(data2, menu2)
                    menu2.close()
                    TriggerServerEvent("strin_admin:updateBan", bannedUser.identifiers.license, "DURATION", tonumber(data2.value or "") or -1)
                    OpenBannedUsersMenu()
                end, function(data2, menu2)
                    menu2.close()
                    OpenBannedUserMenu(bannedUser, returnCallback)
                end)
                return
            end
            if(data.current.value == "unban") then
                menu.close()
                ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "unban_reason", {
                    title = "Důvod unbanu"
                }, function(data2, menu2)
                    menu2.close()
                    ExecuteCommand(("unban %s %s"):format(bannedUser.identifiers.license, data2.value))
                    OpenBannedUsersMenu()
                end, function(data2, menu2)
                    menu2.close()
                    OpenBannedUserMenu(bannedUser, returnCallback)
                end)
                return
            end
            if(data.current.value:find("identifiers")) then
                lib.setClipboard(json.encode(data.current.value:find("banner") and bannedUser.bannedBy.identifiers or bannedUser.identifiers))
                return
            end
            if(data.current.type) then
                lib.setClipboard(data.current.type == "banner" and bannedUser.bannedBy.identifiers[data.current.value] or bannedUser.identifiers[data.current.value])
                ESX.ShowNotification("Zkopíroval/a jste identifikátor - "..data.current.value..".")
                return
            end
            OpenBannedUserMenu(bannedUser, returnCallback)
        end
    end, function(data, menu)
        menu.close()
        returnCallback()
    end)
end

function OpenOnlinePlayersMenu(players, pageNumber)
    local elements = {}
    local players = players and players or lib.callback.await("strin_admin:getOnlinePlayers", 500)
    
    local pageSize = 8
    local pageCount = (#players % pageSize == 0) and math.floor(#players / pageSize) or math.ceil(#players / pageSize + 0.5)
    if(not pageNumber) then
        pageNumber = 1
    end
    local startIndex = (pageNumber == 1) and 1 or ((pageSize * (pageNumber - 1)) + 1)
    local endIndex = pageNumber * pageSize

    if(pageNumber > 1) then
        table.insert(elements, {
            label = '<span style="color: #e74c3c"> << Předchozí stránka </span>',
            value = "previous_page"
        })
    end
    for i=startIndex, endIndex do
        local player = players[i]
        if(player) then
            table.insert(elements, {
                label = ([[<div style="display: flex; justify-content: space-between; align-items: center;">
                    %s (#%s)<div>Lokální ID: %s</div>
                </div>]]):format(
                    player.name,
                    player.id,
                    GetPlayerFromServerId(player.id)
                ),
                value = i
            })
        end
    end

    if(pageNumber < pageCount) then
        table.insert(elements, {
            label = '<span style="color: #2ecc71"> Další stránka >> </span>',
            value = "next_page"
        })
    end
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "admin_menu_online_players", {
        title = "Online hráči",
        align = "center",
        elements = elements,
    }, function(data, menu)
        menu.close()
        if(data.current.value == "next_page") then
            OpenOnlinePlayersMenu(players, pageNumber + 1)
            return
        end
        if(data.current.value == "previous_page") then
            OpenOnlinePlayersMenu(players, pageNumber - 1)
            return
        end
        OpenOnlinePlayerMenu(players[data.current.value])
    end, function(data, menu)
        menu.close()
        OpenAdminMenu()
    end)
end


RegisterNetEvent("strin_admin:getSpectateState", function()
    TriggerServerEvent("strin_admin:sendSpectateState", IsSpectating)
end)

RegisterNetEvent("strin_admin:spectate", function(targetNetId)
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end
    IsSpectating = not IsSpectating
    local targetPlayerId = GetPlayerFromServerId(targetNetId)
    if(targetPlayerId == -1) then
        while true do
            targetPlayerId = GetPlayerFromServerId(targetNetId)
            if(targetPlayerId ~= -1) then
                break
            end
            Citizen.Wait(250)
        end
    end
    local ped = PlayerPedId()
    local targetPed = GetPlayerPed(targetPlayerId)
    if(IsSpectating) then
        SetEntityAlpha(ped, 0, false)
        NetworkSetInSpectatorMode(true, targetPed)
    else
        ResetEntityAlpha(ped)
        NetworkSetInSpectatorMode(false, targetPed)
    end
end)

function OpenOnlinePlayerMenu(player)
    local elements = {}
    table.insert(elements, {
        label = ([[<div style="display: flex; justify-content: space-between; align-items: center;">
            Nick: %s<div>Server ID: %s</div><div>Lokální ID: %s</div>
        </div>]]):format(
            player.name,
            player.id,
            GetPlayerFromServerId(player.id)
        ),
        value = "xxx",
    })

    table.insert(elements, { label = "Teleportnout se k hráči", value = "teleport_to_player" })
    table.insert(elements, { label = "Teleportnout se k hráči do vozidla", value = "teleport_into_player_vehicle" })
    table.insert(elements, { label = "Vyvolat hráče k sobě", value = "summon" })
    table.insert(elements, { label = "Spectate", value = "spectate" })

    table.insert(elements, { label = "<span style='color: #e74c3c;'>Zabít hráče</span>", value = "kill" })
    table.insert(elements, { label = "<span style='color: #e74c3c;'>Zabanovat hráče (dočasně)</span>", value = "ban_temporary" })
    table.insert(elements, { label = "<span style='color: #e74c3c;'>Zabanovat hráče (permanentně)</span>", value = "ban_permanent" })

    if(next(player.identifiers)) then
        table.insert(elements, { label = "Zkopírovat identifikátory", value = "identifiers" })

        for identifierKey, identifierValue in pairs(player.identifiers) do
            table.insert(elements, {
                label = ([[<div style="display: flex; justify-content: space-between; align-items: center;">
                    %s: <div>%s</div>
                </div>]]):format(
                    identifierKey:gsub("^%l", string.upper),
                    identifierValue
                ),
                value = identifierKey,
            })
        end
    end

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "admin_menu_online_player", {
        title = "Hráč - "..player.name,
        align = "center",
        elements = elements,
    }, function(data, menu)

        if(data.current.value == "teleport_to_player") then
            TriggerServerEvent("strin_admin:teleportToPlayer", player.id, false)
            return
        end
        if(data.current.value == "teleport_into_player_vehicle") then
            TriggerServerEvent("strin_admin:teleportToPlayer", player.id, true)
            return
        end

        if(data.current.value == "spectate") then
            TriggerServerEvent("strin_admin:spectatePlayer", player.id)
            return
        end

        if(data.current.value == "summon") then
            TriggerServerEvent("strin_admin:summonPlayer", player.id)
            return
        end

        if(data.current.value == "kill") then
            TriggerServerEvent("strin_admin:killPlayer", player.id)
            return
        end

        if(data.current.value == "ban_temporary") then
            ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "ban_duration_dialog", {
                title = "Trvání banu (dny)",
            }, function(data2, menu2)
                menu2.close()
                if(data2.value == "" or not tonumber(data2.value)) then
                    OpenOnlinePlayerMenu(player)
                    ESX.ShowNotification("Neplatná hodnota!", { type = "error" })
                    return
                end
                ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "ban_reason_dialog", {
                    title = "Důvod banu",
                }, function(data3, menu3)
                    menu3.close()
                    ExecuteCommand(("ban %s %s %s"):format(player.id, tonumber(data2.value or ""), data3.value or ""))
                    --TriggerServerEvent("strin_admin:ban", player.id, tonumber(data2.value), data3.value)
                end, function(data3, menu3)
                    menu3.close()
                    OpenOnlinePlayerMenu(player)
                end)
            end, function(data2, menu2)
                menu2.close()
                OpenOnlinePlayerMenu(player)
            end)
            return
        end

        if(data.current.value == "ban_permanent") then
            ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "ban_reason_dialog", {
                title = "Důvod banu",
            }, function(data2, menu2)
                menu2.close()
                ExecuteCommand(("ban %s %s %s"):format(player.id, -1, data2.value or ""))
            end, function(data2, menu2)
                menu2.close()
                OpenOnlinePlayerMenu(player)
            end)
            return
        end

        if(data.current.value == "identifiers") then
            lib.setClipboard(json.encode(player.identifiers))
            ESX.ShowNotification("Zkopíroval/a jste identifikátory.")
            return
        end
        
        lib.setClipboard(player.identifiers[data.current.value])
        ESX.ShowNotification("Zkopíroval/a jste identifikátor - "..data.current.value..".")
    end, function(data, menu)
        menu.close()
        OpenOnlinePlayersMenu()
    end)
end

local previousSkin = nil

function OpenPlayerOptionsMenu()
    local playerId = PlayerId()
    local ped = PlayerPedId()
    local isPlayerInvincible = GetPlayerInvincible(playerId)
    local model = GetEntityModel(ped)
    local isPlayerInvisible = GetEntityAlpha(ped) == 0
    local elements = {}
    table.insert(elements, { label = ([[<div style="display: flex; justify-content: space-between; align-items: center;">
        Godmode<div>%s</div>
    </div>]]):format((isPlayerInvincible and "Ano" or "Ne")), value = "godmode"})
    table.insert(elements, { label = ([[<div style="display: flex; justify-content: space-between; align-items: center;">
        Neviditelnost<div>%s</div>
    </div>]]):format((isPlayerInvisible and "Ano" or "Ne")), value = "invisiblemode"})
    table.insert(elements, { label = "Obnovit životy ", value = "heal"})
    table.insert(elements, { label = "Obnovit armor", value = "armor"})
    table.insert(elements, { label = "Nastavit ped", value = "ped"})
    table.insert(elements, { label = "Nastavit životy", value = "set_health"})
    if((model ~= `mp_m_freemode_01` and model ~= `mp_f_freemode_01`) or previousSkin) then
        table.insert(elements, { label = "Resetnout peda", value = "reset_ped"})
    end
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "player_options_menu", {
        title = "Možnosti hráče",
        align = "center",
        elements = elements,
    }, function(data, menu)
        menu.close()
        if(data.current.value == "godmode") then
            SetEntityInvincible(cache.ped, not isPlayerInvincible)
            if(GetPlayerInvincible(cache.playerId)) then
                Citizen.CreateThread(function()
                    while GetPlayerInvincible(cache.playerId) do
                        SetEntityInvincible(cache.ped, not isPlayerInvincible)
                        Citizen.Wait(0)
                    end
                end)
            end
        elseif(data.current.value == "invisiblemode") then
            if(isPlayerInvisible) then
                SetEntityAlpha(ped, 255, false)
                --ResetEntityAlpha(ped)
            else
                SetEntityAlpha(ped, 0, false)
            end
        elseif(data.current.value == "heal") then
            SetEntityHealth(ped, GetEntityMaxHealth(ped))
        elseif(data.current.value == "set_health") then
            ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "health_dialog", {
                title = "Množství HP",
            }, function(data2, menu2)
                menu2.close()
                local health = tonumber(data2.value)
                if(not health or health < 0) then
                    OpenPlayerOptionsMenu()
                    return
                end
                SetEntityHealth(cache.ped, health + 100)
                OpenPlayerOptionsMenu()
                return
            end, function(data2, menu2)
                menu2.close()
                OpenPlayerOptionsMenu()
            end)
            return
        elseif(data.current.value == "armor") then
            SetPedArmour(ped, 100)
        elseif(data.current.value == "ped") then
            ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "ped_name_dialog", {
                title = "Název peda",
            }, function(data2, menu2)
                menu2.close()
                local hash = GetHashKey(data2.value or "")
                if(not IsModelValid(hash)) then
                    OpenPlayerOptionsMenu()
                    ESX.ShowNotification("Model neeexistuje.")
                    return
                end
                if(not previousSkin) then
                    previousSkin = SkinChanger:GetSkin()
                end
                ESX.ShowNotification("Načítám model...")
                RequestModel(hash)
                while not HasModelLoaded(hash) do
                    Citizen.Wait(0)
                end
                SetPlayerModel(playerId, hash)
                SetPedDefaultComponentVariation(PlayerPedId()) -- we need a new ped handle so
            end, function(data2, menu2)
                menu2.close()
                OpenPlayerOptionsMenu()
            end)
            return
        elseif(data.current.value == "reset_ped" and previousSkin) then
            TriggerEvent("skinchanger:loadDefaultModel", previousSkin.sex == 0, function()
                TriggerEvent("skinchanger:loadSkin", previousSkin, function()
                    previousSkin = nil
                    OpenPlayerOptionsMenu()
                end)
            end)
            return
        end

        OpenPlayerOptionsMenu()
    end, function(data, menu)
        menu.close()
        OpenAdminMenu()
    end)
end

AddEventHandler("esx:exitedVehicle", function()
    local menus = {
        ["default"] = { "vehicle_options_menu", "vehicle_mods_menu" },
        ["dialog"] = { "spawn_vehicle_dialog" }
    }
    local namespace = GetCurrentResourceName()
    for k,v in pairs(menus) do
        for i=1, #v do
            local args = { k, namespace, v[i] }
            if(ESX.UI.Menu.IsOpen(table.unpack(args))) then
                ESX.UI.Menu.Close(table.unpack(args))
            end
        end
    end
end)

local recentlySpawnedVehicle = nil

function OpenVehicleOptionsMenu()
    local elements = {}
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped)
    local vehicleState = Entity(vehicle).state
    if(vehicleState and vehicleState?.spawnedByAdmin) then
        recentlySpawnedVehicle = vehicle
    end
    if(vehicle ~= 0) then
        if(not vehicleState or not vehicleState?.spawnedByAdmin) then
            table.insert(elements, { label = "Tagnout vozidlo", value = "convert_vehicle" })
        end
        table.insert(elements, { label = ([[<div style="display: flex; justify-content: space-between; align-items: center;">
            Zdraví vozidla<div>%s/%s</div>
        </div>]]):format(math.floor(GetEntityHealth(vehicle)), math.floor(GetEntityMaxHealth(vehicle))), value = "xxx" })
        table.insert(elements, { label = "Opravit vozidlo", value = "repair_vehicle" })
        table.insert(elements, { label = "Umýt vozidlo", value = "wash_vehicle" })
        table.insert(elements, { label = "Doplnit palivo", value = "fuel_vehicle" })
        if(not IsVehicleOnAllWheels(vehicle)) then
            table.insert(elements, { label = "Otočit vozidlo", value = "flip_vehicle" })
        end
        table.insert(elements, { label = "Modifikace vozidla", value = "vehicle_mods" })
        table.insert(elements, { label = "Smazat vozidlo", value = "delete_vehicle" })
    end
    table.insert(elements, { label = ([[<div style="display: flex; justify-content: space-between; align-items: center;">
        Vehicle Spawner<div>%s</div>
    </div>]]):format(vehicle ~= 0 and " - "..GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)) or ""), value = "spawn_vehicle"})
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "vehicle_options_menu", {
        title = "Možnosti vozidla",
        align = "center",
        elements = elements,
    }, function(data, menu)
        menu.close()
        if(data.current.value == "flip_vehicle") then
            local vehicleRotation = GetEntityRotation(vehicle, 2)
            SetEntityRotation(vehicle, vehicleRotation[1], 0, vehicleRotation[3], 2, true)
            SetVehicleOnGroundProperly(vehicle)
        elseif(data.current.value == "convert_vehicle") then
            Entity(vehicle).state.spawnedByAdmin = true
        elseif(data.current.value == "wash_vehicle") then
            SetVehicleDirtLevel(vehicle, 0.0)
        elseif(data.current.value == "repair_vehicle") then
            SetVehicleFixed(vehicle)
            for i=0, 47 do
                if(DoesVehicleTyreExist(vehicle, i) and IsVehicleTyreBurst(vehicle, i)) then
                    SetVehicleTyreFixed(vehicle, i)
                end
            end
            if(not AreAllVehicleWindowsIntact(vehicle)) then
                for i=0, 7 do
                    if(not IsVehicleWindowIntact(vehicle, i)) then
                        FixVehicleWindow(vehicle, i)
                    end
                end
            end
        elseif(data.current.value == "fuel_vehicle") then
            Entity(vehicle).state.fuel = 100
        elseif(data.current.value == "spawn_vehicle") then
            ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "spawn_vehicle_dialog", {
                title = "Název modelu vozidla",
            }, function(data2, menu2)
                menu2.close()
                local hash = GetHashKey((data2.value or ""):lower())
                if(not IsModelValid(hash)) then
                    OpenVehicleOptionsMenu()
                    ESX.ShowNotification("Model neeexistuje.")
                    return
                end
                lib.callback("strin_admin:requestVehicle", false, function(vehicleNetId)
                    if(not vehicleNetId) then
                        ESX.ShowNotification("Vozidlo se nezdařilo spawnout!", { type = "error" })
                        OpenVehicleOptionsMenu()
                        return
                    end

                    if(vehicle ~= 0) then
                        DeleteEntity(vehicle)
                        recentlySpawnedVehicle = nil
                    end

                    if(not NetworkDoesEntityExistWithNetworkId(vehicleNetId)) then
                        local timer = GetGameTimer()
                        while not NetworkDoesEntityExistWithNetworkId(vehicleNetId) do
                            if((GetGameTimer() - timer) > 5000) then
                                ESX.ShowNotification("Vozidlo se nezdařilo spawnout!", { type = "error" })
                                OpenVehicleOptionsMenu()
                                return
                            end
                            Citizen.Wait(0)
                        end
                    end
                    
                    recentlySpawnedVehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
                    SetPedIntoVehicle(ped, recentlySpawnedVehicle, -1)
                    OpenVehicleOptionsMenu()
                end, hash)
            end, function(data2, menu2)
                menu2.close()
                OpenVehicleOptionsMenu()
            end)
            return
        elseif(data.current.value == "delete_vehicle") then
            DeleteEntity(vehicle)
            recentlySpawnedVehicle = nil
        elseif(data.current.value == "vehicle_mods") then
            OpenVehicleModsMenu()
            return
        end
        OpenVehicleOptionsMenu()
    end, function(data, menu)
        menu.close()
        OpenAdminMenu()
    end)
end

function OpenVehicleModsMenu()
    local vehicle = recentlySpawnedVehicle
    if(not vehicle) then
        OpenVehicleOptionsMenu()
        return
    end
    local elements = {}
    local currentTopSpeedModifier = GetVehicleTopSpeedModifier(vehicle)
    local currentTopSpeedModifier = currentTopSpeedModifier ~= -1.0 and currentTopSpeedModifier or 0
    table.insert(elements, { label = "Power Multiplier (2x)", min = 0, value = currentTopSpeedModifier ~= -1.0 and (
        currentTopSpeedModifier % 2 == 0 and
        math.floor(currentTopSpeedModifier / 2) or
        math.ceil(currentTopSpeedModifier / 2)
    ), max = 128, mod = "power_multiplier", type = "slider" })
    table.insert(elements, {
        label = "Tunning Menu",
        mod = "tunning"
    })

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "vehicle_mods_menu", {
        title = "Modifikace vozidla",
        align = "center",
        elements = elements,
    }, function(data, menu)
        menu.close()
        if(data.current.mod == "power_multiplier") then
            ModifyVehicleTopSpeed(vehicle, data.current.value == 0 and -1.0 or (data.current.value * 2.0))
        elseif(data.current.mod == "tunning") then
            exports.strin_tunning:OpenTunningMenu(function(response)
                OpenVehicleModsMenu()
            end)
            return
        end
        OpenVehicleModsMenu()
    end, function(data, menu)
        menu.close()
        OpenVehicleOptionsMenu()
    end)
end

RegisterNetEvent("strin_admin:setTime", function(hour, minute, second)
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end
    SetClockTime(hour, minute, second)
    NetworkOverrideClockTime(hour, minute, second)
end)

function OpenTimeMenu()
    local elements = {}
    local currentHour = tostring(GetClockHours())
    local currentMinute = tostring(GetClockMinutes())
    table.insert(elements, { label = ("%s:%s"):format(
        (currentHour:len() >= 2) and currentHour or ("0"..currentHour),
        (currentMinute:len() >= 2) and currentMinute or ("0"..currentMinute)
    ), value = "current_time" })
    for i=0, 23 do
        if((i == 0) or (i % 2 == 0)) then
            local hour = tostring(i)
            local hour = hour:len() >= 2 and hour or "0"..hour
            table.insert(elements, { label = ("%s:00"):format(hour), value = hour })
        end
    end
    table.insert(elements, { label = "Nastavit vlastní čas", value = "set_time" })
    local namespace = GetCurrentResourceName()
    ESX.UI.Menu.Open("default", namespace, "time_menu", {
        title = "Nastavení času",
        align = "center",
        elements = elements,
    }, function(data, menu)
        menu.close()
        if(tonumber(data.current.value)) then
            local hour = tonumber(data.current.value)
            local minute = 0
            TriggerServerEvent("strin_admin:setTime", hour, minute)
            Citizen.Wait(250) -- keko?
        elseif(data.current.value == "set_time") then
            ESX.UI.Menu.Open("dialog", namespace, "time_hour_dialog", {
                title = "Hodiny"
            }, function(data2, menu2)
                local hour = tonumber(data2.value)
                if(not hour) then
                    OpenTimeMenu()
                    return
                end
                ESX.UI.Menu.Open("dialog", namespace, "time_minute_dialog", {
                    title = "Minuty"
                }, function(data3, menu3)
                    local minute = tonumber(data3.value)
                    if(not minute) then
                        OpenTimeMenu()
                        return
                    end
                    TriggerServerEvent("strin_admin:setTime", hour, minute)
                    Citizen.Wait(250) -- keko n.o2?
                    OpenTimeMenu()
                end, function(data3, menu3)
                    menu3.close()
                    OpenTimeMenu()
                end)
            end, function(data2, menu2)
                menu2.close()
                OpenTimeMenu()
            end)
            Citizen.Wait(250) -- keko n.o2?
            return
        end
        OpenTimeMenu()
    end, function(data, menu)
        menu.close()
        OpenAdminMenu()
    end)
end

local PlayerNamesRange = 0
local DisplayCoords = false
local DebugEntityOnAim = false

/*
    0 = none
    1 = vehicles
    2 = props
    3 = peds
    4 = all
*/
local DrawDimensionsType = 0

function OpenMiscMenu()
    local elements = {}
    table.insert(elements, { label = "Hráčské jmenovky (OFF, n * 32)", min = 0, value = PlayerNamesRange, max = 12, key = "player_names", type = "slider"})
    table.insert(elements, { label = "Koordinace (OFF, ON)", min = 0, value = ((not DisplayCoords) and 0 or 1), max = 1, key = "display_coords", type = "slider"})

    if(GetFirstBlipInfoId(8) ~= 0) then
        table.insert(elements, { label = "Teleport k waypointu", key = "teleport_to_waypoint" })
    end

    table.insert(elements, { label = "Teleport ke koordinacím (X,Y,Z)", key = "teleport_to_coords" })
    table.insert(elements, { label = "Teleport ke koordinacím (VECTOR)", key = "teleport_to_coords_vector" })

    table.insert(elements, { label = "Zkopírovat koordinace", key = "clipboard_coords" })
    table.insert(elements, { label = "Entity AIM Debug (OFF, ON)", min = 0, value = ((not DebugEntityOnAim) and 0 or 1), max = 1, key = "debug_entity_on_aim", type = "slider"})

    table.insert(elements, { label = "R* - Record", key = "record" })
    table.insert(elements, { label = "R* - Save Clip", key = "save_clip" })
    table.insert(elements, { label = "R* - Delete Clip", key = "delete_clip" })
    table.insert(elements, { label = "R* - Editor", key = "editor" })
    --table.insert(elements, { label = "Entity Debug (OFF, VEH, PROP, PED, ALL)", min = 0, value = DrawDimensionsType, max = 4, key = "show_dimensions_type", type = "slider"})
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "misc_menu", {
        title = "Ostatní možnosti",
        align = "center",
        elements = elements,
    }, function(data, menu)
        if(data.current.key == "record") then
            StartRecording(1)
            return
        elseif(data.current.key == "save_clip") then
            StartRecording(0)
            return
        elseif(data.current.key == "delete_clip") then
            StopRecordingAndDiscardClip()
            return
        elseif(data.current.key == "editor") then
            NetworkSessionLeaveSinglePlayer()
            ActivateRockstarEditor()
            return
        end
        menu.close()
        if(data.current.key == "teleport_to_waypoint") then
            TeleportToMarker()
        elseif(data.current.key == "teleport_to_coords") then
            ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "misc_coords_x_menu", {
                title = "Koordinace X"
            }, function(data2, menu2)
                menu2.close()
                local x = tonumber(data2.value)
                if(not x) then
                    OpenMiscMenu()
                    return
                end
                ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "misc_coords_y_menu", {
                    title = "Koordinace Y"
                }, function(data3, menu3)
                    menu3.close()
                    local y = tonumber(data3.value)
                    if(not y) then
                        OpenMiscMenu()
                        return
                    end
                    ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "misc_coords_z_menu", {
                        title = "Koordinace Z"
                    }, function(data4, menu4)
                        menu4.close()
                        local z = tonumber(data4.value)
                        local ped = PlayerPedId()
                        local vehicle = GetVehiclePedIsIn(ped)
                        if(not z) then
                            FindZCoord({ x = x, y = y})
                            --Teleport(vehicle ~= 0 and vehicle or nil, x, y, z)
                            return
                        end
                        local heading = GetEntityHeading(ped)
                        StartPlayerTeleport(PlayerId(), x, y, z, heading, vehicle ~= 0, vehicle ~= 0, true)
                        ESX.ShowNotification("Zahajuju přemisťování...")
                    end, function(data4, menu4)
                        menu4.close()
                        OpenMiscMenu()
                    end)
                end, function(data2, menu2)
                    menu3.close()
                    OpenMiscMenu()
                end)
            end, function(data2, menu2)
                menu2.close()
                OpenMiscMenu()
            end)
            return
        elseif(data.current.key == "teleport_to_coords_vector") then
            ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "teleport_vector_dialog", {
                title = "vector3(x,y,z) / vec3(x,y,z)"
            }, function(data2, menu2)
                menu2.close()
                local value = data2.value
                local x,y,z = ParseCoordinatesFromVectorString(value)
                if(not x) then
                    OpenMiscMenu()
                    ESX.ShowNotification("Špatné jste zadal/a souřadnice!", { type = "error" })
                    return
                end
                local ped = PlayerPedId()
                local vehicle = GetVehiclePedIsIn(ped)
                local heading = GetEntityHeading(ped)
                StartPlayerTeleport(PlayerId(), x, y, z, heading, vehicle ~= 0, vehicle ~= 0, true)
                ESX.ShowNotification("Zahajuju přemisťování...")
                OpenMiscMenu()
            end, function(data2, menu2)
                menu2.close()
                OpenMiscMenu()
            end)
            return
        elseif(data.current.key == "clipboard_coords") then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local roundedCoords = {}
            for k,v in pairs(coords) do
                roundedCoords[k == 1 and "x" or ((k == 2) and "y" or ((k == 3) and "z" or nil))] = (math.floor((v * (10 ^ 2)) + 0.5) / (10 ^ 2))
            end
            local stringifiedCoords = ("vector3(%s, %s, %s)"):format(roundedCoords.x, roundedCoords.y, roundedCoords.z)
            lib.setClipboard(stringifiedCoords)
            ESX.ShowNotification("Souřadnice: "..stringifiedCoords)
        end
        OpenMiscMenu()
    end, function(data, menu)
        menu.close()
        OpenAdminMenu()
    end, function(data, menu)
        if(data.current.key == "player_names") then
            PlayerNamesRange = data.current.value
        elseif(data.current.key == "display_coords") then
            DisplayCoords = data.current.value == 1 and true or false
        elseif(data.current.key == "debug_entity_on_aim") then
            DebugEntityOnAim = data.current.value == 1 and true or false
        elseif(data.current.key == "show_dimensions_type") then
            DrawDimensionsType = data.current.value
        end
    end)
end

local CachedPlayerNames = {}

function ParseCoordinatesFromVectorString(vectorString)
    local openingParantheseIndex = vectorString:find("%(")
    local closingParantheseIndex = vectorString:find("%)")
    if(not openingParantheseIndex or not closingParantheseIndex) then
        return nil
    end
    local vectorValues = vectorString:sub(openingParantheseIndex + 1, closingParantheseIndex - 1):gsub("%s+", "")
    local function getNextValue()
        if(not vectorValues:find(",") and not (vectorValues:len() > 0)) then
            return nil
        end
        local value = vectorValues:sub(1, (vectorValues:find(",") and vectorValues:find(",") - 1 or vectorValues:len()))
        vectorValues = vectorValues:gsub(value..",", "")
        return value
    end
    local coords = {}
    for i=1, 3 do

        local value = tonumber(getNextValue())
        if(not value) then
            return nil
        end
        
        coords[i] = value
    end
    return table.unpack(coords)
end

local function RoundNumber(num, decimalPlaces)
    local roundedNumber = 0
    if(decimalPlaces) then
        local power = 10 ^ tonumber(decimalPlaces)
        return math.floor((num * power) + 0.5) / power
    else
        return math.floor(num + 0.5)
    end
    return roundedNumber
end

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        if(PlayerNamesRange > 0 or DisplayCoords or DrawDimensionsType > 0 or DebugEntityOnAim) then
            sleep = 0
            local ped = cache.ped
            local coords = GetEntityCoords(ped)
            if(PlayerNamesRange > 0) then
                local players = GetActivePlayers()
                for _,playerId in pairs(players) do
                    local ped = GetPlayerPed(playerId)
                    local serverId = GetPlayerServerId(playerId)
                    if(not CachedPlayerNames[serverId]) then
                        CachedPlayerNames[serverId] = "#"..serverId.." - "..ESX.SanitizeString(GetPlayerName(playerId))
                    end
                    local playerCoords = GetEntityCoords(ped)
                    local distanceToPlayer = #(coords - playerCoords)
                    if(distanceToPlayer < (PlayerNamesRange * 32)) then
                        DrawText3D(playerCoords + vector3(0, 0, 1.0), CachedPlayerNames[serverId])
                    end
                end
            end
            if(DrawDimensionsType > 0) then
                ModelDrawDimensions(coords)
            end
            if(DebugEntityOnAim) then
                local hit, entity = GetEntityPlayerIsFreeAimingAt(cache.playerId)
                if(hit) then
                    local message = "Entity Handle: %s | Hash: %s | Model: %s | Net. Owner: %s | Entity Type: %s"
                    DrawText3D(GetEntityCoords(entity), message:format(
                        entity,
                        GetEntityModel(entity),
                        GetEntityArchetypeName(entity),
                        NetworkGetEntityOwner(entity),
                        entityType
                    ))
                end
            end
            if(DisplayCoords) then
                local heading = GetEntityHeading(ped)
                local text = ("X: %s\nY: %s\nZ: %s\nH: %s"):format(
                    RoundNumber(coords.x, 2),
                    RoundNumber(coords.y, 2),
                    RoundNumber(coords.z, 2),
                    RoundNumber(heading, 2)
                )
                DrawText3D(coords, text)
            end
        end
        Citizen.Wait(sleep)
    end
end)

function DrawText3D(coords, text)
    local vector = type(coords) == "vector3" and coords or vec(coords.x, coords.y, coords.z)

    local camCoords = GetFinalRenderedCamCoord()
    local distance = #(vector - camCoords)
    local size = 0.75 

    local scale = (size / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    SetTextScale(0.0 * scale, 0.55 * scale)
    SetTextFont(ESX.FontId)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    BeginTextCommandDisplayText('STRING')
    SetTextCentre(true)
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(vector.xyz, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

local LastCoords
function TeleportToMarker()
    local coords = GetBlipInfoIdCoord(GetFirstBlipInfoId(8))

    DoScreenFadeOut(100)
    Wait(100)

    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped)
    --LastCoords = GetEntityCoords(ped)

    FreezePlayer(true, vehicle)

    local z = FindZCoord(coords)
    Teleport(vehicle ~= 0 and vehicle or nil, coords.x, coords.y, z)

    SetGameplayCamRelativeHeading(0)
    Wait(500)
    FreezePlayer(false, vehicle)
    DoScreenFadeIn(750)
end

function FindZCoord(coords, lastCoords)
    local foundZ = nil
    local z = GetHeightmapBottomZForPosition(coords.x, coords.y)
    local inc = 1.0 + 0.0

    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped)
    while z < 800.0 do
        local found, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, z, true)
        local int = GetInteriorAtCoords(coords.x, coords.y, z)

        if found or int ~= 0 then
            if int ~= 0 then
                local _, _, z = GetInteriorPosition(int)
                groundZ = z
            end

            foundZ = groundZ
            return foundZ
        end

        foundZ = z
        Teleport(vehicle ~= 0 and vehicle or nil, coords.x, coords.y, z)
        Citizen.Wait(0)

        z += inc
    end
    if(lastCoords) then
        Teleport(vehicle ~= 0 and vehicle or nil, lastCoords.x, lastCoords.y, lastCoords.z)
    end
    return z
end

function Teleport(vehicle, x, y, z)
    local ped = PlayerPedId()
    if vehicle then
        return SetPedCoordsKeepVehicle(ped, x, y, z)
    end

    SetEntityCoords(ped, x, y, z, false, false, false, false)
end

function FreezePlayer(state, vehicle)
    local playerId, ped = PlayerId(), PlayerPedId()
    vehicle = vehicle

    SetPlayerInvincible(playerId, state)
    FreezeEntityPosition(ped, state)
    SetEntityCollision(ped, not state, true)

    if vehicle then
        if not state then
            SetVehicleOnGroundProperly(vehicle)
        end

        FreezeEntityPosition(vehicle, state)
        SetEntityCollision(vehicle, not state, true)
    end
end

/*
function GetEntityBoundingBox(entity)
    local min, max = GetModelDimensions(GetEntityModel(entity))
    local pad = 0.001
    return {
        -- Bottom
        GetOffsetFromEntityInWorldCoords(entity, min.X - pad, min.Y - pad, min.Z - pad),
        GetOffsetFromEntityInWorldCoords(entity, max.X + pad, min.Y - pad, min.Z - pad),
        GetOffsetFromEntityInWorldCoords(entity, max.X + pad, max.Y + pad, min.Z - pad),
        GetOffsetFromEntityInWorldCoords(entity, min.X - pad, max.Y + pad, min.Z - pad),

        -- Top
        GetOffsetFromEntityInWorldCoords(entity, min.X - pad, min.Y - pad, max.Z + pad),
        GetOffsetFromEntityInWorldCoords(entity, max.X + pad, min.Y - pad, max.Z + pad),
        GetOffsetFromEntityInWorldCoords(entity, max.X + pad, max.Y + pad, max.Z + pad),
        GetOffsetFromEntityInWorldCoords(entity, min.X - pad, max.Y + pad, max.Z + pad)
    }
end

function DrawBoundingBox(box, r, g, b, a)
    local polyMatrix = GetBoundingBoxPolyMatrix(box)
    local edgeMatrix = GetBoundingBoxEdgeMatrix(box)

    DrawPolyMatrix(polyMatrix, r, g, b, a)
    DrawEdgeMatrix(polyMatrix, 255, 255, 255, 255)
end

function GetBoundingBoxPolyMatrix(box)
    return {
        vector3( box[2], box[1], box[0] ),
        vector3( box[3], box[2], box[0] ),

        vector3( box[4], box[5], box[6] ),
        vector3( box[4], box[6], box[7] ),

        vector3( box[2], box[3], box[6] ),
        vector3( box[7], box[6], box[3] ),

        vector3( box[0], box[1], box[4] ),
        vector3( box[5], box[4], box[1] ),

        vector3( box[1], box[2], box[5] ),
        vector3( box[2], box[6], box[5] ),

        vector3( box[4], box[7], box[3] ),
        vector3( box[4], box[3], box[0] )
    }
end

function GetBoundingBoxEdgeMatrix(box)
    return {
        vector3( box[0], box[1] ),
        vector3( box[1], box[2] ),
        vector3( box[2], box[3] ),
        vector3( box[3], box[0] ),

        vector3( box[4], box[5] ),
        vector3( box[5], box[6] ),
        vector3( box[6], box[7] ),
        vector3( box[7], box[4] ),

        vector3( box[0], box[4] ),
        vector3( box[1], box[5] ),
        vector3( box[2], box[6] ),
        vector3( box[3], box[7] )
    }
end

function DrawPolyMatrix(polyCollection, r, g, b, a)
    for i=1, #polyCollection do
        local poly = polyCollection[i]
        local x1 = poly[0].x
        local y1 = poly[0].y
        local z1 = poly[0].z

        local x2 = poly[1].x
        local y2 = poly[1].y
        local z2 = poly[1].z

        local x3 = poly[2].x
        local y3 = poly[2].y
        local z3 = poly[2].z
        DrawPoly(x1, y1, z1, x2, y2, z2, x3, y3, z3, r, g, b, a)
    end
end

function DrawEdgeMatrix(linesCollection, r, g, b, a)
    for i=1, #linesCollection do
        local line = linesCollection[i]
        local x1 = line[0].x
        local y1 = line[0].y
        local z1 = line[0].z

        local x2 = line[1].x
        local y2 = line[1].y
        local z2 = line[1].z

        DrawLine(x1, y1, z1, x2, y2, z2, r, g, b, a)
    end
end

function DrawEntityBoundingBox(entity, r, g, b, a)
    local box = GetEntityBoundingBox(entity)
    DrawBoundingBox(box, r, g, b, a)
end
*/

local recentlyDrawed = false
function ModelDrawDimensions(playerCoords)
    if(DrawDimensionsType > 0) then
        local entities = {}
        if(DrawDimensionsType == 1 or DrawDimensionsType == 5) then
            local vehicles = GetGamePool("CVehicle")
            for i=1, #vehicles do
                table.insert(entities, vehicles[i])
            end
        end
        if(DrawDimensionsType == 2 or DrawDimensionsType == 5) then
            local objects = GetGamePool("CObject")
            for i=1, #objects do
                table.insert(entities, objects[i])
            end
        end
        if(DrawDimensionsType == 3 or DrawDimensionsType == 5) then
            local peds = GetGamePool("CPed")
            for i=1, #peds do
                table.insert(entities, peds[i])
            end
        end

        for i=1, #entities do
            local entity = entities[i]
            local entityCoords = GetEntityCoords(entity)
            if(#(playerCoords - entityCoords) > 5) then
                SetEntityDrawOutline(entity, false)
                goto skipLoop
            end
            local message = "Entity Handle: %s | Hash: %s | Model: %s | Net. Owner: %s | Entity Type: %s"
            local entityType = GetEntityType(entity)
            local r, g, b = 250, 150, 0
            if(entityType == 1) then
                r, g, b = 50, 255, 50
            elseif(entityType == 3) then
                r, g, b = 255, 0, 0
            end
            recentlyDrawed = true
            SetEntityDrawOutline(entity, true)
            SetEntityDrawOutlineColor(r, g, b, 255)
            --local drawingSettings = entityType == 2 and { 250, 150, 0 } or (entityType == 1 and { 50, 255, 50 } or (entityType == 3 and { 255, 0, 0 }))
            --DrawEntityBoundingBox(entity, table.unpack(drawingSettings), 100)
            DrawText3D(GetEntityCoords(entity), message:format(
                entity,
                GetEntityModel(entity),
                GetEntityArchetypeName(entity),
                NetworkGetEntityOwner(entity),
                entityType
            ))
            ::skipLoop::
        end
    else
        if(recentlyDrawed) then
            recentlyDrawed = false
        end
    end
end