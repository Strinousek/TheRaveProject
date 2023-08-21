local LastSkin = nil
/*
    víte, že banány nerostou, ale koušou
*/
local Target = exports.ox_target
local SkinChanger = exports.skinchanger
local Skin = exports.strin_skin
local BarberShopBlips = {}
local Base = exports.strin_base

Citizen.CreateThread(function()
    for barberShopId, barberShop in pairs(BarberShops) do
        BarberShopBlips[barberShopId] = CreateBarberShopBlip(barberShop)
        Target:addSphereZone({
            coords = vector(barberShop.x, barberShop.y, barberShop.z + 1.0),
            radius = 2,
            drawSprite = true,
            options = {
                {
                    label = "Kadeřnictví",
                    icon = "fa-solid fa-scissors",
                    onSelect = function()
                        OpenBarberShopMenu(barberShopId)
                    end,
                    canInteract = function()
                        return not Base:IsPlayerAPed()
                    end,
                }
            }   
        })
    end
end)

function OpenBarberShopMenu(barberShopId)
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    local skin, lastSkin = Skin:OpenSkinMenu(nil, nil, BarberShopPieces)
    FreezeEntityPosition(ped, false)
    SetEntityInvincible(ped, false)
    local changes = GetChangesFromSkins(skin, lastSkin)
    if(not next(changes)) then
        TriggerEvent("skinchanger:loadSkin", lastSkin)
        return
    end
    local haircut = CompleteHaircutFromPreviousSkin(changes, lastSkin)
    lib.callback("strin_barbershop:buyHaircut", 500, function(success)
        if(not success) then
            TriggerEvent("skinchanger:loadSkin", lastSkin)
        end
    end, haircut)
end

function GetChangesFromSkins(changedSkin, previousSkin)
    local changes = {}
    for k,v in pairs(changedSkin) do
        if(previousSkin[k] ~= v) then
            changes[k] = v
        end
    end
    return changes
end

function CompleteHaircutFromPreviousSkin(changes, previousSkin)
    local haircut = {}
    for _,k in pairs(BarberShopPieces) do
        if(changes[k]) then
            haircut[k] = changes[k]
        elseif(not changes[k] and previousSkin[k]) then
            haircut[k] = previousSkin[k]
        end
    end
    return haircut
end

function CreateBarberShopBlip(barberShop)
    local blip = AddBlipForCoord(barberShop)
    SetBlipDisplay(blip, 2)
    SetBlipSprite(blip, 71)
    SetBlipColour(blip, 50)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("<FONT FACE='Righteous'>Kadeřnictví</FONT>")
    EndTextCommandSetBlipName(blip)
    return blip
end

AddEventHandler("onResourceStop", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        for _,v in pairs(BarberShopBlips) do
            if(DoesBlipExist(v)) then
                RemoveBlip(v)
            end
        end
    end
end)