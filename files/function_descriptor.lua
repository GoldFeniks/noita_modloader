dofile_once("mods/modloader/files/utils.lua")
dofile_once("mods/modloader/files/modloader.lua")
dofile_once("mods/modloader/files/descriptor.lua")

function_descriptor = descriptor:new()
function_descriptor.__index = function_descriptor
function_descriptor.__name = "function_descriptor"

function_descriptor.__call = function(self, ...)
    return self.__implementation(...)
end

function_descriptor.new = make_smart_function(function (self, name, func)
    func = {
        __name=name,
        __original_func=func,
        __original=func,
        __prepends={},
        __appends={},
        __update_return={}
    }

    func.__implementation = function(...)
        returns = {}

        for id, f in pairs(func.__prepends) do
            f(...)
        end

        if func.__original ~= nil then
            returns["__original"] = func.__original(...)
        end

        for id, f in pairs(func.__appends) do
            returns[id] = f(...)
        end

        local return_value = func.__handle_returns and func.handle_returns(returns) or returns["__original"] 

        for id, f in pairs(func.__update_return) do
            return_value = f(return_value, returns)
        end

        return return_value
    end

    return descriptor.new(self, func)
end, { "self", "name", "func" })

function_descriptor.prepend = make_smart_function(function (self, func, mod_id)
    self.__prepends[modloader.get_current_mod_id(mod_id, self.loader)] = func
end, { "self", "func", "mod_id" })

function_descriptor.append = make_smart_function(function (self, func, mod_id)
    self.__appends[modloader.get_current_mod_id(mod_id, self.loader)] = func
end, { "self", "func", "mod_id" })

function_descriptor.disable_original = make_smart_function(function (self, mod_id)
    if self.__original == nil then
        return false
    end

    self.__original = nil
    self.__enabled_by = nil
    self.__disabled_by = modloader.get_current_mod_id(mod_id, self.loader)
end, { "self", "mod_id" })

function_descriptor.enable_original = make_smart_function(function (self, mod_id)
    if self.__original ~= nil then
        return false
    end

    self.__original = self.__original_func
    self.__enabled_by = modloader.get_current_mod_id(mod_id, self.loader)
    self.__disabled_by = nil
end, { "self", "mod_id" })

function_descriptor.original_enabled_by = function (self)
    return self.__enabled_by
end

function_descriptor.original_dsiabled_by = function (self)
    return self.__disabled_by
end

function_descriptor.original_enabled = function (self)
    return self.__original ~= nil
end

function_descriptor.replace = make_smart_function(function (self, func, mod_id)
    self:disable_original(mod_id)

    self.appends = {}
    self.update_return = {}
    self.handle_returns = nil
    self.returns_handled_by = nil

    self:append(name, func, mod_id)
end, { "self", "func", "mod_id" })

function_descriptor.remove_changes = make_smart_function(function (self, mod_id)
    mod_id = modloader.get_current_mod_id(mod_id, self.loader)

    self.appends[mod_id] = nil
    self.update_return[mod_id] = nil

    if self.returns_handled_by == mod_id then
        self.returns_handled_by = nil
        self.handle_returns = nil
    end
end, { "self", "mod_id" })

function_descriptor.handle_returns = make_smart_function(function (self, func, overwrite, mod_id)
    if self.handle_returns ~= nil and not overwrite then
        return false
    end

    self.handle_returns = func
    self.returns_handled_by = modloader.get_current_mod_id(mod_id, self.loader)
    return true
end, { "self", "func", "overwrite", "mod_id" }, { overwrite=false })

function_descriptor.update_return = make_smart_function(function (self, func, mod_id)
    self.update_return[modloader.get_current_mod_id(mod_id, self.loader)] = func
end, { "self", "func", "mod_id" })
