dofile_once("mods/modloader/files/utils.lua")
dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/modloader/files/gui/gui_object.lua")

image = gui_object:new()
image.__name = "image"
image.__index = image

image.new = make_smart_function(
    function (self, x, y, sprite_filename, alpha, scale, scale_y, rotation, rect_animation_playback_type, rect_animation_name, options, update)
        return gui_object.new(self, x, y, options, update, {
            sprite_filename=sprite_filename,
            alpha=alpha,
            scale=scale,
            scale_y=scale_y,
            rotation=rotation,
            rect_animation_playback_type=rect_animation_playback_type,
            rect_animation_name=rect_animation_name
        })
    end,
    { "self", "x", "y", "sprite_filename", "alpha", "scale", "scale_y", "rotation", "rect_animation_name", "rect_animation_name", "options", "update" },
    { alpha=1, scale=1, scale_y=0, rotation=0, rect_animation_playback_type=GUI_RECT_ANIMATION_PLAYBACK.PlayToEndAndHide, rect_animation_name="" }
)

image.__render = image:__make_render_function(GuiImage, { "self", "x", "y", "sprite_filename", "alpha", "scale", "scale_y", "rotation", "rect_animation_playback_type", "rect_animation_name" })


image_nine_piece = gui_object:new()
image_nine_piece.__name = "image_nine_piece"
image_nine_piece.__index = image_nine_piece

image_nine_piece.new = make_smart_function(
    function (self, x, y, width, height, alpha, sprite_filename, sprite_highlight_filename, options, update)
        return gui_object.new(self, x, y, options, update, {
            width=width,
            height=height,
            alpha=alpha,
            sprite_filename=sprite_filename,
            sprite_highlight_filename=sprite_highlight_filename
        })
    end,
    { "self", "x", "y", "width", "height", "alpha", "sprite_filename", "sprite_highlight_filename", "options", "update" },
    { alpha=1, sprite_filename="data/ui_gfx/decorations/9piece0_gray.png", sprite_highlight_filename="data/ui_gfx/decorations/9piece0_gray.png" }
)

image_nine_piece.__render = image_nine_piece:__make_render_function(GuiImageNinePiece, { "self", "x", "y", "width", "height", "alpha", "sprite_filename", "sprite_highlight_filename" })
