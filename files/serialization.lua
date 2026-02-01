function serialize_value(value, visited)
    local t = type(value)

    if t == "nil" then
        return "nil"
    elseif t == "boolean" then
        return tostring(value)
    elseif t == "number" then
        return tostring(value)
    elseif t == "string" then
        return "'" .. value .. "'"
    elseif t == "table" then
        if visited[value] then
            error("circular reference detected")
        end
        visited[value] = true

        local parts = {}
        local array_len = #value

        for i = 1, array_len do
            parts[#parts + 1] = serialize_value(value[i], visited)
        end

        for k, v in pairs(value) do
            if type(k) ~= "number" or k < 1 or k > array_len or k ~= math.floor(k) then
                if type(k) == "string" and k:match("^[%a_][%w_]*$") then
                    parts[#parts + 1] = k .. "=" .. serialize_value(v, visited)
                else
                    parts[#parts + 1] = "[" .. serialize_value(k, visited) .. "]=" .. serialize_value(v, visited)
                end
            end
        end

        visited[value] = nil
        return "{" .. table.concat(parts, ",") .. "}"
    else
        error("cannot serialize type: " .. t)
    end
end

function serialize(value)
    return serialize_value(value, {})
end

function deserialize(str)
    local pos = 1
    local len = #str

    local parse_value

    local function parse_string()
        pos = pos + 1
        local start = pos
        while pos <= len and string.sub(str, pos, pos) ~= "'" do
            pos = pos + 1
        end
        local result = string.sub(str, start, pos - 1)
        pos = pos + 1
        return result
    end

    local function parse_number()
        local start = pos
        if string.sub(str, pos, pos) == "-" then
            pos = pos + 1
        end
        while pos <= len and string.match(string.sub(str, pos, pos), "[%d.]") do
            pos = pos + 1
        end
        if pos <= len and string.match(string.sub(str, pos, pos), "[eE]") then
            pos = pos + 1
            if pos <= len and string.match(string.sub(str, pos, pos), "[+-]") then
                pos = pos + 1
            end
            while pos <= len and string.match(string.sub(str, pos, pos), "%d") do
                pos = pos + 1
            end
        end
        return tonumber(string.sub(str, start, pos - 1))
    end

    local function parse_keyword()
        local start = pos
        while pos <= len and string.match(string.sub(str, pos, pos), "[%a_]") do
            pos = pos + 1
        end
        return string.sub(str, start, pos - 1)
    end

    local function parse_table()
        pos = pos + 1
        local result = {}
        local array_index = 1

        while pos <= len and string.sub(str, pos, pos) ~= "}" do
            if string.sub(str, pos, pos) == "," then
                pos = pos + 1
            end

            if string.sub(str, pos, pos) == "}" then
                break
            end

            if string.sub(str, pos, pos) == "[" then
                pos = pos + 1
                local key = parse_value()
                pos = pos + 1
                pos = pos + 1
                result[key] = parse_value()
            elseif string.match(string.sub(str, pos, pos), "[%a_]") then
                local word = parse_keyword()

                if pos <= len and string.sub(str, pos, pos) == "=" then
                    pos = pos + 1
                    result[word] = parse_value()
                else
                    if word == "true" then
                        result[array_index] = true
                    elseif word == "false" then
                        result[array_index] = false
                    end
                    array_index = array_index + 1
                end
            else
                result[array_index] = parse_value()
                array_index = array_index + 1
            end
        end

        pos = pos + 1
        return result
    end

    parse_value = function()
        local c = string.sub(str, pos, pos)

        if c == "{" then
            return parse_table()
        elseif c == "'" then
            return parse_string()
        elseif c == "-" or string.match(c, "%d") then
            return parse_number()
        elseif string.match(c, "[%a_]") then
            local word = parse_keyword()
            if word == "true" then
                return true
            elseif word == "false" then
                return false
            elseif word == "nil"
                then return nil
            else
                error("unknown keyword: " .. word)
            end
        else
            error("unexpected character at position " .. pos .. ": " .. c)
        end
    end

    return parse_value()
end
