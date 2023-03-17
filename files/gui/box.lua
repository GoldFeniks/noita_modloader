dofile_once("mods/modloader/files/utils.lua")
dofile_once("mods/modloader/files/gui/container.lua")

box = container:new()
box.__name = "box"
box.__index = function (self, key)
    if key == "width" then
        return (self.__x or 0) - (self.__pos_x or 0)
    end

    if key == "height" then
        return (self.__y or 0) - (self.__pos_y or 0)
    end
    
    return box[key]
end

box.__needs_id = false

box.new = make_smart_function(function (self, width, height, extra)
    if width and height then
        error("Only one of width or height may be specified")
    end

    if not width and not height then
        error("One of width or height must be specified")
    end

    extra.width = width
    extra.height = height

    if width then
        extra.__put_child = self.__put_horizontal
    else
        extra.__put_child = self.__put_vertical
    end

    return container.new(self, extra)
end, { "self", "width", "height" }, { padding_x=0, padding_y=0 })


box.__put_horizontal = make_smart_function(function (self, child, x, y, width, height, padding_x, padding_y)
    local c_width  = child.width  or child.info.width  or 0
    local c_height = child.height or child.info.height or 0

    self.__current_size = self.__current_size + c_width + padding_x

    if self.__current_size > width then
        self.__y = self.__y + padding_y + self.__max_step
        self.__max_step = c_height
        self.__x = x
        self.__current_size = c_width + padding_x
    end

    child:render{ x=self.__x, y=self.__y }
    
    self.__x = x + self.__current_size
    self.__max_step = math.max(self.__max_step, c_height)
end, { "self", "child", "x", "y", "width", "height", "padding_x", "padding_y" })

box.__put_vertical = make_smart_function(function (self, child, x, y, width, height, padding_x, padding_y)
    local c_width  = child.width  or child.info.width  or 0
    local c_height = child.height or child.info.height or 0

    self.__current_size = self.__current_size + c_height + padding_y

    if self.__current_size > height then
        self.__x = self.__x + padding_x + self.__max_step
        self.__max_step = c_width
        self.__y = y
        self.__current_size = c_height + padding_y
    end

    child:render{ x=self.__x, y=self.__y }
    
    self.__y = y + self.__current_size
    self.__max_step = math.max(self.__max_step, c_width)
end, { "self", "child", "x", "y", "width", "height", "padding_x", "padding_y" })

box.__render = make_smart_function(function (self, x, y, width, height, padding_x, padding_y)
    x = x or self.x
    y = y or self.y
    width = width or self.width
    height = height or self.height
    padding_x = padding_x or self.padding_x
    padding_y = padding_y or self.padding_y

    self.__x = x
    self.__y = y
    self.__pos_x = x
    self.__pos_y = y
    self.__max_step = 0
    self.__current_size = 0

    for _, child in ipairs(self.children) do
        self:__put_child(child, x, y, width, height, padding_x, padding_y)
    end

    if self.__put_child == self.__put_horizontal then
        self.__y = self.__y + padding_y + self.__max_step
    else
        self.__x = self.__x + padding_x + self.__max_step
    end
end, { "self", "x", "y", "width", "height", "padding_x", "padding_y" })
