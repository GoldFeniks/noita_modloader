dofile_once("mods/modloader/files/utils.lua")
dofile_once("mods/modloader/files/gui/container.lua")

grid = container:new()
grid.__name = "grid"
grid.__index = function (self, key)
    if key == "width" then
        return self.info.width or self:__get_content_width() + self.margin_x * 2
    end

    if key == "height" then
        return self.info.height or self:__get_content_height() + self.margin_y * 2
    end
    
    return grid[key]
end
grid.__needs_id = true

grid.new = make_smart_function(
    function (self, extra)
        return container.new(self, extra)
    end,
    { "self" },
    { n_rows=1, n_cols=1, scrollbar_gamepad_focusable=true, margin_x=2, margin_y=2, row_margin=0, col_margin=0 }
)

grid.__get_content_width = function (self)
    return self.n_cols * (self.item_width or 0) + self.col_margin * (self.n_cols - 1)
end

grid.__get_content_height = function (self)
    return self.n_rows * (self.item_height or 0) + self.row_margin * (self.n_rows - 1)
end

grid.__render = make_smart_function(function (self, x, y, width, height, scrollbar_gamepad_focusable)    
    width  = width  or self:__get_content_width()
    height = height or self:__get_content_height()

    local gui = self.__gui.get_current_gui()
    GuiBeginScrollContainer(
        gui,
        self.id,
        x or self.x,
        y or self.y,
        width,
        height,
        scrollbar_gamepad_focusable or self.scrollbar_gamepad_focusable,
        self.margin_x,
        self.margin_y
    )

    self:populate_info()

    local n_items = 0
    local got_size = false

    GuiLayoutBeginVertical(gui, 0, 0, self.row_margin, 0)
    GuiLayoutBeginHorizontal(gui, 0, 0, 0, self.col_margin)

    for i, child in ipairs(self.children) do
        if child.enabled then
            child:render(0, 0)

            if not got_size then
                self.item_width  = self.item_width or child.info.width
                self.item_height = self.item_height or child.info.height
                got_size = true
            end

            n_items = n_items + 1
            if n_items == self.n_cols then
                n_items = 0
                GuiLayoutEnd(gui)
                GuiLayoutBeginHorizontal(gui, 0, 0, 0, self.col_margin)
            end
        end
    end

    GuiLayoutEnd(gui)
    GuiLayoutEnd(gui)
    GuiEndScrollContainer(gui)
end, { "self", "x", "y", "width", "height", "scrollbar_gamepad_focusable" })
