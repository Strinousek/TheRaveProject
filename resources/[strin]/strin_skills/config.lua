REDUCE_TIMER = 120000
SKILLS = {
    ["stamina"] = {
        label = "Výdrž",
        tooltip = "Výdrž zvyšujete za pomocí jízdy na kole, běhání nebo klusáním.",
        reduce = -0.01,
        default = 25.0,
        effect = function(value)
            local newValue = 0
            if value > 0 then
                newValue = math.floor(value / 1.25)

                if newValue < 0 then
                    newValue = 0
                end
            end

            StatSetInt(`MP0_STAMINA`, newValue, true)
        end
    },
    ["strength"] = {
        label = "Síla",
        tooltip = "Sílu můžete nabrat za pomocí posilovny.",
        reduce = -0.01,
        default = 25.0,
        effect = function(value)
            local newValue = 0
            if value > 0 then
                newValue = math.floor(value / 1.25)

                if newValue < 0 then
                    newValue = 0
                end
            end

            StatSetInt(`MP0_STRENGTH`, newValue, true)
        end
    },
    ["shooting"] = {
        label = "Střelba",
        tooltip = "Střelbu lze zlepšit za pomocí míření a střílení.",
        reduce = -0.01,
        default = 0.0,
        effect = function(value)
            local newValue = 0
            if value > 0 then
                newValue = math.floor(value / 1.25)

                if newValue < 0 then
                    newValue = 0
                end
            end

            StatSetInt(`MP0_SHOOTING_ABILITY`, newValue, true)
        end
    },
}