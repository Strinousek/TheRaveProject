local RegisteredBlips = {}

local function CreateBlip(data)
    local blip = data.entity and AddBlipForEntity(data.entity) or AddBlipForCoord(data.coords)
    SetBlipDisplay(blip, data.display or 2)
    SetBlipSprite(blip, data.sprite)
    SetBlipColour(blip, data.colour)
    SetBlipScale(blip, data.scale or 1.0)
    if(data.shrink ~= nil) then
        SetBlipShrink(blip, data.shrink)
    else
        SetBlipShrink(blip, false)
    end
    if(data.shortRange ~= nil) then
        SetBlipAsShortRange(blip, data.shortRange)
    else
        SetBlipAsShortRange(blip, true)
    end
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("<FONT FACE='Righteous'>"..data.label.."</FONT>")
    EndTextCommandSetBlipName(blip)
    RegisteredBlips[data.id] = blip
    return RegisteredBlips[data.id]
end

exports("CreateBlip", CreateBlip)

local function DeleteBlip(id)
    local blipRemoved = false 
    if(RegisteredBlips[id] and DoesBlipExist(RegisteredBlips[id])) then
        RemoveBlip(RegisteredBlips[id])
        RegisteredBlips[id] = nil
        blipRemoved = true
    end
    return RegisteredBlips[id]
end

exports("DeleteBlip", DeleteBlip)