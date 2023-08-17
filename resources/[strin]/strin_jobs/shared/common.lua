function DebugPrint(printMessage, ...)
    if(DEBUG_PRINT) then
        if((...) ~= nil) then
            print(printMessage:format(...))
        else
            print(printMessage)
        end
    end
end