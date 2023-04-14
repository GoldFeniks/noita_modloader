if actions == nil then
    dofile_once("data/scripts/gun/gun_actions.lua")
end 

dofile_once("mods/modloader/files/modloader.lua")
dofile_once("mods/modloader/files/table_handler.lua")

modloader.__subclasses['actions'] = table_handler:__new(actions)
