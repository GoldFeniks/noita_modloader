dofile_once("mods/modloader/files/base.lua")

descriptor = base:new()
descriptor.__index = descriptor

function descriptor:new(object)
    local object = object or {}
    object.accessed_by = {}

    return base.new(self, object)
end
