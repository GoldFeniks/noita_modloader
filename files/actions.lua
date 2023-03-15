if actions == nil then
    dofile_once("data/scripts/gun/gun_actions.lua")
end

dofile_once("mods/modloader/files/base.lua")
dofile_once("mods/modloader/files/utils.lua")
dofile_once("mods/modloader/files/modloader.lua")
dofile_once("mods/modloader/files/boundable_action.lua")
dofile_once("mods/modloader/files/action_descriptor.lua")
dofile_once("mods/modloader/files/loaded_descriptor.lua")

local _actions = base:new()
_actions.__index = _actions
_actions.__descriptors = {}

_actions.find = make_smart_function(function (self, id)
    local descriptor = self.__descriptors[id]
    if descriptor == nil then
        for i, action in ipairs(actions) do
            if action.id == id then
                descriptor = action_descriptor:new(action)
                descriptor.accessed_by[self.loader.mod_id] = true
                break
            end
        end

        _actions.__descriptors[id] = descriptor
    end

    descriptor.accessed_by[self.loader.mod_id] = true
    return loaded_descriptor:new({ descriptor=descriptor, loader=self.loader })
end, { "self", "id" })

_actions.add = make_smart_function(function (self, action)
    local id = action.id
    if id == nil then
        error("Trying to add action without id")
    end

    local old = self:find(id)
    if old ~= nil then
        error("Action with id \"" .. id .. "\" already exists")
    end

    local descriptor = action_descriptor:new(action)
    descriptor.accessed_by[self.loader.mod_id] = true
    _actions.__descriptors[id] = descriptor

    table.insert(actions, action)

    return descriptor
end, { "self", "action" })

_actions.remove = make_smart_function(function (self, id)
    for i, action in ipairs(actions) do
        if action.id == id then
            table.remove(actions, i)
            return true
        end
    end

    return false
end, { "self", "id" })

_actions.boundable_action = boundable_action
modloader.__subclasses['actions'] = _actions
