RegisterCommand("shirt", function()
    TriggerServerEvent("strin_skin:updatePiece", "top")
end)

RegisterCommand("pants", function()
    TriggerServerEvent("strin_skin:updatePiece", "bottom")
end)

RegisterCommand("shoes", function()
    TriggerServerEvent("strin_skin:updatePiece", "boots")
end)