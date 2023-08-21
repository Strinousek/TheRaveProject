SocietiesLoaded = false
Societies = {}
Characters = exports.strin_characters
/*
    Societies = {
        police = {
            name = "police",
            label = "Police Department",
            balance = 100,
            grades = {
                {
                    grade = 1,
                    name = "cadet",
                    label = "Kadet",
                    salary = 100
                }
            }
            ---
            employees = {
                [1] = {
                    grade = 1,
                    identifier = "xxx",
                    char_id = 1
                }
            }
        }
    }
*/

Citizen.CreateThread(function()
    local PreparedJobs = {}
    local jobs = MySQL.query.await("SELECT * FROM jobs")

    if(jobs and next(jobs)) then
        for _,v in pairs(jobs) do
            PreparedJobs[v.name] = {
                name = v.name,
                label = v.label,
                balance = v.balance,
                grades = {}
            }
        end
        local grades = MySQL.query.await("SELECT * FROM job_grades")
        if(grades and next(grades)) then
            for _,v in pairs(grades) do
                PreparedJobs[v.job_name].grades[v.grade] = {
                    label = v.label,
                    grade = v.grade,
                    name = v.name,
                    salary = v.salary,
                }
            end
        end
    end
    
    for _,job in pairs(PreparedJobs) do
        CreateSociety(job.name, job.label, job.balance, job.grades)
    end
    StartPaycheck()
    SocietiesLoaded = true
end)

function CreateSociety(name, label, balance, grades, isNewSociety)
    if(Societies[name]) then
        return
    end

    Societies[name] = {
        name = name,
        label = label,
        balance = balance,
        grades = grades,
    }
    if(isNewSociety) then
        TriggerEvent("strin_society:societyCreated", Societies[name])
    end
end

function CreateNewSociety(name, label, balance, grades)
    if(Societies[name]) then
        return
    end
    MySQL.prepare.await("INSERT IGNORE INTO `jobs` SET `name` = ?, `label` = ?, `balance` = ?", {
        name,
        ESX.SanitizeString(label),
        balance,
    })
    for k,v in pairs(grades) do
        MySQL.prepare.await("INSERT INTO job_grades SET `job_name` = ?, `grade` = ?, `name` = ?, `label` = ?, `salary` = ?", {
            name,
            v.grade or tonumber(k),
            v.name or "casual",
            v.label,
            v.salary or 0
        })
    end
    CreateSociety(name, label, balance, grades, true)
end

exports("CreateNewSociety", CreateNewSociety)

function ChangeSocietyLabel(societyName, label)
    if(not Societies[societyName]) then
        return
    end
    local label = ESX.SanitizeString(label)
    Societies[societyName].label = label
    TriggerEvent("strin_society:societyChange", Societies[societyName])
    local xPlayers = ESX.GetExtendedPlayers("job", societyName)
    for _, xPlayer in pairs(xPlayers) do
        local job = xPlayer.getJob()
        xPlayer.setJob(societyName, job.grade)
    end
    MySQL.update.await("UPDATE jobs SET `label` = ? WHERE `name` = ?", {
        label,
        societyName
    })
    return label
end

exports("ChangeSocietyLabel", ChangeSocietyLabel)

function UpdateSocietyGrade(societyName, grade, changes)
    if(not Societies[societyName]) then
        return
    end
    if(not Societies[societyName].grades[grade]) then
        return
    end
    if(not changes or not next(changes)) then
        return
    end

    local hasChanged = false
    if(changes.label) then
        hasChanged = true
        Societies[societyName].grades[grade].label = ESX.SanitizeString(changes.label)
    end
    if(changes.salary) then
        hasChanged = true
        Societies[societyName].grades[grade].salary = tonumber(changes.salary)
    end

    if(hasChanged) then
        TriggerEvent("strin_society:societyChange", Societies[societyName])
        local xPlayers = ESX.GetExtendedPlayers("job", societyName)
        for _, xPlayer in pairs(xPlayers) do
            local job = xPlayer.getJob()
            if(job.grade == grade) then
                xPlayer.setJob(societyName, grade)
            end
        end
        if(changes.label and changes.salary) then
            MySQL.update.await("UPDATE job_grades SET `label` = ?, `salary` = ? WHERE `job_name` = ? AND `grade` = ?", {
                Societies[societyName].grades[grade].label,
                Societies[societyName].grades[grade].salary,
                societyName,
                grade
            })
            return true
        end
        if(changes.label) then
            MySQL.update.await("UPDATE job_grades SET `label` = ? WHERE `job_name` = ? AND `grade` = ?", {
                Societies[societyName].grades[grade].label,
                societyName,
                grade
            })
            return true
        end
        if(changes.salary) then
            MySQL.update.await("UPDATE job_grades SET `salary` = ? WHERE `job_name` = ? AND `grade` = ?", {
                Societies[societyName].grades[grade].salary,
                societyName,
                grade
            })
            return true
        end
    end
end

exports("UpdateSocietyGrade", UpdateSocietyGrade)

function SetSocietyMoney(societyName, money, mode)
    local society = Societies[societyName]
    if(not society) then
        return
    end
    local money = tonumber(money)
    if(not money) then
        return
    end
    if(mode == "REMOVE") then
        if(society.balance - money <= 0) then
            society.balance = 0
        else
            society.balance -= money
        end
    elseif(mode == "ADD") then
        society.balance += money
    else
        society.balance = money
    end
    society.balance = math.floor(society.balance + 0.5)
    TriggerEvent("strin_society:societyChange", society)
    MySQL.update.await("UPDATE `jobs` SET `balance` = ? WHERE `name` = ?", { society.balance, societyName })
    return society.balance
end

exports("SetSocietyMoney", SetSocietyMoney)

function RemoveSocietyMoney(societyName, money)
    return SetSocietyMoney(societyName, money, "REMOVE")
end

exports("RemoveSocietyMoney", RemoveSocietyMoney)

function AddSocietyMoney(societyName, money)
    return SetSocietyMoney(societyName, money, "ADD")
end

exports("AddSocietyMoney", AddSocietyMoney)

function FireSocietyEmployee(societyName, identifier, characterId)
    local society = Societies[societyName]
    if(not society) then
        return
    end
    if(not identifier or not characterId) then
        return
    end
    
    local currentCharacter = Characters:GetCurrentCharacter(identifier)
    if(not currentCharacter.char_id == characterId) then
        local employeeCharacter = Characters:GetSpecificCharacter(identifier, characterId)
        if(employeeCharacter.job == societyName or employeeCharacter.job == ("off_"..societyName)) then
            local result = MySQL.update.await("UPDATE characters SET `job` = ?, `job_grade` = ? WHERE `identifier` = ? AND `char_id` = ?", {
                "unemployed",
                1,
                identifier,
                characterId
            })
            return true
        end
        local otherJobs = {}
        for job,grade in pairs(employeeCharacter.other_jobs) do
            if(job ~= societyName and job ~= ("off_"..societyName)) then
                otherJobs[job] = grade
            end
        end
        local result = MySQL.update.await("UPDATE characters SET `other_jobs` = ? WHERE `identifier` = ? AND `char_id` = ?", {
            json.encode(otherJobs),
            identifier,
            characterId
        })
        return true
    end

    if(currentCharacter.job ~= societyName and currentCharacter.job ~= ("off_"..societyName)) then
        local otherJobs = {}
        for job,grade in pairs(currentCharacter.other_jobs) do
            if(job ~= societyName and job ~= ("off_"..societyName)) then
                otherJobs[job] = grade
            end
        end
        MySQL.update.await("UPDATE users SET `other_jobs` = ? WHERE `identifier` = ?", {
            json.encode(otherJobs),
            identifier
        })
        return true
    end

    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
    if(not xPlayer) then
        MySQL.update.await("UPDATE users SET `job` = ?, `job_grade` = ? WHERE `identifier` = ?", {
            "unemployed",
            1,
            identifier
        })
        return true
    end

    xPlayer.setJob("unemployed", 1)
    return true
end

exports("FireSocietyEmployee", FireSocietyEmployee)

function HireSocietyEmployee(societyName, identifier, grade)
    local society = Societies[societyName]
    if(not society) then
        return
    end

    local grade = tonumber(grade)
    if(not society.grades[grade]) then
        return
    end

    local employeePlayer = ESX.GetPlayerFromIdentifier(identifier)
    if(not employeePlayer) then
        return
    end

    local currentCharacter = Characters:GetCurrentCharacter(identifier, true)
    if(not currentCharacter) then
        return
    end
    
    if(currentCharacter.job ~= "unemployed") then
        local otherJobs = {}
        otherJobs[job.name] = job.grade
        if(currentCharacter.other_jobs) then
            local oldOtherJobs = json.decode(currentCharacter.other_jobs or "{}")
            for otherJob, otherJobGrade in pairs(oldOtherJobs) do
                otherJobs[otherJob] = otherJobGrade
            end
        end
        MySQL.update.await("UPDATE users SET `other_jobs` = ? WHERE `identifier` = ?", {
            json.encode(otherJobs),
            identifier
        })
        employeePlayer.setJob(societyName, grade)
        return true
    end
    employeePlayer.setJob(societyName, grade)
    return true
end

exports("HireSocietyEmployee", HireSocietyEmployee)

function UpdateSocietyEmployee(societyName, identifier, characterId, grade)
    local society = Societies[societyName]
    if(not society) then
        return
    end

    local grade = tonumber(grade)
    if(not society.grades[grade]) then
        return
    end

    local employeeCharacter = Characters:GetSpecificCharacter(identifier, characterId, true)
    if(not employeeCharacter) then
        return
    end

    if(employeeCharacter.job ~= societyName and employeeCharacter.job ~= "off_"..societyName) then
        local otherJobs = {}
        if(employeeCharacter.other_jobs) then
            local oldOtherJobs = json.decode(employeeCharacter.other_jobs or "{}")
            for otherJob, otherGrade in pairs(oldOtherJobs) do
                otherJobs[otherJob] = otherGrade
            end
        end
        if(not otherJobs[societyName] and not otherJobs["off_"..societyName]) then
            return
        end
        if(otherJobs["off_"..societyName]) then
            otherJobs["off_"..societyName] = grade
        else
            otherJobs[societyName] = grade
        end
        local activeCharId = MySQL.scalar.await("SELECT `char_id` FROM users WHERE `identifier` = ?", {
            identifier
        })
        if(not activeCharId) then
            return
        end
        local databaseTable = activeCharId == employeeCharacter.char_id and "users" or "characters"
        MySQL.update.await("UPDATE ? SET `other_jobs` = ? WHERE `identifier` = ?", {
            databaseTable,
            json.encode(otherJobs),
            identifier
        })
        return true
    end
    
    local employeePlayer = ESX.GetPlayerFromIdentifier(identifier)
    if(not employeePlayer) then
        local job = MySQL.scalar.await("SELECT `job` FROM `users` WHERE `identifier` = ?", {
            identifier
        })
        
        MySQL.update.await("UPDATE users SET `job` = ?, `job_grade` = ? WHERE `identifier` = ?", {
            (job:find("off_") and "off_" or "")..societyName,
            grade,
            identifier
        })
        return true
    end
    if(employeePlayer.getJob().name:find("off_")) then
        employeePlayer.setJob("off_"..societyName, grade)
    else
        employeePlayer.setJob(societyName, grade)
    end
    return true
end

exports("UpdateSocietyEmployee", UpdateSocietyEmployee)

function GetSocietyEmployees(societyName)
    local users = MySQL.query.await("SELECT job, job_grade, other_jobs, identifier, char_id, firstname, lastname FROM users")
    local usersFoundEmployees = SelectEmployees(societyName, SyncActiveUsers(users))
    local characters = MySQL.query.await("SELECT job, job_grade, other_jobs, identifier, char_id, firstname, lastname FROM characters")
    local charactersFoundEmployees = SelectEmployees(societyName, characters, function(employee)
        for i=1, #usersFoundEmployees do
            local userEmployee = usersFoundEmployees[i]
            if(
                userEmployee.identifier == employee.identifier and
                userEmployee.char_id == employee.char_id
            ) then
                return false
            end
        end
        return true
    end)
    return lib.table.merge(usersFoundEmployees, charactersFoundEmployees)
end

exports("GetSocietyEmployees", GetSocietyEmployees)

function SyncActiveUsers(users)
    local syncedUsers = {}
    if(users and next(users)) then
        for _,user in pairs(users) do
            local xPlayer = ESX.GetPlayerFromIdentifier(user.identifier)
            if(xPlayer) then
                user.job = xPlayer.getJob().name
                user.job_grade = xPlayer.getJob().grade
            end
            syncedUsers[#syncedUsers + 1] = user
        end
    end
    return syncedUsers
end

function SelectEmployees(societyName, characters, condition)
    local employees = {}
    if(characters and next(characters)) then
        local characterGrade = -1
        for i=1, #characters do
            local character = characters[i]
            local isEmployee = false
            if(character.job == societyName or character.job == "off_"..societyName) then
                characterGrade = character.job_grade
                isEmployee = true
            end
            if(not isEmployee) then
                local otherJobs = json.decode(character.other_jobs or "{}")
                for job,grade in pairs(otherJobs) do
                    if(job == societyName and job == ("off_"..societyName)) then
                        characterGrade = grade
                        isEmployee = true
                    end
                end
            end
            if(isEmployee) then
                local employee = CreateEmployee(
                    character.identifier, 
                    character.char_id,
                    characterGrade,
                    character.firstname,
                    character.lastname
                )
                if(condition == nil or (condition and condition(employee))) then
                    employees[#employees+1] = employee
                end
            end
        end
    end
    return employees
end

function CreateEmployee(identifier, characterId, grade, firstName, lastName)
    return {
        identifier = identifier,
        char_id = characterId,
        job_grade = grade,
        fullname = firstName.." "..lastName
    }
end

function GetSociety(societyName)
    return Societies[societyName]
end

exports("GetSociety", GetSociety)

function GetSocieties()
    return Societies
end

exports("GetSocieties", GetSocieties)

function GetSocietyVehicles(societyName, columns)
    if(not Societies[societyName]) then
        return {}
    end
    return MySQL.query.await(GenerateSelectVehiclesQuery(columns), {societyName})
end

function GenerateSelectVehiclesQuery(columns)
    local expressions = {}
    if(not columns) then
        expressions = {"*"}
    end
    if(type(columns) == "table") then
        for _,column in pairs(columns) do
            expressions[#expressions + 1] = "`"..column.."`"
        end
    elseif(type(columns) == "string") then
        expressions[#expressions + 1] = "`"..columns.."`"
    end
    return ("SELECT %s FROM owned_vehicles WHERE `job` = ?"):format(table.concat(expressions, ","))
end

exports("GetSocietyVehicles", GetSocietyVehicles)

lib.callback.register("strin_society:getSociety", function(source, societyName)
    return GetSociety(societyName)
end)

lib.callback.register("strin_society:getSocietyEmployees", function(source, societyName)
    if(GetSociety(societyName)) then
        return GetSocietyEmployees(societyName)
    end
    return nil
end)

ESX.RegisterCommand("refreshsociety", "admin", function()
    ESX.RefreshJobs()
end)