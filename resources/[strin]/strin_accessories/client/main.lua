local Target = exports.ox_target
local SkinChanger = exports.skinchanger
local Skin = exports.strin_skin
local Base = exports.strin_base

Citizen.CreateThread(function()
    local registeredLocations = {}
    for accessory, shopLocations in pairs(AccessoryShops) do
        for i=1, #shopLocations do
            for j=1, #registeredLocations do
                if(#(registeredLocations[j] - shopLocations[i]) < 5) then
                    goto skipLoop
                end
            end
            table.insert(registeredLocations, shopLocations[i])
            local shopLocation = shopLocations[i]
            Target:addSphereZone({
                coords = shopLocation,
                radius = 2.0,
                drawSprite = true,
                options = {
                    {
                        label = "Doplňky",
                        icon = "fa-solid fa-ring",
                        onSelect = function()
                            OpenAccessoriesShopMenu()
                        end,
                        canInteract = function()
                            return not Base:IsPlayerAPed()
                        end,
                    }
                }
            })
            ::skipLoop::
        end
    end
end)

function OpenAccessoriesShopMenu()
    local elements = {}
    for accessory, _ in pairs(AccessoryShops) do
        table.insert(elements, {
            label = Labels[accessory.."s"].." - "..AccessoryPrice.."$",
            value = accessory:lower(),
        })
    end
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "accessories_menu", {
        title = "Obchod s doplňky",
        align = "center",
        elements = elements,
    }, function(data, menu)
        menu.close()
        OpenAccessoryShopMenu(data.current.value)
    end, function(data, menu)
        menu.close()
    end)
end

function OpenAccessoryShopMenu(accessory)
    local restrict = {}
    if(accessory ~= "arms") then
        restrict = {accessory..'_1', accessory..'_2'}
    else
        restrict = {accessory, accessory.."_2"}
    end
    local skin, lastSkin = Skin:OpenSkinMenu(nil, nil, restrict)
    TriggerEvent("skinchanger:loadSkin", lastSkin)
    local changes = GetChangesFromSkins(skin, lastSkin)
    if(next(changes)) then
        TriggerServerEvent("strin_accessories:buyAccessory", changes)
    end
end

RegisterCommand("accessories", function()
    if(Base:IsPlayerAPed()) then
        ESX.ShowNotification("Pro tento typ postavy nelze mít doplňky!", { type = "error" })
        return
    end
    local playerAccessories = lib.callback.await("strin_accessories:getAccessories", false)
    if(not playerAccessories or not next(playerAccessories)) then
        ESX.ShowNotification("Provádíte akce moc rychle!", { type = "error" })
        return
    end
    local totalCount = 0
    for k,v in pairs(playerAccessories) do
        playerAccessories[k] = json.decode(v)
        totalCount += #playerAccessories[k]
    end
    if(totalCount <= 0) then
        ESX.ShowNotification("Nevlástníte žádné doplňky!", { type = "error" })
        return
    end
    OpenAccessoriesMenu(playerAccessories)
end)

RegisterKeyMapping("accessories", "<FONT FACE='Righteous'>Doplňky</FONT>", "KEYBOARD", "L")

function OpenAccessoriesMenu(accessories) 
    local elements = {}
    for k,v in pairs(accessories) do
        if(#v > 0) then
            local label = Labels[k:gsub("^%l", string.upper)..("s")] or Labels[k:gsub("^%l", string.upper)]
            table.insert(elements, {
                label = ([[<div style="display: flex; justify-content: space-between; align-items: center;">
                    %s<div>%sx</div>
                </div>]]):format(label, #v),
                value = k,
            })
        end
    end
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "accessories", {
        title = "Doplňky",
        align = "center",
        elements = elements
    }, function(data, menu)
        menu.close()
        OpenAccessoryTypeMenu(data.current.value, accessories[data.current.value])
    end, function(data, menu)
        menu.close()
    end)
end

function OpenAccessoryTypeMenu(accessoryType, accessories)
    local elements = {}
    local skin = SkinChanger:GetSkin()
    local label = Labels[accessoryType:gsub("^%l", string.upper)..("s")] or Labels[accessoryType:gsub("^%l", string.upper)]
    /*local textureComponent = {}
    if(accessoryType:sub(-1) == "s" and not Labels[accessoryType:gsub("^%l", string.upper)..("s")]) then
        textureComponent = SkinChanger:GetComponent(accessoryType:sub(1, accessoryType:len() - 1).."_2")
    end*/
    local sanitizedAccessoryType = accessoryType
    if(accessoryType:sub(-1) == "s" and not Labels[accessoryType:gsub("^%l", string.upper)..("s")]) then
        sanitizedAccessoryType = accessoryType:sub(1, accessoryType:len() - 1)
    end
    for i=1, #accessories do
        local accessory = accessories[i]
        table.insert(elements, {
            label = ([[<div style="display: flex; justify-content: space-between; align-items: center;">
                %s #%s<div>%s:%s</div>%s
            </div>]]):format(
                accessory.label or label,
                i,
                accessory.variation,
                accessory.texture,
                ((skin[
                    sanitizedAccessoryType ~= "arms" and sanitizedAccessoryType.."_1" or sanitizedAccessoryType
                ] == accessory.variation) and (
                    skin[sanitizedAccessoryType.."_2"] == accessory.texture
                )) and "<div>Nasazeno</div>" or ""
            ),
            value = i,
        })
    end
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "accessory_"..accessoryType, {
        title = "Doplňky - "..label,
        align = "center",
        elements = elements
    }, function(data, menu)
        menu.close()
        OpenAccessoryMenu(sanitizedAccessoryType, data.current.value, accessories[data.current.value])
    end, function(data, menu)
        menu.close()
    end)
end

function OpenAccessoryMenu(accessoryType, accessoryId, accessory)
    local skin = SkinChanger:GetSkin()
    local elements = {
        { label = (((skin[
            accessoryType ~= "arms" and accessoryType.."_1" or accessoryType
        ] == accessory.variation) and (skin[accessoryType.."_2"] == accessory.texture)) and "Sundat" or "Nasadit").." doplněk", value = "wear" },
        { label = "Přejmenovat doplněk", value = "rename" },
        { label = "Smazat doplněk", value = "delete" },
    }
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "accessory_"..accessoryType.."_"..accessoryId, {
        title = "Doplňek - "..(accessory.label or "#"..accessoryId),
        align = "center",
        elements = elements
    }, function(data, menu)
        menu.close()
        if(data.current.value == "wear") then
            TriggerServerEvent("strin_accessories:wearAccessory", accessoryType, tonumber(accessoryId))
        elseif(data.current.value == "rename") then
            ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "accessory_label", {
                title = "Text (nechte prázdné pro reset)",
            }, function(data2, menu2)
                menu2.close()
                TriggerServerEvent("strin_accessories:renameAccessory", accessoryType, accessoryId, data2.value or "")
            end, function(data2, menu2)
                menu2.close()
            end)
        elseif(data.current.value == "delete") then
            TriggerServerEvent("strin_accessories:deleteAccessory", accessoryType, accessoryId)
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