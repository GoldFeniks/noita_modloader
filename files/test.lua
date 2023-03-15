xml_parser = require("xml/xml")

local data = io.open("player.xml"):read("*a")

parser = xml_parser:new(data)
local tag = parser:parse()

print(tag:find("DamageModelComponent")[1]:to_string())

-- print([1]:to_string())

-- for i, v in ipairs(tag.__children) do
--     print(v.__name)
-- end
