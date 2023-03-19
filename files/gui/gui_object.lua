dofile_once("mods/modloader/files/base.lua")
dofile_once("mods/modloader/files/utils.lua")
dofile_once("mods/modloader/files/gui/info.lua")

gui_object = base:new()
gui_object.__name = "gui_object"
gui_object.__index = gui_object
gui_object.__needs_id = true

gui_object.__current_id = 1
gui_object.__next_id = function ()
    gui_object.__current_id = gui_object.__current_id + 1
    return gui_object.__current_id
end

gui_object.__make_render_function = function(self, func, params)
    return make_smart_function(function (this, ...)
        local arguments = table.pack(...)
        for i=1,#params - 1 do
            arguments[i] = arguments[i] or this[params[i + 1]]
        end

        if self.__needs_id then
            return func(this.__gui.get_current_gui(), this["id"], table.unpack(arguments, 1, #params - 1))
        end

        return func(this.__gui.get_current_gui(), table.unpack(arguments, 1, #params - 1))
    end, params)
end

gui_object.new = make_smart_function(function (self, x, y, options, extra)
    local object = extra or {}
    object.x  = x or 0
    object.y  = y or 0
    object.id = self.__needs_id and gui_object.__next_id() or nil
    object.info = info:new()
    object.options = options or {}
    object.enabled = true

    return base.new(self, object)
end, { "self", "x", "y", "options" })

gui_object.populate_info = function (self)
    self.info:populate()
end

gui_object.add_option = make_smart_function(function (self, option)
    table.insert(self.options, option)
end, { "self", "option" })

gui_object.remove_option = make_smart_function(function (self, option)
    for i, value in ipairs(self.options) do
        if value == option then
            table.remove(self.options, i)
            return true
        end
    end

    return false    
end, { "self", "option" })

gui_object.set_options = make_smart_function(function (self, options)
    self.options = options
end, { "self" })

gui_object.clear_options = function (self)
    self.options = {}
end

gui_object.apply_options = function (self)
    local gui = gui_object.__gui.get_current_gui()

    for i, option in ipairs(self.options) do
        GuiOptionsAddForNextWidget(gui, option)
    end
end

gui_object.render = function (self, ...)
    if not self.enabled then
        return
    end

    self:apply_options()
    self.info.updated = false

    local result = self:__render(...)

    if not self.info.updated then
        self:populate_info()
    end

    if self.info.hovered and self.on_hover then
        self:on_hover(self.__gui.get_current_gui())
    end

    return result
end

gui_object.update = function (self, gui)
    if self.__update then
        self:__update(gui)
    end
end
