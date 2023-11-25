local CurrentMonthRewards = {}
local Base = exports.strin_base
local Inventory = exports.ox_inventory

local MONTHS = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 } 

function IsLeapYear(year) 
    if ((year % 4 == 0) and (year % 100 ~= 0)) or (year % 400 == 0) then 
        return true 
    end 
    return false 
end

function GetMonthMaxDays(month, year) 
    if (MONTHS[month]) then 
        if (month ~= 2 and not IsLeapYear(year)) then 
            return MONTHS[month] 
        else 
            return 29 
        end 
    end 
    return false 
end

function GetDayOfWeek(dd, mm, yy) 
    local days = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" }

    local mmx = mm

    if (mm == 1) then  mmx = 13; yy = yy-1  end
    if (mm == 2) then  mmx = 14; yy = yy-1  end

    local val8 = dd + (mmx*2) +  math.floor(((mmx+1)*3)/5)   + yy + math.floor(yy/4)  - math.floor(yy/100)  + math.floor(yy/400) + 2
    local val9 = math.floor(val8/7)
    local dw = val8-(val9*7)

    if (dw == 0) then
      dw = 7
    end

    return dw, days[dw]
end

Citizen.CreateThread(function()
    MySQL.query.await([[
        ALTER TABLE `users`
            ADD IF NOT EXISTS `rewards` LONGTEXT NULL DEFAULT NULL COLLATE 'latin1_swedish_ci';
    ]])

    local cachedRewards = {}
    local date = os.date("*t")
    local currentMonth = GetResourceKvpInt("currentMonth")
    local currentYear = GetResourceKvpInt("currentYear")
    if((not currentMonth or currentMonth == 0) or (not currentYear or currentYear == 0)) then
        local GeneratedRewards = {}
        for i=2023, 2040 do
            local months = {}
            for j=1, 12 do
                local days = {}
                for k=1, GetMonthMaxDays(j, i) do
                    local dayIndex, dayName = GetDayOfWeek(k, j, i)
                    math.randomseed(GetGameTimer() + math.random(10000, 99999))
                    local amount = (dayIndex == 5 or dayIndex == 6) and 1 or (100 * math.random(1, 3))
                    days[tostring(k)] = {
                        day = k,
                        type = (dayIndex == 5 or dayIndex == 6) and "lottery" or "cash",
                        amount = amount,
                    }
                end
                months[tostring(j)] = days
            end
            GeneratedRewards[tostring(i)] = months
        end
        cachedRewards = Base:LoadJSONFile(GetCurrentResourceName(), "rewards.json", json.encode(GeneratedRewards))
        currentMonth = tonumber(date.month)
        currentYear = tonumber(date.year)
        SetResourceKvpInt("currentMonth", currentMonth)
        SetResourceKvpInt("currentYear", currentYear)
    else
        cachedRewards = Base:LoadJSONFile(GetCurrentResourceName(), "rewards.json", json.encode({}))
    end
    if(tonumber(date.month) ~= currentMonth or tonumber(date.year) ~= currentYear) then
        currentMonth = tonumber(date.month)
        currentYear = tonumber(date.year)
        SetResourceKvpInt("currentMonth", currentMonth)
        SetResourceKvpInt("currentYear", currentYear)
        MySQL.query.await("UPDATE `users` SET `rewards` = ?", { "[]" })
    end
    CurrentMonthRewards = cachedRewards[tostring(currentYear)][tostring(currentMonth)]
    while true do
        local date = os.date("*t")
        if(tonumber(date.month) ~= currentMonth or tonumber(date.year) ~= currentYear) then
            currentMonth = tonumber(date.month)
            currentYear = tonumber(date.year)
            SetResourceKvpInt("currentMonth", currentMonth)
            SetResourceKvpInt("currentYear", currentYear)
            CurrentMonthRewards = cachedRewards[tostring(currentYear)][tostring(currentMonth)]
            MySQL.query.await("UPDATE `users` SET `rewards` = ?", { "[]" })
            break
        end
        Citizen.Wait(5000)
    end
end)

lib.callback.register("strin_rewards:getData", function(_source)
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return false
    end
    local rewards = MySQL.prepare.await("SELECT `rewards` FROM `users` WHERE `identifier` = ?", { xPlayer.identifier })
    if(not rewards) then
        rewards = {}
    else
        rewards = json.decode(rewards)
    end
    local data = {
        playedTime = xPlayer.get("played_time"),
        rewards = GetPlayerRewards(rewards)
    }
    return data
end)

lib.callback.register("strin_rewards:claimReward", function(_source, day)
    if(type(day) ~= "number" or not tonumber(day)) then
        return false
    end
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return false
    end
    local date = os.date("*t")
    if(day < date.day or day > date.day) then
        xPlayer.showNotification("Tato odměna již / ještě není odemčená!", { type = "error" })
        return false
    end
    local rewards = MySQL.prepare.await("SELECT `rewards` FROM `users` WHERE `identifier` = ?", { xPlayer.identifier })
    if(not rewards) then
        rewards = {}
    else
        rewards = json.decode(rewards)
    end
    local formattedRewards = GetPlayerRewards(rewards)
    local isClaimed = false
    for i=1, #formattedRewards do
        local reward = formattedRewards[i]
        if(reward.day == day) then
            if(reward.claimed) then
                isClaimed = true
                break
            else
                if(not Inventory:AddItem(_source, reward.type == "cash" and "money" or "lottery_ticket", reward.amount)) then
                    xPlayer.showNotification("Odměnu nelze vyzvednout!", { type = "error" })
                    return false
                end
                table.insert(rewards, reward.day)
                MySQL.prepare.await("UPDATE `users` SET `rewards` = ? WHERE `identifier` = ?", { json.encode(rewards), xPlayer.identifier })
                xPlayer.showNotification(("Vyzvedl/a jste odměnu za den - %s!"):format(reward.day), { type = "success" })
                break
            end
        end
    end
    if(isClaimed) then
        xPlayer.showNotification("Tuto odměnu jste si již vyzvedl/a!", { type = "error" })
        return false
    end

    return GetPlayerRewards(rewards)
end)

function GetPlayerRewards(playerRewards)
    local rewards = {}
    for day, data in each(CurrentMonthRewards) do
        local reward = {
            day = tonumber(day),
        }
        local claimed = false
        for i=1, #playerRewards do
            if(playerRewards[i] == reward.day) then
                claimed = true
                break
            end
        end
        reward.claimed = claimed
        reward.amount = data.amount
        reward.type = data.type
        table.insert(rewards, reward)
    end
    table.sort(rewards, function(a,b )
        return a.day < b.day
    end)
    return rewards
end