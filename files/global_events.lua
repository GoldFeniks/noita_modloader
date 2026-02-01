dofile_once("mods/modloader/files/base.lua")
dofile_once("mods/modloader/files/utils.lua")
dofile_once("mods/modloader/files/modloader.lua")
dofile_once("mods/modloader/files/serialization.lua")


global_events = base:new()
global_events.__index = global_events
global_events.__name = "global_events"

global_events.create = make_smart_function(function (self, name, poll_frequency)
    local ge_path = self.loader:__get_global_events_path()
    local content = ModTextFileGetContent(ge_path) or ""
    ModTextFileSetContent(ge_path, content .. "create\t" .. name .. "\t" .. tostring(poll_frequency) .. "\n")
end, { "self", "name", "poll_frequency" }, { poll_frequency=5 })

global_events.subscribe = make_smart_function(function (self, name, handler, mod_id)
    mod_id = mod_id or self.loader.mod_id
    local ge_path = self.loader:__get_global_events_path()
    local content = ModTextFileGetContent(ge_path) or ""
    ModTextFileSetContent(ge_path, content .. "subscribe\t" .. name .. "\t" .. handler .. "\t" .. mod_id .. "\n")
end, { "self", "name", "handler", "mod_id" })

global_events.emit = make_smart_function(function (self, name, data, mod_id)
    mod_id = mod_id or self.loader.mod_id
    local key = "MODLOADER_GE_" .. mod_id .. "_" .. name
    local n = tonumber(GlobalsGetValue(key .. "_n", "0"))
    GlobalsSetValue(key .. "_" .. n, serialize(data))
    GlobalsSetValue(key .. "_n", tostring(n + 1))
end, { "self", "name", "data", "mod_id" })


global_event_emitter = base:new()
global_event_emitter.__index = global_event_emitter
global_event_emitter.__name = "global_event_emitter"
global_event_emitter.__call = function (self, data)
    self.events:emit(self.name, data, self.mod_id)
end

global_events.emitter = make_smart_function(function (self, name, mod_id)
    mod_id = mod_id or self.loader.mod_id
    return global_event_emitter:new{ events=self, name=name, mod_id=mod_id }
end, { "self", "name", "mod_id" })


modloader.__subclasses['global_events'] = global_events
