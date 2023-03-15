dofile_once("mods/modloader/files/base.lua")
dofile_once("mods/modloader/files/utils.lua")
dofile_once("mods/modloader/files/constants.lua")
dofile_once("mods/modloader/files/templates.lua")

modloader = base:new()
modloader.__mods = {}
modloader.__name = "modloader"
modloader.__subclasses = {}
modloader.__allowed_subclasses = {
    "actions",
    "entities",
    "functions",
}

modloader.__index = function(self, key)
    local value = modloader[key]
    if value ~= nil then
        return value
    end

    local subclass = nil
    for i, value in ipairs(modloader.__allowed_subclasses) do
        if value == key then
            subclass = modloader.__subclasses[key]

            if subclass == nil then
                dofile_once(string.format("mods/modloader/files/%s.lua", key))
                subclass = modloader.__subclasses[key]
            end
        end
    end

    if subclass == nil then
        return nil
    end

    self[key] = subclass:new{ loader=self }
    return self[key]
end

modloader.new = make_smart_function(function (self, mod_id)
    if mod_id == nil then
        error("mod_id cannot be nil")
    end

    modloader.__current_mod_id = mod_id
    local mod = modloader.__mods[mod_id]
    if mod ~= nil then
        return mod
    end

    mod = base.new(self, { mod_id=mod_id })
    modloader.__mods[mod_id] = mod
    return mod
end, { "self", "mod_id" })

modloader.register = modloader.new

modloader.append = make_smart_function(function (self, path, file)
    local appends = self:__get_appends_path()
    local content = ModTextFileGetContent(appends) or ""
    ModTextFileSetContent(appends, content .. path .. "\t" .. file .. "\n")
end, { "self", "path", "file" })

modloader.finalize = function (self)
    local content = ModTextFileGetContent(MODLOADER_REGISTERED_PATH) or ""
    ModTextFileSetContent(MODLOADER_REGISTERED_PATH, content .. self.mod_id .. "\n")
end

modloader.get_current_mod_id = make_smart_function(function(mod_id, loader)
    return mod_id or loader and loader.mod_id or modloader.__current_mod_id
end, { "mod_id", "loader" })

modloader.__get_appends_path = function (self)
    return string.format(MOD_APPENDS_TEMPLATE, self.mod_id)
end

modloader.__get_entity_patches_path = function (self)
    return string.format(MOD_ENTITY_PATCHES_TEMPLATE, self.mod_id)
end

