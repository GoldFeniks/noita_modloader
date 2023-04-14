dofile_once("mods/modloader/files/base.lua")
dofile_once("mods/modloader/files/utils.lua")
dofile_once("mods/modloader/files/descriptor.lua")
dofile_once("mods/modloader/files/loaded_descriptor.lua")
dofile_once("mods/modloader/files/boundable_function.lua")
dofile_once("mods/modloader/files/function_descriptor.lua")

table_item_descriptor = descriptor:new()
table_item_descriptor.__name = "table_item_descriptor"

table_item_descriptor.__index = function (self, key)
    local value = table_item_descriptor[key]
    if value ~= nil then
        return value
    end

    value = self.__item[key]

    for _, name in ipairs(self.__functions) do
        if key == name then
            if value.__name ~= function_descriptor.__name and value.__name ~= loaded_descriptor.__name then
                local descriptor = function_descriptor:new(name, value)

                if self.loader then
                    descriptor = loaded_descriptor:new(descriptor, self.loader)
                end

                value = descriptor
            end
        end
    end

    return value
end

table_item_descriptor.__newindex = function (self, key, value)
    for _, name in ipairs(self.__functions) do
        if key == name then
            error(string.format("Cannot update %s function directly", name))
        end
    end

    self.__item[key] = value
end

table_item_descriptor.new = make_smart_function(function (self, item, functions)
    local d = { __item=item, __functions=functions or {} }

    for _, name in ipairs(d.__functions) do
        if item[name].__name == boundable_function.__name then
            item[name] = item[name]:bind(item)
        end
    end

    return descriptor.new(self, d)
end, { "self", "item", "functions" })
