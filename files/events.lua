dofile_once("mods/modloader/files/base.lua")
dofile_once("mods/modloader/files/utils.lua")
dofile_once("mods/modloader/files/modloader.lua")
dofile_once("mods/modloader/files/loaded_descriptor.lua")
dofile_once("mods/modloader/files/function_descriptor.lua")


event = base:new()
event.__index = event
event.__name = "event"
event.__call = function (self, ...)
    return self:call(...)
end

event.new = make_smart_function(function (self, name, mod_id)
    return base.new(self, {
        name=name,
        subscribers={},
        creator=modloader.get_current_mod_id(mod_id, nil)
    })
end, { "self", "name", "mod_id" })

event.subscribe = make_smart_function(function (self, callback, mod_id)
    mod_id = mod_id or modloader.get_current_mod_id(mod_id, self.creator)

    if self.subscribers[mod_id] then
        return false
    end

    self.subscribers[mod_id] = callback

    return true
end, { "self", "callback", "mod_id" })

event.unsubscribe = make_smart_function(function (self, mod_id)
    mod_id = mod_id or modloader.get_current_mod_id(mod_id, self.creator)

    local callback = self.subscribers[mod_id]
    if not callback then
        return false
    end

    self.subscribers[mod_id] = nil

    return true
end, { "self", "mod_id" })

event.call = function (self, ...)
    local result = {}
    for mod_id, callback in pairs(self.subscribers) do
        result[mod_id] = callback(...)
    end

    return result
end


event_view = base:new()
event_view.__index = event_view
event_view.__name = "event_view"

event_view.new = make_smart_function(function (self, event, mod_id)
    return base.new(self, { event=event, mod_id=mod_id })
end, { "self", "event", "mod_id" })

event_view.subscribe = make_smart_function(function (self, callback)
    return self.event:subscribe(callback, self.mod_id)
end, { "self", "callback" })

event_view.unsubscribe = function (self)
    return self.event:unsubscribe(self.mod_id)
end


events = base:new()
events.__index = events
events.__name = "events"
events.__events = {}

events.add = make_smart_function(function (self, name)
    if self.__events[name] then
        error(string.format("Event with name %s already exists", name))
    end

    local e = event:new(name, self.loader.mod_id)
    events.__events[name] = e
    return e
end, { "self", "name" })

events.get = make_smart_function(function (self, name)
    local e = __events[name]
    if not e then
        return e
    end

    return event_view:new(e, self.loader.mod_id)
end, { "self", "name"})


modloader.__subclasses['events'] = events
