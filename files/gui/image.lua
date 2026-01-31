dofile_once("mods/modloader/files/utils.lua")
dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/modloader/files/gui/gui_object.lua")

image = gui_object:new()
image.__name = "image"
image.__index = function (self, key)
    if key == "width" or key == "height" then
        local width, height = self:__get_image_dimensions()
        return key == "width" and width or height 
    end

    return image[key]
end

image.new = make_smart_function(
    function (self, extra)
        return gui_object.new(self, extra)
    end,
    { "self" },
    { alpha=1, scale=1, scale_y=0, rotation=0, rect_animation_playback_type=GUI_RECT_ANIMATION_PLAYBACK.PlayToEndAndHide, rect_animation_name="" }
)

image.__render = image:__make_render_function(GuiImage, { "self", "x", "y", "sprite_filename", "alpha", "scale", "scale_y", "rotation", "rect_animation_playback_type", "rect_animation_name" })

image.__get_image_dimensions = make_smart_function(function (self, sprite_filename, scale)
    return GuiGetImageDimensions(self.__gui.get_current_gui(), sprite_filename or self.sprite_filename, scale or self.scale or 1)
end, { "self", "sprite_filename", "scale"})


image_nine_piece = gui_object:new()
image_nine_piece.__name = "image_nine_piece"
image_nine_piece.__index = image_nine_piece

image_nine_piece.new = make_smart_function(
    function (self, extra)
        return gui_object.new(self, extra)
    end,
    { "self" },
    { alpha=1, sprite_filename="data/ui_gfx/decorations/9piece0_gray.png", sprite_highlight_filename="data/ui_gfx/decorations/9piece0_gray.png" }
)

image_nine_piece.__render = image_nine_piece:__make_render_function(GuiImageNinePiece, { "self", "x", "y", "width", "height", "alpha", "sprite_filename", "sprite_highlight_filename" })
