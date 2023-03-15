dofile_once("mods/modloader/files/base.lua")
dofile_once("mods/modloader/files/utils.lua")
dofile_once("mods/modloader/files/modloader.lua")
dofile_once("mods/modloader/files/loaded_descriptor.lua")
dofile_once("mods/modloader/files/function_descriptor.lua")

functions = base:new()
functions.__index = functions
functions.__name = "functions"
functions.__descriptors = {}

functions.__get_descriptor = function (self, name)
    local descriptor = self.__descriptors[name]

    if descriptor ~= nil then
        return descriptor
    end

    descriptor = function_descriptor:new(name, _G[name])

    _G[name] = descriptor
    self.__descriptors[name] = descriptor

    return descriptor
end

functions.load = make_smart_function(function (self, name)
    local descriptor = self:__get_descriptor(name)

    return loaded_descriptor:new({ descriptor=descriptor, loader=self.loader })
end, { "self", "name" })

functions.append = make_smart_function(function (self, name, func)
    return self:__get_descriptor(name):append(func, self.loader.mod_id)
end, { "self", "name", "func" })

functions.disable_original = make_smart_function(function (self, name)
    return self:__get_descriptor(name):disable_original(self.loader.mod_id)
end, { "self", "name" })

functions.enable_original = make_smart_function(function (self, name)
    return self:__get_descriptor(name):enable_original(self.loader.mod_id)
end, { "self", "name" })

functions.original_enabled_by = make_smart_function(function (self, name)
    return self:__get_descriptor(name):original_enabled_by()
end, { "self", "name" })

functions.original_disabled_by = make_smart_function(function (self, name)
    return self:__get_descriptor(name):original_disabled_by()
end, { "self", "name" })

functions.original_enabled = make_smart_function(function (self, name)
    return self:__get_descriptor(name):original_enabled()
end, { "self", "name" })

functions.replace = make_smart_function(function (self, name, func)
    return self:__get_descriptor(name):replace(func, self.loader.mod_id)
end, { "self", "name", "func" })

functions.remove_changes = make_smart_function(function (self, name)
    return self:__get_descriptor(name):remove_changes(self.loader.mod_id)
end, { "self", "name" })

functions.handle_returns = make_smart_function(function (self, name, func, overwrite)
    return self:__get_descriptor(name):handle_returns(func, overwrite, self.loader.mod_id)
end, { "self", "name", "func", "overwrite" }, { overwrite=false })

functions.update_return = make_smart_function(function (self, name, func)
    return self:__get_descriptor(name):handle_returns(func, self.loader.mod_id)
end, { "self", "name", "func" })

modloader.__subclasses['functions'] = functions
