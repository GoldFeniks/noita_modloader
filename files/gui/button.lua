dofile_once("mods/modloader/files/utils.lua")
dofile_once("mods/modloader/files/gui/gui_object.lua")

button = gui_object:new()
button.__name = "button"
button.__index = button

button.new = make_smart_function(function (self, x, y, text, on_clicked, on_right_clicked, options, update, extra)
    extra = extra or {}
    extra.text = text
    extra.on_clicked = on_clicked
    extra.on_right_clicked = on_right_clicked

    return gui_object.new(self, x, y, options, update, extra)
end, { "self", "x", "y", "text", "on_clicked", "on_right_clicked", "options", "update", "extra"})

button.__handle_clicks = function (self)
    if self.clicked and self.on_clicked ~= nil then
        self:on_clicked()
    end

    if self.right_clicked and self.on_right_clicked ~= nil then
        self:on_right_clicked()
    end

    return self.clicked, self.right_clicked
end

button.__render = make_smart_function(function (self, x, y, text)
    self.clicked, self.right_clicked = GuiButton(
        self.__gui.get_current_gui(),
        self.id,
        x or self.x,
        y or self.y,
        text or self.text
    )

    return self:__handle_clicks()
end, { "self", "x", "y", "text" })


image_button = button:new()
image_button.__name = "image_button"
image_button.__index = image_button

image_button.new = make_smart_function(function (self, x, y, text, sprite_filename, on_clicked, on_right_clicked, options, update)
    return button.new(self, x, y, text, on_clicked, on_right_clicked, options, update, { sprite_filename=sprite_filename })
end, { "self", "x", "y", "text", "sprite_filename", "on_clicked", "on_right_clicked", "options", "update" })

image_button.render = make_smart_function(function (self, x, y, text, sprite_filename)
    self.clicked, self.right_clicked = GuiImageButton(
        self.__gui.get_current_gui(),
        self.id,
        x or self.x,
        y or self.y,
        text or self.text,
        sprite_filename or self.sprite_filename
    )

    return self:__handle_clicks()
end, { "self", "x", "y", "text", "sprite_filename" }, { text="" })
