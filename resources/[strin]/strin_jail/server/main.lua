JailedPlayers = {}

Citizen.CreateThread(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `jail` (
            `owner` VARCHAR(255) NOT NULL,
            `reason` VARCHAR(255) NULL DEFAULT NULL,
            `jailed_on` BIGINT(24) NULL DEFAULT NULL,
            `duration` INT(11) NOT NULL DEFAULT 0,

            PRIMARY KEY (`owner`),
            UNIQUE KEY (`owner`)
        )
    ]])
end)

AddEventHandler("esx:playerLoaded", function(playerId, xPlayer)
    local owner = xPlayer.identifier..":"..xPlayer.get("char_id")
    if(JailedPlayers[owner]) then
        -- jail that mf
        return
    end
    local jailData = MySQL.single.await("SELECT * FROM `jail` WHERE `owner` = ?", { owner })
    if(not jailData or not next(jailData)) then
        return
    end
    JailedPlayers[owner] = jailData
    -- jail that mf
end)