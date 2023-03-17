dofile_once("mods/modloader/files/utils.lua")
dofile_once("mods/modloader/files/gui/gui_object.lua")

text = gui_object:new()
text.__name = "text"
text.__index = function (self, key)
    if key == "width" or key == "height" then
        local width, height = self:__get_text_dimensions()        
        return key == "width" and width or height 
    end

    return text[key]
end
text.__needs_id = false

text.__render = text:__make_render_function(GuiText, { "self", "x", "y", "text" })

text.__get_text_dimensions = make_smart_function(function (self, scale, line_spacing)
    return GuiGetTextDimensions(self.__gui.get_current_gui(), self.text, scale or self.scale or 1, line_spacing or self.line_spacing or 2)
end, { "self", "scale", "line_spacing"})
