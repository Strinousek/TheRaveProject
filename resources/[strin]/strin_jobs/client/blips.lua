local CachedBlips = {}

/*
    [1] = {
        blip = 1111,
        playerId = 1,
        distant = false,
        fullname = "Abraham Lincoln",
        job = "police",
        coords = vector3(0, 0, 0)
    }
*/

local playerSpawned = false
local blipsSetup = false
AddEventHandler("esx:onPlayerSpawn", function()
    playerSpawned = true
end)

function CountValidBlips(blips)
    local validBlips = 0
    for i=1, #blips do
        if(blips[i]) then
            validBlips += 1
        end
    end
    return validBlips
end

RegisterNetEvent("strin_jobs:updateBlips", function(blips)
    --[[if(not blipsSetup or (blipsSetup and next(CachedBlips) and not next(blips))) then
        SetBigmapActive(true, false)
        DisplayPlayerNameTagsOnBlips(true)
        blipsSetup = true
    end]]

    if(CountValidBlips(blips) == 0) then
        for i=1, #CachedBlips do
            local v = CachedBlips[i]
            if(v) then
                if(DoesBlipExist(v.blip)) then
                    RemoveBlip(v.blip)
                end
            end
        end
        CachedBlips = {}
        return
    end
    
    for i=1, #blips do
        local blip = blips[i]
        local cachedBlip = CachedBlips[i]
        if(cachedBlip and not blip) then
            if(DoesBlipExist(cachedBlip.blip)) then
                RemoveBlip(cachedBlip.blip)
            end
            CachedBlips[i] = false
            goto skipLoop
        end
        if(not cachedBlip and blip) then
            if(blip.playerId == cache.serverId and not playerSpawned) then
                CachedBlips[i] = false
                goto skipLoop
            end
            if(GetPlayerFromServerId(blip.playerId) == -1) then
                blip.distant = true
            else
                blip.distant = false
            end
            CachedBlips[i] = blip
            CachedBlips[i].blip = CreateJobBlip(blip)
            goto skipLoop
        end
        if(cachedBlip and blip) then
            if(GetPlayerFromServerId(blip.playerId) == -1) then
                blip.distant = true
            else
                blip.distant = false
            end
            cachedBlip.coords = blip.coords
            if((not blip.distant and cachedBlip.distant) or (blip.distant and not cachedBlip.distant)) then 
                if(DoesBlipExist(cachedBlip.blip)) then
                    RemoveBlip(cachedBlip.blip)
                    cachedBlip.blip = nil
                end
                cachedBlip.blip = CreateJobBlip(blip)
                goto skipLoop
            end
            if(cachedBlip.distant and blip.distant) then
                UpdateJobBlip(cachedBlip.blip, blip)
                goto skipLoop
            end
        end
        if(not cachedBlip and not blip) then
            CachedBlips[i] = false
            goto skipLoop
        end
        ::skipLoop::
    end
end)

function CreateJobBlip(data)
    local blip = (data.distant) and AddBlipForCoord(data.coords) or AddBlipForEntity(GetPlayerPed(GetPlayerFromServerId(data.playerId)))
	SetBlipDisplay(blip, 2)
	SetBlipSprite(blip, Jobs[data.job].Blips.sprite)
	SetBlipScale(blip, Jobs[data.job].Blips.scale or 1.0)
	SetBlipColour(blip, Jobs[data.job].Blips.colour)
    if(not data.distant) then
        if(Jobs[data.job].Blips.showCone == nil) then
            SetBlipShowCone(blip, true)
        else
            SetBlipShowCone(blip, Jobs[data.job].Blips.showCone)
        end
    end
    SetBlipFlashes(blip, false)
    SetBlipShrink(blip, true)
	BeginTextCommandSetBlipName("STRING")
    --DisplayPlayerNameTagsOnBlips(true)
    AddTextComponentString("<FONT FACE='Righteous'>"..(
        Jobs?[data?.job]?.Blips?.prefix and Jobs?[data?.job]?.Blips?.prefix.." " or ""
    )..data.fullname.."</FONT>")
	EndTextCommandSetBlipName(blip)
    SetBlipCategory(blip, 7)
    return blip
end

function UpdateJobBlip(blip, data)
    SetBlipCoords(blip, data.coords)
end

AddEventHandler("onResourceStop", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        --DisplayPlayerNameTagsOnBlips(false)
        for i=1, #CachedBlips do
            local v = CachedBlips[i]
            if(v) then
                if(DoesBlipExist(v.blip)) then
                    RemoveBlip(v.blip)
                end
            end
        end
    end
end)