dofile_once("mods/modloader/files/base.lua")

loaded_descriptor = base:new()
loaded_descriptor.__index = function (self, key)
    local value = loaded_descriptor[key]
    if value ~= nil then
        return value
    end

    return self.descriptor[key]
end

loaded_descriptor.__newindex = function (self, key, value)
    self.descriptor[key] = value
end
