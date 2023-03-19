dofile_once("mods/modloader/files/utils.lua")
dofile_once("mods/modloader/files/gui/container.lua")

grid = container:new()
grid.__name = "grid"
grid.__index = grid
grid.__needs_id = true

grid.new = make_smart_function(
    function (self, extra)
        return container.new(self, extra)
    end,
    { "self" },
    { n_rows=1, n_cols=1, scrollbar_gamepad_focusable=true, margin_x=2, margin_y=2, row_margin=0, col_margin=0 }
)

grid.__get_width = make_smart_function(function (self, width, item_width, col_margin)
    return width or self.width or self.n_cols * (item_width or self.item_width or 0) + (col_margin or self.col_margin) * (self.n_cols - 1)
end, { "self", "width", "item_width", "col_margin" })

grid.__get_height = make_smart_function(function (self, height, item_height, row_margin, margin_y)
    return height or self.height or self.n_rows * (item_width or self.item_height or 0) + (row_margin or self.row_margin) * (self.n_rows - 1) + (margin_y or self.margin_y) * 2
end, { "self", "height", "item_height", "row_margin", "margin_y" })

grid.__render = make_smart_function(function (self, x, y, margin_x, margin_y, width, height, scrollbar_gamepad_focusable, row_margin, col_margin, item_width, item_height)
    width  = self:__get_width(width, item_width, col_margin)
    height = self:__get_height(height, item_height, row_margin, margin_y)

    local gui = self.__gui.get_current_gui()
    GuiBeginScrollContainer(
        gui,
        self.id,
        x or self.x,
        y or self.y,
        width,
        height,
        scrollbar_gamepad_focusable or self.scrollbar_gamepad_focusable,
        margin_x or self.margin_x,
        margin_y or self.margin_y
    )

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
end, { "self", "x", "y", "margin_x", "margin_y", "width", "height", "scrollbar_gamepad_focusable", "row_margin", "col_margin", "item_width", "item_height" })