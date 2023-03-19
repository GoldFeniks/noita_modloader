dofile_once("mods/modloader/files/base.lua")
dofile_once("mods/modloader/files/gui/info.lua")
dofile_once("mods/modloader/files/gui/gui_object.lua")


gui_item = base:new()
gui_item.__name = "gui_item"
gui_item.__index = gui_item

gui_item.new = make_smart_function(function (self, name)
    return base.new(self, { name=name, objects={}, first_init=true })
end, { "self", "name" })

gui_item.render = function (self)
    for _, object in ipairs(self.objects) do
        object:render()
    end
end

gui_item.update = function (self)
    for _, object in ipairs(self.objects) do
        if object.update ~= nil then
            object:update(self.__gui)
        end
    end
end


gui_item.add_object = make_smart_function(function (self, object)
    table.insert(self.objects, object)
end, { "self", "object" })

gui_item.remove_object = make_smart_function(function (self, object)
    if type(object) == "number" then
        if self.objects[object] then
            table.remove(self.objects, object)
            return true
        end

        return false
    end

    for i, value in ipairs(self.objects) do
        if value == object then
            table.remove(self.objects, i)
            return true
        end
    end

    return false
end, { "self", "object" })

gui = base:new()
gui.__name = "gui"
gui.__index = gui
gui.__guis = {}

info.__gui = gui
gui_object.__gui = gui

gui.get_current_gui = function()
    return gui.__current_gui
end

gui.new = function (self)
    local result = base.new(self, { items={} })
    table.insert(gui.__guis, result)
    return result
end

gui.__update = function(self)
    if self.__gui == nil then
        self.__gui = GuiCreate()
    end

    return true
end

gui.add = make_smart_function(function (self, name)
    if self.items[name] ~= nil then
        error(string.format("Gui item with the name %s already exists", name))
    end

    local item = gui_item:new(name)
    self.items[name] = item
    return item
end, { "self", "name" })

gui.remove = make_smart_function(function (self, name)
    if self.items[name] then
        self.items[name] = nil
        return true
    end

    return false
end, { "self", "name" })

gui.__render = function(self)
    GuiStartFrame(self.__gui)    

    for _, item in pairs(self.items) do
        if not item.initialized and item.initialize then
            item.initialized = nil

            item:initialize(self.__gui)
            item.first_init = false

            if item.initialized == nil then
                item.initialized = true
            end
        end

        if item.update then
            item:update(self.__gui)
        end

        if not item.disabled then
            item:render(self.__gui)
        end
    end
end

gui.__main_render = function (self)
    for _, agui in ipairs(gui.__guis) do
        if agui:__update() then
            gui.__current_gui = agui.__gui
            agui:__render()
        end
    end
end

gui.main = gui:new()
gui.inventory_open = gui:new()
gui.inventory_closed = gui:new()

function __update_inventory_gui(func)
    return function (self)
        if func() then
            if self.__gui == nil then
                self.__gui = GuiCreate()
            end

            return true
        end

        if self.__gui ~= nil then
            GuiDestroy(self.__gui)
            self.__gui = nil

            for _, item in pairs(self.items) do
                item.initialized = false
            end
        end

        return false
    end
end

gui.inventory_open.__update = __update_inventory_gui(GameIsInventoryOpen)
gui.inventory_closed.__update = __update_inventory_gui(function ()
    return not GameIsInventoryOpen()
end)

__IN_CASE_GUI_IS_OVERRIDEN_GUI = gui

