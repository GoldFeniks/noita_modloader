dofile_once("mods/modloader/files/utils.lua")
dofile_once("mods/modloader/files/xml/xml.lua")
dofile_once("mods/modloader/files/descriptor.lua")


entity_descriptor = descriptor:new()
entity_descriptor.__index = entity_descriptor

entity_descriptor.new = make_smart_function(function (self, path)
    local root_tag = xml_parser:new(ModTextFileGetContent(path)):parse()

    return descriptor.new(self, { root_tag=root_tag, __path=path })
end, { "self", "path" })

entity_descriptor.save = function(self)
    ModTextFileSetContent(self.__path, self.root_tag:to_string())
end

entity_descriptor.find = make_smart_function(function (self, tag_name, filters, levels, allow_recursive)
    return self.root_tag:find(tag_name, filters, levels, allow_recursive, {}, 0)
end, { "self", "tag_name", "filters", "levels", "allow_recursive" }, { filters={}, levels=1, allow_recursive=false })

entity_descriptor.add_component = make_smart_function(function (self, name, parameters, children)
    local tag = xml_tag:new(name, parameters, children)
    self.root_tag:add_child(tag)
    return tag
end, { "self", "name", "parameters", "children" })

entity_descriptor.add_lua_script = make_smart_function(function (self, path, interval, parameters)
    parameters = parameters or {}
    parameters.script_source_file = path
    parameters.execute_every_n_frame = interval

    return self:add_component{
        name="LuaComponent",
        parameters=parameters
    }
end, { "self", "path", "interval", "parameters" }, { interval=1 })


local events = {
    "damage_received",
    "damage_about_to_be_received",
    "item_picked_up",
    "shot",
    "collision_trigger_hit",
    "collision_trigger_timer_finished",
    "physics_body_modified",
    "pressure_plate_change",
    "inhaled_material",
    "death",
    "throw_item",
    "material_area_checker_failed",
    "material_area_checker_success",
    "electricity_receiver_switched",
    "electricity_receiver_electrified",
    "kick",
    "interacting",
    "audio_event_dead",
    "wand_fired",
    "teleported",
    "portal_teleport_used"
}

for i, value in ipairs(events) do
    entity_descriptor["on_" .. value] = make_smart_function(function (self, path)
        return self:add_component{
            name="LuaComponent",
            parameters={
                ["script_" .. value]=path
            }
        }
    end, { "self", "path" })
end
