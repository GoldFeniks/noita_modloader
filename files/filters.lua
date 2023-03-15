dofile_once("mods/modloader/files/utils.lua")

filters = {}

filters.contains = make_smart_function(function (pattern)
    return function (value)
        return string.find(value, pattern) ~= nil
    end
end, { "pattern" })


function filters.all(...)
    conditions = table.pack(...)

    return function (value)
        for i, checker in ipairs(conditions) do
            if not checker(value) then
                return false
            end
        end

        return true
    end
end
 