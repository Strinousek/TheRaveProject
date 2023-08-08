local StrinJobs = exports.strin_jobs

lib.callback.register("strin_personalmenu:getCharacterData", function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return nil
    end
    return {
        firstname = xPlayer.get("firstname"),
        lastname = xPlayer.get("lastname"),
        fullname = xPlayer.get("fullname"),
        dateofbirth = xPlayer.get("dateofbirth"),
        sex = xPlayer.get("sex"),
        height = xPlayer.get("height"),
        weight = xPlayer.get("weight"),
        job = xPlayer.getJob(),
        money = xPlayer.getMoney(),
        bank = xPlayer.getAccount('bank').money
    }
end)

lib.callback.register("strin_personalmenu:getCharacterBills", function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return {}
    end
    return StrinJobs:GetCharacterBills(xPlayer.identifier, xPlayer.get("char_id"))
end)