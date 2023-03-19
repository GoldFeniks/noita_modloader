dofile_once("mods/modloader/files/base.lua")
dofile_once("mods/modloader/files/utils.lua")
dofile_once("mods/modloader/files/xml/xml.lua")
dofile_once("mods/modloader/files/modloader.lua")
dofile_once("mods/modloader/files/entity_descriptor.lua")

entities = base:new()
entities.__index = entities
entities.__descriptors = {}

entities.load = make_smart_function(function (self, path, mod_id)
    local descriptor = self.__descriptors[path]

    if descriptor == nil then
        descriptor = entity_descriptor:new(path)
        entities.__descriptors[path] = descriptor    
    end

    local name = modloader.get_current_mod_id(mod_id, self.loader)
    if name ~= nil then
        descriptor.accessed_by[name] = true
    end

    return descriptor
end, { "self", "path", "mod_id" })

entities.patch = make_smart_function(function (self, path, update)
    if type(update) == "string" then
        local patches = self.loader:__get_entity_patches_path()
        local content = ModTextFileGetContent(patches) or ""
        ModTextFileSetContent(patches, content .. path .. "\t" .. update .. "\n")
        return
    end

    local entity = self:load(path)
    update(entity, self.loader)
    entity:save()
end, { "self", "path", "update" })

modloader.__subclasses['entities'] = entities
