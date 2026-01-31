dofile_once("mods/modloader/files/utils.lua")
dofile_once("mods/modloader/files/gui/container.lua")
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


stacked_button = container:new()
stacked_button.__name = "stacked_button"
stacked_button.__index = stacked_button

stacked_button.new = make_smart_function(
    function (self, extra)
        local result = container.new(self, extra)
        result:__setup_handlers()
        return result
    end,
    { "self" },
    { hovered_scale=1.2, scale=1 }
)

stacked_button.__render = make_smart_function(function (self, x, y)
    local n = #self.children
    if n < 1 then
        return
    end

    local child = self.children[1]
    local child_scale = (child.scale or 1) * self.scale

    local width, height = self:__get_width_height(child, child.scale or 1)
    local scaled_width, scaled_height = self:__get_width_height(child, child_scale)    

    local x_offset = (width  - scaled_width ) / 2
    local y_offset = (height - scaled_height) / 2    

    x = (x or self.x) + x_offset
    y = (y or self.y) + y_offset

    child.z_order = (self.z_order or 0) + n
    child:render{ x=x, y=y, scale=child_scale }

    for i=2,n do
        child = self.children[i]
        if child.enabled then
            child_scale = (child.scale or 1) * self.scale

            width, height = self:__get_width_height(child, child_scale)
            child.z_order = (self.z_order or 0) + n - i + 1
            child:render{ x=x + (scaled_width - width) / 2, y=y + (scaled_height - height) / 2, scale=child_scale }
        end
    end
end, { "self", "x", "y" })

stacked_button.__setup_handlers = function(self)
    local handlers = { "on_clicked", "on_right_clicked", "on_hover", "on_hover_exit", "on_hover_enter" }
    local child = self.children[1]

    for i, v in ipairs(handlers) do
        child[v] = (function (v, vi)
            return function(other, gui)
                if self[v] ~= nil then
                    self[v](self, gui)
                end

                if self[vi] ~= nil then
                    self[vi](self, gui)
                end
            end
        end)(v, "__" .. v)
    end
end

stacked_button.__on_hover_enter = function(self, gui)
    self.scale = self.scale * self.hovered_scale
end

stacked_button.__on_hover_exit = function(self, gui)
    self.scale = self.scale / self.hovered_scale
end

stacked_button.__get_width_height = function(self, object, scale)
    if object.__get_image_dimensions ~= nil then
        return object:__get_image_dimensions{ scale=scale }
    end

    if object.__get_text_dimensions ~= nil then
        return object:__get_text_dimensions{ scale=scale }
    end

    return (object.width or 0) * scale, (object.height or 0) * scale
end
