dofile_once("mods/modloader/files/entities.lua")
dofile_once("mods/modloader/files/constants.lua")
dofile_once("mods/modloader/files/modloader.lua")
dofile_once("mods/modloader/files/templates.lua")

local entity_patches = {}
local registered = ModTextFileGetContent(MODLOADER_REGISTERED_PATH) or ""

for mod_id in string.gmatch(registered, "([%w_]+)\n") do
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