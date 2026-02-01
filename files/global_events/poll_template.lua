local MODLOADER_GE_KEY = "MODLOADER_GE_%s_%s"
local MODLOADER_GE_N = tonumber(GlobalsGetValue(MODLOADER_GE_KEY .. "_n", "0"))

if MODLOADER_GE_N > 0 then
    local MODLOADER_GE_PAYLOADS = {}

    for MODLOADER_GE_I = 0, MODLOADER_GE_N - 1 do
        MODLOADER_GE_PAYLOADS[MODLOADER_GE_I + 1] = deserialize(GlobalsGetValue(MODLOADER_GE_KEY .. "_" .. MODLOADER_GE_I, ""))
        GlobalsSetValue(MODLOADER_GE_KEY .. "_" .. MODLOADER_GE_I, "")
    end

    GlobalsSetValue(MODLOADER_GE_KEY .. "_n", "0")

    local MODLOADER_GE_LAST = MODLOADER_GE_PAYLOADS[#MODLOADER_GE_PAYLOADS]

    for _, MODLOADER_GE_H in pairs(MODLOADER_GE_HANDLERS_LAST) do
        MODLOADER_GE_H(MODLOADER_GE_LAST)
    end

    for _, MODLOADER_GE_H in pairs(MODLOADER_GE_HANDLERS_ALL) do
        MODLOADER_GE_H(MODLOADER_GE_PAYLOADS, MODLOADER_GE_N)
    end
end
