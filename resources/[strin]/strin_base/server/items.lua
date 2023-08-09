local ListeningResources = {}

/*
    strin_drugs = {
        {
            item = "weed",
            event = "usedItem",
            cb = Func
        },
    }

*/

exports("RegisterItemListener", function(item, cb, options)
    local options = options or { event = "all" }
    if(not options.event) then
        options.event = "all"
    end
    local items = type(item) == "table" and item or { item }
    local resource = GetInvokingResource() or GetCurrentResourceName()
    if(not ListeningResources[resource]) then
        ListeningResources[resource] = {}
    end
    /*local overwrite = false
    for k,v in pairs(ListeningResources[resource]) do
        for _, selectedItem in pairs(items) do
            if(v.item == selectedItem) then
                if((v.event == options.event)) then
                    ListeningResources[resource][k].cb = cb
                    overwrite = true
                end
            end
        end
    end
    if(not overwrite) then
        for _, selectedItem in pairs(items) do
            table.insert(ListeningResources[resource], {
                item = selectedItem,
                event = options.event,
                cb = cb,
            })
        end
    end*/
    for _, selectedItem in pairs(items) do
        table.insert(ListeningResources[resource], {
            item = selectedItem,
            event = options.event,
            cb = cb,
        })
    end
end)

exports("use_item", function(event, item, inventory, slot, data)
    for resource,listeners in pairs(ListeningResources) do
        for listenerId, listener in pairs(listeners) do
            if(listener?.item == item.name and (listener?.event == event or listener?.event == "all")) then
                if(listener?.event == "all") then
                    listener?.cb(event, item, inventory, slot, data)
                else
                    listener?.cb(item, inventory, slot, data)
                end
            end
        end
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if(ListeningResources[resourceName]) then
        ListeningResources[resourceName] = {}
    end
end)