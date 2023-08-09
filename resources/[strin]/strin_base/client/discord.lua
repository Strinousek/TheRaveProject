local MaxOnlinePlayers = GetConvarInt("sv_maxclients", 64)
local DiscordSet = false

RegisterNetEvent('strin_scoreboard:updatePlayers', function(players)
    local serverId = GetPlayerServerId(PlayerId())
    local name = "Unknown"
    local CurrentOnlinePlayersCount = 0
    for k,v in pairs(players) do
        if(v) then
            if(v?.id == serverId) then
                name = v?.name
            end
            CurrentOnlinePlayersCount += 1
        end
    end
    if(not DiscordSet) then
        while not DiscordSet do
            Citizen.Wait(0)
        end
    end
    SetDiscordAppId(1135562897905426452)
    SetDiscordRichPresenceAssetSmallText(("%s #%s | %s/%s"):format(
        name,
        serverId,
        CurrentOnlinePlayersCount,
        MaxOnlinePlayers
    ))
end)

Citizen.CreateThread(function()
	while true do
        if(not DiscordSet) then
            SetDiscordAppId(1135562897905426452)
            SetDiscordRichPresenceAsset('the_rave_project_big')
            SetDiscordRichPresenceAssetText('The Rave Project')
            SetDiscordRichPresenceAssetSmall('the_rave_project')
            SetDiscordRichPresenceAssetSmallText('Inicializace...')
            SetDiscordRichPresenceAction(0, "Discord", "https://discord.gg/MkNBdbRRmU")
            DiscordSet = true
        end
        if(DiscordSet) then
            break
        end
        Citizen.Wait(60000)
	end
end)

AddEventHandler("onResourceStart", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        if(not DiscordSet) then
            while not DiscordSet do
                Citizen.Wait(0)
            end
        end
        if(DiscordSet) then
            TriggerServerEvent("strin_scoreboard:requestUpdatePlayers")
        end
    end
end)