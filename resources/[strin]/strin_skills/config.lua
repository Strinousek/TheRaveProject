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
    }
}