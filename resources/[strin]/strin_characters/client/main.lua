local Skin = exports.strin_skin
local SkinChanger = exports.skinchanger
local Base = exports.strin_base

loadingScreenFinished = false

AddEventHandler("onClientResourceStart", function(resourceName)
    if(ESX.IsPlayerLoaded() and GetCurrentResourceName() == resourceName) then
		loadingScreenFinished = true
    end
end)

AddEventHandler('esx:loadingScreenOff', function()
	loadingScreenFinished = true
end)

RegisterNetEvent("strin_characters:demandSkin", function()
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end
    if(not loadingScreenFinished) then
        while not loadingScreenFinished do
            Citizen.Wait(0)
        end
    end
    DemandConfirmedSkinMenu()
end)

SetPedModel = function(modelHash)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(0)
    end
    SetPlayerModel(PlayerId(), modelHash)
    SetPedDefaultComponentVariation(PlayerPedId())
end

DemandConfirmedSkinMenu = function(cb, loadedDefaultModel, lastSkin)
    if(ESX.PlayerData.char_type == 1) then
        local lastSkin = lastSkin and lastSkin or SkinChanger:GetSkin()
        if(not loadedDefaultModel) then
            local components = SkinChanger:GetComponents()
            local defaultSkin = {}
            for _,v in pairs(components) do
                defaultSkin[v.name] = v.value
            end
            TriggerEvent('skinchanger:loadSkin', defaultSkin, function()
                FreezeEntityPosition(PlayerPedId(), false)
                DemandConfirmedSkinMenu(cb, true)
            end)
            FreezeEntityPosition(PlayerPedId(), true)
            return
        end
        local onConfirm = function(skin)
            local isSkinSaved = lib.callback.await("strin_skin:saveSkin", false)
            if(cb) then
                cb(isSkinSaved)
            end
            if(not isSkinSaved) then
                TriggerEvent("skinchanger:loadSkin", lastSkin)
            end
        end
        local onCancel = function()
            DemandConfirmedSkinMenu(cb, true, lastSkin)
        end
        Skin:OpenSkinMenu(onConfirm, onCancel, nil, {
            "bproof_1", "bproof_2",
            /*"mask_1", "mask_2",
            "chain_1", "chain_2",
            "helmet_1", "helmet_2",
            "glasses_1", "glasses_2",
            "bracelets_1", "bracelets_2",
            "bags_1", "bags_2",*/
        })
    else
        local elements = {}
        local models = ESX.PlayerData.char_type == 2 and Base:GetPedModels() or Base:GetAnimalModels()
        table.insert(elements, { label = "Model", min = 1, value = 1, max = #models, type = "slider" })
        ESX.UI.Menu.Open("default", GetCurrentResourceName(), "demanded_skin_menu", {
            title = "Ped / Animal Menu",
            align = "center",
            elements = elements,
        }, function(data, menu)
            menu.close()
            local isSkinSaved = lib.callback.await("strin_skin:saveSkin", false)
            if(isSkinSaved) then
                if(cb) then
                    cb(isSkinSaved)
                end
                return 
            end
            DemandConfirmedSkinMenu(cb)
        end, nil, function(data, menu)
            SetPedModel(models[data.current.value])
        end)
        SetPedModel(models[1])
    end
end

RegisterNetEvent("strin_characters:characterSwitched", function(character)
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end
    
    local skin = json.decode(character.skin)
    if(not skin?.model) then
        local ped = PlayerPedId()
        local model = GetEntityModel(ped)
        if(model ~= `mp_f_freemode_01` and model ~= `mp_m_freemode_01`) then
            TriggerEvent("skinchanger:loadDefaultModel", skin.sex == 0, function()
                TriggerEvent("skinchanger:loadSkin", skin)
            end)
            return
        end
        TriggerEvent("skinchanger:loadSkin", skin)
        return
    end
    RequestModel(skin?.model)
    while not HasModelLoaded(skin?.model) do
        Citizen.Wait(0)
    end
    SetPlayerModel(PlayerId(), skin?.model)
    SetPedDefaultComponentVariation(PlayerPedId())
end)

RegisterNetEvent("strin_characters:openCharactersMenu", function(characters, slots, currentCharId)
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end
    local elems = {}
    local availableSlots = slots - #characters
    if(not characters or not next(characters)) then
        return
    end
    for k,v in pairs(characters) do
        if(v.char_id == currentCharId) then
            table.insert(elems, {label = v.firstname.." "..v.lastname.." <span style='float: right;'>#"..v.char_id.."<span style='color: #2ecc71;'> - AKTIVNÍ</span></span>", value = k})
        else
            table.insert(elems, {label = v.firstname.." "..v.lastname.." <span style='float: right;'>#"..v.char_id.."</span>", value = k})
        end
    end
    if(availableSlots > 0) then
        table.insert(elems, {label = "<span style='display: flex; align-items: center;'><i class='fas fa-plus' style='margin-right: 8px'></i>Vytvořit novou postavu</span>", value = "create_char"})
    end
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "multichar_menu", {
        title = "Multichar ("..#characters.."/"..slots.." FULL)",
        align = "center",
        elements = elems,
    }, function(data, menu)
        menu.close()
        if(data.current.value ~= "create_char") then
            OpenSpecificCharacterMenu(characters[data.current.value], currentCharId)
        else
            TriggerServerEvent("strin_characters:requestCharacterCreator")
        end
    end, function(data, menu)
        menu.close()
    end)
end)

function OpenSpecificCharacterMenu(character, currentCharId)
    local isCurrentCharacter = character.char_id == currentCharId
    local status = (isCurrentCharacter) and "<span style='color: #2ecc71; margin-left: 8px;'>[AKTIVNÍ]</span" or "<span style='color: #e74c3c; margin-left: 8px;'>[NEAKTIVNÍ]</span"
    local elems = {}
    local inventory = json.decode(character.inventory)
    if(not isCurrentCharacter) then
        table.insert(elems, {label = "Inventář - "..#inventory, value = "inventory"})
        table.insert(elems, {label = "<span style='display: flex; align-items: center;'><i class='fas fa-exclamation-triangle' style='margin-right: 8px'></i>Smazat postavu</span>", value = "delete_char"})
        table.insert(elems, {label = "<span style='display: flex; align-items: center;'><i class='fas fa-dice-d20' style='margin-right: 8px'></i>Přepnout na tuto postavu</span>", value = "switch_char"})
    else
        table.insert(elems, {label = "<span style='display: flex; align-items: center;'><i class='fas fa-dice-d20' style='margin-right: 8px'></i><span style='color: #2ecc71; margin-left: 8px;'>TATO POSTAVA JE AKTIVNÍ - NELZE PROVÁDĚT ŽÁDNÉ AKCE</span></span>"})
    end
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "multichar_"..character.char_id, {
        title = character.firstname.." "..character.lastname..status,
        align = "center",
        elements = elems,
    }, function(data, menu)
        if(data.current.value == "delete_char") then
            menu.close()
            ESX.UI.Menu.Open("default", GetCurrentResourceName(), "multichar_delete_"..character.char_id, {
                title = "Doopravdy si přejete postavu smazat?",
                align = "center",
                elements = {
                    { label = "Ne", value = "no" },
                    { label = "Ano", value = "yes" },
                }
            }, function(data2, menu2)
                menu2.close()
                if(data2.current.value == "yes") then
                    TriggerServerEvent("strin_characters:updateCharacter", character.char_id, "DELETE")
                end
            end, function(data2, menu2)
                menu2.close()
            end)
        elseif(data.current.value == "switch_char") then
            menu.close()
            TriggerServerEvent("strin_characters:updateCharacter", character.char_id, "SWITCH")
        end
    end, function(data, menu)
        menu.close()
    end)
end