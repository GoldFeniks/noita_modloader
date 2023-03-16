dofile_once("mods/modloader/files/utils.lua")
dofile_once("mods/modloader/files/gui/container.lua")

autobox = container:new()
autobox.__name = "autobox"
autobox.__index = autobox
autobox.__needs_id = false

autobox.new = make_smart_function(
    function (self, margin, size_min_x, size_min_y, mirrorize_over_x_axis, x_axis, sprite_filename, sprite_highlight_filename, children, options, update)
        return container.new(self, 0, 0, children, options, update {
            margin=margin,
            size_min_x=size_min_x,
            size_min_y=size_min_y,
            mirrorize_over_x_axis=mirrorize_over_x_axis,
            x_axis=x_axis,
            sprite_filename=sprite_filename,
            sprite_highlight_filename=sprite_highlight_filename
        })
    end,
    { "self", "margin", "size_min_x", "size_min_y", "mirrorize_over_x_axis", "x_axis", "sprite_filename", "sprite_highlight_filename", "children", "options", "update" },
    { margin=5, size_min_x=0, size_min_y=0, mirrorize_over_x_axis=false, x_axis=0, sprite_filename="data/ui_gfx/decorations/9piece0_gray.png", sprite_highlight_filename="data/ui_gfx/decorations/9piece0_gray.png" }
)

autobox.__render = make_smart_function(function (self, margin, size_min_x, size_min_y, mirrorize_over_x_axis, x_axis, sprite_filename, sprite_highlight_filename)
    local gui = self.__gui.get_current_gui()

    GuiZSetForNextWidget(gui, -1)

    GuiBeginAutoBox(gui)

    container.__render(self)

    GuiEndAutoBoxNinePiece(
        gui,
        margin or self.margin,
        size_min_x or self.size_min_x,
        size_min_y or self.size_min_y,
        mirrorize_over_x_axis or self.mirrorize_over_x_axis,
        x_axis or self.x_axis,
        sprite_filename or self.sprite_filename,
        sprite_highlight_filename or self.sprite_highlight_filename
    )
end, { "self", "margin", "size_min_x", "size_min_y", "mirrorize_over_x_axis", "x_axis", "sprite_filename", "sprite_highlight_filename", "children", "options" })
