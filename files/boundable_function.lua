dofile_once("mods/modloader/files/base.lua")
dofile_once("mods/modloader/files/utils.lua")

boundable_function = base:new()
boundable_function.__index = boundable_function
boundable_function.__name = "boundable_function"

boundable_function.new = make_smart_function(function (self, func)
    return base.new(self, { func=func })
end, { "self", "func" })

boundable_function.bind = make_smart_function(function (self, value)
    return function()
        return self.func(value)
    end
end, { "self", "value" })
