dofile_once("mods/modloader/files/utils.lua")
dofile_once("mods/modloader/files/gui/container.lua")

stack = container:new()
stack.__name = "stack"
stack.__index = stack
stack.__needs_id = false

stack.new = make_smart_function(
    function (self, extra)
        return container.new(self, extra)
    end,
    { "self" },
    { z_offset=0 }
)

stack.__render = function (self, ...)
    local z_order = #self.children + self.z_offset
    for i, child in ipairs(self.children) do
        if self.before_child_render then
            self:before_child_render(i, child)
        end

        child.z_order = z_order
        child:render(...)

        z_order = z_order - 1
    end
end
