
local Base = exports.strin_base

Base:RegisterWebhook("BOSS_BALANCE", "https://discord.com/api/webhooks/1137785921463398461/B0GOkyyszPruyQtbQHb_GHPhOurfpSqyRTdCoTzgJi2r8-dOepmv_IJvVj7g5z9Bpmnn")
Base:RegisterWebhook("BOSS_EMPLOYEE", "https://discord.com/api/webhooks/1137785708027850812/bPql1xoLN21fqG_GVxOwswZ7Rzo8CjTbravL2Rog0kUTU0OJjlQhkV8_Nw4lg51gZ5Va")
Base:RegisterWebhook("BOSS_UPDATE", "https://discord.com/api/webhooks/777279695267037235/elBRknk8Qqw3ZRcCccSxQ15TIXQ20aC6ntlsP5wJNMkpRlk1eW-q3pxHqFVlJgsIYkeE")
Base:RegisterWebhook("BOSS_VEHICLES", "https://discord.com/api/webhooks/1137788527082483782/pIpzr4s4Sh7LziqO7MgSox8vVTYuwOIQTIbnOKRVYmMqxDUByZH42Jd66uv34Q6NQzNl")

local GetEntityCoords = GetEntityCoords
local GetPlayerPed = GetPlayerPed 

RegisterNetEvent("strin_jobs:requestBossOffice", function(jobName)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    if(not Jobs[jobName]) then
        return
    end

    local job = xPlayer.getJob()
    if(job.name ~= jobName or (job.grade_name ~= "boss" and job.grade_name ~= "manager")) then
        xPlayer.showNotification("K této akci nemáte dostatečné oprávnění!", { type = "error" })
        return
    end

    local isNearBossOffice = IsNearJobBossOffice(_source, job.name)
    if(not isNearBossOffice) then
        xPlayer.showNotification("Nejste dostatečně blízko!", { type = "error" })
        return
    end
    
    local society = Society:GetSociety(job.name)
    if(not society) then
        xPlayer.showNotification("Neidentifikovaná společnost!", { type = "error" })
        return
    end

    local employees = Society:GetSocietyEmployees(job.name) or {}
    local vehicles = Society:GetSocietyVehicles(job.name, {"id", "plate", "owner", "model"})
    TriggerClientEvent("strin_jobs:openBossOffice", _source, society, employees, vehicles)
end)

RegisterNetEvent("strin_jobs:fireEmployee", function(jobName, identifier, characterId)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    if(not Jobs[jobName]) then
        return
    end

    local job = xPlayer.getJob()
    if(job.name ~= jobName or (job.grade_name ~= "boss" and job.grade_name ~= "manager")) then
        xPlayer.showNotification("K této akci nemáte dostatečné oprávnění!", { type = "error" })
        return
    end

    if(xPlayer.get("char_id") == characterId and xPlayer.identifier == identifier) then
        xPlayer.showNotification("Nemůžete vyhodit sám sebe jako šéfa!", { type = "error" })
        return
    end

    local isNearBossOffice = IsNearJobBossOffice(_source, jobName)
    if(not isNearBossOffice) then
        xPlayer.showNotification("Nejste dostatečně blízko!", { type = "error" })
        return
    end
    
    local society = Society:GetSociety(jobName)
    if(not society) then
        xPlayer.showNotification("Neidentifikovaná společnost!", { type = "error" })
        return
    end

    local success = Society:FireSocietyEmployee(jobName, ESX.SanitizeString(identifier), characterId)
    if(not success) then
        xPlayer.showNotification("Nastala chyba při vyhazování zaměstnance.", { type = "error" })
        return
    end
    xPlayer.showNotification("Zaměstnanec vyhozen.", {type = "success"})
end)

RegisterNetEvent("strin_jobs:updateEmployee", function(jobName, identifier, characterId, grade)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    if(not Jobs[jobName]) then
        return
    end

    local job = xPlayer.getJob()
    if(job.name ~= jobName or (job.grade_name ~= "boss" and job.grade_name ~= "manager")) then
        xPlayer.showNotification("K této akci nemáte dostatečné oprávnění!", { type = "error" })
        return
    end
    
    if(xPlayer.get("char_id") == characterId and xPlayer.identifier == identifier) then
        xPlayer.showNotification("Nemůžete změnit svojí pozici!", { type = "error" })
        return
    end

    local isNearBossOffice = IsNearJobBossOffice(_source, jobName)
    if(not isNearBossOffice) then
        xPlayer.showNotification("Nejste dostatečně blízko!", { type = "error" })
        return
    end
    
    local society = Society:GetSociety(jobName)
    if(not society) then
        xPlayer.showNotification("Neidentifikovaná společnost!", {type = "error"})
        return
    end

    local success = Society:UpdateSocietyEmployee(jobName, ESX.SanitizeString(identifier), characterId, grade)
    if(not success) then
        xPlayer.showNotification("Nastala chyba při změně hodnosti.", { type = "error" })
        return
    end
    /*Base:DiscordLog("BOSS_EMPLOYEE", "THE RAVE PROJECT - SPOLEČNOST - ZMĚNA HODNOSTI", {
        { name = "Identifikace hráče", value = xPlayer.identifier },
        { name = "Společnost", value = jobName },
        { name = "Identifikace zaměstnance", value = identifier },
        { name = "ID postavy zaměstnance", value = characterId },
        { name = "ID vozidla", value = vehicleId },
    }, {
        fields = true
    })*/
    xPlayer.showNotification("Zaměstnanci byla změněna hodnost.", { type = "success" })
end)

lib.callback.register("strin_jobs:hireEmployee", function(source, targetId)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return false, "Hráč nenalezen!"
    end

    local job = xPlayer.getJob()
    if(job.grade_name ~= "boss" and job.grade_name ~= "manager" and (not job.name:find("off_"))) then
        return false, "Nedostatečné oprávnění!"
    end

    local targetPlayer = ESX.GetPlayerFromId(targetId)
    if(not targetPlayer) then
        return false, "Hráč nenalezen!"
    end

    local targetId = targetPlayer.source
    local distance = #(GetEntityCoords(GetPlayerPed(_source)) - GetEntityCoords(GetPlayerPed(targetId)))
    if(distance > 15.00) then
        return false, "Hráč je moc daleko!"
    end

    return Society:HireSocietyEmployee(job.name, targetPlayer.identifier, 1), "Neznámá chyba. Zkuste později. Kontaktujte dev. tým v případě, že problém přetrvává."
end)

RegisterNetEvent("strin_jobs:attachEmployeeToVehicle", function(vehicleId, identifier, characterId)
    if(type(vehicleId) ~= "number" or type(identifier) ~= "string" or type(characterId) ~= "number") then
        return
    end
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end
    
    local job = xPlayer.getJob()
    if(not Jobs[job.name]) then
        xPlayer.showNotification("Společnost není uvedena v systému!", { type = "error" })
        return
    end
    
    local isNearBossOffice = IsNearJobBossOffice(_source, job.name)
    if(not isNearBossOffice) then
        xPlayer.showNotification("Nejste dostatečně blízko!", { type = "error" })
        return
    end

    local vehicles = Society:GetSocietyVehicles(job.name, {"id"})
    if(not next(vehicles)) then
        xPlayer.showNotification("Společnost nemá žádné firemní vozidla!", { type = "error" })
        return
    end

    local isVehicleValid = DoesSocietyVehicleExist(vehicles, vehicleId)
    if(not isVehicleValid) then
        xPlayer.showNotification("Neplatné vozidlo!", {type = "error"})
        return
    end

    xPlayer.showNotification("Probíhá přiřazovaní...")
    local success = MySQL.update.await("UPDATE owned_vehicles SET `owner` = ? WHERE `id` = ?", {
        ESX.SanitizeString(identifier)..":"..characterId,
        vehicleId
    })
    if(not success) then   
        xPlayer.showNotification("Při přiřazení nastala chyba!", { type = "error" })
        return
    end
    
    Base:DiscordLog("BOSS_VEHICLES", "THE RAVE PROJECT - SPOLEČNOST - PŘIPNUTÍ VOZIDLA", {
        { name = "Identifikace hráče", value = xPlayer.identifier },
        { name = "Společnost", value = jobName },
        { name = "Identifikace zaměstnance", value = identifier },
        { name = "ID postavy zaměstnance", value = characterId },
        { name = "ID vozidla", value = vehicleId },
    }, {
        fields = true
    })

    xPlayer.showNotification("Vozidlo úspěšně přiřazeno!", { type = "success" })
end)

RegisterNetEvent("strin_jobs:detachEmployeeFromVehicle", function(vehicleId)
    if(type(vehicleId) ~= "number") then
        return
    end
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end
    
    local job = xPlayer.getJob()
    if(not Jobs[job.name]) then
        xPlayer.showNotification("Společnost není uvedena v systému!", {type = "error"})
        return
    end
    
    local isNearBossOffice = IsNearJobBossOffice(_source, job.name)
    if(not isNearBossOffice) then
        xPlayer.showNotification("Nejste dostatečně blízko!", {type = "error"})
        return
    end

    local vehicles = Society:GetSocietyVehicles(job.name, {"id"})
    if(not next(vehicles)) then
        xPlayer.showNotification("Společnost nemá žádné firemní vozidla!", {type = "error"})
        return
    end

    local isVehicleValid = DoesSocietyVehicleExist(vehicles, vehicleId)
    if(not isVehicleValid) then
        xPlayer.showNotification("Neplatné vozidlo!", {type = "error"})
        return
    end

    xPlayer.showNotification("Probíhá odebírání vozidla...")
    local affectedRows = MySQL.update.await("UPDATE owned_vehicles SET `owner` = ? WHERE `id` = ?", {
        nil,
        vehicleId
    })
    if(affectedRows <= 0) then
        xPlayer.showNotification("Při odebrání nastala chyba!", { type = "error" })
        return
    end
    
    Base:DiscordLog("BOSS_VEHICLES", "THE RAVE PROJECT - SPOLEČNOST - ODEPNUTÍ VOZIDLA", {
        { name = "Identifikace hráče", value = xPlayer.identifier },
        { name = "Společnost", value = jobName },
        { name = "ID vozidla", value = vehicleId },
    }, {
        fields = true
    })
    xPlayer.showNotification("Vozidlo úspěšně odebráno!", { type = "success" })
end)

RegisterNetEvent("strin_jobs:addMoney", function(jobName, amount)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    if(not tonumber(amount)) then
        return
    end

    if(not Jobs[jobName]) then
        return
    end

    local job = xPlayer.getJob()
    if(job.name ~= jobName or (job.grade_name ~= "boss" and job.grade_name ~= "manager")) then
        xPlayer.showNotification("K této akci nemáte dostatečné oprávnění!", {type = "error"})
        return
    end

    if(xPlayer.getMoney() < amount) then
        xPlayer.showNotification("Nemáte tolik peněz na vložení!", {type = "error"})
        return
    end
    
    local isNearBossOffice = IsNearJobBossOffice(_source, jobName)
    if(not isNearBossOffice) then
        xPlayer.showNotification("Nejste dostatečně blízko!", {type = "error"})
        return
    end

    xPlayer.removeMoney(tonumber(amount))
    local success = Society:AddSocietyMoney(jobName, tonumber(amount))
    if(not success) then
        xPlayer.showNotification(("Peníze se nezdařilo vložit do společnosti!"), {type = "error"})
        return
    end
    
    Base:DiscordLog("BOSS_BALANCE", "THE RAVE PROJECT - SPOLEČNOST - VLOŽENÍ DO SPOLEČNOSTI", {
        { name = "Identifikace hráče", value = xPlayer.identifier },
        { name = "Společnost", value = jobName },
        { name = "Částka", value = ESX.Math.GroupDigits(tonumber(amount)).."$" },
    }, {
        fields = true
    })

    xPlayer.showNotification(("Vložil jste do společnosti - %s$"):format(tonumber(amount)), {type = "success"})
end)

RegisterNetEvent("strin_jobs:removeMoney", function(jobName, amount)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    if(not tonumber(amount)) then
        return
    end

    if(not Jobs[jobName]) then
        return
    end

    local job = xPlayer.getJob()
    if(job.name ~= jobName or (job.grade_name ~= "boss" and job.grade_name ~= "manager")) then
        xPlayer.showNotification("K této akci nemáte dostatečné oprávnění!", {type = "error"})
        return
    end
    
    local isNearBossOffice = IsNearJobBossOffice(_source, jobName)
    if(not isNearBossOffice) then
        xPlayer.showNotification("Nejste dostatečně blízko!", {type = "error"})
        return
    end
    
    local society = Society:GetSociety(jobName)
    if(not society) then
        return
    end
    
    if((society.balance - tonumber(amount)) < 0) then
        xPlayer.showNotification("Tolik peněz ze společnosti nelze vzít!", {type = "error"})
        return
    end

    xPlayer.addMoney(tonumber(amount))
    local success = Society:RemoveSocietyMoney(jobName, tonumber(amount))
    if(not success) then
        xPlayer.showNotification(("Peníze se nezdařilo vzít do společnosti!"), {type = "error"})
        return
    end
    
    Base:DiscordLog("BOSS_BALANCE", "THE RAVE PROJECT - SPOLEČNOST - VÝBĚR ZE SPOLEČNOSTI", {
        { name = "Identifikace hráče", value = xPlayer.identifier },
        { name = "Společnost", value = jobName },
        { name = "Částka", value = ESX.Math.GroupDigits(tonumber(amount)).."$" },
    }, {
        fields = true
    })

    xPlayer.showNotification(("Vybral jste ze společnosti - %s$"):format(tonumber(amount)), {type = "success"})
end)

RegisterNetEvent("strin_jobs:updateLabel", function(jobName, label)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    if(not type(label) == "string") then
        return
    end

    if(not Jobs[jobName]) then
        return
    end

    local job = xPlayer.getJob()
    if(job.name ~= jobName or (job.grade_name ~= "boss" and job.grade_name ~= "manager")) then
        xPlayer.showNotification("K této akci nemáte dostatečné oprávnění!", {type = "error"})
        return
    end
    
    local isNearBossOffice = IsNearJobBossOffice(_source, jobName)
    if(not isNearBossOffice) then
        xPlayer.showNotification("Nejste dostatečně blízko!", {type = "error"})
        return
    end
    
    local label = ESX.SanitizeString(tostring(label))

    local success = Society:ChangeSocietyLabel(jobName, label)
    if(not success) then
        xPlayer.showNotification(("Název společnosti se nepodařilo změnit."), {type = "error"})
        return
    end
    
    Base:DiscordLog("BOSS_UPDATE", "THE RAVE PROJECT - SPOLEČNOST - ÚPRAVA SPOLEČNOSTI", {
        { name = "Identifikace hráče", value = xPlayer.identifier },
        { name = "Společnost", value = jobName },
        { name = "Nový název", value = label },
    }, {
        fields = true
    })

    xPlayer.showNotification(("Název společnosti úspěšně upraven!"), {type = "success"})
end)

RegisterNetEvent("strin_jobs:updateGrade", function(jobName, grade, changes)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end

    if(not changes or not next(changes) or (not changes.salary and not changes.label) or not ESX.DoesJobExist(jobName, grade)) then
        return
    end

    if(not Jobs[jobName]) then
        return
    end

    local job = xPlayer.getJob()
    if(job.name ~= jobName or (job.grade_name ~= "boss" and job.grade_name ~= "manager")) then
        xPlayer.showNotification("K této akci nemáte dostatečné oprávnění!", {type = "error"})
        return
    end
    
    local isNearBossOffice = IsNearJobBossOffice(_source, jobName)
    if(not isNearBossOffice) then
        xPlayer.showNotification("Nejste dostatečně blízko!", {type = "error"})
        return
    end
    
    if(changes.label) then
        changes.label = type(changes.label) == "string" and ESX.SanitizeString(changes.label) or ""
    end
    if(changes.salary) then
        changes.salary = type(tonumber(changes.salary)) == "number" and tonumber(changes.salary) or 0
    end

    local success = Society:UpdateSocietyGrade(jobName, tonumber(grade), changes)
    if(not success) then
        xPlayer.showNotification(("Hodnost se nepodařilo změnit."), {type = "error"})
        return
    end
    Base:DiscordLog("BOSS_UPDATE", "THE RAVE PROJECT - SPOLEČNOST - ÚPRAVA HODNOSTI", {
        { name = "Identifikace hráče", value = xPlayer.identifier },
        { name = "Společnost", value = jobName },
        { name = "Index hodnosti", value = tonumber(grade) },
        { name = "Změny", value = json.encode(changes) },
    }, {
        fields = true
    })
    xPlayer.showNotification(("Hodnost úspěšně upravena!"), {type = "success"})
end)

lib.callback.register("strin_jobs:getTotalCost", function(source, jobName)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local totalCost = 0
    if(not xPlayer) then
        return -1
    end
    local society = Society:GetSociety(jobName)
    if(not Jobs[jobName] or not society) then
        return -1
    end
    local users = MySQL.query.await("SELECT `identifier`, `job`, `job_grade` FROM users`")
    if(not users or not next(users)) then
        return -1
    end
    for i=1, #users do
        local user = users[i]
        local userPlayer = ESX.GetPlayerFromIdentifier(user.identifier)
        if(userPlayer) then
            user.job = userPlayer.getJob().name
            user.job_grade = userPlayer.getJob().grade
        end
        totalCost += society.grades[user.job_grade].salary
    end
    return totalCost
end)

function IsNearJobBossOffice(playerId, jobName)
    local isNear = false
    local ped = GetPlayerPed(playerId)
    local coords = GetEntityCoords(ped)
    local offices = Jobs[jobName].Zones.BossOffices or {}
    for i=1, #offices do
        local distance = #(coords - offices[i])
        if(distance < 10) then
            isNear = true
            break
        end
    end
    return isNear
end

function DoesSocietyVehicleExist(vehicles, vehicleId)
    local vehicleFound = false
    for i=1, #vehicles do
        local vehicle = vehicles[i]
        if(vehicle.id == vehicleId) then
            vehicleFound = true
            break
        end
    end
    return vehicleFound
end