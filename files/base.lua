base = {}
base.__index = base

function base:new(object)
    local object = object or {}
    setmetatable(object, self)

    return object
end

return base
