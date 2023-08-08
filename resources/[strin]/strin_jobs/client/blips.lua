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

RegisterNetEvent("strin_jobs:updateBlips", function(blips)
    --[[if(not blipsSetup or (blipsSetup and next(CachedBlips) and not next(blips))) then
        SetBigmapActive(true, false)
        DisplayPlayerNameTagsOnBlips(true)
        blipsSetup = true
    end]]
    if(not blips or not next(blips)) then
        for k,v in pairs(CachedBlips) do
            if(DoesBlipExist(v.blip)) then
                RemoveBlip(v.blip)
            end
        end
        CachedBlips = {}
        return
    end
    for blipId,blip in pairs(blips) do
        blip.distant = GetPlayerFromServerId(blip.playerId) == -1 and true or false
        local cachedBlip = CachedBlips[blipId]
        if(cachedBlip and not blip) then
            if(DoesBlipExist(cachedBlip.blip)) then
                RemoveBlip(cachedBlip.blip)
                CachedBlips[blipId] = nil
            end
        end
        if(not cachedBlip and blip) then
            if(blip.playerId == GetPlayerServerId(PlayerId())) then
                if(playerSpawned) then            
                    CachedBlips[blipId] = blip
                    CachedBlips[blipId].blip = CreateJobBlip(blip)
                end
            else
                CachedBlips[blipId] = blip
                CachedBlips[blipId].blip = CreateJobBlip(blip)
            end
        end
        if(cachedBlip and blip) then
            CachedBlips[blipId].coords = blip.coords
            if((not blip.distant and cachedBlip.distant) or (blip.distant and not cachedBlip.distant)) then 
                if(DoesBlipExist(cachedBlip.blip)) then
                    RemoveBlip(cachedBlip.blip)
                    CachedBlips[blipId].blip = nil
                end
                CachedBlips[blipId].blip = CreateJobBlip(blip)
                return
            end
            if(cachedBlip.distant and blip.distant) then
                UpdateJobBlip(cachedBlip.blip, blip)
                return
            end
        end
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
        DisplayPlayerNameTagsOnBlips(false)
        for _,v in pairs(CachedBlips) do
            if(DoesBlipExist(v.blip)) then
                RemoveBlip(v.blip)
            end
        end
    end
end)