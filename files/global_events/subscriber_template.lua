if not MODLOADER_GE_SUB_%s then
    MODLOADER_GE_SUB_%s = true
    MODLOADER_GE_CURRENT_MOD = "%s"
    dofile("%s")
end
