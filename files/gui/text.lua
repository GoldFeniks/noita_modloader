dofile_once("mods/modloader/files/utils.lua")
dofile_once("mods/modloader/files/gui/gui_object.lua")

text = gui_object:new()
text.__name = "text"
text.__index = text
text.__needs_id = false

text.new = make_smart_function(function (self, x, y, text, options, update)
    return gui_object.new(self, x, y, options, update, { text=text })
end, { "self", "x", "y", "text", "options", "update" })

text.__render = text:__make_render_function(GuiText, { "self", "x", "y", "text" })
