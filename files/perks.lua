if perk_list == nil then
    dofile_once("data/scripts/perks/perk_list.lua")
end 

dofile_once("mods/modloader/files/modloader.lua")
dofile_once("mods/modloader/files/table_handler.lua")

modloader.__subclasses['perks'] = table_handler:__new(perk_list)
 