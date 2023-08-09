
-- // TAKEN FROM DISC-BASE (very useful)
function getOrElse(value, default)
    if value ~= nil then
        return value
    else
        return default
    end
end
-- //

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end
