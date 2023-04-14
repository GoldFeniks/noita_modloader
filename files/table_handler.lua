dofile_once("mods/modloader/files/base.lua")
dofile_once("mods/modloader/files/utils.lua")
dofile_once("mods/modloader/files/loaded_descriptor.lua")
dofile_once("mods/modloader/files/boundable_function.lua")
dofile_once("mods/modloader/files/table_item_descriptor.lua")

table_handler = base:new()
table_handler.__index = table_handler
table_handler.__name = "table_handler"
table_handler.__descriptors = {}

table_handler.__new = function (self, table)
    local object = base.new(self, { __table=table, __removed={} })
    object.__index = object

    return object
end

table_handler.find = make_smart_function(function (self, id)
    local descriptor = self.__descriptors[id]
    if descriptor == nil then
        for _, item in ipairs(self.__table) do
            if item.id == id then
                descriptor = table_item_descriptor:new(item)
                break
            end
        end

        if descriptor == nil then
            return nil
        end

        table_handler.__descriptors[id] = descriptor
    end

    descriptor.accessed_by[self.loader.mod_id] = true
    return loaded_descriptor:new({ descriptor=descriptor, loader=self.loader })
end, { "self", "id" })

table_handler.add = make_smart_function(function (self, item)
    local id = item.id
    if id == nil then
        error("Trying to add item without id")
    end

    local old = self:find(id)
    if old ~= nil then
        error(string.format("Item with id \"%s\" already exists", id))
    end

    local descriptor = table_item_descriptor:new(item)
    descriptor.accessed_by[self.loader.mod_id] = true
    table_handler.__descriptors[id] = descriptor

    table.insert(self.__table, item)

    return descriptor
end, { "self" })

table_handler.remove = make_smart_function(function (self, ids)
    local ids_set = {}
    for _, item in ipairs(ids) do
        ids_set[item] = -1
    end

    local idx = {}    
    for i, item in ipairs(self.__table) do
        if ids_set[item.id] then
            table.insert(idx, i)            
        end
    end

    if #idx == 0 then
        return false
    end

    table.sort(idx)

    for i=#idx,1,-1 do
        local ind = idx[i]
        self.__removed[self.__table[ind].id] = { by=self.loader.mod_id, value=self.__table[ind] }
        table.remove(self.__table, idx[i])
    end

    return true
end, { "self" })

table_handler.boundable_function = boundable_function
