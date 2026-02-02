dofile_once("mods/modloader/files/entities.lua")
dofile_once("mods/modloader/files/constants.lua")
dofile_once("mods/modloader/files/modloader.lua")
dofile_once("mods/modloader/files/templates.lua")

local entity_patches = {}
local global_events_creates = {}
local global_events_subs = {}
local mods = ModGetActiveModIDs()

for _, mod_id in ipairs(mods) do
    local mod = modloader:new(mod_id)

    local appends = ModTextFileGetContent(mod:__get_appends_path()) or ""
    for path, file in string.gmatch(appends, "([^\n\t]+)\t([^\n\t]+)\n") do
        ModLuaFileAppend(path, file)
    end

    local patches = ModTextFileGetContent(mod:__get_entity_patches_path()) or ""
    for entity, patch in string.gmatch(patches, "([^\n\t]+)\t([^\n\t]+)\n") do
        local list = entity_patches[entity]
        if list == nil then
            list = {}
            entity_patches[entity] = list
        end

        table.insert(list, { mod_id=mod_id, patch=patch })
    end

    local guis = ModTextFileGetContent(mod:__get_guis_path()) or ""
    for gui in string.gmatch(guis, "([^\n\t]+)\n") do
        ModLuaFileAppend(MODLOADER_MAIN_GUI_PATH, gui)
    end

    local ge_content = ModTextFileGetContent(mod:__get_global_events_path()) or ""
    for action, name, rest in string.gmatch(ge_content, "([^\n\t]+)\t([^\n\t]+)\t([^\n]+)\n") do
        if action == "create" then
            local event_key = mod_id .. "_" .. name
            global_events_creates[event_key] = {
                mod_id=mod_id,
                name=name,
                poll_frequency=tonumber(rest)
            }
        elseif action == "subscribe" then
            local handler, source_mod_id = string.match(rest, "([^\t]+)\t?([^\t]*)")
            if source_mod_id == nil or source_mod_id == "" then
                source_mod_id = mod_id
            end
            local event_key = source_mod_id .. "_" .. name
            if not global_events_subs[event_key] then
                global_events_subs[event_key] = {}
            end
            table.insert(global_events_subs[event_key], {
                subscriber_mod_id=mod_id,
                handler=handler
            })
        end
    end
end


for entity, patches in pairs(entity_patches) do
    for i, patch in ipairs(patches) do
        local mod = modloader:new(patch.mod_id)
        local entity = mod.entities:load(entity)

        dofile(patch.patch)
        if patch_entity ~= nil then
            patch_entity(entity, mod)
        end
    end
end

local GLOBAL_EVENT_SCRIPT_TEMPLATE = "mods/modloader/files/global_events/%s_%s.lua"

local GE_BASE_TEMPLATE = ModTextFileGetContent("mods/modloader/files/global_events/base_template.lua")
local GE_SUB_TEMPLATE = ModTextFileGetContent("mods/modloader/files/global_events/subscriber_template.lua")
local GE_POLL_TEMPLATE = ModTextFileGetContent("mods/modloader/files/global_events/poll_template.lua")

local player_descriptor = entity_descriptor:new("data/entities/player.xml")
entities.__descriptors["data/entities/player.xml"] = player_descriptor

for event_key, subs in pairs(global_events_subs) do
    if not global_events_creates[event_key] then
        local mod_ids = {}
        for _, sub in ipairs(subs) do
            table.insert(mod_ids, sub.subscriber_mod_id)
        end
        error("Mods " .. table.concat(mod_ids, ", ") .. " subscribing to a missing event " .. event_key)
    end
end

for event_key, event in pairs(global_events_creates) do
    local script_path = string.format(GLOBAL_EVENT_SCRIPT_TEMPLATE, event.mod_id, event.name)

    local script_content = GE_BASE_TEMPLATE

    local subs = global_events_subs[event_key] or {}
    for _, sub in ipairs(subs) do
        script_content = script_content .. string.format(GE_SUB_TEMPLATE, sub.subscriber_mod_id, sub.subscriber_mod_id, sub.subscriber_mod_id, sub.handler)
    end

    script_content = script_content .. string.format(GE_POLL_TEMPLATE, event.mod_id, event.name)

    ModTextFileSetContent(script_path, script_content)

    player_descriptor:add_lua_script{
        path=script_path,
        interval=event.poll_frequency
    }
end

for _, entity in pairs(entities.__descriptors) do
    entity:save()
end

function OnPlayerSpawned(player_entity)
    dofile(MODLOADER_MAIN_GUI_PATH)
end

function OnWorldPostUpdate()
    if __IN_CASE_GUI_IS_OVERRIDEN_GUI and __IN_CASE_GUI_IS_OVERRIDEN_GUI.__main_render then
        __IN_CASE_GUI_IS_OVERRIDEN_GUI.__main_render()
    end
end