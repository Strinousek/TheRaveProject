local Target = exports.ox_target
local SkinChanger = exports.skinchanger
local Skin = exports.strin_skin
local Base = exports.strin_base

local CloakroomsBlips = {}

Citizen.CreateThread(function()
    for cloakroomId, cloakroom in pairs(Cloakrooms) do
        local restrictedJobs = cloakroom.restrictedJobs
        if(cloakroom.showBlip) then
            CloakroomsBlips[cloakroomId] = CreateCloakroomBlip(cloakroom)
        end
        Target:addSphereZone({
            coords = cloakroom.coords,
            radius = 2.0,
            drawSprite = true,
            options = {
                {
                    label = "Oblečení",
                    onSelect = function()
                        OpenCloakroomMenu(cloakroomId, cloakroom)
                    end,
                    canInteract = function()
                        return not Base:IsPlayerAPed() and (
                            (restrictedJobs and next(restrictedJobs)) and 
                            lib.table.contains(restrictedJobs, ESX.PlayerData.job?.name) or
                            true
                        )
                    end,
                }
            }
        })
    end
end)

function OpenCloakroomMenu(cloakroomId, cloakroom)
    local elements = {}
    if(cloakroom.includeShop) then
        table.insert(elements, {
            label = ([[<div style="display: flex; justify-content: space-between; align-items: center">
                Obchod<div style="color: %s;">%s$</div>
            </div>]]):format(
                ((exports.ox_inventory:GetItemCount("money") - OutfitPrice) >= 0) and "#2ecc71" or "#e74c3c",
                OutfitPrice
            ),
            value = "shop"
        })
        table.insert(elements, {
            label = ([[<div style="display: flex; justify-content: space-between; align-items: center">
                Uložit aktuální oblek<div style="color: %s;">%s$</div>
            </div>]]):format(
                ((exports.ox_inventory:GetItemCount("money") - OutfitPrice) >= 0) and "#2ecc71" or "#e74c3c",
                OutfitPrice
            ),
            value = "shop_save_current"
        })
    end
    local outfits = lib.callback.await("strin_clotheshop:getOutfits", 1000)

    table.insert(elements, {
        label = ([[<div style="display: flex; justify-content: space-between; align-items: center">
            Šatna<div>%sx</div>
        </div>]]):format(
            (outfits and next(outfits)) and #outfits or 0
        ),
        value = "wardrobe"
    })
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "cloakroom_"..cloakroomId, {
        title = "Oblečení"..(cloakroom.label and " - "..cloakroom.label or ""),
        align = "center",
        elements = elements,
    }, function(data, menu)
        menu.close()
        if(data.current.value == "shop") then
            if((exports.ox_inventory:GetItemCount("money") - OutfitPrice) >= 0) then
                OpenClotheShopMenu()
            else
                ESX.ShowNotification("Nemáte peníze na zakoupení nového outfitu!", { type = "error " })
            end
        elseif(data.current.value == "wardrobe") then
            if(outfits and next(outfits)) then
                OpenWardrobeMenu(cloakroomId, cloakroom, outfits)
            else
                ESX.ShowNotification("Nevlastníte žádné outfity!", { type = "error" })
            end
        elseif(data.current.value == "shop_save_current") then
            if((exports.ox_inventory:GetItemCount("money") - OutfitPrice) >= 0) then
                SaveCurrentOutfit()
            else
                ESX.ShowNotification("Nemáte peníze na zakoupení nového outfitu!", { type = "error " })
            end
        end
    end,function(data, menu)
        menu.close()
    end)
end

function SaveCurrentOutfit()
    local skin = SkinChanger:GetSkin()
    local outfit = {}
    for k,v in pairs(skin) do
        if(lib.table.contains(ClotheShopPieces, k)) then
            outfit[k] = v
        end
    end
    TriggerServerEvent("strin_clotheshop:buyOutfit", outfit)
end

function OpenClotheShopMenu()
    local skin, lastSkin = Skin:OpenSkinMenu(nil, nil, ClotheShopPieces)
    TriggerEvent("skinchanger:loadSkin", lastSkin)
    local changes = GetChangesFromSkins(skin, lastSkin)
    if(next(changes)) then
        TriggerServerEvent("strin_clotheshop:buyOutfit", changes)
    end
end

function OpenWardrobeMenu(cloakroomId, cloakroom, outfits, pageNumber)
    local elements = {}

    local pageSize = 8
    local pageCount = (#outfits % pageSize == 0) and math.floor(#outfits / pageSize) or (math.ceil(#outfits / pageSize + 0.5))
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
        local outfit = outfits[i]
        if(outfit) then
            table.insert(elements, {
                label = (outfit.label and outfit.label or "Oblek")..(" #"..i),
                value = i,
            })
        end
    end

    if(pageNumber < pageCount) then
        table.insert(elements, {
            label = '<span style="color: #2ecc71"> Další stránka >> </span>',
            value = "next_page"
        })
    end
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "wardrobe_"..cloakroomId, {
        title = "Oblečení"..(cloakroom.label and " - "..cloakroom.label or "").." ("..pageNumber.."/"..pageCount..")",
        align = "center",
        elements = elements,
    }, function(data, menu)
        menu.close()
        if(data.current.value == "next_page") then
            OpenWardrobeMenu(cloakroomId, cloakroom, outfits, pageNumber + 1)
            return
        end
        if(data.current.value == "previous_page") then
            OpenWardrobeMenu(cloakroomId, cloakroom, outfits, pageNumber - 1)
            return
        end
        OpenOutfitMenu(outfits[data.current.value], data.current.value)
    end, function(data, menu)
        menu.close()
    end)
end

exports("OpenWardrobeMenu", function(wardrobeLabel)
    if(Base:IsPlayerAPed()) then
        ESX.ShowNotification("Pro tento typ postavy nelze otevřít šatník!", { type = "error" })
        return
    end
    lib.callback("strin_clotheshop:getOutfits", false, function(outfits)
        OpenWardrobeMenu(math.random(1,99), {
            label = wardrobeLabel or nil,
        }, outfits)
    end)
end)

function OpenOutfitMenu(outfitData, outfitId)
    local elements = {
        { label = "Obléct oblek", value = "wear" },
        { label = "Přejmenovat oblek", value = "rename" },
        { label = "Odebrat oblek", value = "delete" },
    }
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "outfit_"..outfitId, {
        title = "Oblek - "..(outfitData.label or "#"..outfitId),
        align = "center",
        elements = elements
    }, function(data, menu)
        menu.close()
        if(data.current.value == "wear") then
            TriggerServerEvent("strin_clotheshop:wearOutfit", outfitData.id)
        elseif(data.current.value == "rename") then
            ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "outfit_label", {
                title = "Text (nechte prázdné pro reset)",
            }, function(data2, menu2)
                menu2.close()
                TriggerServerEvent("strin_clotheshop:renameOutfit", outfitData.id, data2.value or "")
            end, function(data2, menu2)
                menu2.close()
            end)
        elseif(data.current.value == "delete") then
            TriggerServerEvent("strin_clotheshop:deleteOutfit", outfitData.id)
        end
    end, function(data, menu)
        menu.close()
    end)
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

function CreateCloakroomBlip(cloakroom)
    local blip = AddBlipForCoord(cloakroom.coords)
    SetBlipDisplay(blip, 2)
    SetBlipSprite(blip, 73)
    SetBlipColour(blip, 64)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("<FONT FACE='Righteous'>Oblečení</FONT>")
    EndTextCommandSetBlipName(blip)
    return blip
end

AddEventHandler("onResourceStop", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        for _,v in pairs(CloakroomsBlips) do
            if(DoesBlipExist(v)) then
                RemoveBlip(v)
            end
        end
    end
end)