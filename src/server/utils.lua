function debug(...)
    if not Config.debugMode then return end
    
    print("stl_bankingsystem:" .. ...)
end

function typeMustBe(variable, typeNeeded)
    if not variable then return debug("variable missing") end

    return type(variable) == typeNeeded
end

function splitString(input, separator)
    if not separator then
        separator = "%s"
    end

    local result = {}

    for string in string.gmatch(input, "([^" .. separator .. "]+)") do
        result[#result + 1] = string
    end
    
    return result
end