local TattooShopBlips = {}
local CurrentPreviewTattoos = {}
local StaticTattoos = {}
local Base = exports.strin_base
/*
    ["mpbeach_overlays"] = {
        hashInt, nil, hashInt, hashInt
    }

    
    ["mpbeach_overlays"] = {
        {
            hash = hashInt,
            alreadyBought = true,
        }
    }
*/
local LastSkin = nil
/*
    víte, že banány nerostou, ale koušou
*/
local Target = exports.ox_target
local SkinChanger = exports.skinchanger

Citizen.CreateThread(function()
    for tattooShopId, tattooShop in pairs(TattooShops) do
        TattooShopBlips[tattooShopId] = CreateTattooShopBlip(tattooShop)
        Target:addSphereZone({
            coords = tattooShop,
            radius = 2,
            drawSprite = true,
            options = {
                {
                    label = "Tatérství",
                    icon = "fa-solid fa-user-pen",
                    onSelect = function()
                        OpenTattooShopMenu(tattooShopId)
                    end,
                    canInteract = function()
                        return not Base:IsPlayerAPed()
                    end,
                }
            }   
        })
    end
end)

function OpenTattooShopMenu(tattooShopId)
    local elements = {}
    local ped = PlayerPedId()
    local currentCharacterTattoos = GetCharacterTattoos()
    if(currentCharacterTattoos and next(currentCharacterTattoos)) then
        table.insert(elements, {
            label = "<span style='color: #e74c3c;'>Odstranit tetování</span> - "..TattoosRemovalPrice.."$",
            value = "remove",
        })
    end
    for tattooCategory, tattooList in pairs(TattooList) do
        local categoryLabel = tattooCategory:gsub("_overlays", ""):gsub("mp", ""):gsub("^%l", string.upper)
        table.insert(elements, {
            label = "Kategorie tetování - "..categoryLabel,
            value = tattooCategory,
            categoryLabel = categoryLabel,
        })
    end
    if(not LastSkin) then
        LastSkin = SkinChanger:GetSkin()
        local pedModelHash = GetEntityModel(ped)
        if(pedModelHash == `mp_f_freemode_01`) then
            SetPedComponentVariation(ped, 8, 34, 0, 2)
            SetPedComponentVariation(ped, 3, 15, 0, 2)
            SetPedComponentVariation(ped, 11, 101, 1, 2)
            SetPedComponentVariation(ped, 4, 16, 0, 2)
        elseif(pedModelHash == `mp_m_freemode_01`) then
            SetPedComponentVariation(ped, 8, 15, 0, 2)
            SetPedComponentVariation(ped, 3, 15, 0, 2)
            SetPedComponentVariation(ped, 11, 91, 0, 2)
            SetPedComponentVariation(ped, 4, 14, 0, 2)
        else
            ESX.ShowNotification("Pro Váš typ postavy není tatérství dostupné!", { type = "error" })
            return
        end
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        PreviewCurrentPedDecorations(ped)
    end

    ClearPedDecorations(ped)
    ApplyPreviewTattoos()

    if(next(CurrentPreviewTattoos)) then
        local price, count = CalculatePriceAndCount()
        if((count > 0) and (price > 0)) then
            table.insert(elements, {
                label = ([[<div style="display: flex; justify-content: space-between; align-items: center; min-width: 350px;">
                    Celkem tetování - %sx<div>%s$</div><div style="color: #2ecc71;">Zaplatit</div>
                </div>]]):format(count, price),
                value = "buy"
            })
        end
    end
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "tattooshop_"..tattooShopId, {
        title = "Tatérství",
        align = "center",
        elements = elements,
    }, function(data, menu)
        menu.close()
        if(data.current.value == "buy") then
            TriggerServerEvent("strin_tattoos:buyTattoos", ConvertTattoos())
            ClearPedFromEffects()
            return
        end
        if(data.current.value == "remove") then
            TriggerServerEvent("strin_tattoos:removeTattoos")
            ClearPedFromEffects()
            return
        end
        OpenTattooCategory(tattooShopId, data.current.value, data.current.categoryLabel)
    end, function(data, menu)
        menu.close()
        ClearPedFromEffects()
    end)
end

function ClearPedFromEffects()
    local ped = PlayerPedId()
    if(next(CurrentPreviewTattoos)) then
        ClearPedDecorations(ped)
        for k,v in pairs(CurrentPreviewTattoos) do
            if(v) then
                for i=1, #v do
                    if(v[i] and v[i].alreadyBought) then
                        AddPedDecorationFromHashes(ped, GetHashKey(k), GetHashKey(v[i].name))
                    end
                end
            end
        end
    end
    FreezeEntityPosition(ped, false)
    SetEntityInvincible(ped, false)
    TriggerEvent("skinchanger:loadSkin", LastSkin)
    CurrentPreviewTattoos = {}
    LastSkin = nil
end

function OpenTattooCategory(tattooShopId, tattooCategory, categoryLabel)
    local elements = {}
    local categoryTattooList = TattooList[tattooCategory]
    for i=1, #categoryTattooList do
        local tattoo = categoryTattooList[i]
        table.insert(elements, {
            label = "Tetování #"..i,
            value = i
        })
    end

    ApplyPreviewTattoo(tattooCategory, 1)
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "tattooshop_"..tattooCategory, {
        title = "Tetování - "..categoryLabel,
        align = "center",
        elements = elements,
    }, function(data, menu)
        if(not CurrentPreviewTattoos[tattooCategory]) then
            CurrentPreviewTattoos[tattooCategory] = {}
        end
        local tattooName = categoryTattooList[data.current.value].name
        local category = CurrentPreviewTattoos[tattooCategory]
        local previewTattoos = false
        for i=1, #category do
            local tattoo = category[i]
            if(tattoo) then
                if(tattoo.name == tattooName and not tattoo.alreadyBought) then
                    CurrentPreviewTattoos[tattooCategory][i] = nil
                    previewTattoos = true
                elseif(tattoo.name == tattooName and tattoo.alreadyBought) then
                    ESX.ShowNotification("Tetování musíte nejdříve odstranit!", { type = "error" })
                    previewTattoos = true
                end
            end
        end
        if(previewTattoos) then
            ApplyPreviewTattoos()
        else
            table.insert(CurrentPreviewTattoos[tattooCategory], {
                name = tattooName
            })
            ApplyPreviewTattoo(tattooCategory, data.current.value)
        end
    end, function(data, menu)
        menu.close()
        OpenTattooShopMenu(tattooShopId)
    end, function(data, menu)
        ApplyPreviewTattoo(tattooCategory, data.current.value)
    end)
end

function ApplyPreviewTattoo(tattooCategory, tattooIndex)
    local ped = PlayerPedId()
    ClearPedDecorations(ped)
    AddPedDecorationFromHashes(ped, GetHashKey(tattooCategory), GetHashKey(TattooList[tattooCategory][tattooIndex].name))
    for k,v in pairs(CurrentPreviewTattoos) do
        for i=1, #v do
            if(v[i]) then
                AddPedDecorationFromHashes(ped, GetHashKey(k), GetHashKey(v[i].name))
            end
        end
    end
end

function ApplyPreviewTattoos()
    local ped = PlayerPedId()
    ClearPedDecorations(ped)
    for k,v in pairs(CurrentPreviewTattoos) do
        for i=1, #v do
            if(v[i]) then
                AddPedDecorationFromHashes(ped, GetHashKey(k), GetHashKey(v[i].name))
            end
        end
    end
end

function CreateTattooShopBlip(tattooShop)
    local blip = AddBlipForCoord(tattooShop)
    SetBlipDisplay(blip, 2)
    SetBlipSprite(blip, 75)
    SetBlipColour(blip, 48)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("<FONT FACE='Righteous'>Tatérství</FONT>")
    EndTextCommandSetBlipName(blip)
    return blip
end

function ConvertTattoos()
    local convertedTattoos = {}
    for k,v in pairs(CurrentPreviewTattoos) do
        convertedTattoos[k] = {}
        for i=1, #v do
            if(v[i] and v[i].name) then
                table.insert(convertedTattoos[k], v[i].name)
            end
        end
    end
    return convertedTattoos
end

function CalculatePriceAndCount()
    local price, count = 0,0
    for k,v in pairs(CurrentPreviewTattoos) do
        for i=1, #v do
            if(v[i] and not v[i]?.alreadyBought) then
                count += 1
            end
        end
    end
    price = count * TattooPrice
    return price, count
end

function PreviewCurrentPedDecorations(ped)
    local currentTattoos = GetCharacterTattoos()
    if(next(currentTattoos)) then
        for k,v in pairs(currentTattoos) do
            if(not CurrentPreviewTattoos[k]) then
                CurrentPreviewTattoos[k] = {}
            end
            local v = type(v) == "string" and json.decode(v) or v
            for _, tattooName in pairs(v) do
                table.insert(CurrentPreviewTattoos[k], {
                    name = tattooName,
                    alreadyBought = true,
                })
            end
        end
    end
end

AddEventHandler("skinchanger:modelLoaded", function()
    if(next(StaticTattoos)) then
        local ped = PlayerPedId()
        SetCharacterTattoos(StaticTattoos)
    end
end)

RegisterNetEvent("skinchanger:loadSkin", function()
    if(next(StaticTattoos)) then
        SetCharacterTattoos(StaticTattoos)
    end
end)

RegisterNetEvent("esx:playerLoaded", function()
    LoadCharacterTattoos()
end)

RegisterNetEvent("strin_characters:characterCreated", function()
    LoadCharacterTattoos()
end)

RegisterNetEvent("strin_characters:characterSwitched", function()
    LoadCharacterTattoos()
end)

RegisterNetEvent("strin_tattoos:updateTattoos", function(tattoos)
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end
    SetCharacterTattoos(tattoos)
end)

function LoadCharacterTattoos()
    local tattoos = GetCharacterTattoos()
    SetCharacterTattoos(tattoos)
end

exports("LoadCharacterTattoos", LoadCharacterTattoos)

function GetCharacterTattoos()
    return lib.callback.await("strin_tattoos:getTattoos", false)
end
exports("GetCharacterTattoos", GetCharacterTattoos)

function SetCharacterTattoos(tattoos)
    local ped = PlayerPedId()
    StaticTattoos = {}
    if(tattoos and next(tattoos)) then
        for k,v in pairs(tattoos) do
            local v = type(v) == "string" and json.decode(v) or v
            StaticTattoos[k] = v
            for i=1, #v do
                if(v[i]) then
                    AddPedDecorationFromHashes(ped, GetHashKey(k), GetHashKey(v[i]))
                end
            end
        end
        return
    end
    ClearPedDecorations(ped)
end

exports("SetCharacterTattoos", SetCharacterTattoos)

AddEventHandler("onResourceStop", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        for _,v in pairs(TattooShopBlips) do
            if(DoesBlipExist(v)) then
                RemoveBlip(v)
            end
        end
    end
end)