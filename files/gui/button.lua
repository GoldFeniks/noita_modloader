dofile_once("mods/modloader/files/utils.lua")
dofile_once("mods/modloader/files/gui/text.lua")
dofile_once("mods/modloader/files/gui/image.lua")
dofile_once("mods/modloader/files/gui/gui_object.lua")

button = gui_object:new()
button.__name = "button"
button.__handles_clicks = true
button.__index = function (self, key)
    if key == "width" or key == "height" then
        local width, height = text.__get_text_dimensions(self)
        return key == "width" and width or height
    end
    
    return button[key]
end

button.__handle_clicks = function (self)
    if self.clicked and self.on_clicked ~= nil then
        self:on_clicked(self.__gui.get_current_gui())
    end

    if self.right_clicked and self.on_right_clicked ~= nil then
        self:on_right_clicked(self.__gui.get_current_gui())
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
image_button.__handles_clicks = true
image_button.__index = function (self, key)
    if key == "width" or key == "height" then
        local width, height = image.__get_image_dimensions(self)
        return key == "width" and width or height
    end

    return image_button[key]
end

image_button.__render = make_smart_function(function (self, x, y, text, sprite_filename)
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
