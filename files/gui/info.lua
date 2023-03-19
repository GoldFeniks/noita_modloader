dofile_once("mods/modloader/files/base.lua")
dofile_once("mods/modloader/files/utils.lua")

info = base:new()
info.__name = "info"
info.__index = info

info.new = function (self)
    return base.new(self, { updated=false })
end

info.populate = function (self)
    self.clicked, self.right_clicked, self.hovered, self.x, self.y, self.width, self.height, self.draw_x, self.draw_y, self.draw_width, self.draw_height =
        GuiGetPreviousWidgetInfo(info.__gui.get_current_gui())

    self.updated = true
end
