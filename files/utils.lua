table.pack   = table.pack or function(...) return { n = select("#", ...), ... } end
table.unpack = table.unpack or unpack

function parse_arguments(names, defaults, ...)
    local values = table.pack(...)
    local arg = {}

    local idx = names[1] ~= "self" and 1 or 2
    if type(values[idx]) == "table" and values.n == idx and getmetatable(values[idx]) == nil then
        arg = values[idx]
        values[idx] = arg[names[idx]]
    end

    setmetatable(arg, { __index=defaults })

    local result = {}
    for i=1,#names do
        result[i] = values[i] or arg[names[i]]
    end

    return result
end

function make_smart_function(func, names, defaults)
    defaults = defaults or {}

    -- Imagine not being Nolla and being able to use debug
    -- local names = {}
    -- for i=1, debug.getinfo(func).nparams do
    --     table.insert(names, debug.getlocal(func, i))
    -- end

    return function (...)
        return func(table.unpack(parse_arguments(names, defaults, ...), 1, #names))   --table.unpack(arg)
    end

    -- return result
end
