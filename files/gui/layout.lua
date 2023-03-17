dofile_once("mods/modloader/files/utils.lua")
dofile_once("mods/modloader/files/gui/container.lua")

horizontal_layout = container:new()
horizontal_layout.__name = "horizontal_layout"
horizontal_layout.__index = horizontal_layout
horizontal_layout.__needs_id = false
horizontal_layout.__spacing_function = GuiLayoutAddHorizontalSpacing
horizontal_layout.__layout_begin_function = GuiLayoutBeginHorizontal

horizontal_layout.new = make_smart_function(
    function (self, extra)
        return container.new(self, extra)
    end,
    { "self" },
    { position_in_ui_scale=false, margin_x=2, margin_y=2 }
)

horizontal_layout.add_spacing = make_smart_function(function (self, amount)
    if self.__has_spacing then
        return false
    end

    self.__spacing = amount
    self.__has_spacing = true
    self.__old_before_child_render = self.before_child_render

    self.before_child_render = make_smart_function(function (self, i, child)
        self.__spacing_function(self.__gui.get_current_gui(), self.__spacing)

        if self.__old_before_child_render then
            self:__old_before_child_render(i, child)
        end
    end, { "self", "i", "child" })

    return true
end, { "self", "amount" })

horizontal_layout.remove_spacing = make_smart_function(function (self, amount)
    if not self.__has_spacing then
        return false
    end

    self.__spacing = nil
    self.__has_spacing = false
    self.before_child_render = self.__old_before_child_render
    self.__old_before_child_render = nil

    return true
end, { "self", "amount" })

horizontal_layout.__render = make_smart_function(function (self, x, y, position_in_ui_scale, margin_x, margin_y)
    local gui = self.__gui.get_current_gui()

    self.__layout_begin_function(
        gui,
        x or self.x,
        y or self.y,
        position_in_ui_scale or self.position_in_ui_scale,
        margin_x or self.margin_x,
        margin_y or self.margin_y
    )    

    container.__render(self, {x=0, y=0})

    GuiLayoutEnd(gui)
end, { "self", "x", "y", "position_in_ui_scale", "margin_x", "margin_y" })


vertical_layout = horizontal_layout:new()
vertical_layout.__name = "vertical_layout"
vertical_layout.__index = vertical_layout
vertical_layout.__needs_id = false
vertical_layout.__spacing_function = GuiLayoutAddVerticalSpacing
vertical_layout.__layout_begin_function = GuiLayoutBeginVertical

vertical_layout.new = make_smart_function(
    function (self, extra)
        return horizontal_layout.new(self, extra)
    end,
    { "self" },
    { position_in_ui_scale=false, margin_x=0, margin_y=0 }
)
