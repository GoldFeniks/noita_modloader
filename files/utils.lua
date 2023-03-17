table.pack   = table.pack or function(...) return { n = select("#", ...), ... } end
table.unpack = table.unpack or unpack

function parse_arguments(names, name_idx, defaults, ...)
    local values = table.pack(...)
    local arg = {}

    local idx = names[1] ~= "self" and 1 or 2
    if type(values[idx]) == "table" and #values == idx and getmetatable(values[idx]) == nil then
        arg = values[idx]
        values[idx] = arg[names[idx]]
    elseif #values > #names then
        arg = values[#names + 1]
    end    

    local result = {}
    for i=1,#names do
        result[i] = values[i] or arg[names[i]] or defaults[names[i]]
    end

    local extra = {}
    for key, value in pairs(arg) do
        if not name_idx[key] then
            extra[key] = value
        end
    end

    for key, value in pairs(defaults) do
        extra[key] = extra[key] or defaults[key]
    end

    result[#names + 1] = extra

    return result
end

function make_smart_function(func, names, defaults)
    defaults = defaults or {}
    local name_idx = {}
    for i, v in ipairs(names) do
        name_idx[v] = i
    end

    -- Imagine not being Nolla and being able to use debug
    -- local names = {}
    -- for i=1, debug.getinfo(func).nparams do
    --     table.insert(names, debug.getlocal(func, i))
    -- end

    return function (...)
        return func(table.unpack(parse_arguments(names, name_idx, defaults, ...), 1, #names + 1))   --table.unpack(arg)
    end
end
