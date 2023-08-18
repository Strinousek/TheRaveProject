AddEventHandler("skinchanger:getSkin", function(playerId, cb)
    cb(GetSkin(playerId))
end)

function GetSkin(playerId)
    return lib.callback.await("skinchanger:getNetSkin", playerId)
end

exports("GetSkin", GetSkin)

AddEventHandler("skinchanger:getData", function(playerId, cb)
    cb(GetData(playerId))
end)

function GetData(playerId)
    return lib.callback.await("skinchanger:getNetData", playerId)
end

exports("GetData", GetData)

function GetComponents(playerId)
    return Components
end

exports("GetComponents", GetComponents)

function GetComponent(playerId, componentName)
    return lib.callback.await("skinchanger:getNetComponent", playerId, componentName)
end

exports("GetComponent", GetComponent)