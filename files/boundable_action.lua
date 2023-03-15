dofile_once("mods/modloader/files/base.lua")
dofile_once("mods/modloader/files/utils.lua")

boundable_action = base:new()
boundable_action.__index = boundable_action
boundable_action.__name = "boundable_action"

boundable_action.new = make_smart_function(function (self, func)
    return base.new(self, { func=func })
end, { "self", "func" })

boundable_action.bind = make_smart_function(function (self, action)
    return function()
        return self.func(action)
    end
end, { "self", "action" })
