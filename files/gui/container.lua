dofile_once("mods/modloader/files/utils.lua")
dofile_once("mods/modloader/files/gui/gui_object.lua")

container = gui_object:new()
container.__name = "container"
container.__index = container
container.__needs_id = false

container.__render = function (self, ...)
    for i, child in ipairs(self.children) do
        if self.before_child_render then
            self:before_child_render(i, child)
        end

        child:render(...)
    end
end

container.new = make_smart_function(function (self, extra)
    extra.children = extra.children or {}
    return gui_object.new(self, extra)    
end, { "self" })

container.add_child = make_smart_function(function (self, child)
    table.insert(self.children, child)
end, { "self", "child" })

container.remove_child = make_smart_function(function (self, child)
    if type(child) == "number" then
        if self.children[child] then
            table.remove(self.children, child)
            return true
        end

        return false
    end

    for i, value in ipairs(self.children) do
        if value == child then
            table.remove(self.children, i)
            return true
        end
    end

    return false
end, { "self", "child" })

container.update = function (self)
    for _, child in ipairs(self.children) do
        if child.update ~= nil then
            child:update()
        end
    end
end


scroll_container = container:new()
scroll_container.__name = "scroll_container"
scroll_container.__index = scroll_container
scroll_container.__needs_id = true

scroll_container.new = make_smart_function(
    function (self, extra)
        return container.new(self, extra)
    end,
    { "self" },
    { scrollbar_gamepad_focusable=true, margin_x=2, margin_y=2 }
)

scroll_container.__render = make_smart_function(function (self, x, y, width, height, scrollbar_gamepad_focusable, margin_x, margin_y)
    local gui = self.__gui.get_current_gui()

    GuiBeginScrollContainer(
        gui,
        self.id,
        x or self.x,
        y or self.y,
        width or self.width,
        height or self.height,
        scrollbar_gamepad_focusable or self.scrollbar_gamepad_focusable,
        margin_x or self.margin_x,
        margin_y or self.margin_y
    )

    container.__render(self)

    GuiEndScrollContainer(gui)
end, { "self", "x", "y", "width", "height", "scrollbar_gamepad_focusable", "margin_x", "margin_y" })
