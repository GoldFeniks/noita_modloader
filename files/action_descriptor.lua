dofile_once("mods/modloader/files/utils.lua")
dofile_once("mods/modloader/files/descriptor.lua")
dofile_once("mods/modloader/files/boundable_action.lua")
dofile_once("mods/modloader/files/loaded_descriptor.lua")
dofile_once("mods/modloader/files/function_descriptor.lua")

action_descriptor = descriptor:new()
action_descriptor.__name = "action_descriptor"

action_descriptor.__index = function (self, key)
    local value = action_descriptor[key]
    if value ~= nil then
        return value
    end

    value = self.__action[key]

    if key == "action" then
        if value.__name ~= function_descriptor.__name and value.__name ~= loaded_descriptor.__name then
            local descriptor = function_descriptor:new("action", value)

            if self.loader then
                descriptor = loaded_descriptor:new(descriptor, self.loader)
            end

            value = descriptor
        end
    end

    return value
end

action_descriptor.__newindex = function (self, key, value)
    if key == "action" then
        error("Cannot update action function directly")
    end

    self.__action[key] = value
end

action_descriptor.new = make_smart_function(function (self, action)
    local d = { __action=action }    

    if action.action.__name == boundable_action.__name then
        action.action = action.action:bind(action)
    end

    return descriptor.new(self, d)
end, { "self", "action" })
